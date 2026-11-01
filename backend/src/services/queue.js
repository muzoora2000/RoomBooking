import { config } from '../config.js';
import { query } from '../db/pool.js';
import { formatKampala } from '../lib/time.js';
import { sendEmail } from './email.js';
import { sendSms } from './sms.js';
import { sendPushToUser, pushConfigured } from './push.js';

let running = false;
let scheduled = false;

function absoluteLink(link) {
  if (!link) return config.primaryFrontendUrl;
  if (/^https?:\/\//i.test(link)) return link;
  return `${config.primaryFrontendUrl}${link.startsWith('/') ? '' : '/'}${link}`;
}

function escapeHtml(value) {
  return String(value || '')
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;');
}

function buildEmail(notification) {
  const link = absoluteLink(notification.link);
  const text = `${notification.message}\n\nOpen the app: ${link}\n\nThis message was sent by Campus Navigation. You receive it because of your role or enrolment.`;
  const html = `<div style="font-family:system-ui,Segoe UI,Roboto,sans-serif;line-height:1.5;color:#12212f">
    <h2 style="font-size:18px;margin:0 0 10px">${escapeHtml(notification.title)}</h2>
    <p style="margin:0 0 14px">${escapeHtml(notification.message).replace(/\n/g, '<br>')}</p>
    <p style="margin:0 0 14px"><a href="${escapeHtml(link)}" style="background:#124e78;color:#fff;padding:10px 16px;border-radius:8px;text-decoration:none">Open Campus Navigation</a></p>
    <p style="font-size:12px;color:#52667a;margin:0">You receive this because of your role or enrolment. Online meeting links are only available after sign-in.</p>
  </div>`;
  return { subject: notification.title, text, html };
}

function buildSms(notification, booking, user) {
  const parts = [notification.message];
  if (booking?.online_link) {
    if (user.sms_link_opt_in) {
      parts.push(`Join: ${booking.online_link}`);
    } else {
      parts.push('Open the app to join.');
    }
  } else if (notification.link && user.sms_link_opt_in) {
    parts.push(absoluteLink(notification.link));
  }
  const text = parts.join(' ').replace(/\s+/g, ' ').trim();
  return text.length > 480 ? `${text.slice(0, 477)}...` : text;
}

async function recordDelivery({ notification, channel, status, providerResponse = null, error = null, attempts = 1 }) {
  await query(
    `INSERT INTO notification_deliveries (notification_id, user_id, channel, status, provider_response, error, attempts)
     VALUES ($1,$2,$3,$4,$5,$6,$7)`,
    [
      notification.id,
      notification.user_id,
      channel,
      status,
      providerResponse ? String(providerResponse).replace(/https?:\/\/\S+/gi, '[url]').slice(0, 500) : null,
      error ? String(error).replace(/https?:\/\/\S+/gi, '[url]').slice(0, 800) : null,
      attempts
    ]
  );
}

async function warnAdmins(channel, message) {
  const title = `Notification delivery problem: ${channel}`;
  const recent = await query(
    `SELECT 1 FROM notifications WHERE type = 'system_alert' AND title = $1 AND created_at > now() - interval '1 hour' LIMIT 1`,
    [title]
  );
  if (recent.rows.length) return;
  const admins = await query(`SELECT id FROM users WHERE role = 'super_admin' AND is_active = true`);
  for (const admin of admins.rows) {
    const inserted = await query(
      `INSERT INTO notifications (user_id, type, title, message, severity)
       VALUES ($1,'system_alert',$2,$3,'warning') RETURNING id`,
      [admin.id, title, message]
    );
    await recordDelivery({
      notification: { id: inserted.rows[0].id, user_id: admin.id },
      channel: 'inapp',
      status: 'sent',
      providerResponse: 'in-app admin warning'
    });
  }
}

async function handleQueueRow(row) {
  const result = await query(
    `SELECT n.*, u.email, u.phone, u.name AS user_name, u.sms_link_opt_in,
            b.online_link, b.start_at, b.session_mode
     FROM notifications n
     JOIN users u ON u.id = n.user_id
     LEFT JOIN bookings b ON b.id = n.booking_id
     WHERE n.id = $1`,
    [row.notification_id]
  );
  if (!result.rows.length) {
    await query(`UPDATE notification_queue SET status='skipped', processed_at=now(), last_error='Notification no longer exists' WHERE id=$1`, [row.id]);
    return { status: 'skipped' };
  }
  const notification = result.rows[0];
  let outcome;
  if (row.channel === 'email') {
    if (!notification.email) {
      outcome = { status: 'skipped', error: 'Recipient has no email address' };
    } else {
      const payload = buildEmail(notification);
      outcome = await sendEmail({ to: notification.email, ...payload });
      outcome = outcome.sent
        ? { status: 'sent', providerResponse: `${outcome.provider}${outcome.providerId ? `:${outcome.providerId}` : ''}` }
        : { status: 'failed', error: outcome.error };
    }
  } else if (row.channel === 'sms') {
    if (!notification.phone) {
      outcome = { status: 'skipped', error: 'Recipient has no phone number' };
    } else {
      const message = buildSms(notification, notification, notification);
      outcome = await sendSms({ to: notification.phone, message });
      outcome = outcome.sent
        ? { status: 'sent', providerResponse: `${outcome.provider}${outcome.providerId ? `:${outcome.providerId}` : ''}` }
        : { status: 'failed', error: outcome.error };
    }
  } else if (row.channel === 'push') {
    if (!pushConfigured()) {
      outcome = { status: 'failed', error: 'VAPID keys are not configured' };
    } else {
      const push = await sendPushToUser(notification.user_id, {
        title: notification.title,
        body: notification.message,
        link: absoluteLink(notification.link),
        notificationId: notification.id,
        severity: notification.severity,
        tag: `notification-${notification.id}`
      });
      outcome = push.sent
        ? { status: 'sent', providerResponse: 'webpush' }
        : {
            status: /no active push subscription/i.test(push.error || '') ? 'skipped' : 'failed',
            error: push.error
          };
    }
  } else {
    outcome = { status: 'skipped', error: `Unsupported channel ${row.channel}` };
  }

  await recordDelivery({
    notification,
    channel: row.channel,
    status: outcome.status,
    providerResponse: outcome.providerResponse || null,
    error: outcome.error || null,
    attempts: row.attempts + 1
  });

  const attempts = row.attempts + 1;
  if (outcome.status === 'failed' && attempts < 5) {
    const delayMinutes = Math.min(60, 2 ** attempts);
    await query(
      `UPDATE notification_queue
       SET status='pending', attempts=$2, next_attempt_at=now() + ($3 || ' minutes')::interval, last_error=$4, processed_at=now()
       WHERE id=$1`,
      [row.id, attempts, String(delayMinutes), String(outcome.error || '').slice(0, 800)]
    );
  } else {
    await query(
      `UPDATE notification_queue SET status=$2, attempts=$3, last_error=$4, processed_at=now() WHERE id=$1`,
      [row.id, outcome.status, attempts, outcome.error ? String(outcome.error).slice(0, 800) : null]
    );
  }
  if (outcome.status === 'failed') {
    await warnAdmins(
      row.channel,
      `${row.channel.toUpperCase()} delivery failed: ${String(outcome.error || 'unknown error').slice(0, 300)}. Check provider environment variables on Render.`
    );
  }
  return outcome;
}

export async function processNotificationQueue(limit = 50) {
  const picked = await query(
    `UPDATE notification_queue
     SET status = 'processing'
     WHERE id IN (
       SELECT id FROM notification_queue
       WHERE status = 'pending' AND next_attempt_at <= now()
       ORDER BY created_at
       LIMIT $1
       FOR UPDATE SKIP LOCKED
     )
     RETURNING *`,
    [limit]
  );
  let sent = 0;
  let failed = 0;
  let skipped = 0;
  for (const row of picked.rows) {
    try {
      const outcome = await handleQueueRow(row);
      if (outcome.status === 'sent') sent += 1;
      else if (outcome.status === 'failed') failed += 1;
      else skipped += 1;
    } catch (error) {
      failed += 1;
      await query(
        `UPDATE notification_queue SET status='failed', attempts=attempts+1, last_error=$2, processed_at=now() WHERE id=$1`,
        [row.id, error.message.slice(0, 800)]
      ).catch(() => {});
      await warnAdmins(row.channel, `Queue worker error: ${error.message}`).catch(() => {});
    }
  }
  const pending = await query(`SELECT count(*)::int AS count FROM notification_queue WHERE status='pending' AND next_attempt_at <= now()`);
  return { picked: picked.rowCount, sent, failed, skipped, pending: pending.rows[0].count };
}

export function kickQueue() {
  if (scheduled) return;
  scheduled = true;
  setTimeout(async () => {
    scheduled = false;
    if (running) return;
    running = true;
    try {
      let rounds = 0;
      while (rounds < 10) {
        const result = await processNotificationQueue(50);
        rounds += 1;
        if (result.picked === 0 || result.pending === 0) break;
      }
    } catch (error) {
      console.error('[queue] worker failed', error.message);
    } finally {
      running = false;
      const pending = await query(
        `SELECT 1 FROM notification_queue WHERE status='pending' AND next_attempt_at <= now() LIMIT 1`
      ).catch(() => ({ rows: [] }));
      if (pending.rows.length) kickQueue();
    }
  }, 10);
}

export async function retryDelivery(deliveryId) {
  const delivery = await query(
    `SELECT id, notification_id, channel FROM notification_deliveries WHERE id = $1`,
    [deliveryId]
  );
  if (!delivery.rows.length) return null;
  const row = delivery.rows[0];
  const existing = await query(
    `SELECT id FROM notification_queue
     WHERE notification_id = $1 AND channel = $2
     ORDER BY created_at DESC LIMIT 1`,
    [row.notification_id, row.channel]
  );
  if (existing.rows.length) {
    await query(
      `UPDATE notification_queue SET status='pending', attempts=0, next_attempt_at=now(), last_error=NULL WHERE id=$1`,
      [existing.rows[0].id]
    );
  } else {
    const notif = await query(`SELECT user_id FROM notifications WHERE id = $1`, [row.notification_id]);
    if (!notif.rows.length) return null;
    await query(
      `INSERT INTO notification_queue (notification_id, user_id, channel, status, payload)
       VALUES ($1,$2,$3,'pending','{}'::jsonb)`,
      [row.notification_id, notif.rows[0].user_id, row.channel]
    );
  }
  kickQueue();
  return row;
}
