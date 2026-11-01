import bcrypt from 'bcryptjs';
import { config } from '../config.js';
import { query, withTransaction } from '../db/pool.js';
import { hashQrToken, randomToken, sha256Hex } from '../lib/crypto.js';
import { AppError, badRequest, unauthorized, notFound } from '../lib/errors.js';
import { auditLog } from '../lib/audit.js';
import { createAuthSession } from '../middleware/auth.js';
import {
  assertAccountUsable,
  consumeChallenge,
  createOtp,
  recordFailedAttempt,
  verifyOtpCode,
  verifyUserPin
} from './otp.js';
import {
  describeDevice,
  getTrustedDevice,
  isDeviceTrusted,
  revokeAllDevices,
  touchTrustedDevice,
  trustDevice
} from './device.js';
import { notifyAccountSecurity, notifyAdmins, notifySessionEvent } from './notifications.js';
import { getSettings } from './settings.js';
import { verifyPersonalQr } from './qr.js';
import { kickQueue } from './queue.js';

function publicUser(user) {
  return {
    id: user.id,
    id_number: user.id_number,
    name: user.name,
    email: user.email,
    phone: user.phone,
    role: user.role,
    department_id: user.department_id,
    class_id: user.class_id,
    study_mode: user.study_mode,
    qr_active: user.qr_active,
    is_active: user.is_active,
    last_verified_at: user.last_verified_at,
    consent_at: user.consent_at,
    sms_link_opt_in: user.sms_link_opt_in
  };
}

async function findUserByQr(token) {
  const result = await query(
    `SELECT id, id_number, name, email, phone, role, department_id, class_id, study_mode,
            qr_active, is_active, locked_until, last_verified_at, consent_at, sms_link_opt_in, password_hash, pin_hash
     FROM users WHERE qr_token_hash = $1`,
    [hashQrToken(token)]
  );
  return result.rows[0] || null;
}

export async function qrLookup({ token, deviceId, req }) {
  if (!token || String(token).length < 16) throw badRequest('That QR code is not a valid ID token.');
  if (!deviceId) throw badRequest('device_id is required for device recognition.');
  const user = await findUserByQr(token);
  if (!user) {
    await auditLog({ req, action: 'auth.qr_scan_failed', details: { reason: 'unknown_token' } });
    throw unauthorized('This ID QR is not recognised. Ask the registry to issue a new card.', 'QR_NOT_FOUND');
  }
  try {
    assertAccountUsable(user);
  } catch (error) {
    await auditLog({
      req,
      userId: user.id,
      action: 'auth.qr_scan_failed',
      entityType: 'user',
      entityId: user.id,
      details: { reason: error.code || 'unusable' }
    });
    throw error;
  }
  if (!user.qr_active) {
    await auditLog({
      req,
      userId: user.id,
      action: 'auth.qr_scan_failed',
      entityType: 'user',
      entityId: user.id,
      details: { reason: 'qr_deactivated' }
    });
    throw new AppError(403, 'QR_DEACTIVATED', 'This ID QR has been deactivated. Ask an administrator for a replacement card.');
  }
  const trusted = await getTrustedDevice(user.id, deviceId);
  const otp = await createOtp(user, { purpose: 'login', req });
  await auditLog({
    req,
    userId: user.id,
    action: 'auth.qr_scan',
    entityType: 'user',
    entityId: user.id,
    details: { new_device: !trusted?.trusted, pin_available: Boolean(user.pin_hash) }
  });
  return {
    otp_required: true,
    otp_id: otp.otpId,
    expires_at: otp.expiresAt,
    masked_email: user.email ? maskEmailSafe(user.email) : null,
    masked_phone: user.phone ? maskPhoneSafe(user.phone) : null,
    delivery: otp.delivery,
    warning: otp.warning,
    pin_available: Boolean(user.pin_hash),
    trusted_device: Boolean(trusted?.trusted),
    user: { name: user.name, role: user.role, id_number: user.id_number }
  };
}

function maskEmailSafe(email) {
  const [local, domain] = String(email).split('@');
  return `${local.slice(0, 2)}${'*'.repeat(Math.max(2, local.length - 2))}@${domain}`;
}

function maskPhoneSafe(phone) {
  const value = String(phone);
  return `${value.slice(0, 4)}${'*'.repeat(Math.max(2, value.length - 6))}${value.slice(-2)}`;
}

async function completeLogin({ user, req, deviceId, trustDeviceRequested, verified, method }) {
  const wasNewDevice = deviceId ? !(await isDeviceTrusted(user.id, deviceId)) : true;
  const session = await createAuthSession(user, req, deviceId ? sha256Hex(`device:${deviceId}`) : null);
  await query(
    `UPDATE users
     SET failed_attempts = 0,
         locked_until = NULL,
         last_verified_at = CASE WHEN $2 THEN now() ELSE last_verified_at END,
         updated_at = now()
     WHERE id = $1`,
    [user.id, verified]
  );
  if (deviceId && trustDeviceRequested) {
    await trustDevice({ userId: user.id, deviceId, req, days: config.trustDeviceDays });
  } else if (deviceId) {
    await touchTrustedDevice(user.id, deviceId, req);
  }
  await auditLog({
    req,
    userId: user.id,
    action: 'auth.login_success',
    entityType: 'user',
    entityId: user.id,
    details: { method, new_device: wasNewDevice, trusted_device_created: Boolean(deviceId && trustDeviceRequested) }
  });
  if (wasNewDevice) {
    await notifyAccountSecurity({
      userId: user.id,
      title: 'New sign-in from a new device',
      message: `A new sign-in to your account was completed from ${describeDevice(req.headers['user-agent'])} at ${new Date().toISOString()}. If this was not you, open Settings and report it immediately.`,
      severity: 'critical'
    }).catch(() => {});
  }
  const fresh = await query(
    `SELECT id, id_number, name, email, phone, role, department_id, class_id, study_mode,
            qr_active, is_active, last_verified_at, consent_at, sms_link_opt_in
     FROM users WHERE id = $1`,
    [user.id]
  );
  return {
    token: session.token,
    expires_at: session.expiresAt,
    user: publicUser(fresh.rows[0]),
    new_device: wasNewDevice,
    trusted: Boolean(deviceId && trustDeviceRequested)
  };
}

export async function loginWithPassword({ idNumber, password, deviceId, trustDeviceRequested = false, req }) {
  const result = await query(
    `SELECT id, id_number, name, email, phone, role, department_id, class_id, study_mode,
            qr_active, is_active, locked_until, last_verified_at, consent_at, sms_link_opt_in, password_hash, pin_hash
     FROM users WHERE lower(id_number) = lower($1)`,
    [String(idNumber || '').trim()]
  );
  const user = result.rows[0];
  if (!user) {
    await auditLog({ req, action: 'auth.password_login_failed', details: { reason: 'unknown_user' } });
    throw unauthorized('Invalid ID number or password.', 'LOGIN_INVALID');
  }
  assertAccountUsable(user);
  if (!user.password_hash) {
    throw new AppError(403, 'ACCOUNT_NOT_ACTIVATED', 'This account has not been activated. Use the activation link sent to your email.');
  }
  const matches = await bcrypt.compare(String(password || ''), user.password_hash);
  if (!matches) {
    await recordFailedAttempt(user.id, 'wrong_password', req);
    throw unauthorized('Invalid ID number or password.', 'LOGIN_INVALID');
  }
  if (!deviceId) throw badRequest('device_id is required.');
  const settings = await getSettings(['rotating_qr_required_roles']);
  const requiresSecondFactor = Array.isArray(settings.rotating_qr_required_roles)
    ? settings.rotating_qr_required_roles.includes(user.role)
    : false;
  const trusted = await isDeviceTrusted(user.id, deviceId);
  if (trusted && !requiresSecondFactor) {
    return completeLogin({
      user,
      req,
      deviceId,
      trustDeviceRequested: false,
      verified: false,
      method: 'password_trusted_device'
    });
  }
  const otp = await createOtp(user, { purpose: 'login', req });
  await auditLog({
    req,
    userId: user.id,
    action: 'auth.password_ok_second_factor_required',
    entityType: 'user',
    entityId: user.id,
    details: { reason: trusted ? 'policy_second_factor' : 'new_device' }
  });
  return {
    otp_required: true,
    otp_id: otp.otpId,
    expires_at: otp.expiresAt,
    masked_email: user.email ? maskEmailSafe(user.email) : null,
    masked_phone: user.phone ? maskPhoneSafe(user.phone) : null,
    delivery: otp.delivery,
    warning: otp.warning,
    pin_available: Boolean(user.pin_hash),
    trusted_device: trusted,
    reason: trusted ? 'policy_second_factor' : 'new_device',
    user: { name: user.name, role: user.role, id_number: user.id_number }
  };
}

export async function verifyLoginOtp({ otpId, code, deviceId, trustDeviceRequested = false, req }) {
  if (!deviceId) throw badRequest('device_id is required.');
  const user = await verifyOtpCode({ otpId, code, purpose: 'login', req });
  return completeLogin({ user, req, deviceId, trustDeviceRequested, verified: true, method: 'otp' });
}

async function challengeUser(otpId, purpose = 'login') {
  const result = await query(
    `SELECT o.id AS otp_id, o.expires_at, o.consumed_at, o.attempts, o.max_attempts, o.purpose,
            u.id, u.id_number, u.name, u.email, u.phone, u.role, u.department_id, u.class_id,
            u.study_mode, u.qr_active, u.is_active, u.locked_until, u.last_verified_at, u.consent_at,
            u.sms_link_opt_in, u.password_hash, u.pin_hash
     FROM otp_codes o JOIN users u ON u.id = o.user_id WHERE o.id = $1`,
    [otpId]
  );
  const row = result.rows[0];
  if (!row) throw badRequest('Verification challenge not found.', undefined, 'OTP_NOT_FOUND');
  if (row.purpose !== purpose) throw badRequest('This challenge is not valid for that action.', undefined, 'OTP_PURPOSE');
  if (row.consumed_at) throw badRequest('This challenge was already used.', undefined, 'OTP_USED');
  if (new Date(row.expires_at).getTime() <= Date.now()) throw new AppError(410, 'OTP_EXPIRED', 'This challenge expired. Start again.');
  assertAccountUsable(row);
  return row;
}

export async function verifyLoginPin({ otpId, pin, deviceId, trustDeviceRequested = false, req }) {
  if (!deviceId) throw badRequest('device_id is required.');
  const row = await challengeUser(otpId);
  await verifyUserPin(row, pin, req);
  await consumeChallenge(otpId);
  return completeLogin({ user: row, req, deviceId, trustDeviceRequested, verified: true, method: 'pin' });
}

export async function loginWithRotatingQr({ handle, code, deviceId, trustDeviceRequested = false, req }) {
  if (!deviceId) throw badRequest('device_id is required.');
  const verified = await verifyPersonalQr(handle, code);
  if (!verified.ok) {
    const existing = await query(`SELECT id FROM users WHERE qr_handle = $1`, [handle]);
    if (existing.rows.length) {
      await recordFailedAttempt(existing.rows[0].id, `rotating_${verified.reason}`, req);
    }
    await auditLog({
      req,
      action: 'auth.rotating_qr_failed',
      details: { reason: verified.reason }
    });
    throw unauthorized('That rotating QR code is expired or invalid. Refresh it and try again.', 'ROTATING_QR_INVALID');
  }
  const user = await query(
    `SELECT id, id_number, name, email, phone, role, department_id, class_id, study_mode,
            qr_active, is_active, locked_until, last_verified_at, consent_at, sms_link_opt_in, password_hash, pin_hash
     FROM users WHERE id = $1`,
    [verified.user.id]
  );
  return completeLogin({
    user: user.rows[0],
    req,
    deviceId,
    trustDeviceRequested,
    verified: true,
    method: 'rotating_qr'
  });
}

export async function requestStepUp({ user, req }) {
  const result = await query(
    `SELECT id, id_number, name, email, phone, role, department_id, class_id, study_mode,
            qr_active, is_active, locked_until, last_verified_at, consent_at, sms_link_opt_in, password_hash, pin_hash
     FROM users WHERE id = $1`,
    [user.id]
  );
  const fresh = result.rows[0];
  const otp = await createOtp(fresh, { purpose: 'step_up', req });
  return {
    otp_id: otp.otpId,
    expires_at: otp.expiresAt,
    masked_email: fresh.email ? maskEmailSafe(fresh.email) : null,
    masked_phone: fresh.phone ? maskPhoneSafe(fresh.phone) : null,
    delivery: otp.delivery,
    warning: otp.warning,
    pin_available: Boolean(fresh.pin_hash)
  };
}

export async function verifyStepUp({ user, otpId, code, pin, req }) {
  if (otpId && code) {
    const verified = await verifyOtpCode({ otpId, code, purpose: 'step_up', req });
    if (verified.id !== user.id) throw unauthorized('Verification challenge belongs to another account.', 'OTP_OWNER');
  } else if (pin) {
    const result = await query(`SELECT * FROM users WHERE id = $1`, [user.id]);
    await verifyUserPin(result.rows[0], pin, req);
  } else {
    throw badRequest('Provide either a one-time code or your PIN.');
  }
  await query(`UPDATE users SET last_verified_at = now(), updated_at = now() WHERE id = $1`, [user.id]);
  await auditLog({ req, userId: user.id, action: 'auth.step_up_verified', entityType: 'user', entityId: user.id });
  return { verified: true, last_verified_at: new Date().toISOString() };
}

export async function logout({ user, sessionId, req }) {
  await query(`UPDATE auth_sessions SET revoked_at = now(), revoked_reason = 'logout' WHERE id = $1`, [sessionId]);
  await auditLog({ req, userId: user.id, action: 'auth.logout', entityType: 'user', entityId: user.id });
  return { logged_out: true };
}

export async function activateAccount({ token, password, pin, consent, req }) {
  if (!token) throw badRequest('Activation token is required.');
  if (!consent) throw badRequest('You must accept the privacy notice to activate your account.');
  if (typeof password !== 'string' || password.length < 8 || !/[A-Za-z]/.test(password) || !/\d/.test(password)) {
    throw badRequest('Password must be at least 8 characters and include a letter and a number.');
  }
  if (!/^\d{4,6}$/.test(String(pin || ''))) throw badRequest('PIN must be 4 to 6 digits.');
  const passwordHash = await bcrypt.hash(password, 10);
  const pinHash = await bcrypt.hash(String(pin), 10);
  const user = await withTransaction(async (client) => {
    const result = await client.query(
      `SELECT t.*, u.id AS uid, u.id_number, u.name, u.email, u.role, u.department_id, u.class_id, u.study_mode
       FROM user_activation_tokens t JOIN users u ON u.id = t.user_id
       WHERE t.token_hash = $1 FOR UPDATE OF t`,
      [sha256Hex(token)]
    );
    const row = result.rows[0];
    if (!row) throw badRequest('That activation link is not valid.', undefined, 'ACTIVATION_INVALID');
    if (row.used_at) throw badRequest('That activation link was already used.', undefined, 'ACTIVATION_USED');
    if (new Date(row.expires_at).getTime() <= Date.now()) {
      throw new AppError(410, 'ACTIVATION_EXPIRED', 'That activation link expired. Ask an administrator to resend it.');
    }
    await client.query(
      `UPDATE users
       SET password_hash = $2, pin_hash = $3, email_verified_at = now(), consent_at = now(), is_active = true,
           failed_attempts = 0, locked_until = NULL, last_verified_at = now(), updated_at = now()
       WHERE id = $1`,
      [row.uid, passwordHash, pinHash]
    );
    await client.query(`UPDATE user_activation_tokens SET used_at = now() WHERE id = $1`, [row.id]);
    await auditLog({
      req,
      userId: row.uid,
      action: 'user.activated',
      entityType: 'user',
      entityId: row.uid
    });
    return {
      id: row.uid,
      id_number: row.id_number,
      name: row.name,
      email: row.email,
      role: row.role,
      department_id: row.department_id,
      class_id: row.class_id,
      study_mode: row.study_mode,
      qr_active: true,
      is_active: true,
      consent_at: new Date()
    };
  });
  const session = await createAuthSession(user, req, null);
  return {
    token: session.token,
    expires_at: session.expiresAt,
    user: publicUser(user)
  };
}

export async function forgotPassword({ email, req }) {
  const result = await query(
    `SELECT id, name, email, is_active FROM users WHERE lower(email) = lower($1)`,
    [String(email || '').trim()]
  );
  const user = result.rows[0];
  if (!user || !user.is_active) {
    await auditLog({ req, action: 'auth.password_reset_requested', details: { found: false } });
    return { message: 'If that email is registered, a password reset link has been sent.' };
  }
  const token = randomToken(32);
  const expiresAt = new Date(Date.now() + 60 * 60 * 1000);
  await query(
    `INSERT INTO password_reset_tokens (user_id, token_hash, expires_at) VALUES ($1,$2,$3)`,
    [user.id, sha256Hex(token), expiresAt]
  );
  const link = `${config.primaryFrontendUrl}/reset.html?token=${encodeURIComponent(token)}`;
  const { sendEmail } = await import('./email.js');
  const delivery = await sendEmail({
    to: user.email,
    subject: 'Reset your Campus Navigation password',
    text: `Use this link to reset your password. It expires in 60 minutes: ${link}`,
    html: `<p>Use the link below to reset your password. It expires in 60 minutes.</p><p><a href="${link}">Reset password</a></p>`
  });
  await auditLog({
    req,
    userId: user.id,
    action: 'auth.password_reset_requested',
    entityType: 'user',
    entityId: user.id,
    details: { found: true, email_delivered: delivery.sent }
  });
  if (!delivery.sent) {
    await notifyAdmins({
      type: 'system_alert',
      eventType: 'system_alert',
      title: 'Password reset email could not be sent',
      message: `A password reset was requested for ${user.id_number}, but the email provider failed: ${delivery.error}`,
      severity: 'warning'
    }).catch(() => {});
  }
  return { message: 'If that email is registered, a password reset link has been sent.' };
}

export async function resetPassword({ token, password, req }) {
  if (typeof password !== 'string' || password.length < 8 || !/[A-Za-z]/.test(password) || !/\d/.test(password)) {
    throw badRequest('Password must be at least 8 characters and include a letter and a number.');
  }
  const passwordHash = await bcrypt.hash(password, 10);
  const user = await withTransaction(async (client) => {
    const result = await client.query(
      `SELECT t.*, u.id AS uid FROM password_reset_tokens t JOIN users u ON u.id = t.user_id
       WHERE t.token_hash = $1 FOR UPDATE OF t`,
      [sha256Hex(token)]
    );
    const row = result.rows[0];
    if (!row) throw badRequest('That reset link is not valid.', undefined, 'RESET_INVALID');
    if (row.used_at) throw badRequest('That reset link was already used.', undefined, 'RESET_USED');
    if (new Date(row.expires_at).getTime() <= Date.now()) {
      throw new AppError(410, 'RESET_EXPIRED', 'That reset link expired. Request a new one.');
    }
    await client.query(`UPDATE users SET password_hash = $2, updated_at = now() WHERE id = $1`, [row.uid, passwordHash]);
    await client.query(`UPDATE password_reset_tokens SET used_at = now() WHERE id = $1`, [row.id]);
    await client.query(
      `UPDATE auth_sessions SET revoked_at = now(), revoked_reason = 'password_reset' WHERE user_id = $1 AND revoked_at IS NULL`,
      [row.uid]
    );
    await auditLog({
      req,
      userId: row.uid,
      action: 'auth.password_reset_completed',
      entityType: 'user',
      entityId: row.uid
    });
    return row.uid;
  });
  return { message: 'Password updated. Sign in with your new password.', user_id: user };
}

export async function reportMisuse({ user, bookingId, reason, req }) {
  const result = await withTransaction(async (client) => {
    const flagged = await client.query(
      `SELECT * FROM bookings WHERE id = $1 AND (user_id = $2 OR lecturer_id = $2) FOR UPDATE`,
      [bookingId, user.id]
    );
    if (!flagged.rows.length) throw notFound('That booking was not found under your identity.');
    const toCancel = await client.query(
      `SELECT * FROM bookings
       WHERE (user_id = $1 OR lecturer_id = $1)
         AND (id = $2 OR created_at >= now() - interval '24 hours')
         AND status IN ('pending','confirmed')
       ORDER BY start_at`,
      [user.id, bookingId]
    );
    for (const booking of toCancel.rows) {
      await client.query(
        `UPDATE bookings SET status = 'cancelled', displacement_reason = $2, updated_at = now() WHERE id = $1`,
        [booking.id, 'Cancelled after an identity misuse report.']
      );
      await notifySessionEvent({
        bookingId: booking.id,
        event: 'cancelled',
        reason: 'Cancelled after an identity misuse report.',
        client
      }).catch((error) => console.error('[misuse] notification failed', error.message));
    }
    await client.query(
      `UPDATE users SET qr_active = false, flagged_for_review = true,
              flagged_reason = $2, failed_attempts = 0, locked_until = NULL, updated_at = now()
       WHERE id = $1`,
      [user.id, String(reason || 'User reported misuse of their ID QR').slice(0, 1000)]
    );
    await client.query(
      `UPDATE trusted_devices SET revoked_at = now() WHERE user_id = $1 AND revoked_at IS NULL`,
      [user.id]
    );
    await client.query(
      `UPDATE auth_sessions SET revoked_at = now(), revoked_reason = 'identity_misuse_report'
       WHERE user_id = $1 AND revoked_at IS NULL`,
      [user.id]
    );
    await auditLog({
      req,
      userId: user.id,
      action: 'security.misuse_reported',
      entityType: 'booking',
      entityId: bookingId,
      details: { cancelled_bookings: toCancel.rowCount, reason: reason || null }
    });
    return { cancelled: toCancel.rowCount, flagged_booking: bookingId };
  });
  await notifyAdmins({
    departmentId: user.department_id,
    type: 'security_alert',
    eventType: 'security',
    title: 'Identity misuse reported',
    message: `${user.name} (${user.id_number}) reported misuse of their ID. Their QR is deactivated, sessions and trusted devices were revoked, and ${result.cancelled} recent booking(s) were cancelled.`,
    severity: 'critical'
  }).catch(() => {});
  kickQueue();
  return {
    message: 'Your QR has been deactivated, trusted devices and sessions revoked, and recent bookings cancelled. An administrator has been notified.',
    ...result
  };
}
