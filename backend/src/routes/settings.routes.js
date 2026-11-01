import express from 'express';
import { asyncHandler } from '../lib/errors.js';
import { getPublicSettings } from '../services/settings.js';

const router = express.Router();

router.get(
  '/public',
  asyncHandler(async (req, res) => {
    res.json({ settings: await getPublicSettings() });
  })
);

export default router;
