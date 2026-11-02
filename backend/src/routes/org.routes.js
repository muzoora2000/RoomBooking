import express from 'express';
import { z } from 'zod';
import { query } from '../db/pool.js';
import { asyncHandler, AppError } from '../lib/errors.js';
import { auditLog } from '../lib/audit.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import { capacityPreview, getCurrentSemester } from '../services/studyMode.js';
import { getAuthorisedModules, getModuleClasses } from '../services/sessions.js';
import { notifyUser } from '../services/notifications.js';

const router = express.Router();

// ── Public endpoints (no authentication required) ────────────────────────────
// Used by login/registration page to populate faculty dropdowns

router.get('/public/departments', asyncHandler(async (req, res) => {
  const result = await query(
    `SELECT id, code, name FROM departments ORDER BY name`
  );
  res.json({ departments: result.rows });
}));

router.get('/public/programmes', asyncHandler(async (req, res) => {
  const params = [];
  let where = '';
  if (req.query.department_id) {
    params.push(req.query.department_id);
    where = 'WHERE p.department_id = $1';
  }
  const result = await query(
    `SELECT p.id, p.code, p.name, p.duration_years, p.department_id
     FROM programmes p ${where} ORDER BY p.name`,
    params
  );
  res.json({ programmes: result.rows });
}));

router.get('/public/classes', asyncHandler(async (req, res) => {
  const params = [];
  const conditions = [];
  if (req.query.programme_id) {
    params.push(req.query.programme_id);
    conditions.push(`c.programme_id = $${params.length}`);
  }
  const result = await query(
    `SELECT c.id, c.name, c.year_of_study, c.programme_id
     FROM classes c
     ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
     ORDER BY c.year_of_study`,
    params
  );
  res.json({ classes: result.rows });
}));

router.get('/public/modules', asyncHandler(async (req, res) => {
  const params = [];
  const conditions = [];
  if (req.query.programme_id) {
    params.push(req.query.programme_id);
    conditions.push(`m.programme_id = $${params.length}`);
  }
  if (req.query.department_id) {
    params.push(req.query.department_id);
    conditions.push(`m.department_id = $${params.length}`);
  }
  const result = await query(
    `SELECT m.id, m.code, m.name, m.credit_units, m.programme_id, m.department_id,
            u.name AS lecturer_name
     FROM modules m
     LEFT JOIN users u ON u.id = m.lecturer_id
     ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
     ORDER BY m.code`,
    params
  );
  res.json({ modules: result.rows });
}));

// ── All routes below require authentication ──────────────────────────────────
router.use(authenticate);

const ADMIN_ROLES = new Set(['department_admin', 'super_admin']);

router.get(
  '/departments',
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT d.id, d.code, d.name,
              count(DISTINCT f.id)::int AS facility_count,
              count(DISTINCT m.id)::int AS module_count
       FROM departments d
       LEFT JOIN facilities f ON f.department_id = d.id
       LEFT JOIN modules m ON m.department_id = d.id
       GROUP BY d.id ORDER BY d.name`
    );
    res.json({ departments: result.rows });
  })
);

router.get(
  '/programmes',
  asyncHandler(async (req, res) => {
    const params = [];
    let where = '';
    if (req.query.department_id) {
      params.push(req.query.department_id);
      where = 'WHERE p.department_id = $1';
    }
    const result = await query(
      `SELECT p.id, p.code, p.name, p.department_id, p.duration_years,
              d.code AS department_code, d.name AS department_name,
              count(c.id)::int AS class_count
       FROM programmes p JOIN departments d ON d.id = p.department_id
       LEFT JOIN classes c ON c.programme_id = p.id
       ${where}
       GROUP BY p.id, d.code, d.name
       ORDER BY p.name`,
      params
    );
    res.json({ programmes: result.rows });
  })
);

router.get(
  '/classes',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [];
    if (req.query.programme_id) {
      params.push(req.query.programme_id);
      conditions.push(`c.programme_id = $${params.length}`);
    }
    if (req.query.department_id) {
      params.push(req.query.department_id);
      conditions.push(`p.department_id = $${params.length}`);
    }
    const result = await query(
      `SELECT c.id, c.code, c.name, c.year_of_study, c.programme_id, c.default_study_mode,
              p.code AS programme_code, p.name AS programme_name,
              d.code AS department_code, d.name AS department_name,
              count(st.id)::int AS student_count
       FROM classes c
       JOIN programmes p ON p.id = c.programme_id
       JOIN departments d ON d.id = p.department_id
       LEFT JOIN users st ON st.class_id = c.id AND st.is_active = true
       ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
       GROUP BY c.id, p.code, p.name, d.code, d.name
       ORDER BY c.code`,
      params
    );
    res.json({ classes: result.rows });
  })
);

router.get(
  '/semesters',
  asyncHandler(async (req, res) => {
    const result = await query(`SELECT * FROM semesters ORDER BY start_date DESC`);
    res.json({ semesters: result.rows });
  })
);

router.get(
  '/semesters/current',
  asyncHandler(async (req, res) => {
    const semester = await getCurrentSemester();
    if (!semester) throw new AppError(404, 'NO_SEMESTER', 'No current semester is configured.');
    res.json({ semester });
  })
);

router.get(
  '/modules',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [];
    if (req.query.class_id) {
      const semesterId = req.query.semester_id || (await getCurrentSemester())?.id;
      if (!semesterId) throw new AppError(409, 'NO_SEMESTER', 'No current semester is configured.');
      params.push(req.query.class_id, semesterId);
      conditions.push(
        `EXISTS (SELECT 1 FROM class_modules cm WHERE cm.module_id = m.id AND cm.class_id = $${params.length - 1} AND cm.semester_id = $${params.length})`
      );
    }
    if (req.query.department_id) {
      params.push(req.query.department_id);
      conditions.push(`m.department_id = $${params.length}`);
    }
    if (req.query.q) {
      params.push(`%${String(req.query.q).toLowerCase()}%`);
      conditions.push(`(lower(m.code) LIKE $${params.length} OR lower(m.name) LIKE $${params.length})`);
    }
    const result = await query(
      `SELECT m.id, m.code, m.name, m.department_id, m.lecturer_id,
              d.code AS department_code, d.name AS department_name,
              u.name AS lecturer_name
       FROM modules m
       JOIN departments d ON d.id = m.department_id
       LEFT JOIN users u ON u.id = m.lecturer_id
       ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
       ORDER BY m.code
       LIMIT 500`,
      params
    );
    res.json({ modules: result.rows });
  })
);

router.get(
  '/my-modules',
  asyncHandler(async (req, res) => {
    const result = await getAuthorisedModules(req.user, { semesterId: req.query.semester_id || null });
    res.json(result);
  })
);

router.get(
  '/modules/:id/classes',
  asyncHandler(async (req, res) => {
    const classes = await getModuleClasses(req.params.id, { semesterId: req.query.semester_id || null });
    res.json({ classes });
  })
);

router.get(
  '/modules/:id/capacity',
  asyncHandler(async (req, res) => {
    const preview = await capacityPreview(req.params.id, req.query.semester_id || null);
    res.json(preview);
  })
);

router.get(
  '/enrolments/mine',
  asyncHandler(async (req, res) => {
    const semester = await getCurrentSemester();
    if (!semester) throw new AppError(409, 'NO_SEMESTER', 'No current semester is configured.');
    const result = await query(
      `SELECT e.id, e.module_id, e.semester_id, e.delivery_mode_override,
              COALESCE(e.delivery_mode_override, u.study_mode) AS effective_mode,
              m.code AS module_code, m.name AS module_name,
              d.name AS department_name, l.name AS lecturer_name
       FROM enrolments e
       JOIN users u ON u.id = e.user_id
       JOIN modules m ON m.id = e.module_id
       JOIN departments d ON d.id = m.department_id
       LEFT JOIN users l ON l.id = m.lecturer_id
       WHERE e.user_id = $1 AND e.semester_id = $2
       ORDER BY m.code`,
      [req.user.id, semester.id]
    );
    res.json({ semester, enrolments: result.rows });
  })
);

router.get(
  '/class-reps',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = ['cr.is_active = true'];
    if (req.query.class_id) {
      params.push(req.query.class_id);
      conditions.push(`cr.class_id = $${params.length}`);
    }
    if (req.query.semester_id) {
      params.push(req.query.semester_id);
      conditions.push(`cr.semester_id = $${params.length}`);
    }
    const result = await query(
      `SELECT cr.id, cr.class_id, cr.is_deputy, cr.is_available, cr.assigned_at,
              u.id AS user_id, u.name, u.id_number, u.email, u.phone,
              c.code AS class_code, c.name AS class_name, s.name AS semester_name
       FROM class_reps cr
       JOIN users u ON u.id = cr.user_id
       JOIN classes c ON c.id = cr.class_id
       JOIN semesters s ON s.id = cr.semester_id
       WHERE ${conditions.join(' AND ')}
       ORDER BY c.code, cr.is_deputy`,
      params
    );
    res.json({ class_reps: result.rows });
  })
);

router.get(
  '/delegations',
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT d.*, m.code AS module_code, m.name AS module_name,
              f.name AS from_name, t.name AS to_name
       FROM delegations d
       JOIN modules m ON m.id = d.module_id
       JOIN users f ON f.id = d.from_user_id
       JOIN users t ON t.id = d.to_user_id
       WHERE $1 IN (d.from_user_id, d.to_user_id) OR $2 = true
       ORDER BY d.starts_at DESC`,
      [req.user.id, ADMIN_ROLES.has(req.user.role)]
    );
    res.json({ delegations: result.rows });
  })
);

router.post(
  '/delegations',
  validate(
    z.object({
      module_id: z.string().uuid(),
      to_user_id: z.string().uuid(),
      starts_at: z.string().min(8).max(60),
      ends_at: z.string().min(8).max(60),
      note: z.string().max(500).optional()
    })
  ),
  asyncHandler(async (req, res) => {
    const moduleResult = await query('SELECT * FROM modules WHERE id = $1', [req.body.module_id]);
    const module = moduleResult.rows[0];
    if (!module) throw new AppError(404, 'MODULE_NOT_FOUND', 'Module not found.');
    const fromUserId = req.user.role === 'lecturer' ? req.user.id : module.lecturer_id;
    if (!fromUserId) throw new AppError(409, 'NO_LECTURER', 'This module has no lecturer to delegate from.');
    if (req.user.role !== 'lecturer' && req.user.role !== 'department_admin' && req.user.role !== 'super_admin') {
      throw new AppError(403, 'DELEGATION_FORBIDDEN', 'Only a lecturer or administrator can delegate a module.');
    }
    if (req.user.role === 'lecturer' && module.lecturer_id !== req.user.id) {
      throw new AppError(403, 'NOT_MODULE_LECTURER', 'You can only delegate a module you teach.');
    }
    if (req.user.role === 'department_admin' && module.department_id !== req.user.department_id) {
      throw new AppError(403, 'DEPARTMENT_SCOPE', 'You can only delegate modules in your department.');
    }
    const target = await query('SELECT id, name, role, is_active FROM users WHERE id = $1', [req.body.to_user_id]);
    if (!target.rows[0]?.is_active) throw new AppError(404, 'USER_NOT_FOUND', 'The person you are delegating to was not found.');
    if (!['lecturer', 'class_rep', 'deputy_rep', 'department_admin'].includes(target.rows[0].role)) {
      throw new AppError(400, 'DELEGATION_ROLE', 'Delegations can only be made to lecturers, class representatives, or administrators.');
    }
    if (target.rows[0].id === fromUserId) throw new AppError(400, 'SELF_DELEGATION', 'You cannot delegate to yourself.');
    const starts = new Date(req.body.starts_at);
    const ends = new Date(req.body.ends_at);
    if (Number.isNaN(starts.getTime()) || Number.isNaN(ends.getTime()) || ends <= starts) {
      throw new AppError(400, 'INVALID_WINDOW', 'Provide a valid delegation start and end time.');
    }
    const result = await query(
      `INSERT INTO delegations (module_id, from_user_id, to_user_id, starts_at, ends_at)
       VALUES ($1,$2,$3,$4,$5) RETURNING *`,
      [module.id, fromUserId, target.rows[0].id, starts, ends]
    );
    await auditLog({
      req,
      action: 'delegation.created',
      entityType: 'delegation',
      entityId: result.rows[0].id,
      details: { module_id: module.id, to_user_id: target.rows[0].id, starts_at: starts, ends_at: ends }
    });
    await notifyUser({
      userId: target.rows[0].id,
      type: 'delegation',
      eventType: 'delegation',
      title: 'You can now schedule a module',
      message: `${req.user.name} delegated ${module.code} ${module.name} to you from ${starts.toISOString()} to ${ends.toISOString()}.`,
      link: '/schedule.html'
    }).catch(() => {});
    res.status(201).json({ delegation: result.rows[0] });
  })
);

router.delete(
  '/delegations/:id',
  asyncHandler(async (req, res) => {
    const result = await query(
      `UPDATE delegations SET revoked_at = now()
       WHERE id = $1 AND (from_user_id = $2 OR to_user_id = $2 OR $3 = true) AND revoked_at IS NULL
       RETURNING id`,
      [req.params.id, req.user.id, ADMIN_ROLES.has(req.user.role)]
    );
    if (!result.rowCount) throw new AppError(404, 'DELEGATION_NOT_FOUND', 'Delegation not found.');
    await auditLog({ req, action: 'delegation.revoked', entityType: 'delegation', entityId: req.params.id });
    res.json({ revoked: true });
  })
);

export default router;
