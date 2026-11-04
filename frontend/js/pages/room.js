import { api, queryString } from '../api.js';
import { requireAuth } from '../auth.js';
import {
  badge,
  confirmDialog,
  emptyState,
  errorMessage,
  escapeHtml,
  formatDate,
  formatRange,
  icon,
  loadScript,
  loadStyle,
  notifyError,
  openModal,
  queryParams,
  scanQr,
  setButtonLoading,
  toast
} from '../ui.js';

const params = queryParams();
const paramsId = params.get('id') || params.get('f') || '';
const roomQr = {
  v: params.get('v') || '',
  s: params.get('s') || ''
};
let facility = null;
let roomMap = null;
let marker = null;

const categoryLabels = {
  lecture_room: 'Lecture room',
  discussion_room: 'Discussion room',
  lab: 'Laboratory',
  office: 'Office',
  library: 'Library'
};

function setWarnings(text, type = 'warning') {
  const box = document.getElementById('room-warning');
  box.className = `notice ${type}`;
  box.textContent = text;
  box.classList.remove('hidden');
}

async function loadRoom() {
  if (!paramsId) {
    document.getElementById('room-name').textContent = 'Room code missing';
    setWarnings('This page needs a room link. Scan the QR code on the room door or open a room from the room finder.', 'danger');
    return;
  }
  try {
    const result = await api.get(`/api/facilities/${encodeURIComponent(paramsId)}`);
    facility = result.facility;
    renderRoom(result.upcoming || []);
    loadAvailability();
    initMap();
  } catch (error) {
    document.getElementById('room-name').textContent = 'Room not found';
    setWarnings(errorMessage(error), 'danger');
  }
}

function renderRoom(upcoming) {
  document.title = `${facility.name} | Campus Compass`;
  document.getElementById('room-eyebrow').textContent = categoryLabels[facility.category] || facility.category;
  document.getElementById('room-name').textContent = facility.name;
  document.getElementById('room-subtitle').textContent = `${facility.building}${facility.floor ? `, ${facility.floor}` : ''} · Room ${facility.room_number} · ${facility.department_name}`;
  if (facility.status !== 'active') {
    setWarnings(`This room is currently marked ${facility.status}. Bookings may be unavailable.`);
  }
  // Show "currently occupied" banner if any upcoming booking is active right now
  const nowMs = Date.now();
  const activeNow = upcoming.find(
    (item) => new Date(item.start_at).getTime() <= nowMs && new Date(item.end_at).getTime() > nowMs
  );
  if (activeNow) {
    setWarnings(
      `🔴 This room is currently in use: ${activeNow.module_code || activeNow.purpose || 'Reserved'} · until ${activeNow.end_local || formatDate(activeNow.end_at, { timeStyle: 'short' })}. It will be free after the session ends.`,
      'danger'
    );
  }
  const bookUrl = `schedule.html?facility_id=${encodeURIComponent(facility.id)}`;
  document.getElementById('room-actions').innerHTML = `
    <a class="btn" href="${bookUrl}">Book this room</a>
    ${roomQr.v && roomQr.s ? `<button class="btn warning" type="button" id="use-now">Use this room now</button>` : ''}
    <button class="btn secondary" type="button" id="check-in">Check in</button>`;
  document.getElementById('qr-verified').classList.toggle('hidden', !(roomQr.v && roomQr.s));
  const useNow = document.getElementById('use-now');
  if (useNow) useNow.addEventListener('click', openWalkUp);
  document.getElementById('check-in').addEventListener('click', () => checkInFlow().catch(notifyError));

  document.getElementById('room-facts').innerHTML = `
    <div class="list">
      <div class="list-item"><span class="item-icon">${icon('users')}</span><div class="main"><strong>${Number(facility.capacity)} seats</strong><p>Maximum room capacity</p></div></div>
      <div class="list-item"><span class="item-icon">${icon('pin')}</span><div class="main"><strong>${escapeHtml(facility.building)} · ${escapeHtml(facility.room_number)}</strong><p>${escapeHtml([facility.floor, facility.wing, facility.location_description].filter(Boolean).join(' · '))}</p></div></div>
      <div class="list-item"><span class="item-icon">${icon('scan')}</span><div class="main"><strong>${facility.checkin_mode === 'static_geo' ? 'Location check-in' : 'QR door check-in'}</strong><p>${facility.checkin_mode === 'static_geo' ? `Within ${Number(facility.checkin_radius_m)}m of the room` : 'Scan the live QR at the door'}</p></div></div>
      <div class="list-item"><span class="item-icon">${icon('shield')}</span><div class="main"><strong>${facility.requires_approval ? 'Approval required' : 'Instant confirmation'}</strong><p>${facility.requires_approval ? 'An administrator reviews bookings for this room.' : 'Bookings confirm immediately when the slot is free.'}</p></div></div>
    </div>`;

  const equipment = Array.isArray(facility.equipment) ? facility.equipment.filter((item) => item.quantity > 0) : [];
  document.getElementById('room-equipment').innerHTML = equipment.length
    ? `<div class="chips">${equipment.map((item) => `<span class="chip">${escapeHtml(item.name)}${item.quantity > 1 ? ` x${item.quantity}` : ''}</span>`).join('')}</div>`
    : '<p class="muted small">No equipment has been listed for this room.</p>';

  const upcomingContainer = document.getElementById('room-upcoming');
  upcomingContainer.innerHTML = upcoming.length
    ? `<div class="list">${upcoming.map((item) => `
        <div class="list-item">
          <span class="item-icon">${icon('calendar')}</span>
          <div class="main"><h3>${escapeHtml(item.module_code || item.purpose || 'Reserved')}</h3><p>${escapeHtml(formatRange(item.start_at, item.end_at))}</p></div>
          ${badge(item.status)}
        </div>`).join('')}</div>`
    : emptyState('No upcoming sessions', 'The room is open for booking.');

  document.getElementById('issue-card').classList.remove('hidden');
  document.getElementById('report-issue').addEventListener('click', openIssueModal);
}

async function loadAvailability() {
  if (!facility) return;
  const dateInput = document.getElementById('availability-date');
  if (!dateInput.value) dateInput.value = new Date().toISOString().slice(0, 10);
  document.getElementById('availability-title').textContent = formatDate(`${dateInput.value}T12:00:00+03:00`, { weekday: 'long' });
  const container = document.getElementById('availability-content');
  container.innerHTML = '<div class="skeleton"></div><div class="skeleton"></div>';
  try {
    const result = await api.get(`/api/bookings/availability${queryString({
      facility_id: facility.id,
      date: dateInput.value
    })}`);
    const slots = result.free_slots || [];
    const busy = result.busy || [];
    container.innerHTML = `
      <h3>Free 30-minute slots</h3>
      ${slots.length ? `<div class="chips">${slots.slice(0, 20).map((slot) => `
        <a class="chip" href="schedule.html?facility_id=${encodeURIComponent(facility.id)}&date=${encodeURIComponent(result.day)}&start_time=${encodeURIComponent(slot.start_local)}&end_time=${encodeURIComponent(slot.end_local)}">${escapeHtml(slot.start_local)} - ${escapeHtml(slot.end_local)}</a>
      `).join('')}</div>` : '<p class="muted small">No free slots remain for this date.</p>'}
      <p class="hint">Booking limits: ${Number(result.limits?.min_notice_minutes || 0)} minutes notice, up to ${Number(result.limits?.max_booking_duration_minutes || 0)} minutes per booking.</p>
      <h3 style="margin-top:1rem">Busy periods</h3>
      ${busy.length ? `<div class="list">${busy.map((item) => `
        <div class="list-item">
          <span class="item-icon">${icon('clock')}</span>
          <div class="main"><h3>${escapeHtml(item.module_code || item.purpose || item.reason || item.name || 'Busy')}</h3><p>${escapeHtml(formatRange(item.start_at, item.end_at))}</p></div>
          ${badge(item.type === 'maintenance' ? 'blocked' : item.type || item.status, item.type === 'maintenance' ? 'Maintenance' : item.type === 'exam' ? 'Exam' : '')}
        </div>`).join('')}</div>` : '<p class="muted small">No bookings or maintenance blocks on this date.</p>'}
    `;
  } catch (error) {
    container.innerHTML = `<div class="notice danger">${escapeHtml(errorMessage(error))}</div>`;
  }
}

function openWalkUp() {
  const modal = openModal({
    title: 'Use this room now',
    content: `
      <form id="walkup-form">
        <div class="field">
          <label for="walkup-purpose">What do you need the room for?</label>
          <input id="walkup-purpose" name="purpose" required minlength="3" maxlength="1000" placeholder="e.g. Group revision">
        </div>
        <div class="field">
          <label for="walkup-duration">How long?</label>
          <select id="walkup-duration" name="duration_minutes">
            <option value="30">30 minutes</option>
            <option value="60" selected>1 hour</option>
            <option value="90">1 hour 30 minutes</option>
            <option value="120">2 hours</option>
          </select>
        </div>
        <p class="hint">Walk-up use starts now and skips the usual advance-notice rule. Duration, fairness, and capacity rules still apply.</p>
        <p class="error-text hidden" data-error></p>
        <button class="btn wide" type="submit">Start using this room</button>
      </form>`,
    footer: '<button type="button" class="btn secondary" data-close>Cancel</button>'
  });
  const form = modal.body.querySelector('#walkup-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    const errorBox = form.querySelector('[data-error]');
    setButtonLoading(button, true, 'Reserving...');
    try {
      const data = Object.fromEntries(new FormData(form).entries());
      const result = await api.post('/api/bookings/walk-up', {
        facility_id: facility.id,
        v: roomQr.v,
        s: roomQr.s,
        purpose: data.purpose,
        duration_minutes: Number(data.duration_minutes)
      }, { retry: false });
      modal.close();
      const content = `
        <p>${escapeHtml(result.booking.facility?.name || facility.name)} is yours until <strong>${escapeHtml(result.booking.end_local)}</strong>.</p>
        <p class="muted small">${result.checked_in ? 'Your arrival was recorded automatically.' : 'Check in at the door when you arrive.'}</p>`;
      const success = openModal({
        title: 'Room reserved',
        content,
        footer: `<a class="btn" href="bookings.html">View booking</a>`
      });
      setTimeout(() => success.close(), 7000);
      toast('Room reserved successfully.', 'success');
    } catch (error) {
      errorBox.textContent = errorMessage(error);
      errorBox.classList.remove('hidden');
    } finally {
      setButtonLoading(button, false);
    }
  });
}

async function chooseBooking(candidates) {
  if (candidates.length === 0) {
    toast('You have no active booking in this room. Use the room QR to start a walk-up booking.', 'error', 6000);
    return null;
  }
  if (candidates.length === 1) return candidates[0];
  return new Promise((resolve) => {
    const modal = openModal({
      title: 'Choose the session to check in',
      content: `<div class="list">${candidates.map((item) => `
        <button type="button" class="list-item" data-booking="${escapeHtml(item.id)}" style="text-align:left;cursor:pointer">
          <span class="item-icon">${icon('clock')}</span>
          <span class="main"><h3>${escapeHtml(item.module?.code || item.purpose || 'Session')}</h3><p>${escapeHtml(formatRange(item.start_at, item.end_at))}</p></span>
        </button>`).join('')}</div>`,
      footer: '<button type="button" class="btn secondary" data-close>Cancel</button>',
      onClose: () => resolve(null)
    });
    modal.body.querySelectorAll('[data-booking]').forEach((button) => {
      button.addEventListener('click', () => {
        const found = candidates.find((item) => item.id === button.dataset.booking);
        modal.close();
        resolve(found);
      });
    });
  });
}

function geolocation() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('This device does not support location check-in. Use the door QR instead.'));
      return;
    }
    navigator.geolocation.getCurrentPosition(
      (position) => resolve(position.coords),
      (error) => reject(new Error(error.message || 'Could not read your location.')),
      { enableHighAccuracy: true, timeout: 15000, maximumAge: 0 }
    );
  });
}

async function checkInFlow() {
  if (!facility) return;
  const now = new Date();
  const result = await api.get(`/api/bookings${queryString({
    from: new Date(now.getTime() - 6 * 3600000).toISOString(),
    to: new Date(now.getTime() + 6 * 3600000).toISOString()
  })}`);
  const candidates = (result.bookings || []).filter((item) => (
    item.facility_id === facility.id && ['confirmed'].includes(item.status)
  ));
  const booking = await chooseBooking(candidates);
  if (!booking) return;
  if (booking.checked_in_at) {
    toast('You are already checked in for this session.', 'success');
    return;
  }
  const method = await new Promise((resolve) => {
    const modal = openModal({
      title: 'Check in',
      content: '<p>Choose how to prove you are at the room.</p>',
      footer: '<button type="button" class="btn secondary" data-close>Cancel</button>',
      onClose: () => resolve(null)
    });
    modal.body.innerHTML = `
      <div class="list">
        <button type="button" class="list-item" data-method="rotating" style="text-align:left"><span class="item-icon">${icon('scan')}</span><span class="main"><h3>Scan the door QR</h3><p>Fastest and most accurate</p></span></button>
        <button type="button" class="list-item" data-method="static_geo" style="text-align:left"><span class="item-icon">${icon('pin')}</span><span class="main"><h3>Use my location</h3><p>Confirm you are within the room radius</p></span></button>
      </div>`;
    modal.body.querySelectorAll('[data-method]').forEach((button) => {
      button.addEventListener('click', () => {
        modal.close();
        resolve(button.dataset.method);
      });
    });
  });
  if (!method) return;
  try {
    let payload;
    if (method === 'rotating') {
      const token = await scanQr({ title: 'Scan the door QR' });
      payload = { method: 'rotating', door_token: token.trim() };
    } else {
      const coords = await geolocation();
      payload = {
        method: 'static_geo',
        latitude: coords.latitude,
        longitude: coords.longitude,
        accuracy: coords.accuracy
      };
    }
    const checked = await api.post(`/api/bookings/${encodeURIComponent(booking.id)}/checkin`, payload, { retry: false });
    toast(checked.already_checked_in ? 'You were already checked in.' : 'Checked in. Have a productive session.', 'success');
    loadAvailability();
  } catch (error) {
    if (!error.cancelled) notifyError(error);
  }
}

function openIssueModal() {
  const modal = openModal({
    title: 'Report a room issue',
    content: `
      <form id="issue-form">
        <div class="field">
          <label for="issue-category">Category</label>
          <select id="issue-category" name="category">
            <option value="projector">Projector or screen</option>
            <option value="power">Power or sockets</option>
            <option value="cleanliness">Cleanliness</option>
            <option value="furniture">Furniture</option>
            <option value="wrong_details">Wrong room details</option>
            <option value="other">Other</option>
          </select>
        </div>
        <div class="field">
          <label for="issue-description">What is wrong?</label>
          <textarea id="issue-description" name="description" minlength="5" maxlength="2000" required placeholder="Describe the problem and where it is."></textarea>
        </div>
        <div class="field">
          <label for="issue-photo">Photo (optional, max 1MB)</label>
          <input id="issue-photo" name="photo" type="file" accept="image/png,image/jpeg,image/webp">
        </div>
        <p class="error-text hidden" data-error></p>
        <button class="btn wide" type="submit">Send report</button>
      </form>`,
    footer: '<button type="button" class="btn secondary" data-close>Cancel</button>'
  });
  const form = modal.body.querySelector('#issue-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    const errorBox = form.querySelector('[data-error]');
    setButtonLoading(button, true, 'Sending...');
    try {
      const data = new FormData(form);
      let photoData;
      const file = data.get('photo');
      if (file && file.size) {
        if (file.size > 1000000) throw new Error('Photo must be 1MB or smaller.');
        photoData = await new Promise((resolve, reject) => {
          const reader = new FileReader();
          reader.onload = () => resolve(reader.result);
          reader.onerror = () => reject(new Error('Could not read the photo.'));
          reader.readAsDataURL(file);
        });
      }
      await api.post(`/api/facilities/${encodeURIComponent(facility.id)}/issues`, {
        category: data.get('category'),
        description: data.get('description'),
        photo_data: photoData
      }, { retry: false });
      modal.close();
      toast('Issue reported. Thank you.', 'success');
      document.getElementById('issue-card').classList.add('hidden');
    } catch (error) {
      errorBox.textContent = errorMessage(error);
      errorBox.classList.remove('hidden');
    } finally {
      setButtonLoading(button, false);
    }
  });
}

async function initMap() {
  if (!facility || !facility.latitude || !facility.longitude) {
    document.getElementById('room-map').innerHTML = '<div class="empty"><p>No map pin is available.</p></div>';
    return;
  }
  try {
    loadStyle('https://unpkg.com/leaflet@1.9.4/dist/leaflet.css');
    await loadScript('https://unpkg.com/leaflet@1.9.4/dist/leaflet.js', 'L');
    const point = [Number(facility.latitude), Number(facility.longitude)];
    roomMap = window.L.map('room-map', { scrollWheelZoom: false }).setView(point, 18);
    window.L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      maxZoom: 19,
      attribution: '&copy; OpenStreetMap contributors'
    }).addTo(roomMap);
    marker = window.L.marker(point).addTo(roomMap).bindPopup(escapeHtml(facility.name));
    document.getElementById('room-map-link').innerHTML = `<a target="_blank" rel="noopener" href="https://www.openstreetmap.org/?mlat=${point[0]}&mlon=${point[1]}#map=19/${point[0]}/${point[1]}">Open in OpenStreetMap</a>`;
  } catch {
    document.getElementById('room-map').innerHTML = '<div class="empty"><p>The map could not load. Use the room details above.</p></div>';
  }
}

document.getElementById('availability-date').addEventListener('change', loadAvailability);

async function start() {
  const user = await requireAuth();
  if (!user) return;
  await loadRoom();
}

start().catch(notifyError);
