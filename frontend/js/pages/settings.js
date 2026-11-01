import { api } from '../api.js';
import { getUser, refreshMe, requireAuth, roleLabel, setUser } from '../auth.js';
import {
  badge,
  confirmDialog,
  emptyState,
  escapeHtml,
  formatDate,
  notifyError,
  openModal,
  setButtonLoading,
  toast
} from '../ui.js';

const modeLabels = { physical: 'In person', online: 'Online', hybrid: 'Hybrid' };
const eventOptions = [
  ['session_confirmed', 'Booking confirmed'],
  ['session_updated', 'Session changed'],
  ['session_cancelled', 'Session cancelled'],
  ['session_released', 'Room released'],
  ['session_reminder', 'Session reminder'],
  ['session_displaced', 'Displaced by priority'],
  ['room_issue_update', 'Room issue updates'],
  ['security', 'Security alerts']
];
const channelOptions = [['inapp', 'In app'], ['email', 'Email'], ['sms', 'SMS'], ['push', 'Push']];
const defaultChannels = { inapp: true, email: true, sms: false, push: true };
let profile = null;
let qrTimer = null;

function setSectionError(form, message) {
  const box = form.querySelector('[data-error]');
  if (!box) {
    toast(message, 'error');
    return;
  }
  box.textContent = message;
  box.classList.remove('hidden');
}

function clearSectionError(form) {
  const box = form.querySelector('[data-error]');
  if (box) box.classList.add('hidden');
}

async function loadProfile() {
  profile = await api.get('/api/me/profile');
  setUser({ ...getUser(), ...profile });
  renderProfile();
  // Run sections independently so a single failing endpoint doesn't block the rest
  // or trigger the global error toast — each section shows its own inline error instead.
  await Promise.allSettled([
    loadStudyMode().catch((err) => {
      document.getElementById('study-mode-summary').innerHTML =
        `<div class="notice warning">Could not load study mode: ${escapeHtml(err.message)}</div>`;
    }),
    loadDevices().catch((err) => {
      document.getElementById('devices-list').innerHTML =
        `<div class="notice warning">Could not load devices: ${escapeHtml(err.message)}</div>`;
      document.getElementById('sessions-list').innerHTML = '';
    }),
    loadPreferences().catch((err) => {
      document.getElementById('preferences-grid').innerHTML =
        `<div class="notice warning">Could not load notification preferences: ${escapeHtml(err.message)}</div>`;
    }),
    loadDataRequests().catch((err) => {
      document.getElementById('data-requests').innerHTML =
        `<div class="notice warning">Could not load privacy requests: ${escapeHtml(err.message)}</div>`;
    })
  ]);
}

function renderProfile() {
  const repRoles = (profile.rep_roles || []).map((role) => role.is_deputy
    ? `Deputy rep, ${role.class_code}`
    : `Class rep, ${role.class_code}`);
  document.getElementById('profile-summary').innerHTML = `
    <div class="profile-head">
      <div class="avatar large">${escapeHtml((profile.name || '?').slice(0, 2).toUpperCase())}</div>
      <div>
        <h3>${escapeHtml(profile.name)}</h3>
        <p class="muted small">${escapeHtml(profile.id_number)} · ${escapeHtml(roleLabel(profile.role))}</p>
        <p class="small">${escapeHtml([profile.department_name, profile.programme_code, profile.class_code].filter(Boolean).join(' · '))}</p>
        ${repRoles.length ? `<p class="small">${escapeHtml(repRoles.join(' · '))}</p>` : ''}
      </div>
    </div>
    <p class="small muted" style="margin-top:.6rem">${escapeHtml(profile.email || '')}${profile.phone ? ` · ${escapeHtml(profile.phone)}` : ''}</p>
    ${profile.flagged_for_review ? '<div class="notice warning" style="margin-top:.7rem">Your account is flagged for review. Contact an administrator if you need help.</div>' : ''}`;
  document.getElementById('profile-phone').value = profile.phone || '';
  document.getElementById('sms-opt-in').checked = Boolean(profile.sms_link_opt_in);
  const consentRow = document.getElementById('consent-row');
  consentRow.classList.toggle('hidden', Boolean(profile.consent_at));
  if (!profile.consent_at) document.getElementById('consent').checked = false;
}

async function loadStudyMode() {
  document.getElementById('study-mode-summary').innerHTML = `
    <div class="notice info">
      <strong>${escapeHtml(modeLabels[profile.study_mode] || profile.study_mode || 'Not set')}</strong>
      <p class="small">This controls whether you are counted as attending on site or online for hybrid sessions. Changes are reviewed by your department.</p>
    </div>`;
  const result = await api.get('/api/me/study-mode/requests');
  const requests = result.requests || [];
  document.getElementById('mode-requests').innerHTML = requests.length
    ? `<div class="list">${requests.slice(0, 5).map((item) => `
        <div class="list-item">
          <span class="item-icon">${escapeHtml(modeLabels[item.requested_mode]?.slice(0, 1) || '?')}</span>
          <div class="main"><h3>${escapeHtml(modeLabels[item.requested_mode] || item.requested_mode)}</h3><p>${escapeHtml(formatDate(item.created_at, { dateStyle: 'medium' }))} · ${escapeHtml(item.reason)}</p></div>
          ${badge(item.status === 'approved' ? 'confirmed' : item.status === 'rejected' ? 'cancelled' : 'pending')}
        </div>`).join('')}</div>`
    : '<p class="small muted">No study mode requests yet.</p>';
}

document.getElementById('request-mode').addEventListener('click', () => {
  const modal = openModal({
    title: 'Request study mode change',
    content: `
      <form id="mode-form">
        <div class="field">
          <label for="requested-mode">Requested mode</label>
          <select id="requested-mode" name="requested_mode">
            <option value="physical">In person</option>
            <option value="online">Online</option>
            <option value="hybrid">Hybrid</option>
          </select>
        </div>
        <div class="field">
          <label for="mode-reason">Reason</label>
          <textarea id="mode-reason" name="reason" rows="3" minlength="10" maxlength="1000" required placeholder="Explain why you need this change. At least 10 characters."></textarea>
        </div>
        <p class="error-text hidden" data-error></p>
        <button class="btn wide" type="submit">Send request</button>
      </form>`,
    footer: '<button type="button" class="btn secondary" data-close>Cancel</button>'
  });
  const form = modal.body.querySelector('#mode-form');
  form.querySelector('#requested-mode').value = profile.study_mode === 'physical' ? 'online' : 'physical';
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    setButtonLoading(button, true, 'Sending...');
    clearSectionError(form);
    try {
      const data = Object.fromEntries(new FormData(form).entries());
      await api.post('/api/me/study-mode/request', data, { retry: false });
      modal.close();
      toast('Study mode request sent.', 'success');
      await loadStudyMode();
    } catch (error) {
      setSectionError(form, error.message);
    } finally {
      setButtonLoading(button, false);
    }
  });
});

document.getElementById('profile-form').addEventListener('submit', async (event) => {
  event.preventDefault();
  const form = event.currentTarget;
  const button = form.querySelector('button[type="submit"]');
  clearSectionError(form);
  setButtonLoading(button, true, 'Saving...');
  try {
    const phone = document.getElementById('profile-phone').value.trim();
    const consent = !profile.consent_at && document.getElementById('consent').checked;
    const payload = {
      phone,
      sms_link_opt_in: document.getElementById('sms-opt-in').checked
    };
    if (consent) payload.consent = true;
    await api.patch('/api/me/profile', payload);
    await refreshMe().catch(() => {});
    profile = await api.get('/api/me/profile');
    renderProfile();
    toast('Profile updated.', 'success');
  } catch (error) {
    setSectionError(form, error.message);
  } finally {
    setButtonLoading(button, false);
  }
});

document.getElementById('password-form').addEventListener('submit', async (event) => {
  event.preventDefault();
  const form = event.currentTarget;
  const button = form.querySelector('button[type="submit"]');
  clearSectionError(form);
  setButtonLoading(button, true, 'Changing...');
  try {
    const data = Object.fromEntries(new FormData(form).entries());
    await api.post('/api/me/password', data, { retry: false });
    form.reset();
    toast('Password changed. Other sessions were signed out.', 'success');
  } catch (error) {
    setSectionError(form, error.message);
  } finally {
    setButtonLoading(button, false);
  }
});

document.getElementById('pin-form').addEventListener('submit', async (event) => {
  event.preventDefault();
  const form = event.currentTarget;
  const button = form.querySelector('button[type="submit"]');
  clearSectionError(form);
  setButtonLoading(button, true, 'Saving...');
  try {
    const data = Object.fromEntries(new FormData(form).entries());
    await api.post('/api/me/pin', data, { retry: false });
    form.reset();
    toast('Check-in PIN updated.', 'success');
  } catch (error) {
    setSectionError(form, error.message);
  } finally {
    setButtonLoading(button, false);
  }
});

async function loadQr() {
  const result = await api.get('/api/me/qr', { retry: false });
  document.getElementById('qr-image').src = result.image_data_url;
  const expires = result.expires_at ? formatDate(result.expires_at, { timeStyle: 'medium' }) : 'in 30 seconds';
  document.getElementById('qr-expiry').textContent = `Refreshes ${expires}. Do not share a screenshot — it will not work later.`;
}

async function showQr() {
  const panel = document.getElementById('qr-panel');
  panel.classList.remove('hidden');
  document.getElementById('show-qr').hidden = true;
  try {
    await loadQr();
    clearInterval(qrTimer);
    qrTimer = setInterval(() => {
      if (!panel.classList.contains('hidden') && !document.hidden) loadQr().catch(() => {});
    }, 25000);
  } catch (error) {
    panel.classList.add('hidden');
    document.getElementById('show-qr').hidden = false;
    notifyError(error);
  }
}

function hideQr() {
  document.getElementById('qr-panel').classList.add('hidden');
  document.getElementById('show-qr').hidden = false;
  clearInterval(qrTimer);
  qrTimer = null;
}

document.getElementById('show-qr').addEventListener('click', () => showQr().catch(notifyError));
document.getElementById('hide-qr').addEventListener('click', hideQr);
document.addEventListener('visibilitychange', () => {
  if (!document.hidden && qrTimer) loadQr().catch(() => {});
});

async function loadDevices() {
  const [deviceResult, sessionResult] = await Promise.all([
    api.get('/api/me/devices'),
    api.get('/api/me/sessions')
  ]);
  const devices = deviceResult.devices || [];
  document.getElementById('devices-list').innerHTML = devices.length
    ? `<div class="list">${devices.map((device) => `
        <div class="list-item">
          <span class="item-icon">${escapeHtml(device.label?.slice(0, 1) || 'D')}</span>
          <div class="main">
            <h3>${escapeHtml(device.label || 'Trusted device')}</h3>
            <p>Last used ${escapeHtml(formatDate(device.last_used_at, { dateStyle: 'medium' }))}${device.trusted_until ? ` · trusted until ${escapeHtml(formatDate(device.trusted_until, { dateStyle: 'medium' }))}` : ''}</p>
            ${device.revoked_at ? '<p class="small danger-text">Revoked</p>' : ''}
          </div>
          ${device.revoked_at ? '' : `<button class="btn ghost small danger-text" type="button" data-revoke-device="${escapeHtml(device.id)}">Revoke</button>`}
        </div>`).join('')}</div>`
    : '<p class="small muted">No trusted devices yet.</p>';
  const sessions = sessionResult.sessions || [];
  document.getElementById('sessions-list').innerHTML = sessions.length
    ? `<div class="list">${sessions.map((session) => `
        <div class="list-item">
          <span class="item-icon">${session.current ? '✓' : 'S'}</span>
          <div class="main">
            <h3>${session.current ? 'This device' : 'Signed-in device'}</h3>
            <p>${escapeHtml((session.user_agent || 'Unknown browser').slice(0, 90))}</p>
            <p>Last active ${escapeHtml(formatDate(session.last_seen_at, { dateStyle: 'medium', timeStyle: 'short' }))}${session.revoked_at ? ' · ended' : ''}</p>
          </div>
          ${session.revoked_at || session.current ? '' : `<button class="btn ghost small danger-text" type="button" data-revoke-session="${escapeHtml(session.id)}">End</button>`}
        </div>`).join('')}</div>`
    : '<p class="small muted">No active sessions.</p>';
}

document.getElementById('refresh-devices').addEventListener('click', () => loadDevices().catch(notifyError));
document.getElementById('devices-list').addEventListener('click', async (event) => {
  const button = event.target.closest('[data-revoke-device]');
  if (!button) return;
  if (!await confirmDialog('Revoke this trusted device? It will need a one-time code the next time it signs in.', { confirmText: 'Revoke', danger: true })) return;
  try {
    await api.delete(`/api/me/devices/${encodeURIComponent(button.dataset.revokeDevice)}`);
    toast('Device revoked.', 'success');
    await loadDevices();
  } catch (error) {
    notifyError(error);
  }
});
document.getElementById('sessions-list').addEventListener('click', async (event) => {
  const button = event.target.closest('[data-revoke-session]');
  if (!button) return;
  if (!await confirmDialog('End this session? That device will need to sign in again.', { confirmText: 'End session', danger: true })) return;
  try {
    await api.delete(`/api/me/sessions/${encodeURIComponent(button.dataset.revokeSession)}`);
    toast('Session ended.', 'success');
    await loadDevices();
  } catch (error) {
    notifyError(error);
  }
});

async function loadPreferences() {
  const result = await api.get('/api/me/notifications/preferences');
  const saved = new Map((result.preferences || []).map((item) => [`${item.event_type}:${item.channel}`, item.enabled]));
  document.getElementById('preferences-grid').innerHTML = `
    <div class="preference-grid">
      <div class="preference-head">Update</div>
      ${channelOptions.map(([, label]) => `<div class="preference-head">${label}</div>`).join('')}
      ${eventOptions.map(([eventType, label]) => `
        <div class="preference-label">${escapeHtml(label)}</div>
        ${channelOptions.map(([channel]) => {
          const checked = saved.has(`${eventType}:${channel}`) ? saved.get(`${eventType}:${channel}`) : defaultChannels[channel];
          return `<label class="preference-check"><input type="checkbox" data-event="${eventType}" data-channel="${channel}" ${checked ? 'checked' : ''}><span class="sr-only">${escapeHtml(label)} by ${channel}</span></label>`;
        }).join('')}`).join('')}
    </div>`;
}

document.getElementById('preferences-form').addEventListener('submit', async (event) => {
  event.preventDefault();
  const button = event.currentTarget.querySelector('button[type="submit"]');
  setButtonLoading(button, true, 'Saving...');
  try {
    const preferences = [...event.currentTarget.querySelectorAll('[data-event]')].map((input) => ({
      event_type: input.dataset.event,
      channel: input.dataset.channel,
      enabled: input.checked
    }));
    await api.put('/api/me/notifications/preferences', { preferences });
    toast('Notification preferences saved.', 'success');
  } catch (error) {
    toast(error.message, 'error');
  } finally {
    setButtonLoading(button, false);
  }
});

async function loadDataRequests() {
  const result = await api.get('/api/me/data-requests');
  const requests = result.requests || [];
  document.getElementById('data-requests').innerHTML = requests.length
    ? `<div class="list">${requests.map((item) => `
        <div class="list-item">
          <span class="item-icon">${item.type === 'deletion' ? '×' : '↓'}</span>
          <div class="main"><h3>${escapeHtml(item.type === 'deletion' ? 'Deletion request' : 'Data export request')}</h3><p>${escapeHtml(formatDate(item.requested_at, { dateStyle: 'medium' }))}</p></div>
          ${badge(item.status === 'completed' ? 'confirmed' : item.status === 'rejected' ? 'cancelled' : 'pending')}
        </div>`).join('')}</div>`
    : '<p class="small muted">No privacy requests yet.</p>';
}

function openDataRequest(type) {
  const isDeletion = type === 'deletion';
  const modal = openModal({
    title: isDeletion ? 'Request data deletion' : 'Request formal export',
    content: `
      <p class="muted small">${isDeletion
        ? 'An administrator will review this request and contact you. Some records may be retained where the university has a legal obligation.'
        : 'An administrator will prepare a formal copy of your data. You can also download your data immediately below.'}</p>
      <form id="data-request-form" style="margin-top:.8rem">
        <div class="field">
          <label for="data-notes">Notes (optional)</label>
          <textarea id="data-notes" name="notes" rows="2" maxlength="1000"></textarea>
        </div>
        <p class="error-text hidden" data-error></p>
        <button class="btn ${isDeletion ? 'danger' : ''} wide" type="submit">${isDeletion ? 'Submit deletion request' : 'Submit export request'}</button>
      </form>`,
    footer: '<button type="button" class="btn secondary" data-close>Cancel</button>'
  });
  const form = modal.body.querySelector('#data-request-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    setButtonLoading(button, true, 'Submitting...');
    try {
      const notes = form.querySelector('#data-notes').value.trim();
      await api.post('/api/me/data-requests', { type, notes: notes || undefined }, { retry: false });
      modal.close();
      toast('Privacy request submitted.', 'success');
      await loadDataRequests();
    } catch (error) {
      setSectionError(form, error.message);
    } finally {
      setButtonLoading(button, false);
    }
  });
}

document.getElementById('download-data').addEventListener('click', async () => {
  try {
    await api.download('/api/me/export', `campus-data-${profile?.id_number || 'account'}.json`);
    toast('Data download started.', 'success');
  } catch (error) {
    notifyError(error);
  }
});
document.getElementById('request-export').addEventListener('click', () => openDataRequest('export'));
document.getElementById('request-deletion').addEventListener('click', () => openDataRequest('deletion'));

async function start() {
  const user = await requireAuth();
  if (!user) return;
  await loadProfile();
}

start().catch(notifyError);
