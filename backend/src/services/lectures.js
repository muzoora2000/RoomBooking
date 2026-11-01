import { query, withTransaction } from '../db/pool.js';
import { AppError } from '../lib/errors.js';
import { auditLog } from '../lib/audit.js';
import { addHours, formatKampala, formatKampalaRange, durationMinutes, kampalaDate } from '../lib/time.js';
import { getCurrentSemester } from './studyMode.js';
import { getSettings } from './settings.js';
import { bookingToApi, getBookingRow } from './booking.js';
import { sessionAudienceSummary } from './sessions.js';

const JOIN_OPEN_MINUTES = 15;
const ADMIN_ROLES = new Set(['department_admin', 'super_admin']);

function viewerDisplay(row, viewerMode) {
  if (row.session_mode === 'online') return { show_room: false, show_join: true, label: 'Join online' };
  if (row.session_mode === 'physical') return { show_room: true, show_join: false, label: 'Go to room' };
  if (viewerMode === 'online') return { show_room: false, show_join: true, label: 'Join online' };
  return { show_room: true, show_join: true, label: 'Go to room or join online' };
}

function joinWindow(row, now = new Date()) {
  const opensAt = new Date(new Date(row.start_at).getTime() - JOIN_OPEN_MINUTES * 60_000);
  const closesAt = new Date(row.end_at);
  return { opensAt, closesAt, available: now >= opensAt && now <= closesAt };
}

export async function listMyLectures({ user, from = null, to = null, client = null }) {
  const db = client || { query };
  const semester = await getCurrentSemester(db);
  if (!semester) throw new AppError(409, 'NO_SEMESTER', 'No current semester is configured.');
  const lower = from ? new Date(from) : addHours(new Date(), -2);
  const upper = to ? new Date(to) : new Date(Date.now() + 35 * 24 * 60 * 60 * 1000);
  if (Number.isNaN(lower.getTime()) || Number.isNaN(upper.getTime())) {
    throw new AppError(400, 'INVALID_RANGE', 'Invalid lecture date range.');
  }
  const result = await db.query(
    `SELECT b.id,
            COALESCE(e.delivery_mode_override, u.study_mode) AS viewer_mode,
            (e.id IS NOT NULL) AS is_enrolled,
            EXISTS (
              SELECT 1 FROM session_joins sj
              WHERE sj.booking_id = b.id AND sj.user_id = $1
            ) AS joined
     FROM bookings b
     JOIN users u ON u.id = $1
     LEFT JOIN enrolments e ON e.module_id = b.module_id
       AND e.semester_id = $2 AND e.user_id = $1
     WHERE b.module_id IS NOT NULL
       AND b.status IN ('confirmed','pending')
       AND (b.user_id = $1 OR b.lecturer_id = $1 OR e.id IS NOT NULL)
       AND b.start_at >= $3 AND b.start_at < $4
     ORDER BY b.start_at
     LIMIT 500`,
    [user.id, semester.id, lower, upper]
  );
  const lectures = [];
  for (const entry of result.rows) {
    const row = await getBookingRow(db, entry.id);
    if (!row) continue;
    if (row.session_mode === 'physical' && entry.viewer_mode === 'online' && !entry.is_enrolled && row.user_id !== user.id && row.lecturer_id !== user.id) {
      continue;
    }
    const display = viewerDisplay(row, entry.viewer_mode);
    const window = joinWindow(row);
    const api = bookingToApi(row, user, {
      includeOnlineLink: ['online', 'hybrid'].includes(row.session_mode) && Boolean(entry.is_enrolled || row.user_id === user.id || row.lecturer_id === user.id)
    });
    lectures.push({
      ...api,
      viewer_mode: entry.viewer_mode,
      is_enrolled: Boolean(entry.is_enrolled),
      joined: Boolean(entry.joined),
      show_room: display.show_room && Boolean(row.facility_id),
      show_join: display.show_join && ['online', 'hybrid'].includes(row.session_mode),
      action_label: display.label,
      join_available: display.show_join && ['online', 'hybrid'].includes(row.session_mode) && window.available,
      join_opens_at: window.opensAt,
      join_closes_at: window.closesAt,
      room_url: row.facility_id ? `/room.html?id=${row.facility_id}` : null,
      join_url: `/lectures.html?join=${row.id}`,
      time_text: formatKampalaRange(row.start_at, row.end_at),
      day: kampalaDate(row.start_at),
      duration_minutes: durationMinutes(row.start_at, row.end_at)
    });
  }
  return {
    semester: { id: semester.id, name: semester.name, start_date: semester.start_date, end_date: semester.end_date },
    from: lower,
    to: upper,
    lectures
  };
}

export async function assertLectureAudience({ row, user, client = null }) {
  const db = client || { query };
  if (!row) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Session not found.');
  if (ADMIN_ROLES.has(user.role)) return { audience: 'admin', viewer_mode: user.study_mode };
  if (row.user_id === user.id || row.lecturer_id === user.id) {
    return { audience: 'staff', viewer_mode: user.study_mode };
  }
  if (!row.module_id) {
    throw new AppError(403, 'NOT_ENROLLED', 'You are not part of this session.');
  }
  const semester = await getCurrentSemester(db);
  if (!semester) throw new AppError(409, 'NO_SEMESTER', 'No current semester is configured.');
  const enrolment = await db.query(
    `SELECT COALESCE(e.delivery_mode_override, u.study_mode) AS viewer_mode
     FROM enrolments e JOIN users u ON u.id = e.user_id
     WHERE e.user_id = $1 AND e.module_id = $2 AND e.semester_id = $3`,
    [user.id, row.module_id, semester.id]
  );
  if (!enrolment.rowCount) {
    throw new AppError(403, 'NOT_ENROLLED', 'You are not enrolled in this module for the current semester.');
  }
  return { audience: 'student', viewer_mode: enrolment.rows[0].viewer_mode };
}

export async function joinLecture({ bookingId, user, req = null }) {
  const settings = await getSettings(['app_name']);
  const outcome = await withTransaction(async (client) => {
    const row = await getBookingRow(client, bookingId);
    if (!row) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Session not found.');
    if (row.status !== 'confirmed') {
      throw new AppError(409, 'SESSION_NOT_ACTIVE', `This session is ${row.status} and cannot be joined.`);
    }
    if (!['online', 'hybrid'].includes(row.session_mode) || !row.online_link) {
      throw new AppError(409, 'NOT_ONLINE_SESSION', 'This session has no online meeting link.');
    }
    const access = await assertLectureAudience({ row, user, client });
    const window = joinWindow(row);
    if (!window.available) {
      if (new Date() < window.opensAt) {
        throw new AppError(409, 'JOIN_NOT_OPEN', `The join link opens at ${formatKampala(window.opensAt)} (15 minutes before the session).`, {
          opens_at: window.opensAt
        });
      }
      throw new AppError(409, 'JOIN_CLOSED', 'This session has ended and can no longer be joined.', {
        closed_at: window.closesAt
      });
    }
    await client.query(
      `INSERT INTO session_joins (booking_id, user_id, clicked_at)
       VALUES ($1, $2, now())
       ON CONFLICT (booking_id, user_id) DO UPDATE SET clicked_at = now()`,
      [bookingId, user.id]
    );
    return { row, access };
  });
  await auditLog({
    req,
    userId: user.id,
    action: 'session_join',
    entityType: 'booking',
    entityId: bookingId,
    details: {
      audience: outcome.access.audience,
      viewer_mode: outcome.access.viewer_mode,
      session_mode: outcome.row.session_mode
    }
  });
  return {
    app_name: settings.app_name,
    booking_id: outcome.row.id,
    session_id: outcome.row.session_id,
    module: outcome.row.module_id
      ? { code: outcome.row.module_code, name: outcome.row.module_name }
      : null,
    session_mode: outcome.row.session_mode,
    online_platform: outcome.row.online_platform,
    online_link: outcome.row.online_link,
    meeting_passcode: outcome.row.meeting_passcode || null,
    time_text: formatKampalaRange(outcome.row.start_at, outcome.row.end_at),
    audience: outcome.access.audience
  };
}

export async function getLectureDetail({ bookingId, user }) {
  const row = await getBookingRow({ query }, bookingId);
  if (!row) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Session not found.');
  const access = await assertLectureAudience({ row, user });
  const display = viewerDisplay(row, access.viewer_mode);
  const window = joinWindow(row);
  const api = bookingToApi(row, user, {
    includeOnlineLink: ['online', 'hybrid'].includes(row.session_mode)
  });
  return {
    ...api,
    viewer_mode: access.viewer_mode,
    audience: access.audience,
    show_room: display.show_room && Boolean(row.facility_id),
    show_join: display.show_join && ['online', 'hybrid'].includes(row.session_mode),
    join_available: display.show_join && window.available,
    join_opens_at: window.opensAt,
    join_closes_at: window.closesAt,
    room_url: row.facility_id ? `/room.html?id=${row.facility_id}` : null,
    audience_summary: ['staff', 'admin'].includes(access.audience)
      ? await sessionAudienceSummary(bookingId)
      : null
  };
}

export async function listLectureRoster({ bookingId, user }) {
  const row = await getBookingRow({ query }, bookingId);
  if (!row) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Session not found.');
  await assertLectureAudience({ row, user });
  if (row.user_id !== user.id && row.lecturer_id !== user.id && !ADMIN_ROLES.has(user.role)) {
    throw new AppError(403, 'ROSTER_FORBIDDEN', 'Only the session owner, lecturer, or an administrator can view the roster.');
  }
  if (!row.module_id) return { session: bookingToApi(row, user), roster: [] };
  const semester = await getCurrentSemester();
  if (!semester) throw new AppError(409, 'NO_SEMESTER', 'No current semester is configured.');
  const roster = await query(
    `SELECT u.id, u.name, u.id_number, u.email, u.role, u.study_mode,
            COALESCE(e.delivery_mode_override, u.study_mode) AS effective_mode,
            sj.clicked_at
     FROM enrolments e
     JOIN users u ON u.id = e.user_id
     LEFT JOIN session_joins sj ON sj.booking_id = $3 AND sj.user_id = u.id
     WHERE e.module_id = $1 AND e.semester_id = $2 AND u.is_active = true
     ORDER BY u.name`,
    [row.module_id, semester.id, bookingId]
  );
  return {
    session: bookingToApi(row, user),
    audience_summary: await sessionAudienceSummary(bookingId),
    roster: roster.rows.map((entry) => ({
      ...entry,
      joined_at: entry.clicked_at
    }))
  };
}
