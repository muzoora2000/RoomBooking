const TZ = 'Africa/Kampala';
const SVG = {
  home: '<path d="M3 10.8 12 3l9 7.8v9.2a1 1 0 0 1-1 1h-5v-6H9v6H4a1 1 0 0 1-1-1z"/>',
  search: '<circle cx="11" cy="11" r="7"/><path d="m20 20-4-4"/>',
  video: '<rect x="2" y="5" width="14" height="14" rx="2"/><path d="m16 10 6-4v12l-6-4"/>',
  calendar: '<rect x="3" y="5" width="18" height="16" rx="2"/><path d="M16 3v4M8 3v4M3 10h18"/>',
  settings: '<circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.7 1.7 0 0 0 .3 1.9l.1.1-2.8 2.8-.1-.1a1.7 1.7 0 0 0-1.9-.3 1.7 1.7 0 0 0-1 1.6v.2h-4v-.2a1.7 1.7 0 0 0-1-1.6 1.7 1.7 0 0 0-1.9.3l-.1.1L4.2 17l.1-.1a1.7 1.7 0 0 0 .3-1.9A1.7 1.7 0 0 0 3 14H2.8v-4H3a1.7 1.7 0 0 0 1.6-1 1.7 1.7 0 0 0-.3-1.9L4.2 7 7 4.2l.1.1A1.7 1.7 0 0 0 9 4.6a1.7 1.7 0 0 0 1-1.6v-.2h4V3a1.7 1.7 0 0 0 1 1.6 1.7 1.7 0 0 0 1.9-.3l.1-.1L19.8 7l-.1.1a1.7 1.7 0 0 0-.3 1.9 1.7 1.7 0 0 0 1.6 1h.2v4H21a1.7 1.7 0 0 0-1.6 1z"/>',
  bell: '<path d="M18 8a6 6 0 0 0-12 0c0 7-3 7-3 9h18c0-2-3-2-3-9"/><path d="M10 21h4"/>',
  shield: '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>',
  pin: '<path d="M20 10c0 5-8 12-8 12S4 15 4 10a8 8 0 1 1 16 0z"/><circle cx="12" cy="10" r="2.5"/>',
  clock: '<circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/>',
  users: '<path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M23 21v-2a4 4 0 0 0-3-3.9M16 3.1a4 4 0 0 1 0 7.8"/>',
  arrow: '<path d="M5 12h14M13 6l6 6-6 6"/>',
  check: '<path d="m5 12 4 4L19 6"/>',
  x: '<path d="M18 6 6 18M6 6l12 12"/>',
  plus: '<path d="M12 5v14M5 12h14"/>',
  refresh: '<path d="M21 12a9 9 0 0 1-15.5 6.2L3 16"/><path d="M3 21v-5h5"/><path d="M3 12A9 9 0 0 1 18.5 5.8L21 8"/><path d="M21 3v5h-5"/>',
  logout: '<path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="m16 17 5-5-5-5M21 12H9"/>',
  scan: '<path d="M3 7V4a1 1 0 0 1 1-1h3M17 3h3a1 1 0 0 1 1 1v3M21 17v3a1 1 0 0 1-1 1h-3M7 21H4a1 1 0 0 1-1-1v-3"/><path d="M7 12h10"/>',
  link: '<path d="M10 13a5 5 0 0 0 7.5.5l2-2a5 5 0 0 0-7-7l-1.2 1.2"/><path d="M14 11a5 5 0 0 0-7.5-.5l-2 2a5 5 0 0 0 7 7l1.2-1.2"/>',
  map: '<path d="m3 6 6-3 6 3 6-3v15l-6 3-6-3-6 3z"/><path d="M9 3v15M15 6v15"/>',
  book: '<path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20V2H6.5A2.5 2.5 0 0 0 4 4.5z"/><path d="M4 19.5A2.5 2.5 0 0 0 6.5 22H20v-5"/>',
  user: '<path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/>',
  door: '<path d="M4 21h16"/><path d="M6 21V4a1 1 0 0 1 1-1h10a1 1 0 0 1 1 1v17"/><path d="M14 12h.01"/>',
  alert: '<path d="M10.3 3.9 1.8 18a2 2 0 0 0 1.7 3h17a2 2 0 0 0 1.7-3L13.7 3.9a2 2 0 0 0-3.4 0z"/><path d="M12 9v4M12 17h.01"/>',
  chevron: '<path d="m9 18 6-6-6-6"/>',
  inbox: '<path d="M22 12h-6l-2 3h-4l-2-3H2"/><path d="M5.5 5.1 2 12v6a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2v-6l-3.5-6.9A2 2 0 0 0 16.8 4H7.2a2 2 0 0 0-1.7 1.1z"/>'
};

export function icon(name, className = '') {
  const path = SVG[name] || SVG.arrow;
  return `<svg class="${className}" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.9" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">${path}</svg>`;
}

export function escapeHtml(value) {
  return String(value ?? '')
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#039;');
}

export function initials(name) {
  return String(name || '?')
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 2)
    .map((part) => part[0].toUpperCase())
    .join('');
}

export function avatar(name, size = '') {
  return `<span class="avatar ${size}" aria-hidden="true">${escapeHtml(initials(name))}</span>`;
}

function formatKampala(value, options) {
  if (!value) return '';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '';
  return new Intl.DateTimeFormat('en-GB', { timeZone: TZ, ...options }).format(date);
}

export function formatDate(value, options = {}) {
  const defaults = options.dateStyle || options.timeStyle ? {} : { day: 'numeric', month: 'short', year: 'numeric' };
  return formatKampala(value, { ...defaults, ...options });
}

export function formatDayNumber(value) {
  return formatKampala(value, { day: 'numeric' });
}

export function formatMonthShort(value) {
  return formatKampala(value, { month: 'short' });
}

export function formatTime(value) {
  if (!value) return '';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '';
  return new Intl.DateTimeFormat('en-GB', {
    timeZone: TZ,
    hour: '2-digit',
    minute: '2-digit',
    hour12: false
  }).format(date);
}

export function formatDateTime(value) {
  if (!value) return '';
  return `${formatDate(value)} at ${formatTime(value)}`;
}

export function formatRange(start, end) {
  if (!start) return '';
  const startText = `${formatDate(start, { weekday: 'short' })} ${formatTime(start)}`;
  return end ? `${startText} - ${formatTime(end)}` : startText;
}

export function relativeTime(value) {
  if (!value) return '';
  const date = new Date(value);
  if (Number.isNaN(date.getTime())) return '';
  const diff = date.getTime() - Date.now();
  const minutes = Math.round(diff / 60000);
  const formatter = new Intl.RelativeTimeFormat('en', { numeric: 'auto' });
  if (Math.abs(minutes) < 60) return formatter.format(minutes, 'minute');
  const hours = Math.round(minutes / 60);
  if (Math.abs(hours) < 24) return formatter.format(hours, 'hour');
  const days = Math.round(hours / 24);
  if (Math.abs(days) < 30) return formatter.format(days, 'day');
  return formatDate(value);
}

export function durationText(minutes) {
  const value = Number(minutes || 0);
  if (value < 60) return `${value} min`;
  const hours = Math.floor(value / 60);
  const rest = value % 60;
  return rest ? `${hours}h ${rest}m` : `${hours}h`;
}

export function statusLabel(status) {
  return String(status || '')
    .replaceAll('_', ' ')
    .replace(/\b\w/g, (letter) => letter.toUpperCase());
}

export function badge(status, label = '') {
  const key = String(status || '').toLowerCase().replaceAll(' ', '_');
  return `<span class="badge ${escapeHtml(key)}">${escapeHtml(label || statusLabel(status))}</span>`;
}

export function modeBadge(mode) {
  const labels = { physical: 'In person', online: 'Online', hybrid: 'Hybrid' };
  return badge(mode, labels[mode] || mode);
}

export function toast(message, type = 'info', timeout = 4200) {
  let stack = document.querySelector('.toast-stack');
  if (!stack) {
    stack = document.createElement('div');
    stack.className = 'toast-stack';
    stack.setAttribute('aria-live', 'polite');
    document.body.appendChild(stack);
  }
  const item = document.createElement('div');
  item.className = `toast ${type}`;
  item.textContent = message;
  stack.appendChild(item);
  setTimeout(() => item.remove(), timeout);
}

export function errorMessage(error) {
  if (!error) return 'Something went wrong.';
  return error.message || 'Something went wrong.';
}

export function notifyError(error) {
  toast(errorMessage(error), 'error', 6000);
}

export function emptyState(title, message = '', action = '') {
  return `<div class="empty"><div class="empty-icon">${icon('search')}</div><h3>${escapeHtml(title)}</h3>${message ? `<p>${escapeHtml(message)}</p>` : ''}${action}</div>`;
}

export function skeletons(container, count = 3) {
  if (!container) return;
  container.innerHTML = Array.from({ length: count }, () => '<div class="skeleton"></div>').join('');
}

export function setButtonLoading(button, loading, text = 'Working...') {
  if (!button) return;
  if (loading) {
    button.dataset.originalText = button.textContent;
    button.disabled = true;
    button.textContent = text;
  } else {
    button.disabled = false;
    button.textContent = button.dataset.originalText || button.textContent;
    delete button.dataset.originalText;
  }
}

export function debounce(fn, wait = 350) {
  let timer;
  return (...args) => {
    clearTimeout(timer);
    timer = setTimeout(() => fn(...args), wait);
  };
}

export function formObject(form) {
  const result = {};
  const data = new FormData(form);
  for (const [key, value] of data.entries()) {
    if (value instanceof File) continue;
    if (result[key] !== undefined) {
      result[key] = Array.isArray(result[key]) ? [...result[key], value] : [result[key], value];
    } else {
      result[key] = value;
    }
  }
  for (const element of form.querySelectorAll('input[type="checkbox"]')) {
    result[element.name] = element.checked;
  }
  return result;
}

export function queryParams() {
  return new URLSearchParams(location.search);
}

export function cachedUser() {
  try {
    return JSON.parse(localStorage.getItem('campus.user') || 'null');
  } catch {
    return null;
  }
}

export function mountChrome(active = '') {
  const user = cachedUser();
  const loggedIn = Boolean(localStorage.getItem('campus.token'));
  const admin = user && ['department_admin', 'super_admin'].includes(user.role);
  const top = document.getElementById('topbar');
  if (top) {
    top.className = 'topbar';
    top.innerHTML = `
      <div class="topbar-inner">
        <a class="brand" href="index.html" aria-label="Campus Compass home">
          <span class="brand-mark">${icon('pin')}</span>
          <span>Campus Compass<small>Find. Book. Arrive.</small></span>
        </a>
        <div class="top-actions">
          ${loggedIn ? `
            <a class="icon-btn" href="notifications.html" aria-label="Notifications">
              ${icon('bell')}<span class="badge-dot hidden" id="notif-count">0</span>
            </a>
            ${admin ? `<a class="icon-btn" href="admin.html" aria-label="Administration">${icon('shield')}</a>` : ''}
            <a class="icon-btn" href="settings.html" aria-label="Settings">${icon('settings')}</a>
          ` : `
            <a class="btn secondary small" href="login.html" style="font-size:.85rem;padding:.4rem .9rem">Sign in</a>
          `}
        </div>
      </div>`;
  }
  const nav = document.getElementById('bottom-nav');
  if (nav) {
    nav.className = 'bottom-nav';
    const items = loggedIn
      ? [
          ['index.html', 'home', 'Home', 'home'],
          ['rooms.html', 'rooms', 'Rooms', 'search'],
          ['lectures.html', 'lectures', 'Lectures', 'video'],
          ['bookings.html', 'bookings', 'Bookings', 'calendar'],
          ['settings.html', 'settings', 'Settings', 'settings']
        ]
      : [
          ['index.html', 'home', 'Home', 'home'],
          ['rooms.html', 'rooms', 'Rooms', 'search'],
          ['login.html', 'login', 'Sign in', 'user']
        ];
    nav.innerHTML = items.map(([href, key, label, iconName]) => (
      `<a href="${href}" class="${active === key ? 'active' : ''}" ${active === key ? 'aria-current="page"' : ''}>
        <span>${icon(iconName)}</span><span>${label}</span>
      </a>`
    )).join('');
  }
}

export function setUnreadCount(count) {
  const badge = document.getElementById('notif-count');
  if (!badge) return;
  const value = Number(count || 0);
  badge.textContent = value > 99 ? '99+' : String(value);
  badge.classList.toggle('hidden', value <= 0);
}

export function openModal({ title, content, footer = '', onClose = null, wide = false }) {
  const root = document.createElement('div');
  root.className = 'modal-backdrop';
  root.innerHTML = `
    <div class="modal" role="dialog" aria-modal="true" aria-labelledby="modal-title" ${wide ? 'style="width:min(820px,100%)"' : ''}>
      <div class="modal-head">
        <h2 id="modal-title">${escapeHtml(title)}</h2>
        <button type="button" class="icon-btn" data-close aria-label="Close">${icon('x')}</button>
      </div>
      <div class="modal-body">${content}</div>
      ${footer ? `<div class="modal-foot btn-row" style="margin-top:1rem;justify-content:flex-end">${footer}</div>` : ''}
    </div>`;
  const close = () => {
    root.remove();
    document.removeEventListener('keydown', onKey);
    if (onClose) onClose();
  };
  const onKey = (event) => {
    if (event.key === 'Escape') close();
  };
  root.addEventListener('click', (event) => {
    if (event.target === root || event.target.closest('[data-close]')) close();
  });
  document.addEventListener('keydown', onKey);
  document.body.appendChild(root);
  const focusable = root.querySelector('input, select, textarea, button:not([data-close])');
  if (focusable) setTimeout(() => focusable.focus(), 50);
  return { root, close, body: root.querySelector('.modal-body') };
}

export function confirmDialog(message, { title = 'Please confirm', confirmText = 'Confirm', danger = false } = {}) {
  return new Promise((resolve) => {
    const modal = openModal({
      title,
      content: `<p>${escapeHtml(message)}</p>`,
      footer: `<button type="button" class="btn secondary" data-cancel>Cancel</button><button type="button" class="btn ${danger ? 'danger' : ''}" data-confirm>${escapeHtml(confirmText)}</button>`,
      onClose: () => resolve(false)
    });
    modal.root.querySelector('[data-cancel]').addEventListener('click', () => {
      modal.close();
      resolve(false);
    });
    modal.root.querySelector('[data-confirm]').addEventListener('click', () => {
      modal.root.remove();
      resolve(true);
    });
  });
}

export function loadScript(src, globalName = null) {
  if (globalName && window[globalName]) return Promise.resolve(window[globalName]);
  const existing = [...document.scripts].find((script) => script.src === src);
  if (existing) {
    return new Promise((resolve, reject) => {
      existing.addEventListener('load', () => resolve(globalName ? window[globalName] : true));
      existing.addEventListener('error', () => reject(new Error('Could not load a required script.')));
    });
  }
  return new Promise((resolve, reject) => {
    const script = document.createElement('script');
    script.src = src;
    script.async = true;
    script.onload = () => resolve(globalName ? window[globalName] : true);
    script.onerror = () => reject(new Error('Could not load a required script. Check your connection.'));
    document.head.appendChild(script);
  });
}

export function loadStyle(href) {
  if ([...document.styleSheets].some((sheet) => sheet.href === href)) return;
  const link = document.createElement('link');
  link.rel = 'stylesheet';
  link.href = href;
  document.head.appendChild(link);
}

export async function scanQr({ title = 'Scan a QR code' } = {}) {
  const modal = openModal({
    title,
    content: `
      <div id="scanner-region" style="border-radius:14px;overflow:hidden;background:#0b1512;min-height:240px"></div>
      <p class="hint" id="scanner-status">Point the camera at a room, event, or campus QR code.</p>
      <div class="field" style="margin-top:.8rem">
        <label for="manual-qr">Or enter the code manually</label>
        <div style="display:flex;gap:.5rem">
          <input id="manual-qr" autocomplete="off" placeholder="Paste QR contents">
          <button type="button" class="btn secondary" id="manual-go">Use</button>
        </div>
      </div>`,
    footer: `<button type="button" class="btn secondary" data-close>Cancel</button>`
  });
  const region = modal.root.querySelector('#scanner-region');
  const status = modal.root.querySelector('#scanner-status');
  const manual = modal.root.querySelector('#manual-qr');
  let scanner = null;
  let finished = false;

  return new Promise(async (resolve, reject) => {
    const finish = async (value) => {
      if (finished) return;
      finished = true;
      if (scanner) {
        try { await scanner.stop(); } catch { scanner = null; }
        try { scanner.clear(); } catch { scanner = null; }
      }
      modal.close();
      resolve(value);
    };
    const cancel = () => {
      if (finished) return;
      finished = true;
      if (scanner) {
        scanner.stop().catch(() => {});
        scanner.clear();
      }
      modal.close();
      reject(Object.assign(new Error('Scan cancelled.'), { cancelled: true }));
    };
    modal.root.querySelectorAll('[data-close]').forEach((button) => {
      button.addEventListener('click', cancel);
      button.setAttribute('data-close', '');
    });
    modal.root.addEventListener('click', (event) => {
      if (event.target === modal.root) cancel();
    });
    modal.root.querySelector('#manual-go').addEventListener('click', () => {
      if (manual.value.trim()) finish(manual.value.trim());
    });
    manual.addEventListener('keydown', (event) => {
      if (event.key === 'Enter') {
        event.preventDefault();
        if (manual.value.trim()) finish(manual.value.trim());
      }
    });
    try {
      const lib = await loadScript('https://unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js', 'Html5Qrcode');
      scanner = new lib('scanner-region', { verbose: false });
      await scanner.start(
        { facingMode: 'environment' },
        { fps: 10, qrbox: { width: 230, height: 230 } },
        (text) => finish(text),
        () => {}
      );
      status.textContent = 'Camera active. Hold the code steady inside the frame.';
    } catch (error) {
      status.textContent = 'Camera scanning is unavailable. Enter the code manually below.';
      if (error && error.message && !/camera|permission|notfound|notallowed/i.test(error.message)) {
        status.textContent = error.message;
      }
    }
  });
}

export async function renderQr(element, text, size = 220) {
  if (!element) return;
  const lib = await loadScript('https://cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js', 'QRCode');
  element.innerHTML = '';
  new lib(element, { text, width: size, height: size, correctLevel: lib.CorrectLevel.M });
}

export function downloadText(filename, text, type = 'text/plain') {
  const blob = new Blob([text], { type });
  const url = URL.createObjectURL(blob);
  const link = document.createElement('a');
  link.href = url;
  link.download = filename;
  document.body.appendChild(link);
  link.click();
  link.remove();
  setTimeout(() => URL.revokeObjectURL(url), 10000);
}

export function copyText(text) {
  if (navigator.clipboard && window.isSecureContext) return navigator.clipboard.writeText(text);
  const input = document.createElement('textarea');
  input.value = text;
  input.style.position = 'fixed';
  input.style.opacity = '0';
  document.body.appendChild(input);
  input.select();
  document.execCommand('copy');
  input.remove();
  return Promise.resolve();
}

export function setupTabs(container, onChange) {
  if (!container) return;
  const buttons = [...container.querySelectorAll('button[data-tab]')];
  buttons.forEach((button) => {
    button.addEventListener('click', () => {
      buttons.forEach((item) => item.setAttribute('aria-selected', String(item === button)));
      onChange(button.dataset.tab);
    });
  });
  const selected = buttons.find((button) => button.getAttribute('aria-selected') === 'true') || buttons[0];
  if (selected) {
    selected.setAttribute('aria-selected', 'true');
    onChange(selected.dataset.tab);
  }
}
