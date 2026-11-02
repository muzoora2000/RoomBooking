import { api, newDeviceId } from '../api.js';
import {
  isLoggedIn,
  loginWithPassword,
  qrLookup,
  safeNext,
  verifyOtp,
  verifyPin
} from '../auth.js';
import {
  errorMessage,
  notifyError,
  queryParams,
  scanQr,
  setButtonLoading,
  toast
} from '../ui.js';

const params = queryParams();
const next = safeNext(params.get('next'));
const deviceId = newDeviceId();

if (isLoggedIn() && !params.get('switch')) {
  location.replace(next);
}

const loginMain = document.getElementById('login-main');
const otpPanel = document.getElementById('otp-panel');
const profilePanel = document.getElementById('profile-panel');
const passwordForm = document.getElementById('password-form');
const otpForm = document.getElementById('otp-form');
const pinForm = document.getElementById('pin-form');
const loginError = document.getElementById('login-error');
const otpError = document.getElementById('otp-error');
const loginSubmit = document.getElementById('login-submit');
const otpSubmit = document.getElementById('otp-submit');
const pinSubmit = document.getElementById('pin-submit');
const step2 = document.getElementById('step-2');
const state = { otpId: null, pinAvailable: false, qrToken: null };

function setError(element, message) {
  element.textContent = message || '';
  element.classList.toggle('hidden', !message);
}

// ── Profile setup panel (faculty / programme / class) ────────────────────────

const apiBase = (() => {
  const meta = document.querySelector('meta[name="campus-api-base"]');
  return (meta && meta.content) ? meta.content.replace(/\/$/, '') : '';
})();

async function loadFaculties() {
  try {
    const res = await fetch(`${apiBase}/api/org/public/departments`);
    const data = await res.json();
    const sel = document.getElementById('setup-faculty');
    sel.innerHTML = '<option value="">— Select faculty —</option>' +
      (data.departments || []).map(d =>
        `<option value="${d.id}">${d.name}</option>`
      ).join('');
  } catch {
    document.getElementById('setup-faculty').innerHTML =
      '<option value="">Could not load faculties</option>';
  }
}

document.getElementById('setup-faculty').addEventListener('change', async (e) => {
  const deptId = e.target.value;
  const progSel = document.getElementById('setup-programme');
  const classSel = document.getElementById('setup-class');
  progSel.innerHTML = '<option value="">Loading…</option>';
  progSel.disabled = true;
  classSel.innerHTML = '<option value="">Select programme first</option>';
  classSel.disabled = true;
  if (!deptId) { progSel.innerHTML = '<option value="">Select a faculty first</option>'; return; }
  try {
    const res = await fetch(`${apiBase}/api/org/public/programmes?department_id=${encodeURIComponent(deptId)}`);
    const data = await res.json();
    progSel.innerHTML = '<option value="">— Select programme —</option>' +
      (data.programmes || []).map(p =>
        `<option value="${p.id}">${p.name}</option>`
      ).join('');
    progSel.disabled = false;
  } catch {
    progSel.innerHTML = '<option value="">Could not load programmes</option>';
  }
});

document.getElementById('setup-programme').addEventListener('change', async (e) => {
  const progId = e.target.value;
  const classSel = document.getElementById('setup-class');
  classSel.innerHTML = '<option value="">Loading…</option>';
  classSel.disabled = true;
  if (!progId) { classSel.innerHTML = '<option value="">Select a programme first</option>'; return; }
  try {
    const res = await fetch(`${apiBase}/api/org/public/classes?programme_id=${encodeURIComponent(progId)}`);
    const data = await res.json();
    classSel.innerHTML = '<option value="">— Select year/class —</option>' +
      (data.classes || []).map(c =>
        `<option value="${c.id}">Year ${c.year_of_study} — ${c.name}</option>`
      ).join('');
    classSel.disabled = false;
  } catch {
    classSel.innerHTML = '<option value="">Could not load classes</option>';
  }
});

document.getElementById('profile-setup-form').addEventListener('submit', async (e) => {
  e.preventDefault();
  const classId = document.getElementById('setup-class').value;
  const errEl = document.getElementById('profile-setup-error');
  setError(errEl, '');
  if (!classId) { setError(errEl, 'Please select your year/class.'); return; }
  const btn = document.getElementById('profile-setup-submit');
  setButtonLoading(btn, true, 'Saving…');
  try {
    await api.patch('/api/me/profile', { class_id: classId });
    location.replace(next);
  } catch (error) {
    setError(errEl, errorMessage(error));
  } finally {
    setButtonLoading(btn, false);
  }
});

document.getElementById('profile-setup-skip').addEventListener('click', () => {
  location.replace(next);
});

function showProfilePanel() {
  loginMain.classList.add('hidden');
  otpPanel.classList.add('hidden');
  profilePanel.classList.remove('hidden');
  loadFaculties();
}

function complete(result) {
  if (result.new_device) toast('New device verified. Review your sign-in activity in Settings.', 'success', 5000);
  // Always redirect after successful login — faculty/class selection is done in Settings
  location.replace(next);
}

// ── Password form ─────────────────────────────────────────────────────────────

function showOtp(challenge) {
  state.otpId = challenge.otp_id;
  state.pinAvailable = Boolean(challenge.pin_available);
  loginMain.classList.add('hidden');
  otpPanel.classList.remove('hidden');
  step2.classList.add('active');
  const delivery = challenge.delivery || {};
  const target = challenge.masked_email || challenge.masked_phone;
  let text = target
    ? `We sent a 6-digit code to ${target}.`
    : 'A 6-digit verification code was issued for your account.';
  if (delivery.warning || challenge.warning) text += ` ${delivery.warning || challenge.warning}`;
  document.getElementById('otp-delivery').textContent = text;
  pinForm.classList.toggle('hidden', !state.pinAvailable);
  setError(otpError, '');
  document.getElementById('otp-code').value = '';
  document.getElementById('pin-code').value = '';
  setTimeout(() => document.getElementById('otp-code').focus(), 50);
}

function backToPassword() {
  state.otpId = null;
  loginMain.classList.remove('hidden');
  otpPanel.classList.add('hidden');
  step2.classList.remove('active');
  setError(otpError, '');
}

passwordForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setError(loginError, '');
  const data = new FormData(passwordForm);
  const idNumber = String(data.get('id_number') || '').trim();
  const password = String(data.get('password') || '');
  if (!idNumber || !password) {
    setError(loginError, 'Enter your ID number and password.');
    return;
  }
  setButtonLoading(loginSubmit, true, 'Signing in...');
  try {
    const result = await loginWithPassword({
      idNumber,
      password,
      trustDevice: data.get('trust_device') === 'true',
      deviceId
    });
    if (result.otp_required) {
      state.qrToken = null;
      showOtp(result);
    } else {
      complete(result);
    }
  } catch (error) {
    setError(loginError, errorMessage(error));
  } finally {
    setButtonLoading(loginSubmit, false);
  }
});

otpForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setError(otpError, '');
  const code = String(new FormData(otpForm).get('code') || '').trim();
  if (!/^\d{4,8}$/.test(code)) {
    setError(otpError, 'Enter the 6-digit code or your PIN.');
    return;
  }
  const trustDevice = new FormData(otpForm).get('trust_device') === 'true';
  setButtonLoading(otpSubmit, true, 'Verifying...');
  try {
    let result;
    try {
      result = await verifyOtp({
        otpId: state.otpId,
        code,
        trustDevice,
        deviceId
      });
    } catch (otpErr) {
      if (state.pinAvailable) {
        try {
          result = await verifyPin({
            otpId: state.otpId,
            pin: code,
            trustDevice,
            deviceId
          });
        } catch {
          throw otpErr;
        }
      } else {
        throw otpErr;
      }
    }
    complete(result);
  } catch (error) {
    setError(otpError, errorMessage(error));
  } finally {
    setButtonLoading(otpSubmit, false);
  }
});

pinForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setError(otpError, '');
  const pin = String(new FormData(pinForm).get('pin') || '').trim();
  if (!/^\d{4,8}$/.test(pin)) {
    setError(otpError, 'Enter your 4 to 8 digit PIN.');
    return;
  }
  setButtonLoading(pinSubmit, true, 'Verifying...');
  try {
    const result = await verifyPin({ otpId: state.otpId, pin, trustDevice: false, deviceId });
    complete(result);
  } catch (error) {
    setError(otpError, errorMessage(error));
  } finally {
    setButtonLoading(pinSubmit, false);
  }
});

document.getElementById('back-to-password').addEventListener('click', backToPassword);

document.getElementById('resend-code').addEventListener('click', async (event) => {
  const button = event.currentTarget;
  if (!state.qrToken && !passwordForm.reportValidity()) {
    return;
  }
  setButtonLoading(button, true, 'Sending...');
  try {
    let result;
    if (state.qrToken) {
      result = await qrLookup({ token: state.qrToken, deviceId });
    } else {
      const data = new FormData(passwordForm);
      result = await loginWithPassword({
        idNumber: String(data.get('id_number') || '').trim(),
        password: String(data.get('password') || ''),
        trustDevice: false,
        deviceId
      });
    }
    if (result.otp_required) {
      showOtp(result);
      toast('A new verification code was sent.', 'success');
    } else {
      complete(result);
    }
  } catch (error) {
    setError(otpError, errorMessage(error));
  } finally {
    setButtonLoading(button, false);
  }
});

document.getElementById('toggle-password').addEventListener('click', (event) => {
  const input = document.getElementById('password');
  const showing = input.type === 'text';
  input.type = showing ? 'password' : 'text';
  event.currentTarget.textContent = showing ? 'Show' : 'Hide';
});

document.getElementById('scan-id').addEventListener('click', async () => {
  try {
    const raw = await scanQr({ title: 'Scan your student or staff ID' });
    let token = raw.trim();
    try {
      const parsed = new URL(token);
      token = parsed.searchParams.get('token') || parsed.searchParams.get('id') || token;
    } catch {
      token = raw.trim();
    }
    const result = await qrLookup({ token, deviceId });
    state.qrToken = token;
    showOtp(result);
  } catch (error) {
    if (!error.cancelled) notifyError(error);
  }
});

function showOtp(challenge) {
  state.otpId = challenge.otp_id;
  state.pinAvailable = Boolean(challenge.pin_available);
  loginMain.classList.add('hidden');
  otpPanel.classList.remove('hidden');
  step2.classList.add('active');
  const delivery = challenge.delivery || {};
  const target = challenge.masked_email || challenge.masked_phone;
  let text = target
    ? `We sent a 6-digit code to ${target}.`
    : 'A 6-digit verification code was issued for your account.';
  if (delivery.warning || challenge.warning) text += ` ${delivery.warning || challenge.warning}`;
  document.getElementById('otp-delivery').textContent = text;
  pinForm.classList.toggle('hidden', !state.pinAvailable);
  setError(otpError, '');
  document.getElementById('otp-code').value = '';
  document.getElementById('pin-code').value = '';
  setTimeout(() => document.getElementById('otp-code').focus(), 50);
}

function backToPassword() {
  state.otpId = null;
  loginMain.classList.remove('hidden');
  otpPanel.classList.add('hidden');
  step2.classList.remove('active');
  setError(otpError, '');
}

passwordForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setError(loginError, '');
  const data = new FormData(passwordForm);
  const idNumber = String(data.get('id_number') || '').trim();
  const password = String(data.get('password') || '');
  if (!idNumber || !password) {
    setError(loginError, 'Enter your ID number and password.');
    return;
  }
  setButtonLoading(loginSubmit, true, 'Signing in...');
  try {
    const result = await loginWithPassword({
      idNumber,
      password,
      trustDevice: data.get('trust_device') === 'true',
      deviceId
    });
    if (result.otp_required) {
      state.qrToken = null;
      showOtp(result);
    } else {
      complete(result);
    }
  } catch (error) {
    setError(loginError, errorMessage(error));
  } finally {
    setButtonLoading(loginSubmit, false);
  }
});

otpForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setError(otpError, '');
  const code = String(new FormData(otpForm).get('code') || '').trim();
  if (!/^\d{4,8}$/.test(code)) {
    setError(otpError, 'Enter the 6-digit code or your PIN.');
    return;
  }
  const trustDevice = new FormData(otpForm).get('trust_device') === 'true';
  setButtonLoading(otpSubmit, true, 'Verifying...');
  try {
    let result;
    try {
      result = await verifyOtp({
        otpId: state.otpId,
        code,
        trustDevice,
        deviceId
      });
    } catch (otpErr) {
      if (state.pinAvailable) {
        try {
          result = await verifyPin({
            otpId: state.otpId,
            pin: code,
            trustDevice,
            deviceId
          });
        } catch {
          throw otpErr;
        }
      } else {
        throw otpErr;
      }
    }
    complete(result);
  } catch (error) {
    setError(otpError, errorMessage(error));
  } finally {
    setButtonLoading(otpSubmit, false);
  }
});

pinForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  setError(otpError, '');
  const pin = String(new FormData(pinForm).get('pin') || '').trim();
  if (!/^\d{4,8}$/.test(pin)) {
    setError(otpError, 'Enter your 4 to 8 digit PIN.');
    return;
  }
  setButtonLoading(pinSubmit, true, 'Verifying...');
  try {
    const result = await verifyPin({ otpId: state.otpId, pin, trustDevice: false, deviceId });
    complete(result);
  } catch (error) {
    setError(otpError, errorMessage(error));
  } finally {
    setButtonLoading(pinSubmit, false);
  }
});

document.getElementById('back-to-password').addEventListener('click', backToPassword);

document.getElementById('resend-code').addEventListener('click', async (event) => {
  const button = event.currentTarget;
  if (!state.qrToken && !passwordForm.reportValidity()) {
    return;
  }
  setButtonLoading(button, true, 'Sending...');
  try {
    let result;
    if (state.qrToken) {
      result = await qrLookup({ token: state.qrToken, deviceId });
    } else {
      const data = new FormData(passwordForm);
      result = await loginWithPassword({
        idNumber: String(data.get('id_number') || '').trim(),
        password: String(data.get('password') || ''),
        trustDevice: false,
        deviceId
      });
    }
    if (result.otp_required) {
      showOtp(result);
      toast('A new verification code was sent.', 'success');
    } else {
      complete(result);
    }
  } catch (error) {
    setError(otpError, errorMessage(error));
  } finally {
    setButtonLoading(button, false);
  }
});

document.getElementById('toggle-password').addEventListener('click', (event) => {
  const input = document.getElementById('password');
  const showing = input.type === 'text';
  input.type = showing ? 'password' : 'text';
  event.currentTarget.textContent = showing ? 'Show' : 'Hide';
});

document.getElementById('scan-id').addEventListener('click', async () => {
  try {
    const raw = await scanQr({ title: 'Scan your student or staff ID' });
    let token = raw.trim();
    try {
      const parsed = new URL(token);
      token = parsed.searchParams.get('token') || parsed.searchParams.get('id') || token;
    } catch {
      token = raw.trim();
    }
    const result = await qrLookup({ token, deviceId });
    state.qrToken = token;
    showOtp(result);
  } catch (error) {
    if (!error.cancelled) notifyError(error);
  }
});
