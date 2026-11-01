(function () {
  const meta = document.querySelector('meta[name="campus-api-base"]');
  const stored = localStorage.getItem('campus.apiBase') || '';
  const apiBase = String(window.CAMPUS_API_BASE || (meta && meta.content) || stored || '')
    .trim()
    .replace(/\/+$/, '');
  window.CAMPUS_CONFIG = {
    apiBase,
    appName: 'Campus Compass',
    university: 'University Campus',
    kampalaTimeZone: 'Africa/Kampala',
    version: '1.0.0'
  };
})();
