import { api, queryString } from '../api.js';
import { requireAuth } from '../auth.js';
import { withStepUp } from '../stepup.js';
import {
  badge,
  emptyState,
  escapeHtml,
  formatDate,
  formatDayNumber,
  formatMonthShort,
  formatRange,
  icon,
  notifyError,
  openModal,
  scanQr,
  setButtonLoading,
  toast
} from '../ui.js';

const listContainer = document.getElementById('bookings-list');
const tabs = [...document.querySelectorAll('[data-tab]')];
let activeTab = 'upcoming';
let currentBookings = [];
let loading = false;
let checkinWindowConfig = { opens_before_minutes: 10, grace_after_minutes: 15 };

const tabLabels = {
  upcoming: 'Upcoming',
  past: 'Past',
  pending: 'Pending',
  cancelled: 'Cancelled'
};

function apiRange(tab) {
  const now = new Date().toISOString();
  if (tab === 'upcoming') return { from: now };
  if (tab === 'past') return { to: now };
  if (tab === 'pending') return { status: 'pending' };
  if (tab === 'cancelled') return { status: 'cancelled' };
  return {};
}

function filterBookings(bookings, tab) {
  if (tab === 'upcoming') return bookings.filter((item) => ['pending', 'confirmed'].includes(item.status));
  if (tab === 'past') return bookings.filter((item) => !['cancelled'].includes(item.status));
  return bookings;
}

function checkinWindow(booking) {
  const start = new Date(booking.start_at).getTime();
  const now = Date.now();
  const opensBefore = Number(checkinWindowConfig.opens_before_minutes) * 60000;
  const graceAfter = Number(checkinWindowConfig.grace_after_minutes) * 60000;
  return now >= start - opensBefore && now <= start + graceAfter;
}

function actionButtons(booking) {
  const actions = [`<button type="button" class="btn ghost small" data-action="details">Details</button>`];
  if (booking.can_cancel) {
    actions.push('<button type="button" class="btn ghost small danger-text" data-action="cancel">Cancel</button>');
  }
  if (booking.status === 'confirmed' && !booking.checked_in_at && checkinWindow(booking)) {
    actions.push('<button type="button" class="btn small" data-action="checkin">Check in</button>');
  }
  if (booking.online_link && booking.status !== 'cancelled') {
    actions.push(`<a class="btn small secondary" href="${escapeHtml(booking.online_link)}" target="_blank" rel="noopener noreferrer">Join online</a>`);
  }
  if (booking.can_manage && !booking.converted_to_online_at && booking.status === 'confirmed' && new Date(booking.end_at) > new Date()) {
    actions.push('<button type="button" class="btn ghost small" data-action="convert">Convert online</button>');
  }
  return actions.join('');
}

function renderBooking(booking) {
  const title = booking.module?.code
    ? `${booking.module.code} · ${booking.module.name}`
    : booking.purpose || 'Room booking';
  const room = booking.facility;
  const checkin = booking.checked_in_at
    ? `<span class="small" style="color:var(--success)">${icon('check')} Checked in ${escapeHtml(formatDate(booking.checked_in_at, { timeStyle: 'short' }))}</span>`
    : '';
  const online = booking.session_mode !== 'physical'
    ? `<span class="badge blue">${escapeHtml(booking.session_mode === 'online' ? 'Online' : 'Hybrid')}</span>`
    : '';
  const pendingNote = booking.status === 'pending'
    ? '<p class="small muted">Waiting for administrator approval. The slot is held while it is reviewed.</p>'
    : '';
  return `
    <article class="card booking-card" data-booking-id="${escapeHtml(booking.id)}">
      <div class="row space-between">
        <div class="row" style="gap:.55rem;align-items:flex-start">
          <span class="date-chip"><strong>${escapeHtml(formatDayNumber(booking.start_at))}</strong><span>${escapeHtml(formatMonthShort(booking.start_at))}</span></span>
          <div>
            <h3>${escapeHtml(title)}</h3>
            <p class="muted small">${escapeHtml(formatRange(booking.start_at, booking.end_at))}</p>
          </div>
        </div>
        <div class="chips">${badge(booking.status)}${online}</div>
      </div>
      <div class="booking-meta">
        <span>${icon('pin')} ${escapeHtml(room?.name || 'Online session')}${room ? ` · ${escapeHtml(room.building)} ${escapeHtml(room.room_number)}` : ''}</span>
        ${booking.checked_in_at ? checkin : ''}
      </div>
      ${pendingNote}
      <div class="card-actions">${actionButtons(booking)}</div>
    </article>`;
}

function render() {
  if (!currentBookings.length) {
    const copy = activeTab === 'upcoming'
      ? 'Book a room and it will appear here.'
      : activeTab === 'pending'
        ? 'You have no requests waiting for approval.'
        : `No ${tabLabels[activeTab].toLowerCase()} bookings.`;
    listContainer.innerHTML = emptyState(`No ${tabLabels[activeTab].toLowerCase()} bookings`, copy);
    return;
  }
  const groups = new Map();
  for (const booking of currentBookings) {
    const key = booking.day || new Date(booking.start_at).toISOString().slice(0, 10);
    if (!groups.has(key)) groups.set(key, []);
    groups.get(key).push(booking);
  }
  const entries = [...groups.entries()].sort(([a], [b]) => activeTab === 'past' || activeTab === 'cancelled' ? b.localeCompare(a) : a.localeCompare(b));
  const total = currentBookings.length;
  listContainer.innerHTML = `<p class="small muted" style="margin-bottom:.7rem">${total} booking${total === 1 ? '' : 's'}</p>` + entries.map(([day, bookings]) => `
    <section style="margin-bottom:1.2rem">
      <h2 class="day-heading">${escapeHtml(formatDate(`${day}T12:00:00+03:00`, { weekday: 'long', day: 'numeric', month: 'long' }))}</h2>
      ${bookings.sort((a, b) => new Date(a.start_at) - new Date(b.start_at)).map(renderBooking).join('')}
    </section>`).join('');
}

async function load() {
  if (loading) return;
  loading = true;
  listContainer.innerHTML = '<div class="skeleton"></div><div class="skeleton"></div><div class="skeleton"></div>';
  try {
    const result = await api.get(`/api/bookings${queryString(apiRange(activeTab))}`);
    if (result.checkin_window) checkinWindowConfig = result.checkin_window;
    currentBookings = filterBookings(result.bookings || [], activeTab);
    render();
  } catch (error) {
    listContainer.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  } finally {
    loading = false;
  }
}

function findBooking(id) {
  return currentBookings.find((item) => item.id === id);
}

function openDetails(booking) {
  const room = booking.facility;
  const rows = [
    ['Status', badge(booking.status)],
    ['When', escapeHtml(formatRange(booking.start_at, booking.end_at))],
    ['Mode', escapeHtml(booking.session_mode || 'physical')],
    ['Room', room ? `<a href="room.html?id=${encodeURIComponent(room.id)}">${escapeHtml(room.name)}</a><br><span class="small muted">${escapeHtml([room.building, room.floor, room.room_number].filter(Boolean).join(' · '))}</span>` : 'Online only'],
    ['Module', booking.module ? `${escapeHtml(booking.module.code)} · ${escapeHtml(booking.module.name)}` : 'General room use'],
    ['Booked by', booking.booked_by ? `${escapeHtml(booking.booked_by.name)} (${escapeHtml(booking.booked_by.id_number)})` : ''],
    ['Purpose', escapeHtml(booking.purpose || '')],
    ['Checked in', booking.checked_in_at ? escapeHtml(formatDate(booking.checked_in_at, { timeStyle: 'short' })) : 'Not yet'],
    ['Booking ID', `<code>${escapeHtml(booking.id)}</code>`],
    ['Group', booking.recurrence_group_id ? `<code>${escapeHtml(booking.recurrence_group_id)}</code>` : 'Single booking']
  ].filter(([, value]) => value);
  const online = booking.online_link
    ? `<div class="notice info" style="margin-top:.8rem"><strong>Online access</strong><br><a href="${escapeHtml(booking.online_link)}" target="_blank" rel="noopener noreferrer">Open meeting</a>${booking.meeting_passcode ? `<br>Passcode: <code>${escapeHtml(booking.meeting_passcode)}</code>` : ''}</div>`
    : booking.has_online_link
      ? '<div class="notice warning" style="margin-top:.8rem">This is an online or hybrid session. Join it from My lectures with your student account.</div>'
      : '';
  const modal = openModal({
    title: booking.module ? booking.module.code : 'Booking details',
    content: `<div class="detail-grid">${rows.map(([label, value]) => `<div><span>${label}</span><div>${value}</div></div>`).join('')}</div>${online}`,
    footer: `<button type="button" class="btn secondary" data-close>Close</button>${booking.can_cancel ? '<button type="button" class="btn danger" data-details-cancel>Cancel booking</button>' : ''}`
  });
  if (booking.can_cancel) {
    modal.root.querySelector('[data-details-cancel]').addEventListener('click', () => {
      modal.close();
      openCancel(booking);
    });
  }
}

function openCancel(booking) {
  const recurring = Boolean(booking.recurrence_group_id);
  const modal = openModal({
    title: 'Cancel booking',
    content: `
      <p>${escapeHtml(booking.facility?.name || 'This session')} · ${escapeHtml(formatRange(booking.start_at, booking.end_at))}</p>
      <form id="cancel-form" style="margin-top:.8rem">
        ${recurring ? `
          <div class="field">
            <label for="cancel-scope">Which bookings?</label>
            <select id="cancel-scope" name="scope">
              <option value="single">Only this booking</option>
              <option value="future">This and future weekly bookings</option>
              <option value="all">The whole series</option>
            </select>
          </div>` : ''}
        <div class="field">
          <label for="cancel-reason">Reason (optional)</label>
          <textarea id="cancel-reason" name="reason" rows="2" maxlength="1000" placeholder="Let the class know why you are cancelling."></textarea>
        </div>
        <p class="error-text hidden" data-error></p>
        <button class="btn danger wide" type="submit">Confirm cancellation</button>
      </form>`,
    footer: '<button type="button" class="btn secondary" data-close>Keep booking</button>'
  });
  const form = modal.body.querySelector('#cancel-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    const errorBox = form.querySelector('[data-error]');
    setButtonLoading(button, true, 'Cancelling...');
    try {
      const data = new FormData(form);
      await withStepUp(() => api.post(`/api/bookings/${encodeURIComponent(booking.id)}/cancel`, {
        reason: String(data.get('reason') || '').trim() || undefined,
        scope: data.get('scope') || 'single'
      }, { retry: false }));
      modal.close();
      toast('Booking cancelled.', 'success');
      await load();
    } catch (error) {
      if (!error.cancelled) {
        errorBox.textContent = error.message;
        errorBox.classList.remove('hidden');
      }
    } finally {
      setButtonLoading(button, false);
    }
  });
}

function openConvert(booking) {
  const modal = openModal({
    title: 'Convert to online',
    content: `
      <p class="muted small">The room will be released and students will be notified with the meeting details.</p>
      <form id="convert-form">
        <div class="field">
          <label for="convert-platform">Platform</label>
          <select id="convert-platform" name="online_platform">
            <option value="zoom">Zoom</option>
            <option value="google_meet">Google Meet</option>
            <option value="teams">Microsoft Teams</option>
            <option value="other">Other approved platform</option>
          </select>
        </div>
        <div class="field">
          <label for="convert-link">Meeting link</label>
          <input id="convert-link" name="online_link" type="url" required placeholder="https://...">
        </div>
        <div class="field">
          <label for="convert-passcode">Passcode (optional)</label>
          <input id="convert-passcode" name="meeting_passcode" maxlength="200">
        </div>
        <div class="field">
          <label for="convert-reason">Reason</label>
          <textarea id="convert-reason" name="reason" rows="2" maxlength="1000"></textarea>
        </div>
        <p class="error-text hidden" data-error></p>
        <button class="btn wide" type="submit">Convert and notify class</button>
      </form>`,
    footer: '<button type="button" class="btn secondary" data-close>Cancel</button>'
  });
  const form = modal.body.querySelector('#convert-form');
  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const button = form.querySelector('button[type="submit"]');
    const errorBox = form.querySelector('[data-error]');
    setButtonLoading(button, true, 'Converting...');
    try {
      const data = Object.fromEntries(new FormData(form).entries());
      await withStepUp(() => api.post(`/api/bookings/${encodeURIComponent(booking.id)}/convert-online`, {
        online_platform: data.online_platform,
        online_link: data.online_link,
        meeting_passcode: data.meeting_passcode || null,
        reason: data.reason || undefined
      }, { retry: false }));
      modal.close();
      toast('Session converted to online. Students were notified.', 'success');
      await load();
    } catch (error) {
      if (!error.cancelled) {
        errorBox.textContent = error.message;
        errorBox.classList.remove('hidden');
      }
    } finally {
      setButtonLoading(button, false);
    }
  });
}

function geolocation() {
  return new Promise((resolve, reject) => {
    if (!navigator.geolocation) {
      reject(new Error('Location is not available on this device. Scan the door QR instead.'));
      return;
    }
    navigator.geolocation.getCurrentPosition(
      (position) => resolve(position.coords),
      (error) => reject(new Error(error.message || 'Could not read your location.')),
      { enableHighAccuracy: true, timeout: 15000, maximumAge: 0 }
    );
  });
}

function openCheckin(booking) {
  const modal = openModal({
    title: 'Check in',
    content: `<p>${escapeHtml(booking.facility?.name || 'Your session')} · ${escapeHtml(formatRange(booking.start_at, booking.end_at))}</p>`,
    footer: '<button type="button" class="btn secondary" data-close>Cancel</button>'
  });
  modal.body.innerHTML = `
    <div class="list">
      <button type="button" class="list-item" data-method="rotating" style="text-align:left"><span class="item-icon">${icon('scan')}</span><span class="main"><h3>Scan the door QR</h3><p>Scan the live code at the room door</p></span></button>
      <button type="button" class="list-item" data-method="static_geo" style="text-align:left"><span class="item-icon">${icon('pin')}</span><span class="main"><h3>Use my location</h3><p>Confirm you are inside the room radius</p></span></button>
    </div>
    <p class="error-text hidden" data-error style="margin-top:.6rem"></p>`;
  const errorBox = modal.body.querySelector('[data-error]');
  modal.body.querySelectorAll('[data-method]').forEach((button) => {
    button.addEventListener('click', async () => {
      const method = button.dataset.method;
      try {
        let payload;
        if (method === 'rotating') {
          const token = await scanQr({ title: 'Scan the door QR' });
          payload = { method: 'rotating', door_token: token.trim() };
        } else {
          const coords = await geolocation();
          payload = { method: 'static_geo', latitude: coords.latitude, longitude: coords.longitude, accuracy: coords.accuracy };
        }
        const result = await api.post(`/api/bookings/${encodeURIComponent(booking.id)}/checkin`, payload, { retry: false });
        modal.close();
        toast(result.already_checked_in ? 'You were already checked in.' : 'Checked in successfully.', 'success');
        await load();
      } catch (error) {
        if (!error.cancelled) {
          errorBox.textContent = error.message;
          errorBox.classList.remove('hidden');
        }
      }
    });
  });
}

listContainer.addEventListener('click', (event) => {
  const action = event.target.closest('[data-action]');
  const card = event.target.closest('[data-booking-id]');
  if (!card) return;
  const booking = findBooking(card.dataset.bookingId);
  if (!booking) return;
  const name = action?.dataset.action;
  if (name === 'cancel') openCancel(booking);
  else if (name === 'convert') openConvert(booking);
  else if (name === 'checkin') openCheckin(booking);
  else openDetails(booking);
});

tabs.forEach((tab) => {
  tab.addEventListener('click', () => {
    tabs.forEach((item) => {
      const selected = item === tab;
      item.classList.toggle('active', selected);
      item.setAttribute('aria-selected', String(selected));
    });
    activeTab = tab.dataset.tab;
    load();
  });
});

async function start() {
  const user = await requireAuth();
  if (!user) return;
  await load();
}

start().catch(notifyError);
