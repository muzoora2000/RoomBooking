import webpush from 'web-push';
import { config } from '../config.js';
import { query } from '../db/pool.js';

let configured = false;

function configure() {
  if (configured) return;
  if (config.vapidPublicKey && config.vapidPrivateKey) {
    webpush.setVapidDetails(config.vapidSubject, config.vapidPublicKey, config.vapidPrivateKey);
    configured = true;
  }
}

export function pushConfigured() {
  return Boolean(config.vapidPublicKey && config.vapidPrivateKey);
}

export function publicVapidKey() {
  return config.vapidPublicKey || null;
}

export async function sendPushToUser(userId, payload) {
  if (!pushConfigured()) {
    return { sent: false, error: 'Web push is not configured. Set VAPID_PUBLIC_KEY and VAPID_PRIVATE_KEY.' };
  }
  configure();
  const result = await query(
    `SELECT id, endpoint, p256dh, auth FROM push_subscriptions
     WHERE user_id = $1 AND revoked_at IS NULL`,
    [userId]
  );
  if (!result.rows.length) return { sent: false, error: 'User has no active push subscription.' };
  let sent = 0;
  let lastError = null;
  let providerIds = [];
  for (const subscription of result.rows) {
    try {
      const response = await webpush.sendNotification(
        {
          endpoint: subscription.endpoint,
          keys: { p256dh: subscription.p256dh, auth: subscription.auth }
        },
        JSON.stringify(payload),
        { TTL: 3600, urgency: payload.severity === 'critical' ? 'high' : 'normal' }
      );
      sent += 1;
      if (response?.statusCode) providerIds.push(String(response.statusCode));
      await query('UPDATE push_subscriptions SET last_used_at = now() WHERE id = $1', [subscription.id]);
    } catch (error) {
      lastError = error;
      if (error.statusCode === 404 || error.statusCode === 410) {
        await query('UPDATE push_subscriptions SET revoked_at = now() WHERE id = $1', [subscription.id]);
      }
    }
  }
  if (sent > 0) return { sent: true, provider: 'webpush', providerId: providerIds.join(',') || null };
  return {
    sent: false,
    error: lastError ? `Push failed: ${lastError.message}` : 'No push subscriptions could be reached.'
  };
}
