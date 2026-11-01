import { api, queryString } from '../api.js';
import { requireAuth } from '../auth.js';
import {
  badge,
  emptyState,
  escapeHtml,
  formatDate,
  formatRange,
  icon,
  notifyError,
  openModal,
  queryParams,
  toast
} from '../ui.js';

const listContainer = document.getElementById('lectures-list');
const searchInput = document.getElementById('lecture-search');
const modeFilter = document.getElementById('lecture-mode');
const tabs = [...document.querySelectorAll('[data-lecture-tab]')];
const query = queryParams();
let lectures = [];
let activeTab = 'upcoming';
let loading = false;

const modeLabels = { physical: 'In person', online: 'Online', hybrid: 'Hybrid' };

function rangeFor(tab) {
  const now = new Date();
  if (tab === 'past') {
    return {
      from: new Date(now.getTime() - 35 * 24 * 60 * 60 * 1000).toISOString(),
      to: now.toISOString()
    };
  }
  return {
    from: new Date(now.getTime() - 2 * 60 * 60 * 1000).toISOString(),
    to: new Date(now.getTime() + 35 * 24 * 60 * 60 * 1000).toISOString()
  };
}

function matches(lecture) {
  const term = searchInput.value.trim().toLowerCase();
  if (modeFilter.value && lecture.session_mode !== modeFilter.value) return false;
  if (!term) return true;
  return [
    lecture.module?.code,
    lecture.module?.name,
    lecture.facility?.name,
    lecture.facility?.building,
    lecture.lecturer?.name,
    lecture.purpose
  ].filter(Boolean).join(' ').toLowerCase().includes(term);
}

function actionBar(lecture) {
  const buttons = [];
  if (lecture.show_room) {
    buttons.push(`<a class="btn small secondary" href="${escapeHtml(lecture.room_url || `room.html?id=${encodeURIComponent(lecture.facility_id)}`)}">${icon('pin')} Go to room</a>`);
  }
  if (lecture.show_join) {
    if (lecture.join_available) {
      buttons.push(`<button type="button" class="btn small" data-join="${escapeHtml(lecture.id)}">${icon('video')} ${lecture.joined ? 'Join again' : 'Join online'}</button>`);
    } else {
      const opens = lecture.join_opens_at ? formatDate(lecture.join_opens_at, { dateStyle: 'medium', timeStyle: 'short' }) : '';
      buttons.push(`<button type="button" class="btn small secondary" disabled title="${escapeHtml(opens ? `Join opens ${opens}` : 'Join is closed')}">${escapeHtml(opens ? `Join opens ${opens}` : 'Join closed')}</button>`);
    }
  }
  if (lecture.can_manage && lecture.module_id) {
    buttons.push(`<button type="button" class="btn small ghost" data-roster="${escapeHtml(lecture.id)}">Roster</button>`);
  }
  return buttons.join('');
}

function renderLecture(lecture) {
  const title = lecture.module
    ? `${lecture.module.code} · ${lecture.module.name}`
    : lecture.purpose || 'Lecture';
  const room = lecture.facility;
  const joined = lecture.joined ? '<span class="badge green">Joined</span>' : '';
  const status = lecture.status !== 'confirmed' ? badge(lecture.status) : '';
  return `
    <article class="card lecture-card">
      <div class="row space-between" style="align-items:flex-start;gap:.7rem">
        <div class="main">
          <div class="chips" style="margin-bottom:.35rem">
            <span class="badge">${escapeHtml(modeLabels[lecture.session_mode] || lecture.session_mode)}</span>
            ${status}${joined}
          </div>
          <h3>${escapeHtml(title)}</h3>
          <p class="muted small">${escapeHtml(formatRange(lecture.start_at, lecture.end_at))}</p>
        </div>
        ${room ? `<a class="item-icon" href="${escapeHtml(lecture.room_url)}" aria-label="Room details">${icon('door')}</a>` : `<span class="item-icon">${icon('video')}</span>`}
      </div>
      <div class="lecture-meta">
        ${room && lecture.show_room ? `<span>${icon('pin')} ${escapeHtml(room.name)} · ${escapeHtml(room.building)} ${escapeHtml(room.room_number)}</span>` : ''}
        ${lecture.lecturer?.name ? `<span>${icon('user')} ${escapeHtml(lecture.lecturer.name)}</span>` : ''}
        ${lecture.online_platform && lecture.show_join ? `<span>${icon('video')} ${escapeHtml(lecture.online_platform.replace('_', ' '))}</span>` : ''}
      </div>
      <div class="card-actions">${actionBar(lecture)}</div>
    </article>`;
}

function render() {
  const filtered = lectures.filter(matches);
  if (!filtered.length) {
    listContainer.innerHTML = emptyState(
      activeTab === 'past' ? 'No recent lectures' : 'No lectures scheduled',
      searchInput.value || modeFilter.value ? 'Try clearing the search or mode filter.' : 'Your enrolled module sessions will appear here.'
    );
    return;
  }
  const groups = new Map();
  for (const lecture of filtered) {
    const day = lecture.day || new Date(lecture.start_at).toISOString().slice(0, 10);
    if (!groups.has(day)) groups.set(day, []);
    groups.get(day).push(lecture);
  }
  const entries = [...groups.entries()].sort(([a], [b]) => activeTab === 'past' ? b.localeCompare(a) : a.localeCompare(b));
  listContainer.innerHTML = entries.map(([day, items]) => `
    <section style="margin-bottom:1.2rem">
      <h2 class="day-heading">${escapeHtml(formatDate(`${day}T12:00:00+03:00`, { weekday: 'long', day: 'numeric', month: 'long' }))}</h2>
      ${items.sort((a, b) => new Date(a.start_at) - new Date(b.start_at)).map(renderLecture).join('')}
    </section>`).join('');
}

async function load() {
  if (loading) return;
  loading = true;
  listContainer.innerHTML = '<div class="skeleton"></div><div class="skeleton"></div><div class="skeleton"></div>';
  try {
    const result = await api.get(`/api/lectures${queryString(rangeFor(activeTab))}`);
    lectures = result.lectures || [];
    document.getElementById('semester-label').textContent = result.semester
      ? `${result.semester.name} · ${formatDate(result.semester.start_date, { day: 'numeric', month: 'short' })} to ${formatDate(result.semester.end_date, { day: 'numeric', month: 'short', year: 'numeric' })}`
      : '';
    render();
  } catch (error) {
    listContainer.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  } finally {
    loading = false;
  }
}

function showJoin(lecture, result) {
  const moduleCode = lecture?.module?.code || result.module?.code || 'Session';
  const moduleName = lecture?.module?.name || result.module?.name || '';
  const range = result.time_text || (lecture ? formatRange(lecture.start_at, lecture.end_at) : '');
  const content = `
    <p><strong>${escapeHtml(moduleCode)}</strong> · ${escapeHtml(moduleName ? `${moduleName} · ${range}` : range)}</p>
    <div class="notice info" style="margin-top:.8rem">
      <p>${escapeHtml(result.online_platform ? result.online_platform.replace('_', ' ') : 'Online meeting')}</p>
      <p style="margin-top:.5rem"><a class="btn" href="${escapeHtml(result.online_link)}" target="_blank" rel="noopener noreferrer">Open meeting link</a></p>
      ${result.meeting_passcode ? `<p class="small" style="margin-top:.6rem">Passcode: <code>${escapeHtml(result.meeting_passcode)}</code></p>` : ''}
    </div>
    <p class="hint">Only enrolled students and the teaching team can open this link. Do not share it publicly.</p>`;
  const modal = openModal({
    title: 'Join lecture',
    content,
    footer: '<button type="button" class="btn secondary" data-close>Close</button>'
  });
  setTimeout(() => modal.close(), 60000);
}

async function joinLecture(lecture, popup = null) {
  try {
    const result = await api.post(`/api/lectures/${encodeURIComponent(lecture.id)}/join`, {}, { retry: false });
    if (popup && !popup.closed) {
      popup.location.href = result.online_link;
      toast('Opening the meeting link.', 'success');
      lecture.joined = true;
      render();
    } else {
      showJoin(lecture, result);
    }
  } catch (error) {
    if (popup && !popup.closed) popup.close();
    notifyError(error);
  }
}

async function joinById(id) {
  try {
    const popup = window.open('about:blank', '_blank');
    const result = await api.post(`/api/lectures/${encodeURIComponent(id)}/join`, {}, { retry: false });
    if (popup && !popup.closed) {
      popup.location.href = result.online_link;
    } else {
      showJoin(null, result);
    }
  } catch (error) {
    notifyError(error);
  }
}

async function openRoster(id) {
  const modal = openModal({
    title: 'Class roster',
    content: '<div class="skeleton"></div><div class="skeleton"></div>',
    footer: '<button type="button" class="btn secondary" data-close>Close</button>'
  });
  try {
    const result = await api.get(`/api/lectures/${encodeURIComponent(id)}/roster`);
    const summary = result.audience_summary || {};
    const roster = result.roster || [];
    modal.body.innerHTML = `
      <div class="stats-grid">
        <div class="stat"><strong>${Number(summary.enrolled || 0)}</strong><span>Enrolled</span></div>
        <div class="stat"><strong>${Number(summary.expected_on_site || 0)}</strong><span>Expected on site</span></div>
        <div class="stat"><strong>${Number(summary.expected_online || 0)}</strong><span>Expected online</span></div>
        <div class="stat"><strong>${Number(summary.joined_online || 0)}</strong><span>Joined online</span></div>
      </div>
      <div class="table-wrap" style="margin-top:.8rem">
        <table>
          <thead><tr><th>Student</th><th>ID</th><th>Mode</th><th>Joined</th></tr></thead>
          <tbody>${roster.map((person) => `
            <tr>
              <td>${escapeHtml(person.name)}</td>
              <td>${escapeHtml(person.id_number)}</td>
              <td>${escapeHtml(person.effective_mode || person.study_mode || '')}</td>
              <td>${person.joined_at ? escapeHtml(formatDate(person.joined_at, { timeStyle: 'short' })) : '<span class="muted">-</span>'}</td>
            </tr>`).join('')}</tbody>
        </table>
      </div>
      ${roster.length ? '' : '<p class="muted small" style="margin-top:.6rem">No students are enrolled in this module.</p>'}`;
  } catch (error) {
    modal.body.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  }
}

listContainer.addEventListener('click', (event) => {
  const joinButton = event.target.closest('[data-join]');
  if (joinButton) {
    const lecture = lectures.find((item) => item.id === joinButton.dataset.join);
    const popup = window.open('about:blank', '_blank');
    if (lecture) joinLecture(lecture, popup);
    return;
  }
  const rosterButton = event.target.closest('[data-roster]');
  if (rosterButton) {
    openRoster(rosterButton.dataset.roster).catch(notifyError);
  }
});

tabs.forEach((tab) => {
  tab.addEventListener('click', () => {
    tabs.forEach((item) => {
      const selected = item === tab;
      item.classList.toggle('active', selected);
      item.setAttribute('aria-selected', String(selected));
    });
    activeTab = tab.dataset.lectureTab;
    load();
  });
});

let searchTimer;
searchInput.addEventListener('input', () => {
  clearTimeout(searchTimer);
  searchTimer = setTimeout(render, 120);
});
modeFilter.addEventListener('change', render);

async function start() {
  const user = await requireAuth();
  if (!user) return;
  await load();
  if (query.get('join')) {
    joinById(query.get('join'));
  }
}

start().catch(notifyError);
