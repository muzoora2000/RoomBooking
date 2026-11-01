import crypto from 'node:crypto';
import jwt from 'jsonwebtoken';
import { config } from '../config.js';
import { query } from '../db/pool.js';
import { AppError, unauthorized } from '../lib/errors.js';

export function issueUserToken(user, sessionId) {
  return jwt.sign(
    {
      sub: user.id,
      role: user.role,
      department_id: user.department_id,
      class_id: user.class_id,
      session_id: sessionId,
      typ: 'user'
    },
    config.jwtSecret,
    { expiresIn: config.jwtExpiresIn, issuer: 'campus-navigation' }
  );
}

export async function createAuthSession(user, req, deviceIdHash = null) {
  const sessionId = crypto.randomUUID();
  const expiresAt = new Date(Date.now() + 8 * 60 * 60 * 1000);
  await query(
    `INSERT INTO auth_sessions (id, user_id, device_id_hash, ip, user_agent, expires_at)
     VALUES ($1,$2,$3,$4,$5,$6)`,
    [sessionId, user.id, deviceIdHash, req.ip || null, req.headers['user-agent']?.slice(0, 500) || null, expiresAt]
  );
  return { sessionId, token: issueUserToken(user, sessionId), expiresAt };
}

export function issueDisplayToken(displayDevice) {
  return jwt.sign(
    {
      sub: displayDevice.id,
      facility_id: displayDevice.facility_id,
      typ: 'display',
      label: displayDevice.label
    },
    config.jwtSecret,
    { expiresIn: '12h', issuer: 'campus-navigation' }
  );
}

function bearerToken(req) {
  const header = req.headers.authorization || '';
  if (!header.startsWith('Bearer ')) return null;
  return header.slice(7).trim();
}

export async function loadUser(userId) {
  const result = await query(
    `SELECT id, id_number, name, email, phone, role, department_id, class_id, study_mode,
            qr_active, is_active, last_verified_at, flagged_for_review, consent_at, sms_link_opt_in
     FROM users WHERE id = $1`,
    [userId]
  );
  return result.rows[0] || null;
}

export async function authenticate(req, res, next) {
  try {
    const token = bearerToken(req);
    if (!token) throw unauthorized();
    let payload;
    try {
      payload = jwt.verify(token, config.jwtSecret, { issuer: 'campus-navigation' });
    } catch {
      throw unauthorized('Your session has expired. Please sign in again.', 'TOKEN_INVALID');
    }
    if (payload.typ !== 'user' || !payload.session_id) throw unauthorized('Invalid session token', 'TOKEN_INVALID');
    const session = await query(
      `SELECT id, user_id, revoked_at, expires_at FROM auth_sessions WHERE id = $1`,
      [payload.session_id]
    );
    const row = session.rows[0];
    if (!row || row.revoked_at || new Date(row.expires_at).getTime() <= Date.now()) {
      throw unauthorized('This session was revoked or expired. Please sign in again.', 'SESSION_REVOKED');
    }
    const user = await loadUser(payload.sub);
    if (!user || !user.is_active) throw unauthorized('This account is inactive', 'ACCOUNT_INACTIVE');
    req.user = user;
    req.sessionId = payload.session_id;
    req.authPayload = payload;
    next();
  } catch (error) {
    next(error);
  }
}

export async function optionalAuthenticate(req, res, next) {
  const token = bearerToken(req);
  if (!token) return next();
  return authenticate(req, res, next);
}

export function requireRecentVerification(req, res, next) {
  if (!req.user) return next(unauthorized());
  const roles = ['lecturer', 'class_rep', 'deputy_rep'];
  if (!roles.includes(req.user.role)) return next();
  if (!req.user.last_verified_at) {
    return next(new AppError(428, 'STEP_UP_REQUIRED', 'Please verify with an OTP or PIN before scheduling lectures.'));
  }
  const ageMs = Date.now() - new Date(req.user.last_verified_at).getTime();
  if (ageMs > config.stepUpHours * 60 * 60 * 1000) {
    return next(
      new AppError(428, 'STEP_UP_REQUIRED', 'Your last verification is older than 8 hours. Verify again to schedule lectures.')
    );
  }
  return next();
}

export async function requireDisplay(req, res, next) {
  try {
    const token = bearerToken(req);
    if (!token) throw unauthorized('Display authentication required', 'DISPLAY_UNAUTHORIZED');
    let payload;
    try {
      payload = jwt.verify(token, config.jwtSecret, { issuer: 'campus-navigation' });
    } catch {
      throw unauthorized('Display session expired. Reconnect the display.', 'DISPLAY_TOKEN_INVALID');
    }
    if (payload.typ !== 'display' || !payload.facility_id) {
      throw unauthorized('Invalid display session', 'DISPLAY_TOKEN_INVALID');
    }
    const result = await query(
      `SELECT id, facility_id, label, revoked_at FROM display_devices WHERE id = $1`,
      [payload.sub]
    );
    const device = result.rows[0];
    if (!device || device.revoked_at) throw unauthorized('This display device was revoked', 'DISPLAY_REVOKED');
    req.display = device;
    req.displayFacilityId = payload.facility_id;
    next();
  } catch (error) {
    next(error);
  }
}

export function currentUserIsAdmin(user) {
  return user && (user.role === 'department_admin' || user.role === 'super_admin');
}
