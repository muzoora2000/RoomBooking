import crypto from 'node:crypto';
import { query, withTransaction } from '../db/pool.js';
import { AppError, isPgExclusionViolation } from '../lib/errors.js';
import { auditLog } from '../lib/audit.js';
import {
  addDays,
  durationMinutes,
  formatKampala,
  formatKampalaRange,
  fromKampala,
  fromKampalaISO,
  kampalaDate
} from '../lib/time.js';
import { getSettings } from './settings.js';
import { assertFairness } from './fairness.js';
import { canDisplace, displacementReason, priorityForRole } from './priority.js';
import {
  assertCanScheduleModule,
  assertCapacity,
  assertFacilityEligibleForSession,
  assertOnlineLink,
  validateSessionMode
} from './sessions.js';
import {
  assertFacilityBookable,
  findFacilityClash,
  findLecturerClash,
  suggestAlternatives
} from './clash.js';
import { autoCheckInWalkUp } from './checkin.js';
import {
  notifyAdmins,
  notifyBookingOwner,
  notifySessionEvent,
  notifyUser
} from './notifications.js';

const ADMIN_ROLES = new Set(['department_admin', 'super_admin']);
const GENERAL_ROOM_CATEGORIES = new Set(['discussion_room', 'library']);

function isAdmin(user) {
  return ADMIN_ROLES.has(user.role);
}

function parseMoment(value, dateValue, timeValue) {
  if (value instanceof Date) {
    if (Number.isNaN(value.getTime())) throw new AppError(400, 'INVALID_TIME', 'Invalid date/time.');
    return value;
  }
  if (typeof value === 'number') {
    const parsed = new Date(value);
    if (Number.isNaN(parsed.getTime())) throw new AppError(400, 'INVALID_TIME', 'Invalid date/time.');
    return parsed;
  }
  if (value) {
    const raw = String(value);
    if (/[zZ]$|[+-]\d{2}:?\d{2}$/.test(raw)) {
      const parsed = new Date(raw);
      if (Number.isNaN(parsed.getTime())) throw new AppError(400, 'INVALID_TIME', `Invalid date/time: ${value}`);
      return parsed;
    }
    try {
      return fromKampalaISO(raw);
    } catch {
      throw new AppError(400, 'INVALID_TIME', `Invalid date/time: ${value}`);
    }
  }
  if (dateValue && timeValue) {
    try {
      return fromKampala(dateValue, timeValue);
    } catch (error) {
      throw new AppError(400, 'INVALID_TIME', error.message);
    }
  }
  throw new AppError(400, 'TIME_REQUIRED', 'Provide a start and end time for the booking.');
}

function resolveStartEnd(input) {
  const startAt = parseMoment(input.start_at || input.startAt, input.date, input.start_time || input.startTime);
  const endAt = parseMoment(input.end_at || input.endAt, input.date, input.end_time || input.endTime);
  if (!(new Date(endAt) > new Date(startAt))) {
    throw new AppError(400, 'INVALID_DURATION', 'The end time must be after the start time.');
  }
  return { startAt, endAt };
}

export async function loadFacility(client, facilityId) {
  if (!facilityId) return null;
  const result = await client.query('SELECT * FROM facilities WHERE id = $1', [facilityId]);
  return result.rows[0] || null;
}

export async function getBookingRow(client, bookingId) {
  const result = await client.query(
    `SELECT b.*,
            f.name AS facility_name, f.category AS facility_category, f.building, f.floor, f.wing,
            f.room_number, f.latitude, f.longitude, f.location_description, f.capacity AS facility_capacity,
            f.checkin_mode, f.requires_approval,
            m.code AS module_code, m.name AS module_name,
            u.name AS booked_by_name, u.id_number AS booked_by_id_number, u.role AS booked_by_role_current,
            l.name AS lecturer_name, l.email AS lecturer_email,
            d.name AS department_name, d.code AS department_code,
            c.id AS class_id, c.code AS class_code, c.name AS class_name
       FROM bookings b
       LEFT JOIN facilities f ON f.id = b.facility_id
       LEFT JOIN modules m ON m.id = b.module_id
       LEFT JOIN users u ON u.id = b.user_id
       LEFT JOIN users l ON l.id = b.lecturer_id
       LEFT JOIN departments d ON d.id = m.department_id
       LEFT JOIN classes c ON c.id = u.class_id
       WHERE b.id = $1`,
    [bookingId]
  );
  return result.rows[0] || null;
}

function baseVisibility(row, viewer) {
  if (!viewer) return false;
  if (isAdmin(viewer)) return true;
  if (row.user_id === viewer.id || row.lecturer_id === viewer.id) return true;
  return false;
}

export function canSeeOnlineLink(row, viewer, { enrolled = false } = {}) {
  if (!row?.online_link) return false;
  if (baseVisibility(row, viewer)) return true;
  return Boolean(enrolled);
}

export function bookingToApi(row, viewer = null, { includeOnlineLink = false } = {}) {
  if (!row) return null;
  const showLink = includeOnlineLink && canSeeOnlineLink(row, viewer);
  return {
    id: row.id,
    session_id: row.session_id,
    user_id: row.user_id,
    facility_id: row.facility_id,
    module_id: row.module_id,
    lecturer_id: row.lecturer_id,
    session_mode: row.session_mode,
    online_platform: row.online_platform || null,
    online_link: showLink ? row.online_link : null,
    has_online_link: Boolean(row.online_link),
    meeting_passcode: showLink ? row.meeting_passcode || null : null,
    start_at: row.start_at,
    end_at: row.end_at,
    start_local: formatKampala(row.start_at),
    end_local: formatKampala(row.end_at),
    range_local: formatKampalaRange(row.start_at, row.end_at),
    day: kampalaDate(row.start_at),
    duration_minutes: durationMinutes(row.start_at, row.end_at),
    status: row.status,
    priority: row.priority,
    source: row.source,
    entry_point: row.entry_point,
    purpose: row.purpose || null,
    recurrence_group_id: row.recurrence_group_id || null,
    booked_by_role: row.booked_by_role,
    is_locked: row.is_locked,
    checked_in_at: row.checked_in_at,
    checkin_method: row.checkin_method || null,
    released_at: row.released_at,
    release_reason: row.release_reason || null,
    converted_to_online_at: row.converted_to_online_at || null,
    displacement_reason: row.displacement_reason || null,
    created_at: row.created_at,
    updated_at: row.updated_at,
    facility: row.facility_id
      ? {
          id: row.facility_id,
          name: row.facility_name,
          category: row.facility_category,
          building: row.building,
          floor: row.floor,
          wing: row.wing || null,
          room_number: row.room_number,
          location_description: row.location_description,
          latitude: row.latitude,
          longitude: row.longitude,
          capacity: row.facility_capacity,
          checkin_mode: row.checkin_mode
        }
      : null,
    module: row.module_id
      ? { id: row.module_id, code: row.module_code, name: row.module_name, department: row.department_name }
      : null,
    class: row.class_id ? { id: row.class_id, code: row.class_code, name: row.class_name } : null,
    booked_by: row.booked_by_name ? { id: row.user_id, name: row.booked_by_name, id_number: row.booked_by_id_number } : null,
    lecturer: row.lecturer_id ? { id: row.lecturer_id, name: row.lecturer_name, email: row.lecturer_email } : null,
    can_manage: viewer ? baseVisibility(row, viewer) : false,
    can_cancel:
      viewer && ['pending', 'confirmed'].includes(row.status) && (baseVisibility(row, viewer) || isAdmin(viewer))
  };
}

async function assertCanManage(row, user) {
  if (!row) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Booking not found.');
  if (isAdmin(user)) return true;
  if (row.user_id === user.id || row.lecturer_id === user.id) return true;
  if (row.module_id) {
    const delegate = await query(
      `SELECT 1 FROM delegations
       WHERE module_id = $1 AND to_user_id = $2 AND revoked_at IS NULL
         AND $3 BETWEEN starts_at AND ends_at LIMIT 1`,
      [row.module_id, user.id, row.start_at]
    );
    if (delegate.rowCount) return true;
  }
  throw new AppError(403, 'BOOKING_FORBIDDEN', 'You cannot manage this booking.');
}

function assertNotStartedForChange(row, user) {
  if (isAdmin(user)) return;
  if (row.checked_in_at || Date.now() >= new Date(row.start_at).getTime()) {
    throw new AppError(409, 'BOOKING_STARTED', 'This session has already started. Ask an administrator to change it.');
  }
}

function resolveLecturer(user, module, input) {
  if (isAdmin(user) && input.lecturer_id) return input.lecturer_id;
  return module?.lecturer_id || null;
}

function categoryAllowedForGeneralBooking(user, facility) {
  if (!facility) return;
  // Admins, lecturers, class reps and deputy reps can book any room category
  if (isAdmin(user) || ['lecturer', 'class_rep', 'deputy_rep'].includes(user.role)) return;
  // Students and other roles are restricted to discussion rooms and library spaces
  if (!GENERAL_ROOM_CATEGORIES.has(facility.category)) {
    throw new AppError(
      403,
      'ROOM_CATEGORY_FORBIDDEN',
      'Only students are restricted to discussion rooms and library spaces. If you are a class representative, make sure your account has the class rep role assigned by an administrator.'
    );
  }
}

async function checkConflicts({ client, user, module, lecturerId, facility, startAt, endAt, excludeId = null, displaced, allowDisplace = true }) {
  if (lecturerId) {
    const lecturerClash = await findLecturerClash(client, { lecturerId, startAt, endAt, excludeId });
    if (lecturerClash.length) {
      const clash = lecturerClash[0];
      throw new AppError(
        409,
        'LECTURER_CONFLICT',
        `${clash.module_code || 'Another session'} is already scheduled with this lecturer from ${formatKampala(
          clash.start_at
        )} to ${formatKampala(clash.end_at, 'HH:mm')}.`,
        { booking_id: clash.id, start_at: clash.start_at, end_at: clash.end_at }
      );
    }
  }
  if (!facility) return;
  const facilityClash = await findFacilityClash(client, { facilityId: facility.id, startAt, endAt, excludeId });
  if (!facilityClash.length) return;
  const displaceable = [];
  for (const clash of facilityClash) {
    const allowed = allowDisplace && canDisplace({
      newPriority: priorityForRole(user.role),
      newRole: user.role,
      newModuleId: module?.id || null,
      existing: clash
    });
    if (!allowed) {
      const alternatives = await suggestAlternatives({
        client,
        facility,
        startAt,
        endAt,
        category: module ? facility.category : null,
        capacity: null,
        excludeId
      });
      throw new AppError(
        409,
        'FACILITY_CONFLICT',
        `${facility.name} is already booked from ${formatKampala(clash.start_at)} to ${formatKampala(
          clash.end_at,
          'HH:mm'
        )}.`,
        {
          conflict: {
            id: clash.id,
            module: clash.module_code || null,
            status: clash.status,
            start_at: clash.start_at,
            end_at: clash.end_at
          },
          alternatives
        }
      );
    }
    displaceable.push(clash);
  }
  const reason = displacementReason(user.role, displaceable[0]);
  for (const clash of displaceable) {
    await client.query(
      `UPDATE bookings
       SET status = 'cancelled', displacement_reason = $2, updated_at = now()
       WHERE id = $1`,
      [clash.id, reason]
    );
    displaced.push({ id: clash.id, reason });
  }
}

function validateGeneralBooking(user, input, facility) {
  if (!facility) {
    throw new AppError(400, 'FACILITY_REQUIRED', 'Choose a room to book.');
  }
  if (input.session_mode && input.session_mode !== 'physical') {
    throw new AppError(400, 'INVALID_SESSION_MODE', 'General room bookings are always physical. Choose a module to schedule an online or hybrid class.');
  }
  if (input.online_link || input.online_platform) {
    throw new AppError(400, 'LINK_NOT_ALLOWED', 'Online links are only used for class sessions.');
  }
  categoryAllowedForGeneralBooking(user, facility);
  if (!String(input.purpose || '').trim()) {
    throw new AppError(400, 'PURPOSE_REQUIRED', 'Describe what you need the room for.');
  }
}

async function createOne({
  client,
  user,
  input,
  startAt,
  endAt,
  recurrenceGroupId = null,
  displaced = []
}) {
  const moduleId = input.module_id || null;
  const isSession = Boolean(moduleId);
  const settings = await getSettings();
  let module = null;
  let classId = input.class_id || null;
  if (isSession) {
    const authorised = await assertCanScheduleModule(user, moduleId, { classId, at: startAt, client });
    module = authorised.module;
    classId = authorised.classId || classId;
  }
  const facility = await loadFacility(client, input.facility_id || null);
  const sessionMode = input.session_mode || (facility ? 'physical' : 'online');
  if (!isSession) {
    validateGeneralBooking(user, { ...input, session_mode: sessionMode }, facility);
  } else {
    validateSessionMode({
      sessionMode,
      facility,
      onlinePlatform: input.online_platform,
      onlineLink: input.online_link
    });
    await assertFacilityEligibleForSession({ facility, user, sessionMode });
  }
  let onlineLink = null;
  if (sessionMode !== 'physical') onlineLink = await assertOnlineLink(input.online_link);
  if (facility) await assertFacilityBookable(client, { facility, startAt, endAt, source: input.source || 'manual' });
  if (isSession && facility) {
    await assertCapacity({ moduleId, facility, semesterId: input.semester_id || null, client });
  }
  if (facility) {
    await assertFairness({
      client,
      user,
      startAt,
      endAt,
      entryPoint: input.entry_point || 'app',
      source: input.source || 'manual',
      facilityId: facility.id,
      settings
    });
  }
  const source = input.source || 'manual';
  if (source !== 'manual' && !isAdmin(user)) {
    throw new AppError(403, 'OFFICIAL_SOURCE_FORBIDDEN', 'Only administrators can import timetable or exam bookings.');
  }
  if (input.is_locked && !isAdmin(user)) {
    throw new AppError(403, 'LOCK_FORBIDDEN', 'Only administrators can lock a booking.');
  }
  const lecturerId = isSession ? resolveLecturer(user, module, input) : null;
  await checkConflicts({ client, user, module, lecturerId, facility, startAt, endAt, displaced });
  const requiresApproval = Boolean(facility?.requires_approval) && !isAdmin(user) && source === 'manual';
  const status = requiresApproval ? 'pending' : 'confirmed';
  const priority = priorityForRole(user.role, source);
  const id = crypto.randomUUID();
  try {
    await client.query(
      `INSERT INTO bookings (
         id, session_id, user_id, facility_id, module_id, lecturer_id,
         session_mode, online_platform, online_link, meeting_passcode,
         start_at, end_at, status, priority, source, entry_point, purpose,
         recurrence_group_id, booked_by_role, is_locked
       ) VALUES (
         $1,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19
       )`,
      [
        id,
        user.id,
        facility?.id || null,
        isSession ? module.id : null,
        lecturerId,
        sessionMode,
        sessionMode === 'physical' ? null : input.online_platform,
        onlineLink,
        sessionMode === 'physical' ? null : input.meeting_passcode || null,
        startAt,
        endAt,
        status,
        priority,
        source,
        input.entry_point || 'app',
        String(input.purpose || '').trim() || null,
        recurrenceGroupId,
        user.role,
        Boolean(input.is_locked) && isAdmin(user)
      ]
    );
  } catch (error) {
    if (isPgExclusionViolation(error)) {
      throw new AppError(409, 'TIME_CONFLICT', 'That room or lecturer was just booked by someone else. Choose another time or room.');
    }
    // PostgreSQL check constraint violation (23514) — usually the session_mode/facility/online_link combo
    if (error?.code === '23514') {
      throw new AppError(400, 'BOOKING_CONSTRAINT', 'The booking details are inconsistent. Physical bookings need a room, online bookings need a meeting link. Please check your selections and try again.');
    }
    // Column does not exist — booked_by_role or is_locked may be missing; retry without them
    if (error?.code === '42703') {
      console.warn('[booking] INSERT fell back to base columns (migration pending):', error.message);
      try {
        await client.query(
          `INSERT INTO bookings (
             id, session_id, user_id, facility_id, module_id, lecturer_id,
             session_mode, online_platform, online_link, meeting_passcode,
             start_at, end_at, status, priority, source, entry_point, purpose,
             recurrence_group_id
           ) VALUES (
             $1,$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17
           )`,
          [
            id,
            user.id,
            facility?.id || null,
            isSession ? module.id : null,
            lecturerId,
            sessionMode,
            sessionMode === 'physical' ? null : input.online_platform,
            onlineLink,
            sessionMode === 'physical' ? null : input.meeting_passcode || null,
            startAt,
            endAt,
            status,
            priority,
            source,
            input.entry_point || 'app',
            String(input.purpose || '').trim() || null,
            recurrenceGroupId
          ]
        );
      } catch (retryError) {
        if (isPgExclusionViolation(retryError)) {
          throw new AppError(409, 'TIME_CONFLICT', 'That room or lecturer was just booked by someone else. Choose another time or room.');
        }
        throw new AppError(500, 'BOOKING_FAILED', `Booking could not be saved: ${retryError.message || 'database error'}. Please try again.`);
      }
    } else if (error?.code === '23502') {
      // Not-null constraint violated
      throw new AppError(400, 'MISSING_FIELD', `A required booking field is missing: ${error.column || 'unknown'}. Please fill in all required fields.`);
    } else if (error?.code === '23503') {
      // Foreign key violation
      throw new AppError(400, 'INVALID_REFERENCE', 'One of the selected rooms, modules, or users no longer exists. Refresh the page and try again.');
    } else {
      throw new AppError(500, 'BOOKING_FAILED', `Booking could not be saved: ${error.message || 'database error'}. Please try again or contact support.`);
    }
  }
  const row = await getBookingRow(client, id);
  return { row, status, requiresApproval, module, facility, displaced };
}

async function notifyCreated(row, { requiresApproval, user, displaced, walkUp }) {
  if (requiresApproval) {
    await notifyAdmins({
      type: 'booking_approval',
      eventType: 'booking_approval',
      title: 'Booking needs approval',
      message: `${user.name} requested ${row.facility_name || 'a room'} from ${formatKampalaRange(row.start_at, row.end_at)}.`,
      severity: 'info',
      link: '/admin.html#bookings',
      bookingId: row.id
    });
    await notifyUser({
      userId: row.user_id,
      type: 'booking_pending',
      eventType: 'booking_pending',
      title: 'Booking awaiting approval',
      message: `Your request for ${row.facility_name || 'the room'} on ${formatKampalaRange(row.start_at, row.end_at)} is awaiting administrator approval.`,
      bookingId: row.id,
      link: '/bookings.html'
    });
    return;
  }
  await notifySessionEvent({ bookingId: row.id, event: 'confirmed' });
  for (const item of displaced) {
    try {
      const { notifyDisplacedUser } = await import('./notifications.js');
      const displacedRow = await getBookingRow({ query }, item.id);
      if (displacedRow) await notifyDisplacedUser(displacedRow, row, item.reason);
    } catch (error) {
      console.error('[booking] displacement notification failed', item.id, error.message);
    }
  }
  if (walkUp) {
    await auditLog({
      action: 'booking_walkup',
      entityType: 'booking',
      entityId: row.id,
      details: { facility_id: row.facility_id, user_id: row.user_id }
    });
  }
}

export async function createBooking({ user, input, req = null }) {
  const { startAt, endAt } = resolveStartEnd(input);
  const result = await withTransaction(async (client) => {
    const displaced = [];
    const created = await createOne({ client, user, input, startAt, endAt, displaced });
    return { ...created, displaced };
  });
  const walkUp = (input.entry_point || 'app') === 'room_qr';
  let checkedIn = null;
  if (walkUp && result.status === 'confirmed') {
    checkedIn = await autoCheckInWalkUp({ bookingId: result.row.id, req });
  }
  await auditLog({
    req,
    userId: user.id,
    action: 'booking_created',
    entityType: 'booking',
    entityId: result.row.id,
    details: {
      facility_id: result.row.facility_id,
      module_id: result.row.module_id,
      start_at: result.row.start_at,
      end_at: result.row.end_at,
      status: result.status,
      source: result.row.source,
      entry_point: result.row.entry_point,
      displaced: result.displaced.map((item) => item.id)
    }
  });
  try {
    await notifyCreated(result.row, {
      requiresApproval: result.requiresApproval,
      user,
      displaced: result.displaced,
      walkUp
    });
  } catch (error) {
    console.error('[booking] created notification failed', result.row.id, error.message);
  }
  return {
    booking: bookingToApi(result.row, user, { includeOnlineLink: true }),
    status: result.status,
    requires_approval: result.requiresApproval,
    displaced: result.displaced.map((item) => item.id),
    checked_in: Boolean(checkedIn),
    warning: result.status === 'pending' ? 'This room requires administrator approval. Your slot is held while it is reviewed.' : null
  };
}

export async function createRecurringBookings({ user, input, req = null }) {
  if ((input.entry_point || 'app') === 'room_qr') {
    throw new AppError(400, 'WALKUP_NOT_RECURRING', 'Walk-up bookings cannot repeat.');
  }
  const frequency = input.recurrence?.frequency || 'weekly';
  if (frequency !== 'weekly') {
    throw new AppError(400, 'INVALID_RECURRENCE', 'Only weekly recurring bookings are supported.');
  }
  const { startAt, endAt } = resolveStartEnd(input);
  const count = Math.min(Math.max(Number(input.recurrence?.count || 0), 0), 52);
  let occurrences = [];
  if (count > 0) {
    const duration = new Date(endAt).getTime() - new Date(startAt).getTime();
    for (let index = 0; index < count; index += 1) {
      const start = addDays(startAt, index * 7);
      occurrences.push({ start, end: new Date(new Date(start).getTime() + duration) });
    }
  } else if (input.recurrence?.until) {
    const until = new Date(input.recurrence.until);
    if (Number.isNaN(until.getTime())) throw new AppError(400, 'INVALID_RECURRENCE', 'Invalid recurrence end date.');
    const duration = new Date(endAt).getTime() - new Date(startAt).getTime();
    for (let index = 0; index < 52; index += 1) {
      const start = addDays(startAt, index * 7);
      if (start > until) break;
      occurrences.push({ start, end: new Date(new Date(start).getTime() + duration) });
    }
  } else {
    throw new AppError(400, 'INVALID_RECURRENCE', 'Provide a repeat count or an end date.');
  }
  if (!occurrences.length) throw new AppError(400, 'INVALID_RECURRENCE', 'The recurrence has no occurrences.');
  const groupId = crypto.randomUUID();
  const createdRows = [];
  const displaced = [];
  let requiresApproval = false;
  await withTransaction(async (client) => {
    for (const occurrence of occurrences) {
      const created = await createOne({
        client,
        user,
        input,
        startAt: occurrence.start,
        endAt: occurrence.end,
        recurrenceGroupId: groupId,
        displaced
      });
      requiresApproval = requiresApproval || created.requiresApproval;
      createdRows.push(created.row);
    }
  });
  await auditLog({
    req,
    userId: user.id,
    action: 'booking_created_recurring',
    entityType: 'booking',
    entityId: groupId,
    details: {
      group_id: groupId,
      occurrences: createdRows.length,
      facility_id: createdRows[0]?.facility_id,
      module_id: createdRows[0]?.module_id,
      displaced: displaced.map((item) => item.id)
    }
  });
  for (const [index, row] of createdRows.entries()) {
    try {
      await notifyCreated(row, { requiresApproval, user, displaced: index === 0 ? displaced : [], walkUp: false });
    } catch (error) {
      console.error('[booking] recurring notification failed', row.id, error.message);
    }
  }
  return {
    recurrence_group_id: groupId,
    count: createdRows.length,
    bookings: createdRows.map((row) => bookingToApi(row, user, { includeOnlineLink: true })),
    requires_approval: requiresApproval,
    displaced: displaced.map((item) => item.id)
  };
}

export async function updateBooking({ bookingId, user, input, req = null }) {
  const result = await withTransaction(async (client) => {
    const existingResult = await client.query('SELECT * FROM bookings WHERE id = $1 FOR UPDATE', [bookingId]);
    const existing = existingResult.rows[0];
    if (!existing) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Booking not found.');
    await assertCanManage(existing, user);
    if (existing.is_locked && !isAdmin(user)) {
      throw new AppError(409, 'BOOKING_LOCKED', 'This booking is locked by an administrator.');
    }
    if (!['pending', 'confirmed'].includes(existing.status)) {
      throw new AppError(409, 'BOOKING_NOT_EDITABLE', `A ${existing.status} booking cannot be edited.`);
    }
    const timesChanged = Boolean(input.start_at || input.startAt || input.end_at || input.endAt || input.date || input.start_time);
    if (timesChanged) assertNotStartedForChange(existing, user);
    const { startAt, endAt } = timesChanged
      ? resolveStartEnd({ ...input, date: input.date })
      : { startAt: existing.start_at, endAt: existing.end_at };
    const moduleId = existing.module_id;
    let module = null;
    if (moduleId) {
      const moduleResult = await client.query('SELECT * FROM modules WHERE id = $1', [moduleId]);
      module = moduleResult.rows[0] || null;
    }
    const facilityId = input.facility_id !== undefined ? input.facility_id : existing.facility_id;
    const facility = await loadFacility(client, facilityId);
    const sessionMode = input.session_mode || existing.session_mode;
    const onlinePlatform =
      input.online_platform !== undefined ? input.online_platform : existing.online_platform;
    const onlineLinkInput = input.online_link !== undefined ? input.online_link : existing.online_link;
    if (!moduleId) {
      validateGeneralBooking(user, { ...input, session_mode: sessionMode, purpose: input.purpose ?? existing.purpose }, facility);
    } else {
      validateSessionMode({
        sessionMode,
        facility,
        onlinePlatform: sessionMode === 'physical' ? null : onlinePlatform,
        onlineLink: sessionMode === 'physical' ? null : onlineLinkInput
      });
      await assertFacilityEligibleForSession({ facility, user, sessionMode });
    }
    const onlineLink = sessionMode === 'physical' ? null : await assertOnlineLink(onlineLinkInput);
    if (facility) {
      await assertFacilityBookable(client, { facility, startAt, endAt, source: existing.source });
      await checkConflicts({
        client,
        user,
        module,
        lecturerId: existing.lecturer_id,
        facility,
        startAt,
        endAt,
        excludeId: existing.id,
        displaced: [],
        allowDisplace: false
      });
      if (moduleId) {
        await assertCapacity({ moduleId, facility, semesterId: input.semester_id || null, client });
      }
      if (timesChanged || input.facility_id !== undefined) {
        await assertFairness({
          client,
          user,
          startAt,
          endAt,
          entryPoint: existing.entry_point,
          source: existing.source,
          facilityId: facility.id,
          excludeBookingId: existing.id
        });
      }
    }
    const meetingPasscode =
      input.meeting_passcode !== undefined ? input.meeting_passcode : existing.meeting_passcode;
    const updated = await client.query(
      `UPDATE bookings
       SET facility_id = $2, session_mode = $3, online_platform = $4, online_link = $5,
           meeting_passcode = $6, start_at = $7, end_at = $8,
           purpose = COALESCE($9, purpose), updated_at = now()
       WHERE id = $1 RETURNING *`,
      [
        bookingId,
        facility?.id || null,
        sessionMode,
        sessionMode === 'physical' ? null : onlinePlatform,
        onlineLink,
        sessionMode === 'physical' ? null : meetingPasscode || null,
        startAt,
        endAt,
        input.purpose === undefined ? null : String(input.purpose || '').trim() || null
      ]
    );
    const row = await getBookingRow(client, updated.rows[0].id);
    return { row, existing };
  });
  await auditLog({
    req,
    userId: user.id,
    action: 'booking_updated',
    entityType: 'booking',
    entityId: bookingId,
    details: {
      before: {
        facility_id: result.existing.facility_id,
        session_mode: result.existing.session_mode,
        start_at: result.existing.start_at,
        end_at: result.existing.end_at
      },
      after: {
        facility_id: result.row.facility_id,
        session_mode: result.row.session_mode,
        start_at: result.row.start_at,
        end_at: result.row.end_at
      }
    }
  });
  try {
    await notifySessionEvent({
      bookingId,
      event: 'updated',
      changes: {
        timeChanged:
          new Date(result.existing.start_at).getTime() !== new Date(result.row.start_at).getTime() ||
          new Date(result.existing.end_at).getTime() !== new Date(result.row.end_at).getTime(),
        roomChanged: result.existing.facility_id !== result.row.facility_id,
        modeChanged: result.existing.session_mode !== result.row.session_mode,
        linkChanged: result.existing.online_link !== result.row.online_link
      },
      reason: input.reason || ''
    });
  } catch (error) {
    console.error('[booking] update notification failed', bookingId, error.message);
  }
  return bookingToApi(result.row, user, { includeOnlineLink: true });
}

export async function cancelBooking({ bookingId, user, reason = '', scope = 'single', req = null }) {
  const settings = await getSettings(['cancellation_cutoff_minutes']);
  const cutoffMinutes = Number(settings.cancellation_cutoff_minutes || 0);
  const cancelled = await withTransaction(async (client) => {
    const result = await client.query('SELECT * FROM bookings WHERE id = $1 FOR UPDATE', [bookingId]);
    const existing = result.rows[0];
    if (!existing) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Booking not found.');
    await assertCanManage(existing, user);
    if (!['pending', 'confirmed'].includes(existing.status)) {
      throw new AppError(409, 'BOOKING_NOT_CANCELLABLE', `A ${existing.status} booking cannot be cancelled.`);
    }
    if (existing.is_locked && !isAdmin(user)) {
      throw new AppError(409, 'BOOKING_LOCKED', 'This booking is locked by an administrator.');
    }
    if (!isAdmin(user) && cutoffMinutes > 0) {
      const cutoff = new Date(existing.start_at).getTime() - cutoffMinutes * 60_000;
      if (Date.now() > cutoff) {
        throw new AppError(409, 'CANCELLATION_CUTOFF', `Cancellations close ${cutoffMinutes} minutes before the session starts.`);
      }
    }
    if (!isAdmin(user) && (existing.checked_in_at || Date.now() >= new Date(existing.start_at).getTime())) {
      throw new AppError(409, 'BOOKING_STARTED', 'This session has started. Ask an administrator to cancel it.');
    }
    let targetIds = [existing.id];
    if (scope === 'future' && existing.recurrence_group_id) {
      const future = await client.query(
        `SELECT id FROM bookings
         WHERE recurrence_group_id = $1 AND start_at >= $2
           AND status IN ('pending','confirmed')
         ORDER BY start_at
         FOR UPDATE`,
        [existing.recurrence_group_id, existing.start_at]
      );
      targetIds = future.rows.map((row) => row.id);
    } else if (scope === 'all' && existing.recurrence_group_id) {
      const all = await client.query(
        `SELECT id FROM bookings
         WHERE recurrence_group_id = $1 AND status IN ('pending','confirmed')
         ORDER BY start_at
         FOR UPDATE`,
        [existing.recurrence_group_id]
      );
      targetIds = all.rows.map((row) => row.id);
    }
    const updated = await client.query(
      `UPDATE bookings
       SET status = 'cancelled', release_reason = COALESCE($2, release_reason), updated_at = now()
       WHERE id = ANY($1::uuid[])
       RETURNING id`,
      [targetIds, String(reason || '').trim() || 'Cancelled by user']
    );
    return { ids: updated.rows.map((row) => row.id), existing };
  });
  for (const id of cancelled.ids) {
    await auditLog({
      req,
      userId: user.id,
      action: 'booking_cancelled',
      entityType: 'booking',
      entityId: id,
      details: { reason, scope }
    });
    try {
      await notifySessionEvent({ bookingId: id, event: 'cancelled', reason });
    } catch (error) {
      console.error('[booking] cancellation notification failed', id, error.message);
    }
  }
  return { cancelled: cancelled.ids.length, ids: cancelled.ids };
}

export async function convertToOnline({ bookingId, user, onlinePlatform, onlineLink, meetingPasscode = null, reason = '', req = null }) {
  if (!['zoom', 'google_meet', 'teams', 'other'].includes(onlinePlatform)) {
    throw new AppError(400, 'PLATFORM_REQUIRED', 'Choose an online platform.');
  }
  const safeLink = await assertOnlineLink(onlineLink);
  const row = await withTransaction(async (client) => {
    const result = await client.query('SELECT * FROM bookings WHERE id = $1 FOR UPDATE', [bookingId]);
    const existing = result.rows[0];
    if (!existing) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Booking not found.');
    await assertCanManage(existing, user);
    if (!['pending', 'confirmed'].includes(existing.status)) {
      throw new AppError(409, 'BOOKING_NOT_EDITABLE', `A ${existing.status} booking cannot be converted.`);
    }
    const updated = await client.query(
      `UPDATE bookings
       SET session_mode = 'online', facility_id = NULL, online_platform = $2,
           online_link = $3, meeting_passcode = $4, converted_to_online_at = now(), updated_at = now()
       WHERE id = $1 RETURNING *`,
      [bookingId, onlinePlatform, safeLink, meetingPasscode || null]
    );
    return getBookingRow(client, updated.rows[0].id);
  });
  await auditLog({
    req,
    userId: user.id,
    action: 'booking_converted_online',
    entityType: 'booking',
    entityId: bookingId,
    details: { platform: onlinePlatform, reason }
  });
  try {
    await notifySessionEvent({
      bookingId,
      event: 'updated',
      changes: { modeChanged: true, roomChanged: true, linkChanged: true },
      reason: reason || 'The session has been moved online.'
    });
  } catch (error) {
    console.error('[booking] convert notification failed', bookingId, error.message);
  }
  return bookingToApi(row, user, { includeOnlineLink: true });
}

export async function updateOnlineLink({ bookingId, user, onlinePlatform, onlineLink, meetingPasscode = null, req = null }) {
  const safeLink = await assertOnlineLink(onlineLink);
  const row = await withTransaction(async (client) => {
    const result = await client.query('SELECT * FROM bookings WHERE id = $1 FOR UPDATE', [bookingId]);
    const existing = result.rows[0];
    if (!existing) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Booking not found.');
    await assertCanManage(existing, user);
    if (!['online', 'hybrid'].includes(existing.session_mode)) {
      throw new AppError(409, 'NOT_ONLINE_SESSION', 'This session is physical and has no online link.');
    }
    if (!['pending', 'confirmed'].includes(existing.status)) {
      throw new AppError(409, 'BOOKING_NOT_EDITABLE', `A ${existing.status} booking cannot be edited.`);
    }
    const updated = await client.query(
      `UPDATE bookings
       SET online_platform = $2, online_link = $3, meeting_passcode = $4, updated_at = now()
       WHERE id = $1 RETURNING *`,
      [bookingId, onlinePlatform || existing.online_platform, safeLink, meetingPasscode || null]
    );
    return getBookingRow(client, updated.rows[0].id);
  });
  await auditLog({
    req,
    userId: user.id,
    action: 'booking_link_updated',
    entityType: 'booking',
    entityId: bookingId,
    details: { platform: onlinePlatform }
  });
  try {
    await notifySessionEvent({ bookingId, event: 'updated', changes: { linkChanged: true } });
  } catch (error) {
    console.error('[booking] link notification failed', bookingId, error.message);
  }
  return bookingToApi(row, user, { includeOnlineLink: true });
}

export async function approveBooking({ bookingId, admin, req = null, note = '' }) {
  if (!isAdmin(admin)) throw new AppError(403, 'ADMIN_ONLY', 'Only administrators can approve bookings.');
  const row = await withTransaction(async (client) => {
    const result = await client.query('SELECT * FROM bookings WHERE id = $1 FOR UPDATE', [bookingId]);
    const existing = result.rows[0];
    if (!existing) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Booking not found.');
    if (existing.status !== 'pending') {
      throw new AppError(409, 'NOT_PENDING', `This booking is already ${existing.status}.`);
    }
    const facility = await loadFacility(client, existing.facility_id);
    if (facility) {
      await assertFacilityBookable(client, {
        facility,
        startAt: existing.start_at,
        endAt: existing.end_at,
        source: existing.source
      });
      await findLecturerClash(client, {
        lecturerId: existing.lecturer_id,
        startAt: existing.start_at,
        endAt: existing.end_at,
        excludeId: existing.id
      }).then((clashes) => {
        if (clashes.length) throw new AppError(409, 'LECTURER_CONFLICT', 'The lecturer now has another session at this time.');
      });
    }
    const updated = await client.query(
      `UPDATE bookings SET status = 'confirmed', updated_at = now() WHERE id = $1 RETURNING *`,
      [bookingId]
    );
    return getBookingRow(client, updated.rows[0].id);
  });
  await auditLog({
    req,
    userId: admin.id,
    action: 'booking_approved',
    entityType: 'booking',
    entityId: bookingId,
    details: { note }
  });
  try {
    await notifySessionEvent({ bookingId, event: 'confirmed' });
    await notifyBookingOwner(bookingId, 'booking_approved', {
      title: 'Booking approved',
      message: `Your booking for ${formatKampalaRange(row.start_at, row.end_at)} has been approved.`
    });
  } catch (error) {
    console.error('[booking] approval notification failed', bookingId, error.message);
  }
  return bookingToApi(row, admin, { includeOnlineLink: true });
}

export async function rejectBooking({ bookingId, admin, reason, req = null }) {
  if (!isAdmin(admin)) throw new AppError(403, 'ADMIN_ONLY', 'Only administrators can reject bookings.');
  if (!String(reason || '').trim()) throw new AppError(400, 'REASON_REQUIRED', 'Give a reason for rejecting the booking.');
  const row = await withTransaction(async (client) => {
    const result = await client.query(
      `UPDATE bookings SET status = 'rejected', release_reason = $2, updated_at = now()
       WHERE id = $1 AND status = 'pending' RETURNING *`,
      [bookingId, String(reason).trim()]
    );
    if (!result.rowCount) throw new AppError(409, 'NOT_PENDING', 'Only pending bookings can be rejected.');
    return getBookingRow(client, bookingId);
  });
  await auditLog({
    req,
    userId: admin.id,
    action: 'booking_rejected',
    entityType: 'booking',
    entityId: bookingId,
    details: { reason }
  });
  try {
    await notifyBookingOwner(bookingId, 'booking_rejected', {
      title: 'Booking rejected',
      message: `Your booking request was rejected: ${reason}`,
      severity: 'warning'
    });
  } catch (error) {
    console.error('[booking] rejection notification failed', bookingId, error.message);
  }
  return bookingToApi(row, admin);
}

export async function adminDisplaceBooking({ bookingId, admin, reason, req = null }) {
  if (!isAdmin(admin)) throw new AppError(403, 'ADMIN_ONLY', 'Only administrators can displace bookings.');
  if (!String(reason || '').trim()) throw new AppError(400, 'REASON_REQUIRED', 'Give a reason for displacing the booking.');
  const row = await withTransaction(async (client) => {
    const result = await client.query(
      `UPDATE bookings
       SET status = 'cancelled', displacement_reason = $2, release_reason = $2, updated_at = now()
       WHERE id = $1 AND status IN ('pending','confirmed') RETURNING *`,
      [bookingId, String(reason).trim()]
    );
    if (!result.rowCount) throw new AppError(409, 'BOOKING_NOT_ACTIVE', 'Only pending or confirmed bookings can be displaced.');
    return getBookingRow(client, bookingId);
  });
  await auditLog({
    req,
    userId: admin.id,
    action: 'booking_displaced_admin',
    entityType: 'booking',
    entityId: bookingId,
    details: { reason }
  });
  try {
    await notifyBookingOwner(bookingId, 'session_displaced', {
      title: 'Booking displaced',
      message: `Your booking was displaced by an administrator: ${reason}`,
      severity: 'warning'
    });
  } catch (error) {
    console.error('[booking] displacement notification failed', bookingId, error.message);
  }
  return bookingToApi(row, admin);
}

export async function listBookingsForUser({ user, from = null, to = null, status = null }) {
  const params = [user.id];
  const conditions = ['b.user_id = $1'];
  if (from) {
    params.push(from);
    conditions.push(`b.end_at > $${params.length}`);
  }
  if (to) {
    params.push(to);
    conditions.push(`b.start_at < $${params.length}`);
  }
  if (status) {
    params.push(status);
    conditions.push(`b.status = $${params.length}`);
  }
  const result = await query(
    `SELECT b.id FROM bookings b WHERE ${conditions.join(' AND ')} ORDER BY b.start_at DESC LIMIT 500`,
    params
  );
  const rows = await Promise.all(result.rows.map((row) => getBookingRow({ query }, row.id)));
  return rows.filter(Boolean).map((row) => bookingToApi(row, user, { includeOnlineLink: true }));
}

export async function getBookingDetail({ bookingId, user }) {
  const row = await getBookingRow({ query }, bookingId);
  if (!row) throw new AppError(404, 'BOOKING_NOT_FOUND', 'Booking not found.');
  if (!baseVisibility(row, user) && !isAdmin(user)) {
    if (row.module_id) {
      const enrolled = await query(
        `SELECT 1 FROM enrolments e JOIN semesters s ON s.id = e.semester_id
         WHERE e.user_id = $1 AND e.module_id = $2 AND s.is_current = true LIMIT 1`,
        [user.id, row.module_id]
      );
      if (!enrolled.rowCount) throw new AppError(403, 'BOOKING_FORBIDDEN', 'You cannot view this booking.');
    } else {
      throw new AppError(403, 'BOOKING_FORBIDDEN', 'You cannot view this booking.');
    }
  }
  return bookingToApi(row, user, { includeOnlineLink: true });
}

export { isAdmin, resolveStartEnd };
