import { api } from '../api.js';
import { errorMessage, escapeHtml, queryParams, setButtonLoading } from '../ui.js';

const TZ = 'Africa/Kampala';
const POLL_MS = 30000;
const RETRY_MS = 10000;
const TOKEN_PREFIX = 'campus.display.token.';
const KEY_PREFIX = 'campus.display.key.';
const DEVICE_KEY = 'campus.display.device';

const params = queryParams();
const elements = {
  clock: document.getElementById('display-clock'),
  date: document.getElementById('display-date'),
  roomName: document.getElementById('display-room-name'),
  meta: document.getElementById('display-meta'),
  session: document.getElementById('display-session'),
  qr: document.getElementById('display-qr'),
  qrPlaceholder: document.getElementById('display-qr-placeholder'),
  status: document.getElementById('display-status'),
  login: document.getElementById('display-login'),
  form: document.getElementById('display-form'),
  device: document.getElementById('display-device'),
  key: document.getElementById('display-key'),
  remember: document.getElementById('display-remember'),
  error: document.getElementById('display-error'),
  submit: document.getElementById('display-submit')
};

const state = {
  deviceId: '',
  token: '',
  payload: null,
  offsetMs: 0,
  timer: null,
  stopped: false
};

function storageGet(key) {
  try {
    return localStorage.getItem(key) || '';
  } catch {
    return '';
  }
}

function storageSet(key, value) {
  try {
    if (value) localStorage.setItem(key, value);
    else localStorage.removeItem(key);
  } catch {
    return;
  }
}

function readToken(deviceId) {
  return storageGet(`${TOKEN_PREFIX}${deviceId}`);
}

function writeToken(deviceId, token) {
  storageSet(`${TOKEN_PREFIX}${deviceId}`, token);
}

function readKey(deviceId) {
  return storageGet(`${KEY_PREFIX}${deviceId}`);
}

function writeKey(deviceId, key) {
  storageSet(`${KEY_PREFIX}${deviceId}`, key);
}

function readDevice() {
  return storageGet(DEVICE_KEY);
}

function writeDevice(deviceId) {
  storageSet(DEVICE_KEY, deviceId);
}

function tokenExpired(token) {
  try {
    const part = token.split('.')[1].replaceAll('-', '+').replaceAll('_', '/');
    const padded = part + '='.repeat((4 - (part.length % 4)) % 4);
    const payload = JSON.parse(atob(padded));
    return !payload.exp || payload.exp * 1000 < Date.now() + 60000;
  } catch {
    return true;
  }
}

function showError(message) {
  elements.error.textContent = message;
  elements.error.classList.toggle('hidden', !message);
}

function showLogin(message = '') {
  state.stopped = true;
  stopPolling();
  elements.login.classList.remove('hidden');
  elements.login.setAttribute('aria-hidden', 'false');
  elements.device.value = state.deviceId || readDevice();
  const storedKey = state.deviceId ? readKey(state.deviceId) : '';
  elements.key.value = storedKey;
  elements.remember.checked = Boolean(storedKey);
  showError(message);
  setTimeout(() => (storedKey ? elements.key : elements.device).focus(), 50);
}

function hideLogin() {
  state.stopped = false;
  elements.login.classList.add('hidden');
  elements.login.setAttribute('aria-hidden', 'true');
  showError('');
}

function isAuthError(error) {
  return error && (
    error.status === 401 ||
    error.status === 403 ||
    ['DISPLAY_UNAUTHORIZED', 'DISPLAY_TOKEN_INVALID', 'DISPLAY_REVOKED'].includes(error.code)
  );
}

function setStatus(text, tone = '') {
  elements.status.className = `display-status ${tone}`;
  elements.status.innerHTML = `<span class="display-dot"></span>${escapeHtml(text)}`;
}

function modeLabel(mode) {
  return { physical: 'In person', online: 'Online', hybrid: 'Hybrid' }[mode] || 'Session';
}

function sessionName(session) {
  if (!session) return '';
  return session.module_code || 'Reserved session';
}

function sessionDetail(session) {
  if (!session) return '';
  return session.module_name || 'A room booking is in progress.';
}

function relativeStart(value) {
  const diff = Math.round((new Date(value).getTime() - (Date.now() + state.offsetMs)) / 60000);
  if (diff <= 0) return 'starting now';
  if (diff < 60) return `in ${diff} min`;
  const hours = Math.floor(diff / 60);
  const minutes = diff % 60;
  if (hours < 24) return minutes ? `in ${hours}h ${minutes}m` : `in ${hours}h`;
  const days = Math.round(hours / 24);
  return `in ${days} day${days === 1 ? '' : 's'}`;
}

function clockText(date) {
  return new Intl.DateTimeFormat('en-GB', {
    timeZone: TZ,
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit',
    hour12: false
  }).format(date);
}

function dateText(date) {
  return new Intl.DateTimeFormat('en-GB', {
    timeZone: TZ,
    weekday: 'long',
    day: 'numeric',
    month: 'long',
    year: 'numeric'
  }).format(date);
}

function tickClock() {
  const now = new Date(Date.now() + state.offsetMs);
  elements.clock.textContent = clockText(now);
  elements.date.textContent = dateText(now);
  if (state.payload) renderNextTiming();
}

function renderNextTiming() {
  const node = document.getElementById('display-next-timing');
  if (node && state.payload?.next) {
    node.textContent = relativeStart(state.payload.next.start_at);
  }
}

function renderSession(payload) {
  const facility = payload.facility || {};
  const current = payload.current;
  const next = payload.next;
  const mode = current ? modeLabel(current.session_mode) : '';
  const available = facility.status === 'active';

  let html = '';
  if (current) {
    html += `
      <div class="display-state live"><span class="display-dot live"></span>In session</div>
      <h1 class="display-title">${escapeHtml(sessionName(current))}</h1>
      <p class="display-session-name">${escapeHtml(sessionDetail(current))}</p>
      <div class="display-time">${escapeHtml(current.start_local || '')} &ndash; ${escapeHtml(current.end_local || '')}</div>
      <div class="display-tags"><span class="display-tag">${escapeHtml(mode)}</span></div>`;
  } else {
    html += `
      <div class="display-state free"><span class="display-dot free"></span>${available ? 'Room available' : 'Room unavailable'}</div>
      <h1 class="display-title">${available ? 'Room available' : 'Room offline'}</h1>
      <p class="display-session-name">${available ? 'No session is running right now.' : `This room is marked ${escapeHtml(facility.status || 'unavailable')}.`}</p>`;
  }

  if (next) {
    html += `
      <div class="display-next">
        <div>
          <span class="display-next-label">Next session</span>
          <strong>${escapeHtml(sessionName(next))}</strong>
          <span>${escapeHtml(next.start_local || '')} &ndash; ${escapeHtml(next.end_local || '')}</span>
        </div>
        <span class="display-next-time" id="display-next-timing">${escapeHtml(relativeStart(next.start_at))}</span>
      </div>`;
  } else if (!current) {
    html += '<p class="display-quiet">No further sessions are scheduled in this room.</p>';
  }

  elements.session.innerHTML = html;
  elements.roomName.textContent = facility.name || 'Room';
  const roomBits = [
    facility.building,
    facility.floor,
    facility.room_number ? `Room ${facility.room_number}` : '',
    facility.category ? facility.category.replaceAll('_', ' ') : ''
  ].filter(Boolean);
  elements.meta.textContent = roomBits.join(' · ');
  document.title = `${facility.name || 'Door display'} | Campus Compass`;
}

function renderQr(payload) {
  const source = payload.door_qr_data_url || payload.room_qr_data_url || '';
  if (!source) {
    elements.qr.hidden = true;
    elements.qr.removeAttribute('src');
    elements.qrPlaceholder.hidden = false;
    elements.qrPlaceholder.textContent = 'QR code is not available for this room.';
    return;
  }
  elements.qr.src = source;
  elements.qr.hidden = false;
  elements.qrPlaceholder.hidden = true;
}

function applyPayload(payload) {
  state.payload = payload;
  if (payload.server_time) {
    state.offsetMs = new Date(payload.server_time).getTime() - Date.now();
  }
  renderSession(payload);
  renderQr(payload);
  tickClock();
}

async function loadRoom() {
  const token = state.token || readToken(state.deviceId);
  if (!token) throw Object.assign(new Error('This display is not connected.'), { status: 401, code: 'DISPLAY_UNAUTHORIZED' });
  const payload = await api.get('/api/display/room', {
    auth: false,
    retry: false,
    skipAuthRedirect: true,
    headers: { Authorization: `Bearer ${token}` }
  });
  state.token = token;
  applyPayload(payload);
}

async function login(deviceId, key) {
  const payload = await api.post('/api/display/login', { device_id: deviceId, key }, {
    auth: false,
    retry: false,
    skipAuthRedirect: true
  });
  if (!payload?.token) {
    throw Object.assign(new Error('The display did not return a session.'), { status: 401, code: 'DISPLAY_UNAUTHORIZED' });
  }
  state.deviceId = deviceId;
  state.token = payload.token;
  writeDevice(deviceId);
  writeToken(deviceId, payload.token);
  applyPayload(payload);
}

function stopPolling() {
  if (state.timer) clearTimeout(state.timer);
  state.timer = null;
}

function schedule(ms) {
  if (state.stopped) return;
  stopPolling();
  state.timer = setTimeout(tick, ms);
}

async function tick() {
  if (state.stopped) return;
  if (document.hidden) {
    schedule(5000);
    return;
  }
  try {
    await loadRoom();
    setStatus('Live', 'ok');
    schedule(POLL_MS);
  } catch (error) {
    if (isAuthError(error)) {
      const storedKey = readKey(state.deviceId);
      writeToken(state.deviceId, '');
      if (storedKey) {
        try {
          await login(state.deviceId, storedKey);
          setStatus('Live', 'ok');
          schedule(POLL_MS);
          return;
        } catch (loginError) {
          showLogin(isAuthError(loginError) ? errorMessage(loginError) : 'Could not reconnect this display. Check the network and try again.');
          return;
        }
      }
      showLogin(errorMessage(error));
      return;
    }
    setStatus(navigator.onLine ? 'Reconnecting...' : 'Offline', 'warn');
    schedule(RETRY_MS);
  }
}

function startPolling() {
  hideLogin();
  setStatus('Live', 'ok');
  schedule(POLL_MS);
}

async function boot() {
  state.deviceId = (params.get('device') || params.get('id') || readDevice()).trim();
  if (!state.deviceId) {
    showLogin('');
    return;
  }
  elements.device.value = state.deviceId;
  const token = readToken(state.deviceId);
  if (token && !tokenExpired(token)) {
    state.token = token;
    try {
      await loadRoom();
      startPolling();
      return;
    } catch (error) {
      if (!isAuthError(error)) {
        hideLogin();
        setStatus(navigator.onLine ? 'Reconnecting...' : 'Offline', 'warn');
        schedule(RETRY_MS);
        return;
      }
      writeToken(state.deviceId, '');
      state.token = '';
    }
  }
  const storedKey = readKey(state.deviceId);
  if (storedKey) {
    try {
      await login(state.deviceId, storedKey);
      startPolling();
      return;
    } catch (error) {
      if (!isAuthError(error)) {
        showLogin('Could not reach the campus server. Check the network and try again.');
        return;
      }
    }
  }
  showLogin('');
}

elements.form.addEventListener('submit', async (event) => {
  event.preventDefault();
  const deviceId = elements.device.value.trim();
  const key = elements.key.value.trim();
  if (!deviceId) {
    showError('Enter the device ID from the display link.');
    elements.device.focus();
    return;
  }
  if (key.length < 16) {
    showError('Enter the display key created by an administrator.');
    elements.key.focus();
    return;
  }
  setButtonLoading(elements.submit, true, 'Connecting...');
  showError('');
  try {
    state.deviceId = deviceId;
    await login(deviceId, key);
    writeKey(deviceId, elements.remember.checked ? key : '');
    startPolling();
  } catch (error) {
    showError(errorMessage(error));
  } finally {
    setButtonLoading(elements.submit, false);
  }
});

document.addEventListener('visibilitychange', () => {
  if (!document.hidden && !state.stopped) {
    schedule(100);
  }
});

window.addEventListener('online', () => {
  if (!state.stopped) schedule(100);
});

window.addEventListener('offline', () => {
  if (!state.stopped) setStatus('Offline', 'warn');
});

tickClock();
setInterval(tickClock, 1000);
boot().catch((error) => showLogin(errorMessage(error)));
