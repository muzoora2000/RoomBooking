import { api, clearSession, getToken, setToken } from './api.js';

const USER_KEY = 'campus.user';

export function getUser() {
  try {
    return JSON.parse(localStorage.getItem(USER_KEY) || 'null');
  } catch {
    return null;
  }
}

export function setUser(user) {
  if (user) localStorage.setItem(USER_KEY, JSON.stringify(user));
  else localStorage.removeItem(USER_KEY);
}

export function saveSession(result) {
  setToken(result.token);
  setUser(result.user);
  return result.user;
}

export async function refreshMe() {
  const result = await api.get('/api/auth/me');
  setUser(result.user);
  return result.user;
}

export function isLoggedIn() {
  return Boolean(getToken());
}

export function isAdmin(user = getUser()) {
  return Boolean(user && ['department_admin', 'super_admin'].includes(user.role));
}

export function canSchedule(user = getUser()) {
  return Boolean(user && ['lecturer', 'class_rep', 'deputy_rep', 'department_admin', 'super_admin'].includes(user.role));
}

export function roleLabel(role) {
  const labels = {
    student: 'Student',
    class_rep: 'Class representative',
    deputy_rep: 'Deputy class representative',
    lecturer: 'Lecturer',
    department_admin: 'Department administrator',
    super_admin: 'Super administrator'
  };
  return labels[role] || role || 'Member';
}

export function safeNext(value) {
  if (!value) return 'index.html';
  const text = String(value);
  if (/^https?:|^\/\//i.test(text) || text.includes('..')) return 'index.html';
  return text.replace(/^\//, '');
}

export function redirectToLogin() {
  const next = encodeURIComponent(location.pathname.split('/').pop() + location.search);
  location.replace(`login.html?next=${next}`);
}

export async function requireAuth() {
  if (!isLoggedIn()) {
    redirectToLogin();
    return null;
  }
  const cached = getUser();
  if (cached) return cached;
  try {
    return await refreshMe();
  } catch {
    clearSession();
    redirectToLogin();
    return null;
  }
}

export async function requireAdmin() {
  const user = await requireAuth();
  if (!user) return null;
  if (!isAdmin(user)) {
    location.replace('index.html');
    return null;
  }
  return user;
}

export async function loginWithPassword({ idNumber, password, trustDevice, deviceId }) {
  const result = await api.post('/api/auth/password', {
    id_number: idNumber,
    password,
    device_id: deviceId,
    trust_device: Boolean(trustDevice)
  }, { auth: false, retry: false });
  if (result.otp_required) return result;
  saveSession(result);
  return result;
}

export async function verifyOtp({ otpId, code, trustDevice, deviceId }) {
  const result = await api.post('/api/auth/otp/verify', {
    otp_id: otpId,
    code,
    device_id: deviceId,
    trust_device: Boolean(trustDevice)
  }, { auth: false, retry: false });
  saveSession(result);
  return result;
}

export async function verifyPin({ otpId, pin, trustDevice, deviceId }) {
  const result = await api.post('/api/auth/pin', {
    otp_id: otpId,
    pin,
    device_id: deviceId,
    trust_device: Boolean(trustDevice)
  }, { auth: false, retry: false });
  saveSession(result);
  return result;
}

export async function qrLookup({ token, deviceId }) {
  return api.post('/api/auth/qr/lookup', {
    token,
    device_id: deviceId
  }, { auth: false, retry: false });
}

export async function logout() {
  try {
    await api.post('/api/auth/logout', {}, { retry: false });
  } catch {
    clearSession();
  }
  clearSession();
  location.replace('login.html');
}

export async function ensureVerified() {
  try {
    await api.post('/api/auth/step-up/request', {}, { retry: false });
    return true;
  } catch (error) {
    if (error.status === 428) return false;
    throw error;
  }
}
