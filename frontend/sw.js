const VERSION = 'campus-v1.0.0';
const APP_SHELL = [
  './',
  './index.html',
  './login.html',
  './rooms.html',
  './room.html',
  './bookings.html',
  './schedule.html',
  './lectures.html',
  './notifications.html',
  './settings.html',
  './admin.html',
  './display.html',
  './activate.html',
  './reset.html',
  './offline.html',
  './css/styles.css',
  './js/config.js',
  './js/api.js',
  './js/auth.js',
  './js/ui.js',
  './js/app.js',
  './js/stepup.js',
  './js/pages/activate.js',
  './js/pages/admin.js',
  './js/pages/bookings.js',
  './js/pages/display.js',
  './js/pages/home.js',
  './js/pages/lectures.js',
  './js/pages/login.js',
  './js/pages/notifications.js',
  './js/pages/reset.js',
  './js/pages/room.js',
  './js/pages/rooms.js',
  './js/pages/schedule.js',
  './js/pages/settings.js',
  './my-bookings.html',
  './admin/audit.html',
  './admin/bookings.html',
  './admin/data-requests.html',
  './admin/issues.html',
  './admin/study-mode.html',
  './manifest.webmanifest',
  './icons/icon.svg'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(VERSION).then((cache) => cache.addAll(APP_SHELL)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => Promise.all(keys.filter((key) => key !== VERSION).map((key) => caches.delete(key))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;
  if (url.pathname.startsWith('/api/')) return;

  if (request.mode === 'navigate') {
    event.respondWith(
      fetch(request)
        .then((response) => {
          const copy = response.clone();
          caches.open(VERSION).then((cache) => cache.put(request, copy));
          return response;
        })
        .catch(async () => {
          const cached = await caches.match(request);
          return cached || caches.match('./offline.html') || caches.match('./index.html');
        })
    );
    return;
  }

  const isAsset = /\.(css|js|svg|png|jpg|jpeg|webp|woff2?)$/i.test(url.pathname);
  if (isAsset) {
    event.respondWith(
      caches.match(request).then((cached) => {
        if (cached) return cached;
        return fetch(request).then((response) => {
          if (response.ok) {
            const copy = response.clone();
            caches.open(VERSION).then((cache) => cache.put(request, copy));
          }
          return response;
        });
      })
    );
  }
});

self.addEventListener('push', (event) => {
  let payload = {};
  try {
    payload = event.data ? event.data.json() : {};
  } catch {
    payload = { body: event.data ? event.data.text() : '' };
  }
  const title = payload.title || 'Campus Compass';
  const options = {
    body: payload.body || payload.message || 'You have a new campus update.',
    icon: '/icons/icon.svg',
    badge: '/icons/icon.svg',
    data: { url: payload.url || payload.link || '/notifications.html' },
    tag: payload.tag || undefined,
    renotify: Boolean(payload.tag)
  };
  event.waitUntil(self.registration.showNotification(title, options));
});

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const target = new URL(event.notification.data?.url || '/notifications.html', self.location.origin).href;
  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then((clients) => {
      const existing = clients.find((client) => client.url.startsWith(self.location.origin));
      if (existing) {
        existing.navigate(target);
        return existing.focus();
      }
      return self.clients.openWindow(target);
    })
  );
});
