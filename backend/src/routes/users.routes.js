import express from 'express';
import bcrypt from 'bcryptjs';
import { z } from 'zod';
import { query, withTransaction } from '../db/pool.js';
import { asyncHandler, AppError } from '../lib/errors.js';
import { auditLog } from '../lib/audit.js';
import { normalizeUgandaPhone } from '../lib/crypto.js';
import { formatKampala, fromKampalaISO } from '../lib/time.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import { getCurrentSemester } from '../services/studyMode.js';
import { issuePersonalQr, generateQrDataUrl } from '../services/qr.js';
import { notifyAccountSecurity, notifyAdmins } from '../services/notifications.js';

const router = express.Router();
router.use(authenticate);

const profileSchema = z.object({
  phone: z.string().min(7).max(30).optional(),
  sms_link_opt_in: z.boolean().optional(),
  consent: z.literal(true).optional(),
  class_id: z.string().uuid().optional()
});

const passwordSchema = z.object({
  current_password: z.string().min(1).max(200),
  new_password: z.string().min(8).max(200)
});

const pinSchema = z.object({
  current_password: z.string().min(1).max(200),
  pin: z.string().regex(/^\d{4,8}$/, 'PIN must be 4 to 8 digits')
});

const studyModeSchema = z.object({
  requested_mode: z.enum(['physical', 'online', 'hybrid']),
  reason: z.string().min(10).max(1000)
});

const workModeSchema = z.object({
  mode: z.enum(['physical', 'online', 'hybrid'])
});

const STUDY_MODE_ROLES = new Set(['student', 'class_rep', 'deputy_rep']);
const WORK_MODE_ROLES = new Set(['lecturer', 'department_admin', 'super_admin']);

const dataRequestSchema = z.object({
  type: z.enum(['export', 'deletion']),
  notes: z.string().max(1000).optional()
});

router.get(
  '/profile',
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT u.id, u.id_number, u.name, u.email, u.phone, u.role, u.study_mode,
              u.qr_handle, u.qr_active, u.sms_link_opt_in, u.consent_at, u.created_at,
              u.last_verified_at, u.flagged_for_review,
              d.id AS department_id, d.code AS department_code, d.name AS department_name,
              c.id AS class_id, c.code AS class_code, c.name AS class_name, c.year_of_study,
              p.id AS programme_id, p.code AS programme_code, p.name AS programme_name
       FROM users u
       LEFT JOIN departments d ON d.id = u.department_id
       LEFT JOIN classes c ON c.id = u.class_id
       LEFT JOIN programmes p ON p.id = c.programme_id
       WHERE u.id = $1`,
      [req.user.id]
    );
    const user = result.rows[0];
    if (!user) throw new AppError(404, 'USER_NOT_FOUND', 'User account not found.');
    const reps = await query(
      `SELECT cr.id, cr.class_id, cr.is_deputy, cr.is_active, c.code AS class_code, c.name AS class_name,
              s.name AS semester_name
       FROM class_reps cr
       JOIN classes c ON c.id = cr.class_id
       JOIN semesters s ON s.id = cr.semester_id
       WHERE cr.user_id = $1 AND cr.is_active = true
       ORDER BY cr.assigned_at DESC`,
      [req.user.id]
    );
    const semester = await getCurrentSemester();
    res.json({
      ...user,
      rep_roles: reps.rows,
      current_semester: semester
        ? { id: semester.id, name: semester.name, start_date: semester.start_date, end_date: semester.end_date }
        : null
    });
  })
);

router.patch(
  '/profile',
  validate(profileSchema),
  asyncHandler(async (req, res) => {
    const updates = [];
    const params = [req.user.id];
    if (req.body.phone !== undefined) {
      if (req.body.phone === '' || req.body.phone === null) {
        params.push(null);
        updates.push(`phone = $${params.length}`);
      } else {
        const phone = normalizeUgandaPhone(req.body.phone);
        if (!phone) throw new AppError(400, 'INVALID_PHONE', 'Enter a valid Ugandan phone number.');
        params.push(phone);
        updates.push(`phone = $${params.length}`);
      }
    }
    if (req.body.sms_link_opt_in !== undefined) {
      params.push(req.body.sms_link_opt_in);
      updates.push(`sms_link_opt_in = $${params.length}`);
    }
    if (req.body.consent === true) {
      updates.push('consent_at = COALESCE(consent_at, now())');
    }
    if (req.body.class_id !== undefined) {
      const classCheck = await query(
        'SELECT id, department_id FROM classes WHERE id = $1',
        [req.body.class_id]
      );
      if (!classCheck.rows[0]) throw new AppError(404, 'CLASS_NOT_FOUND', 'Class not found.');
      params.push(req.body.class_id);
      updates.push(`class_id = $${params.length}`);
      params.push(classCheck.rows[0].department_id);
      updates.push(`department_id = $${params.length}`);
    }
    if (!updates.length) throw new AppError(400, 'NO_CHANGES', 'No profile changes were supplied.');
    const result = await query(
      `UPDATE users SET ${updates.join(', ')}, updated_at = now()
       WHERE id = $1
       RETURNING id, name, email, phone, sms_link_opt_in, consent_at`,
      params
    );
    await auditLog({
      req,
      action: 'profile.updated',
      entityType: 'user',
      entityId: req.user.id,
      details: { fields: Object.keys(req.body) }
    });
    res.json({ user: result.rows[0] });
  })
);

router.post(
  '/password',
  validate(passwordSchema),
  asyncHandler(async (req, res) => {
    if (!/[A-Za-z]/.test(req.body.new_password) || !/\d/.test(req.body.new_password)) {
      throw new AppError(400, 'WEAK_PASSWORD', 'Password must be at least 8 characters and include a letter and a number.');
    }
    const result = await query('SELECT password_hash FROM users WHERE id = $1', [req.user.id]);
    const matches = await bcrypt.compare(req.body.current_password, result.rows[0]?.password_hash || '');
    if (!matches) throw new AppError(400, 'CURRENT_PASSWORD_INVALID', 'Your current password is not correct.');
    const hash = await bcrypt.hash(req.body.new_password, 12);
    await query('UPDATE users SET password_hash = $2, updated_at = now() WHERE id = $1', [req.user.id, hash]);
    await query(
      `UPDATE auth_sessions SET revoked_at = now(), revoked_reason = 'password_changed'
       WHERE user_id = $1 AND id <> $2 AND revoked_at IS NULL`,
      [req.user.id, req.sessionId]
    );
    await auditLog({ req, action: 'profile.password_changed', entityType: 'user', entityId: req.user.id });
    await notifyAccountSecurity({
      userId: req.user.id,
      title: 'Password changed',
      message: 'Your password was changed. Other sessions were signed out. If this was not you, contact an administrator immediately.',
      severity: 'warning'
    }).catch(() => {});
    res.json({ changed: true });
  })
);

router.post(
  '/pin',
  validate(pinSchema),
  asyncHandler(async (req, res) => {
    const result = await query('SELECT password_hash FROM users WHERE id = $1', [req.user.id]);
    const matches = await bcrypt.compare(req.body.current_password, result.rows[0]?.password_hash || '');
    if (!matches) throw new AppError(400, 'CURRENT_PASSWORD_INVALID', 'Your current password is not correct.');
    const hash = await bcrypt.hash(req.body.pin, 12);
    await query('UPDATE users SET pin_hash = $2, updated_at = now() WHERE id = $1', [req.user.id, hash]);
    await auditLog({ req, action: 'profile.pin_changed', entityType: 'user', entityId: req.user.id });
    await notifyAccountSecurity({
      userId: req.user.id,
      title: 'PIN changed',
      message: 'Your check-in PIN was changed. If this was not you, contact an administrator.',
      severity: 'warning'
    }).catch(() => {});
    res.json({ changed: true });
  })
);

router.get(
  '/qr',
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT id, name, qr_handle, qr_secret, qr_active FROM users WHERE id = $1`,
      [req.user.id]
    );
    const user = result.rows[0];
    if (!user) throw new AppError(404, 'USER_NOT_FOUND', 'User account not found.');
    if (!user.qr_active) throw new AppError(403, 'QR_DEACTIVATED', 'Your personal QR has been deactivated.');
    const personal = await issuePersonalQr(user);
    const image = await generateQrDataUrl(personal.content, { margin: 1, width: 320 });
    res.json({
      ...personal,
      image_data_url: image,
      note: 'This code refreshes every 30 seconds. Only present it to staff or scan it yourself at a kiosk.'
    });
  })
);

router.get(
  '/overview',
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT
         (SELECT count(*)::int FROM bookings WHERE user_id = $1 AND status IN ('pending','confirmed') AND start_at > now()) AS upcoming_bookings,
         (SELECT count(*)::int FROM notifications WHERE user_id = $1 AND is_read = false) AS unread_notifications,
         (SELECT count(*)::int FROM no_shows WHERE user_id = $1 AND marked_at > now() - interval '30 days') AS recent_no_shows,
         (SELECT count(*)::int FROM enrolments e JOIN semesters s ON s.id = e.semester_id WHERE e.user_id = $1 AND s.is_current = true) AS modules,
         (SELECT count(*)::int FROM auth_sessions WHERE user_id = $1 AND revoked_at IS NULL AND expires_at > now()) AS active_sessions`,
      [req.user.id]
    );
    res.json(result.rows[0]);
  })
);

router.post(
  '/study-mode/request',
  validate(studyModeSchema),
  asyncHandler(async (req, res) => {
    if (!STUDY_MODE_ROLES.has(req.user.role)) {
      throw new AppError(403, 'STUDY_MODE_STUDENTS_ONLY', 'Only students can request study mode changes. Update your working mode in Settings instead.');
    }
    const pending = await query(
      `SELECT id FROM study_mode_requests WHERE user_id = $1 AND status = 'pending'`,
      [req.user.id]
    );
    if (pending.rowCount) {
      throw new AppError(409, 'REQUEST_PENDING', 'You already have a pending study mode request.');
    }
    const result = await query(
      `INSERT INTO study_mode_requests (user_id, requested_mode, reason)
       VALUES ($1,$2,$3) RETURNING *`,
      [req.user.id, req.body.requested_mode, req.body.reason]
    );
    await auditLog({
      req,
      action: 'study_mode.requested',
      entityType: 'study_mode_request',
      entityId: result.rows[0].id,
      details: { requested_mode: req.body.requested_mode }
    });
    await notifyAdmins({
      departmentId: req.user.department_id,
      type: 'study_mode_request',
      eventType: 'study_mode_request',
      title: 'Study mode request',
      message: `${req.user.name} requested ${req.body.requested_mode} mode. Reason: ${req.body.reason}`,
      link: '/admin.html#study'
    }).catch(() => {});
    res.status(201).json({ request: result.rows[0] });
  })
);

router.get(
  '/study-mode/requests',
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT r.*, d.name AS decided_by_name
       FROM study_mode_requests r
       LEFT JOIN users d ON d.id = r.decided_by
       WHERE r.user_id = $1
       ORDER BY r.created_at DESC`,
      [req.user.id]
    );
    res.json({ requests: result.rows });
  })
);

router.patch(
  '/work-mode',
  validate(workModeSchema),
  asyncHandler(async (req, res) => {
    if (!WORK_MODE_ROLES.has(req.user.role)) {
      throw new AppError(403, 'WORK_MODE_STAFF_ONLY', 'Working mode is available to lecturers and administrators. Students should request a study mode change.');
    }
    const result = await query(
      `UPDATE users SET study_mode = $2, updated_at = now()
       WHERE id = $1
       RETURNING id, study_mode`,
      [req.user.id, req.body.mode]
    );
    await auditLog({
      req,
      action: 'profile.work_mode_updated',
      entityType: 'user',
      entityId: req.user.id,
      details: { mode: req.body.mode }
    });
    res.json({ user: result.rows[0] });
  })
);

router.get(
  '/devices',
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT id, label, user_agent, first_seen_at, last_used_at, trusted_until, revoked_at
       FROM trusted_devices WHERE user_id = $1 ORDER BY last_used_at DESC`,
      [req.user.id]
    );
    res.json({ devices: result.rows });
  })
);

router.delete(
  '/devices/:id',
  asyncHandler(async (req, res) => {
    const result = await query(
      `UPDATE trusted_devices SET revoked_at = now()
       WHERE id = $1 AND user_id = $2 AND revoked_at IS NULL
       RETURNING id`,
      [req.params.id, req.user.id]
    );
    if (!result.rowCount) throw new AppError(404, 'DEVICE_NOT_FOUND', 'Device not found.');
    await auditLog({ req, action: 'device.revoked', entityType: 'trusted_device', entityId: req.params.id });
    res.json({ revoked: true });
  })
);

router.get(
  '/sessions',
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT id, ip, user_agent, created_at, last_seen_at, expires_at, revoked_at, revoked_reason
       FROM auth_sessions WHERE user_id = $1 ORDER BY last_seen_at DESC LIMIT 50`,
      [req.user.id]
    );
    res.json({
      sessions: result.rows.map((row) => ({ ...row, current: row.id === req.sessionId }))
    });
  })
);

router.delete(
  '/sessions/:id',
  asyncHandler(async (req, res) => {
    const result = await query(
      `UPDATE auth_sessions SET revoked_at = now(), revoked_reason = 'revoked_by_user'
       WHERE id = $1 AND user_id = $2 AND revoked_at IS NULL
       RETURNING id`,
      [req.params.id, req.user.id]
    );
    if (!result.rowCount) throw new AppError(404, 'SESSION_NOT_FOUND', 'Session not found.');
    await auditLog({ req, action: 'session.revoked', entityType: 'auth_session', entityId: req.params.id });
    res.json({ revoked: true });
  })
);

router.get(
  '/data-requests',
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT * FROM data_requests WHERE user_id = $1 ORDER BY requested_at DESC`,
      [req.user.id]
    );
    res.json({ requests: result.rows });
  })
);

router.post(
  '/data-requests',
  validate(dataRequestSchema),
  asyncHandler(async (req, res) => {
    const pending = await query(
      `SELECT id FROM data_requests WHERE user_id = $1 AND type = $2 AND status IN ('pending','processing')`,
      [req.user.id, req.body.type]
    );
    if (pending.rowCount) throw new AppError(409, 'REQUEST_PENDING', 'A matching data request is already being processed.');
    const result = await query(
      `INSERT INTO data_requests (user_id, type, notes) VALUES ($1,$2,$3) RETURNING *`,
      [req.user.id, req.body.type, req.body.notes || null]
    );
    await auditLog({
      req,
      action: 'data_request.created',
      entityType: 'data_request',
      entityId: result.rows[0].id,
      details: { type: req.body.type }
    });
    await notifyAdmins({
      type: 'data_request',
      eventType: 'data_request',
      title: 'Data request',
      message: `${req.user.name} (${req.user.id_number}) requested a data ${req.body.type}.`,
      link: '/admin.html#data'
    }).catch(() => {});
    res.status(201).json({ request: result.rows[0] });
  })
);

router.get(
  '/export',
  asyncHandler(async (req, res) => {
    const user = await query(
      `SELECT id_number, name, email, phone, role, study_mode, consent_at, created_at
       FROM users WHERE id = $1`,
      [req.user.id]
    );
    const bookings = await query(
      `SELECT b.id, b.start_at, b.end_at, b.session_mode, b.status, b.purpose,
              f.name AS facility, m.code AS module_code
       FROM bookings b
       LEFT JOIN facilities f ON f.id = b.facility_id
       LEFT JOIN modules m ON m.id = b.module_id
       WHERE b.user_id = $1 ORDER BY b.start_at DESC`,
      [req.user.id]
    );
    const notifications = await query(
      `SELECT title, message, severity, created_at FROM notifications WHERE user_id = $1 ORDER BY created_at DESC LIMIT 1000`,
      [req.user.id]
    );
    const noShows = await query(
      `SELECT marked_at, reason FROM no_shows WHERE user_id = $1 ORDER BY marked_at DESC`,
      [req.user.id]
    );
    await auditLog({ req, action: 'profile.exported', entityType: 'user', entityId: req.user.id });
    res.setHeader('Content-Disposition', `attachment; filename="campus-data-${req.user.id_number}.json"`);
    res.json({
      exported_at: new Date().toISOString(),
      user: user.rows[0],
      bookings: bookings.rows,
      notifications: notifications.rows,
      no_shows: noShows.rows
    });
  })
);

router.get(
  '/notifications/preferences',
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT event_type, channel, enabled FROM notification_preferences WHERE user_id = $1`,
      [req.user.id]
    );
    res.json({ preferences: result.rows });
  })
);

router.put(
  '/notifications/preferences',
  validate(
    z.object({
      preferences: z.array(
        z.object({
          event_type: z.string().min(2).max(60),
          channel: z.enum(['inapp', 'email', 'sms', 'push']),
          enabled: z.boolean()
        })
      ).max(100)
    })
  ),
  asyncHandler(async (req, res) => {
    await withTransaction(async (client) => {
      for (const preference of req.body.preferences) {
        await client.query(
          `INSERT INTO notification_preferences (user_id, event_type, channel, enabled)
           VALUES ($1,$2,$3,$4)
           ON CONFLICT (user_id, event_type, channel)
           DO UPDATE SET enabled = EXCLUDED.enabled`,
          [req.user.id, preference.event_type, preference.channel, preference.enabled]
        );
      }
    });
    await auditLog({ req, action: 'notifications.preferences_updated', entityType: 'user', entityId: req.user.id });
    res.json({ saved: req.body.preferences.length });
  })
);

router.get(
  '/activate-qr',
  asyncHandler(async (req, res) => {
    if (!['department_admin', 'super_admin'].includes(req.user.role)) {
      throw new AppError(403, 'ADMIN_ONLY', 'Only administrators can issue activation QR codes.');
    }
    const result = await query(
      `SELECT id, id_number, name, qr_handle FROM users WHERE is_active = true AND password_hash IS NULL ORDER BY created_at DESC LIMIT 200`
    );
    res.json({ users: result.rows.map((row) => ({ ...row, activation_content: row.qr_handle })) });
  })
);

export default router;
