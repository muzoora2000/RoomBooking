import express from 'express';
import { z } from 'zod';
import { query } from '../db/pool.js';
import { asyncHandler, AppError } from '../lib/errors.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import { publicVapidKey, pushConfigured } from '../services/push.js';

const router = express.Router();
router.use(authenticate);

router.get(
  '/',
  asyncHandler(async (req, res) => {
    const limit = Math.min(Math.max(Number(req.query.limit || 30), 1), 100);
    const params = [req.user.id];
    const conditions = ['user_id = $1'];
    if (req.query.unread === 'true') conditions.push('is_read = false');
    if (req.query.before) {
      params.push(req.query.before);
      conditions.push(`created_at < $${params.length}`);
    }
    params.push(limit);
    const result = await query(
      `SELECT id, booking_id, module_id, type, title, message, link, severity, is_read, created_at
       FROM notifications
       WHERE ${conditions.join(' AND ')}
       ORDER BY created_at DESC
       LIMIT $${params.length}`,
      params
    );
    res.json({
      notifications: result.rows,
      next_before: result.rows.length === limit ? result.rows[result.rows.length - 1].created_at : null
    });
  })
);

router.get(
  '/unread-count',
  asyncHandler(async (req, res) => {
    const result = await query(
      `SELECT count(*)::int AS count FROM notifications WHERE user_id = $1 AND is_read = false`,
      [req.user.id]
    );
    res.json({ unread: result.rows[0].count });
  })
);

router.post(
  '/:id/read',
  asyncHandler(async (req, res) => {
    const result = await query(
      `UPDATE notifications SET is_read = true WHERE id = $1 AND user_id = $2 RETURNING id`,
      [req.params.id, req.user.id]
    );
    if (!result.rowCount) throw new AppError(404, 'NOTIFICATION_NOT_FOUND', 'Notification not found.');
    res.json({ read: true });
  })
);

router.post(
  '/read-all',
  asyncHandler(async (req, res) => {
    const result = await query(
      `UPDATE notifications SET is_read = true WHERE user_id = $1 AND is_read = false`,
      [req.user.id]
    );
    res.json({ marked: result.rowCount });
  })
);

router.delete(
  '/all',
  asyncHandler(async (req, res) => {
    const result = await query(
      `DELETE FROM notifications WHERE user_id = $1`,
      [req.user.id]
    );
    res.json({ cleared: result.rowCount });
  })
);

router.get(
  '/push/key',
  asyncHandler(async (req, res) => {
    res.json({
      configured: pushConfigured(),
      public_key: publicVapidKey(),
      message: pushConfigured() ? null : 'Web push is not configured yet. In-app and email notifications still work.'
    });
  })
);

router.post(
  '/push/subscribe',
  validate(
    z.object({
      endpoint: z.string().url().max(2000),
      keys: z.object({
        p256dh: z.string().min(10).max(500),
        auth: z.string().min(5).max(500)
      })
    })
  ),
  asyncHandler(async (req, res) => {
    const result = await query(
      `INSERT INTO push_subscriptions (user_id, endpoint, p256dh, auth, user_agent)
       VALUES ($1,$2,$3,$4,$5)
       ON CONFLICT (endpoint) DO UPDATE
         SET user_id = EXCLUDED.user_id, p256dh = EXCLUDED.p256dh, auth = EXCLUDED.auth,
             user_agent = EXCLUDED.user_agent, revoked_at = NULL, last_used_at = now()
       RETURNING id`,
      [
        req.user.id,
        req.body.endpoint,
        req.body.keys.p256dh,
        req.body.keys.auth,
        req.headers['user-agent']?.slice(0, 500) || null
      ]
    );
    res.status(201).json({ subscribed: true, id: result.rows[0].id });
  })
);

router.delete(
  '/push/subscribe',
  validate(z.object({ endpoint: z.string().url().max(2000) })),
  asyncHandler(async (req, res) => {
    await query(
      `UPDATE push_subscriptions SET revoked_at = now()
       WHERE endpoint = $1 AND user_id = $2 AND revoked_at IS NULL`,
      [req.body.endpoint, req.user.id]
    );
    res.json({ unsubscribed: true });
  })
);

export default router;
