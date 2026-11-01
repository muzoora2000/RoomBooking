import { api } from '../api.js';
import { errorMessage, queryParams, setButtonLoading } from '../ui.js';

const token = queryParams().get('token') || '';
const forgotPanel = document.getElementById('forgot-panel');
const resetPanel = document.getElementById('reset-panel');

if (token) {
  forgotPanel.classList.add('hidden');
  resetPanel.classList.remove('hidden');
}

const forgotForm = document.getElementById('forgot-form');
const forgotButton = document.getElementById('forgot-submit');
const forgotError = document.getElementById('forgot-error');
const forgotSuccess = document.getElementById('forgot-success');

forgotForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  forgotError.classList.add('hidden');
  forgotSuccess.classList.add('hidden');
  setButtonLoading(forgotButton, true, 'Sending...');
  try {
    const result = await api.post('/api/auth/forgot-password', {
      email: String(new FormData(forgotForm).get('email') || '').trim()
    }, { auth: false, retry: false });
    forgotSuccess.textContent = result.message || 'If that email is registered, a reset link has been sent.';
    forgotSuccess.classList.remove('hidden');
  } catch (error) {
    forgotError.textContent = errorMessage(error);
    forgotError.classList.remove('hidden');
  } finally {
    setButtonLoading(forgotButton, false);
  }
});

const resetForm = document.getElementById('reset-form');
const resetButton = document.getElementById('reset-submit');
const resetError = document.getElementById('reset-error');
const resetSuccess = document.getElementById('reset-success');

resetForm.addEventListener('submit', async (event) => {
  event.preventDefault();
  resetError.classList.add('hidden');
  resetSuccess.classList.add('hidden');
  const data = new FormData(resetForm);
  const password = String(data.get('password') || '');
  const confirm = String(data.get('confirm') || '');
  if (!/[A-Za-z]/.test(password) || !/\d/.test(password)) {
    resetError.textContent = 'Password must include at least one letter and one number.';
    resetError.classList.remove('hidden');
    return;
  }
  if (password !== confirm) {
    resetError.textContent = 'The passwords do not match.';
    resetError.classList.remove('hidden');
    return;
  }
  setButtonLoading(resetButton, true, 'Updating...');
  try {
    const result = await api.post('/api/auth/reset-password', { token, password }, { auth: false, retry: false });
    resetSuccess.textContent = result.message || 'Password updated. You can now sign in.';
    resetSuccess.classList.remove('hidden');
    resetForm.classList.add('hidden');
    setTimeout(() => location.replace('login.html'), 1800);
  } catch (error) {
    resetError.textContent = errorMessage(error);
    resetError.classList.remove('hidden');
  } finally {
    setButtonLoading(resetButton, false);
  }
});
