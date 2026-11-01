import { getSettings } from './settings.js';
import { verifyDoorToken } from './qr.js';
import { auditLog } from '../lib/audit.js';
import { AppError } from '../lib/errors.js';
import { notifyAdmins, notifyBookingOwner, notifySessionEvent } from './notifications.js';
import { query, withTransaction } from '../db/pool.js';

const ADMIN_ROLES = new Set(['department_admin', 'super_admin']);

export function haversineMeters(lat1, lon1, lat2, lon2) {
  const toRad = (value) => (Number(value) * Math.PI) / 180;
  const earthRadius = 6371000;
  const dLat = toRad(lat2 - lat1);
  const dLon = toRad(lon2 - lon1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLon / 2) ** 2;
  return 2 * earthRadius * Math.asin(Math.sqrt(a));
}

export async function canCheckInForBooking(client, { booking, user }) {
  if (!booking) return false;
  if (booking.user_id === user.id || booking.lecturer_id === user.id) return true;
  if (ADMIN_ROLES.has(user.role)) {
    if (user.role === 'super_admin') return true;
    if (!booking.facility_id) return false;
    const facility = await client.query('SELECT department_id FROM facilities WHERE id = $1', [booking.facility_id]);
    return facility.rows[0]?.department_id === user.department_id;
  }
  if (!booking.module_id) return false;
  const delegation = await client.query(
    `SELECT 1 FROM delegations
     WHERE module_id = $1 AND to_user_id = $2
       AND starts_at <= $3 AND ends_at >= $4
       AND revoked_at IS NULL
     LIMIT 1`,
    [booking.module_id, user.id, booking.start_at, booking.end_at]
  );
  return delegation.rowCount > 0;
}

function windowFor(booking, settings) {
  const openBefore = Number(settings.checkin_open_minutes ?? 10) * 60_000;
  const graceAfter = Number(settings.no_show_grace_minutes ?? 15) * 60_000;
  const start = new Date(booking.start_at).getTime();
  return { opensAt: new Date(start - openBefore), closesAt: new Date(start + graceAfter) };
}

export async function checkinWindowConfig() {
  const settings = await getSettings(['checkin_open_minutes', 'no_show_grace_minutes']);
  return {
    opens_before_minutes: Number(settings.checkin_open_minutes ?? 10),
    grace_after_minutes: Number(settings.no_show_grace_minutes ?? 15)
  };
}

export async function assertCheckinWindow(booking, settings, { now = new Date(), allowOutside = false } = {}) {
  if (allowOutside) return;
  const { opensAt, closesAt } = windowFor(booking, settings);
  if (now < opensAt) {
    throw new AppError(409, 'CHECKIN_NOT_OPEN', `Check-in opens at ${opensAt.toISOString()} (${settings.checkin_open_minutes ?? 10} minutes before the session).`, {
      opens_at: opensAt.toISOString()
    });
  }
  if (now > closesAt) {
    throw new AppError(409, 'CHECKIN_CLOSED', 'The check-in window for this session has closed.', {
      closed_at: closesAt.toISOString()
    });
  }
}

export async function checkInBooking({
  bookingId,
  user,
  method,
  proof = {},
  req = null,
  allowOutsideWindow = false
}) {
  const settings = await getSettings([
    'checkin_open_minutes',
    'no_show_grace_minutes',
    'max_checkin_accuracy_m',
    'default_checkin_radius_m'
  ]);
  const outcome = await withTransaction(async (client) => {
    const result = await client.query(
      `SELECT b.*, f.checkin_mode, f.checkin_radius_m, f.latitude, f.longitude,
              f.name AS facility_name, f.category AS facility_category,
              m.code AS module_code, m.name AS module_name
       FROM bookings b
       LEFT JOIN facilities f ON f.id = b.facility_id
       LEFT JOIN modules m ON m.id = b.module_id
       WHERE b.id = $1
       FOR UPDATE OF b`,
      [bookingId]
    );
    const booking = result.rows[0];
    if (!booking) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Booking not found.');
    if (booking.checked_in_at) {
      return { booking, already: true, method: booking.checkin_method };
    }
    if (!['pending', 'confirmed'].includes(booking.status)) {
      throw new AppError(409, 'BOOKING_NOT_ACTIVE', `This booking is ${booking.status} and cannot be checked in.`);
    }
    if (booking.session_mode === 'online' || !booking.facility_id) {
      throw new AppError(409, 'CHECKIN_NOT_REQUIRED', 'Online sessions do not require room check-in. Join from My lectures instead.');
    }
    const permitted = await canCheckInForBooking(client, { booking, user });
    if (!permitted) {
      await recordFailedAttempt({ req, user, booking, reason: 'not_authorised' });
      throw new AppError(403, 'CHECKIN_FORBIDDEN', 'You are not authorised to check in for this session.');
    }
    const isAdminOverride = ADMIN_ROLES.has(user.role) && user.id !== booking.user_id;
    const effectiveMethod = isAdminOverride ? 'admin' : method;
    if (!['rotating', 'static_geo', 'admin'].includes(effectiveMethod)) {
      throw new AppError(400, 'INVALID_CHECKIN_METHOD', 'Check-in method must be rotating, static_geo, or admin.');
    }
    await assertCheckinWindow(booking, settings, { allowOutside: allowOutsideWindow || effectiveMethod === 'admin' });

    let distance = null;
    if (effectiveMethod === 'rotating') {
      const verification = verifyDoorToken(proof.door_token, booking.facility_id);
      if (!verification.valid) {
        await recordFailedAttempt({ req, user, booking, reason: `door_token_${verification.reason}` });
        throw new AppError(400, 'INVALID_DOOR_TOKEN', 'That room code is invalid or has expired. Scan the QR at the room door again.');
      }
    } else if (effectiveMethod === 'static_geo') {
      const latitude = Number(proof.latitude);
      const longitude = Number(proof.longitude);
      const accuracy = proof.accuracy === undefined || proof.accuracy === null ? null : Number(proof.accuracy);
      if (!Number.isFinite(latitude) || !Number.isFinite(longitude)) {
        throw new AppError(400, 'LOCATION_REQUIRED', 'Share your current location to check in for this room.');
      }
      if (accuracy !== null && accuracy > Number(settings.max_checkin_accuracy_m ?? 150)) {
        throw new AppError(400, 'LOCATION_INACCURATE', `Your GPS accuracy is about ${Math.round(accuracy)}m. Move outdoors or near a window and try again.`, {
          accuracy_m: Math.round(accuracy)
        });
      }
      distance = haversineMeters(latitude, longitude, booking.latitude, booking.longitude);
      const radius = Number(booking.checkin_radius_m || settings.default_checkin_radius_m || 100);
      if (distance > radius) {
        await recordFailedAttempt({ req, user, booking, reason: 'outside_radius', details: { distance_m: Math.round(distance) } });
        throw new AppError(409, 'OUTSIDE_CHECKIN_RADIUS', `You are about ${Math.round(distance)}m from ${booking.facility_name}. Check-in is allowed within ${radius}m.`, {
          distance_m: Math.round(distance),
          radius_m: radius
        });
      }
    } else if (effectiveMethod === 'admin') {
      if (!ADMIN_ROLES.has(user.role)) {
        throw new AppError(403, 'ADMIN_CHECKIN_FORBIDDEN', 'Only administrators can record an administrative check-in.');
      }
    }
    const update = await client.query(
      `UPDATE bookings
       SET checked_in_at = now(), checkin_method = $2, updated_at = now()
       WHERE id = $1
       RETURNING *`,
      [booking.id, effectiveMethod]
    );
    return { booking: update.rows[0], already: false, method: effectiveMethod, distance };
  });

  await auditLog({
    req,
    userId: user.id,
    action: outcome.already ? 'checkin_repeat' : 'checkin_success',
    entityType: 'booking',
    entityId: outcome.booking.id,
    details: {
      method: outcome.method,
      recorded_method: outcome.booking.checkin_method,
      distance_m: outcome.distance === null ? null : Math.round(outcome.distance),
      checked_in_at: outcome.booking.checked_in_at
    }
  });
  return outcome;
}

async function recordFailedAttempt({ req, user, booking, reason, details = {} }) {
  await auditLog({
    req,
    userId: user.id,
    action: 'checkin_failed',
    entityType: 'booking',
    entityId: booking.id,
    details: { reason, ...details }
  });
  try {
    const count = await query(
      `SELECT count(*)::int AS count FROM audit_log
       WHERE user_id = $1 AND action = 'checkin_failed'
         AND created_at > now() - interval '24 hours'`,
      [user.id]
    );
    if (count.rows[0]?.count >= 3) {
      await query(
        `UPDATE users
         SET flagged_for_review = true,
             flagged_reason = COALESCE(flagged_reason, 'Repeated failed check-in attempts'),
             updated_at = now()
         WHERE id = $1 AND flagged_for_review = false`,
        [user.id]
      );
      await notifyAdmins({
        type: 'security_alert',
        eventType: 'security_alert',
        title: 'Repeated check-in failures',
        message: `${user.name} (${user.id_number}) failed check-in three times in 24 hours. Latest reason: ${reason}.`,
        severity: 'warning',
        link: '/admin.html#audit'
      });
    }
  } catch (error) {
    console.error('[checkin] failed to update failed-attempt flag', error.message);
  }
}

export async function autoCheckInWalkUp({ bookingId, req = null }) {
  const result = await withTransaction(async (client) => {
    const updated = await client.query(
      `UPDATE bookings
       SET checked_in_at = now(), checkin_method = 'rotating', updated_at = now()
       WHERE id = $1 AND entry_point = 'room_qr' AND checked_in_at IS NULL
         AND status IN ('pending','confirmed')
       RETURNING *`,
      [bookingId]
    );
    return updated.rows[0] || null;
  });
  if (result) {
    await auditLog({
      req,
      userId: result.user_id,
      action: 'checkin_success',
      entityType: 'booking',
      entityId: result.id,
      details: { method: 'rotating', walk_up: true, checked_in_at: result.checked_in_at }
    });
  }
  return result;
}

export async function releaseNoShows({ now = new Date() } = {}) {
  const settings = await getSettings([
    'no_show_grace_minutes',
    'timetable_no_show_exempt',
    'lecturer_no_show_exempt',
    'lecture_room_no_show_exempt'
  ]);
  const grace = Number(settings.no_show_grace_minutes ?? 15);
  const candidates = await withTransaction(async (client) => {
    const result = await client.query(
      `SELECT b.*, u.role AS booker_role, f.category AS facility_category, f.name AS facility_name,
              m.code AS module_code, m.name AS module_name
       FROM bookings b
       JOIN users u ON u.id = b.user_id
       LEFT JOIN facilities f ON f.id = b.facility_id
       LEFT JOIN modules m ON m.id = b.module_id
       WHERE b.status = 'confirmed'
         AND b.checked_in_at IS NULL
         AND b.released_at IS NULL
         AND b.start_at + ($1::int * interval '1 minute') < $2
         AND b.start_at > $2 - interval '7 days'
         AND b.session_mode IN ('physical','hybrid')
         AND b.entry_point = 'app'
       ORDER BY b.start_at
       LIMIT 100
       FOR UPDATE OF b SKIP LOCKED`,
      [grace, now]
    );
    const released = [];
    for (const booking of result.rows) {
      if (booking.source === 'timetable' && settings.timetable_no_show_exempt !== false) continue;
      if (booking.booker_role === 'lecturer' && settings.lecturer_no_show_exempt === true) continue;
      if (booking.facility_category === 'lecture_room' && settings.lecture_room_no_show_exempt === true) continue;
      const marker = booking.session_mode === 'hybrid' ? 'converted_to_online' : 'released';
      const reason = booking.session_mode === 'hybrid'
        ? 'No check-in within grace period; converted to online'
        : 'No check-in within grace period; room released';
      const update = await client.query(
        `UPDATE bookings
         SET status = CASE WHEN session_mode = 'hybrid' THEN 'confirmed' ELSE 'released' END,
             facility_id = CASE WHEN session_mode = 'hybrid' THEN NULL ELSE facility_id END,
             session_mode = CASE WHEN session_mode = 'hybrid' THEN 'online' ELSE session_mode END,
             released_at = now(),
             release_reason = $2,
             updated_at = now()
         WHERE id = $1
         RETURNING *`,
        [booking.id, reason]
      );
      await client.query(
        `INSERT INTO no_shows (booking_id, user_id, reason)
         VALUES ($1, $2, $3)
         ON CONFLICT (booking_id) DO NOTHING`,
        [booking.id, booking.user_id, reason]
      );
      await client.query(
        `INSERT INTO audit_log (user_id, action, entity_type, entity_id, details)
         VALUES ($1, 'no_show_released', 'booking', $2, $3)`,
        [
          null,
          booking.id,
          JSON.stringify({
            booking_id: booking.id,
            user_id: booking.user_id,
            grace_minutes: grace,
            mode: booking.session_mode,
            marker,
            facility_id: booking.facility_id
          })
        ]
      );
      released.push({ before: booking, after: update.rows[0] });
    }
    return released;
  });

  for (const item of candidates) {
    try {
      if (item.after.session_mode === 'online' && item.before.session_mode === 'hybrid') {
        await notifySessionEvent({
          bookingId: item.after.id,
          event: 'updated',
          changes: { sessionMode: true, roomChanged: true },
          reason: 'The room was released because the booking owner did not check in. The session continues online.'
        });
      } else {
        await notifyBookingOwner(item.after.id, 'released', {
          title: 'Room released after missed check-in',
          message: `Your booking for ${item.before.facility_name || 'the room'} was released because there was no check-in within ${grace} minutes of the start time. A no-show has been recorded.`,
          severity: 'warning'
        });
      }
    } catch (error) {
      console.error('[checkin] no-show notification failed', item.after.id, error.message);
    }
  }
  return { released: candidates.length, bookings: candidates.map((item) => item.after.id) };
}

export async function markNoShowAdmin({ bookingId, userId, reason, req = null }) {
  const settings = await getSettings(['no_show_grace_minutes']);
  const result = await withTransaction(async (client) => {
    const bookingResult = await client.query('SELECT * FROM bookings WHERE id = $1 FOR UPDATE', [bookingId]);
    const booking = bookingResult.rows[0];
    if (!booking) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Booking not found.');
    if (booking.checked_in_at) throw new AppError(409, 'ALREADY_CHECKED_IN', 'This booking has already been checked in.');
    if (booking.released_at) throw new AppError(409, 'ALREADY_RELEASED', 'This booking has already been released.');
    const updated = await client.query(
      `UPDATE bookings
       SET status = CASE WHEN session_mode = 'hybrid' THEN 'confirmed' ELSE 'released' END,
           facility_id = CASE WHEN session_mode = 'hybrid' THEN NULL ELSE facility_id END,
           session_mode = CASE WHEN session_mode = 'hybrid' THEN 'online' ELSE session_mode END,
           released_at = now(), release_reason = $2, updated_at = now()
       WHERE id = $1 RETURNING *`,
      [bookingId, reason || `Administrative no-show (grace ${settings.no_show_grace_minutes} minutes)`]
    );
    await client.query(
      `INSERT INTO no_shows (booking_id, user_id, reason)
       VALUES ($1, $2, $3)
       ON CONFLICT (booking_id) DO NOTHING`,
      [bookingId, userId || booking.user_id, reason || 'Administrative no-show']
    );
    return updated.rows[0];
  });
  await auditLog({
    req,
    action: 'no_show_admin',
    entityType: 'booking',
    entityId: bookingId,
    details: { booking_id: bookingId, user_id: userId || result.user_id, reason }
  });
  try {
    await notifyBookingOwner(bookingId, 'released', {
      title: 'Booking marked as no-show',
      message: reason || 'An administrator marked this booking as a no-show and released the room.',
      severity: 'warning'
    });
  } catch (error) {
    console.error('[checkin] admin no-show notification failed', error.message);
  }
  return result;
}
