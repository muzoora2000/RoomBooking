import express from 'express';
import { z } from 'zod';
import { query, withTransaction } from '../db/pool.js';
import { asyncHandler, AppError, isPgUniqueViolation } from '../lib/errors.js';
import { auditLog } from '../lib/audit.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import { requireAdmin } from '../middleware/roles.js';
import { getCurrentSemester } from '../services/studyMode.js';

const router = express.Router();
router.use(authenticate, requireAdmin);

const uuid = z.string().uuid();
const shortCode = z.string().trim().min(1).max(50);
const longName = z.string().trim().min(2).max(200);

function isSuper(user) {
  return user.role === 'super_admin';
}

function assertDepartmentScope(user, departmentId) {
  if (isSuper(user)) return;
  if (!departmentId || user.department_id !== departmentId) {
    throw new AppError(403, 'DEPARTMENT_SCOPE', 'You can only manage records in your own department.');
  }
}

function departmentFilter(user, params, conditions, alias = 'd') {
  if (!isSuper(user)) {
    params.push(user.department_id);
    conditions.push(`${alias}.department_id = $${params.length}`);
  }
}

async function findProgramme(id, executor = { query }) {
  const result = await executor.query('SELECT * FROM programmes WHERE id = $1', [id]);
  return result.rows[0] || null;
}

async function findClass(id, executor = { query }) {
  const result = await executor.query(
    `SELECT c.*, p.code AS programme_code, p.department_id AS programme_department_id
     FROM classes c JOIN programmes p ON p.id = c.programme_id
     WHERE c.id = $1`,
    [id]
  );
  return result.rows[0] || null;
}

async function findModule(id, executor = { query }) {
  const result = await executor.query('SELECT * FROM modules WHERE id = $1', [id]);
  return result.rows[0] || null;
}

async function assertProgrammeScope(user, programmeId) {
  const programme = await findProgramme(programmeId);
  if (!programme) throw new AppError(404, 'PROGRAMME_NOT_FOUND', 'Programme not found.');
  assertDepartmentScope(user, programme.department_id);
  return programme;
}

async function assertModuleScope(user, moduleId) {
  const module = await findModule(moduleId);
  if (!module) throw new AppError(404, 'MODULE_NOT_FOUND', 'Module not found.');
  assertDepartmentScope(user, module.department_id);
  return module;
}

function codeFromName(value, fallback = 'CLASS') {
  const text = String(value || '')
    .trim()
    .toUpperCase()
    .replace(/[^A-Z0-9]+/g, '-')
    .replace(/^-+|-+$/g, '');
  return text || fallback;
}

async function assertSemester(id) {
  const result = await query('SELECT * FROM semesters WHERE id = $1', [id]);
  if (!result.rows[0]) throw new AppError(404, 'SEMESTER_NOT_FOUND', 'Semester not found.');
  return result.rows[0];
}

router.get(
  '/departments',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [];
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      conditions.push(`d.id = $${params.length}`);
    }
    const result = await query(
      `SELECT d.id, d.code, d.name, d.created_at,
              count(DISTINCT p.id)::int AS programme_count,
              count(DISTINCT c.id)::int AS class_count,
              count(DISTINCT m.id)::int AS module_count,
              count(DISTINCT f.id)::int AS facility_count
       FROM departments d
       LEFT JOIN programmes p ON p.department_id = d.id
       LEFT JOIN classes c ON c.department_id = d.id
       LEFT JOIN modules m ON m.department_id = d.id
       LEFT JOIN facilities f ON f.department_id = d.id
       ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
       GROUP BY d.id
       ORDER BY d.name`,
      params
    );
    res.json({ departments: result.rows });
  })
);

router.post(
  '/departments',
  validate(z.object({ code: shortCode, name: longName })),
  asyncHandler(async (req, res) => {
    if (!isSuper(req.user)) throw new AppError(403, 'SUPER_ADMIN_REQUIRED', 'Only a super administrator can create departments.');
    let department;
    try {
      const result = await query(
        `INSERT INTO departments (code, name) VALUES ($1, $2) RETURNING *`,
        [req.body.code.toUpperCase(), req.body.name]
      );
      department = result.rows[0];
    } catch (error) {
      if (isPgUniqueViolation(error)) throw new AppError(409, 'DEPARTMENT_EXISTS', 'That department code or name already exists.');
      throw error;
    }
    await auditLog({ req, action: 'admin.department_created', entityType: 'department', entityId: department.id });
    res.status(201).json({ department });
  })
);

router.patch(
  '/departments/:id',
  validate(z.object({ code: shortCode.optional(), name: longName.optional() })),
  asyncHandler(async (req, res) => {
    if (!isSuper(req.user)) throw new AppError(403, 'SUPER_ADMIN_REQUIRED', 'Only a super administrator can edit departments.');
    const fields = [];
    const params = [req.params.id];
    if (req.body.code !== undefined) {
      params.push(req.body.code.toUpperCase());
      fields.push(`code = $${params.length}`);
    }
    if (req.body.name !== undefined) {
      params.push(req.body.name);
      fields.push(`name = $${params.length}`);
    }
    if (!fields.length) throw new AppError(400, 'NO_CHANGES', 'No changes were supplied.');
    let department;
    try {
      const result = await query(
        `UPDATE departments SET ${fields.join(', ')} WHERE id = $1 RETURNING *`,
        params
      );
      department = result.rows[0];
    } catch (error) {
      if (isPgUniqueViolation(error)) throw new AppError(409, 'DEPARTMENT_EXISTS', 'That department code or name already exists.');
      throw error;
    }
    if (!department) throw new AppError(404, 'DEPARTMENT_NOT_FOUND', 'Department not found.');
    await auditLog({ req, action: 'admin.department_updated', entityType: 'department', entityId: department.id });
    res.json({ department });
  })
);

router.delete(
  '/departments/:id',
  asyncHandler(async (req, res) => {
    if (!isSuper(req.user)) throw new AppError(403, 'SUPER_ADMIN_REQUIRED', 'Only a super administrator can delete departments.');
    const references = await query(
      `SELECT
         (SELECT count(*)::int FROM programmes WHERE department_id = $1) AS programmes,
         (SELECT count(*)::int FROM classes WHERE department_id = $1) AS classes,
         (SELECT count(*)::int FROM modules WHERE department_id = $1) AS modules,
         (SELECT count(*)::int FROM facilities WHERE department_id = $1) AS facilities,
         (SELECT count(*)::int FROM users WHERE department_id = $1) AS users`,
      [req.params.id]
    );
    const counts = references.rows[0];
    if (Object.values(counts).some((value) => Number(value) > 0)) {
      throw new AppError(409, 'DEPARTMENT_IN_USE', 'Move or remove the programmes, classes, modules, rooms, and users for this department first.', counts);
    }
    const result = await query('DELETE FROM departments WHERE id = $1 RETURNING id', [req.params.id]);
    if (!result.rowCount) throw new AppError(404, 'DEPARTMENT_NOT_FOUND', 'Department not found.');
    await auditLog({ req, action: 'admin.department_deleted', entityType: 'department', entityId: req.params.id });
    res.json({ deleted: true });
  })
);

router.get(
  '/programmes',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [];
    departmentFilter(req.user, params, conditions, 'p');
    if (isSuper(req.user) && req.query.department_id) {
      params.push(req.query.department_id);
      conditions.push(`p.department_id = $${params.length}`);
    }
    const result = await query(
      `SELECT p.*, d.code AS department_code, d.name AS department_name,
              count(DISTINCT c.id)::int AS class_count,
              count(DISTINCT m.id)::int AS module_count
       FROM programmes p
       JOIN departments d ON d.id = p.department_id
       LEFT JOIN classes c ON c.programme_id = p.id
       LEFT JOIN modules m ON m.programme_id = p.id
       ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
       GROUP BY p.id, d.code, d.name
       ORDER BY d.name, p.name`,
      params
    );
    res.json({ programmes: result.rows });
  })
);

router.post(
  '/programmes',
  validate(
    z.object({
      department_id: uuid.optional(),
      code: shortCode,
      name: longName,
      duration_years: z.coerce.number().int().min(1).max(8).optional().default(3)
    })
  ),
  asyncHandler(async (req, res) => {
    const departmentId = req.body.department_id || req.user.department_id;
    assertDepartmentScope(req.user, departmentId);
    if (!departmentId) throw new AppError(400, 'DEPARTMENT_REQUIRED', 'Choose a department.');
    let programme;
    try {
      const result = await query(
        `INSERT INTO programmes (department_id, code, name, duration_years)
         VALUES ($1, $2, $3, $4) RETURNING *`,
        [departmentId, req.body.code.toUpperCase(), req.body.name, req.body.duration_years]
      );
      programme = result.rows[0];
    } catch (error) {
      if (isPgUniqueViolation(error)) throw new AppError(409, 'PROGRAMME_EXISTS', 'That programme code already exists in the department.');
      throw error;
    }
    await auditLog({
      req,
      action: 'admin.programme_created',
      entityType: 'programme',
      entityId: programme.id,
      details: { department_id: departmentId }
    });
    res.status(201).json({ programme });
  })
);

router.patch(
  '/programmes/:id',
  validate(
    z.object({
      department_id: uuid.optional(),
      code: shortCode.optional(),
      name: longName.optional(),
      duration_years: z.coerce.number().int().min(1).max(8).optional()
    })
  ),
  asyncHandler(async (req, res) => {
    const programme = await assertProgrammeScope(req.user, req.params.id);
    const nextDepartmentId = req.body.department_id || programme.department_id;
    assertDepartmentScope(req.user, nextDepartmentId);
    const fields = [];
    const params = [programme.id];
    if (req.body.department_id !== undefined) {
      params.push(nextDepartmentId);
      fields.push(`department_id = $${params.length}`);
    }
    if (req.body.code !== undefined) {
      params.push(req.body.code.toUpperCase());
      fields.push(`code = $${params.length}`);
    }
    if (req.body.name !== undefined) {
      params.push(req.body.name);
      fields.push(`name = $${params.length}`);
    }
    if (req.body.duration_years !== undefined) {
      params.push(req.body.duration_years);
      fields.push(`duration_years = $${params.length}`);
    }
    if (!fields.length) throw new AppError(400, 'NO_CHANGES', 'No changes were supplied.');
    let updated;
    try {
      updated = await withTransaction(async (client) => {
        const result = await client.query(
          `UPDATE programmes SET ${fields.join(', ')} WHERE id = $1 RETURNING *`,
          params
        );
        if (nextDepartmentId !== programme.department_id) {
          await client.query('UPDATE classes SET department_id = $2 WHERE programme_id = $1', [programme.id, nextDepartmentId]);
          await client.query('UPDATE modules SET department_id = $2 WHERE programme_id = $1', [programme.id, nextDepartmentId]);
        }
        return result.rows[0];
      });
    } catch (error) {
      if (isPgUniqueViolation(error)) throw new AppError(409, 'PROGRAMME_EXISTS', 'That programme code already exists in the department.');
      throw error;
    }
    await auditLog({ req, action: 'admin.programme_updated', entityType: 'programme', entityId: programme.id });
    res.json({ programme: updated });
  })
);

router.delete(
  '/programmes/:id',
  asyncHandler(async (req, res) => {
    const programme = await assertProgrammeScope(req.user, req.params.id);
    const references = await query(
      `SELECT
         (SELECT count(*)::int FROM classes WHERE programme_id = $1) AS classes,
         (SELECT count(*)::int FROM modules WHERE programme_id = $1) AS modules`,
      [programme.id]
    );
    const counts = references.rows[0];
    if (Object.values(counts).some((value) => Number(value) > 0)) {
      throw new AppError(409, 'PROGRAMME_IN_USE', 'Move or remove the classes and modules for this programme first.', counts);
    }
    await query('DELETE FROM programmes WHERE id = $1', [programme.id]);
    await auditLog({ req, action: 'admin.programme_deleted', entityType: 'programme', entityId: programme.id });
    res.json({ deleted: true });
  })
);

router.get(
  '/classes',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [];
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      conditions.push(`p.department_id = $${params.length}`);
    } else if (req.query.department_id) {
      params.push(req.query.department_id);
      conditions.push(`p.department_id = $${params.length}`);
    }
    if (req.query.programme_id) {
      params.push(req.query.programme_id);
      conditions.push(`c.programme_id = $${params.length}`);
    }
    const result = await query(
      `SELECT c.*, p.code AS programme_code, p.name AS programme_name,
              d.code AS department_code, d.name AS department_name,
              count(DISTINCT u.id)::int AS student_count,
              count(DISTINCT cm.module_id)::int AS module_count
       FROM classes c
       JOIN programmes p ON p.id = c.programme_id
       JOIN departments d ON d.id = p.department_id
       LEFT JOIN users u ON u.class_id = c.id AND u.is_active = true
       LEFT JOIN class_modules cm ON cm.class_id = c.id
       ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
       GROUP BY c.id, p.code, p.name, d.code, d.name
       ORDER BY d.name, c.code`,
      params
    );
    res.json({ classes: result.rows });
  })
);

router.post(
  '/classes',
  validate(
    z.object({
      programme_id: uuid,
      code: z.string().trim().min(1).max(50).optional(),
      name: longName,
      year_of_study: z.coerce.number().int().min(1).max(8),
      intake: z.string().trim().min(1).max(50).optional().default('Main'),
      stream: z.string().trim().min(1).max(50).optional().default('Day'),
      default_study_mode: z.enum(['physical', 'online', 'hybrid']).optional().default('physical')
    })
  ),
  asyncHandler(async (req, res) => {
    const programme = await assertProgrammeScope(req.user, req.body.programme_id);
    const stream = req.body.stream || 'Day';
    const code = req.body.code
      ? req.body.code.toUpperCase()
      : [programme.code, `Y${req.body.year_of_study}`, stream.toLowerCase() === 'day' ? '' : codeFromName(stream)]
        .filter(Boolean)
        .join('-');
    let created;
    try {
      const result = await query(
        `INSERT INTO classes (programme_id, department_id, code, name, year_of_study, intake, stream, default_study_mode)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8) RETURNING *`,
        [
          programme.id,
          programme.department_id,
          code,
          req.body.name,
          req.body.year_of_study,
          req.body.intake || 'Main',
          stream,
          req.body.default_study_mode || 'physical'
        ]
      );
      created = result.rows[0];
    } catch (error) {
      if (isPgUniqueViolation(error)) throw new AppError(409, 'CLASS_EXISTS', 'That class already exists for this programme, intake, and stream.');
      throw error;
    }
    await auditLog({ req, action: 'admin.class_created', entityType: 'class', entityId: created.id });
    res.status(201).json({ class: created });
  })
);

router.patch(
  '/classes/:id',
  validate(
    z.object({
      programme_id: uuid.optional(),
      code: z.string().trim().min(1).max(50).optional(),
      name: longName.optional(),
      year_of_study: z.coerce.number().int().min(1).max(8).optional(),
      intake: z.string().trim().min(1).max(50).optional(),
      stream: z.string().trim().min(1).max(50).optional(),
      default_study_mode: z.enum(['physical', 'online', 'hybrid']).optional()
    })
  ),
  asyncHandler(async (req, res) => {
    const existing = await findClass(req.params.id);
    if (!existing) throw new AppError(404, 'CLASS_NOT_FOUND', 'Class not found.');
    assertDepartmentScope(req.user, existing.programme_department_id);
    const programme = req.body.programme_id
      ? await assertProgrammeScope(req.user, req.body.programme_id)
      : await findProgramme(existing.programme_id);
    const fields = [];
    const params = [existing.id];
    if (req.body.programme_id !== undefined) {
      params.push(programme.id);
      fields.push(`programme_id = $${params.length}`);
      params.push(programme.department_id);
      fields.push(`department_id = $${params.length}`);
    }
    if (req.body.code !== undefined) {
      params.push(req.body.code.toUpperCase());
      fields.push(`code = $${params.length}`);
    }
    if (req.body.name !== undefined) {
      params.push(req.body.name);
      fields.push(`name = $${params.length}`);
    }
    if (req.body.year_of_study !== undefined) {
      params.push(req.body.year_of_study);
      fields.push(`year_of_study = $${params.length}`);
    }
    if (req.body.intake !== undefined) {
      params.push(req.body.intake);
      fields.push(`intake = $${params.length}`);
    }
    if (req.body.stream !== undefined) {
      params.push(req.body.stream);
      fields.push(`stream = $${params.length}`);
    }
    if (req.body.default_study_mode !== undefined) {
      params.push(req.body.default_study_mode);
      fields.push(`default_study_mode = $${params.length}`);
    }
    if (!fields.length) throw new AppError(400, 'NO_CHANGES', 'No changes were supplied.');
    let updated;
    try {
      const result = await query(
        `UPDATE classes SET ${fields.join(', ')} WHERE id = $1 RETURNING *`,
        params
      );
      updated = result.rows[0];
    } catch (error) {
      if (isPgUniqueViolation(error)) throw new AppError(409, 'CLASS_EXISTS', 'That class already exists for this programme, intake, and stream.');
      throw error;
    }
    await auditLog({ req, action: 'admin.class_updated', entityType: 'class', entityId: updated.id });
    res.json({ class: updated });
  })
);

router.delete(
  '/classes/:id',
  asyncHandler(async (req, res) => {
    const existing = await findClass(req.params.id);
    if (!existing) throw new AppError(404, 'CLASS_NOT_FOUND', 'Class not found.');
    assertDepartmentScope(req.user, existing.programme_department_id);
    const references = await query(
      `SELECT
         (SELECT count(*)::int FROM users WHERE class_id = $1) AS users,
         (SELECT count(*)::int FROM timetable_slots WHERE class_id = $1) AS timetable_slots,
         (SELECT count(*)::int FROM class_reps WHERE class_id = $1 AND is_active = true) AS class_reps`,
      [existing.id]
    );
    const counts = references.rows[0];
    if (Object.values(counts).some((value) => Number(value) > 0)) {
      throw new AppError(409, 'CLASS_IN_USE', 'Move or remove the users, representatives, and timetable slots for this class first.', counts);
    }
    await withTransaction(async (client) => {
      await client.query('DELETE FROM class_modules WHERE class_id = $1', [existing.id]);
      await client.query('DELETE FROM classes WHERE id = $1', [existing.id]);
    });
    await auditLog({ req, action: 'admin.class_deleted', entityType: 'class', entityId: existing.id });
    res.json({ deleted: true });
  })
);

router.get(
  '/classes/:id/modules',
  asyncHandler(async (req, res) => {
    const existing = await findClass(req.params.id);
    if (!existing) throw new AppError(404, 'CLASS_NOT_FOUND', 'Class not found.');
    assertDepartmentScope(req.user, existing.programme_department_id);
    const params = [existing.id];
    let semesterSql = '';
    if (req.query.semester_id) {
      params.push(req.query.semester_id);
      semesterSql = `AND cm.semester_id = $${params.length}`;
    }
    const result = await query(
      `SELECT cm.id AS link_id, cm.semester_id, m.id, m.code, m.name, m.credit_units
       FROM class_modules cm
       JOIN modules m ON m.id = cm.module_id
       WHERE cm.class_id = $1 ${semesterSql}
       ORDER BY m.code`,
      params
    );
    res.json({ modules: result.rows });
  })
);

router.post(
  '/classes/:id/modules',
  validate(z.object({ module_id: uuid, semester_id: uuid.optional() })),
  asyncHandler(async (req, res) => {
    const existing = await findClass(req.params.id);
    if (!existing) throw new AppError(404, 'CLASS_NOT_FOUND', 'Class not found.');
    assertDepartmentScope(req.user, existing.programme_department_id);
    const module = await assertModuleScope(req.user, req.body.module_id);
    if (module.department_id !== existing.programme_department_id) {
      throw new AppError(400, 'MODULE_DEPARTMENT_MISMATCH', 'The module belongs to a different department.');
    }
    const semester = req.body.semester_id ? await assertSemester(req.body.semester_id) : await getCurrentSemester();
    if (!semester) throw new AppError(409, 'NO_SEMESTER', 'No current semester is configured.');
    const result = await query(
      `INSERT INTO class_modules (class_id, module_id, semester_id)
       VALUES ($1, $2, $3)
       ON CONFLICT (class_id, module_id, semester_id) DO NOTHING
       RETURNING id`,
      [existing.id, module.id, semester.id]
    );
    await auditLog({
      req,
      action: 'admin.class_module_linked',
      entityType: 'class',
      entityId: existing.id,
      details: { module_id: module.id, semester_id: semester.id }
    });
    res.status(201).json({ linked: Boolean(result.rowCount), semester_id: semester.id });
  })
);

router.delete(
  '/classes/:id/modules/:moduleId',
  asyncHandler(async (req, res) => {
    const existing = await findClass(req.params.id);
    if (!existing) throw new AppError(404, 'CLASS_NOT_FOUND', 'Class not found.');
    assertDepartmentScope(req.user, existing.programme_department_id);
    const params = [existing.id, req.params.moduleId];
    let semesterSql = '';
    if (req.query.semester_id) {
      params.push(req.query.semester_id);
      semesterSql = `AND semester_id = $${params.length}`;
    }
    const result = await query(
      `DELETE FROM class_modules WHERE class_id = $1 AND module_id = $2 ${semesterSql} RETURNING id`,
      params
    );
    if (!result.rowCount) throw new AppError(404, 'CLASS_MODULE_NOT_FOUND', 'Module link not found.');
    await auditLog({
      req,
      action: 'admin.class_module_unlinked',
      entityType: 'class',
      entityId: existing.id,
      details: { module_id: req.params.moduleId }
    });
    res.json({ deleted: true });
  })
);

router.get(
  '/modules',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [];
    departmentFilter(req.user, params, conditions, 'm');
    if (isSuper(req.user) && req.query.department_id) {
      params.push(req.query.department_id);
      conditions.push(`m.department_id = $${params.length}`);
    }
    if (req.query.programme_id) {
      params.push(req.query.programme_id);
      conditions.push(`m.programme_id = $${params.length}`);
    }
    if (req.query.q) {
      params.push(`%${String(req.query.q).toLowerCase()}%`);
      conditions.push(`(lower(m.code) LIKE $${params.length} OR lower(m.name) LIKE $${params.length})`);
    }
    const result = await query(
      `SELECT m.*, d.code AS department_code, d.name AS department_name,
              p.code AS programme_code, p.name AS programme_name,
              u.name AS lecturer_name,
              count(DISTINCT cm.class_id)::int AS class_count,
              count(DISTINCT t.id)::int AS timetable_count
       FROM modules m
       JOIN departments d ON d.id = m.department_id
       LEFT JOIN programmes p ON p.id = m.programme_id
       LEFT JOIN users u ON u.id = m.lecturer_id
       LEFT JOIN class_modules cm ON cm.module_id = m.id
       LEFT JOIN timetable_slots t ON t.module_id = m.id
       ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
       GROUP BY m.id, d.code, d.name, p.code, p.name, u.name
       ORDER BY m.code`,
      params
    );
    res.json({ modules: result.rows });
  })
);

router.post(
  '/modules',
  validate(
    z.object({
      code: shortCode,
      name: longName,
      department_id: uuid.optional(),
      programme_id: uuid.nullable().optional(),
      lecturer_id: uuid.nullable().optional(),
      credit_units: z.coerce.number().int().min(1).max(10).optional().default(3)
    })
  ),
  asyncHandler(async (req, res) => {
    const departmentId = req.body.department_id || req.user.department_id;
    assertDepartmentScope(req.user, departmentId);
    if (!departmentId) throw new AppError(400, 'DEPARTMENT_REQUIRED', 'Choose a department.');
    if (req.body.programme_id) {
      const programme = await assertProgrammeScope(req.user, req.body.programme_id);
      if (programme.department_id !== departmentId) {
        throw new AppError(400, 'PROGRAMME_DEPARTMENT_MISMATCH', 'The programme belongs to a different department.');
      }
    }
    if (req.body.lecturer_id) {
      const lecturer = await query('SELECT id, role, department_id, is_active FROM users WHERE id = $1', [req.body.lecturer_id]);
      if (!lecturer.rows[0]?.is_active) throw new AppError(404, 'LECTURER_NOT_FOUND', 'Lecturer not found.');
      if (!['lecturer', 'department_admin'].includes(lecturer.rows[0].role)) {
        throw new AppError(400, 'LECTURER_ROLE', 'Choose a lecturer or administrator as the module owner.');
      }
      if (!isSuper(req.user) && lecturer.rows[0].department_id !== req.user.department_id) {
        throw new AppError(403, 'DEPARTMENT_SCOPE', 'You can only assign staff from your department.');
      }
    }
    let module;
    try {
      const result = await query(
        `INSERT INTO modules (code, name, department_id, programme_id, lecturer_id, credit_units)
         VALUES ($1, $2, $3, $4, $5, $6) RETURNING *`,
        [
          req.body.code.toUpperCase(),
          req.body.name,
          departmentId,
          req.body.programme_id || null,
          req.body.lecturer_id || null,
          req.body.credit_units
        ]
      );
      module = result.rows[0];
    } catch (error) {
      if (isPgUniqueViolation(error)) throw new AppError(409, 'MODULE_EXISTS', 'That module code already exists.');
      throw error;
    }
    await auditLog({ req, action: 'admin.module_created', entityType: 'module', entityId: module.id });
    res.status(201).json({ module });
  })
);

router.patch(
  '/modules/:id',
  validate(
    z.object({
      code: shortCode.optional(),
      name: longName.optional(),
      department_id: uuid.optional(),
      programme_id: uuid.nullable().optional(),
      lecturer_id: uuid.nullable().optional(),
      credit_units: z.coerce.number().int().min(1).max(10).optional()
    })
  ),
  asyncHandler(async (req, res) => {
    const module = await assertModuleScope(req.user, req.params.id);
    const departmentId = req.body.department_id || module.department_id;
    assertDepartmentScope(req.user, departmentId);
    if (req.body.programme_id) {
      const programme = await assertProgrammeScope(req.user, req.body.programme_id);
      if (programme.department_id !== departmentId) {
        throw new AppError(400, 'PROGRAMME_DEPARTMENT_MISMATCH', 'The programme belongs to a different department.');
      }
    }
    if (req.body.lecturer_id) {
      const lecturer = await query('SELECT id, role, department_id, is_active FROM users WHERE id = $1', [req.body.lecturer_id]);
      if (!lecturer.rows[0]?.is_active) throw new AppError(404, 'LECTURER_NOT_FOUND', 'Lecturer not found.');
      if (!['lecturer', 'department_admin'].includes(lecturer.rows[0].role)) {
        throw new AppError(400, 'LECTURER_ROLE', 'Choose a lecturer or administrator as the module owner.');
      }
      if (!isSuper(req.user) && lecturer.rows[0].department_id !== req.user.department_id) {
        throw new AppError(403, 'DEPARTMENT_SCOPE', 'You can only assign staff from your department.');
      }
    }
    const fields = [];
    const params = [module.id];
    if (req.body.code !== undefined) {
      params.push(req.body.code.toUpperCase());
      fields.push(`code = $${params.length}`);
    }
    if (req.body.name !== undefined) {
      params.push(req.body.name);
      fields.push(`name = $${params.length}`);
    }
    if (req.body.department_id !== undefined) {
      params.push(departmentId);
      fields.push(`department_id = $${params.length}`);
    }
    if (req.body.programme_id !== undefined) {
      params.push(req.body.programme_id || null);
      fields.push(`programme_id = $${params.length}`);
    }
    if (req.body.lecturer_id !== undefined) {
      params.push(req.body.lecturer_id || null);
      fields.push(`lecturer_id = $${params.length}`);
    }
    if (req.body.credit_units !== undefined) {
      params.push(req.body.credit_units);
      fields.push(`credit_units = $${params.length}`);
    }
    if (!fields.length) throw new AppError(400, 'NO_CHANGES', 'No changes were supplied.');
    let updated;
    try {
      const result = await query(
        `UPDATE modules SET ${fields.join(', ')} WHERE id = $1 RETURNING *`,
        params
      );
      updated = result.rows[0];
    } catch (error) {
      if (isPgUniqueViolation(error)) throw new AppError(409, 'MODULE_EXISTS', 'That module code already exists.');
      throw error;
    }
    await auditLog({ req, action: 'admin.module_updated', entityType: 'module', entityId: module.id });
    res.json({ module: updated });
  })
);

router.delete(
  '/modules/:id',
  asyncHandler(async (req, res) => {
    const module = await assertModuleScope(req.user, req.params.id);
    const references = await query(
      `SELECT
         (SELECT count(*)::int FROM timetable_slots WHERE module_id = $1) AS timetable_slots,
         (SELECT count(*)::int FROM class_modules WHERE module_id = $1) AS class_modules,
         (SELECT count(*)::int FROM enrolments WHERE module_id = $1) AS enrolments,
         (SELECT count(*)::int FROM bookings WHERE module_id = $1) AS bookings`,
      [module.id]
    );
    const counts = references.rows[0];
    if (Object.values(counts).some((value) => Number(value) > 0)) {
      throw new AppError(409, 'MODULE_IN_USE', 'Remove the timetable slots, class links, enrolments, and bookings for this module first.', counts);
    }
    await query('DELETE FROM modules WHERE id = $1', [module.id]);
    await auditLog({ req, action: 'admin.module_deleted', entityType: 'module', entityId: module.id });
    res.json({ deleted: true });
  })
);

router.get(
  '/semesters',
  asyncHandler(async (req, res) => {
    const result = await query('SELECT * FROM semesters ORDER BY start_date DESC');
    res.json({ semesters: result.rows });
  })
);

router.post(
  '/semesters',
  validate(
    z.object({
      name: z.string().trim().min(4).max(100),
      start_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
      end_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
      is_current: z.boolean().optional().default(false)
    })
  ),
  asyncHandler(async (req, res) => {
    if (!isSuper(req.user)) throw new AppError(403, 'SUPER_ADMIN_REQUIRED', 'Only a super administrator can create semesters.');
    if (req.body.end_date <= req.body.start_date) {
      throw new AppError(400, 'INVALID_SEMESTER_DATES', 'The semester end date must be after its start date.');
    }
    let semester;
    try {
      semester = await withTransaction(async (client) => {
        if (req.body.is_current) {
          await client.query('UPDATE semesters SET is_current = false WHERE is_current = true');
        }
        const result = await client.query(
          `INSERT INTO semesters (name, start_date, end_date, is_current)
           VALUES ($1, $2, $3, $4) RETURNING *`,
          [req.body.name, req.body.start_date, req.body.end_date, req.body.is_current]
        );
        return result.rows[0];
      });
    } catch (error) {
      if (isPgUniqueViolation(error)) throw new AppError(409, 'SEMESTER_EXISTS', 'That semester name already exists.');
      throw error;
    }
    await auditLog({ req, action: 'admin.semester_created', entityType: 'semester', entityId: semester.id });
    res.status(201).json({ semester });
  })
);

router.patch(
  '/semesters/:id',
  validate(
    z.object({
      name: z.string().trim().min(4).max(100).optional(),
      start_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
      end_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
      is_current: z.boolean().optional()
    })
  ),
  asyncHandler(async (req, res) => {
    if (!isSuper(req.user)) throw new AppError(403, 'SUPER_ADMIN_REQUIRED', 'Only a super administrator can edit semesters.');
    const existing = await assertSemester(req.params.id);
    const start = req.body.start_date || existing.start_date;
    const end = req.body.end_date || existing.end_date;
    if (end <= start) throw new AppError(400, 'INVALID_SEMESTER_DATES', 'The semester end date must be after its start date.');
    const fields = [];
    const params = [existing.id];
    if (req.body.name !== undefined) {
      params.push(req.body.name);
      fields.push(`name = $${params.length}`);
    }
    if (req.body.start_date !== undefined) {
      params.push(req.body.start_date);
      fields.push(`start_date = $${params.length}`);
    }
    if (req.body.end_date !== undefined) {
      params.push(req.body.end_date);
      fields.push(`end_date = $${params.length}`);
    }
    if (req.body.is_current !== undefined) {
      params.push(req.body.is_current);
      fields.push(`is_current = $${params.length}`);
    }
    if (!fields.length) throw new AppError(400, 'NO_CHANGES', 'No changes were supplied.');
    let semester;
    try {
      semester = await withTransaction(async (client) => {
        if (req.body.is_current === true) {
          await client.query('UPDATE semesters SET is_current = false WHERE is_current = true AND id <> $1', [existing.id]);
        }
        const result = await client.query(
          `UPDATE semesters SET ${fields.join(', ')} WHERE id = $1 RETURNING *`,
          params
        );
        return result.rows[0];
      });
    } catch (error) {
      if (isPgUniqueViolation(error)) throw new AppError(409, 'SEMESTER_EXISTS', 'That semester name already exists.');
      throw error;
    }
    await auditLog({ req, action: 'admin.semester_updated', entityType: 'semester', entityId: semester.id });
    res.json({ semester });
  })
);

router.delete(
  '/semesters/:id',
  asyncHandler(async (req, res) => {
    if (!isSuper(req.user)) throw new AppError(403, 'SUPER_ADMIN_REQUIRED', 'Only a super administrator can delete semesters.');
    const semester = await assertSemester(req.params.id);
    const references = await query(
      `SELECT
         (SELECT count(*)::int FROM timetable_slots WHERE semester_id = $1) AS timetable_slots,
         (SELECT count(*)::int FROM class_modules WHERE semester_id = $1) AS class_modules,
         (SELECT count(*)::int FROM enrolments WHERE semester_id = $1) AS enrolments`,
      [semester.id]
    );
    const counts = references.rows[0];
    if (Object.values(counts).some((value) => Number(value) > 0)) {
      throw new AppError(409, 'SEMESTER_IN_USE', 'Remove this semester timetable, bookings, class links, and enrolments first.', counts);
    }
    await query('DELETE FROM semesters WHERE id = $1', [semester.id]);
    await auditLog({ req, action: 'admin.semester_deleted', entityType: 'semester', entityId: semester.id });
    res.json({ deleted: true });
  })
);

router.get(
  '/timetable',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [];
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      conditions.push(`m.department_id = $${params.length}`);
    }
    if (req.query.semester_id) {
      params.push(req.query.semester_id);
      conditions.push(`t.semester_id = $${params.length}`);
    } else {
      const semester = await getCurrentSemester();
      if (semester) {
        params.push(semester.id);
        conditions.push(`t.semester_id = $${params.length}`);
      }
    }
    if (req.query.class_id) {
      params.push(req.query.class_id);
      conditions.push(`t.class_id = $${params.length}`);
    }
    if (req.query.module_id) {
      params.push(req.query.module_id);
      conditions.push(`t.module_id = $${params.length}`);
    }
    if (req.query.lecturer_id) {
      params.push(req.query.lecturer_id);
      conditions.push(`t.lecturer_id = $${params.length}`);
    }
    if (req.query.facility_id) {
      params.push(req.query.facility_id);
      conditions.push(`t.facility_id = $${params.length}`);
    }
    if (req.query.from) {
      params.push(`${req.query.from}T00:00:00+03:00`);
      conditions.push(`t.end_at > $${params.length}`);
    }
    if (req.query.to) {
      params.push(`${req.query.to}T23:59:59+03:00`);
      conditions.push(`t.start_at < $${params.length}`);
    }
    params.push(Math.min(Math.max(Number(req.query.limit || 1000), 1), 2000));
    const result = await query(
      `SELECT t.*, m.code AS module_code, m.name AS module_name,
              c.code AS class_code, c.name AS class_name,
              f.name AS facility_name, f.building, f.room_number,
              l.name AS lecturer_name
       FROM timetable_slots t
       JOIN modules m ON m.id = t.module_id
       LEFT JOIN classes c ON c.id = t.class_id
       LEFT JOIN facilities f ON f.id = t.facility_id
       LEFT JOIN users l ON l.id = t.lecturer_id
       ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
       ORDER BY t.start_at
       LIMIT $${params.length}`,
      params
    );
    res.json({ slots: result.rows });
  })
);

export default router;
