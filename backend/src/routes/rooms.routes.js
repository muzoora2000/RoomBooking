import express from 'express';
import { query } from '../db/pool.js';
import { asyncHandler, AppError } from '../lib/errors.js';
import { formatKampala } from '../lib/time.js';
import { signDoorToken, verifyRoomSignature } from '../services/qr.js';

const router = express.Router();

async function loadRoom(facilityId) {
  const result = await query(
    `SELECT f.id, f.name, f.category, f.building, f.floor, f.wing, f.room_number,
            f.location_description, f.latitude, f.longitude, f.capacity, f.status,
            f.checkin_mode, f.checkin_radius_m, f.qr_version, f.qr_secret, f.photo_url,
            d.code AS department_code, d.name AS department_name
     FROM facilities f JOIN departments d ON d.id = f.department_id
     WHERE f.id = $1`,
    [facilityId]
  );
  return result.rows[0] || null;
}

async function sessionWindow(facilityId) {
  const current = await query(
    `SELECT b.id, b.start_at, b.end_at, b.session_mode, b.status, m.code AS module_code, m.name AS module_name
     FROM bookings b LEFT JOIN modules m ON m.id = b.module_id
     WHERE b.facility_id = $1 AND b.status = 'confirmed'
       AND b.start_at <= now() AND b.end_at > now()
     ORDER BY b.start_at LIMIT 1`,
    [facilityId]
  );
  const next = await query(
    `SELECT b.id, b.start_at, b.end_at, b.session_mode, b.status, m.code AS module_code, m.name AS module_name
     FROM bookings b LEFT JOIN modules m ON m.id = b.module_id
     WHERE b.facility_id = $1 AND b.status = 'confirmed' AND b.start_at > now()
     ORDER BY b.start_at LIMIT 1`,
    [facilityId]
  );
  const shape = (row) => row ? {
    ...row,
    start_local: formatKampala(row.start_at),
    end_local: formatKampala(row.end_at, 'HH:mm')
  } : null;
  return { current: shape(current.rows[0]), next: shape(next.rows[0]) };
}

router.get(
  '/:id',
  asyncHandler(async (req, res) => {
    const room = await loadRoom(req.params.id);
    if (!room) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
    const qrValid = verifyRoomSignature(room, req.query.v, req.query.s);
    const sessions = await sessionWindow(room.id);
    const { qr_secret, ...safeRoom } = room;
    res.json({
      facility: safeRoom,
      qr_valid: qrValid,
      door_token: qrValid ? signDoorToken(room.id, 60) : null,
      door_token_seconds: 60,
      checkin_available: qrValid && room.status === 'active',
      ...sessions
    });
  })
);

router.get(
  '/:id/sessions',
  asyncHandler(async (req, res) => {
    const room = await loadRoom(req.params.id);
    if (!room) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
    const sessions = await sessionWindow(room.id);
    res.json({ facility_id: room.id, ...sessions });
  })
);

export default router;
