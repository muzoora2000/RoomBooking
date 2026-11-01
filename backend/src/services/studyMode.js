import { query } from '../db/pool.js';
import { notFound } from '../lib/errors.js';

export function resolveEffectiveMode(userStudyMode, override = null) {
  return override || userStudyMode || 'physical';
}

export async function getCurrentSemester(client = null) {
  const db = client || { query };
  const result = await db.query(`SELECT * FROM semesters WHERE is_current = true ORDER BY start_date DESC LIMIT 1`);
  return result.rows[0] || null;
}

export async function getSemesterForDate(date, client = null, timezone = 'Africa/Kampala') {
  const db = client || { query };
  const result = await db.query(
    `SELECT * FROM semesters
     WHERE start_date <= ($1::timestamptz AT TIME ZONE $2)::date
       AND end_date >= ($1::timestamptz AT TIME ZONE $2)::date
     ORDER BY is_current DESC, start_date DESC LIMIT 1`,
    [date, timezone]
  );
  return result.rows[0] || null;
}

export async function getModuleSemester(moduleId, date, client = null, timezone = 'Africa/Kampala') {
  const semester = await getSemesterForDate(date, client, timezone);
  if (!semester) return null;
  return semester;
}

export async function getStudyModeCounts(moduleId, semesterId, client = null) {
  const db = client || { query };
  const result = await db.query(
    `SELECT
       count(*)::int AS total,
       count(*) FILTER (WHERE effective_mode = 'physical')::int AS physical,
       count(*) FILTER (WHERE effective_mode = 'hybrid')::int AS hybrid,
       count(*) FILTER (WHERE effective_mode = 'online')::int AS online
     FROM (
       SELECT COALESCE(e.delivery_mode_override, u.study_mode) AS effective_mode
       FROM enrolments e JOIN users u ON u.id = e.user_id
       WHERE e.module_id = $1 AND e.semester_id = $2 AND u.is_active = true
     ) counts`,
    [moduleId, semesterId]
  );
  const row = result.rows[0] || { total: 0, physical: 0, hybrid: 0, online: 0 };
  return {
    ...row,
    required_capacity: row.physical + row.hybrid
  };
}

export async function capacityPreview(moduleId, semesterId = null, client = null, timezone = 'Africa/Kampala') {
  const db = client || { query };
  const moduleResult = await db.query(
    `SELECT m.id, m.code, m.name, m.department_id, m.lecturer_id FROM modules m WHERE m.id = $1`,
    [moduleId]
  );
  const module = moduleResult.rows[0];
  if (!module) throw notFound('Module not found');
  const semester = semesterId
    ? (await db.query(`SELECT * FROM semesters WHERE id = $1`, [semesterId])).rows[0]
    : await getCurrentSemester(db);
  if (!semester) throw notFound('No current semester configured. Ask an administrator to set one.');
  const counts = await getStudyModeCounts(moduleId, semester.id, db);
  return {
    module,
    semester,
    ...counts,
    explanation: `${counts.total} enrolled: ${counts.physical} physical, ${counts.hybrid} hybrid, ${counts.online} online. Room needs capacity of at least ${counts.required_capacity}.`
  };
}

export async function getEnrolmentEffectiveMode(userId, moduleId, semesterId, client = null) {
  const db = client || { query };
  const result = await db.query(
    `SELECT u.study_mode, e.delivery_mode_override,
            COALESCE(e.delivery_mode_override, u.study_mode) AS effective_mode
     FROM enrolments e JOIN users u ON u.id = e.user_id
     WHERE e.user_id = $1 AND e.module_id = $2 AND e.semester_id = $3`,
    [userId, moduleId, semesterId]
  );
  return result.rows[0] || null;
}
