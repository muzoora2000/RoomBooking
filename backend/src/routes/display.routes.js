import express from 'express';
import { z } from 'zod';
import { query } from '../db/pool.js';
import { asyncHandler, AppError } from '../lib/errors.js';
import { constantTimeEqual, sha256Hex } from '../lib/crypto.js';
import { formatKampala } from '../lib/time.js';
import { validate } from '../middleware/validate.js';
import { authenticate, issueDisplayToken, requireDisplay } from '../middleware/auth.js';
import { buildRoomQrUrl, generateQrDataUrl, signDoorToken } from '../services/qr.js';
import { auditLog } from '../lib/audit.js';

const router = express.Router();

const loginSchema = z.object({
  device_id: z.string().uuid(),
  key: z.string().min(16).max(200)
});

async function displayPayload(facilityId) {
  const room = await query(
    `SELECT f.id, f.name, f.category, f.building, f.floor, f.wing, f.room_number,
            f.location_description, f.capacity, f.status, f.qr_version, f.qr_secret,
            f.checkin_mode, d.name AS department_name
     FROM facilities f JOIN departments d ON d.id = f.department_id
     WHERE f.id = $1`,
    [facilityId]
  );
  const facility = room.rows[0];
  if (!facility) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
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
  const { qr_secret, ...safeFacility } = facility;
  const roomUrl = buildRoomQrUrl(facility);
  const roomQr = await generateQrDataUrl(roomUrl, { width: 420, margin: 1 });
  const doorToken = signDoorToken(facilityId, 60);
  const doorQr = await generateQrDataUrl(doorToken, { width: 420, margin: 1 });
  return {
    facility: safeFacility,
    current: shape(current.rows[0]),
    next: shape(next.rows[0]),
    door_token: doorToken,
    door_token_seconds: 60,
    door_qr_data_url: doorQr,
    room_qr_url: roomUrl,
    room_qr_data_url: roomQr,
    server_time: new Date().toISOString()
  };
}

router.post(
  '/login',
  validate(loginSchema),
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT id, facility_id, label, key_hash, revoked_at FROM display_devices WHERE id = $1`,
      [req.body.device_id]
    );
    const device = result.rows[0];
    if (!device || device.revoked_at) {
      throw new AppError(401, 'DISPLAY_UNAUTHORIZED', 'This display is not registered or was revoked.');
    }
    const expected = sha256Hex(req.body.key);
    if (!constantTimeEqual(expected, device.key_hash)) {
      await auditLog({ req, action: 'display.login_failed', entityType: 'display_device', entityId: device.id });
      throw new AppError(401, 'DISPLAY_UNAUTHORIZED', 'Display key is incorrect.');
    }
    await query('UPDATE display_devices SET last_seen_at = now() WHERE id = $1', [device.id]);
    await auditLog({ req, action: 'display.login', entityType: 'display_device', entityId: device.id });
    res.json({
      token: issueDisplayToken(device),
      device: { id: device.id, label: device.label, facility_id: device.facility_id },
      ...(await displayPayload(device.facility_id))
    });
  })
);

router.get(
  '/room',
  requireDisplay,
  asyncHandler(async (req, res) => {
    await query('UPDATE display_devices SET last_seen_at = now() WHERE id = $1', [req.display.id]);
    res.json(await displayPayload(req.displayFacilityId));
  })
);

router.post(
  '/heartbeat',
  requireDisplay,
  asyncHandler(async (req, res) => {
    await query('UPDATE display_devices SET last_seen_at = now() WHERE id = $1', [req.display.id]);
    res.json({ ok: true, server_time: new Date().toISOString() });
  })
);

export default router;
