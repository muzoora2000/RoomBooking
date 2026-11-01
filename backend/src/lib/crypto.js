import crypto from 'node:crypto';
import { config } from '../config.js';

export function randomToken(bytes = 32) {
  return crypto.randomBytes(bytes).toString('base64url');
}

export function sha256Hex(value) {
  return crypto.createHash('sha256').update(String(value)).digest('hex');
}

export function hashQrToken(token) {
  return sha256Hex(token);
}

export function hashOtp(code) {
  return crypto.createHmac('sha256', config.otpPepper).update(String(code)).digest('hex');
}

export function hashDeviceId(deviceId) {
  return sha256Hex(`device:${deviceId}`);
}

export function constantTimeEqual(a, b) {
  const left = Buffer.from(String(a));
  const right = Buffer.from(String(b));
  if (left.length !== right.length) return false;
  return crypto.timingSafeEqual(left, right);
}

export function hmacSha256(value, secret) {
  return crypto.createHmac('sha256', secret).update(String(value)).digest();
}

export function hmacBase64Url(value, secret, length = 32) {
  return crypto.createHmac('sha256', secret).update(String(value)).digest('base64url').slice(0, length);
}

const BASE32_ALPHABET = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';

export function base32Encode(buffer) {
  let bits = 0;
  let value = 0;
  let output = '';
  for (const byte of buffer) {
    value = (value << 8) | byte;
    bits += 8;
    while (bits >= 5) {
      output += BASE32_ALPHABET[(value >>> (bits - 5)) & 31];
      bits -= 5;
    }
  }
  if (bits > 0) output += BASE32_ALPHABET[(value << (5 - bits)) & 31];
  return output;
}

export function base32Decode(value) {
  const clean = String(value).toUpperCase().replace(/=+$/g, '').replace(/\s+/g, '');
  let bits = 0;
  let current = 0;
  const bytes = [];
  for (const char of clean) {
    const index = BASE32_ALPHABET.indexOf(char);
    if (index === -1) throw new Error('Invalid base32 secret');
    current = (current << 5) | index;
    bits += 5;
    if (bits >= 8) {
      bytes.push((current >>> (bits - 8)) & 0xff);
      bits -= 8;
    }
  }
  return Buffer.from(bytes);
}

export function randomBase32Secret(bytes = 20) {
  return base32Encode(crypto.randomBytes(bytes));
}

export function totpCode(secretBase32, timestamp = Date.now(), periodSeconds = 30, digits = 6) {
  const counter = Math.floor(timestamp / 1000 / periodSeconds);
  const buffer = Buffer.alloc(8);
  buffer.writeUInt32BE(Math.floor(counter / 0x100000000), 0);
  buffer.writeUInt32BE(counter % 0x100000000, 4);
  const digest = crypto.createHmac('sha1', base32Decode(secretBase32)).update(buffer).digest();
  const offset = digest[digest.length - 1] & 0x0f;
  const binary =
    ((digest[offset] & 0x7f) << 24) |
    ((digest[offset + 1] & 0xff) << 16) |
    ((digest[offset + 2] & 0xff) << 8) |
    (digest[offset + 3] & 0xff);
  return String(binary % 10 ** digits).padStart(digits, '0');
}

export function totpRemainingSeconds(timestamp = Date.now(), periodSeconds = 30) {
  return periodSeconds - (Math.floor(timestamp / 1000) % periodSeconds);
}

export function verifyTotp(secretBase32, code, { window = 1, periodSeconds = 30 } = {}) {
  const clean = String(code || '').replace(/\s+/g, '');
  if (!/^\d{6}$/.test(clean)) return false;
  const now = Date.now();
  for (let offset = -window; offset <= window; offset += 1) {
    if (constantTimeEqual(totpCode(secretBase32, now + offset * periodSeconds * 1000, periodSeconds), clean)) {
      return true;
    }
  }
  return false;
}

export function maskEmail(email) {
  if (!email) return '';
  const [local, domain] = String(email).split('@');
  if (!domain) return '***';
  const visible = local.slice(0, 2);
  return `${visible}${'*'.repeat(Math.max(2, local.length - 2))}@${domain}`;
}

export function maskPhone(phone) {
  if (!phone) return '';
  const value = String(phone);
  return `${value.slice(0, 4)}${'*'.repeat(Math.max(2, value.length - 6))}${value.slice(-2)}`;
}

export function normalizeUgandaPhone(phone) {
  if (!phone) return null;
  const digits = String(phone).replace(/[^\d+]/g, '');
  if (/^\+256\d{9}$/.test(digits)) return digits;
  if (/^256\d{9}$/.test(digits)) return `+${digits}`;
  if (/^0\d{9}$/.test(digits)) return `+256${digits.slice(1)}`;
  return null;
}

export function safeJsonParse(value, fallback = null) {
  try {
    return JSON.parse(value);
  } catch {
    return fallback;
  }
}
