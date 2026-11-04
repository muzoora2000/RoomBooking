import express from 'express';
import { parse } from 'csv-parse/sync';
import { z } from 'zod';
import { query } from '../db/pool.js';
import { asyncHandler, AppError } from '../lib/errors.js';
import { auditLog } from '../lib/audit.js';
import { formatKampala, fromKampala } from '../lib/time.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import { requireAdmin } from '../middleware/roles.js';
import { getCurrentSemester } from '../services/studyMode.js';
import { createBooking } from '../services/booking.js';

const router = express.Router();
router.use(authenticate);

function isSuper(user) {
  return user.role === 'super_admin';
}

async function assertModuleScope(user, moduleId) {
  const result = await query('SELECT id, department_id FROM modules WHERE id = $1', [moduleId]);
  const module = result.rows[0];
  if (!module) throw new AppError(404, 'MODULE_NOT_FOUND', 'Module not found.');
  if (!isSuper(user) && module.department_id !== user.department_id) {
    throw new AppError(403, 'DEPARTMENT_SCOPE', 'You can only manage timetable slots for modules in your department.');
  }
  return module;
}

router.get(
  '/',
  asyncHandler(async (req, res) => {
    const params = [];
    const conditions = [];
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
       LIMIT 2000`,
      params
    );
    res.json({
      slots: result.rows.map((row) => ({
        ...row,
        start_local: formatKampala(row.start_at),
        end_local: formatKampala(row.end_at, 'HH:mm')
      }))
    });
  })
);

router.get(
  '/my',
  asyncHandler(async (req, res) => {
    const semester = await getCurrentSemester();
    if (!semester) throw new AppError(409, 'NO_SEMESTER', 'No current semester is configured.');
    const result = await query(
      `SELECT DISTINCT t.*, m.code AS module_code, m.name AS module_name,
              c.code AS class_code, f.name AS facility_name, f.building, f.room_number,
              l.name AS lecturer_name
       FROM timetable_slots t
       JOIN modules m ON m.id = t.module_id
       LEFT JOIN classes c ON c.id = t.class_id
       LEFT JOIN facilities f ON f.id = t.facility_id
       LEFT JOIN users l ON l.id = t.lecturer_id
       LEFT JOIN enrolments e ON e.module_id = t.module_id AND e.semester_id = t.semester_id AND e.user_id = $1
       WHERE t.semester_id = $2
         AND (e.id IS NOT NULL OR t.lecturer_id = $1 OR t.class_id = $3)
       ORDER BY t.start_at`,
      [req.user.id, semester.id, req.user.class_id]
    );
    res.json({
      semester,
      slots: result.rows.map((row) => ({
        ...row,
        start_local: formatKampala(row.start_at),
        end_local: formatKampala(row.end_at, 'HH:mm')
      }))
    });
  })
);

router.post(
  '/',
  requireAdmin,
  validate(
    z.object({
      semester_id: z.string().uuid().optional(),
      class_id: z.string().uuid().nullable().optional(),
      module_id: z.string().uuid(),
      lecturer_id: z.string().uuid().nullable().optional(),
      facility_id: z.string().uuid().nullable().optional(),
      start_at: z.string().min(8).max(60),
      end_at: z.string().min(8).max(60),
      session_mode: z.enum(['physical', 'online', 'hybrid']),
      online_platform: z.enum(['zoom', 'google_meet', 'teams', 'other']).nullable().optional(),
      online_link: z.string().max(2000).nullable().optional(),
      create_booking: z.boolean().optional().default(true)
    })
  ),
  asyncHandler(async (req, res) => {
    await assertModuleScope(req.user, req.body.module_id);
    const semester = req.body.semester_id
      ? (await query('SELECT * FROM semesters WHERE id = $1', [req.body.semester_id])).rows[0]
      : await getCurrentSemester();
    if (!semester) throw new AppError(409, 'NO_SEMESTER', 'No current semester is configured.');
    const start = new Date(req.body.start_at);
    const end = new Date(req.body.end_at);
    if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime()) || end <= start) {
      throw new AppError(400, 'INVALID_TIMES', 'Provide valid start and end times.');
    }
    let bookingId = null;
    if (req.body.create_booking) {
      const result = await createBooking({
        user: req.user,
        input: {
          module_id: req.body.module_id,
          class_id: req.body.class_id || null,
          facility_id: req.body.facility_id || null,
          lecturer_id: req.body.lecturer_id || null,
          session_mode: req.body.session_mode,
          online_platform: req.body.online_platform || null,
          online_link: req.body.online_link || null,
          start_at: start.toISOString(),
          end_at: end.toISOString(),
          source: 'timetable',
          is_locked: true,
          purpose: 'Official timetable'
        },
        req
      });
      bookingId = result.booking.id;
    }
    const inserted = await query(
      `INSERT INTO timetable_slots (semester_id, class_id, module_id, lecturer_id, facility_id, booking_id,
         start_at, end_at, session_mode, online_platform, online_link, imported_by)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
       RETURNING *`,
      [
        semester.id,
        req.body.class_id || null,
        req.body.module_id,
        req.body.lecturer_id || null,
        req.body.facility_id || null,
        bookingId,
        start,
        end,
        req.body.session_mode,
        req.body.online_platform || null,
        req.body.online_link || null,
        req.user.id
      ]
    );
    await auditLog({
      req,
      action: 'timetable.slot_created',
      entityType: 'timetable_slot',
      entityId: inserted.rows[0].id,
      details: { booking_id: bookingId, module_id: req.body.module_id }
    });
    res.status(201).json({ slot: inserted.rows[0], booking_id: bookingId });
  })
);

router.post(
  '/import',
  requireAdmin,
  validate(
    z.object({
      semester_id: z.string().uuid().optional(),
      csv: z.string().min(10).max(1000000),
      create_bookings: z.boolean().optional().default(true)
    })
  ),
  asyncHandler(async (req, res) => {
    const semester = req.body.semester_id
      ? (await query('SELECT * FROM semesters WHERE id = $1', [req.body.semester_id])).rows[0]
      : await getCurrentSemester();
    if (!semester) throw new AppError(409, 'NO_SEMESTER', 'No current semester is configured.');
    let rows;
    try {
      rows = parse(req.body.csv, {
        columns: (header) => header.map((value) => String(value).trim().toLowerCase()),
        skip_empty_lines: true,
        trim: true,
        bom: true,
        relax_column_count: true
      });
    } catch (error) {
      throw new AppError(400, 'CSV_INVALID', `Could not parse CSV: ${error.message}`);
    }
    if (rows.length > 500) throw new AppError(400, 'CSV_TOO_LARGE', 'Import at most 500 rows at a time.');
    const modules = await query(`SELECT id, code, department_id FROM modules`);
    const classes = await query(`SELECT id, code FROM classes`);
    const facilities = await query(`SELECT id, name, building, room_number FROM facilities`);
    const users = await query(`SELECT id, id_number FROM users`);
    const moduleByCode = new Map(modules.rows.map((row) => [row.code.toLowerCase(), row]));
    const classByCode = new Map(classes.rows.map((row) => [row.code.toLowerCase(), row]));
    const facilityByKey = new Map();
    for (const facility of facilities.rows) {
      facilityByKey.set(String(facility.id), facility);
      facilityByKey.set(`${facility.building}|${facility.room_number}`.toLowerCase(), facility);
      facilityByKey.set(facility.name.toLowerCase(), facility);
    }
    const userByIdNumber = new Map(users.rows.map((row) => [row.id_number.toLowerCase(), row]));
    const results = [];
    for (const [index, row] of rows.entries()) {
      const line = index + 2;
      try {
        const module = moduleByCode.get(String(row.module_code || '').toLowerCase());
        if (!module) throw new Error(`Unknown module_code ${row.module_code}`);
        if (!isSuper(req.user) && module.department_id !== req.user.department_id) {
          throw new Error('Module is outside your department');
        }
        const classRow = row.class_code ? classByCode.get(String(row.class_code).toLowerCase()) : null;
        if (row.class_code && !classRow) throw new Error(`Unknown class_code ${row.class_code}`);
        const lecturer = row.lecturer_id_number
          ? userByIdNumber.get(String(row.lecturer_id_number).toLowerCase())
          : null;
        if (row.lecturer_id_number && !lecturer) throw new Error(`Unknown lecturer_id_number ${row.lecturer_id_number}`);
        const facility = row.facility_id
          ? facilityByKey.get(String(row.facility_id))
          : facilityByKey.get(`${row.building || ''}|${row.room_number || ''}`.toLowerCase());
        if (String(row.session_mode || 'physical') !== 'online' && !facility) {
          throw new Error('Unknown facility_id or building/room_number');
        }
        const start = row.start_at
          ? new Date(row.start_at)
          : fromKampala(row.date, row.start_time);
        const end = row.end_at
          ? new Date(row.end_at)
          : fromKampala(row.date, row.end_time);
        if (Number.isNaN(start.getTime()) || Number.isNaN(end.getTime()) || end <= start) {
          throw new Error('Invalid start_at/end_at or date/start_time/end_time');
        }
        const duplicate = await query(
          `SELECT id FROM timetable_slots
           WHERE semester_id = $1 AND module_id = $2 AND start_at = $3
             AND ($4::uuid IS NULL OR class_id = $4)`,
          [semester.id, module.id, start, classRow?.id || null]
        );
        if (duplicate.rowCount) throw new Error('A timetable slot already exists for this module, class, and start time');
        let bookingId = null;
        if (req.body.create_bookings) {
          const created = await createBooking({
            user: req.user,
            input: {
              module_id: module.id,
              class_id: classRow?.id || null,
              facility_id: facility?.id || null,
              lecturer_id: lecturer?.id || null,
              session_mode: row.session_mode || 'physical',
              online_platform: row.online_platform || null,
              online_link: row.online_link || null,
              start_at: start.toISOString(),
              end_at: end.toISOString(),
              source: 'timetable',
              is_locked: true,
              purpose: 'Official timetable import'
            },
            req
          });
          bookingId = created.booking.id;
        }
        const inserted = await query(
          `INSERT INTO timetable_slots (semester_id, class_id, module_id, lecturer_id, facility_id, booking_id,
             start_at, end_at, session_mode, online_platform, online_link, imported_by)
           VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
           RETURNING id`,
          [
            semester.id,
            classRow?.id || null,
            module.id,
            lecturer?.id || null,
            facility?.id || null,
            bookingId,
            start,
            end,
            row.session_mode || 'physical',
            row.online_platform || null,
            row.online_link || null,
            req.user.id
          ]
        );
        results.push({ line, status: 'imported', slot_id: inserted.rows[0].id, booking_id: bookingId });
      } catch (error) {
        results.push({ line, status: 'failed', error: error.message });
      }
    }
    const imported = results.filter((row) => row.status === 'imported').length;
    await auditLog({
      req,
      action: 'timetable.imported',
      entityType: 'semester',
      entityId: semester.id,
      details: { imported, failed: results.length - imported }
    });
    res.json({
      semester_id: semester.id,
      total: results.length,
      imported,
      failed: results.length - imported,
      results
    });
  })
);

router.delete(
  '/:id',
  requireAdmin,
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT t.*, m.department_id AS module_department_id
       FROM timetable_slots t JOIN modules m ON m.id = t.module_id
       WHERE t.id = $1`,
      [req.params.id]
    );
    const slot = result.rows[0];
    if (!slot) throw new AppError(404, 'SLOT_NOT_FOUND', 'Timetable slot not found.');
    if (!isSuper(req.user) && slot.module_department_id !== req.user.department_id) {
      throw new AppError(403, 'DEPARTMENT_SCOPE', 'You can only remove timetable slots for modules in your department.');
    }
    await query('DELETE FROM timetable_slots WHERE id = $1', [slot.id]);
    if (slot.booking_id) {
      await query(
        `UPDATE bookings SET status = 'cancelled', release_reason = 'Official timetable slot removed', updated_at = now()
         WHERE id = $1 AND status IN ('pending','confirmed')`,
        [slot.booking_id]
      );
    }
    await auditLog({
      req,
      action: 'timetable.slot_deleted',
      entityType: 'timetable_slot',
      entityId: slot.id,
      details: { booking_id: slot.booking_id }
    });
    res.json({ deleted: true });
  })
);

export default router;
