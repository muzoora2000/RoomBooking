import { api } from '../api.js';
import { getUser, isLoggedIn, refreshMe, roleLabel } from '../auth.js';
import {
  badge,
  escapeHtml,
  formatDate,
  formatRange,
  icon,
  modeBadge,
  notifyError,
  avatar
} from '../ui.js';

const guest = document.getElementById('guest-home');
const member = document.getElementById('member-home');

function greetingForHour() {
  const hour = Number(new Intl.DateTimeFormat('en-GB', {
    timeZone: 'Africa/Kampala',
    hour: '2-digit',
    hour12: false
  }).format(new Date()));
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

function renderStats(overview) {
  const user = getUser();
  const isAdmin = user && (user.role === 'super_admin' || user.role === 'department_admin');
  const items = [
    [overview.upcoming_bookings, isAdmin ? 'Upcoming bookings (managed)' : 'Upcoming bookings'],
    [overview.unread_notifications, 'Unread notifications'],
    [overview.modules, 'Enrolled modules'],
    [overview.recent_no_shows, 'No-shows in 30 days']
  ];
  document.getElementById('overview-stats').innerHTML = items.map(([value, label]) => (
    `<div class="stat"><strong>${Number(value || 0)}</strong><span>${escapeHtml(label)}</span></div>`
  )).join('');
}

function renderLectures(lectures) {
  const container = document.getElementById('next-lectures');
  if (!lectures.length) {
    container.innerHTML = `<div class="empty"><p>No upcoming lectures are visible to you.</p><a class="btn secondary small" href="lectures.html">Open lectures</a></div>`;
    return;
  }
  container.innerHTML = lectures.slice(0, 3).map((item) => `
    <a class="list-item" href="lectures.html?lecture=${encodeURIComponent(item.id)}">
      <span class="item-icon">${icon('video')}</span>
      <span class="main">
        <h3>${escapeHtml(item.module?.code || item.purpose || 'Session')} ${escapeHtml(item.module?.name || '')}</h3>
        <p>${escapeHtml(formatRange(item.start_at, item.end_at))}</p>
        <p>${item.show_room && item.facility ? escapeHtml(item.facility.name) : 'Online session'} ${modeBadge(item.session_mode)}</p>
      </span>
    </a>
  `).join('');
}

function renderBookings(bookings) {
  const container = document.getElementById('next-bookings');
  if (!bookings.length) {
    container.innerHTML = `<div class="empty"><p>No upcoming room bookings.</p><a class="btn secondary small" href="rooms.html">Find a room</a></div>`;
    return;
  }
  container.innerHTML = bookings.slice(0, 3).map((item) => `
    <a class="list-item" href="bookings.html?booking=${encodeURIComponent(item.id)}">
      <span class="item-icon">${icon('calendar')}</span>
      <span class="main">
        <h3>${escapeHtml(item.facility?.name || 'Online session')}</h3>
        <p>${escapeHtml(formatRange(item.start_at, item.end_at))}</p>
        <p>${badge(item.status)} ${modeBadge(item.session_mode)}</p>
      </span>
    </a>
  `).join('');
}

async function load() {
  if (!isLoggedIn()) {
    guest.classList.remove('hidden');
    return;
  }
  member.classList.remove('hidden');
  document.getElementById('today-label').textContent = formatDate(new Date(), { weekday: 'long' });
  let user = getUser();
  try {
    user = await refreshMe();
  } catch (error) {
    if (error.status === 401) return;
  }
  // Build a friendly first name: use first token of full name, fall back to role label
  const firstName = (() => {
    const parts = String(user.name || '').trim().split(/\s+/).filter(Boolean);
    // If name exists and doesn't look like a generic system label, use first part
    if (parts.length && !/^system$/i.test(parts[0])) return parts[0];
    // Fall back to their role label (e.g. "Super administrator")
    return roleLabel(user.role);
  })();
  document.getElementById('greeting').textContent = `${greetingForHour()}, ${firstName}`;

  // Show role label as a subtitle so admins always know their access level
  const greetingSub = document.getElementById('greeting-sub');
  if (greetingSub) {
    greetingSub.textContent = `${roleLabel(user.role)} · Here is what is happening on campus today.`;
  }
  document.getElementById('quick-unread').textContent = 'Updates and reminders';

  const now = new Date().toISOString();
  const [overview, lectures, bookings, profile] = await Promise.allSettled([
    api.get('/api/me/overview'),
    api.get('/api/lectures?from=' + encodeURIComponent(now)),
    api.get('/api/bookings?from=' + encodeURIComponent(now)),
    api.get('/api/me/profile')
  ]);

  if (overview.status === 'fulfilled') renderStats(overview.value);
  else {
    document.getElementById('overview-stats').innerHTML = `<div class="notice warning">${escapeHtml(overview.reason.message)}</div>`;
  }
  if (lectures.status === 'fulfilled') renderLectures(lectures.value.lectures || []);
  else document.getElementById('next-lectures').innerHTML = `<div class="notice warning">${escapeHtml(lectures.reason.message)}</div>`;
  if (bookings.status === 'fulfilled') renderBookings(bookings.value.bookings || []);
  else document.getElementById('next-bookings').innerHTML = `<div class="notice warning">${escapeHtml(bookings.reason.message)}</div>`;

  if (profile.status === 'fulfilled') {
    const semester = profile.value.current_semester;
    if (semester) {
      document.getElementById('semester-name').textContent = semester.name;
      document.getElementById('semester-dates').textContent = `${formatDate(semester.start_date)} to ${formatDate(semester.end_date)}`;
    } else {
      document.getElementById('semester-name').textContent = 'No current semester';
      document.getElementById('semester-dates').textContent = 'An administrator needs to set the current semester.';
    }
    if (profile.value.unread_notifications) {
      document.getElementById('quick-unread').textContent = `${profile.value.unread_notifications} unread updates`;
    }
  }
}

load().catch(notifyError);
