import { query, withTransaction } from '../db/pool.js';
import { badRequest } from '../lib/errors.js';
import { sanitizeAuditDetails } from '../lib/audit.js';

export const SETTING_DEFAULTS = {
  max_booking_hours_per_day: 4,
  max_booking_hours_per_week: 12,
  max_advance_booking_days: 30,
  max_booking_duration_minutes: 240,
  min_notice_minutes: 15,
  no_show_suspension_threshold: 3,
  no_show_suspension_days: 7,
  no_show_lookback_days: 30,
  cancellation_cutoff_minutes: 0,
  no_show_grace_minutes: 15,
  checkin_open_minutes: 10,
  max_checkin_accuracy_m: 150,
  reminder_1_minutes: 60,
  reminder_2_minutes: 10,
  enable_10min_reminder: true,
  allow_join_recording: true,
  notify_online_students_physical: true,
  allowed_meeting_domains: ['zoom.us', 'meet.google.com', 'teams.microsoft.com'],
  default_checkin_radius_m: 100,
  rotating_qr_required_roles: ['lecturer', 'class_rep', 'deputy_rep'],
  join_retention_days: 365,
  delivery_log_retention_days: 365,
  otp_retention_days: 7,
  graduated_anonymize_days: 0,
  app_name: 'Campus Navigation and Facility Booking',
  timetable_no_show_exempt: true,
  lecturer_no_show_exempt: false,
  lecture_room_no_show_exempt: false,
  email_provider: 'resend'
};

const NUMERIC_SETTINGS = new Set([
  'max_booking_hours_per_day',
  'max_booking_hours_per_week',
  'max_advance_booking_days',
  'max_booking_duration_minutes',
  'min_notice_minutes',
  'no_show_suspension_threshold',
  'no_show_suspension_days',
  'no_show_lookback_days',
  'cancellation_cutoff_minutes',
  'no_show_grace_minutes',
  'checkin_open_minutes',
  'max_checkin_accuracy_m',
  'reminder_1_minutes',
  'reminder_2_minutes',
  'default_checkin_radius_m',
  'join_retention_days',
  'delivery_log_retention_days',
  'otp_retention_days',
  'graduated_anonymize_days'
]);

const BOOLEAN_SETTINGS = new Set([
  'enable_10min_reminder',
  'allow_join_recording',
  'notify_online_students_physical',
  'timetable_no_show_exempt',
  'lecturer_no_show_exempt',
  'lecture_room_no_show_exempt'
]);

export async function getSettings(keys = Object.keys(SETTING_DEFAULTS)) {
  const defaults = {};
  for (const key of keys) defaults[key] = SETTING_DEFAULTS[key];
  if (keys.length === 0) return defaults;
  const result = await query('SELECT key, value FROM settings WHERE key = ANY($1::text[])', [keys]);
  for (const row of result.rows) defaults[row.key] = row.value;
  return defaults;
}

export async function getSetting(key) {
  if (!(key in SETTING_DEFAULTS)) throw badRequest(`Unknown setting: ${key}`);
  const result = await query('SELECT value FROM settings WHERE key = $1', [key]);
  return result.rows.length ? result.rows[0].value : SETTING_DEFAULTS[key];
}

export async function getPublicSettings() {
  const values = await getSettings(['app_name', 'allowed_meeting_domains', 'notify_online_students_physical']);
  return {
    app_name: values.app_name,
    allowed_meeting_domains: values.allowed_meeting_domains
  };
}

export function validateSettingValue(key, value) {
  if (!(key in SETTING_DEFAULTS)) throw badRequest(`Unknown setting: ${key}`);
  if (NUMERIC_SETTINGS.has(key)) {
    const numeric = Number(value);
    if (!Number.isFinite(numeric) || numeric < 0) throw badRequest(`${key} must be a non-negative number`);
    return numeric;
  }
  if (BOOLEAN_SETTINGS.has(key)) {
    if (typeof value === 'boolean') return value;
    if (value === 'true' || value === 'false') return value === 'true';
    throw badRequest(`${key} must be true or false`);
  }
  if (key === 'allowed_meeting_domains') {
    if (!Array.isArray(value) || value.length === 0) throw badRequest('allowed_meeting_domains must be a non-empty array');
    return value.map((domain) => String(domain).trim().toLowerCase()).filter(Boolean);
  }
  if (key === 'rotating_qr_required_roles') {
    if (!Array.isArray(value)) throw badRequest('rotating_qr_required_roles must be an array');
    const allowed = new Set(['lecturer', 'class_rep', 'deputy_rep', 'student']);
    return value.filter((role) => allowed.has(role));
  }
  if (key === 'email_provider') {
    if (!['resend', 'brevo'].includes(String(value))) throw badRequest('email_provider must be resend or brevo');
    return String(value);
  }
  return value;
}

export async function updateSettings(entries, userId) {
  const keys = Object.keys(entries || {});
  if (keys.length === 0) throw badRequest('No settings supplied');
  const validated = {};
  for (const key of keys) validated[key] = validateSettingValue(key, entries[key]);
  await withTransaction(async (client) => {
    for (const [key, value] of Object.entries(validated)) {
      await client.query(
        `INSERT INTO settings (key, value, updated_by, updated_at)
         VALUES ($1, $2::jsonb, $3, now())
         ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_by = EXCLUDED.updated_by, updated_at = now()`,
        [key, JSON.stringify(value), userId]
      );
    }
  });
  return { values: validated, auditDetails: sanitizeAuditDetails(validated) };
}

export function isAllowedMeetingLink(link, allowedDomains) {
  if (typeof link !== 'string' || !/^https:\/\//i.test(link)) return false;
  let url;
  try {
    url = new URL(link);
  } catch {
    return false;
  }
  if (url.protocol !== 'https:') return false;
  const host = url.hostname.toLowerCase();
  return allowedDomains.some((domain) => {
    const clean = String(domain).toLowerCase().replace(/^\*\./, '');
    return host === clean || host.endsWith(`.${clean}`);
  });
}

export function allowedPlatformForHost(link) {
  try {
    const host = new URL(link).hostname.toLowerCase();
    if (host.endsWith('zoom.us')) return 'zoom';
    if (host === 'meet.google.com') return 'google_meet';
    if (host.endsWith('teams.microsoft.com')) return 'teams';
    return 'other';
  } catch {
    return 'other';
  }
}
