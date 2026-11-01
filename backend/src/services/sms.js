import { config } from '../config.js';
import { normalizeUgandaPhone } from '../lib/crypto.js';

function cleanResponse(text) {
  return String(text || '')
    .replace(/https?:\/\/\S+/gi, '[url]')
    .replace(/["\\]/g, '')
    .slice(0, 600);
}

export async function sendSms({ to, message }) {
  if (!config.atApiKey || !config.atUsername) {
    return {
      sent: false,
      error: 'Africa\'s Talking SMS is not configured. Set AT_API_KEY and AT_USERNAME in the API environment.'
    };
  }
  const phone = normalizeUgandaPhone(to);
  if (!phone) {
    return { sent: false, error: 'Phone number must be a valid Ugandan number in +256 format.' };
  }
  const body = new URLSearchParams({
    username: config.atUsername,
    to: phone,
    message: String(message || '').slice(0, 480)
  });
  if (config.atSenderId) body.set('from', config.atSenderId);
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 20_000);
  try {
    const response = await fetch('https://api.africastalking.com/version1/messaging', {
      method: 'POST',
      headers: {
        apiKey: config.atApiKey,
        'content-type': 'application/x-www-form-urlencoded',
        accept: 'application/json'
      },
      body: body.toString(),
      signal: controller.signal
    });
    const raw = await response.text();
    if (!response.ok) {
      return { sent: false, error: `SMS provider returned HTTP ${response.status}: ${cleanResponse(raw)}` };
    }
    let parsed = null;
    try {
      parsed = JSON.parse(raw);
    } catch {
      parsed = null;
    }
    const recipient = parsed?.SMSMessageData?.Recipients?.[0];
    if (recipient && String(recipient.status).toLowerCase() !== 'success') {
      return { sent: false, error: `SMS rejected: ${cleanResponse(recipient.status || 'unknown status')}` };
    }
    return {
      sent: true,
      provider: 'africastalking',
      providerId: recipient?.messageId || null,
      response: cleanResponse(recipient?.status || raw).slice(0, 200)
    };
  } catch (error) {
    return {
      sent: false,
      error: error.name === 'AbortError' ? 'SMS provider timed out after 20 seconds.' : `SMS provider request failed: ${error.message}`
    };
  } finally {
    clearTimeout(timer);
  }
}
