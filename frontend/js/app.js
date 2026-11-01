import { api, getToken } from './api.js';
import { isLoggedIn, logout } from './auth.js';
import { mountChrome, notifyError, setUnreadCount, toast } from './ui.js';

const page = document.body.dataset.page || '';
const noChrome = document.body.hasAttribute('data-no-chrome');

if (!noChrome) mountChrome(page);

if ('serviceWorker' in navigator && location.protocol !== 'file:') {
  window.addEventListener('load', () => {
    navigator.serviceWorker.register('sw.js').catch(() => {});
  });
}

function showOfflineBar(show) {
  let bar = document.getElementById('offline-bar');
  if (show && !bar) {
    bar = document.createElement('div');
    bar.id = 'offline-bar';
    bar.className = 'offline-bar';
    bar.textContent = 'You are offline. Cached pages remain available; live actions will resume when connected.';
    document.body.prepend(bar);
  } else if (!show && bar) {
    bar.remove();
  }
}

window.addEventListener('online', () => {
  showOfflineBar(false);
  toast('Back online.', 'success');
  refreshUnread();
});
window.addEventListener('offline', () => showOfflineBar(true));
if (!navigator.onLine) showOfflineBar(true);

window.addEventListener('campus:retrying', (event) => {
  const key = 'campus.retryToastAt';
  const now = Date.now();
  if (now - Number(sessionStorage.getItem(key) || 0) > 12000) {
    sessionStorage.setItem(key, String(now));
    toast(event.detail?.message || 'Connecting to the campus server...', 'info', 5000);
  }
});

export async function refreshUnread() {
  if (!isLoggedIn()) {
    setUnreadCount(0);
    return;
  }
  try {
    const result = await api.get('/api/notifications/unread-count', { retry: false, skipAuthRedirect: true });
    setUnreadCount(result.unread);
  } catch {
    setUnreadCount(0);
  }
}

if (isLoggedIn() && getToken()) refreshUnread();

document.addEventListener('click', async (event) => {
  const button = event.target.closest('[data-logout]');
  if (!button) return;
  event.preventDefault();
  await logout();
});

window.addEventListener('beforeinstallprompt', (event) => {
  event.preventDefault();
  window.campusInstallPrompt = event;
  document.dispatchEvent(new CustomEvent('campus:installable'));
});

window.campusRefreshUnread = refreshUnread;

window.addEventListener('unhandledrejection', (event) => {
  if (event.reason && !event.reason.cancelled) notifyError(event.reason);
});
