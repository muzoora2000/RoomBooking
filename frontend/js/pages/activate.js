import { api } from '../api.js';
import { saveSession } from '../auth.js';
import { errorMessage, queryParams, setButtonLoading } from '../ui.js';

const token = queryParams().get('token') || '';
const form = document.getElementById('activate-form');
const button = document.getElementById('activate-submit');
const errorBox = document.getElementById('activate-error');

if (!token) {
  form.classList.add('hidden');
  document.getElementById('activate-missing').classList.remove('hidden');
  document.getElementById('activate-intro').classList.add('hidden');
}

form.addEventListener('submit', async (event) => {
  event.preventDefault();
  errorBox.classList.add('hidden');
  const data = new FormData(form);
  const password = String(data.get('password') || '');
  const confirm = String(data.get('confirm') || '');
  const pin = String(data.get('pin') || '').trim();
  if (!/[A-Za-z]/.test(password) || !/\d/.test(password)) {
    errorBox.textContent = 'Password must include at least one letter and one number.';
    errorBox.classList.remove('hidden');
    return;
  }
  if (password !== confirm) {
    errorBox.textContent = 'The passwords do not match.';
    errorBox.classList.remove('hidden');
    return;
  }
  setButtonLoading(button, true, 'Activating...');
  try {
    const result = await api.post('/api/auth/activate', {
      token,
      password,
      pin: pin || undefined,
      consent: true
    }, { auth: false, retry: false });
    saveSession(result);
    location.replace('index.html?activated=1');
  } catch (error) {
    errorBox.textContent = errorMessage(error);
    errorBox.classList.remove('hidden');
  } finally {
    setButtonLoading(button, false);
  }
});
