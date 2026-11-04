import { getSettings } from './settings.js';
import { kampalaDayBounds, kampalaWeekBounds, durationMinutes, kampalaDate } from '../lib/time.js';
import { AppError } from '../lib/errors.js';

const EXEMPT_ROLES = new Set(['lecturer', 'department_admin', 'super_admin']);

function hours(value) {
  return Math.round((Number(value) || 0) * 100) / 100;
}

export async function assertFairness({
  client,
  user,
  startAt,
  endAt,
  entryPoint = 'app',
  source = 'manual',
  facilityId = null,
  settings = null,
  excludeBookingId = null
}) {
  if (!facilityId) return;
  if (source !== 'manual') return;
  if (EXEMPT_ROLES.has(user.role)) return;
  const config = settings || (await getSettings());
  const db = client || { query };
  if (!db.query) throw new AppError(500, 'DB_CLIENT_MISSING', 'Internal error: fairness check missing database client.');
  const now = new Date();
  const duration = durationMinutes(startAt, endAt);
  if (duration <= 0) throw new AppError(400, 'INVALID_DURATION', 'End time must be after start time.');
  if (duration > Number(config.max_booking_duration_minutes)) {
    throw new AppError(400, 'MAX_DURATION', `The maximum booking duration is ${config.max_booking_duration_minutes} minutes.`);
  }
  if (entryPoint !== 'room_qr') {
    if (new Date(startAt).getTime() < now.getTime() + Number(config.min_notice_minutes) * 60_000) {
      throw new AppError(
        400,
        'MIN_NOTICE',
        `Bookings need at least ${config.min_notice_minutes} minutes notice unless made by scanning the room QR at the room.`
      );
    }
    const maxAdvanceMs = Number(config.max_advance_booking_days) * 24 * 60 * 60 * 1000;
    if (new Date(startAt).getTime() - now.getTime() > maxAdvanceMs) {
      throw new AppError(400, 'MAX_ADVANCE', `You can book at most ${config.max_advance_booking_days} days ahead.`);
    }
  }
  const lookback = Number(config.no_show_lookback_days);
  const suspension = await db.query(
    `SELECT count(*)::int AS count, max(marked_at) AS latest
     FROM no_shows WHERE user_id = $1 AND marked_at > now() - ($2 || ' days')::interval`,
    [user.id, String(lookback)]
  );
  const noShow = suspension.rows[0];
  if (noShow.count >= Number(config.no_show_suspension_threshold) && noShow.latest) {
    const until = new Date(new Date(noShow.latest).getTime() + Number(config.no_show_suspension_days) * 24 * 60 * 60 * 1000);
    if (until > now) {
      throw new AppError(
        403,
        'BOOKING_SUSPENDED',
        `Room booking is suspended until ${until.toISOString()} because you have ${noShow.count} no-shows in the last ${lookback} days.`,
        { no_shows: noShow.count, suspended_until: until.toISOString() }
      );
    }
  }
  const day = kampalaDayBounds(kampalaDate(startAt));
  const week = kampalaWeekBounds(startAt);
  const usage = await db.query(
    `SELECT
       COALESCE(SUM(EXTRACT(EPOCH FROM (end_at - start_at)) / 3600) FILTER (WHERE start_at < $4 AND end_at > $3),0)::float AS day_hours,
       COALESCE(SUM(EXTRACT(EPOCH FROM (end_at - start_at)) / 3600) FILTER (WHERE start_at < $6 AND end_at > $5),0)::float AS week_hours
     FROM bookings
     WHERE user_id = $1 AND facility_id IS NOT NULL
       AND status IN ('pending','confirmed')
       AND start_at < $6 AND end_at > $3
       AND ($7::uuid IS NULL OR id <> $7)`,
    [user.id, day.start, day.end, day.start, week.start, week.end, excludeBookingId]
  );
  const rows = usage.rows[0] || { day_hours: 0, week_hours: 0 };
  const newHours = duration / 60;
  if (hours(rows.day_hours) + newHours > Number(config.max_booking_hours_per_day) + 0.0001) {
    throw new AppError(
      403,
      'DAILY_LIMIT',
      `This booking would exceed the daily limit of ${config.max_booking_hours_per_day} hours. You already have ${hours(
        rows.day_hours
      )} hours on that day.`,
      { limit_hours: config.max_booking_hours_per_day, used_hours: hours(rows.day_hours) }
    );
  }
  if (hours(rows.week_hours) + newHours > Number(config.max_booking_hours_per_week) + 0.0001) {
    throw new AppError(
      403,
      'WEEKLY_LIMIT',
      `This booking would exceed the weekly limit of ${config.max_booking_hours_per_week} hours. You already have ${hours(
        rows.week_hours
      )} hours that week.`,
      { limit_hours: config.max_booking_hours_per_week, used_hours: hours(rows.week_hours) }
    );
  }
}
