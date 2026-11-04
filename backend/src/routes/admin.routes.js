import express from 'express';
import { parse } from 'csv-parse/sync';
import { z } from 'zod';
import { query, withTransaction } from '../db/pool.js';
import { config } from '../config.js';
import { asyncHandler, AppError, isPgUniqueViolation } from '../lib/errors.js';
import { auditLog } from '../lib/audit.js';
import {
  normalizeUgandaPhone,
  randomBase32Secret,
  randomToken,
  sha256Hex
} from '../lib/crypto.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import { requireAdmin } from '../middleware/roles.js';
import {
  bookingToApi,
  getBookingRow,
  approveBooking,
  rejectBooking,
  adminDisplaceBooking,
  cancelBooking
} from '../services/booking.js';
import { checkInBooking, markNoShowAdmin } from '../services/checkin.js';
import { getSettings, updateSettings, SETTING_DEFAULTS } from '../services/settings.js';
import { buildIdCardHtml, buildRoomQrSheetHtml, buildRoomQrUrl, issueIdQr } from '../services/qr.js';
import { notifyStudyModeDecision, notifyUser } from '../services/notifications.js';
import { sendEmail } from '../services/email.js';
import { getCurrentSemester } from '../services/studyMode.js';

const router = express.Router();
router.use(authenticate, requireAdmin);

const USER_ROLES = ['student', 'class_rep', 'deputy_rep', 'lecturer', 'department_admin', 'super_admin'];
const REP_ROLES = new Set(['class_rep', 'deputy_rep']);
const STUDY_MODE_ROLES = new Set(['student', 'class_rep', 'deputy_rep']);

function isSuper(user) {
  return user.role === 'super_admin';
}

function assertDepartmentScope(user, departmentId) {
  if (isSuper(user)) return;
  if (!departmentId || user.department_id !== departmentId) {
    throw new AppError(403, 'DEPARTMENT_SCOPE', 'You can only manage records in your own department.');
  }
}

async function assertBookingScope(user, bookingId) {
  if (isSuper(user)) return;
  const result = await query(
    `SELECT COALESCE(f.department_id, m.department_id) AS department_id
     FROM bookings b
     LEFT JOIN facilities f ON f.id = b.facility_id
     LEFT JOIN modules m ON m.id = b.module_id
     WHERE b.id = $1`,
    [bookingId]
  );
  assertDepartmentScope(user, result.rows[0]?.department_id);
}

async function resolveClass(client, classId) {
  if (!classId) return null;
  const result = await client.query(
    `SELECT c.*, p.department_id AS programme_department_id
     FROM classes c JOIN programmes p ON p.id = c.programme_id WHERE c.id = $1`,
    [classId]
  );
  return result.rows[0] || null;
}

async function syncClassRep(client, { userId, role, classId, adminId }) {
  if (!REP_ROLES.has(role)) {
    await client.query(
      `UPDATE class_reps SET is_active = false, revoked_at = now()
       WHERE user_id = $1 AND is_active = true`,
      [userId]
    );
    return;
  }
  if (!classId) {
    throw new AppError(400, 'CLASS_REQUIRED', 'Class representatives must be assigned to a class.');
  }
  const semester = await getCurrentSemester(client);
  if (!semester) {
    throw new AppError(409, 'NO_SEMESTER', 'No current semester is configured. Set a current semester before assigning class representatives.');
  }
  const isDeputy = role === 'deputy_rep';
  const conflict = await client.query(
    `SELECT user_id FROM class_reps
     WHERE class_id = $1 AND semester_id = $2 AND is_deputy = $3
       AND is_active = true AND user_id <> $4`,
    [classId, semester.id, isDeputy, userId]
  );
  if (conflict.rowCount) {
    throw new AppError(
      409,
      'CLASS_REP_SLOT_FILLED',
      `This class already has an active ${isDeputy ? 'deputy ' : ''}class representative. Demote or move the current representative first.`
    );
  }
  await client.query(
    `UPDATE class_reps SET is_active = false, revoked_at = now()
     WHERE user_id = $1 AND is_active = true
       AND NOT (class_id = $2 AND semester_id = $3 AND is_deputy = $4)`,
    [userId, classId, semester.id, isDeputy]
  );
  const existing = await client.query(
    `SELECT id FROM class_reps
     WHERE user_id = $1 AND class_id = $2 AND semester_id = $3 AND is_deputy = $4
     ORDER BY assigned_at DESC LIMIT 1`,
    [userId, classId, semester.id, isDeputy]
  );
  if (existing.rowCount) {
    await client.query(
      `UPDATE class_reps
       SET is_active = true, is_available = true, assigned_by = $2,
           assigned_at = now(), revoked_at = NULL
       WHERE id = $1`,
      [existing.rows[0].id, adminId]
    );
    return;
  }
  await client.query(
    `INSERT INTO class_reps (user_id, class_id, semester_id, is_deputy, is_active, is_available, assigned_by)
     VALUES ($1,$2,$3,$4,true,true,$5)`,
    [userId, classId, semester.id, isDeputy, adminId]
  );
}

async function createUserRecord({ admin, input, req }) {
  const result = await withTransaction(async (client) => {
    const classRow = await resolveClass(client, input.class_id || null);
    if (input.class_id && !classRow) throw new AppError(404, 'CLASS_NOT_FOUND', 'Class not found.');
    if (input.department_id && classRow && input.department_id !== classRow.programme_department_id) {
      throw new AppError(400, 'CLASS_DEPARTMENT_MISMATCH', 'The class does not belong to that department.');
    }
    const departmentId = input.department_id || classRow?.programme_department_id || null;
    if (departmentId) assertDepartmentScope(admin, departmentId);
    if (!isSuper(admin) && input.role === 'super_admin') {
      throw new AppError(403, 'ROLE_FORBIDDEN', 'Only a super administrator can create another super administrator.');
    }
    if (['student', 'class_rep', 'deputy_rep'].includes(input.role) && !classRow) {
      throw new AppError(400, 'CLASS_REQUIRED', 'Students and class representatives must be assigned to a class.');
    }
    if (['department_admin', 'lecturer'].includes(input.role) && !departmentId) {
      throw new AppError(400, 'DEPARTMENT_REQUIRED', 'Staff accounts must be assigned to a department.');
    }
    const studyMode = input.study_mode || classRow?.default_study_mode || 'physical';
    if (input.study_mode && STUDY_MODE_ROLES.has(input.role) && classRow && input.study_mode !== classRow.default_study_mode) {
      throw new AppError(400, 'STUDY_MODE_APPROVAL_REQUIRED', 'Student study mode must be changed through a reviewed study mode request.');
    }
    const rawQrToken = randomToken(32);
    const handle = `h-${randomToken(12).toLowerCase().replace(/[^a-z0-9]/g, '').slice(0, 12)}`;
    const qrSecret = randomBase32Secret(20);
    const phone = input.phone ? normalizeUgandaPhone(input.phone) : null;
    if (input.phone && !phone) throw new AppError(400, 'INVALID_PHONE', `Invalid phone number for ${input.id_number}.`);
    let user;
    try {
      const inserted = await client.query(
        `INSERT INTO users (id_number, name, email, phone, role, department_id, class_id, study_mode,
           qr_token_hash, qr_handle, qr_secret, sms_link_opt_in, consent_at)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,false,NULL)
         RETURNING *`,
        [
          String(input.id_number).trim(),
          String(input.name).trim(),
          String(input.email).trim(),
          phone,
          input.role,
          departmentId,
          classRow?.id || null,
          studyMode,
          sha256Hex(rawQrToken),
          handle,
          qrSecret
        ]
      );
      user = inserted.rows[0];
    } catch (error) {
      if (isPgUniqueViolation(error)) {
        throw new AppError(409, 'USER_EXISTS', `A user with ID number ${input.id_number} or that email already exists.`);
      }
      throw error;
    }
    await syncClassRep(client, {
      userId: user.id,
      role: input.role,
      classId: classRow?.id || null,
      adminId: admin.id
    });
    const activationToken = randomToken(32);
    await client.query(
      `INSERT INTO user_activation_tokens (user_id, token_hash, expires_at)
       VALUES ($1,$2,now() + interval '7 days')`,
      [user.id, sha256Hex(activationToken)]
    );
    return { user, activationToken, rawQrToken };
  });
  let emailSent = false;
  let emailError = null;
  const activationLink = `${config.primaryFrontendUrl}/activate.html?token=${encodeURIComponent(result.activationToken)}`;
  try {
    const sendResult = await sendEmail({
      to: result.user.email,
      subject: 'Activate your campus account',
      text: `Hello ${result.user.name},\n\nYour campus account (${result.user.id_number}) has been created. Activate it here: ${activationLink}\n\nThis link expires in 7 days.`,
      html: `<p>Hello ${result.user.name},</p><p>Your campus account (<strong>${result.user.id_number}</strong>) has been created.</p><p><a href="${activationLink}">Activate your account</a></p><p>This link expires in 7 days.</p>`
    });
    emailSent = sendResult?.sent !== false;
    emailError = sendResult?.error || null;
  } catch (error) {
    emailError = error.message;
  }
  await auditLog({
    req,
    userId: admin.id,
    action: 'admin.user_created',
    entityType: 'user',
    entityId: result.user.id,
    details: { role: result.user.role, department_id: result.user.department_id, email_sent: emailSent }
  });
  return {
    user: result.user,
    activation_link: activationLink,
    activation_token: result.activationToken,
    id_qr_token: result.rawQrToken,
    email_sent: emailSent,
    email_error: emailError
  };
}

const userCreateSchema = z.object({
  id_number: z.string().min(2).max(50),
  name: z.string().min(2).max(200),
  email: z.string().email().max(200),
  phone: z.string().max(30).optional(),
  role: z.enum(USER_ROLES).default('student'),
  department_id: z.string().uuid().nullable().optional(),
  class_id: z.string().uuid().nullable().optional(),
  study_mode: z.enum(['physical', 'online', 'hybrid']).optional()
});

router.get(
  '/dashboard',
  asyncHandler(async (req, res) => {
    const params = [];
    const scoped = !isSuper(req.user);
    if (scoped) params.push(req.user.department_id);
    const userScope = scoped ? 'AND u.department_id = $1' : '';
    const facilityScope = scoped ? 'AND f.department_id = $1' : '';
    const bookingScope = scoped ? 'AND COALESCE(bf.department_id, bm.department_id) = $1' : '';
    const issueScope = scoped ? 'AND rf.department_id = $1' : '';
    const notificationScope = scoped ? 'AND nu.department_id = $1' : '';
    const counts = await query(
      `SELECT
         (SELECT count(*)::int FROM users u WHERE u.is_active = true ${userScope}) AS users,
         (SELECT count(*)::int FROM facilities f WHERE f.status = 'active' ${facilityScope}) AS facilities,
         (SELECT count(*)::int FROM bookings b
           LEFT JOIN facilities bf ON bf.id = b.facility_id
           LEFT JOIN modules bm ON bm.id = b.module_id
           WHERE b.status = 'pending' ${bookingScope}) AS pending_bookings,
         (SELECT count(*)::int FROM bookings b
           LEFT JOIN facilities bf ON bf.id = b.facility_id
           LEFT JOIN modules bm ON bm.id = b.module_id
           WHERE b.status = 'confirmed' AND b.start_at::date = current_date ${bookingScope}) AS sessions_today,
         (SELECT count(*)::int FROM room_issues ri JOIN facilities rf ON rf.id = ri.facility_id
           WHERE ri.status = 'open' ${issueScope}) AS open_issues,
         (SELECT count(*)::int FROM study_mode_requests r JOIN users u ON u.id = r.user_id
           WHERE r.status = 'pending' AND u.role IN ('student','class_rep','deputy_rep') ${userScope}) AS pending_study_mode,
         (SELECT count(*)::int FROM data_requests r JOIN users u ON u.id = r.user_id
           WHERE r.status = 'pending' ${userScope}) AS pending_data_requests,
         (SELECT count(*)::int FROM notification_queue nq JOIN users nu ON nu.id = nq.user_id
           WHERE nq.status = 'failed' ${notificationScope}) AS failed_notifications`,
      params
    );
    const alerts = await query(
      `SELECT id, title, message, severity, created_at FROM notifications
       WHERE severity IN ('warning','critical') AND created_at > now() - interval '7 days'
       ORDER BY created_at DESC LIMIT 10`
    );
    res.json({ counts: counts.rows[0], alerts: alerts.rows });
  })
);

router.get(
  '/users',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [];
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      conditions.push(`u.department_id = $${params.length}`);
    }
    if (req.query.role) {
      params.push(req.query.role);
      conditions.push(`u.role = $${params.length}`);
    }
    if (req.query.class_id) {
      params.push(req.query.class_id);
      conditions.push(`u.class_id = $${params.length}`);
    }
    if (req.query.department_id && isSuper(req.user)) {
      params.push(req.query.department_id);
      conditions.push(`u.department_id = $${params.length}`);
    }
    if (req.query.q) {
      params.push(`%${String(req.query.q).toLowerCase()}%`);
      conditions.push(`(lower(u.name) LIKE $${params.length} OR lower(u.id_number) LIKE $${params.length} OR lower(u.email) LIKE $${params.length})`);
    }
    const limit = Math.min(Math.max(Number(req.query.limit || 100), 1), 500);
    params.push(limit);
    const result = await query(
      `SELECT u.id, u.id_number, u.name, u.email, u.phone, u.role, u.department_id, u.class_id,
              u.study_mode, u.qr_active, u.is_active, u.flagged_for_review, u.last_verified_at,
              u.created_at, d.code AS department_code, c.code AS class_code
       FROM users u
       LEFT JOIN departments d ON d.id = u.department_id
       LEFT JOIN classes c ON c.id = u.class_id
       ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
       ORDER BY u.name
       LIMIT $${params.length}`,
      params
    );
    res.json({ users: result.rows });
  })
);

router.post(
  '/users',
  validate(userCreateSchema),
  asyncHandler(async (req, res) => {
    const result = await createUserRecord({ admin: req.user, input: req.body, req });
    res.status(201).json(result);
  })
);

router.post(
  '/users/import',
  validate(z.object({ csv: z.string().min(10).max(1000000) })),
  asyncHandler(async (req, res) => {
    const rows = parse(req.body.csv, {
      columns: (header) => header.map((value) => String(value).trim().toLowerCase()),
      skip_empty_lines: true,
      trim: true,
      bom: true,
      relax_column_count: true
    });
    if (rows.length > 300) throw new AppError(400, 'CSV_TOO_LARGE', 'Import at most 300 users at a time.');
    const departments = await query('SELECT id, code FROM departments');
    const classes = await query('SELECT id, code FROM classes');
    const departmentByCode = new Map(departments.rows.map((row) => [row.code.toLowerCase(), row.id]));
    const classByCode = new Map(classes.rows.map((row) => [row.code.toLowerCase(), row.id]));
    const results = [];
    for (const [index, row] of rows.entries()) {
      try {
        const result = await createUserRecord({
          admin: req.user,
          input: {
            id_number: row.id_number,
            name: row.name,
            email: row.email,
            phone: row.phone,
            role: row.role || 'student',
            department_id: row.department_code ? departmentByCode.get(String(row.department_code).toLowerCase()) : null,
            class_id: row.class_code ? classByCode.get(String(row.class_code).toLowerCase()) : null,
            study_mode: row.study_mode || undefined
          },
          req
        });
        results.push({ line: index + 2, status: 'created', user_id: result.user.id, activation_link: result.activation_link });
      } catch (error) {
        results.push({ line: index + 2, status: 'failed', error: error.message });
      }
    }
    const created = results.filter((row) => row.status === 'created').length;
    res.json({ total: results.length, created, failed: results.length - created, results });
  })
);

router.post(
  '/users/id-cards',
  validate(z.object({ user_ids: z.array(z.string().uuid()).min(1).max(100) })),
  asyncHandler(async (req, res) => {
    const cards = [];
    for (const userId of req.body.user_ids) {
      const target = await query('SELECT id, name, id_number, role, department_id FROM users WHERE id = $1', [userId]);
      const user = target.rows[0];
      if (!user) continue;
      if (!isSuper(req.user)) assertDepartmentScope(req.user, user.department_id);
      const issued = await issueIdQr(user.id, req);
      cards.push({ ...user, print_token: issued.token });
    }
    await auditLog({ req, action: 'admin.id_cards_printed', details: { count: cards.length } });
    res.type('html').send(await buildIdCardHtml(cards));
  })
);

router.get(
  '/users/:id',
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT u.*, d.name AS department_name, c.code AS class_code, c.name AS class_name
       FROM users u LEFT JOIN departments d ON d.id = u.department_id
       LEFT JOIN classes c ON c.id = u.class_id WHERE u.id = $1`,
      [req.params.id]
    );
    const user = result.rows[0];
    if (!user) throw new AppError(404, 'USER_NOT_FOUND', 'User not found.');
    if (!isSuper(req.user)) assertDepartmentScope(req.user, user.department_id);
    delete user.password_hash;
    delete user.pin_hash;
    delete user.qr_secret;
    delete user.qr_token_hash;
    const bookings = await query(
      `SELECT count(*)::int AS total,
              count(*) FILTER (WHERE status IN ('pending','confirmed') AND start_at > now())::int AS upcoming,
              count(*) FILTER (WHERE status = 'cancelled')::int AS cancelled
       FROM bookings WHERE user_id = $1`,
      [user.id]
    );
    const noShows = await query(
      `SELECT id, booking_id, marked_at, reason FROM no_shows WHERE user_id = $1 ORDER BY marked_at DESC LIMIT 20`,
      [user.id]
    );
    const requests = await query(
      `SELECT id, type, status, requested_at, processed_at FROM data_requests WHERE user_id = $1 ORDER BY requested_at DESC`,
      [user.id]
    );
    res.json({ user, booking_counts: bookings.rows[0], no_shows: noShows.rows, data_requests: requests.rows });
  })
);

router.patch(
  '/users/:id',
  validate(
    z.object({
      name: z.string().min(2).max(200).optional(),
      role: z.enum(USER_ROLES).optional(),
      department_id: z.string().uuid().nullable().optional(),
      class_id: z.string().uuid().nullable().optional(),
      is_active: z.boolean().optional(),
      flagged_for_review: z.boolean().optional(),
      flagged_reason: z.string().max(1000).nullable().optional(),
      sms_link_opt_in: z.boolean().optional()
    })
  ),
  asyncHandler(async (req, res) => {
    const updated = await withTransaction(async (client) => {
      const existing = await client.query('SELECT * FROM users WHERE id = $1', [req.params.id]);
      const user = existing.rows[0];
      if (!user) throw new AppError(404, 'USER_NOT_FOUND', 'User not found.');
      if (!isSuper(req.user)) assertDepartmentScope(req.user, user.department_id);

      const has = (key) => Object.prototype.hasOwnProperty.call(req.body, key);
      const nextRole = has('role') ? req.body.role : user.role;
      const nextClassId = has('class_id') ? req.body.class_id : user.class_id;
      const nextActive = has('is_active') ? req.body.is_active : user.is_active;
      let nextDepartmentId = has('department_id') ? req.body.department_id : user.department_id;
      const roleChanging = nextRole !== user.role;
      const classChanging = nextClassId !== user.class_id;
      const activeChanging = nextActive !== user.is_active;

      if (!isSuper(req.user)) {
        if (nextRole === 'super_admin') {
          throw new AppError(403, 'ROLE_FORBIDDEN', 'Only a super administrator can grant that role.');
        }
        if (nextDepartmentId && nextDepartmentId !== req.user.department_id) {
          throw new AppError(403, 'ROLE_FORBIDDEN', 'You cannot move a user to another department.');
        }
      }

      if (nextClassId) {
        const classRow = await resolveClass(client, nextClassId);
        if (!classRow) throw new AppError(404, 'CLASS_NOT_FOUND', 'Class not found.');
        assertDepartmentScope(req.user, classRow.programme_department_id);
        if (has('department_id') && nextDepartmentId && nextDepartmentId !== classRow.programme_department_id) {
          throw new AppError(400, 'CLASS_DEPARTMENT_MISMATCH', 'The class does not belong to that department.');
        }
        if (!nextDepartmentId) {
          nextDepartmentId = classRow.programme_department_id;
        }
      }
      if (nextDepartmentId) assertDepartmentScope(req.user, nextDepartmentId);

      if (['student', 'class_rep', 'deputy_rep'].includes(nextRole) && !nextClassId) {
        throw new AppError(400, 'CLASS_REQUIRED', 'Students and class representatives must be assigned to a class.');
      }
      if (['department_admin', 'lecturer'].includes(nextRole) && !nextDepartmentId) {
        throw new AppError(400, 'DEPARTMENT_REQUIRED', 'Staff accounts must be assigned to a department.');
      }
      if (user.id === req.user.id && !nextActive) {
        throw new AppError(400, 'SELF_DEACTIVATE', 'You cannot deactivate your own account.');
      }

      const updates = {};
      for (const key of ['name', 'role', 'department_id', 'class_id', 'is_active', 'flagged_for_review', 'flagged_reason', 'sms_link_opt_in']) {
        if (has(key)) updates[key] = req.body[key];
      }
      if (has('class_id') && nextDepartmentId !== user.department_id) {
        updates.department_id = nextDepartmentId;
      }
      if (!Object.keys(updates).length) throw new AppError(400, 'NO_CHANGES', 'No changes supplied.');

      const fields = [];
      const params = [user.id];
      for (const [key, value] of Object.entries(updates)) {
        params.push(value);
        fields.push(`${key} = $${params.length}`);
      }
      const result = await client.query(
        `UPDATE users SET ${fields.join(', ')}, updated_at = now()
         WHERE id = $1 RETURNING id, id_number, name, email, role, department_id, class_id, study_mode, is_active`,
        params
      );
      const fresh = result.rows[0];

      if (roleChanging || classChanging || activeChanging) {
        if (nextActive) {
          await syncClassRep(client, {
            userId: user.id,
            role: fresh.role,
            classId: fresh.class_id,
            adminId: req.user.id
          });
        } else {
          await client.query(
            `UPDATE class_reps SET is_active = false, revoked_at = now() WHERE user_id = $1 AND is_active = true`,
            [user.id]
          );
        }
      }
      if (!nextActive) {
        await client.query(
          `UPDATE auth_sessions SET revoked_at = now(), revoked_reason = 'account_deactivated'
           WHERE user_id = $1 AND revoked_at IS NULL`,
          [user.id]
        );
      }
      return fresh;
    });

    await auditLog({
      req,
      action: 'admin.user_updated',
      entityType: 'user',
      entityId: updated.id,
      details: { fields: Object.keys(req.body) }
    });
    res.json({ user: updated });
  })
);

router.post(
  '/users/:id/id-qr',
  asyncHandler(async (req, res) => {
    const target = await query('SELECT id, name, id_number, role, department_id FROM users WHERE id = $1', [req.params.id]);
    const user = target.rows[0];
    if (!user) throw new AppError(404, 'USER_NOT_FOUND', 'User not found.');
    if (!isSuper(req.user)) assertDepartmentScope(req.user, user.department_id);
    const issued = await issueIdQr(user.id, req);
    await auditLog({ req, action: 'admin.id_qr_reissued', entityType: 'user', entityId: user.id });
    res.json({ ...issued, warning: 'The previous ID QR has been invalidated. Print and issue this new code.' });
  })
);

router.post(
  '/users/:id/unlock',
  asyncHandler(async (req, res) => {
    const target = await query('SELECT id, department_id FROM users WHERE id = $1', [req.params.id]);
    if (!target.rows[0]) throw new AppError(404, 'USER_NOT_FOUND', 'User not found.');
    if (!isSuper(req.user)) assertDepartmentScope(req.user, target.rows[0].department_id);
    await query(
      `UPDATE users SET locked_until = NULL, failed_attempts = 0, flagged_for_review = false,
         flagged_reason = NULL, updated_at = now() WHERE id = $1`,
      [req.params.id]
    );
    await auditLog({ req, action: 'admin.user_unlocked', entityType: 'user', entityId: req.params.id });
    res.json({ unlocked: true });
  })
);

router.post(
  '/users/:id/revoke-sessions',
  asyncHandler(async (req, res) => {
    const target = await query('SELECT id, department_id FROM users WHERE id = $1', [req.params.id]);
    if (!target.rows[0]) throw new AppError(404, 'USER_NOT_FOUND', 'User not found.');
    if (!isSuper(req.user)) assertDepartmentScope(req.user, target.rows[0].department_id);
    const result = await query(
      `UPDATE auth_sessions SET revoked_at = now(), revoked_reason = 'admin_revoked'
       WHERE user_id = $1 AND revoked_at IS NULL`,
      [req.params.id]
    );
    await auditLog({ req, action: 'admin.sessions_revoked', entityType: 'user', entityId: req.params.id });
    res.json({ revoked: result.rowCount });
  })
);

router.post(
  '/users/:id/reset-password',
  asyncHandler(async (req, res) => {
    const target = await query('SELECT id, name, email, department_id FROM users WHERE id = $1', [req.params.id]);
    const user = target.rows[0];
    if (!user) throw new AppError(404, 'USER_NOT_FOUND', 'User not found.');
    if (!isSuper(req.user)) assertDepartmentScope(req.user, user.department_id);
    const token = randomToken(32);
    await query(
      `INSERT INTO password_reset_tokens (user_id, token_hash, expires_at)
       VALUES ($1,$2,now() + interval '1 hour')`,
      [user.id, sha256Hex(token)]
    );
    const link = `${config.primaryFrontendUrl}/reset.html?token=${encodeURIComponent(token)}`;
    let sent = false;
    try {
      const result = await sendEmail({
        to: user.email,
        subject: 'Reset your campus password',
        text: `Hello ${user.name}, reset your password here: ${link}`,
        html: `<p>Hello ${user.name},</p><p><a href="${link}">Reset your password</a>. This link expires in one hour.</p>`
      });
      sent = result?.sent !== false;
    } catch (error) {
      console.error('[admin] reset email failed', error.message);
    }
    await auditLog({ req, action: 'admin.password_reset_sent', entityType: 'user', entityId: user.id });
    res.json({ sent, reset_link: link });
  })
);

router.get(
  '/facilities',
  asyncHandler(async (req, res) => {
    const params = [];
    let where = '';
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      where = `WHERE f.department_id = $1`;
    }
    const result = await query(
      `SELECT f.*, d.code AS department_code, d.name AS department_name,
              count(DISTINCT b.id)::int AS session_count
       FROM facilities f JOIN departments d ON d.id = f.department_id
       LEFT JOIN bookings b ON b.facility_id = f.id AND b.start_at > now()
       ${where}
       GROUP BY f.id, d.code, d.name
       ORDER BY f.building, f.floor, f.room_number`,
      params
    );
    res.json({ facilities: result.rows.map(({ qr_secret, ...row }) => row) });
  })
);

router.post(
  '/facilities',
  validate(
    z.object({
      name: z.string().min(2).max(200),
      category: z.enum(['lecture_room', 'discussion_room', 'lab', 'office', 'library']),
      department_id: z.string().uuid(),
      building: z.string().min(1).max(100),
      floor: z.string().max(50).optional(),
      wing: z.string().max(100).optional(),
      room_number: z.string().min(1).max(50),
      location_description: z.string().max(1000).optional(),
      latitude: z.number().min(-90).max(90),
      longitude: z.number().min(-180).max(180),
      capacity: z.number().int().min(1).max(10000),
      status: z.enum(['active', 'blocked', 'maintenance']).optional(),
      requires_approval: z.boolean().optional(),
      requires_authorized_role: z.boolean().optional(),
      checkin_mode: z.enum(['rotating', 'static_geo']).optional(),
      checkin_radius_m: z.number().int().min(10).max(5000).optional(),
      photo_url: z.string().max(1000).optional(),
      equipment: z.array(z.object({ name: z.string().min(1).max(100), quantity: z.number().int().min(0).max(10000) })).max(50).optional()
    })
  ),
  asyncHandler(async (req, res) => {
    assertDepartmentScope(req.user, req.body.department_id);
    const settings = await getSettings(['default_checkin_radius_m']);
    const qrSecret = randomToken(32);
    let facility;
    try {
      const result = await query(
        `INSERT INTO facilities (name, category, department_id, building, floor, wing, room_number,
           location_description, latitude, longitude, capacity, status, requires_approval,
           requires_authorized_role, checkin_mode, checkin_radius_m, qr_secret, photo_url)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18)
         RETURNING *`,
        [
          req.body.name,
          req.body.category,
          req.body.department_id,
          req.body.building,
          req.body.floor || 'Ground',
          req.body.wing || null,
          req.body.room_number,
          req.body.location_description || '',
          req.body.latitude,
          req.body.longitude,
          req.body.capacity,
          req.body.status || 'active',
          req.body.requires_approval || false,
          req.body.requires_authorized_role || false,
          req.body.checkin_mode || 'static_geo',
          req.body.checkin_radius_m || Number(settings.default_checkin_radius_m || 100),
          qrSecret,
          req.body.photo_url || null
        ]
      );
      facility = result.rows[0];
    } catch (error) {
      if (isPgUniqueViolation(error)) throw new AppError(409, 'FACILITY_EXISTS', 'That building and room number already exists.');
      throw error;
    }
    for (const item of req.body.equipment || []) {
      await query(
        `INSERT INTO facility_equipment (facility_id, name, quantity) VALUES ($1,$2,$3)
         ON CONFLICT (facility_id, name) DO UPDATE SET quantity = EXCLUDED.quantity`,
        [facility.id, item.name, item.quantity]
      );
    }
    await auditLog({ req, action: 'admin.facility_created', entityType: 'facility', entityId: facility.id });
    const { qr_secret, ...safe } = facility;
    res.status(201).json({ facility: safe, room_qr_url: buildRoomQrUrl(facility) });
  })
);

router.get(
  '/facilities/qr-sheet',
  asyncHandler(async (req, res) => {
    const params = [];
    let where = '';
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      where = 'WHERE department_id = $1';
    }
    const result = await query(
      `SELECT * FROM facilities ${where} ORDER BY building, floor, room_number`,
      params
    );
    await auditLog({ req, action: 'admin.room_qr_sheet', details: { count: result.rowCount } });
    res.type('html').send(await buildRoomQrSheetHtml(result.rows, 'Room QR codes'));
  })
);

router.get(
  '/facilities/:id',
  asyncHandler(async (req, res) => {
    const result = await query('SELECT * FROM facilities WHERE id = $1', [req.params.id]);
    const facility = result.rows[0];
    if (!facility) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
    assertDepartmentScope(req.user, facility.department_id);
    const equipment = await query('SELECT id, name, quantity FROM facility_equipment WHERE facility_id = $1 ORDER BY name', [facility.id]);
    const blocks = await query('SELECT * FROM facility_blocks WHERE facility_id = $1 AND end_at > now() ORDER BY start_at', [facility.id]);
    const displays = await query(
      `SELECT id, label, last_seen_at, revoked_at, created_at FROM display_devices WHERE facility_id = $1`,
      [facility.id]
    );
    const { qr_secret, ...safe } = facility;
    res.json({
      facility: safe,
      room_qr_url: buildRoomQrUrl(facility),
      equipment: equipment.rows,
      blocks: blocks.rows,
      displays: displays.rows
    });
  })
);

router.patch(
  '/facilities/:id',
  validate(
    z.object({
      name: z.string().min(2).max(200).optional(),
      category: z.enum(['lecture_room', 'discussion_room', 'lab', 'office', 'library']).optional(),
      department_id: z.string().uuid().optional(),
      building: z.string().min(1).max(100).optional(),
      floor: z.string().max(50).optional(),
      wing: z.string().max(100).nullable().optional(),
      room_number: z.string().min(1).max(50).optional(),
      location_description: z.string().max(1000).optional(),
      latitude: z.number().min(-90).max(90).optional(),
      longitude: z.number().min(-180).max(180).optional(),
      capacity: z.number().int().min(1).max(10000).optional(),
      status: z.enum(['active', 'blocked', 'maintenance']).optional(),
      requires_approval: z.boolean().optional(),
      requires_authorized_role: z.boolean().optional(),
      checkin_mode: z.enum(['rotating', 'static_geo']).optional(),
      checkin_radius_m: z.number().int().min(10).max(5000).optional(),
      photo_url: z.string().max(1000).nullable().optional(),
      last_verified_at: z.string().optional(),
      equipment: z.array(z.object({ name: z.string().min(1).max(100), quantity: z.number().int().min(0).max(10000) })).max(50).optional()
    })
  ),
  asyncHandler(async (req, res) => {
    const existing = await query('SELECT * FROM facilities WHERE id = $1', [req.params.id]);
    const facility = existing.rows[0];
    if (!facility) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
    assertDepartmentScope(req.user, facility.department_id);
    if (req.body.department_id) assertDepartmentScope(req.user, req.body.department_id);
    const fields = [];
    const params = [facility.id];
    const allowed = [
      'name', 'category', 'department_id', 'building', 'floor', 'wing', 'room_number',
      'location_description', 'latitude', 'longitude', 'capacity', 'status', 'requires_approval',
      'requires_authorized_role', 'checkin_mode', 'checkin_radius_m', 'photo_url', 'last_verified_at'
    ];
    for (const key of allowed) {
      if (req.body[key] !== undefined) {
        params.push(req.body[key]);
        fields.push(`${key} = $${params.length}`);
      }
    }
    if (!fields.length && !req.body.equipment) throw new AppError(400, 'NO_CHANGES', 'No changes supplied.');
    if (fields.length) {
      const updated = await query(
        `UPDATE facilities SET ${fields.join(', ')}, updated_at = now() WHERE id = $1 RETURNING *`,
        params
      );
      facility.name = updated.rows[0].name;
    }
    if (req.body.equipment) {
      await withTransaction(async (client) => {
        await client.query('DELETE FROM facility_equipment WHERE facility_id = $1', [facility.id]);
        for (const item of req.body.equipment) {
          await client.query(
            'INSERT INTO facility_equipment (facility_id, name, quantity) VALUES ($1,$2,$3)',
            [facility.id, item.name, item.quantity]
          );
        }
      });
    }
    await auditLog({
      req,
      action: 'admin.facility_updated',
      entityType: 'facility',
      entityId: facility.id,
      details: { fields: Object.keys(req.body) }
    });
    const fresh = await query('SELECT * FROM facilities WHERE id = $1', [facility.id]);
    const { qr_secret, ...safe } = fresh.rows[0];
    res.json({ facility: safe });
  })
);

router.post(
  '/facilities/:id/regenerate-qr',
  asyncHandler(async (req, res) => {
    const existing = await query('SELECT * FROM facilities WHERE id = $1', [req.params.id]);
    const facility = existing.rows[0];
    if (!facility) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
    assertDepartmentScope(req.user, facility.department_id);
    const updated = await query(
      `UPDATE facilities SET qr_version = qr_version + 1, qr_secret = $2,
         qr_regenerated_at = now(), updated_at = now()
       WHERE id = $1 RETURNING *`,
      [facility.id, randomToken(32)]
    );
    await auditLog({
      req,
      action: 'admin.facility_qr_regenerated',
      entityType: 'facility',
      entityId: facility.id,
      details: { old_version: facility.qr_version, new_version: updated.rows[0].qr_version }
    });
    res.json({
      qr_version: updated.rows[0].qr_version,
      room_qr_url: buildRoomQrUrl(updated.rows[0]),
      warning: 'All previously printed QR codes for this room are now invalid. Reprint the room QR sheet.'
    });
  })
);

router.post(
  '/facilities/:id/blocks',
  validate(
    z.object({
      start_at: z.string().min(8).max(60),
      end_at: z.string().min(8).max(60),
      reason: z.string().min(3).max(500)
    })
  ),
  asyncHandler(async (req, res) => {
    const existing = await query('SELECT * FROM facilities WHERE id = $1', [req.params.id]);
    const facility = existing.rows[0];
    if (!facility) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
    assertDepartmentScope(req.user, facility.department_id);
    const start = new Date(req.body.start_at);
    const end = new Date(req.body.end_at);
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime()) || end <= start) {
      throw new AppError(400, 'INVALID_TIMES', 'Provide a valid maintenance window.');
    }
    const conflicts = await query(
      `SELECT b.id, b.start_at, b.end_at, m.code AS module_code
       FROM bookings b LEFT JOIN modules m ON m.id = b.module_id
       WHERE b.facility_id = $1 AND b.status IN ('pending','confirmed')
         AND b.start_at < $3 AND b.end_at > $2`,
      [facility.id, start, end]
    );
    const result = await query(
      `INSERT INTO facility_blocks (facility_id, start_at, end_at, reason, created_by)
       VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [facility.id, start, end, req.body.reason, req.user.id]
    );
    await auditLog({
      req,
      action: 'admin.facility_block_created',
      entityType: 'facility_block',
      entityId: result.rows[0].id,
      details: { facility_id: facility.id, conflicts: conflicts.rowCount }
    });
    res.status(201).json({ block: result.rows[0], conflicting_bookings: conflicts.rows });
  })
);

router.delete(
  '/facilities/:facilityId/blocks/:blockId',
  asyncHandler(async (req, res) => {
    const existing = await query('SELECT * FROM facilities WHERE id = $1', [req.params.facilityId]);
    const facility = existing.rows[0];
    if (!facility) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
    assertDepartmentScope(req.user, facility.department_id);
    const result = await query(
      'DELETE FROM facility_blocks WHERE id = $1 AND facility_id = $2 RETURNING id',
      [req.params.blockId, facility.id]
    );
    if (!result.rowCount) throw new AppError(404, 'BLOCK_NOT_FOUND', 'Maintenance block not found.');
    await auditLog({
      req,
      action: 'admin.facility_block_deleted',
      entityType: 'facility_block',
      entityId: req.params.blockId
    });
    res.json({ deleted: true });
  })
);

router.post(
  '/facilities/:id/displays',
  validate(z.object({ label: z.string().min(2).max(100) })),
  asyncHandler(async (req, res) => {
    const existing = await query('SELECT * FROM facilities WHERE id = $1', [req.params.id]);
    const facility = existing.rows[0];
    if (!facility) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
    assertDepartmentScope(req.user, facility.department_id);
    const key = randomToken(24);
    const result = await query(
      `INSERT INTO display_devices (facility_id, key_hash, label, created_by)
       VALUES ($1,$2,$3,$4) RETURNING id, facility_id, label, created_at`,
      [facility.id, sha256Hex(key), req.body.label, req.user.id]
    );
    await auditLog({
      req,
      action: 'admin.display_created',
      entityType: 'display_device',
      entityId: result.rows[0].id,
      details: { facility_id: facility.id }
    });
    res.status(201).json({
      display: result.rows[0],
      key,
      display_url: `${config.primaryFrontendUrl}/display.html?device=${result.rows[0].id}`,
      warning: 'Store this display key now. It cannot be shown again.'
    });
  })
);

router.delete(
  '/displays/:id',
  asyncHandler(async (req, res) => {
    const result = await query(
      `UPDATE display_devices SET revoked_at = now() WHERE id = $1 AND revoked_at IS NULL RETURNING id, facility_id`,
      [req.params.id]
    );
    if (!result.rowCount) throw new AppError(404, 'DISPLAY_NOT_FOUND', 'Display device not found.');
    const facility = await query('SELECT department_id FROM facilities WHERE id = $1', [result.rows[0].facility_id]);
    if (!isSuper(req.user)) assertDepartmentScope(req.user, facility.rows[0]?.department_id);
    await auditLog({ req, action: 'admin.display_revoked', entityType: 'display_device', entityId: req.params.id });
    res.json({ revoked: true });
  })
);

router.get(
  '/bookings',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [];
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      conditions.push(`COALESCE(f.department_id, m.department_id) = $${params.length}`);
    }
    if (req.query.status) {
      params.push(req.query.status);
      conditions.push(`b.status = $${params.length}`);
    }
    if (req.query.facility_id) {
      params.push(req.query.facility_id);
      conditions.push(`b.facility_id = $${params.length}`);
    }
    if (req.query.user_id) {
      params.push(req.query.user_id);
      conditions.push(`b.user_id = $${params.length}`);
    }
    if (req.query.from) {
      params.push(req.query.from);
      conditions.push(`b.end_at > $${params.length}`);
    }
    if (req.query.to) {
      params.push(req.query.to);
      conditions.push(`b.start_at < $${params.length}`);
    }
    const limit = Math.min(Math.max(Number(req.query.limit || 200), 1), 500);
    params.push(limit);
    const result = await query(
      `SELECT b.id FROM bookings b
       LEFT JOIN facilities f ON f.id = b.facility_id
       LEFT JOIN modules m ON m.id = b.module_id
       ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
       ORDER BY b.start_at DESC LIMIT $${params.length}`,
      params
    );
    const rows = [];
    for (const item of result.rows) {
      const row = await getBookingRow({ query }, item.id);
      if (row) rows.push(bookingToApi(row, req.user, { includeOnlineLink: true }));
    }
    res.json({ bookings: rows });
  })
);

router.get(
  '/bookings/pending',
  asyncHandler(async (req, res) => {
    const params = [];
    let scope = '';
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      scope = `AND COALESCE(f.department_id, m.department_id) = $1`;
    }
    const result = await query(
      `SELECT b.id FROM bookings b
       LEFT JOIN facilities f ON f.id = b.facility_id
       LEFT JOIN modules m ON m.id = b.module_id
       WHERE b.status = 'pending' ${scope}
       ORDER BY b.start_at LIMIT 200`,
      params
    );
    const rows = [];
    for (const item of result.rows) {
      const row = await getBookingRow({ query }, item.id);
      if (row) rows.push(bookingToApi(row, req.user, { includeOnlineLink: true }));
    }
    res.json({ bookings: rows });
  })
);

router.post(
  '/bookings/:id/approve',
  asyncHandler(async (req, res) => {
    await assertBookingScope(req.user, req.params.id);
    const booking = await approveBooking({ bookingId: req.params.id, admin: req.user, req, note: req.body?.note });
    res.json({ booking });
  })
);

router.post(
  '/bookings/:id/reject',
  validate(z.object({ reason: z.string().min(3).max(1000) })),
  asyncHandler(async (req, res) => {
    await assertBookingScope(req.user, req.params.id);
    const booking = await rejectBooking({ bookingId: req.params.id, admin: req.user, reason: req.body.reason, req });
    res.json({ booking });
  })
);

router.post(
  '/bookings/:id/displace',
  validate(z.object({ reason: z.string().min(3).max(1000) })),
  asyncHandler(async (req, res) => {
    await assertBookingScope(req.user, req.params.id);
    const booking = await adminDisplaceBooking({ bookingId: req.params.id, admin: req.user, reason: req.body.reason, req });
    res.json({ booking });
  })
);

router.post(
  '/bookings/:id/no-show',
  validate(z.object({ reason: z.string().max(1000).optional(), user_id: z.string().uuid().optional() })),
  asyncHandler(async (req, res) => {
    await assertBookingScope(req.user, req.params.id);
    const booking = await markNoShowAdmin({
      bookingId: req.params.id,
      userId: req.body.user_id,
      reason: req.body.reason,
      req
    });
    res.json({ booking: bookingToApi(booking, req.user) });
  })
);

router.post(
  '/bookings/:id/checkin',
  asyncHandler(async (req, res) => {
    await assertBookingScope(req.user, req.params.id);
    const outcome = await checkInBooking({
      bookingId: req.params.id,
      user: req.user,
      method: 'admin',
      proof: {},
      req,
      allowOutsideWindow: true
    });
    res.json({
      checked_in: true,
      already_checked_in: outcome.already,
      checkin_method: outcome.booking.checkin_method,
      checked_in_at: outcome.booking.checked_in_at
    });
  })
);

router.post(
  '/bookings/:id/cancel',
  validate(z.object({ reason: z.string().min(3).max(1000), scope: z.enum(['single', 'future', 'all']).optional().default('single') })),
  asyncHandler(async (req, res) => {
    await assertBookingScope(req.user, req.params.id);
    const result = await cancelBooking({
      bookingId: req.params.id,
      user: req.user,
      reason: req.body.reason,
      scope: req.body.scope,
      req
    });
    res.json(result);
  })
);

router.get(
  '/issues',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [];
    if (req.query.status) {
      params.push(req.query.status);
      conditions.push(`i.status = $${params.length}`);
    }
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      conditions.push(`f.department_id = $${params.length}`);
    }
    const result = await query(
      `SELECT i.*, f.name AS facility_name, f.building, f.room_number,
              u.name AS reporter_name, u.id_number AS reporter_id_number
       FROM room_issues i
       JOIN facilities f ON f.id = i.facility_id
       JOIN users u ON u.id = i.reported_by
       ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
       ORDER BY i.created_at DESC LIMIT 300`,
      params
    );
    res.json({ issues: result.rows });
  })
);

router.patch(
  '/issues/:id',
  validate(
    z.object({
      status: z.enum(['open', 'acknowledged', 'resolved']),
      note: z.string().max(1000).optional()
    })
  ),
  asyncHandler(async (req, res) => {
    const params = [req.params.id, req.body.status, req.user.id];
    let scopeSql = '';
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      scopeSql = `AND f.department_id = $${params.length}`;
    }
    const result = await query(
      `UPDATE room_issues i
       SET status = $2,
           acknowledged_by = CASE WHEN $2 = 'acknowledged' THEN $3 ELSE i.acknowledged_by END,
           acknowledged_at = CASE WHEN $2 = 'acknowledged' THEN now() ELSE i.acknowledged_at END,
           resolved_by = CASE WHEN $2 = 'resolved' THEN $3 ELSE i.resolved_by END,
           resolved_at = CASE WHEN $2 = 'resolved' THEN now() ELSE i.resolved_at END
       FROM facilities f
       WHERE i.facility_id = f.id AND i.id = $1 ${scopeSql}
       RETURNING i.*`,
      params
    );
    if (!result.rowCount) throw new AppError(404, 'ISSUE_NOT_FOUND', 'Issue not found.');
    await auditLog({
      req,
      action: 'admin.issue_updated',
      entityType: 'room_issue',
      entityId: req.params.id,
      details: { status: req.body.status, note: req.body.note }
    });
    await notifyUser({
      userId: result.rows[0].reported_by,
      type: 'room_issue_update',
      eventType: 'room_issue_update',
      title: 'Room issue updated',
      message: `Your report is now ${req.body.status}.${req.body.note ? ` ${req.body.note}` : ''}`,
      link: '/rooms.html'
    }).catch(() => {});
    res.json({ issue: result.rows[0] });
  })
);

router.get(
  '/study-mode-requests',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [`u.role IN ('student', 'class_rep', 'deputy_rep')`];
    if (req.query.status) {
      params.push(req.query.status);
      conditions.push(`r.status = $${params.length}`);
    }
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      conditions.push(`u.department_id = $${params.length}`);
    }
    const result = await query(
      `SELECT r.*, u.name AS user_name, u.id_number, u.study_mode AS current_mode,
              u.department_id, d.name AS decided_by_name
       FROM study_mode_requests r
       JOIN users u ON u.id = r.user_id
       LEFT JOIN users d ON d.id = r.decided_by
       ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
       ORDER BY r.created_at DESC LIMIT 300`,
      params
    );
    res.json({ requests: result.rows });
  })
);

router.post(
  '/study-mode-requests/:id/decide',
  validate(
    z.object({
      decision: z.enum(['approved', 'rejected']),
      note: z.string().max(1000).optional()
    })
  ),
  asyncHandler(async (req, res) => {
    const result = await withTransaction(async (client) => {
      const requestResult = await client.query(
        `SELECT r.*, u.department_id FROM study_mode_requests r
         JOIN users u ON u.id = r.user_id WHERE r.id = $1 FOR UPDATE`,
        [req.params.id]
      );
      const request = requestResult.rows[0];
      if (!request) throw new AppError(404, 'REQUEST_NOT_FOUND', 'Study mode request not found.');
      if (request.status !== 'pending') throw new AppError(409, 'REQUEST_DECIDED', 'This request has already been decided.');
      if (!isSuper(req.user) && request.department_id !== req.user.department_id) {
        throw new AppError(403, 'DEPARTMENT_SCOPE', 'You can only decide requests in your department.');
      }
      const updated = await client.query(
        `UPDATE study_mode_requests
         SET status = $2, decided_by = $3, decided_at = now(), decision_note = $4
         WHERE id = $1 RETURNING *`,
        [request.id, req.body.decision, req.user.id, req.body.note || null]
      );
      if (req.body.decision === 'approved') {
        await client.query(
          `UPDATE users SET study_mode = $2, updated_at = now() WHERE id = $1`,
          [request.user_id, request.requested_mode]
        );
      }
      return updated.rows[0];
    });
    await auditLog({
      req,
      action: 'admin.study_mode_decided',
      entityType: 'study_mode_request',
      entityId: result.id,
      details: { decision: req.body.decision }
    });
    await notifyStudyModeDecision({
      userId: result.user_id,
      approved: req.body.decision === 'approved',
      mode: result.requested_mode,
      note: req.body.note
    }).catch(() => {});
    res.json({ request: result });
  })
);

router.get(
  '/data-requests',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [];
    if (req.query.status) {
      params.push(req.query.status);
      conditions.push(`r.status = $${params.length}`);
    }
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      conditions.push(`u.department_id = $${params.length}`);
    }
    const result = await query(
      `SELECT r.*, u.name AS user_name, u.id_number, u.email
       FROM data_requests r JOIN users u ON u.id = r.user_id
       ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
       ORDER BY r.requested_at DESC LIMIT 300`,
      params
    );
    res.json({ requests: result.rows });
  })
);

router.post(
  '/data-requests/:id/process',
  validate(
    z.object({
      status: z.enum(['processing', 'completed', 'rejected']),
      notes: z.string().max(2000).optional()
    })
  ),
  asyncHandler(async (req, res) => {
    const result = await withTransaction(async (client) => {
      const requestResult = await client.query(
        `SELECT r.*, u.department_id FROM data_requests r JOIN users u ON u.id = r.user_id
         WHERE r.id = $1 FOR UPDATE`,
        [req.params.id]
      );
      const request = requestResult.rows[0];
      if (!request) throw new AppError(404, 'REQUEST_NOT_FOUND', 'Data request not found.');
      if (!isSuper(req.user) && request.department_id !== req.user.department_id) {
        throw new AppError(403, 'DEPARTMENT_SCOPE', 'You can only process requests in your department.');
      }
      if (request.type === 'deletion' && req.body.status === 'completed' && !isSuper(req.user)) {
        throw new AppError(403, 'SUPER_ADMIN_REQUIRED', 'Only a super administrator can complete a deletion request.');
      }
      if (request.type === 'deletion' && req.body.status === 'completed') {
        await client.query(
          `UPDATE users SET name = 'Anonymised user', email = $2, phone = NULL,
             password_hash = NULL, pin_hash = NULL, qr_token_hash = $3, qr_handle = $4,
             qr_secret = $5, qr_active = false, is_active = false, flagged_for_review = false,
             flagged_reason = NULL, anonymized_at = now(), updated_at = now()
           WHERE id = $1`,
          [
            request.user_id,
            `deleted-${request.user_id}@invalid.local`,
            sha256Hex(randomToken(32)),
            `deleted-${request.user_id.slice(0, 8)}`,
            randomBase32Secret(20)
          ]
        );
        await client.query(
          `UPDATE auth_sessions SET revoked_at = now(), revoked_reason = 'account_deleted'
           WHERE user_id = $1 AND revoked_at IS NULL`,
          [request.user_id]
        );
      }
      const updated = await client.query(
        `UPDATE data_requests SET status = $2, notes = $3, processed_by = $4,
           processed_at = CASE WHEN $2 = 'completed' OR $2 = 'rejected' THEN now() ELSE processed_at END
         WHERE id = $1 RETURNING *`,
        [request.id, req.body.status, req.body.notes || null, req.user.id]
      );
      return updated.rows[0];
    });
    await auditLog({
      req,
      action: 'admin.data_request_processed',
      entityType: 'data_request',
      entityId: result.id,
      details: { status: req.body.status, type: result.type }
    });
    res.json({ request: result });
  })
);

router.get(
  '/settings',
  asyncHandler(async (req, res) => {
    const settings = await getSettings(Object.keys(SETTING_DEFAULTS));
    res.json({ settings });
  })
);

router.put(
  '/settings',
  validate(z.record(z.string(), z.any())),
  asyncHandler(async (req, res) => {
    if (!isSuper(req.user)) {
      throw new AppError(403, 'SUPER_ADMIN_REQUIRED', 'Only a super administrator can change system settings.');
    }
    const result = await updateSettings(req.body, req.user.id);
    await auditLog({
      req,
      action: 'admin.settings_updated',
      entityType: 'settings',
      details: { keys: Object.keys(req.body) }
    });
    res.json(result);
  })
);

router.get(
  '/audit',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [];
    if (req.query.action) {
      params.push(`${String(req.query.action)}%`);
      conditions.push(`action LIKE $${params.length}`);
    }
    if (req.query.user_id) {
      params.push(req.query.user_id);
      conditions.push(`user_id = $${params.length}`);
    }
    if (req.query.from) {
      params.push(req.query.from);
      conditions.push(`created_at >= $${params.length}`);
    }
    const limit = Math.min(Math.max(Number(req.query.limit || 100), 1), 500);
    params.push(limit);
    const result = await query(
      `SELECT a.*, u.name AS user_name, u.id_number
       FROM audit_log a LEFT JOIN users u ON u.id = a.user_id
       ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
       ORDER BY a.id DESC LIMIT $${params.length}`,
      params
    );
    res.json({ entries: result.rows });
  })
);

router.get(
  '/deliveries',
  asyncHandler(async (req, res) => {
    const status = req.query.status || 'failed';
    const result = await query(
      `SELECT d.*, n.title, u.name AS user_name, u.email
       FROM notification_deliveries d
       JOIN notifications n ON n.id = d.notification_id
       JOIN users u ON u.id = d.user_id
       WHERE d.status = $1
       ORDER BY d.created_at DESC LIMIT 200`,
      [status]
    );
    res.json({ deliveries: result.rows });
  })
);

router.get(
  '/health',
  asyncHandler(async (req, res) => {
    const started = Date.now();
    const db = await query('SELECT now() AS now, version() AS version');
    const queue = await query(
      `SELECT status, count(*)::int AS count FROM notification_queue GROUP BY status`
    );
    const sessions = await query(
      `SELECT count(*)::int AS active FROM auth_sessions WHERE revoked_at IS NULL AND expires_at > now()`
    );
    res.json({
      database: { ok: true, now: db.rows[0].now, version: db.rows[0].version, latency_ms: Date.now() - started },
      notification_queue: Object.fromEntries(queue.rows.map((row) => [row.status, row.count])),
      active_sessions: sessions.rows[0].active,
      environment: config.env
    });
  })
);

export default router;
