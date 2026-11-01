import crypto from 'node:crypto';
import bcrypt from 'bcryptjs';
import { config } from '../config.js';
import { query, withTransaction } from '../db/pool.js';
import { hashOtp } from '../lib/crypto.js';
import { AppError, badRequest, unauthorized } from '../lib/errors.js';
import { auditLog } from '../lib/audit.js';
import { sendEmail } from './email.js';
import { sendSms } from './sms.js';
import { notifyAccountSecurity } from './notifications.js';

function generateCode() {
  return String(crypto.randomInt(0, 1_000_000)).padStart(6, '0');
}

export function assertAccountUsable(user) {
  if (!user) throw unauthorized('Account not found', 'ACCOUNT_NOT_FOUND');
  if (!user.is_active) throw new AppError(403, 'ACCOUNT_INACTIVE', 'This account is inactive. Contact an administrator.');
  if (user.locked_until && new Date(user.locked_until).getTime() > Date.now()) {
    throw new AppError(423, 'ACCOUNT_LOCKED', 'This account is temporarily locked after repeated failed attempts.');
  }
}

export async function createOtp(user, { purpose = 'login', req = null, channel = 'both' } = {}) {
  const code = generateCode();
  const expiresAt = new Date(Date.now() + config.otpExpiryMinutes * 60_000);
  const delivery = [];
  if (channel === 'both' || channel === 'email') {
    if (user.email) {
      const emailResult = await sendEmail({
        to: user.email,
        subject: 'Your Campus Navigation verification code',
        text: `Your verification code is ${code}. It expires in ${config.otpExpiryMinutes} minutes. If you did not request it, change your password and report the activity.`,
        html: `<p>Your verification code is <strong style="font-size:22px;letter-spacing:4px">${code}</strong>.</p><p>It expires in ${config.otpExpiryMinutes} minutes. If you did not request it, change your password and report the activity.</p>`
      });
      delivery.push({ channel: 'email', ...emailResult });
    } else {
      delivery.push({ channel: 'email', sent: false, error: 'No email address on the account.' });
    }
  }
  if ((channel === 'both' || channel === 'sms') && user.phone) {
    const smsResult = await sendSms({
      to: user.phone,
      message: `Campus Navigation code: ${code}. Expires in ${config.otpExpiryMinutes} minutes. Do not share it.`
    });
    delivery.push({ channel: 'sms', ...smsResult });
  }
  const inserted = await query(
    `INSERT INTO otp_codes (user_id, code_hash, purpose, channel, expires_at, ip)
     VALUES ($1,$2,$3,$4,$5,$6) RETURNING id, expires_at`,
    [user.id, hashOtp(code), purpose, channel === 'sms' ? 'sms' : 'email', expiresAt, req?.ip || null]
  );
  if (!config.isProduction && process.env.DEV_OTP_CONSOLE === 'true') {
    console.warn(`[dev-otp] ${user.id_number} ${purpose} code=${code} (development console only)`);
  }
  await auditLog({
    req,
    userId: user.id,
    action: 'auth.otp_requested',
    entityType: 'user',
    entityId: user.id,
    details: {
      purpose,
      channels: delivery.map((entry) => ({ channel: entry.channel, sent: entry.sent, error: entry.error || null }))
    }
  });
  return {
    otpId: inserted.rows[0].id,
    expiresAt: inserted.rows[0].expires_at,
    delivery: delivery.map((entry) => ({ channel: entry.channel, sent: entry.sent, error: entry.error || null })),
    warning: delivery.every((entry) => !entry.sent)
      ? 'No verification message could be delivered. Check that email and SMS provider keys are configured on the server, or ask an administrator to unlock or reset the account.'
      : null
  };
}

export async function recordFailedAttempt(userId, reason, req = null) {
  const result = await query(
    `UPDATE users
     SET failed_attempts = failed_attempts + 1,
         locked_until = CASE WHEN failed_attempts + 1 >= 5 THEN now() + interval '15 minutes' ELSE locked_until END,
         updated_at = now()
     WHERE id = $1
     RETURNING failed_attempts, locked_until, id_number, email`,
    [userId]
  );
  const row = result.rows[0];
  if (!row) return { locked: false };
  const locked = row.locked_until && new Date(row.locked_until).getTime() > Date.now();
  await auditLog({
    req,
    userId,
    action: 'auth.failed_attempt',
    entityType: 'user',
    entityId: userId,
    details: { reason, failed_attempts: row.failed_attempts, locked }
  });
  if (locked) {
    await notifyAccountSecurity({
      userId,
      title: 'Account temporarily locked',
      message: 'Your account was locked for 15 minutes after repeated failed verification attempts. If this was not you, report the activity from Settings.',
      severity: 'critical'
    }).catch(() => {});
  }
  return { locked, locked_until: row.locked_until };
}

export async function clearFailedAttempts(userId, { verified = false, client = null } = {}) {
  const db = client || { query };
  await db.query(
    `UPDATE users
     SET failed_attempts = 0,
         locked_until = NULL,
         last_verified_at = CASE WHEN $2 THEN now() ELSE last_verified_at END,
         updated_at = now()
     WHERE id = $1`,
    [userId, verified]
  );
}

export async function verifyOtpCode({ otpId, code, purpose = 'login', req = null }) {
  const outcome = await withTransaction(async (client) => {
    const result = await client.query(
      `SELECT o.*, u.id AS uid, u.id_number, u.name, u.email, u.phone, u.role, u.department_id, u.class_id,
              u.study_mode, u.is_active, u.locked_until, u.qr_active, u.last_verified_at
       FROM otp_codes o JOIN users u ON u.id = o.user_id
       WHERE o.id = $1 FOR UPDATE OF o`,
      [otpId]
    );
    const row = result.rows[0];
    if (!row) throw badRequest('That verification request was not found. Start again.', undefined, 'OTP_NOT_FOUND');
    if (row.purpose !== purpose) throw badRequest('This code is not valid for that action.', undefined, 'OTP_PURPOSE');
    if (row.consumed_at) throw badRequest('That code was already used. Request a new one.', undefined, 'OTP_USED');
    if (new Date(row.expires_at).getTime() <= Date.now()) {
      throw new AppError(410, 'OTP_EXPIRED', 'That code has expired. Request a new one.');
    }
    assertAccountUsable(row);
    if (row.attempts >= row.max_attempts) {
      throw new AppError(429, 'OTP_ATTEMPTS', 'Too many incorrect attempts for this code. Request a new one.');
    }
    const matches = hashOtp(code) === row.code_hash;
    if (!matches) {
      await client.query('UPDATE otp_codes SET attempts = attempts + 1 WHERE id = $1', [otpId]);
      return {
        wrong: true,
        userId: row.uid,
        attemptsRemaining: Math.max(0, row.max_attempts - row.attempts - 1)
      };
    }
    await client.query('UPDATE otp_codes SET consumed_at = now() WHERE id = $1', [otpId]);
    await client.query(
      `UPDATE users SET failed_attempts = 0, locked_until = NULL, last_verified_at = now(), updated_at = now()
       WHERE id = $1`,
      [row.uid]
    );
    await auditLog({
      req,
      userId: row.uid,
      action: 'auth.otp_verified',
      entityType: 'user',
      entityId: row.uid,
      details: { purpose }
    });
    return {
      wrong: false,
      user: {
        id: row.uid,
        id_number: row.id_number,
        name: row.name,
        email: row.email,
        phone: row.phone,
        role: row.role,
        department_id: row.department_id,
        class_id: row.class_id,
        study_mode: row.study_mode,
        qr_active: row.qr_active,
        is_active: row.is_active
      }
    };
  });
  if (outcome.wrong) {
    await recordFailedAttempt(outcome.userId, 'wrong_otp', req);
    throw new AppError(401, 'OTP_INVALID', 'That code is not correct.', {
      attempts_remaining: outcome.attemptsRemaining
    });
  }
  return outcome.user;
}

export async function verifyUserPin(user, pin, req = null) {
  if (!user.pin_hash) throw badRequest('No PIN is set for this account. Use the emailed one-time code.', undefined, 'PIN_NOT_SET');
  if (user.locked_until && new Date(user.locked_until).getTime() > Date.now()) {
    throw new AppError(423, 'ACCOUNT_LOCKED', 'This account is temporarily locked.');
  }
  if (!/^\d{4,6}$/.test(String(pin || ''))) {
    await recordFailedAttempt(user.id, 'pin_format', req);
    throw unauthorized('PIN must be 4 to 6 digits.', 'PIN_INVALID');
  }
  const matches = await bcrypt.compare(String(pin), user.pin_hash);
  if (!matches) {
    await recordFailedAttempt(user.id, 'wrong_pin', req);
    throw unauthorized('That PIN is not correct.', 'PIN_INVALID');
  }
  await query(
    `UPDATE users SET failed_attempts = 0, locked_until = NULL, last_verified_at = now(), updated_at = now() WHERE id = $1`,
    [user.id]
  );
  await auditLog({ req, userId: user.id, action: 'auth.pin_verified', entityType: 'user', entityId: user.id });
  return true;
}

export async function consumeChallenge(otpId) {
  await query(`UPDATE otp_codes SET consumed_at = now() WHERE id = $1 AND consumed_at IS NULL`, [otpId]);
}
