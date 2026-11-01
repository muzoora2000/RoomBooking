import express from 'express';
import { asyncHandler } from '../lib/errors.js';
import { authenticate } from '../middleware/auth.js';
import { getLectureDetail, joinLecture, listLectureRoster, listMyLectures } from '../services/lectures.js';
import { auditLog } from '../lib/audit.js';

const router = express.Router();
router.use(authenticate);

router.get(
  '/',
  asyncHandler(async (req, res) => {
    const result = await listMyLectures({
      user: req.user,
      from: req.query.from || null,
      to: req.query.to || null
    });
    res.json(result);
  })
);

router.get(
  '/:id',
  asyncHandler(async (req, res) => {
    res.json({ lecture: await getLectureDetail({ bookingId: req.params.id, user: req.user }) });
  })
);

router.post(
  '/:id/join',
  asyncHandler(async (req, res) => {
    const result = await joinLecture({ bookingId: req.params.id, user: req.user, req });
    res.json(result);
  })
);

router.get(
  '/:id/roster',
  asyncHandler(async (req, res) => {
    const result = await listLectureRoster({ bookingId: req.params.id, user: req.user });
    await auditLog({
      req,
      action: 'session.roster_viewed',
      entityType: 'booking',
      entityId: req.params.id
    });
    res.json(result);
  })
);

export default router;
