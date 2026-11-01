import express from 'express';
import { query } from '../db/pool.js';
import { asyncHandler } from '../lib/errors.js';
import { auditLog } from '../lib/audit.js';
import { kampalaDate } from '../lib/time.js';
import { authenticate } from '../middleware/auth.js';
import { requireAdmin } from '../middleware/roles.js';

const router = express.Router();
router.use(authenticate, requireAdmin);

function isSuper(user) {
  return user.role === 'super_admin';
}

function resolveRange(req) {
  const today = kampalaDate();
  const defaultFrom = kampalaDate(new Date(Date.now() - 29 * 86400000));
  const from = String(req.query.from || defaultFrom);
  const to = String(req.query.to || today);
  if (!/^\d{4}-\d{2}-\d{2}$/.test(from) || !/^\d{4}-\d{2}-\d{2}$/.test(to)) {
    throw new Error('from and to must be YYYY-MM-DD dates');
  }
  if (from > to) throw new Error('from must be on or before to');
  return { from, to };
}

function scope(req, params, conditions, facilityAlias = 'f', moduleAlias = 'm') {
  if (!isSuper(req.user)) {
    params.push(req.user.department_id);
    conditions.push(`COALESCE(${facilityAlias}.department_id, ${moduleAlias}.department_id) = $${params.length}`);
  } else if (req.query.department_id) {
    params.push(req.query.department_id);
    conditions.push(`COALESCE(${facilityAlias}.department_id, ${moduleAlias}.department_id) = $${params.length}`);
  }
}

const RANGE_JOIN = `
  LEFT JOIN facilities f ON f.id = b.facility_id
  LEFT JOIN modules m ON m.id = b.module_id`;

function rangeSql(params, from, to) {
  params.push(from);
  const fromIndex = params.length;
  params.push(to);
  const toIndex = params.length;
  return `b.start_at >= (($${fromIndex}::date)::timestamp AT TIME ZONE 'Africa/Kampala')
      AND b.start_at < ((($${toIndex}::date + 1))::timestamp AT TIME ZONE 'Africa/Kampala')`;
}

router.get(
  '/summary',
  asyncHandler(async (req, res) => {
    const { from, to } = resolveRange(req);
    const params = [];
    const conditions = [];
    const range = rangeSql(params, from, to);
    scope(req, params, conditions);
    const where = [`b.status IN ('pending','confirmed','completed','released')`, range, ...conditions].join(' AND ');
    const summary = await query(
      `SELECT
         count(*)::int AS bookings,
         count(*) FILTER (WHERE b.module_id IS NOT NULL)::int AS sessions,
         count(*) FILTER (WHERE b.module_id IS NULL)::int AS ad_hoc_bookings,
         count(*) FILTER (WHERE b.status = 'pending')::int AS pending,
         count(*) FILTER (WHERE b.status = 'confirmed')::int AS confirmed,
         count(*) FILTER (WHERE b.status = 'completed')::int AS completed,
         count(*) FILTER (WHERE b.status = 'released')::int AS released,
         count(*) FILTER (WHERE b.checked_in_at IS NOT NULL)::int AS checked_in,
         count(*) FILTER (WHERE b.session_mode = 'physical')::int AS physical,
         count(*) FILTER (WHERE b.session_mode = 'online')::int AS online,
         count(*) FILTER (WHERE b.session_mode = 'hybrid')::int AS hybrid,
         coalesce(sum(extract(epoch FROM (b.end_at - b.start_at)) / 3600), 0)::numeric(10,1) AS booked_hours,
         count(DISTINCT b.user_id)::int AS unique_bookers,
         count(DISTINCT b.facility_id)::int AS rooms_used
       FROM bookings b ${RANGE_JOIN}
       WHERE ${where}`,
      params
    );
    const noShows = await query(
      `SELECT count(*)::int AS no_shows,
              count(DISTINCT n.user_id)::int AS users
       FROM no_shows n JOIN bookings b ON b.id = n.booking_id
       ${RANGE_JOIN}
       WHERE n.marked_at >= (($1::date)::timestamp AT TIME ZONE 'Africa/Kampala')
         AND n.marked_at < ((($2::date + 1))::timestamp AT TIME ZONE 'Africa/Kampala')
         ${conditions.map((condition) => `AND ${condition}`).join(' ')}`,
      [from, to, ...params.slice(2)]
    );
    const checkinRate = summary.rows[0].bookings
      ? Math.round((summary.rows[0].checked_in / summary.rows[0].bookings) * 1000) / 10
      : 0;
    res.json({ range: { from, to }, summary: { ...summary.rows[0], checkin_rate_percent: checkinRate }, no_shows: noShows.rows[0] });
  })
);

router.get(
  '/by-day',
  asyncHandler(async (req, res) => {
    const { from, to } = resolveRange(req);
    const params = [];
    const conditions = [];
    const range = rangeSql(params, from, to);
    scope(req, params, conditions);
    const result = await query(
      `SELECT (b.start_at AT TIME ZONE 'Africa/Kampala')::date AS day,
              count(*)::int AS bookings,
              count(*) FILTER (WHERE b.checked_in_at IS NOT NULL)::int AS checked_in,
              coalesce(sum(extract(epoch FROM (b.end_at - b.start_at)) / 3600), 0)::numeric(10,1) AS hours
       FROM bookings b ${RANGE_JOIN}
       WHERE b.status IN ('pending','confirmed','completed','released') AND ${range}
         ${conditions.map((condition) => `AND ${condition}`).join(' ')}
       GROUP BY day ORDER BY day`,
      params
    );
    res.json({ range: { from, to }, days: result.rows });
  })
);

router.get(
  '/by-facility',
  asyncHandler(async (req, res) => {
    const { from, to } = resolveRange(req);
    const params = [];
    const conditions = [];
    const range = rangeSql(params, from, to);
    scope(req, params, conditions);
    const result = await query(
      `SELECT f.id, f.name, f.building, f.floor, f.room_number, f.category, f.capacity,
              d.code AS department_code,
              count(b.id)::int AS bookings,
              count(b.id) FILTER (WHERE b.checked_in_at IS NOT NULL)::int AS checked_in,
              coalesce(sum(extract(epoch FROM (b.end_at - b.start_at)) / 3600), 0)::numeric(10,1) AS booked_hours
       FROM facilities f
       JOIN departments d ON d.id = f.department_id
       LEFT JOIN bookings b ON b.facility_id = f.id
         AND b.status IN ('pending','confirmed','completed','released') AND ${range}
       WHERE 1=1 ${!isSuper(req.user) ? `AND f.department_id = $${params.push(req.user.department_id)}` : ''}
       GROUP BY f.id, d.code
       ORDER BY booked_hours DESC, f.name`,
      params
    );
    res.json({ range: { from, to }, facilities: result.rows });
  })
);

router.get(
  '/by-department',
  asyncHandler(async (req, res) => {
    const { from, to } = resolveRange(req);
    const params = [];
    const conditions = [];
    const range = rangeSql(params, from, to);
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      conditions.push(`d.id = $${params.length}`);
    } else if (req.query.department_id) {
      params.push(req.query.department_id);
      conditions.push(`d.id = $${params.length}`);
    }
    const result = await query(
      `SELECT d.id, d.code, d.name,
              count(b.id)::int AS bookings,
              coalesce(sum(extract(epoch FROM (b.end_at - b.start_at)) / 3600), 0)::numeric(10,1) AS booked_hours
       FROM departments d
       LEFT JOIN facilities f ON f.department_id = d.id
       LEFT JOIN bookings b ON b.facility_id = f.id
         AND b.status IN ('pending','confirmed','completed','released') AND ${range}
       WHERE 1=1 ${conditions.map((condition) => `AND ${condition}`).join(' ')}
       GROUP BY d.id ORDER BY bookings DESC, d.name`,
      params
    );
    res.json({ range: { from, to }, departments: result.rows });
  })
);

router.get(
  '/no-shows',
  asyncHandler(async (req, res) => {
    const { from, to } = resolveRange(req);
    const params = [from, to];
    let scopeSql = '';
    if (!isSuper(req.user)) {
      params.push(req.user.department_id);
      scopeSql = `AND u.department_id = $${params.length}`;
    }
    const result = await query(
      `SELECT u.id, u.id_number, u.name, u.role, d.code AS department_code,
              count(n.id)::int AS no_show_count,
              max(n.marked_at) AS last_no_show_at
       FROM no_shows n
       JOIN users u ON u.id = n.user_id
       LEFT JOIN departments d ON d.id = u.department_id
       WHERE n.marked_at >= (($1::date)::timestamp AT TIME ZONE 'Africa/Kampala')
         AND n.marked_at < ((($2::date + 1))::timestamp AT TIME ZONE 'Africa/Kampala')
         ${scopeSql}
       GROUP BY u.id, d.code
       ORDER BY no_show_count DESC, last_no_show_at DESC
       LIMIT 500`,
      params
    );
    res.json({ range: { from, to }, users: result.rows });
  })
);

router.get(
  '/attendance',
  asyncHandler(async (req, res) => {
    const { from, to } = resolveRange(req);
    const params = [];
    const conditions = [];
    const range = rangeSql(params, from, to);
    scope(req, params, conditions);
    const result = await query(
      `SELECT b.id, b.session_id, m.code AS module_code, m.name AS module_name,
              f.name AS facility_name, b.session_mode, b.start_at, b.end_at,
              b.checked_in_at, b.checkin_method, b.status,
              (SELECT count(*)::int FROM session_joins j WHERE j.booking_id = b.id) AS joins,
              (SELECT count(*)::int FROM enrolments e
                 JOIN semesters s ON s.id = e.semester_id
                 WHERE e.module_id = b.module_id AND s.is_current = true) AS enrolled
       FROM bookings b ${RANGE_JOIN}
       WHERE b.module_id IS NOT NULL
         AND b.status IN ('pending','confirmed','completed','released')
         AND ${range}
         ${conditions.map((condition) => `AND ${condition}`).join(' ')}
       ORDER BY b.start_at DESC
       LIMIT 1000`,
      params
    );
    res.json({ range: { from, to }, sessions: result.rows });
  })
);

router.get(
  '/bookings.csv',
  asyncHandler(async (req, res) => {
    const { from, to } = resolveRange(req);
    const params = [];
    const conditions = [];
    const range = rangeSql(params, from, to);
    scope(req, params, conditions);
    const result = await query(
      `SELECT b.id, b.session_id, b.start_at, b.end_at, b.status, b.session_mode,
              b.entry_point, b.source, f.name AS facility, f.building, f.room_number,
              m.code AS module_code, m.name AS module_name, u.id_number AS booked_by_id,
              u.name AS booked_by, l.name AS lecturer, b.checkin_method, b.checked_in_at,
              b.release_reason, b.displacement_reason
       FROM bookings b ${RANGE_JOIN}
       LEFT JOIN users u ON u.id = b.user_id
       LEFT JOIN users l ON l.id = b.lecturer_id
       WHERE ${range}
         ${conditions.map((condition) => `AND ${condition}`).join(' ')}
       ORDER BY b.start_at DESC LIMIT 5000`,
      params
    );
    const header = [
      'booking_id', 'session_id', 'start_at_utc', 'end_at_utc', 'status', 'session_mode',
      'entry_point', 'source', 'facility', 'building', 'room_number', 'module_code', 'module_name',
      'booked_by_id', 'booked_by', 'lecturer', 'checkin_method', 'checked_in_at', 'release_reason', 'displacement_reason'
    ];
    const escapeCsv = (value) => {
      const text = value === null || value === undefined ? '' : String(value);
      return /[",\n\r]/.test(text) ? `"${text.replace(/"/g, '""')}"` : text;
    };
    const lines = [header.join(',')];
    for (const row of result.rows) {
      lines.push(
        [
          row.id, row.session_id, row.start_at?.toISOString(), row.end_at?.toISOString(), row.status,
          row.session_mode, row.entry_point, row.source, row.facility, row.building, row.room_number,
          row.module_code, row.module_name, row.booked_by_id, row.booked_by, row.lecturer,
          row.checkin_method, row.checked_in_at?.toISOString(), row.release_reason, row.displacement_reason
        ].map(escapeCsv).join(',')
      );
    }
    await auditLog({ req, action: 'report_bookings_exported', details: { from, to, rows: result.rowCount } });
    res.setHeader('Content-Type', 'text/csv; charset=utf-8');
    res.setHeader('Content-Disposition', `attachment; filename="bookings-${from}-to-${to}.csv"`);
    res.send(lines.join('\n'));
  })
);

export default router;
