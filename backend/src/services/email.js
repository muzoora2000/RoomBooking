import { config } from '../config.js';

function cleanResponse(text) {
  return String(text || '')
    .replace(/https?:\/\/\S+/gi, '[url]')
    .replace(/["\\]/g, '')
    .slice(0, 600);
}

function parseSender(value) {
  const match = String(value).match(/^(.*)<([^>]+)>$/);
  if (match) return { name: match[1].trim().replace(/^"|"$/g, ''), email: match[2].trim() };
  return { name: 'Campus Navigation', email: String(value).trim() };
}

export async function sendEmail({ to, subject, text, html }) {
  if (!config.emailApiKey) {
    return { sent: false, error: 'EMAIL_API_KEY is not configured. Set it in the API environment.', provider: config.emailProvider };
  }
  if (!to) return { sent: false, error: 'Recipient has no email address.' };
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), 20_000);
  try {
    let response;
    if (config.emailProvider === 'brevo') {
      const sender = parseSender(config.emailFrom);
      response = await fetch('https://api.brevo.com/v3/smtp/email', {
        method: 'POST',
        headers: {
          'api-key': config.emailApiKey,
          'content-type': 'application/json',
          accept: 'application/json'
        },
        body: JSON.stringify({
          sender,
          to: [{ email: to }],
          subject,
          htmlContent: html || `<p>${String(text || '').replace(/\n/g, '<br>')}</p>`,
          textContent: text
        }),
        signal: controller.signal
      });
    } else {
      response = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          authorization: `Bearer ${config.emailApiKey}`,
          'content-type': 'application/json'
        },
        body: JSON.stringify({
          from: config.emailFrom,
          to: [to],
          subject,
          text: text || undefined,
          html: html || undefined
        }),
        signal: controller.signal
      });
    }
    const raw = await response.text();
    if (!response.ok) {
      let message = `Email provider returned HTTP ${response.status}`;
      try {
        const parsed = JSON.parse(raw);
        message = parsed.message || parsed.error || message;
      } catch {
        if (raw) message = `${message}: ${cleanResponse(raw)}`;
      }
      return { sent: false, error: message.slice(0, 600), provider: config.emailProvider };
    }
    let providerId = null;
    try {
      const parsed = JSON.parse(raw);
      providerId = parsed.id || parsed.messageId || null;
    } catch {
      providerId = null;
    }
    return { sent: true, provider: config.emailProvider, providerId, response: cleanResponse(raw).slice(0, 200) };
  } catch (error) {
    return {
      sent: false,
      error: error.name === 'AbortError' ? 'Email provider timed out after 20 seconds.' : `Email provider request failed: ${error.message}`,
      provider: config.emailProvider
    };
  } finally {
    clearTimeout(timer);
  }
}
