import { query } from '../db/pool.js';
import { hashDeviceId } from '../lib/crypto.js';

export function describeDevice(userAgent) {
  const ua = String(userAgent || '');
  if (/iPhone|iPad/i.test(ua)) return 'Apple mobile device';
  if (/Android/i.test(ua)) return 'Android device';
  if (/Macintosh/i.test(ua)) return 'Mac computer';
  if (/Windows/i.test(ua)) return 'Windows computer';
  if (/Linux/i.test(ua)) return 'Linux computer';
  return 'Unknown device';
}

export async function getTrustedDevice(userId, deviceId) {
  if (!deviceId) return null;
  const result = await query(
    `SELECT * FROM trusted_devices
     WHERE user_id = $1 AND device_id_hash = $2 AND revoked_at IS NULL`,
    [userId, hashDeviceId(deviceId)]
  );
  const row = result.rows[0];
  if (!row) return null;
  if (!row.trusted_until || new Date(row.trusted_until).getTime() <= Date.now()) {
    return { ...row, trusted: false };
  }
  return { ...row, trusted: true };
}

export async function isDeviceTrusted(userId, deviceId) {
  const device = await getTrustedDevice(userId, deviceId);
  return Boolean(device?.trusted);
}

export async function touchTrustedDevice(userId, deviceId, req) {
  if (!deviceId) return null;
  const existing = await getTrustedDevice(userId, deviceId);
  if (existing) {
    const updated = await query(
      `UPDATE trusted_devices SET last_used_at = now(), user_agent = $3 WHERE id = $1 AND user_id = $2 RETURNING *`,
      [existing.id, userId, req?.headers?.['user-agent']?.slice(0, 500) || null]
    );
    return updated.rows[0] || existing;
  }
  return null;
}

export async function trustDevice({ userId, deviceId, req, days = 30 }) {
  const deviceHash = hashDeviceId(deviceId);
  const trustedUntil = new Date(Date.now() + days * 24 * 60 * 60 * 1000);
  const existing = await query(
    `SELECT id FROM trusted_devices WHERE user_id = $1 AND device_id_hash = $2 AND revoked_at IS NULL`,
    [userId, deviceHash]
  );
  if (existing.rows.length) {
    const updated = await query(
      `UPDATE trusted_devices
       SET trusted_until = $3, last_used_at = now(), user_agent = $4, label = COALESCE(NULLIF(label,'Unknown device'), $5)
       WHERE id = $1 AND user_id = $2 RETURNING *`,
      [
        existing.rows[0].id,
        userId,
        trustedUntil,
        req?.headers?.['user-agent']?.slice(0, 500) || null,
        describeDevice(req?.headers?.['user-agent'])
      ]
    );
    return updated.rows[0];
  }
  const inserted = await query(
    `INSERT INTO trusted_devices (user_id, device_id_hash, label, user_agent, trusted_until)
     VALUES ($1,$2,$3,$4,$5) RETURNING *`,
    [
      userId,
      deviceHash,
      describeDevice(req?.headers?.['user-agent']),
      req?.headers?.['user-agent']?.slice(0, 500) || null,
      trustedUntil
    ]
  );
  return inserted.rows[0];
}

export async function listDevices(userId) {
  const result = await query(
    `SELECT id, label, user_agent, first_seen_at, last_used_at, trusted_until, revoked_at,
            (trusted_until IS NOT NULL AND trusted_until > now() AND revoked_at IS NULL) AS trusted
     FROM trusted_devices WHERE user_id = $1 ORDER BY last_used_at DESC`,
    [userId]
  );
  return result.rows;
}

export async function revokeDevice(userId, deviceId) {
  const result = await query(
    `UPDATE trusted_devices SET revoked_at = now()
     WHERE id = $1 AND user_id = $2 AND revoked_at IS NULL RETURNING *`,
    [deviceId, userId]
  );
  return result.rows[0] || null;
}

export async function revokeAllDevices(userId, client = null) {
  const db = client || { query };
  const result = await db.query(
    `UPDATE trusted_devices SET revoked_at = now() WHERE user_id = $1 AND revoked_at IS NULL RETURNING id`,
    [userId]
  );
  return result.rowCount;
}
