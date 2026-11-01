import { query } from '../db/pool.js';

const SENSITIVE_KEY = /(password|passcode|otp|token|secret|key_hash|api_key|private_key|online_link|qr_secret|display_key|pin_hash|password_hash)/i;
const MEETING_URL = /https:\/\/([a-z0-9-]+\.)*(zoom\.us|meet\.google\.com|teams\.microsoft\.com)\/[^\s]*/gi;

function sanitizeString(value) {
  return String(value).replace(MEETING_URL, '[meeting-link-redacted]');
}

function sanitize(value, depth = 0, seen = new WeakSet()) {
  if (depth > 6) return '[truncated]';
  if (value === null || value === undefined) return value;
  if (typeof value === 'string') return sanitizeString(value).slice(0, 4000);
  if (typeof value === 'number' || typeof value === 'boolean') return value;
  if (value instanceof Date) return value.toISOString();
  if (typeof value !== 'object') return String(value).slice(0, 4000);
  if (seen.has(value)) return '[circular]';
  seen.add(value);
  if (Array.isArray(value)) return value.slice(0, 200).map((entry) => sanitize(entry, depth + 1, seen));
  const output = {};
  for (const [key, entry] of Object.entries(value)) {
    output[key] = SENSITIVE_KEY.test(key) ? '[redacted]' : sanitize(entry, depth + 1, seen);
  }
  return output;
}

export function sanitizeAuditDetails(details) {
  return sanitize(details || {});
}

export async function auditLog({ req, userId = null, action, entityType = null, entityId = null, details = {} }) {
  try {
    await query(
      `INSERT INTO audit_log (user_id, action, entity_type, entity_id, ip, user_agent, details)
       VALUES ($1,$2,$3,$4,$5,$6,$7)`,
      [
        userId || req?.user?.id || null,
        action,
        entityType,
        entityId === null || entityId === undefined ? null : String(entityId),
        req?.ip || null,
        req?.headers?.['user-agent']?.slice(0, 500) || null,
        JSON.stringify(sanitizeAuditDetails(details))
      ]
    );
  } catch (error) {
    console.error('[audit] failed to write audit entry', action, error.message);
  }
}
