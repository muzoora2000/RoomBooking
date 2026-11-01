import { api, queryString } from '../api.js';
import { requireAdmin, roleLabel } from '../auth.js';
import {
  badge,
  confirmDialog,
  emptyState,
  escapeHtml,
  formatDate,
  formatRange,
  icon,
  notifyError,
  openModal,
  setButtonLoading,
  toast
} from '../ui.js';

const content = document.getElementById('admin-content');
const tabs = [...document.querySelectorAll('[data-admin-tab]')];
const state = {
  me: null,
  tab: 'overview',
  departments: [],
  classes: [],
  facilities: [],
  bookingStatus: 'pending',
  facilityQuery: '',
  userQuery: '',
  userRole: '',
  issueStatus: 'open',
  studyStatus: 'pending',
  dataStatus: 'pending',
  auditAction: '',
  auditFrom: ''
};

const roleOptions = ['student', 'class_rep', 'deputy_rep', 'lecturer', 'department_admin', 'super_admin'];
const categoryLabels = {
  lecture_room: 'Lecture room',
  discussion_room: 'Discussion room',
  lab: 'Laboratory',
  office: 'Office',
  library: 'Library'
};

function skeleton() {
  content.innerHTML = '<div class="skeleton"></div><div class="skeleton"></div><div class="skeleton"></div>';
}

function pageHeader(title, subtitle, actions = '') {
  return `<div class="admin-section-head"><div><h2>${escapeHtml(title)}</h2><p class="muted small">${escapeHtml(subtitle)}</p></div><div class="card-actions">${actions}</div></div>`;
}

function option(value, label, selected = false) {
  return `<option value="${escapeHtml(value)}" ${selected ? 'selected' : ''}>${escapeHtml(label)}</option>`;
}

function departmentOptions(selected = '') {
  if (state.me?.role !== 'super_admin' && state.me?.department_id) {
    return option(state.me.department_id, state.departments.find((item) => item.id === state.me.department_id)?.name || 'My department', true);
  }
  return '<option value="">Choose department</option>' + state.departments.map((item) => option(item.id, `${item.code} · ${item.name}`, item.id === selected)).join('');
}

function classOptions(selected = '') {
  return '<option value="">No class</option>' + state.classes.map((item) => option(item.id, `${item.code} · ${item.name}`, item.id === selected)).join('');
}

function copyText(text) {
  if (navigator.clipboard?.writeText) {
    navigator.clipboard.writeText(text).then(() => toast('Copied.', 'success')).catch(() => toast('Could not copy automatically.', 'error'));
  } else {
    toast('Select the text and copy it manually.', 'info');
  }
}

function openHtml(html) {
  const win = window.open('', '_blank');
  if (!win) {
    toast('Allow pop-ups to open this printable page.', 'error');
    return;
  }
  win.document.open();
  win.document.write(html);
  win.document.close();
}

function bookingTitle(booking) {
  return booking.module?.code
    ? `${booking.module.code} · ${booking.module.name}`
    : booking.purpose || 'Room booking';
}

function askReason({ title, label = 'Reason', placeholder = '', confirmText = 'Continue', danger = false, min = 3 }) {
  return new Promise((resolve) => {
    const modal = openModal({
      title,
      content: `
        <form id="reason-form">
          <div class="field">
            <label for="reason-text">${escapeHtml(label)}</label>
            <textarea id="reason-text" name="reason" rows="3" minlength="${min}" maxlength="1000" required placeholder="${escapeHtml(placeholder)}"></textarea>
          </div>
          <p class="error-text hidden" data-error></p>
          <button class="btn ${danger ? 'danger' : ''} wide" type="submit">${escapeHtml(confirmText)}</button>
        </form>`,
      footer: '<button type="button" class="btn secondary" data-close>Cancel</button>',
      onClose: () => resolve(null)
    });
    const form = modal.body.querySelector('#reason-form');
    form.addEventListener('submit', (event) => {
      event.preventDefault();
      const value = form.querySelector('#reason-text').value.trim();
      if (value.length < min) {
        const error = form.querySelector('[data-error]');
        error.textContent = `Enter at least ${min} characters.`;
        error.classList.remove('hidden');
        return;
      }
      modal.root.remove();
      resolve(value);
    });
  });
}

async function loadDirectory() {
  const [departments, classes] = await Promise.all([
    api.get('/api/org/departments'),
    api.get('/api/org/classes')
  ]);
  state.departments = departments.departments || [];
  state.classes = classes.classes || [];
}

async function loadFacilityDirectory() {
  if (state.facilities.length) return;
  const result = await api.get('/api/admin/facilities');
  state.facilities = result.facilities || [];
}

function deliveryFailures() {
  const modal = openModal({
    title: 'Failed notification deliveries',
    content: '<div class="skeleton"></div><div class="skeleton"></div>',
    footer: '<button type="button" class="btn secondary" data-close>Close</button>'
  });
  api.get('/api/admin/deliveries?status=failed').then((result) => {
    const rows = result.deliveries || [];
    modal.body.innerHTML = rows.length
      ? `<div class="table-wrap"><table><thead><tr><th>When</th><th>Person</th><th>Channel</th><th>Notification</th><th>Error</th></tr></thead><tbody>${rows.map((row) => `
          <tr><td>${escapeHtml(formatDate(row.created_at, { dateStyle: 'medium', timeStyle: 'short' }))}</td>
          <td>${escapeHtml(row.user_name || '')}<br><span class="muted small">${escapeHtml(row.email || '')}</span></td>
          <td>${escapeHtml(row.channel)}</td><td>${escapeHtml(row.title || '')}</td>
          <td class="small danger-text">${escapeHtml((row.error || '').slice(0, 300))}</td></tr>`).join('')}</tbody></table></div>`
      : '<p class="muted">No failed deliveries.</p>';
  }).catch((error) => {
    modal.body.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  });
}

async function loadOverview() {
  const [dashboard, health] = await Promise.all([
    api.get('/api/admin/dashboard'),
    api.get('/api/admin/health').catch(() => null)
  ]);
  const counts = dashboard.counts || {};
  const alerts = dashboard.alerts || [];
  content.innerHTML = `
    ${pageHeader('Today at a glance', 'Live operational counts for your scope.', '<button class="btn secondary" type="button" id="show-failures">Delivery failures</button>')}
    <div class="stats-grid admin-stats">
      <button class="stat clickable" type="button" data-goto="bookings"><strong>${Number(counts.pending_bookings || 0)}</strong><span>Pending bookings</span></button>
      <button class="stat clickable" type="button" data-goto="bookings"><strong>${Number(counts.sessions_today || 0)}</strong><span>Sessions today</span></button>
      <button class="stat clickable" type="button" data-goto="issues"><strong>${Number(counts.open_issues || 0)}</strong><span>Open issues</span></button>
      <button class="stat clickable" type="button" data-goto="study"><strong>${Number(counts.pending_study_mode || 0)}</strong><span>Study mode requests</span></button>
      <button class="stat clickable" type="button" data-goto="data"><strong>${Number(counts.pending_data_requests || 0)}</strong><span>Data requests</span></button>
      <div class="stat"><strong>${Number(counts.facilities || 0)}</strong><span>Active rooms</span></div>
      <div class="stat"><strong>${Number(counts.users || 0)}</strong><span>Active users</span></div>
      <div class="stat"><strong>${Number(counts.failed_notifications || 0)}</strong><span>Failed deliveries</span></div>
    </div>
    <div class="admin-two-col">
      <section class="card">
        <h2>Recent warnings</h2>
        ${alerts.length ? `<div class="list">${alerts.map((item) => `
          <div class="list-item"><span class="item-icon">${icon('alert')}</span><div class="main"><h3>${escapeHtml(item.title)}</h3><p>${escapeHtml(item.message)}</p><p class="small muted">${escapeHtml(formatDate(item.created_at, { dateStyle: 'medium', timeStyle: 'short' }))}</p></div>${badge(item.severity === 'critical' ? 'cancelled' : 'pending')}</div>`).join('')}</div>`
          : '<p class="muted small">No warnings in the last 7 days.</p>'}
      </section>
      <section class="card">
        <h2>System health</h2>
        ${health ? `
          <div class="detail-grid compact">
            <div><span>Database</span><div>${health.database?.ok ? 'Connected' : 'Unavailable'} · ${Number(health.database?.latency_ms || 0)}ms</div></div>
            <div><span>Environment</span><div>${escapeHtml(health.environment || '')}</div></div>
            <div><span>Active sessions</span><div>${Number(health.active_sessions || 0)}</div></div>
            <div><span>Queue</span><div>${escapeHtml(Object.entries(health.notification_queue || {}).map(([key, value]) => `${key}: ${value}`).join(' · ') || 'empty')}</div></div>
          </div>
          <p class="small muted" style="margin-top:.7rem">${escapeHtml(String(health.database?.version || '').split(' ').slice(0, 2).join(' '))}</p>`
          : '<div class="notice warning">Health status is unavailable.</div>'}
      </section>
    </div>`;
  document.getElementById('show-failures').addEventListener('click', deliveryFailures);
  content.querySelectorAll('[data-goto]').forEach((button) => {
    button.addEventListener('click', () => switchTab(button.dataset.goto));
  });
}

async function loadBookings() {
  const statuses = ['pending', 'confirmed', 'cancelled', 'completed', 'no_show', 'released'];
  content.innerHTML = `
    ${pageHeader('Bookings', 'Approve requests and manage live sessions.')}
    <div class="filters">
      <select id="booking-status-filter">${['all', ...statuses].map((value) => option(value, value === 'all' ? 'All statuses' : value.replace('_', ' '), value === state.bookingStatus)).join('')}</select>
      <button class="btn secondary" type="button" id="refresh-bookings">Refresh</button>
    </div>
    <div id="admin-bookings"><div class="skeleton"></div></div>`;
  const select = document.getElementById('booking-status-filter');
  select.addEventListener('change', () => {
    state.bookingStatus = select.value;
    renderAdminBookings();
  });
  document.getElementById('refresh-bookings').addEventListener('click', () => renderAdminBookings());
  await renderAdminBookings();
}

async function renderAdminBookings() {
  const container = document.getElementById('admin-bookings');
  container.innerHTML = '<div class="skeleton"></div><div class="skeleton"></div>';
  try {
    const result = await api.get(`/api/admin/bookings${queryString({
      status: state.bookingStatus === 'all' ? undefined : state.bookingStatus,
      limit: 300
    })}`);
    const bookings = result.bookings || [];
    if (!bookings.length) {
      container.innerHTML = emptyState('No bookings match', 'Try a different status filter.');
      return;
    }
    container.innerHTML = `<p class="small muted">${bookings.length} booking${bookings.length === 1 ? '' : 's'}</p><div class="list">${bookings.map((booking) => `
      <div class="list-item admin-booking" data-booking="${escapeHtml(booking.id)}">
        <div class="main">
          <div class="chips" style="margin-bottom:.3rem">${badge(booking.status)}<span class="badge">${escapeHtml(booking.session_mode)}</span></div>
          <h3>${escapeHtml(bookingTitle(booking))}</h3>
          <p>${escapeHtml(formatRange(booking.start_at, booking.end_at))}</p>
          <p>${escapeHtml(booking.facility?.name || 'Online')}${booking.booked_by ? ` · ${escapeHtml(booking.booked_by.name)} (${escapeHtml(booking.booked_by.id_number)})` : ''}</p>
        </div>
        <div class="card-actions">
          <button class="btn ghost small" type="button" data-booking-action="details">Details</button>
          ${booking.status === 'pending' ? '<button class="btn small" type="button" data-booking-action="approve">Approve</button><button class="btn ghost small danger-text" type="button" data-booking-action="reject">Reject</button>' : ''}
          ${['pending', 'confirmed'].includes(booking.status) ? '<button class="btn ghost small danger-text" type="button" data-booking-action="cancel">Cancel</button>' : ''}
          ${booking.status === 'confirmed' && !booking.checked_in_at ? '<button class="btn ghost small" type="button" data-booking-action="checkin">Check in</button>' : ''}
          ${booking.status === 'confirmed' ? '<button class="btn ghost small danger-text" type="button" data-booking-action="no-show">No-show</button>' : ''}
        </div>
      </div>`).join('')}</div>`;
    container.querySelectorAll('[data-booking]').forEach((row) => {
      row.addEventListener('click', (event) => {
        const action = event.target.closest('[data-booking-action]')?.dataset.bookingAction || 'details';
        adminBookingAction(bookings.find((item) => item.id === row.dataset.booking), action);
      });
    });
  } catch (error) {
    container.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  }
}

async function adminBookingAction(booking, action) {
  if (!booking) return;
  try {
    if (action === 'details') {
      const room = booking.facility;
      const modal = openModal({
        title: bookingTitle(booking),
        content: `<div class="detail-grid">
          <div><span>Status</span><div>${badge(booking.status)}</div></div>
          <div><span>When</span><div>${escapeHtml(formatRange(booking.start_at, booking.end_at))}</div></div>
          <div><span>Room</span><div>${escapeHtml(room ? `${room.name}, ${room.building} ${room.room_number}` : 'Online only')}</div></div>
          <div><span>Mode</span><div>${escapeHtml(booking.session_mode)}</div></div>
          <div><span>Booked by</span><div>${escapeHtml(booking.booked_by ? `${booking.booked_by.name} (${booking.booked_by.id_number})` : '-')}</div></div>
          <div><span>Purpose</span><div>${escapeHtml(booking.purpose || '-')}</div></div>
          <div><span>Checked in</span><div>${booking.checked_in_at ? escapeHtml(formatDate(booking.checked_in_at, { timeStyle: 'short' })) : 'No'}</div></div>
          <div><span>Booking ID</span><div><code>${escapeHtml(booking.id)}</code></div></div>
        </div>${booking.online_link ? `<div class="notice info" style="margin-top:.8rem"><p>${escapeHtml(booking.online_platform || 'Online')}</p><a href="${escapeHtml(booking.online_link)}" target="_blank" rel="noopener noreferrer">Open meeting link</a>${booking.meeting_passcode ? `<p class="small">Passcode: <code>${escapeHtml(booking.meeting_passcode)}</code></p>` : ''}</div>` : ''}`,
        footer: '<button type="button" class="btn secondary" data-close>Close</button>'
      });
      return;
    }
    if (action === 'approve') {
      if (!await confirmDialog(`Approve this booking for ${booking.facility?.name || 'the session'}?`, { confirmText: 'Approve' })) return;
      await api.post(`/api/admin/bookings/${encodeURIComponent(booking.id)}/approve`, {});
      toast('Booking approved.', 'success');
    } else if (action === 'reject') {
      const reason = await askReason({ title: 'Reject booking', label: 'Reason shown to the requester', confirmText: 'Reject booking', danger: true });
      if (!reason) return;
      await api.post(`/api/admin/bookings/${encodeURIComponent(booking.id)}/reject`, { reason });
      toast('Booking rejected.', 'success');
    } else if (action === 'cancel') {
      const reason = await askReason({ title: 'Cancel booking', label: 'Cancellation reason', confirmText: 'Cancel booking', danger: true });
      if (!reason) return;
      await api.post(`/api/admin/bookings/${encodeURIComponent(booking.id)}/cancel`, { reason, scope: 'single' });
      toast('Booking cancelled.', 'success');
    } else if (action === 'checkin') {
      if (!await confirmDialog('Record an administrative check-in for this booking?', { confirmText: 'Check in' })) return;
      await api.post(`/api/admin/bookings/${encodeURIComponent(booking.id)}/checkin`, {});
      toast('Check-in recorded.', 'success');
    } else if (action === 'no-show') {
      const reason = await askReason({ title: 'Mark no-show', label: 'Reason', confirmText: 'Mark no-show', danger: true });
      if (!reason) return;
      await api.post(`/api/admin/bookings/${encodeURIComponent(booking.id)}/no-show`, { reason });
      toast('No-show recorded.', 'success');
    }
    await renderAdminBookings();
  } catch (error) {
    notifyError(error);
  }
}

async function loadFacilities() {
  content.innerHTML = `
    ${pageHeader('Rooms and facilities', 'Manage capacity, approvals, QR codes, maintenance, and displays.', '<button class="btn" type="button" id="new-facility">Add room</button><button class="btn secondary" type="button" id="print-all-qr">Print all room QRs</button>')}
    <div class="filters">
      <input type="search" id="facility-search" placeholder="Search building, room, or department" value="${escapeHtml(state.facilityQuery)}">
      <button class="btn secondary" type="button" id="refresh-facilities">Refresh</button>
    </div>
    <div id="admin-facilities"><div class="skeleton"></div></div>`;
  document.getElementById('new-facility').addEventListener('click', () => facilityForm());
  document.getElementById('print-all-qr').addEventListener('click', printRoomSheet);
  document.getElementById('facility-search').addEventListener('input', (event) => {
    state.facilityQuery = event.target.value;
    renderAdminFacilities();
  });
  document.getElementById('refresh-facilities').addEventListener('click', async () => {
    state.facilities = [];
    await loadFacilityDirectory();
    renderAdminFacilities();
  });
  await loadFacilityDirectory();
  renderAdminFacilities();
}

function renderAdminFacilities() {
  const container = document.getElementById('admin-facilities');
  const term = state.facilityQuery.trim().toLowerCase();
  const rooms = state.facilities.filter((room) => !term || [
    room.name, room.building, room.room_number, room.department_name, room.category
  ].filter(Boolean).join(' ').toLowerCase().includes(term));
  if (!rooms.length) {
    container.innerHTML = emptyState('No rooms found', 'Try another search or add a room.');
    return;
  }
  container.innerHTML = `<div class="room-admin-grid">${rooms.map((room) => `
    <article class="card room-admin-card">
      <div class="row space-between" style="align-items:flex-start">
        <div><div class="eyebrow">${escapeHtml(categoryLabels[room.category] || room.category)}</div><h3>${escapeHtml(room.name)}</h3><p class="muted small">${escapeHtml(room.building)} ${escapeHtml(room.room_number)} · ${escapeHtml(room.department_code || '')}</p></div>
        ${badge(room.status === 'active' ? 'confirmed' : room.status === 'maintenance' ? 'pending' : 'cancelled')}
      </div>
      <div class="room-meta"><span>${Number(room.capacity)} seats</span><span>${room.requires_approval ? 'Approval' : 'Instant'}</span><span>${Number(room.session_count || 0)} upcoming</span></div>
      <div class="card-actions"><button class="btn small secondary" type="button" data-manage-facility="${escapeHtml(room.id)}">Manage</button><a class="btn small ghost" href="room.html?id=${encodeURIComponent(room.id)}">View</a></div>
    </article>`).join('')}</div>`;
  container.querySelectorAll('[data-manage-facility]').forEach((button) => {
    button.addEventListener('click', () => manageFacility(button.dataset.manageFacility));
  });
}

function facilityForm(room = null) {
  const editing = Boolean(room);
  const modal = openModal({
    title: editing ? 'Edit room' : 'Add room',
    content: `
      <form id="facility-form">
        <div class="field"><label>Name</label><input name="name" required maxlength="200" value="${escapeHtml(room?.name || '')}"></div>
        <div class="field-row">
          <div class="field"><label>Category</label><select name="category">${Object.entries(categoryLabels).map(([value, label]) => option(value, label, room?.category === value)).join('')}</select></div>
          <div class="field"><label>Department</label><select name="department_id" required>${departmentOptions(room?.department_id || state.me.department_id)}</select></div>
        </div>
        <div class="field-row">
          <div class="field"><label>Building</label><input name="building" required maxlength="100" value="${escapeHtml(room?.building || '')}"></div>
          <div class="field"><label>Room number</label><input name="room_number" required maxlength="50" value="${escapeHtml(room?.room_number || '')}"></div>
        </div>
        <div class="field-row">
          <div class="field"><label>Floor</label><input name="floor" maxlength="50" value="${escapeHtml(room?.floor || 'Ground')}"></div>
          <div class="field"><label>Wing</label><input name="wing" maxlength="100" value="${escapeHtml(room?.wing || '')}"></div>
        </div>
        <div class="field"><label>Location description</label><input name="location_description" maxlength="1000" value="${escapeHtml(room?.location_description || '')}"></div>
        <div class="field-row">
          <div class="field"><label>Latitude</label><input name="latitude" type="number" step="any" min="-90" max="90" required value="${escapeHtml(room?.latitude ?? '0.3476')}"></div>
          <div class="field"><label>Longitude</label><input name="longitude" type="number" step="any" min="-180" max="180" required value="${escapeHtml(room?.longitude ?? '32.5825')}"></div>
        </div>
        <div class="field-row">
          <div class="field"><label>Capacity</label><input name="capacity" type="number" min="1" max="10000" required value="${escapeHtml(room?.capacity ?? 40)}"></div>
          <div class="field"><label>Status</label><select name="status">${['active', 'maintenance', 'blocked'].map((value) => option(value, value, (room?.status || 'active') === value)).join('')}</select></div>
        </div>
        <div class="field-row">
          <div class="field"><label>Check-in mode</label><select name="checkin_mode">${['static_geo', 'rotating'].map((value) => option(value, value === 'static_geo' ? 'Location radius' : 'Door QR', (room?.checkin_mode || 'static_geo') === value)).join('')}</select></div>
          <div class="field"><label>Radius (metres)</label><input name="checkin_radius_m" type="number" min="10" max="5000" value="${escapeHtml(room?.checkin_radius_m ?? 100)}"></div>
        </div>
        <div class="field"><label>Equipment</label><textarea name="equipment" rows="2" placeholder="Projector:1&#10;Whiteboard:2">${escapeHtml((room?.equipment || []).map((item) => `${item.name}:${item.quantity}`).join('\n'))}</textarea><p class="hint">One item per line as Name:Quantity.</p></div>
        <div class="field"><label>Photo URL (optional)</label><input name="photo_url" type="url" value="${escapeHtml(room?.photo_url || '')}"></div>
        <label class="check"><input type="checkbox" name="requires_approval" ${room?.requires_approval ? 'checked' : ''}> <span>Require administrator approval</span></label>
        <label class="check"><input type="checkbox" name="requires_authorized_role" ${room?.requires_authorized_role ? 'checked' : ''}> <span>Only allow authorised roles</span></label>
        <p class="error-text hidden" data-error></p>
        <button class="btn wide" type="submit">${editing ? 'Save changes' : 'Create room'}</button>
      </form>`,
    footer: '<button type="button" class="btn secondary" data-close>Cancel</button>'
  });
  const form = modal.body.querySelector('#facility-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    const errorBox = form.querySelector('[data-error]');
    errorBox.classList.add('hidden');
    const data = new FormData(form);
    const equipment = String(data.get('equipment') || '').split('\n').map((line) => line.trim()).filter(Boolean).map((line) => {
      const [name, quantity] = line.split(':');
      return { name: name.trim(), quantity: Number(quantity || 1) };
    });
    const payload = {
      name: data.get('name'),
      category: data.get('category'),
      department_id: data.get('department_id'),
      building: data.get('building'),
      floor: data.get('floor') || 'Ground',
      wing: data.get('wing') || null,
      room_number: data.get('room_number'),
      location_description: data.get('location_description') || '',
      latitude: Number(data.get('latitude')),
      longitude: Number(data.get('longitude')),
      capacity: Number(data.get('capacity')),
      status: data.get('status'),
      checkin_mode: data.get('checkin_mode'),
      checkin_radius_m: Number(data.get('checkin_radius_m')),
      requires_approval: data.get('requires_approval') === 'on',
      requires_authorized_role: data.get('requires_authorized_role') === 'on',
      photo_url: data.get('photo_url') || null,
      equipment
    };
    setButtonLoading(button, true, 'Saving...');
    try {
      const result = await api[
        editing ? 'patch' : 'post'
      ](`/api/admin/facilities${editing ? `/${encodeURIComponent(room.id)}` : ''}`, payload);
      modal.close();
      state.facilities = [];
      await loadFacilityDirectory();
      renderAdminFacilities();
      toast(editing ? 'Room updated.' : 'Room created.', 'success');
      if (!editing && result.room_qr_url) {
        openModal({
          title: 'Room created',
          content: `<p>The room is ready. Print its QR code now — the code is required for walk-up use and door check-in.</p><p class="small" style="word-break:break-all"><code>${escapeHtml(result.room_qr_url)}</code></p>`,
          footer: `<button type="button" class="btn" data-copy-qr>Copy link</button><button type="button" class="btn secondary" data-close>Close</button>`
        }).root.querySelector('[data-copy-qr]').addEventListener('click', () => copyText(result.room_qr_url));
      }
    } catch (error) {
      errorBox.textContent = error.message;
      errorBox.classList.remove('hidden');
    } finally {
      setButtonLoading(button, false);
    }
  });
}

async function manageFacility(id) {
  const modal = openModal({
    title: 'Room details',
    content: '<div class="skeleton"></div><div class="skeleton"></div>',
    footer: '<button type="button" class="btn secondary" data-close>Close</button>'
  });
  try {
    const result = await api.get(`/api/admin/facilities/${encodeURIComponent(id)}`);
    const room = { ...result.facility, equipment: result.equipment || [] };
    const blocks = result.blocks || [];
    const displays = result.displays || [];
    modal.body.innerHTML = `
      <div class="detail-grid">
        <div><span>Room</span><div>${escapeHtml(room.name)}</div></div>
        <div><span>Location</span><div>${escapeHtml(room.building)} ${escapeHtml(room.room_number)} · ${escapeHtml(room.floor || '')}</div></div>
        <div><span>Capacity</span><div>${Number(room.capacity)} seats</div></div>
        <div><span>Department</span><div>${escapeHtml(state.departments.find((item) => item.id === room.department_id)?.name || '')}</div></div>
        <div><span>Check-in</span><div>${escapeHtml(room.checkin_mode)} · ${Number(room.checkin_radius_m)}m</div></div>
        <div><span>QR version</span><div>${Number(room.qr_version)}</div></div>
      </div>
      <div class="card-actions" style="margin-top:.8rem">
        <button class="btn small" type="button" data-facility-action="edit">Edit</button>
        <button class="btn small secondary" type="button" data-facility-action="block">Add maintenance block</button>
        <button class="btn small secondary" type="button" data-facility-action="display">Create display</button>
        <button class="btn small ghost" type="button" data-facility-action="qr">Print room QR</button>
        <button class="btn small ghost danger-text" type="button" data-facility-action="regenerate">Regenerate QR</button>
      </div>
      <p class="small" style="margin-top:.8rem;word-break:break-all"><a href="${escapeHtml(result.room_qr_url)}" target="_blank" rel="noopener">Room QR link</a></p>
      <h3 style="margin-top:1rem">Equipment</h3>
      ${room.equipment.length ? `<div class="chips">${room.equipment.map((item) => `<span class="chip">${escapeHtml(item.name)} x${Number(item.quantity)}</span>`).join('')}</div>` : '<p class="muted small">None listed.</p>'}
      <h3 style="margin-top:1rem">Maintenance blocks</h3>
      ${blocks.length ? `<div class="list">${blocks.map((block) => `
        <div class="list-item"><div class="main"><h3>${escapeHtml(block.reason)}</h3><p>${escapeHtml(formatRange(block.start_at, block.end_at))}</p></div><button class="btn ghost small danger-text" type="button" data-remove-block="${escapeHtml(block.id)}">Remove</button></div>`).join('')}</div>` : '<p class="muted small">No upcoming blocks.</p>'}
      <h3 style="margin-top:1rem">Door displays</h3>
      ${displays.length ? `<div class="list">${displays.map((display) => `
        <div class="list-item"><div class="main"><h3>${escapeHtml(display.label)}</h3><p>${display.last_seen_at ? `Last seen ${escapeHtml(formatDate(display.last_seen_at, { dateStyle: 'medium', timeStyle: 'short' }))}` : 'Never connected'}${display.revoked_at ? ' · revoked' : ''}</p></div>${display.revoked_at ? '' : `<button class="btn ghost small danger-text" type="button" data-revoke-display="${escapeHtml(display.id)}">Revoke</button>`}</div>`).join('')}</div>` : '<p class="muted small">No displays yet.</p>'}`;
    modal.body.querySelectorAll('[data-facility-action]').forEach((button) => {
      button.addEventListener('click', () => {
        const action = button.dataset.facilityAction;
        if (action === 'edit') facilityForm(room);
        else if (action === 'block') addFacilityBlock(room.id, modal);
        else if (action === 'display') createDisplay(room.id);
        else if (action === 'qr') printRoomSheet(room.id);
        else if (action === 'regenerate') regenerateRoomQr(room, modal);
      });
    });
    modal.body.querySelectorAll('[data-remove-block]').forEach((button) => {
      button.addEventListener('click', async () => {
        if (!await confirmDialog('Remove this maintenance block?', { confirmText: 'Remove', danger: true })) return;
        try {
          await api.delete(`/api/admin/facilities/${encodeURIComponent(room.id)}/blocks/${encodeURIComponent(button.dataset.removeBlock)}`);
          modal.close();
          toast('Maintenance block removed.', 'success');
          manageFacility(room.id);
        } catch (error) {
          notifyError(error);
        }
      });
    });
    modal.body.querySelectorAll('[data-revoke-display]').forEach((button) => {
      button.addEventListener('click', async () => {
        if (!await confirmDialog('Revoke this door display? It will stop updating immediately.', { confirmText: 'Revoke', danger: true })) return;
        try {
          await api.delete(`/api/admin/displays/${encodeURIComponent(button.dataset.revokeDisplay)}`);
          modal.close();
          toast('Display revoked.', 'success');
          manageFacility(room.id);
        } catch (error) {
          notifyError(error);
        }
      });
    });
  } catch (error) {
    modal.body.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  }
}

function addFacilityBlock(id, parentModal) {
  const modal = openModal({
    title: 'Add maintenance block',
    content: `
      <form id="block-form">
        <div class="field"><label>Starts</label><input type="datetime-local" name="start_at" required></div>
        <div class="field"><label>Ends</label><input type="datetime-local" name="end_at" required></div>
        <div class="field"><label>Reason</label><input name="reason" required maxlength="500" placeholder="e.g. Electrical maintenance"></div>
        <p class="error-text hidden" data-error></p>
        <button class="btn wide" type="submit">Add block</button>
      </form>`,
    footer: '<button type="button" class="btn secondary" data-close>Cancel</button>'
  });
  const form = modal.body.querySelector('#block-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    const data = Object.fromEntries(new FormData(form).entries());
    setButtonLoading(button, true, 'Adding...');
    try {
      const result = await api.post(`/api/admin/facilities/${encodeURIComponent(id)}/blocks`, {
        start_at: new Date(data.start_at).toISOString(),
        end_at: new Date(data.end_at).toISOString(),
        reason: data.reason
      });
      modal.close();
      parentModal.close();
      toast(result.conflicting_bookings?.length ? `Block added. ${result.conflicting_bookings.length} conflicting bookings need attention.` : 'Maintenance block added.', 'success');
      manageFacility(id);
    } catch (error) {
      setButtonLoading(button, false);
      const box = form.querySelector('[data-error]');
      box.textContent = error.message;
      box.classList.remove('hidden');
    }
  });
}

async function printRoomSheet(id = null) {
  try {
    const html = await api.text('/api/admin/facilities/qr-sheet');
    openHtml(html);
  } catch (error) {
    notifyError(error);
  }
}

async function regenerateRoomQr(room, parentModal) {
  const confirmed = await confirmDialog('Regenerating the QR invalidates every printed code for this room. Continue?', { title: 'Regenerate room QR', confirmText: 'Regenerate', danger: true });
  if (!confirmed) return;
  try {
    const result = await api.post(`/api/admin/facilities/${encodeURIComponent(room.id)}/regenerate-qr`, {});
    parentModal.close();
    openModal({
      title: 'QR regenerated',
      content: `<div class="notice warning">${escapeHtml(result.warning)}</div><p class="small" style="word-break:break-all;margin-top:.7rem"><code>${escapeHtml(result.room_qr_url)}</code></p>`,
      footer: `<button class="btn" type="button" data-copy>Copy link</button><button class="btn secondary" type="button" data-close>Close</button>`
    }).root.querySelector('[data-copy]').addEventListener('click', () => copyText(result.room_qr_url));
  } catch (error) {
    notifyError(error);
  }
}

function createDisplay(id) {
  const modal = openModal({
    title: 'Create door display',
    content: `
      <form id="display-form">
        <div class="field"><label>Display label</label><input name="label" required maxlength="100" placeholder="e.g. Hall 3 entrance"></div>
        <p class="hint">The display key is shown once. Store it before closing the dialog.</p>
        <p class="error-text hidden" data-error></p>
        <button class="btn wide" type="submit">Create display</button>
      </form>`,
    footer: '<button type="button" class="btn secondary" data-close>Cancel</button>'
  });
  const form = modal.body.querySelector('#display-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    setButtonLoading(button, true, 'Creating...');
    try {
      const data = Object.fromEntries(new FormData(form).entries());
      const result = await api.post(`/api/admin/facilities/${encodeURIComponent(id)}/displays`, { label: data.label });
      modal.close();
      openModal({
        title: 'Display created',
        content: `
          <div class="notice warning">${escapeHtml(result.warning)}</div>
          <p class="small" style="margin-top:.7rem">Display URL</p><p class="small" style="word-break:break-all"><code>${escapeHtml(result.display_url)}</code></p>
          <p class="small" style="margin-top:.6rem">Display key</p><p class="small" style="word-break:break-all"><code>${escapeHtml(result.key)}</code></p>`,
        footer: '<button type="button" class="btn secondary" data-close>Close</button>'
      });
    } catch (error) {
      setButtonLoading(button, false);
      const box = form.querySelector('[data-error]');
      box.textContent = error.message;
      box.classList.remove('hidden');
    }
  });
}

async function loadUsers() {
  content.innerHTML = `
    ${pageHeader('Users', 'Create accounts, issue ID cards, and manage access.', '<button class="btn" type="button" id="new-user">Add user</button><button class="btn secondary" type="button" id="import-users">Import CSV</button>')}
    <div class="filters">
      <input type="search" id="user-search" placeholder="Search name, ID number, or email" value="${escapeHtml(state.userQuery)}">
      <select id="user-role-filter">${option('', 'All roles', !state.userRole)}${roleOptions.map((role) => option(role, roleLabel(role), state.userRole === role)).join('')}</select>
    </div>
    <div id="admin-users"><div class="skeleton"></div></div>`;
  document.getElementById('new-user').addEventListener('click', createUserForm);
  document.getElementById('import-users').addEventListener('click', importUsersForm);
  document.getElementById('user-search').addEventListener('input', (event) => {
    state.userQuery = event.target.value;
    clearTimeout(loadUsers.timer);
    loadUsers.timer = setTimeout(renderAdminUsers, 250);
  });
  document.getElementById('user-role-filter').addEventListener('change', (event) => {
    state.userRole = event.target.value;
    renderAdminUsers();
  });
  await renderAdminUsers();
}

async function renderAdminUsers() {
  const container = document.getElementById('admin-users');
  if (!container) return;
  container.innerHTML = '<div class="skeleton"></div>';
  try {
    const result = await api.get(`/api/admin/users${queryString({
      q: state.userQuery || undefined,
      role: state.userRole || undefined,
      limit: 300
    })}`);
    const users = result.users || [];
    if (!users.length) {
      container.innerHTML = emptyState('No users found', 'Try a different search.');
      return;
    }
    container.innerHTML = `<p class="small muted">${users.length} user${users.length === 1 ? '' : 's'}</p><div class="list">${users.map((user) => `
      <div class="list-item" data-user="${escapeHtml(user.id)}">
        <span class="avatar">${escapeHtml((user.name || '?').slice(0, 2).toUpperCase())}</span>
        <div class="main">
          <div class="chips" style="margin-bottom:.2rem">${user.is_active ? '' : '<span class="badge red">Inactive</span>'}${user.flagged_for_review ? '<span class="badge amber">Flagged</span>' : ''}</div>
          <h3>${escapeHtml(user.name)}</h3>
          <p>${escapeHtml(user.id_number)} · ${escapeHtml(roleLabel(user.role))}${user.class_code ? ` · ${escapeHtml(user.class_code)}` : ''}${user.department_code ? ` · ${escapeHtml(user.department_code)}` : ''}</p>
          <p>${escapeHtml(user.email)}</p>
        </div>
        <button class="btn ghost small" type="button" data-manage-user>Manage</button>
      </div>`).join('')}</div>`;
    container.querySelectorAll('[data-user]').forEach((row) => {
      row.querySelector('[data-manage-user]').addEventListener('click', () => manageUser(users.find((item) => item.id === row.dataset.user)));
    });
  } catch (error) {
    container.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  }
}

function userFormFields(user = null) {
  return `
    <div class="field-row">
      <div class="field"><label>ID number</label><input name="id_number" required maxlength="50" value="${escapeHtml(user?.id_number || '')}" ${user ? 'disabled' : ''}></div>
      <div class="field"><label>Full name</label><input name="name" required maxlength="200" value="${escapeHtml(user?.name || '')}"></div>
    </div>
    <div class="field"><label>Email</label><input name="email" type="email" required maxlength="200" value="${escapeHtml(user?.email || '')}"></div>
    <div class="field-row">
      <div class="field"><label>Phone (optional)</label><input name="phone" type="tel" maxlength="30" value="${escapeHtml(user?.phone || '')}"></div>
      <div class="field"><label>Role</label><select name="role" id="user-form-role">${roleOptions.map((role) => option(role, roleLabel(role), (user?.role || 'student') === role)).join('')}</select></div>
    </div>
    <div class="field-row">
      <div class="field"><label>Department</label><select name="department_id">${departmentOptions(user?.department_id || '')}</select></div>
      <div class="field"><label>Class</label><select name="class_id">${classOptions(user?.class_id || '')}</select></div>
    </div>
    <div class="field-row">
      <div class="field"><label>Study mode</label><select name="study_mode">${['physical', 'online', 'hybrid'].map((mode) => option(mode, mode, (user?.study_mode || 'physical') === mode)).join('')}</select></div>
      ${user ? `<div class="field"><label>Account status</label><select name="is_active">${option('true', 'Active', user.is_active)}${option('false', 'Inactive', !user.is_active)}</select></div>` : '<div></div>'}
    </div>
    ${user ? `<label class="check"><input type="checkbox" name="flagged_for_review" ${user.flagged_for_review ? 'checked' : ''}> <span>Flag for review</span></label>` : ''}`;
}

function createUserForm() {
  const modal = openModal({
    title: 'Create user',
    content: `<form id="user-form">${userFormFields()}<p class="error-text hidden" data-error></p><button class="btn wide" type="submit">Create account</button></form>`,
    footer: '<button type="button" class="btn secondary" data-close>Cancel</button>'
  });
  const form = modal.body.querySelector('#user-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    const data = new FormData(form);
    setButtonLoading(button, true, 'Creating...');
    try {
      const result = await api.post('/api/admin/users', {
        id_number: data.get('id_number'),
        name: data.get('name'),
        email: data.get('email'),
        phone: data.get('phone') || undefined,
        role: data.get('role'),
        department_id: data.get('department_id') || null,
        class_id: data.get('class_id') || null,
        study_mode: data.get('study_mode')
      });
      modal.close();
      await renderAdminUsers();
      openModal({
        title: 'Account created',
        content: `
          ${result.email_sent ? '<p class="small" style="color:var(--success)">Activation email sent.</p>' : `<div class="notice warning">Activation email was not sent${result.email_error ? `: ${escapeHtml(result.email_error)}` : '.'}</div>`}
          <p class="small" style="margin-top:.7rem">Activation link</p><p class="small" style="word-break:break-all"><code>${escapeHtml(result.activation_link)}</code></p>
          <p class="small" style="margin-top:.6rem">ID QR token</p><p class="small" style="word-break:break-all"><code>${escapeHtml(result.id_qr_token)}</code></p>`,
        footer: '<button type="button" class="btn secondary" data-close>Close</button>'
      });
    } catch (error) {
      setButtonLoading(button, false);
      const box = form.querySelector('[data-error]');
      box.textContent = error.message;
      box.classList.remove('hidden');
    }
  });
}

function importUsersForm() {
  const modal = openModal({
    title: 'Import users from CSV',
    content: `
      <p class="muted small">Include headers: id_number, name, email, phone, role, department_code, class_code, study_mode. Maximum 300 rows.</p>
      <form id="import-form" style="margin-top:.7rem">
        <div class="field"><label>CSV content</label><textarea name="csv" rows="10" required placeholder="id_number,name,email,phone,role,department_code,class_code,study_mode"></textarea></div>
        <p class="error-text hidden" data-error></p>
        <button class="btn wide" type="submit">Import users</button>
      </form>
      <div id="import-result" style="margin-top:.8rem"></div>`,
    footer: '<button type="button" class="btn secondary" data-close>Close</button>'
  });
  const form = modal.body.querySelector('#import-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    const resultBox = modal.body.querySelector('#import-result');
    setButtonLoading(button, true, 'Importing...');
    try {
      const result = await api.post('/api/admin/users/import', { csv: form.querySelector('textarea').value });
      resultBox.innerHTML = `<div class="notice ${result.failed ? 'warning' : 'success'}">${result.created} created, ${result.failed} failed of ${result.total}.</div>${(result.results || []).filter((item) => item.status === 'failed').map((item) => `<p class="small danger-text">Line ${item.line}: ${escapeHtml(item.error)}</p>`).join('')}`;
      await renderAdminUsers();
    } catch (error) {
      setButtonLoading(button, false);
      const box = form.querySelector('[data-error]');
      box.textContent = error.message;
      box.classList.remove('hidden');
    }
  });
}

async function manageUser(user) {
  const modal = openModal({
    title: user.name,
    content: '<div class="skeleton"></div><div class="skeleton"></div>',
    footer: '<button type="button" class="btn secondary" data-close>Close</button>'
  });
  try {
    const result = await api.get(`/api/admin/users/${encodeURIComponent(user.id)}`);
    const detail = result.user;
    const counts = result.booking_counts || {};
    modal.body.innerHTML = `
      <div class="detail-grid">
        <div><span>ID number</span><div>${escapeHtml(detail.id_number)}</div></div>
        <div><span>Role</span><div>${escapeHtml(roleLabel(detail.role))}</div></div>
        <div><span>Email</span><div>${escapeHtml(detail.email)}</div></div>
        <div><span>Phone</span><div>${escapeHtml(detail.phone || '-')}</div></div>
        <div><span>Department</span><div>${escapeHtml(detail.department_name || '-')}</div></div>
        <div><span>Class</span><div>${escapeHtml(detail.class_name || '-')}</div></div>
        <div><span>Study mode</span><div>${escapeHtml(detail.study_mode)}</div></div>
        <div><span>Bookings</span><div>${Number(counts.total || 0)} total · ${Number(counts.upcoming || 0)} upcoming</div></div>
      </div>
      ${(result.no_shows || []).length ? `<h3 style="margin-top:.8rem">Recent no-shows</h3><div class="list">${result.no_shows.slice(0, 5).map((item) => `<div class="list-item"><div class="main"><h3>${escapeHtml(formatDate(item.marked_at, { dateStyle: 'medium' }))}</h3><p>${escapeHtml(item.reason || '')}</p></div></div>`).join('')}</div>` : ''}
      <div class="card-actions" style="margin-top:.9rem">
        <button class="btn small" type="button" data-user-action="edit">Edit</button>
        <button class="btn small secondary" type="button" data-user-action="id-card">Print ID card</button>
        <button class="btn small ghost" type="button" data-user-action="reset">Reset password</button>
        <button class="btn small ghost" type="button" data-user-action="unlock">Unlock</button>
        <button class="btn small ghost danger-text" type="button" data-user-action="revoke">Revoke sessions</button>
      </div>`;
    modal.body.querySelectorAll('[data-user-action]').forEach((button) => {
      button.addEventListener('click', async () => {
        const action = button.dataset.userAction;
        try {
          if (action === 'edit') {
            modal.close();
            editUserForm(detail);
          } else if (action === 'id-card') {
            const response = await api.post('/api/admin/users/id-cards', { user_ids: [detail.id] }, { raw: true });
            openHtml(await response.text());
          } else if (action === 'reset') {
            if (!await confirmDialog('Create a password reset link for this user?', { confirmText: 'Create reset link' })) return;
            const reset = await api.post(`/api/admin/users/${encodeURIComponent(detail.id)}/reset-password`, {});
            modal.close();
            openModal({
              title: 'Password reset',
              content: `<div class="notice ${reset.sent ? 'success' : 'warning'}">${reset.sent ? 'Reset email sent.' : 'Email could not be sent. Share this link securely.'}</div><p class="small" style="word-break:break-all;margin-top:.7rem"><code>${escapeHtml(reset.reset_link)}</code></p>`,
              footer: '<button type="button" class="btn secondary" data-close>Close</button>'
            });
          } else if (action === 'unlock') {
            await api.post(`/api/admin/users/${encodeURIComponent(detail.id)}/unlock`, {});
            toast('Account unlocked.', 'success');
            modal.close();
          } else if (action === 'revoke') {
            if (!await confirmDialog('End every active session for this user?', { confirmText: 'Revoke sessions', danger: true })) return;
            const revoked = await api.post(`/api/admin/users/${encodeURIComponent(detail.id)}/revoke-sessions`, {});
            toast(`${Number(revoked.revoked || 0)} session(s) revoked.`, 'success');
            modal.close();
          }
        } catch (error) {
          notifyError(error);
        }
      });
    });
  } catch (error) {
    modal.body.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  }
}

function editUserForm(user) {
  const modal = openModal({
    title: 'Edit user',
    content: `<form id="edit-user-form">${userFormFields(user)}<div class="field"><label>Flag reason</label><textarea name="flagged_reason" rows="2" maxlength="1000">${escapeHtml(user.flagged_reason || '')}</textarea></div><p class="error-text hidden" data-error></p><button class="btn wide" type="submit">Save changes</button></form>`,
    footer: '<button type="button" class="btn secondary" data-close>Cancel</button>'
  });
  const form = modal.body.querySelector('#edit-user-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    const data = new FormData(form);
    setButtonLoading(button, true, 'Saving...');
    try {
      await api.patch(`/api/admin/users/${encodeURIComponent(user.id)}`, {
        name: data.get('name'),
        role: data.get('role'),
        department_id: data.get('department_id') || null,
        class_id: data.get('class_id') || null,
        study_mode: data.get('study_mode'),
        is_active: data.get('is_active') === 'true',
        flagged_for_review: data.get('flagged_for_review') === 'on',
        flagged_reason: data.get('flagged_reason') || null
      });
      modal.close();
      toast('User updated.', 'success');
      await renderAdminUsers();
    } catch (error) {
      setButtonLoading(button, false);
      const box = form.querySelector('[data-error]');
      box.textContent = error.message;
      box.classList.remove('hidden');
    }
  });
}

async function loadIssues() {
  content.innerHTML = `
    ${pageHeader('Room issues', 'Triage reports from students and staff.')}
    <div class="filters"><select id="issue-status-filter">${['all', 'open', 'acknowledged', 'resolved'].map((value) => option(value, value, value === state.issueStatus)).join('')}</select><button class="btn secondary" type="button" id="refresh-issues">Refresh</button></div>
    <div id="admin-issues"><div class="skeleton"></div></div>`;
  document.getElementById('issue-status-filter').addEventListener('change', (event) => {
    state.issueStatus = event.target.value;
    renderIssues();
  });
  document.getElementById('refresh-issues').addEventListener('click', renderIssues);
  await renderIssues();
}

async function renderIssues() {
  const container = document.getElementById('admin-issues');
  if (!container) return;
  container.innerHTML = '<div class="skeleton"></div>';
  try {
    const result = await api.get(`/api/admin/issues${queryString({ status: state.issueStatus === 'all' ? undefined : state.issueStatus })}`);
    const issues = result.issues || [];
    container.innerHTML = issues.length ? `<div class="list">${issues.map((issue) => `
      <div class="list-item">
        <span class="item-icon">${icon('alert')}</span>
        <div class="main">
          <div class="chips" style="margin-bottom:.2rem">${badge(issue.status === 'resolved' ? 'confirmed' : issue.status === 'open' ? 'pending' : 'blocked', issue.status)}</div>
          <h3>${escapeHtml(issue.facility_name)} · ${escapeHtml(issue.category)}</h3>
          <p>${escapeHtml(issue.description)}</p>
          <p class="small muted">${escapeHtml(issue.reporter_name)} (${escapeHtml(issue.reporter_id_number)}) · ${escapeHtml(formatDate(issue.created_at, { dateStyle: 'medium', timeStyle: 'short' }))}</p>
        </div>
        <button class="btn ghost small" type="button" data-issue="${escapeHtml(issue.id)}">Open</button>
      </div>`).join('')}</div>` : emptyState('No issues', 'Reports submitted from room pages will appear here.');
    container.querySelectorAll('[data-issue]').forEach((button) => {
      button.addEventListener('click', () => openIssue(issues.find((item) => item.id === button.dataset.issue)));
    });
  } catch (error) {
    container.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  }
}

function openIssue(issue) {
  if (!issue) return;
  const modal = openModal({
    title: `${issue.facility_name} issue`,
    content: `
      <div class="detail-grid">
        <div><span>Category</span><div>${escapeHtml(issue.category)}</div></div>
        <div><span>Status</span><div>${escapeHtml(issue.status)}</div></div>
        <div><span>Reported by</span><div>${escapeHtml(issue.reporter_name)} (${escapeHtml(issue.reporter_id_number)})</div></div>
        <div><span>When</span><div>${escapeHtml(formatDate(issue.created_at, { dateStyle: 'medium', timeStyle: 'short' }))}</div></div>
      </div>
      <p style="margin-top:.7rem">${escapeHtml(issue.description)}</p>
      ${issue.photo_data ? `<img src="${escapeHtml(issue.photo_data)}" alt="Issue photo" style="max-width:100%;border-radius:12px;margin-top:.7rem">` : ''}
      <form id="issue-update-form" style="margin-top:.8rem">
        <div class="field"><label>New status</label><select name="status">${['open', 'acknowledged', 'resolved'].map((value) => option(value, value, issue.status === value)).join('')}</select></div>
        <div class="field"><label>Note to reporter (optional)</label><textarea name="note" rows="2" maxlength="1000"></textarea></div>
        <p class="error-text hidden" data-error></p>
        <button class="btn wide" type="submit">Update issue</button>
      </form>`,
    footer: '<button type="button" class="btn secondary" data-close>Close</button>'
  });
  const form = modal.body.querySelector('#issue-update-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    const data = Object.fromEntries(new FormData(form).entries());
    setButtonLoading(button, true, 'Updating...');
    try {
      await api.patch(`/api/admin/issues/${encodeURIComponent(issue.id)}`, { status: data.status, note: data.note || undefined });
      modal.close();
      toast('Issue updated and reporter notified.', 'success');
      await renderIssues();
    } catch (error) {
      setButtonLoading(button, false);
      const box = form.querySelector('[data-error]');
      box.textContent = error.message;
      box.classList.remove('hidden');
    }
  });
}

async function loadStudyRequests() {
  content.innerHTML = `
    ${pageHeader('Study mode requests', 'Review requests to change how a student attends classes.')}
    <div class="filters"><select id="study-status-filter">${['all', 'pending', 'approved', 'rejected'].map((value) => option(value, value, value === state.studyStatus)).join('')}</select><button class="btn secondary" type="button" id="refresh-study">Refresh</button></div>
    <div id="admin-study"><div class="skeleton"></div></div>`;
  document.getElementById('study-status-filter').addEventListener('change', (event) => {
    state.studyStatus = event.target.value;
    renderStudyRequests();
  });
  document.getElementById('refresh-study').addEventListener('click', renderStudyRequests);
  await renderStudyRequests();
}

async function renderStudyRequests() {
  const container = document.getElementById('admin-study');
  if (!container) return;
  container.innerHTML = '<div class="skeleton"></div>';
  try {
    const result = await api.get(`/api/admin/study-mode-requests${queryString({ status: state.studyStatus === 'all' ? undefined : state.studyStatus })}`);
    const requests = result.requests || [];
    container.innerHTML = requests.length ? `<div class="list">${requests.map((request) => `
      <div class="list-item">
        <span class="item-icon">${escapeHtml((request.requested_mode || '?').slice(0, 1).toUpperCase())}</span>
        <div class="main">
          ${badge(request.status === 'approved' ? 'confirmed' : request.status === 'rejected' ? 'cancelled' : 'pending', request.status)}
          <h3>${escapeHtml(request.user_name)} (${escapeHtml(request.id_number)})</h3>
          <p>${escapeHtml(request.current_mode)} to ${escapeHtml(request.requested_mode)} · ${escapeHtml(request.reason)}</p>
          <p class="small muted">${escapeHtml(formatDate(request.created_at, { dateStyle: 'medium' }))}</p>
        </div>
        ${request.status === 'pending' ? `<button class="btn ghost small" type="button" data-study="${escapeHtml(request.id)}">Review</button>` : ''}
      </div>`).join('')}</div>` : emptyState('No study mode requests', 'New requests will appear here.');
    container.querySelectorAll('[data-study]').forEach((button) => {
      button.addEventListener('click', () => decideStudy(requests.find((item) => item.id === button.dataset.study)));
    });
  } catch (error) {
    container.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  }
}

function decideStudy(request) {
  if (!request) return;
  const modal = openModal({
    title: 'Decide study mode request',
    content: `
      <p><strong>${escapeHtml(request.user_name)}</strong> requests ${escapeHtml(request.requested_mode)} mode.</p>
      <p class="muted small">${escapeHtml(request.reason)}</p>
      <form id="study-decide-form" style="margin-top:.7rem">
        <div class="field"><label>Decision</label><select name="decision">${option('approved', 'Approve')}${option('rejected', 'Reject')}</select></div>
        <div class="field"><label>Note (optional)</label><textarea name="note" rows="2" maxlength="1000"></textarea></div>
        <p class="error-text hidden" data-error></p>
        <button class="btn wide" type="submit">Save decision</button>
      </form>`,
    footer: '<button type="button" class="btn secondary" data-close>Cancel</button>'
  });
  const form = modal.body.querySelector('#study-decide-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    const data = Object.fromEntries(new FormData(form).entries());
    setButtonLoading(button, true, 'Saving...');
    try {
      await api.post(`/api/admin/study-mode-requests/${encodeURIComponent(request.id)}/decide`, { decision: data.decision, note: data.note || undefined });
      modal.close();
      toast('Decision saved and student notified.', 'success');
      await renderStudyRequests();
    } catch (error) {
      setButtonLoading(button, false);
      const box = form.querySelector('[data-error]');
      box.textContent = error.message;
      box.classList.remove('hidden');
    }
  });
}

async function loadDataRequests() {
  content.innerHTML = `
    ${pageHeader('Data requests', 'Process privacy exports and deletion requests.')}
    <div class="filters"><select id="data-status-filter">${['all', 'pending', 'processing', 'completed', 'rejected'].map((value) => option(value, value, value === state.dataStatus)).join('')}</select><button class="btn secondary" type="button" id="refresh-data">Refresh</button></div>
    <div id="admin-data"><div class="skeleton"></div></div>`;
  document.getElementById('data-status-filter').addEventListener('change', (event) => {
    state.dataStatus = event.target.value;
    renderDataRequests();
  });
  document.getElementById('refresh-data').addEventListener('click', renderDataRequests);
  await renderDataRequests();
}

async function renderDataRequests() {
  const container = document.getElementById('admin-data');
  if (!container) return;
  container.innerHTML = '<div class="skeleton"></div>';
  try {
    const result = await api.get(`/api/admin/data-requests${queryString({ status: state.dataStatus === 'all' ? undefined : state.dataStatus })}`);
    const requests = result.requests || [];
    container.innerHTML = requests.length ? `<div class="list">${requests.map((request) => `
      <div class="list-item">
        <span class="item-icon">${request.type === 'deletion' ? '×' : '↓'}</span>
        <div class="main">
          ${badge(request.status === 'completed' ? 'confirmed' : request.status === 'rejected' ? 'cancelled' : 'pending', request.status)}
          <h3>${escapeHtml(request.user_name)} (${escapeHtml(request.id_number)})</h3>
          <p>${escapeHtml(request.type)} request · ${escapeHtml(formatDate(request.requested_at, { dateStyle: 'medium' }))}</p>
          ${request.notes ? `<p class="small">${escapeHtml(request.notes)}</p>` : ''}
        </div>
        <button class="btn ghost small" type="button" data-data-request="${escapeHtml(request.id)}">Process</button>
      </div>`).join('')}</div>` : emptyState('No data requests', 'Privacy requests will appear here.');
    container.querySelectorAll('[data-data-request]').forEach((button) => {
      button.addEventListener('click', () => processDataRequest(requests.find((item) => item.id === button.dataset.dataRequest)));
    });
  } catch (error) {
    container.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  }
}

function processDataRequest(request) {
  if (!request) return;
  const modal = openModal({
    title: 'Process data request',
    content: `
      <p><strong>${escapeHtml(request.user_name)}</strong> · ${escapeHtml(request.type)} request</p>
      ${request.type === 'deletion' ? '<div class="notice warning">Completing deletion anonymises the account and cannot be undone. Only a super administrator can complete it.</div>' : ''}
      <form id="data-process-form" style="margin-top:.7rem">
        <div class="field"><label>New status</label><select name="status">${['processing', 'completed', 'rejected'].map((value) => option(value, value, request.status === value)).join('')}</select></div>
        <div class="field"><label>Notes</label><textarea name="notes" rows="2" maxlength="2000"></textarea></div>
        <p class="error-text hidden" data-error></p>
        <button class="btn wide" type="submit">Save status</button>
      </form>`,
    footer: '<button type="button" class="btn secondary" data-close>Cancel</button>'
  });
  const form = modal.body.querySelector('#data-process-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    const data = Object.fromEntries(new FormData(form).entries());
    setButtonLoading(button, true, 'Saving...');
    try {
      await api.post(`/api/admin/data-requests/${encodeURIComponent(request.id)}/process`, { status: data.status, notes: data.notes || undefined });
      modal.close();
      toast('Data request updated.', 'success');
      await renderDataRequests();
    } catch (error) {
      setButtonLoading(button, false);
      const box = form.querySelector('[data-error]');
      box.textContent = error.message;
      box.classList.remove('hidden');
    }
  });
}

async function loadSettings() {
  content.innerHTML = `${pageHeader('System settings', 'Booking rules, check-in windows, and notification behaviour.')}<div id="admin-settings"><div class="skeleton"></div></div>`;
  const container = document.getElementById('admin-settings');
  try {
    const result = await api.get('/api/admin/settings');
    const settings = result.settings || {};
    const groups = {
      'Booking rules': ['max_booking_hours_per_day', 'max_booking_hours_per_week', 'max_advance_booking_days', 'max_booking_duration_minutes', 'min_notice_minutes', 'cancellation_cutoff_minutes'],
      'No-shows and check-in': ['no_show_suspension_threshold', 'no_show_suspension_days', 'no_show_lookback_days', 'no_show_grace_minutes', 'checkin_open_minutes', 'max_checkin_accuracy_m', 'default_checkin_radius_m', 'timetable_no_show_exempt', 'lecturer_no_show_exempt', 'lecture_room_no_show_exempt'],
      'Notifications': ['reminder_1_minutes', 'reminder_2_minutes', 'enable_10min_reminder', 'notify_online_students_physical', 'email_provider'],
      'Security and access': ['rotating_qr_required_roles', 'allowed_meeting_domains', 'allow_join_recording'],
      'Retention and identity': ['join_retention_days', 'delivery_log_retention_days', 'otp_retention_days', 'graduated_anonymize_days'],
      'Identity': ['app_name']
    };
    const fieldHtml = (key, value) => {
      const label = key.replaceAll('_', ' ').replace(/^./, (char) => char.toUpperCase());
      if (key === 'email_provider') {
        return `<div class="field"><label>${escapeHtml(label)}</label><select data-setting="${key}" data-kind="string">${option('resend', 'Resend', value === 'resend')}${option('brevo', 'Brevo', value === 'brevo')}</select></div>`;
      }
      if (typeof value === 'boolean') {
        return `<label class="check" style="margin:.45rem 0"><input type="checkbox" data-setting="${key}" data-kind="boolean" ${value ? 'checked' : ''}> <span>${escapeHtml(label)}</span></label>`;
      }
      if (Array.isArray(value)) {
        return `<div class="field"><label>${escapeHtml(label)}</label><input data-setting="${key}" data-kind="array" value="${escapeHtml(value.join(', '))}" placeholder="Comma separated"></div>`;
      }
      if (typeof value === 'number') {
        return `<div class="field"><label>${escapeHtml(label)}</label><input type="number" min="0" step="1" data-setting="${key}" data-kind="number" value="${Number(value)}"></div>`;
      }
      return `<div class="field"><label>${escapeHtml(label)}</label><input data-setting="${key}" data-kind="string" value="${escapeHtml(String(value ?? ''))}"></div>`;
    };
    container.innerHTML = `<form id="settings-form">${Object.entries(groups).map(([title, keys]) => `
      <section class="card" style="margin-bottom:.9rem"><h3>${escapeHtml(title)}</h3>${keys.filter((key) => key in settings).map((key) => fieldHtml(key, settings[key])).join('')}</section>`).join('')}
      <p class="error-text hidden" data-error></p>
      <button class="btn" type="submit">Save settings</button></form>`;
    container.querySelector('#settings-form').addEventListener('submit', async (event) => {
      event.preventDefault();
      const button = event.currentTarget.querySelector('button[type="submit"]');
      const payload = {};
      event.currentTarget.querySelectorAll('[data-setting]').forEach((input) => {
        const kind = input.dataset.kind;
        payload[input.dataset.setting] = kind === 'boolean'
          ? input.checked
          : kind === 'number'
            ? Number(input.value)
            : kind === 'array'
              ? input.value.split(',').map((item) => item.trim()).filter(Boolean)
              : input.value;
      });
      setButtonLoading(button, true, 'Saving...');
      try {
        await api.put('/api/admin/settings', payload);
        toast('Settings saved.', 'success');
      } catch (error) {
        const box = event.currentTarget.querySelector('[data-error]');
        box.textContent = error.message;
        box.classList.remove('hidden');
      } finally {
        setButtonLoading(button, false);
      }
    });
  } catch (error) {
    container.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  }
}

async function loadAudit() {
  content.innerHTML = `
    ${pageHeader('Audit log', 'Immutable record of security-sensitive and administrative actions.')}
    <div class="filters">
      <input type="search" id="audit-action" placeholder="Filter action prefix (e.g. admin.)" value="${escapeHtml(state.auditAction)}">
      <input type="date" id="audit-from" value="${escapeHtml(state.auditFrom)}">
      <button class="btn secondary" type="button" id="refresh-audit">Refresh</button>
    </div>
    <div id="admin-audit"><div class="skeleton"></div></div>`;
  document.getElementById('audit-action').addEventListener('input', (event) => {
    state.auditAction = event.target.value;
    clearTimeout(loadAudit.timer);
    loadAudit.timer = setTimeout(renderAudit, 300);
  });
  document.getElementById('audit-from').addEventListener('change', (event) => {
    state.auditFrom = event.target.value;
    renderAudit();
  });
  document.getElementById('refresh-audit').addEventListener('click', renderAudit);
  await renderAudit();
}

async function renderAudit() {
  const container = document.getElementById('admin-audit');
  if (!container) return;
  container.innerHTML = '<div class="skeleton"></div>';
  try {
    const result = await api.get(`/api/admin/audit${queryString({
      action: state.auditAction || undefined,
      from: state.auditFrom ? `${state.auditFrom}T00:00:00+03:00` : undefined,
      limit: 200
    })}`);
    const entries = result.entries || [];
    container.innerHTML = entries.length ? `<div class="table-wrap"><table><thead><tr><th>When</th><th>Who</th><th>Action</th><th>Entity</th><th></th></tr></thead><tbody>${entries.map((entry) => `
      <tr><td>${escapeHtml(formatDate(entry.created_at, { dateStyle: 'short', timeStyle: 'short' }))}</td><td>${escapeHtml(entry.user_name || 'System')}<br><span class="muted small">${escapeHtml(entry.id_number || '')}</span></td><td><code>${escapeHtml(entry.action)}</code></td><td>${escapeHtml(entry.entity_type || '')}<br><span class="muted small">${escapeHtml(entry.entity_id || '')}</span></td><td><button class="btn ghost small" type="button" data-audit="${escapeHtml(entry.id)}">View</button></td></tr>`).join('')}</tbody></table></div>` : emptyState('No audit entries', 'Try a different filter.');
    container.querySelectorAll('[data-audit]').forEach((button) => {
      button.addEventListener('click', () => {
        const entry = entries.find((item) => String(item.id) === button.dataset.audit);
        openModal({
          title: entry.action,
          content: `<pre class="code-block">${escapeHtml(JSON.stringify(entry.details || {}, null, 2))}</pre><p class="small muted">${escapeHtml(entry.ip || '')} · ${escapeHtml(entry.user_agent || '')}</p>`,
          footer: '<button type="button" class="btn secondary" data-close>Close</button>'
        });
      });
    });
  } catch (error) {
    container.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  }
}

const loaders = {
  overview: loadOverview,
  bookings: loadBookings,
  facilities: loadFacilities,
  users: loadUsers,
  issues: loadIssues,
  study: loadStudyRequests,
  data: loadDataRequests,
  settings: loadSettings,
  audit: loadAudit
};

async function switchTab(tab) {
  if (!loaders[tab]) tab = 'overview';
  state.tab = tab;
  tabs.forEach((button) => {
    const selected = button.dataset.adminTab === tab;
    button.classList.toggle('active', selected);
    button.setAttribute('aria-selected', String(selected));
  });
  history.replaceState(null, '', `#${tab}`);
  skeleton();
  try {
    await loaders[tab]();
  } catch (error) {
    content.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  }
}

tabs.forEach((button) => {
  button.addEventListener('click', () => switchTab(button.dataset.adminTab));
});

async function start() {
  const user = await requireAdmin();
  if (!user) return;
  state.me = user;
  document.getElementById('admin-subtitle').textContent = user.role === 'super_admin'
    ? 'University-wide access. You can manage every department.'
    : `Department scope: ${user.department_name || 'your department'}`;
  if (user.role === 'super_admin') document.getElementById('settings-tab').classList.remove('hidden');
  await loadDirectory();
  const initial = location.hash.replace('#', '') || 'overview';
  await switchTab(initial);
}

start().catch(notifyError);
