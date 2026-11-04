import { api, queryString } from '../api.js';
import { requireAuth } from '../auth.js';
import {
  emptyState,
  escapeHtml,
  formatDate,
  icon,
  notifyError,
  toast
} from '../ui.js';

const listContainer = document.getElementById('notifications-list');
const loadMoreButton = document.getElementById('load-more');
const markAllButton = document.getElementById('mark-all');
const clearAllButton = document.getElementById('clear-all');
const pushButton = document.getElementById('push-toggle');
const pushStatus = document.getElementById('push-status');
const pushMessage = document.getElementById('push-message');
const tabs = [...document.querySelectorAll('[data-notification-tab]')];
let notifications = [];
let activeTab = 'all';
let nextBefore = null;
let loading = false;
let pushState = null;

const typeIcons = {
  booking_confirmed: 'calendar',
  booking_cancelled: 'calendar',
  booking_reminder: 'clock',
  session_change: 'refresh',
  checkin_reminder: 'scan',
  no_show: 'alert',
  displacement: 'alert',
  system_alert: 'shield',
  approval_request: 'inbox'
};

function safeLink(link) {
  if (!link || typeof link !== 'string') return null;
  if (link.startsWith('/') && !link.startsWith('//')) return link;
  return null;
}

function renderNotification(item) {
  const link = safeLink(item.link);
  return `
    <article class="notification ${item.is_read ? '' : 'unread'} ${escapeHtml(item.severity || '')}" data-id="${escapeHtml(item.id)}" ${link ? `data-link="${escapeHtml(link)}"` : ''}>
      <span class="item-icon">${icon(typeIcons[item.type] || 'bell')}</span>
      <div class="main">
        <div class="row space-between" style="gap:.5rem">
          <h3>${escapeHtml(item.title)}</h3>
          ${item.is_read ? '' : '<span class="unread-dot" aria-label="Unread"></span>'}
        </div>
        <p>${escapeHtml(item.message)}</p>
        <span class="small muted">${escapeHtml(formatDate(item.created_at, { dateStyle: 'medium', timeStyle: 'short' }))}</span>
      </div>
      ${link ? `<span class="notification-arrow">${icon('chevron')}</span>` : ''}
    </article>`;
}

function render() {
  if (!notifications.length) {
    listContainer.innerHTML = emptyState(
      activeTab === 'unread' ? 'You are all caught up' : 'No notifications yet',
      activeTab === 'unread' ? 'New booking changes and reminders will appear here.' : 'Campus updates will appear here.'
    );
    loadMoreButton.classList.add('hidden');
    return;
  }
  listContainer.innerHTML = `<div class="notification-list">${notifications.map(renderNotification).join('')}</div>`;
  loadMoreButton.classList.toggle('hidden', !nextBefore);
}

async function load({ append = false } = {}) {
  if (loading) return;
  loading = true;
  if (!append) {
    listContainer.innerHTML = '<div class="skeleton"></div><div class="skeleton"></div><div class="skeleton"></div>';
    notifications = [];
    nextBefore = null;
  }
  try {
    const params = { limit: 30 };
    if (activeTab === 'unread') params.unread = 'true';
    if (append && nextBefore) params.before = nextBefore;
    const result = await api.get(`/api/notifications${queryString(params)}`);
    notifications = append ? [...notifications, ...(result.notifications || [])] : (result.notifications || []);
    nextBefore = result.next_before || null;
    render();
  } catch (error) {
    listContainer.innerHTML = `<div class="notice danger">${escapeHtml(error.message)}</div>`;
  } finally {
    loading = false;
  }
}

async function openNotification(id) {
  const item = notifications.find((entry) => entry.id === id);
  if (!item) return;
  const link = safeLink(item.link);
  if (!item.is_read) {
    try {
      await api.post(`/api/notifications/${encodeURIComponent(item.id)}/read`, {}, { retry: false });
      item.is_read = true;
      if (typeof window.campusRefreshUnread === 'function') window.campusRefreshUnread();
    } catch (error) {
      toast(error.message, 'error');
    }
  }
  if (link) {
    window.location.href = link;
  } else {
    render();
  }
}

async function clearAll() {
  const confirmed = window.confirm('Delete all notifications? This cannot be undone.');
  if (!confirmed) return;
  if (clearAllButton) clearAllButton.disabled = true;
  try {
    await api.delete('/api/notifications/all');
    notifications = [];
    nextBefore = null;
    render();
    if (typeof window.campusRefreshUnread === 'function') window.campusRefreshUnread();
    toast('All notifications cleared.', 'success');
  } catch (error) {
    toast(error.message, 'error');
  } finally {
    if (clearAllButton) clearAllButton.disabled = false;
  }
}

async function markAllRead() {
  markAllButton.disabled = true;
  try {
    const result = await api.post('/api/notifications/read-all', {}, { retry: false });
    notifications = notifications.map((item) => ({ ...item, is_read: true }));
    if (activeTab === 'unread') notifications = [];
    render();
    if (typeof window.campusRefreshUnread === 'function') window.campusRefreshUnread();
    toast(result.marked ? `${result.marked} notification${result.marked === 1 ? '' : 's'} marked read.` : 'Nothing to mark.', 'success');
  } catch (error) {
    toast(error.message, 'error');
  } finally {
    markAllButton.disabled = false;
  }
}

function base64ToBytes(base64) {
  const padding = '='.repeat((4 - base64.length % 4) % 4);
  const value = (base64 + padding).replace(/-/g, '+').replace(/_/g, '/');
  const raw = atob(value);
  return Uint8Array.from([...raw].map((char) => char.charCodeAt(0)));
}

async function refreshPush() {
  if (!('serviceWorker' in navigator) || !('PushManager' in window) || !('Notification' in window)) {
    pushStatus.textContent = 'This browser does not support web push.';
    pushButton.disabled = true;
    pushButton.textContent = 'Unavailable';
    return;
  }
  try {
    pushState = await api.get('/api/notifications/push/key', { retry: false });
  } catch (error) {
    pushStatus.textContent = 'Could not check push settings.';
    pushMessage.textContent = error.message;
    return;
  }
  if (!pushState.configured) {
    pushStatus.textContent = 'Push is not configured on this server yet.';
    pushMessage.textContent = pushState.message || 'In-app notifications and email still work.';
    pushButton.disabled = true;
    pushButton.textContent = 'Unavailable';
    return;
  }
  const registration = await navigator.serviceWorker.ready;
  const subscription = await registration.pushManager.getSubscription();
  if (subscription && Notification.permission === 'granted') {
    pushStatus.textContent = 'Push notifications are on for this device.';
    pushButton.textContent = 'Disable';
    pushButton.dataset.action = 'unsubscribe';
  } else {
    pushStatus.textContent = Notification.permission === 'denied'
      ? 'Notifications are blocked in your browser settings.'
      : 'Get booking reminders even when the app is closed.';
    pushButton.textContent = 'Enable';
    pushButton.dataset.action = 'subscribe';
    pushButton.disabled = Notification.permission === 'denied';
  }
  pushMessage.textContent = 'You can change this any time. Critical account alerts are also emailed.';
}

async function togglePush() {
  if (!pushState?.configured) return;
  const registration = await navigator.serviceWorker.ready;
  pushButton.disabled = true;
  try {
    if (pushButton.dataset.action === 'unsubscribe') {
      const subscription = await registration.pushManager.getSubscription();
      if (subscription) {
        await api.delete('/api/notifications/push/subscribe', { endpoint: subscription.endpoint });
        await subscription.unsubscribe();
      }
      toast('Push notifications disabled on this device.', 'success');
    } else {
      const permission = await Notification.requestPermission();
      if (permission !== 'granted') {
        toast('Notification permission was not granted. You can allow it in browser settings.', 'error');
        return;
      }
      const subscription = await registration.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: base64ToBytes(pushState.public_key)
      });
      const json = subscription.toJSON();
      await api.post('/api/notifications/push/subscribe', {
        endpoint: subscription.endpoint,
        keys: {
          p256dh: json.keys.p256dh,
          auth: json.keys.auth
        }
      }, { retry: false });
      toast('Push notifications enabled.', 'success');
    }
    await refreshPush();
  } catch (error) {
    toast(error.message, 'error');
  } finally {
    pushButton.disabled = false;
  }
}

listContainer.addEventListener('click', (event) => {
  const card = event.target.closest('[data-id]');
  if (card) openNotification(card.dataset.id).catch(notifyError);
});

loadMoreButton.addEventListener('click', () => load({ append: true }).catch(notifyError));
markAllButton.addEventListener('click', () => markAllRead().catch(notifyError));
if (clearAllButton) clearAllButton.addEventListener('click', () => clearAll().catch(notifyError));
pushButton.addEventListener('click', () => togglePush().catch(notifyError));

tabs.forEach((tab) => {
  tab.addEventListener('click', () => {
    tabs.forEach((item) => {
      const selected = item === tab;
      item.classList.toggle('active', selected);
      item.setAttribute('aria-selected', String(selected));
    });
    activeTab = tab.dataset.notificationTab;
    load();
  });
});

async function start() {
  const user = await requireAuth();
  if (!user) return;
  await Promise.all([load(), refreshPush().catch(() => {})]);
}

start().catch(notifyError);
