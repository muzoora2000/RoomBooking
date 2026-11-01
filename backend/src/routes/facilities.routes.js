import express from 'express';
import { z } from 'zod';
import { query } from '../db/pool.js';
import { asyncHandler, AppError } from '../lib/errors.js';
import { auditLog } from '../lib/audit.js';
import { formatKampala, kampalaDate, kampalaDayBounds, fromKampalaISO } from '../lib/time.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import { notifyAdmins } from '../services/notifications.js';

const router = express.Router();

function equipmentJson() {
  return `COALESCE(
    json_agg(json_build_object('name', fe.name, 'quantity', fe.quantity) ORDER BY fe.name)
      FILTER (WHERE fe.id IS NOT NULL),
    '[]'::json
  )`;
}

export async function listFacilities(filters = {}) {
  const conditions = [];
  const params = [];
  if (filters.category) {
    params.push(filters.category);
    conditions.push(`f.category = $${params.length}`);
  }
  if (filters.department_id) {
    params.push(filters.department_id);
    conditions.push(`f.department_id = $${params.length}`);
  }
  if (filters.min_capacity) {
    params.push(Number(filters.min_capacity));
    conditions.push(`f.capacity >= $${params.length}`);
  }
  if (filters.status) {
    params.push(filters.status);
    conditions.push(`f.status = $${params.length}`);
  } else {
    conditions.push(`f.status <> 'blocked'`);
  }
  if (filters.q) {
    params.push(`%${String(filters.q).toLowerCase()}%`);
    conditions.push(
      `(lower(f.name) LIKE $${params.length} OR lower(f.building) LIKE $${params.length} OR lower(f.room_number) LIKE $${params.length} OR lower(f.location_description) LIKE $${params.length})`
    );
  }
  if (filters.equipment) {
    params.push(String(filters.equipment).toLowerCase());
    conditions.push(
      `EXISTS (SELECT 1 FROM facility_equipment fe2 WHERE fe2.facility_id = f.id AND lower(fe2.name) = $${params.length} AND fe2.quantity > 0)`
    );
  }
  const result = await query(
    `SELECT f.id, f.name, f.category, f.department_id, f.building, f.floor, f.wing, f.room_number,
            f.location_description, f.latitude, f.longitude, f.capacity, f.status,
            f.requires_approval, f.requires_authorized_role, f.checkin_mode, f.checkin_radius_m,
            f.photo_url, f.last_verified_at,
            d.code AS department_code, d.name AS department_name,
            ${equipmentJson()} AS equipment
     FROM facilities f
     JOIN departments d ON d.id = f.department_id
     LEFT JOIN facility_equipment fe ON fe.facility_id = f.id
     ${conditions.length ? `WHERE ${conditions.join(' AND ')}` : ''}
     GROUP BY f.id, d.code, d.name
     ORDER BY f.building, f.floor, f.room_number`,
    params
  );
  return result.rows;
}

export async function facilityDetail(facilityId) {
  const result = await query(
    `SELECT f.id, f.name, f.category, f.department_id, f.building, f.floor, f.wing, f.room_number,
            f.location_description, f.latitude, f.longitude, f.capacity, f.status,
            f.requires_approval, f.requires_authorized_role, f.checkin_mode, f.checkin_radius_m,
            f.qr_version, f.photo_url, f.last_verified_at, f.created_at, f.updated_at,
            d.code AS department_code, d.name AS department_name,
            ${equipmentJson()} AS equipment
     FROM facilities f
     JOIN departments d ON d.id = f.department_id
     LEFT JOIN facility_equipment fe ON fe.facility_id = f.id
     WHERE f.id = $1
     GROUP BY f.id, d.code, d.name`,
    [facilityId]
  );
  return result.rows[0] || null;
}

router.get(
  '/',
  asyncHandler(async (req, res) => {
    const facilities = await listFacilities(req.query);
    res.json({ facilities, count: facilities.length });
  })
);

router.get(
  '/categories',
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT category, count(*)::int AS count FROM facilities WHERE status <> 'blocked' GROUP BY category ORDER BY category`
    );
    res.json({ categories: result.rows });
  })
);

router.get(
  '/:id',
  asyncHandler(async (req, res) => {
    const facility = await facilityDetail(req.params.id);
    if (!facility) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
    const upcoming = await query(
      `SELECT b.id, b.start_at, b.end_at, b.session_mode, b.status, b.purpose,
              m.code AS module_code, m.name AS module_name
       FROM bookings b LEFT JOIN modules m ON m.id = b.module_id
       WHERE b.facility_id = $1 AND b.status IN ('pending','confirmed')
         AND b.end_at > now() AND b.start_at < now() + interval '7 days'
       ORDER BY b.start_at LIMIT 30`,
      [facility.id]
    );
    res.json({
      facility,
      upcoming: upcoming.rows.map((row) => ({
        ...row,
        start_local: formatKampala(row.start_at),
        end_local: formatKampala(row.end_at, 'HH:mm')
      }))
    });
  })
);

router.get(
  '/:id/availability',
  asyncHandler(async (req, res) => {
    const facility = await facilityDetail(req.params.id);
    if (!facility) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
    let dayStart;
    let dayEnd;
    if (req.query.date && /^\d{4}-\d{2}-\d{2}$/.test(req.query.date)) {
      const bounds = kampalaDayBounds(req.query.date);
      dayStart = bounds.start;
      dayEnd = bounds.end;
    } else {
      const bounds = kampalaDayBounds(kampalaDate());
      dayStart = bounds.start;
      dayEnd = bounds.end;
    }
    const bookings = await query(
      `SELECT b.id, b.start_at, b.end_at, b.status, b.source, b.purpose,
              m.code AS module_code, m.name AS module_name
       FROM bookings b LEFT JOIN modules m ON m.id = b.module_id
       WHERE b.facility_id = $1 AND b.status IN ('pending','confirmed')
         AND b.start_at < $3 AND b.end_at > $2
       ORDER BY b.start_at`,
      [facility.id, dayStart, dayEnd]
    );
    const blocks = await query(
      `SELECT id, start_at, end_at, reason FROM facility_blocks
       WHERE facility_id = $1 AND start_at < $3 AND end_at > $2 ORDER BY start_at`,
      [facility.id, dayStart, dayEnd]
    );
    const exams = await query(
      `SELECT eb.id, eb.name, eb.start_at, eb.end_at
       FROM exam_blocks eb JOIN exam_block_facilities ebf ON ebf.exam_block_id = eb.id
       WHERE ebf.facility_id = $1 AND eb.start_at < $3 AND eb.end_at > $2 ORDER BY eb.start_at`,
      [facility.id, dayStart, dayEnd]
    );
    const busy = [
      ...bookings.rows.map((row) => ({
        id: row.id,
        type: 'booking',
        start_at: row.start_at,
        end_at: row.end_at,
        label: row.module_code || row.purpose || 'Booked',
        status: row.status
      })),
      ...blocks.rows.map((row) => ({
        id: row.id,
        type: 'maintenance',
        start_at: row.start_at,
        end_at: row.end_at,
        label: row.reason
      })),
      ...exams.rows.map((row) => ({
        id: row.id,
        type: 'exam',
        start_at: row.start_at,
        end_at: row.end_at,
        label: row.name
      }))
    ].sort((a, b) => new Date(a.start_at) - new Date(b.start_at));
    res.json({
      facility_id: facility.id,
      facility_name: facility.name,
      day: kampalaDate(dayStart),
      day_start: dayStart,
      day_end: dayEnd,
      busy,
      sessions: bookings.rows.map((row) => ({
        id: row.id,
        start_at: row.start_at,
        end_at: row.end_at,
        start_local: formatKampala(row.start_at, 'HH:mm'),
        end_local: formatKampala(row.end_at, 'HH:mm'),
        label: row.module_code || row.purpose || 'Booked',
        status: row.status
      }))
    });
  })
);

router.post(
  '/:id/issues',
  authenticate,
  validate(
    z.object({
      category: z.enum(['projector', 'power', 'cleanliness', 'furniture', 'wrong_details', 'other']),
      description: z.string().min(5).max(2000),
      photo_data: z.string().max(1500000).optional()
    })
  ),
  asyncHandler(async (req, res) => {
    const facility = await facilityDetail(req.params.id);
    if (!facility) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
    let photo = req.body.photo_data || null;
    if (photo) {
      if (!/^data:image\/(png|jpe?g|webp);base64,[A-Za-z0-9+/=]+$/.test(photo)) {
        throw new AppError(400, 'INVALID_PHOTO', 'Photo must be a PNG, JPEG, or WebP data URL.');
      }
      if (Buffer.byteLength(photo, 'utf8') > 1048576) {
        throw new AppError(400, 'PHOTO_TOO_LARGE', 'Photo must be 1MB or smaller.');
      }
    }
    const result = await query(
      `INSERT INTO room_issues (facility_id, reported_by, category, description, photo_data)
       VALUES ($1,$2,$3,$4,$5) RETURNING id, facility_id, category, status, created_at`,
      [facility.id, req.user.id, req.body.category, req.body.description, photo]
    );
    await auditLog({
      req,
      action: 'room_issue.reported',
      entityType: 'room_issue',
      entityId: result.rows[0].id,
      details: { facility_id: facility.id, category: req.body.category }
    });
    await notifyAdmins({
      departmentId: facility.department_id,
      type: 'room_issue',
      eventType: 'room_issue',
      title: 'Room issue reported',
      message: `${req.user.name} reported ${req.body.category.replace('_', ' ')} in ${facility.name}: ${req.body.description}`,
      severity: req.body.category === 'power' ? 'warning' : 'info',
      link: '/admin.html#issues'
    }).catch(() => {});
    res.status(201).json({ issue: result.rows[0] });
  })
);

router.get('/:id/upcoming', asyncHandler(async (req, res) => {
  const facility = await facilityDetail(req.params.id);
  if (!facility) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
  const sessions = await query(
    `SELECT b.id, b.start_at, b.end_at, b.session_mode, b.status, b.purpose, m.code AS module_code
     FROM bookings b LEFT JOIN modules m ON m.id = b.module_id
     WHERE b.facility_id = $1 AND b.status = 'confirmed' AND b.end_at > now()
     ORDER BY b.start_at LIMIT 10`,
    [facility.id]
  );
  res.json({
    facility_id: facility.id,
    sessions: sessions.rows.map((row) => ({
      ...row,
      start_local: formatKampala(row.start_at),
      end_local: formatKampala(row.end_at, 'HH:mm')
    }))
  });
}));

export default router;
