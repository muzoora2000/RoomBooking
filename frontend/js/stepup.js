import { api } from './api.js';
import { errorMessage, openModal, setButtonLoading, toast } from './ui.js';

export async function requestStepUp() {
  const challenge = await api.post('/api/auth/step-up/request', {}, { retry: false });
  return new Promise((resolve, reject) => {
    const target = challenge.masked_email || challenge.masked_phone || 'your registered contact';
    const warning = challenge.delivery?.warning || challenge.warning || '';
    const modal = openModal({
      title: 'Confirm it is you',
      content: `
        <p class="muted">Scheduling and live changes need a recent identity check. A 6-digit code was sent to ${target}.</p>
        ${warning ? `<div class="notice warning">${warning}</div>` : ''}
        <form id="stepup-code-form" style="margin-top:.8rem">
          <div class="field">
            <label for="stepup-code">One-time code</label>
            <input id="stepup-code" name="code" inputmode="numeric" maxlength="6" pattern="[0-9]{6}" autocomplete="one-time-code" required>
          </div>
          <p class="error-text hidden" data-error></p>
          <button class="btn wide" type="submit">Verify</button>
        </form>
        ${challenge.pin_available ? `
          <form id="stepup-pin-form" style="margin-top:.8rem">
            <div class="field">
              <label for="stepup-pin">Or use your PIN</label>
              <input id="stepup-pin" name="pin" inputmode="numeric" maxlength="8" pattern="[0-9]{4,8}" autocomplete="off" required>
            </div>
            <button class="btn secondary wide" type="submit">Use PIN</button>
          </form>` : ''}`,
      footer: '<button type="button" class="btn ghost" data-cancel>Cancel</button>',
      onClose: () => reject(Object.assign(new Error('Verification cancelled.'), { cancelled: true }))
    });
    const errorBox = modal.body.querySelector('[data-error]');
    const finish = async (payload) => {
      try {
        await api.post('/api/auth/step-up/verify', payload, { retry: false });
        modal.root.remove();
        toast('Identity confirmed.', 'success');
        resolve(true);
      } catch (error) {
        errorBox.textContent = errorMessage(error);
        errorBox.classList.remove('hidden');
      }
    };
    const codeForm = modal.body.querySelector('#stepup-code-form');
    codeForm.addEventListener('submit', async (event) => {
      event.preventDefault();
      const button = codeForm.querySelector('button[type="submit"]');
      const code = String(new FormData(codeForm).get('code') || '').trim();
      if (!/^\d{6}$/.test(code)) {
        errorBox.textContent = 'Enter the 6-digit code.';
        errorBox.classList.remove('hidden');
        return;
      }
      setButtonLoading(button, true, 'Checking...');
      await finish({ otp_id: challenge.otp_id, code });
      setButtonLoading(button, false);
    });
    const pinForm = modal.body.querySelector('#stepup-pin-form');
    if (pinForm) {
      pinForm.addEventListener('submit', async (event) => {
        event.preventDefault();
        const button = pinForm.querySelector('button[type="submit"]');
        const pin = String(new FormData(pinForm).get('pin') || '').trim();
        if (!/^\d{4,8}$/.test(pin)) {
          errorBox.textContent = 'Enter your 4 to 8 digit PIN.';
          errorBox.classList.remove('hidden');
          return;
        }
        setButtonLoading(button, true, 'Checking...');
        await finish({ pin });
        setButtonLoading(button, false);
      });
    }
    modal.root.querySelector('[data-cancel]').addEventListener('click', () => {
      modal.close();
      reject(Object.assign(new Error('Verification cancelled.'), { cancelled: true }));
    });
  });
}

export async function withStepUp(fn) {
  try {
    return await fn();
  } catch (error) {
    if (error.status === 428 || error.code === 'STEP_UP_REQUIRED') {
      await requestStepUp();
      return fn();
    }
    throw error;
  }
}
