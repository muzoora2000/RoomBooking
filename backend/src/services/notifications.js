import { config } from '../config.js';
import { query } from '../db/pool.js';
import { formatKampala } from '../lib/time.js';
import { getSettings } from './settings.js';
import { composeDisplacementMessage, composeSessionMessage } from './matrix.js';
import { kickQueue } from './queue.js';

const DEFAULT_CHANNELS = { inapp: true, email: true, sms: false, push: true };
const EVENT_TYPE_BY_EVENT = {
  confirmed: 'session_confirmed',
  updated: 'session_updated',
  cancelled: 'session_cancelled',
  released: 'session_released',
  reminder: 'session_reminder',
  displaced: 'session_displaced'
};

function runner(client) {
  return client ? { query: (text, params) => client.query(text, params) } : { query };
}

async function loadBooking(db, bookingId) {
  const result = await db.query(
    `SELECT b.*, m.code AS module_code, m.name AS module_name,
            f.name AS facility_name, f.building, f.floor, f.wing, f.room_number, f.category
     FROM bookings b
     LEFT JOIN modules m ON m.id = b.module_id
     LEFT JOIN facilities f ON f.id = b.facility_id
     WHERE b.id = $1`,
    [bookingId]
  );
  return result.rows[0] || null;
}

function roomText(booking) {
  if (!booking || !booking.facility_id) return null;
  const wing = booking.wing ? `, ${booking.wing}` : '';
  return `${booking.building}, Floor ${booking.floor}${wing}, ${booking.facility_name} (${booking.room_number})`;
}

function timeText(booking) {
  if (!booking) return '';
  return formatKampala(booking.start_at, 'ccc dd LLL, HH:mm');
}

function rangeText(booking) {
  if (!booking) return '';
  return `${formatKampala(booking.start_at, 'ccc dd LLL, HH:mm')}-${formatKampala(booking.end_at, 'HH:mm')}`;
}

async function getPreferences(db, userIds, eventType) {
  if (!userIds.length) return new Map();
  const result = await db.query(
    `SELECT user_id, channel, enabled FROM notification_preferences
     WHERE user_id = ANY($1::uuid[]) AND event_type = $2`,
    [userIds, eventType]
  );
  const map = new Map();
  for (const row of result.rows) {
    if (!map.has(row.user_id)) map.set(row.user_id, { ...DEFAULT_CHANNELS });
    map.get(row.user_id)[row.channel] = row.enabled;
  }
  return map;
}

function resolveChannels(channels, severity) {
  const result = { ...channels };
  if (severity === 'critical') result.inapp = true;
  const external = ['email', 'sms', 'push'].filter((channel) => result[channel]);
  if (severity === 'critical' && external.length === 0) {
    result.email = true;
  } else if (severity !== 'critical' && external.length === 0) {
    result.email = true;
  }
  return result;
}

export async function enqueueNotification({
  client = null,
  userId,
  type,
  title,
  message,
  link = null,
  bookingId = null,
  moduleId = null,
  severity = 'info',
  eventType = null,
  audience = null,
  canSeeLink = false,
  preferences = null
}) {
  const db = runner(client);
  const prefEvent = eventType || type;
  const channels = resolveChannels(
    preferences || DEFAULT_CHANNELS,
    severity
  );
  const notification = await db.query(
    `INSERT INTO notifications (user_id, booking_id, module_id, type, title, message, link, severity, is_read)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9)
     RETURNING *`,
    [userId, bookingId, moduleId, type, title, message, link, severity, false]
  );
  const row = notification.rows[0];
  const inappDelivered = channels.inapp;
  await db.query(
    `INSERT INTO notification_deliveries (notification_id, user_id, channel, status, provider_response, attempts)
     VALUES ($1,$2,'inapp',$3,$4,1)`,
    [row.id, userId, inappDelivered ? 'sent' : 'skipped', inappDelivered ? 'in-app delivery' : 'disabled by user preference']
  );
  for (const channel of ['email', 'sms', 'push']) {
    if (!channels[channel]) continue;
    await db.query(
      `INSERT INTO notification_queue (notification_id, user_id, channel, payload)
       VALUES ($1,$2,$3,$4::jsonb)`,
      [
        row.id,
        userId,
        channel,
        JSON.stringify({
          booking_id: bookingId,
          event_type: prefEvent,
          audience,
          can_see_link: Boolean(canSeeLink),
          severity
        })
      ]
    );
  }
  if (!channels.inapp) {
    await db.query(`UPDATE notifications SET is_read = true WHERE id = $1`, [row.id]);
  }
  return row;
}

export async function notifyUser(payload) {
  const db = runner(payload.client);
  const eventType = payload.eventType || payload.type;
  const prefs = await getPreferences(db, [payload.userId], eventType);
  const row = await enqueueNotification({
    ...payload,
    eventType,
    preferences: prefs.get(payload.userId) || { ...DEFAULT_CHANNELS }
  });
  if (!payload.client) kickQueue();
  return row;
}

export async function notifyAdmins({ departmentId = null, includeSuper = true, ...payload }) {
  const conditions = [];
  const params = [];
  if (departmentId) {
    params.push(departmentId);
    conditions.push(`(role = 'department_admin' AND department_id = $${params.length})`);
  }
  if (includeSuper) conditions.push(`role = 'super_admin'`);
  if (!conditions.length) return [];
  const result = await query(
    `SELECT id FROM users WHERE is_active = true AND (${conditions.join(' OR ')})`,
    params
  );
  const created = [];
  for (const row of result.rows) {
    created.push(await notifyUser({ ...payload, userId: row.id, eventType: payload.eventType || payload.type }));
  }
  return created;
}

async function getRecipients(db, booking, semesterId) {
  const recipients = new Map();
  if (booking.module_id) {
    const result = await db.query(
      `SELECT DISTINCT u.id, u.name, u.email, u.phone, u.role, u.study_mode, u.sms_link_opt_in,
              COALESCE(e.delivery_mode_override, u.study_mode) AS effective_mode
       FROM enrolments e
       JOIN users u ON u.id = e.user_id
       WHERE e.module_id = $1 AND e.semester_id = $2 AND u.is_active = true`,
      [booking.module_id, semesterId]
    );
    for (const row of result.rows) recipients.set(row.id, row);
  }
  const staffIds = [booking.user_id, booking.lecturer_id].filter(Boolean);
  if (staffIds.length) {
    const staff = await db.query(
      `SELECT id, name, email, phone, role, study_mode, sms_link_opt_in, study_mode AS effective_mode
       FROM users WHERE id = ANY($1::uuid[]) AND is_active = true`,
      [staffIds]
    );
    for (const row of staff.rows) {
      recipients.set(row.id, row);
    }
  }
  return [...recipients.values()];
}

export async function notifySessionEvent({
  bookingId,
  event,
  oldBookingId = null,
  changes = {},
  reason = '',
  client = null,
  reminderKind = '1h'
}) {
  const db = runner(client);
  const booking = await loadBooking(db, bookingId);
  if (!booking) return { notified: 0, skipped: 0 };
  const oldBooking = oldBookingId ? await loadBooking(db, oldBookingId) : null;
  const settings = await getSettings([
    'notify_online_students_physical',
    'allow_join_recording',
    'app_name'
  ]);
  const semester = await db.query(
    `SELECT id FROM semesters
     WHERE start_date <= ($1::timestamptz AT TIME ZONE $2)::date
       AND end_date >= ($1::timestamptz AT TIME ZONE $2)::date
     ORDER BY is_current DESC, start_date DESC LIMIT 1`,
    [booking.start_at, config.timezone]
  );
  let semesterId = semester.rows[0]?.id || null;
  if (!semesterId) {
    const current = await db.query(`SELECT id FROM semesters WHERE is_current = true LIMIT 1`);
    semesterId = current.rows[0]?.id || null;
  }
  if (!semesterId) return { notified: 0, skipped: 0 };
  const recipients = await getRecipients(db, booking, semesterId);
  const eventType = EVENT_TYPE_BY_EVENT[event] || 'session_updated';
  const prefMap = await getPreferences(db, recipients.map((recipient) => recipient.id), eventType);
  const roomUrl = booking.facility_id ? `/room.html?id=${booking.facility_id}` : null;
  const joinUrl = `/lectures.html?join=${booking.id}`;
  let notified = 0;
  let skipped = 0;
  for (const recipient of recipients) {
    const staff = recipient.id === booking.user_id || recipient.id === booking.lecturer_id;
    const message = composeSessionMessage({
      event,
      sessionMode: booking.session_mode,
      recipientKind: staff ? 'staff' : 'student',
      recipientMode: recipient.effective_mode || recipient.study_mode || 'physical',
      moduleCode: booking.module_code,
      moduleName: booking.module_name,
      timeText: rangeText(booking),
      roomText: roomText(booking),
      oldTimeText: oldBooking ? rangeText(oldBooking) : null,
      oldRoomText: oldBooking ? roomText(oldBooking) : null,
      platform: booking.online_platform,
      oldPlatform: oldBooking?.online_platform,
      roomUrl,
      joinUrl,
      onlineLinkChanged: Boolean(changes.linkChanged),
      notifyOnlinePhysical: settings.notify_online_students_physical !== false,
      reminderKind,
      reason
    });
    if (!message) {
      skipped += 1;
      continue;
    }
    if (event === 'cancelled') {
      message.link = '/lectures.html';
      message.canSeeLink = false;
    }
    await enqueueNotification({
      client,
      userId: recipient.id,
      type: event === 'reminder' ? 'session_reminder' : event === 'displaced' ? 'session_displaced' : eventType,
      eventType,
      title: message.title,
      message: message.message,
      link: message.link,
      bookingId: booking.id,
      moduleId: booking.module_id,
      severity: message.severity,
      audience: message.audience,
      canSeeLink: message.canSeeLink,
      preferences: prefMap.get(recipient.id) || { ...DEFAULT_CHANNELS }
    });
    notified += 1;
  }
  if (!client) kickQueue();
  return { notified, skipped, recipients: recipients.length };
}

export async function notifyBookingOwner(bookingId, event, { title, message, severity = 'info', client = null } = {}) {
  const db = runner(client);
  const booking = await loadBooking(db, bookingId);
  if (!booking) return null;
  return enqueueNotification({
    client,
    userId: booking.user_id,
    type: event,
    eventType: event,
    title: title || `Booking ${event}`,
    message:
      message ||
      `${booking.facility_name || 'Online session'}: ${rangeText(booking)}.`,
    link: booking.facility_id ? `/room.html?id=${booking.facility_id}` : '/lectures.html',
    bookingId: booking.id,
    moduleId: booking.module_id,
    severity,
    audience: 'staff',
    canSeeLink: false
  });
}

export async function notifyDisplacedUser(displacedBooking, newBooking, reason, client) {
  const message = composeDisplacementMessage({
    moduleCode: newBooking.module_code,
    moduleName: newBooking.module_name,
    timeText: rangeText(newBooking),
    roomText: roomText(newBooking),
    reason
  });
  return enqueueNotification({
    client,
    userId: displacedBooking.user_id,
    type: 'session_displaced',
    eventType: 'session_displaced',
    title: message.title,
    message: message.message,
    link: '/bookings.html',
    bookingId: displacedBooking.id,
    moduleId: displacedBooking.module_id,
    severity: 'critical',
    audience: 'staff',
    canSeeLink: false
  });
}

export async function notifyStudyModeDecision({ userId, approved, mode, note, client = null }) {
  return enqueueNotification({
    client,
    userId,
    type: 'study_mode_decision',
    eventType: 'study_mode',
    title: approved ? 'Study mode change approved' : 'Study mode change declined',
    message: approved
      ? `Your study mode is now ${mode}. Future lecture notifications and My lectures will follow your new mode.`
      : `Your study mode change request was declined. ${note || ''}`.trim(),
    link: '/settings.html',
    severity: 'info',
    audience: 'staff',
    canSeeLink: false
  });
}

export async function notifyAccountSecurity({ userId, title, message, severity = 'warning', client = null }) {
  return enqueueNotification({
    client,
    userId,
    type: 'security',
    eventType: 'security',
    title,
    message,
    link: '/settings.html',
    severity,
    audience: 'staff',
    canSeeLink: false
  });
}

export async function sendReminders() {
  const settings = await getSettings([
    'reminder_1_minutes',
    'reminder_2_minutes',
    'enable_10min_reminder'
  ]);
  const now = new Date();
  const firstWindowEnd = new Date(now.getTime() + Number(settings.reminder_1_minutes) * 60_000);
  const first = await query(
    `SELECT id FROM bookings
     WHERE status = 'confirmed'
       AND reminder_1h_sent = false
       AND start_at > now()
       AND start_at <= $1
     ORDER BY start_at`,
    [firstWindowEnd]
  );
  let sent = 0;
  for (const row of first.rows) {
    const marked = await query(
      `UPDATE bookings SET reminder_1h_sent = true WHERE id = $1 AND reminder_1h_sent = false RETURNING id`,
      [row.id]
    );
    if (marked.rows.length) {
      await notifySessionEvent({ bookingId: row.id, event: 'reminder', reminderKind: '1h' });
      sent += 1;
    }
  }
  let sentSecond = 0;
  if (settings.enable_10min_reminder) {
    const secondWindowEnd = new Date(now.getTime() + Number(settings.reminder_2_minutes) * 60_000);
    const second = await query(
      `SELECT id FROM bookings
       WHERE status = 'confirmed'
         AND session_mode IN ('online','hybrid')
         AND reminder_10m_sent = false
         AND start_at > now()
         AND start_at <= $1
       ORDER BY start_at`,
      [secondWindowEnd]
    );
    for (const row of second.rows) {
      const marked = await query(
        `UPDATE bookings SET reminder_10m_sent = true WHERE id = $1 AND reminder_10m_sent = false RETURNING id`,
        [row.id]
      );
      if (marked.rows.length) {
        await notifySessionEvent({ bookingId: row.id, event: 'reminder', reminderKind: '10m' });
        sentSecond += 1;
      }
    }
  }
  kickQueue();
  return { first_reminders: sent, second_reminders: sentSecond };
}
