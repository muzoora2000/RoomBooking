import crypto from 'node:crypto';
import express from 'express';
import { query } from '../db/pool.js';
import { config } from '../config.js';
import { asyncHandler, forbidden } from '../lib/errors.js';
import { getSettings } from '../services/settings.js';
import { releaseNoShows } from '../services/checkin.js';
import { sendReminders } from '../services/notifications.js';
import { processNotificationQueue } from '../services/queue.js';

const router = express.Router();

function secretMatches(candidate) {
  if (!candidate || !config.cronSecret) return false;
  const left = Buffer.from(String(candidate));
  const right = Buffer.from(String(config.cronSecret));
  if (left.length !== right.length) return false;
  return crypto.timingSafeEqual(left, right);
}

router.use((req, res, next) => {
  const header = req.get('x-cron-secret');
  const authorization = req.get('authorization') || '';
  const bearer = authorization.toLowerCase().startsWith('bearer ') ? authorization.slice(7).trim() : '';
  if (!secretMatches(header || bearer)) {
    return next(forbidden('Invalid cron secret', 'CRON_UNAUTHORISED'));
  }
  return next();
});

router.post(
  '/reminders',
  asyncHandler(async (req, res) => {
    const result = await sendReminders();
    res.json({ ok: true, ...result });
  })
);

router.post(
  '/release-no-shows',
  asyncHandler(async (req, res) => {
    const result = await releaseNoShows();
    res.json({ ok: true, ...result });
  })
);

router.post(
  '/process-queue',
  asyncHandler(async (req, res) => {
    const limit = Math.min(Math.max(Number(req.body?.limit || req.query.limit || 50), 1), 200);
    const result = await processNotificationQueue(limit);
    res.json({ ok: true, result });
  })
);

router.post(
  '/housekeeping',
  asyncHandler(async (req, res) => {
    const settings = await getSettings([
      'otp_retention_days',
      'delivery_log_retention_days',
      'join_retention_days'
    ]);
    const results = {};
    const have = (value) => value !== null && value !== undefined && !Number.isNaN(Number(value));
    if (have(settings.otp_retention_days)) {
      const deleted = await query(
        `DELETE FROM otp_codes
         WHERE created_at < now() - make_interval(days => $1::int)
            OR (used_at IS NOT NULL AND used_at < now() - make_interval(days => $1::int))`,
        [Number(settings.otp_retention_days)]
      );
      results.otp_codes = deleted.rowCount;
    }
    if (have(settings.delivery_log_retention_days)) {
      const days = Number(settings.delivery_log_retention_days);
      const deliveries = await query(
        `DELETE FROM notification_deliveries
         WHERE created_at < now() - make_interval(days => $1::int)`,
        [days]
      );
      const queue = await query(
        `DELETE FROM notification_queue
         WHERE status IN ('sent','failed','skipped')
           AND created_at < now() - make_interval(days => $1::int)`,
        [days]
      );
      results.notification_deliveries = deliveries.rowCount;
      results.notification_queue = queue.rowCount;
    }
    if (have(settings.join_retention_days)) {
      const joins = await query(
        `DELETE FROM session_joins
         WHERE clicked_at < now() - make_interval(days => $1::int)`,
        [Number(settings.join_retention_days)]
      );
      results.session_joins = joins.rowCount;
    }
    const tokens = await query(
      `DELETE FROM user_activation_tokens WHERE expires_at < now() - interval '30 days'
       RETURNING id`
    );
    const resetTokens = await query(
      `DELETE FROM password_reset_tokens WHERE expires_at < now() - interval '30 days'
       RETURNING id`
    );
    results.activation_tokens = tokens.rowCount;
    results.password_reset_tokens = resetTokens.rowCount;
    res.json({ ok: true, deleted: results });
  })
);

router.get(
  '/status',
  asyncHandler(async (req, res) => {
    const counts = await query(
      `SELECT
         (SELECT count(*)::int FROM notification_queue WHERE status = 'pending') AS pending_notifications,
         (SELECT count(*)::int FROM notification_queue WHERE status = 'failed') AS failed_notifications,
         (SELECT count(*)::int FROM bookings WHERE status = 'confirmed' AND start_at > now()) AS upcoming_sessions,
         (SELECT count(*)::int FROM room_issues WHERE status = 'open') AS open_issues,
         (SELECT count(*)::int FROM bookings
            WHERE status = 'confirmed' AND checked_in_at IS NULL AND released_at IS NULL
              AND session_mode IN ('physical','hybrid')
              AND start_at < now() - interval '15 minutes') AS possible_stale_sessions`
    );
    res.json({ ok: true, counts: counts.rows[0], now: new Date().toISOString() });
  })
);

router.get(
  '/keep-warm',
  asyncHandler(async (req, res) => {
    const result = await query('SELECT now() AS now');
    res.json({ ok: true, now: result.rows[0].now });
  })
);

export default router;
