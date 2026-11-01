import crypto from 'node:crypto';
import QRCode from 'qrcode';
import { config } from '../config.js';
import { query } from '../db/pool.js';
import { constantTimeEqual, hmacBase64Url, randomToken, sha256Hex, totpCode, totpRemainingSeconds, verifyTotp } from '../lib/crypto.js';
import { notFound, badRequest } from '../lib/errors.js';

export function buildRoomQrUrl(facility) {
  const data = `${facility.id}${facility.qr_version}`;
  const secret = `${config.qrSigningSecret}${facility.qr_secret}`;
  const signature = hmacBase64Url(data, secret, 24);
  return `${config.primaryFrontendUrl}/room.html?f=${encodeURIComponent(facility.id)}&v=${facility.qr_version}&s=${encodeURIComponent(signature)}`;
}

export function verifyRoomSignature(facility, version, signature) {
  if (!facility || !signature) return false;
  if (Number(version) !== Number(facility.qr_version)) return false;
  const data = `${facility.id}${facility.qr_version}`;
  const secret = `${config.qrSigningSecret}${facility.qr_secret}`;
  const expected = hmacBase64Url(data, secret, 24);
  return constantTimeEqual(expected, signature);
}

export function signDoorToken(facilityId, seconds = 60) {
  const payload = Buffer.from(
    JSON.stringify({ f: facilityId, exp: Math.floor(Date.now() / 1000) + seconds, jti: randomToken(8) })
  ).toString('base64url');
  const signature = hmacBase64Url(payload, config.doorTokenSecret, 48);
  return `${payload}.${signature}`;
}

export function verifyDoorToken(token, expectedFacilityId) {
  if (typeof token !== 'string' || !token.includes('.')) return { valid: false, reason: 'malformed' };
  const [payload, signature] = token.split('.');
  const expected = hmacBase64Url(payload, config.doorTokenSecret, 48);
  if (!constantTimeEqual(expected, signature)) return { valid: false, reason: 'signature' };
  let parsed;
  try {
    parsed = JSON.parse(Buffer.from(payload, 'base64url').toString('utf8'));
  } catch {
    return { valid: false, reason: 'payload' };
  }
  if (parsed.f !== expectedFacilityId) return { valid: false, reason: 'facility_mismatch' };
  if (!parsed.exp || parsed.exp < Math.floor(Date.now() / 1000)) return { valid: false, reason: 'expired' };
  return { valid: true, payload: parsed };
}

export async function issuePersonalQr(user) {
  const code = totpCode(user.qr_secret);
  return {
    handle: user.qr_handle,
    code,
    step_seconds: 30,
    expires_in: totpRemainingSeconds(),
    content: JSON.stringify({ h: user.qr_handle, c: code })
  };
}

export async function verifyPersonalQr(handle, code) {
  const result = await query(
    `SELECT id, id_number, name, email, phone, role, department_id, class_id, study_mode,
            qr_active, is_active, locked_until, qr_secret, last_verified_at
     FROM users WHERE qr_handle = $1`,
    [handle]
  );
  const user = result.rows[0];
  if (!user) return { ok: false, reason: 'not_found' };
  if (!user.is_active) return { ok: false, reason: 'inactive' };
  if (!user.qr_active) return { ok: false, reason: 'qr_inactive' };
  if (user.locked_until && new Date(user.locked_until) > new Date()) return { ok: false, reason: 'locked' };
  if (!verifyTotp(user.qr_secret, code, { window: 1 })) return { ok: false, reason: 'expired' };
  return { ok: true, user };
}

export async function issueIdQr(userId, req) {
  const rawToken = randomToken(32);
  const handle = `h-${randomToken(9).toLowerCase().replace(/[^a-z0-9]/g, '').slice(0, 12)}`;
  const result = await query(
    `UPDATE users SET qr_token_hash = $2, qr_handle = COALESCE(qr_handle, $3), qr_active = true, updated_at = now()
     WHERE id = $1
     RETURNING id, id_number, name, email, role, qr_handle`,
    [userId, sha256Hex(rawToken), handle]
  );
  if (!result.rows.length) throw notFound('User not found');
  return { user: result.rows[0], token: rawToken, qr_content: rawToken };
}

export async function deactivateIdQr(userId) {
  const result = await query(
    `UPDATE users SET qr_active = false, updated_at = now() WHERE id = $1
     RETURNING id, id_number, name, qr_active`,
    [userId]
  );
  if (!result.rows.length) throw notFound('User not found');
  return result.rows[0];
}

export async function issueActivationQrContent(user) {
  return user.qr_handle;
}

export async function generateQrDataUrl(text, options = {}) {
  return QRCode.toDataURL(text, {
    errorCorrectionLevel: 'M',
    margin: 2,
    width: options.width || 512,
    color: { dark: '#102030', light: '#ffffff' }
  });
}

export async function generateQrBuffer(text, options = {}) {
  return QRCode.toBuffer(text, {
    errorCorrectionLevel: 'M',
    margin: 2,
    width: options.width || 512,
    type: 'png'
  });
}

export function escapeHtml(value) {
  return String(value ?? '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#39;');
}

export function shortRoomCode(facility) {
  return `ROOM-${String(facility.id).slice(0, 6).toUpperCase()}-${facility.qr_version}`;
}

export async function buildRoomQrSheetHtml(facilities, title = 'Room QR codes') {
  const cards = [];
  for (const facility of facilities) {
    const url = buildRoomQrUrl(facility);
    const dataUrl = await generateQrDataUrl(url, { width: 420 });
    cards.push(`
      <article class="card">
        <div class="room">${escapeHtml(facility.name)}</div>
        <div class="meta">${escapeHtml(facility.building)} &middot; Floor ${escapeHtml(facility.floor)} &middot; Room ${escapeHtml(
          facility.room_number
        )}</div>
        <img src="${dataUrl}" alt="QR code for ${escapeHtml(facility.name)}" />
        <div class="code">${escapeHtml(shortRoomCode(facility))}</div>
        <div class="hint">Scan to view, book, check in or navigate. The code identifies the room only.</div>
      </article>`);
  }
  return `<!doctype html><html lang="en"><head><meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>${escapeHtml(title)}</title>
  <style>
    body{font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;margin:24px;color:#13212e;background:#fff}
    h1{font-size:22px;margin:0 0 16px}
    .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(250px,1fr));gap:16px}
    .card{border:1px solid #b9c6d2;border-radius:14px;padding:16px;text-align:center;break-inside:avoid}
    .room{font-size:18px;font-weight:700}
    .meta{font-size:12px;color:#4a5a68;margin-top:4px}
    img{width:220px;height:220px;margin:10px auto;display:block}
    .code{font-family:ui-monospace,Consolas,monospace;font-size:14px;font-weight:700;letter-spacing:1px}
    .hint{font-size:11px;color:#5b6874;margin-top:6px;line-height:1.35}
    @media print{body{margin:10mm}.card{border-color:#8b9aa8}}
  </style></head><body><h1>${escapeHtml(title)}</h1><div class="grid">${cards.join('')}</div>
  <script>window.addEventListener('load',()=>{setTimeout(()=>window.print(),600)})</script>
  </body></html>`;
}

export async function buildIdCardHtml(users) {
  const cards = [];
  for (const user of users) {
    const content = user.print_token || user.qr_handle;
    const dataUrl = await generateQrDataUrl(content, { width: 380 });
    cards.push(`
      <article class="card">
        <div class="brand">Campus ID</div>
        <div class="name">${escapeHtml(user.name)}</div>
        <div class="idno">${escapeHtml(user.id_number)}</div>
        <img src="${dataUrl}" alt="ID QR for ${escapeHtml(user.name)}" />
        <div class="role">${escapeHtml(user.role.replace(/_/g, ' '))}</div>
        <div class="hint">The QR is an opaque token. It never contains your role or permissions.</div>
      </article>`);
  }
  return `<!doctype html><html lang="en"><head><meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Campus ID cards</title>
  <style>
    body{font-family:system-ui,-apple-system,Segoe UI,Roboto,sans-serif;margin:24px;color:#102030;background:#fff}
    .grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(245px,1fr));gap:16px}
    .card{border:1px solid #a9b8c6;border-radius:16px;padding:16px;text-align:center;break-inside:avoid}
    .brand{font-size:11px;text-transform:uppercase;letter-spacing:2px;color:#32526e}
    .name{font-size:18px;font-weight:700;margin-top:6px}
    .idno{font-family:ui-monospace,Consolas,monospace;font-size:14px;margin-top:2px}
    img{width:190px;height:190px;margin:10px auto;display:block}
    .role{font-size:12px;text-transform:uppercase;letter-spacing:1px;color:#455b6e}
    .hint{font-size:10px;color:#64748b;margin-top:6px}
    @media print{body{margin:10mm}}
  </style></head><body><div class="grid">${cards.join('')}</div>
  <script>window.addEventListener('load',()=>{setTimeout(()=>window.print(),600)})</script>
  </body></html>`;
}

export function buildPersonalQrContent(user) {
  return `campus-personal:${user.qr_handle}:${totpCode(user.qr_secret)}`;
}

export function assertRotatingCode(user, code) {
  if (!verifyTotp(user.qr_secret, code, { window: 1 })) throw badRequest('That rotating QR code is expired. Refresh it and try again.');
  return true;
}
