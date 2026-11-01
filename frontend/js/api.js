const CONFIG = window.CAMPUS_CONFIG || { apiBase: '' };
const TOKEN_KEY = 'campus.token';
const COLD_START_LIMIT_MS = 90000;

export class ApiError extends Error {
  constructor(message, options = {}) {
    super(message);
    this.name = 'ApiError';
    this.status = options.status || 0;
    this.code = options.code || 'REQUEST_FAILED';
    this.details = options.details ?? null;
  }
}

export function getToken() {
  return localStorage.getItem(TOKEN_KEY) || '';
}

export function setToken(token) {
  if (token) localStorage.setItem(TOKEN_KEY, token);
  else localStorage.removeItem(TOKEN_KEY);
}

export function clearSession() {
  localStorage.removeItem(TOKEN_KEY);
  localStorage.removeItem('campus.user');
}

export function buildUrl(path) {
  if (/^https?:\/\//i.test(path)) return path;
  return `${CONFIG.apiBase}${path.startsWith('/') ? path : `/${path}`}`;
}

export function queryString(params = {}) {
  const search = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) {
    if (value === undefined || value === null || value === '') continue;
    if (Array.isArray(value)) value.forEach((item) => search.append(key, item));
    else search.set(key, String(value));
  }
  const text = search.toString();
  return text ? `?${text}` : '';
}

function parseError(payload, status) {
  if (payload && typeof payload === 'object') {
    const message =
      (typeof payload.error === 'string' ? payload.error : payload.error?.message) ||
      (typeof payload.message === 'string' ? payload.message : null) ||
      `Request failed (${status})`;
    const code =
      (typeof payload.error === 'object' && payload.error?.code) ||
      payload.code ||
      'REQUEST_FAILED';
    const details =
      (typeof payload.error === 'object' && payload.error?.details) ??
      payload.details ??
      null;
    return { message, code, details };
  }
  return { message: `Request failed (${status})`, code: 'REQUEST_FAILED', details: null };
}

async function parseResponse(response) {
  const text = await response.text();
  if (!text) return null;
  try {
    return JSON.parse(text);
  } catch {
    return { message: text.slice(0, 500) };
  }
}

function shouldRetry(method, status) {
  if (!['GET', 'HEAD'].includes(method)) return false;
  return status === 0 || status === 502 || status === 503 || status === 504;
}

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function sendAttempt(path, options, attemptNumber) {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), options.timeoutMs || 20000);
  const headers = new Headers(options.headers || {});
  const token = options.auth === false ? '' : getToken();
  if (token) headers.set('Authorization', `Bearer ${token}`);
  if (options.body !== undefined && !(options.body instanceof FormData) && !headers.has('Content-Type')) {
    headers.set('Content-Type', 'application/json');
  }
  if (!headers.has('Accept')) headers.set('Accept', 'application/json');
  const init = {
    method: options.method || 'GET',
    headers,
    signal: controller.signal,
    cache: 'no-store',
    credentials: 'omit'
  };
  if (options.body !== undefined) {
    init.body = options.body instanceof FormData ? options.body : JSON.stringify(options.body);
  }
  const started = Date.now();
  try {
    const response = await fetch(buildUrl(path), init);
    clearTimeout(timeout);
    if (options.raw) {
      if (response.ok) return response;
      const rawPayload = await parseResponse(response);
      const rawParsed = parseError(rawPayload, response.status);
      throw new ApiError(rawParsed.message, {
        status: response.status,
        code: rawParsed.code,
        details: rawParsed.details
      });
    }
    const payload = await parseResponse(response);
    if (!response.ok) {
      const parsed = parseError(payload, response.status);
      const error = new ApiError(parsed.message, {
        status: response.status,
        code: parsed.code,
        details: parsed.details
      });
      if (response.status === 401 && options.auth !== false && !options.skipAuthRedirect) {
        clearSession();
        if (!location.pathname.endsWith('/login.html')) {
          const next = encodeURIComponent(location.pathname.split('/').pop() + location.search);
          location.replace(`login.html?next=${next}`);
        }
      }
      throw error;
    }
    return payload;
  } catch (error) {
    clearTimeout(timeout);
    const elapsed = Date.now() - started;
    if (error.name === 'AbortError') {
      throw new ApiError('The server took too long to respond. Check your connection and try again.', {
        status: 0,
        code: 'TIMEOUT',
        details: { elapsed, attempt: attemptNumber }
      });
    }
    if (error instanceof ApiError) throw error;
    throw new ApiError('Could not reach the campus server. Check your internet connection.', {
      status: 0,
      code: 'NETWORK_ERROR',
      details: { cause: error.message, elapsed, attempt: attemptNumber }
    });
  }
}

export async function request(path, options = {}) {
  const method = String(options.method || 'GET').toUpperCase();
  const started = Date.now();
  let lastError;
  for (let attemptNumber = 1; attemptNumber <= 20; attemptNumber += 1) {
    try {
      return await sendAttempt(path, { ...options, method }, attemptNumber);
    } catch (error) {
      lastError = error;
      const canRetry = options.retry !== false && shouldRetry(method, error.status);
      if (!canRetry || Date.now() - started >= COLD_START_LIMIT_MS) break;
      window.dispatchEvent(new CustomEvent('campus:retrying', {
        detail: { attempt: attemptNumber, message: 'The campus server is waking up. Retrying automatically...' }
      }));
      await delay(Math.min(3000 + attemptNumber * 1000, 8000));
    }
  }
  throw lastError;
}

export const api = {
  get(path, options = {}) {
    return request(path, { ...options, method: 'GET' });
  },
  post(path, body, options = {}) {
    return request(path, { ...options, method: 'POST', body });
  },
  patch(path, body, options = {}) {
    return request(path, { ...options, method: 'PATCH', body });
  },
  put(path, body, options = {}) {
    return request(path, { ...options, method: 'PUT', body });
  },
  delete(path, body, options = {}) {
    return request(path, { ...options, method: 'DELETE', body });
  },
  async text(path, options = {}) {
    const response = await request(path, { ...options, raw: true });
    return response.text();
  },
  async download(path, fallbackName, options = {}) {
    const response = await request(path, { ...options, raw: true });
    const blob = await response.blob();
    const disposition = response.headers.get('content-disposition') || '';
    const match = disposition.match(/filename="?([^";]+)"?/i);
    const name = match ? match[1] : fallbackName;
    const link = document.createElement('a');
    const url = URL.createObjectURL(blob);
    link.href = url;
    link.download = name;
    document.body.appendChild(link);
    link.click();
    link.remove();
    setTimeout(() => URL.revokeObjectURL(url), 30000);
  }
};

export function newDeviceId() {
  const key = 'campus.deviceId';
  let value = localStorage.getItem(key);
  if (!value) {
    value = crypto.randomUUID ? crypto.randomUUID() : `${Date.now()}-${Math.random().toString(16).slice(2)}`;
    localStorage.setItem(key, value);
  }
  return value;
}
