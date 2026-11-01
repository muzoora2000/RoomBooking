import { query } from '../db/pool.js';
import { AppError } from '../lib/errors.js';
import { getSettings } from './settings.js';
import { capacityPreview, getCurrentSemester } from './studyMode.js';

const SCHEDULING_ROLES = new Set(['lecturer', 'class_rep', 'deputy_rep', 'department_admin', 'super_admin']);
const ADMIN_ROLES = new Set(['department_admin', 'super_admin']);

export function canSchedule(user) {
  return Boolean(user && SCHEDULING_ROLES.has(user.role));
}

export async function assertCanSchedule(user) {
  if (!canSchedule(user)) {
    throw new AppError(403, 'SCHEDULING_FORBIDDEN', 'Only lecturers, class representatives, deputy representatives, and administrators can schedule sessions.');
  }
}

export async function getAuthorisedModules(user, { semesterId = null, client = null } = {}) {
  const db = client || { query };
  const semester = semesterId
    ? (await db.query('SELECT * FROM semesters WHERE id = $1', [semesterId])).rows[0]
    : await getCurrentSemester(db);
  if (!semester) return { semester: null, modules: [] };
  if (user.role === 'super_admin') {
    const result = await db.query(
      `SELECT m.*, d.code AS department_code, d.name AS department_name,
              u.name AS lecturer_name, 'super_admin'::text AS via
       FROM modules m
       JOIN departments d ON d.id = m.department_id
       LEFT JOIN users u ON u.id = m.lecturer_id
       ORDER BY m.code`
    );
    return { semester, modules: result.rows };
  }
  if (user.role === 'department_admin') {
    const result = await db.query(
      `SELECT m.*, d.code AS department_code, d.name AS department_name,
              u.name AS lecturer_name, 'department_admin'::text AS via
       FROM modules m
       JOIN departments d ON d.id = m.department_id
       LEFT JOIN users u ON u.id = m.lecturer_id
       WHERE m.department_id = $1
       ORDER BY m.code`,
      [user.department_id]
    );
    return { semester, modules: result.rows };
  }
  if (user.role === 'lecturer') {
    const result = await db.query(
      `SELECT DISTINCT m.*, d.code AS department_code, d.name AS department_name,
              u.name AS lecturer_name, 'lecturer'::text AS via
       FROM modules m
       JOIN departments d ON d.id = m.department_id
       LEFT JOIN users u ON u.id = m.lecturer_id
       LEFT JOIN delegations del ON del.module_id = m.id
         AND del.from_user_id = $1 AND del.revoked_at IS NULL
         AND now() BETWEEN del.starts_at AND del.ends_at
       WHERE m.lecturer_id = $1 OR del.to_user_id = $1
       ORDER BY m.code`,
      [user.id]
    );
    return { semester, modules: result.rows };
  }
  const repResult = await db.query(
    `SELECT class_id, is_deputy FROM class_reps
     WHERE user_id = $1 AND is_active = true
       AND (semester_id = $2 OR $2::uuid IS NULL)`,
    [user.id, semester.id]
  );
  if (!repResult.rowCount) return { semester, modules: [] };
  const classIds = [...new Set(repResult.rows.map((row) => row.class_id))];
  const result = await db.query(
    `SELECT DISTINCT m.*, d.code AS department_code, d.name AS department_name,
            u.name AS lecturer_name,
            'class_rep'::text AS via, cm.class_id, c.name AS class_name, c.code AS class_code
     FROM class_modules cm
     JOIN modules m ON m.id = cm.module_id
     JOIN classes c ON c.id = cm.class_id
     JOIN departments d ON d.id = m.department_id
     LEFT JOIN users u ON u.id = m.lecturer_id
     LEFT JOIN delegations del ON del.module_id = m.id
       AND del.from_user_id = m.lecturer_id AND del.to_user_id = $1
       AND del.revoked_at IS NULL AND now() BETWEEN del.starts_at AND del.ends_at
     WHERE cm.class_id = ANY($2::uuid[]) AND cm.semester_id = $3
       AND (m.lecturer_id = $1 OR del.id IS NOT NULL OR m.lecturer_id IS NOT NULL)
     ORDER BY m.code`,
    [user.id, classIds, semester.id]
  );
  const delegated = await db.query(
    `SELECT DISTINCT m.*, d.code AS department_code, d.name AS department_name,
            u.name AS lecturer_name, 'delegation'::text AS via
     FROM delegations del
     JOIN modules m ON m.id = del.module_id
     JOIN departments d ON d.id = m.department_id
     LEFT JOIN users u ON u.id = m.lecturer_id
     WHERE del.to_user_id = $1 AND del.revoked_at IS NULL
       AND now() BETWEEN del.starts_at AND del.ends_at
     ORDER BY m.code`,
    [user.id]
  );
  const map = new Map();
  for (const module of [...result.rows, ...delegated.rows]) map.set(module.id, module);
  return { semester, modules: [...map.values()] };
}

export async function assertCanScheduleModule(user, moduleId, { classId = null, at = new Date(), client = null } = {}) {
  await assertCanSchedule(user);
  const db = client || { query };
  const moduleResult = await db.query(
    `SELECT m.*, d.name AS department_name FROM modules m
     JOIN departments d ON d.id = m.department_id WHERE m.id = $1`,
    [moduleId]
  );
  const module = moduleResult.rows[0];
  if (!module) throw new AppError(404, 'MODULE_NOT_FOUND', 'Module not found.');
  if (user.role === 'super_admin') return { module, via: 'super_admin', classId };
  if (user.role === 'department_admin') {
    if (module.department_id !== user.department_id) {
      throw new AppError(403, 'MODULE_OUTSIDE_DEPARTMENT', 'You can only schedule modules in your department.');
    }
    return { module, via: 'department_admin', classId };
  }
  if (module.lecturer_id === user.id) return { module, via: 'lecturer', classId };
  const delegation = await db.query(
    `SELECT 1 FROM delegations
     WHERE module_id = $1 AND to_user_id = $2 AND revoked_at IS NULL
       AND $3 BETWEEN starts_at AND ends_at LIMIT 1`,
    [moduleId, user.id, at]
  );
  if (delegation.rowCount) return { module, via: 'delegation', classId };
  if (user.role === 'class_rep' || user.role === 'deputy_rep') {
    const semester = await getCurrentSemester(db);
    if (!semester) throw new AppError(409, 'NO_SEMESTER', 'No current semester is configured.');
    const rep = await db.query(
      `SELECT class_id FROM class_reps
       WHERE user_id = $1 AND is_active = true AND semester_id = $2
         AND ($3::uuid IS NULL OR class_id = $3)`,
      [user.id, semester.id, classId || user.class_id]
    );
    if (!rep.rowCount) {
      throw new AppError(403, 'NOT_CLASS_REP', 'You are not an active class representative for this class.');
    }
    const classIds = rep.rows.map((row) => row.class_id);
    const link = await db.query(
      `SELECT 1 FROM class_modules
       WHERE module_id = $1 AND semester_id = $2 AND class_id = ANY($3::uuid[]) LIMIT 1`,
      [moduleId, semester.id, classIds]
    );
    if (!link.rowCount) {
      throw new AppError(403, 'MODULE_NOT_IN_CLASS', 'That module is not registered for your class this semester.');
    }
    return { module, via: 'class_rep', classId: classId || classIds[0], semester };
  }
  throw new AppError(403, 'MODULE_FORBIDDEN', 'You are not authorised to schedule this module.');
}

export async function getModuleClasses(moduleId, { semesterId = null, client = null } = {}) {
  const db = client || { query };
  const semester = semesterId
    ? (await db.query('SELECT * FROM semesters WHERE id = $1', [semesterId])).rows[0]
    : await getCurrentSemester(db);
  if (!semester) return [];
  const result = await db.query(
    `SELECT c.id, c.code, c.name, c.year_of_study FROM class_modules cm
     JOIN classes c ON c.id = cm.class_id
     WHERE cm.module_id = $1 AND cm.semester_id = $2
     ORDER BY c.code`,
    [moduleId, semester.id]
  );
  return result.rows;
}

export function normaliseMeetingLink(rawLink) {
  const value = String(rawLink || '').trim();
  let url;
  try {
    url = new URL(value);
  } catch {
    throw new AppError(400, 'INVALID_MEETING_LINK', 'Enter a valid https meeting link.');
  }
  if (url.protocol !== 'https:') {
    throw new AppError(400, 'INVALID_MEETING_LINK', 'Meeting links must start with https://.');
  }
  if (url.username || url.password) {
    throw new AppError(400, 'INVALID_MEETING_LINK', 'Meeting links must not contain embedded credentials.');
  }
  return url;
}

export async function assertOnlineLink(rawLink) {
  const settings = await getSettings(['allowed_meeting_domains']);
  const url = normaliseMeetingLink(rawLink);
  const allowed = Array.isArray(settings.allowed_meeting_domains) ? settings.allowed_meeting_domains : [];
  const hostname = url.hostname.toLowerCase();
  const domainOk = allowed.some((domain) => {
    const normalised = String(domain).toLowerCase().replace(/^\./, '');
    return hostname === normalised || hostname.endsWith(`.${normalised}`);
  });
  if (!domainOk) {
    throw new AppError(400, 'MEETING_DOMAIN_NOT_ALLOWED', `Meeting links must use an approved platform: ${allowed.join(', ')}.`, {
      allowed_domains: allowed
    });
  }
  return url.toString();
}

const PLATFORMS = new Set(['zoom', 'google_meet', 'teams', 'other']);

export function validateSessionMode({ sessionMode, facility, onlinePlatform, onlineLink }) {
  if (!['physical', 'online', 'hybrid'].includes(sessionMode)) {
    throw new AppError(400, 'INVALID_SESSION_MODE', 'Session mode must be physical, online, or hybrid.');
  }
  if (sessionMode !== 'online' && !facility) {
    throw new AppError(400, 'FACILITY_REQUIRED', 'Choose a room for a physical or hybrid session.');
  }
  if (sessionMode === 'online' && facility) {
    throw new AppError(400, 'FACILITY_NOT_ALLOWED', 'Online sessions do not use a physical room.');
  }
  if (sessionMode !== 'physical') {
    if (!onlinePlatform || !PLATFORMS.has(onlinePlatform)) {
      throw new AppError(400, 'PLATFORM_REQUIRED', 'Choose the online platform for this session.');
    }
    if (!onlineLink) {
      throw new AppError(400, 'LINK_REQUIRED', 'Provide the online meeting link for this session.');
    }
  }
  if (sessionMode === 'physical' && (onlineLink || onlinePlatform)) {
    throw new AppError(400, 'LINK_NOT_ALLOWED', 'Physical sessions do not use an online link.');
  }
  return true;
}

export async function assertFacilityEligibleForSession({ facility, user, sessionMode }) {
  if (!facility) return true;
  if (sessionMode === 'online') {
    throw new AppError(400, 'FACILITY_NOT_ALLOWED', 'Online sessions do not use a physical room.');
  }
  if (['office', 'library'].includes(facility.category) && !ADMIN_ROLES.has(user.role)) {
    throw new AppError(403, 'FACILITY_CATEGORY_FORBIDDEN', `${facility.name} is a ${facility.category.replace('_', ' ')} and cannot be booked as a teaching room.`);
  }
  if (facility.requires_authorized_role && user.role === 'student') {
    throw new AppError(403, 'FACILITY_ROLE_REQUIRED', `${facility.name} is restricted to authorised staff and class representatives.`);
  }
  return true;
}

export async function assertCapacity({ moduleId, facility, semesterId = null, client = null, allowSmall = false }) {
  if (!facility) return null;
  const preview = await capacityPreview(moduleId, semesterId, client);
  if (!allowSmall && preview.required_capacity > facility.capacity) {
    throw new AppError(409, 'CAPACITY_EXCEEDED', `${facility.name} holds ${facility.capacity}, but ${preview.required_capacity} students are attending physically or in hybrid mode. Choose a larger room.`, {
      required_capacity: preview.required_capacity,
      facility_capacity: facility.capacity,
      counts: { total: preview.total, physical: preview.physical, hybrid: preview.hybrid, online: preview.online }
    });
  }
  return preview;
}

export async function sessionAudienceSummary(bookingId, client = null) {
  const db = client || { query };
  const result = await db.query(
    `SELECT
       count(*)::int AS enrolled,
       count(*) FILTER (WHERE COALESCE(e.delivery_mode_override, u.study_mode) IN ('physical','hybrid'))::int AS expected_on_site,
       count(*) FILTER (WHERE COALESCE(e.delivery_mode_override, u.study_mode) = 'online')::int AS expected_online,
       count(sj.id)::int AS joined_online
     FROM bookings b
     JOIN semesters s ON b.start_at >= s.start_date AND b.start_at < (s.end_date + interval '1 day')
     LEFT JOIN enrolments e ON e.module_id = b.module_id AND e.semester_id = s.id
     LEFT JOIN users u ON u.id = e.user_id AND u.is_active = true
     LEFT JOIN session_joins sj ON sj.booking_id = b.id AND sj.user_id = e.user_id
     WHERE b.id = $1
     GROUP BY b.id
     ORDER BY s.is_current DESC
     LIMIT 1`,
    [bookingId]
  );
  return result.rows[0] || { enrolled: 0, expected_on_site: 0, expected_online: 0, joined_online: 0 };
}
