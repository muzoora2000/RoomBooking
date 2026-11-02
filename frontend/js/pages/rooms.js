import { api, queryString } from '../api.js';
import {
  badge,
  debounce,
  emptyState,
  errorMessage,
  escapeHtml,
  icon,
  loadScript,
  loadStyle,
  notifyError,
  queryParams,
  scanQr,
  toast
} from '../ui.js';

const params = queryParams();
const list = document.getElementById('rooms-list');
const mapWrap = document.getElementById('rooms-map-wrap');
const mapElement = document.getElementById('rooms-map');
const count = document.getElementById('room-count');
const filters = document.getElementById('room-filters');
let map = null;
let markers = [];
let currentView = 'list';
let facilities = [];

const categoryLabels = {
  lecture_room: 'Lecture room',
  discussion_room: 'Discussion room',
  lab: 'Laboratory',
  office: 'Office',
  library: 'Library'
};

function roomCard(room) {
  const equipment = Array.isArray(room.equipment) ? room.equipment.filter((item) => item.quantity > 0) : [];
  return `
    <article class="card room-card">
      <div class="room-top">
        <span class="item-icon">${icon('pin')}</span>
        <div class="main" style="flex:1;min-width:0">
          <h3>${escapeHtml(room.name)}</h3>
          <div class="muted small">${escapeHtml(categoryLabels[room.category] || room.category)} · ${escapeHtml(room.department_name || '')}</div>
          <div class="room-meta">
            <span>${escapeHtml(room.building)}${room.floor ? `, ${escapeHtml(room.floor)}` : ''}</span>
            <span>Room ${escapeHtml(room.room_number)}</span>
            <span>${icon('users')} ${Number(room.capacity)} seats</span>
          </div>
        </div>
        ${badge(room.status)}
      </div>
      ${room.location_description ? `<p class="small muted" style="margin:.7rem 0 0">${escapeHtml(room.location_description)}</p>` : ''}
      ${equipment.length ? `<p class="small" style="margin:.5rem 0 0">${equipment.slice(0, 5).map((item) => `${escapeHtml(item.name)}${item.quantity > 1 ? ` x${item.quantity}` : ''}`).join(' · ')}</p>` : ''}
      <div class="room-actions">
        <a class="btn secondary small" href="room.html?id=${encodeURIComponent(room.id)}">View room</a>
        <a class="btn small" href="schedule.html?facility_id=${encodeURIComponent(room.id)}">Book</a>
        ${room.latitude && room.longitude ? `<a class="btn ghost small" target="_blank" rel="noopener" href="https://www.openstreetmap.org/?mlat=${room.latitude}&mlon=${room.longitude}#map=19/${room.latitude}/${room.longitude}">Directions</a>` : ''}
      </div>
    </article>`;
}

function renderRooms() {
  count.textContent = `${facilities.length} room${facilities.length === 1 ? '' : 's'} found`;
  if (!facilities.length) {
    list.className = '';
    list.innerHTML = emptyState('No rooms match', 'Try a different room type, capacity, or search term.');
  } else {
    list.className = 'grid two';
    list.innerHTML = facilities.map(roomCard).join('');
  }
  updateMapMarkers();
}

async function initMap() {
  if (map) return map;
  loadStyle('https://unpkg.com/leaflet@1.9.4/dist/leaflet.css');
  await loadScript('https://unpkg.com/leaflet@1.9.4/dist/leaflet.js', 'L');
  map = window.L.map(mapElement, { scrollWheelZoom: true });
  window.L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; OpenStreetMap contributors'
  }).addTo(map);
  map.setView([0.3318, 32.5701], 15);
  updateMapMarkers();
  return map;
}

function updateMapMarkers() {
  if (!map || !window.L) return;
  markers.forEach((marker) => marker.remove());
  markers = [];
  const points = [];
  for (const room of facilities) {
    const lat = Number(room.latitude);
    const lng = Number(room.longitude);
    if (!Number.isFinite(lat) || !Number.isFinite(lng)) continue;
    const marker = window.L.marker([lat, lng]).addTo(map);
    marker.bindPopup(`<strong>${escapeHtml(room.name)}</strong><br>${escapeHtml(room.building)}, ${escapeHtml(room.room_number)}<br><a href="room.html?id=${encodeURIComponent(room.id)}">Open room</a>`);
    markers.push(marker);
    points.push([lat, lng]);
  }
  if (points.length > 1) map.fitBounds(points, { padding: [30, 30], maxZoom: 18 });
  else if (points.length === 1) map.setView(points[0], 18);
}

async function loadCategories() {
  try {
    const result = await api.get('/api/facilities/categories');
    const select = document.getElementById('category-filter');
    select.innerHTML = '<option value="">All room types</option>' + result.categories
      .map((item) => `<option value="${escapeHtml(item.category)}">${escapeHtml(categoryLabels[item.category] || item.category)} (${item.count})</option>`)
      .join('');
  } catch {
    document.getElementById('category-filter').innerHTML = '<option value="">All room types</option>';
  }
}

async function loadRooms() {
  const data = Object.fromEntries(new FormData(filters).entries());
  count.textContent = 'Loading rooms...';
  list.innerHTML = '<div class="skeleton"></div><div class="skeleton"></div>';
  try {
    const result = await api.get(`/api/facilities${queryString(data)}`);
    facilities = result.facilities || [];
    renderRooms();
  } catch (error) {
    list.className = '';
    list.innerHTML = `<div class="notice danger">${escapeHtml(errorMessage(error))}</div>`;
    count.textContent = 'Could not load rooms';
  }
}

filters.addEventListener('submit', (event) => {
  event.preventDefault();
  loadRooms();
});

filters.querySelectorAll('input[type="search"]').forEach((input) => {
  input.addEventListener('input', debounce(() => loadRooms(), 450));
});

filters.querySelectorAll('select, input[type="number"]').forEach((input) => {
  input.addEventListener('change', () => loadRooms());
});

document.getElementById('clear-filters').addEventListener('click', () => {
  filters.reset();
  loadRooms();
});

document.querySelectorAll('[data-view]').forEach((button) => {
  button.addEventListener('click', async () => {
    currentView = button.dataset.view;
    document.querySelectorAll('[data-view]').forEach((item) => item.setAttribute('aria-pressed', String(item === button)));
    const mapMode = currentView === 'map';
    list.classList.toggle('hidden', mapMode);
    mapWrap.classList.toggle('hidden', !mapMode);
    document.getElementById('room-count').classList.toggle('hidden', false);
    if (mapMode) {
      try {
        await initMap();
        setTimeout(() => map.invalidateSize(), 80);
      } catch (error) {
        notifyError(error);
      }
    }
  });
});

document.getElementById('scan-room').addEventListener('click', async () => {
  try {
    const raw = await scanQr({ title: 'Scan a room QR' });
    let target = null;
    try {
      const url = new URL(raw);
      const id = url.searchParams.get('id') || url.searchParams.get('f');
      if (id) target = `room.html?id=${encodeURIComponent(id)}`;
    } catch {
      target = null;
    }
    if (target) location.href = target;
    else toast('This QR is not a room code. Use the room QR on the door.', 'error');
  } catch (error) {
    if (!error.cancelled) notifyError(error);
  }
});

async function start() {
  // Rooms are public - no auth required
  const initialQuery = params.get('q');
  if (initialQuery) filters.querySelector('[name="q"]').value = initialQuery;
  await Promise.all([loadCategories(), loadRooms()]);
}

start().catch(notifyError);
