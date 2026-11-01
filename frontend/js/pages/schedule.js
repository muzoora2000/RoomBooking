import { api, queryString } from '../api.js';
import { canSchedule, getUser, requireAuth } from '../auth.js';
import { withStepUp } from '../stepup.js';
import {
  escapeHtml,
  formatDate,
  formatRange,
  icon,
  notifyError,
  openModal,
  queryParams,
  setButtonLoading,
  toast
} from '../ui.js';

const params = queryParams();
const form = document.getElementById('booking-form');
const moduleSelect = document.getElementById('module-id');
const facilitySelect = document.getElementById('facility-id');
const modeSelect = document.getElementById('session-mode');
const dateInput = document.getElementById('booking-date');
const startInput = document.getElementById('start-time');
const endInput = document.getElementById('end-time');
const recurringToggle = document.getElementById('recurring-toggle');
const recurringFields = document.getElementById('recurring-fields');
const errorBox = document.getElementById('booking-error');
const submitButton = document.getElementById('booking-submit');
let facilities = [];
let modules = [];

function kampalaNow() {
  const parts = Object.fromEntries(new Intl.DateTimeFormat('en-CA', {
    timeZone: 'Africa/Kampala',
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  }).formatToParts(new Date()).filter((part) => part.type !== 'literal').map((part) => [part.type, part.value]));
  return { year: parts.year, month: parts.month, day: parts.day, hour: parts.hour, minute: parts.minute };
}

function roundToQuarter(base) {
  const value = new Date(`${base.year}-${base.month}-${base.day}T${base.hour}:${base.minute}:00Z`);
  const minutes = value.getUTCMinutes();
  const add = minutes % 15 === 0 ? 0 : 15 - (minutes % 15);
  value.setUTCMinutes(minutes + add);
  return {
    date: value.toISOString().slice(0, 10),
    time: value.toISOString().slice(11, 16),
    plusHour: new Date(value.getTime() + 3600000).toISOString().slice(11, 16)
  };
}

function setDefaults() {
  const initial = roundToQuarter(kampalaNow());
  dateInput.value = params.get('date') || initial.date;
  startInput.value = params.get('start_time') || initial.time;
  endInput.value = params.get('end_time') || initial.plusHour;
  dateInput.min = initial.date;
}

async function loadFacilities() {
  const result = await api.get('/api/facilities');
  facilities = result.facilities || [];
  const selected = params.get('facility_id') || facilitySelect.value;
  facilitySelect.innerHTML = '<option value="">Choose a room</option>' + facilities.map((room) => (
    `<option value="${escapeHtml(room.id)}">${escapeHtml(room.name)} · ${escapeHtml(room.building)} ${escapeHtml(room.room_number)} · ${Number(room.capacity)} seats</option>`
  )).join('');
  if (selected && facilities.some((room) => room.id === selected)) {
    facilitySelect.value = selected;
  }
  renderFacilityPreview();
}

async function loadModules() {
  const user = getUser();
  if (!canSchedule(user)) return;
  try {
    const result = await api.get('/api/org/my-modules');
    modules = result.modules || [];
    moduleSelect.innerHTML = '<option value="">General room use (no module)</option>' + modules.map((module) => (
      `<option value="${escapeHtml(module.id)}">${escapeHtml(module.code)} · ${escapeHtml(module.name)}</option>`
    )).join('');
  } catch {
    moduleSelect.innerHTML = '<option value="">General room use (no module)</option>';
  }
}

function selectedModule() {
  return modules.find((item) => item.id === moduleSelect.value) || null;
}

function selectedFacility() {
  return facilities.find((item) => item.id === facilitySelect.value) || null;
}

function renderFacilityPreview() {
  const room = selectedFacility();
  const box = document.getElementById('facility-preview');
  if (!room) {
    box.innerHTML = '';
    return;
  }
  const equipment = Array.isArray(room.equipment) ? room.equipment.filter((item) => item.quantity > 0) : [];
  box.innerHTML = `
    <div class="notice info" style="margin-bottom:.9rem">
      <strong>${escapeHtml(room.name)}</strong> · ${escapeHtml(room.building)}, ${escapeHtml(room.room_number)} · ${Number(room.capacity)} seats
      ${room.requires_approval ? ' · Approval required' : ' · Instant confirmation'}
      ${equipment.length ? `<br><span class="small">${equipment.slice(0, 6).map((item) => escapeHtml(item.name)).join(' · ')}</span>` : ''}
      <br><a class="small" href="room.html?id=${encodeURIComponent(room.id)}">View room details</a>
    </div>`;
}

function updateMode() {
  const module = selectedModule();
  if (!module) {
    modeSelect.value = 'physical';
    modeSelect.disabled = true;
  } else {
    modeSelect.disabled = false;
  }
  const mode = modeSelect.value;
  document.getElementById('online-fields').classList.toggle('hidden', mode === 'physical');
  document.querySelectorAll('#online-link, #online-platform').forEach((element) => {
    element.required = mode !== 'physical';
  });
}

async function previewAvailability() {
  const room = selectedFacility();
  const container = document.getElementById('availability-preview');
  if (!room || !dateInput.value) {
    container.innerHTML = '';
    return;
  }
  container.innerHTML = '<div class="skeleton"></div>';
  try {
    const result = await api.get(`/api/bookings/availability${queryString({
      facility_id: room.id,
      date: dateInput.value,
      module_id: moduleSelect.value || undefined
    })}`);
    const slots = result.free_slots || [];
    let capacity = '';
    if (result.capacity && !result.capacity.error) {
      const enough = room.capacity >= Number(result.capacity.required_capacity || 0);
      capacity = `<div class="notice ${enough ? 'success' : 'danger'}" style="margin-bottom:.6rem">${escapeHtml(result.capacity.explanation)}</div>`;
    }
    container.innerHTML = `
      ${capacity}
      <p class="small muted" style="margin-bottom:.35rem">Quick-pick a free start and end time:</p>
      ${slots.length ? `<div class="chips">${slots.slice(0, 16).map((slot) => `<button type="button" class="chip" data-slot-start="${escapeHtml(slot.start_local)}" data-slot-end="${escapeHtml(slot.end_local)}">${escapeHtml(slot.start_local)} - ${escapeHtml(slot.end_local)}</button>`).join('')}</div>` : '<p class="small muted">No free slots on this date.</p>'}
      <p class="hint">${formatDate(`${dateInput.value}T12:00:00+03:00`, { weekday: 'long' })} · ${Number(result.limits?.min_notice_minutes || 0)} min notice · max ${Number(result.limits?.max_booking_duration_minutes || 0)} min</p>`;
    container.querySelectorAll('[data-slot-start]').forEach((button) => {
      button.addEventListener('click', () => {
        startInput.value = button.dataset.slotStart;
        endInput.value = button.dataset.slotEnd;
      });
    });
  } catch (error) {
    container.innerHTML = `<div class="notice warning">${escapeHtml(error.message)}</div>`;
  }
}

moduleSelect.addEventListener('change', () => {
  updateMode();
  previewAvailability();
});
facilitySelect.addEventListener('change', () => {
  renderFacilityPreview();
  previewAvailability();
});
dateInput.addEventListener('change', previewAvailability);
startInput.addEventListener('change', previewAvailability);
modeSelect.addEventListener('change', updateMode);
recurringToggle.addEventListener('change', () => {
  recurringFields.classList.toggle('hidden', !recurringToggle.checked);
});

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  errorBox.classList.add('hidden');
  if (!facilitySelect.value) {
    errorBox.textContent = 'Choose a room.';
    errorBox.classList.remove('hidden');
    return;
  }
  if (!moduleSelect.value && !document.getElementById('purpose').value.trim()) {
    errorBox.textContent = 'Describe what you need the room for.';
    errorBox.classList.remove('hidden');
    return;
  }
  if (!dateInput.value || !startInput.value || !endInput.value) {
    errorBox.textContent = 'Choose a date, start time, and end time.';
    errorBox.classList.remove('hidden');
    return;
  }
  if (endInput.value <= startInput.value) {
    errorBox.textContent = 'The end time must be after the start time.';
    errorBox.classList.remove('hidden');
    return;
  }
  if (modeSelect.value !== 'physical' && !document.getElementById('online-link').value.trim()) {
    errorBox.textContent = 'Add the meeting link for an online or hybrid session.';
    errorBox.classList.remove('hidden');
    return;
  }
  const data = new FormData(form);
  const payload = {
    facility_id: facilitySelect.value,
    module_id: moduleSelect.value || null,
    session_mode: moduleSelect.value ? modeSelect.value : 'physical',
    date: dateInput.value,
    start_time: startInput.value,
    end_time: endInput.value,
    purpose: String(data.get('purpose') || '').trim() || null,
    reason: String(data.get('reason') || '').trim() || undefined
  };
  if (payload.session_mode !== 'physical') {
    payload.online_platform = data.get('online_platform');
    payload.online_link = String(data.get('online_link') || '').trim();
    payload.meeting_passcode = String(data.get('meeting_passcode') || '').trim() || null;
  }
  const recurring = recurringToggle.checked;
  if (recurring) {
    payload.recurrence = { frequency: 'weekly', count: Number(data.get('repeat_count') || 4) };
  }
  setButtonLoading(submitButton, true, recurring ? 'Creating series...' : 'Booking...');
  try {
    const result = await withStepUp(() => api.post(
      recurring ? '/api/bookings/recurring' : '/api/bookings',
      payload,
      { retry: false }
    ));
    showSuccess(result, recurring);
    form.reset();
    setDefaults();
    moduleSelect.value = '';
    modeSelect.disabled = true;
    modeSelect.value = 'physical';
    updateMode();
    previewAvailability();
  } catch (error) {
    if (!error.cancelled) {
      errorBox.textContent = error.message;
      errorBox.classList.remove('hidden');
    }
  } finally {
    setButtonLoading(submitButton, false);
  }
});

function showSuccess(result, recurring) {
  const booking = result.booking || (result.bookings && result.bookings[0]);
  const status = booking?.status || result.status || 'confirmed';
  const displaced = Number(result.displaced?.length || 0);
  const content = `
    <div class="notice ${status === 'pending' ? 'warning' : 'success'}">
      ${status === 'pending' ? 'Your request is awaiting administrator approval. The slot is held while it is reviewed.' : 'Your booking is confirmed.'}
    </div>
    ${booking ? `<p style="margin-top:.7rem"><strong>${escapeHtml(booking.facility?.name || 'Your room')}</strong><br>${escapeHtml(formatRange(booking.start_at, booking.end_at))}</p>` : ''}
    ${recurring ? `<p class="small muted">${Number(result.count || 0)} weekly bookings created. Use this booking or any occurrence in My bookings to cancel a series.</p>` : ''}
    ${displaced ? `<p class="small muted">${displaced} lower-priority booking${displaced === 1 ? ' was' : 's were'} displaced and notified.</p>` : ''}
    ${result.warning ? `<p class="small muted">${escapeHtml(result.warning)}</p>` : ''}`;
  const modal = openModal({
    title: status === 'pending' ? 'Request sent' : 'Booking confirmed',
    content,
    footer: `<a class="btn" href="bookings.html">View my bookings</a><button type="button" class="btn secondary" data-close>Done</button>`
  });
  setTimeout(() => modal.close(), 10000);
  toast(status === 'pending' ? 'Booking request sent for approval.' : 'Room booked successfully.', 'success');
}

async function start() {
  const user = await requireAuth();
  if (!user) return;
  setDefaults();
  updateMode();
  try {
    await Promise.all([loadFacilities(), loadModules()]);
    if (params.get('facility_id')) {
      facilitySelect.value = params.get('facility_id');
      renderFacilityPreview();
    }
    previewAvailability();
  } catch (error) {
    toast(error.message, 'error');
  }
}

start().catch(notifyError);
