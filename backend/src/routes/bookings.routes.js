import express from 'express';
import { z } from 'zod';
import { query } from '../db/pool.js';
import { asyncHandler, AppError } from '../lib/errors.js';
import { addMinutes, formatKampala, kampalaDate, kampalaDayBounds, roundUpToMinutes } from '../lib/time.js';
import { validate } from '../middleware/validate.js';
import { authenticate, requireRecentVerification } from '../middleware/auth.js';
import { bookingLimiter } from '../middleware/rateLimit.js';
import {
  bookingToApi,
  cancelBooking,
  convertToOnline,
  createBooking,
  createRecurringBookings,
  getBookingDetail,
  listBookingsForUser,
  updateBooking,
  updateOnlineLink
} from '../services/booking.js';
import { checkInBooking, checkinWindowConfig } from '../services/checkin.js';
import { verifyRoomSignature } from '../services/qr.js';
import { capacityPreview } from '../services/studyMode.js';
import { getSettings } from '../services/settings.js';

const router = express.Router();
router.use(authenticate);

const uuid = z.string().uuid();
const bookingFields = z.object({
  facility_id: uuid.nullable().optional(),
  module_id: uuid.nullable().optional(),
  class_id: uuid.nullable().optional(),
  semester_id: uuid.nullable().optional(),
  session_mode: z.enum(['physical', 'online', 'hybrid']).optional(),
  online_platform: z.enum(['zoom', 'google_meet', 'teams', 'other']).nullable().optional(),
  online_link: z.string().max(2000).nullable().optional(),
  meeting_passcode: z.string().max(200).nullable().optional(),
  start_at: z.string().max(60).optional(),
  end_at: z.string().max(60).optional(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  start_time: z.string().regex(/^\d{2}:\d{2}$/).optional(),
  end_time: z.string().regex(/^\d{2}:\d{2}$/).optional(),
  purpose: z.string().max(1000).nullable().optional(),
  lecturer_id: uuid.nullable().optional(),
  reason: z.string().max(1000).optional()
});

const bookingSchema = bookingFields
  .refine((value) => (value.start_at && value.end_at) || (value.date && value.start_time && value.end_time), {
    message: 'Provide start and end times, or a date with start and end times'
  })
  .refine((value) => value.module_id || String(value.purpose || '').trim(), {
    message: 'Describe what you need the room for'
  });

const cancelSchema = z.object({
  reason: z.string().max(1000).optional(),
  scope: z.enum(['single', 'future', 'all']).optional().default('single')
});

const updateSchema = bookingFields.partial().passthrough();

const convertSchema = z.object({
  online_platform: z.enum(['zoom', 'google_meet', 'teams', 'other']),
  online_link: z.string().min(10).max(2000),
  meeting_passcode: z.string().max(200).nullable().optional(),
  reason: z.string().max(1000).optional()
});

const linkSchema = z.object({
  online_platform: z.enum(['zoom', 'google_meet', 'teams', 'other']).optional(),
  online_link: z.string().min(10).max(2000),
  meeting_passcode: z.string().max(200).nullable().optional()
});

const checkinSchema = z.object({
  method: z.enum(['rotating', 'static_geo']).optional(),
  door_token: z.string().max(2000).optional(),
  latitude: z.number().min(-90).max(90).optional(),
  longitude: z.number().min(-180).max(180).optional(),
  accuracy: z.number().min(0).max(100000).optional()
});

function checkinMethod(body) {
  if (body.method === 'rotating' || (!body.method && body.door_token)) {
    if (!body.door_token) throw new AppError(400, 'DOOR_TOKEN_REQUIRED', 'Scan the QR at the room door to get a check-in code.');
    return 'rotating';
  }
  if (body.method === 'static_geo' || (!body.method && body.latitude !== undefined)) {
    if (body.latitude === undefined || body.longitude === undefined) {
      throw new AppError(400, 'LOCATION_REQUIRED', 'Share your current location to check in.');
    }
    return 'static_geo';
  }
  throw new AppError(400, 'CHECKIN_PROOF_REQUIRED', 'Provide a room door code or your current location.');
}

router.post(
  '/',
  bookingLimiter,
  requireRecentVerification,
  validate(bookingSchema),
  asyncHandler(async (req, res) => {
    const result = await createBooking({ user: req.user, input: req.body, req });
    res.status(201).json(result);
  })
);

router.post(
  '/recurring',
  bookingLimiter,
  requireRecentVerification,
  validate(
    bookingSchema.and(
      z.object({
        recurrence: z.object({
          frequency: z.literal('weekly').default('weekly'),
          count: z.number().int().min(2).max(52).optional(),
          until: z.string().optional()
        })
      }).refine((value) => value.recurrence.count || value.recurrence.until, {
        message: 'Provide a repeat count or an end date'
      })
    )
  ),
  asyncHandler(async (req, res) => {
    const result = await createRecurringBookings({ user: req.user, input: req.body, req });
    res.status(201).json(result);
  })
);

router.post(
  '/walk-up',
  bookingLimiter,
  validate(
    z.object({
      facility_id: uuid,
      v: z.union([z.string(), z.number()]),
      s: z.string().min(8).max(200),
      module_id: uuid.nullable().optional(),
      purpose: z.string().max(1000).optional(),
      duration_minutes: z.number().int().min(15).max(240).optional(),
      online_platform: z.enum(['zoom', 'google_meet', 'teams', 'other']).optional(),
      online_link: z.string().max(2000).optional()
    })
  ),
  asyncHandler(async (req, res) => {
    const facilityResult = await query('SELECT * FROM facilities WHERE id = $1', [req.body.facility_id]);
    const facility = facilityResult.rows[0];
    if (!facility) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
    if (!verifyRoomSignature(facility, req.body.v, req.body.s)) {
      throw new AppError(403, 'INVALID_ROOM_QR', 'This room QR is invalid or has been replaced. Scan the QR on the door again.');
    }
    const start = roundUpToMinutes(new Date(), 5);
    const duration = req.body.duration_minutes || 60;
    const input = {
      facility_id: facility.id,
      module_id: req.body.module_id || null,
      session_mode: req.body.online_link ? 'hybrid' : 'physical',
      online_platform: req.body.online_platform || null,
      online_link: req.body.online_link || null,
      purpose: req.body.purpose || 'Walk-up room use',
      start_at: start.toISOString(),
      end_at: addMinutes(start, duration).toISOString(),
      entry_point: 'room_qr'
    };
    const result = await createBooking({ user: req.user, input, req });
    res.status(201).json(result);
  })
);

router.get(
  '/',
  asyncHandler(async (req, res) => {
    const bookings = await listBookingsForUser({
      user: req.user,
      from: req.query.from || null,
      to: req.query.to || null,
      status: req.query.status || null
    });
    const checkinWindow = await checkinWindowConfig();
    res.json({ bookings, count: bookings.length, checkin_window: checkinWindow });
  })
);

router.get(
  '/availability',
  asyncHandler(async (req, res) => {
    const facilityId = req.query.facility_id;
    if (!facilityId) throw new AppError(400, 'FACILITY_REQUIRED', 'Choose a room.');
    const facilityResult = await query('SELECT * FROM facilities WHERE id = $1', [facilityId]);
    const facility = facilityResult.rows[0];
    if (!facility) throw new AppError(404, 'FACILITY_NOT_FOUND', 'Room not found.');
    const day = req.query.date || kampalaDate();
    const bounds = kampalaDayBounds(day);
    const settings = await getSettings(['min_notice_minutes', 'max_advance_booking_days', 'max_booking_duration_minutes']);
    const bookings = await query(
      `SELECT start_at, end_at, status, source, purpose, module_id FROM bookings
       WHERE facility_id = $1 AND status IN ('pending','confirmed')
         AND start_at < $3 AND end_at > $2
       ORDER BY start_at`,
      [facility.id, bounds.start, bounds.end]
    );
    const blocks = await query(
      `SELECT start_at, end_at, reason FROM facility_blocks
       WHERE facility_id = $1 AND start_at < $3 AND end_at > $2`,
      [facility.id, bounds.start, bounds.end]
    );
    const exams = await query(
      `SELECT eb.name, eb.start_at, eb.end_at FROM exam_blocks eb
       JOIN exam_block_facilities ebf ON ebf.exam_block_id = eb.id
       WHERE ebf.facility_id = $1 AND eb.start_at < $3 AND eb.end_at > $2`,
      [facility.id, bounds.start, bounds.end]
    );
    const busy = [
      ...bookings.rows.map((row) => ({ ...row, type: 'booking' })),
      ...blocks.rows.map((row) => ({ ...row, type: 'maintenance' })),
      ...exams.rows.map((row) => ({ ...row, type: 'exam' }))
    ].sort((a, b) => new Date(a.start_at) - new Date(b.start_at));
    const now = new Date();
    const earliest = new Date(now.getTime() + Number(settings.min_notice_minutes || 15) * 60_000);
    const latest = new Date(now.getTime() + Number(settings.max_advance_booking_days || 30) * 24 * 60 * 60 * 1000);
    const free = [];
    let cursor = new Date(Math.max(new Date(bounds.start).getTime(), earliest.getTime()));
    for (const item of busy) {
      const start = new Date(item.start_at);
      const end = new Date(item.end_at);
      if (start >= new Date(bounds.end)) break;
      if (start > cursor) free.push({ start_at: new Date(cursor), end_at: start });
      if (end > cursor) cursor = end;
    }
    if (cursor < new Date(bounds.end)) free.push({ start_at: cursor, end_at: new Date(bounds.end) });
    const slots = [];
    for (const gap of free) {
      let slotStart = new Date(gap.start);
      while (slotStart < gap.end && slots.length < 200) {
        const slotEnd = addMinutes(slotStart, 30);
        if (slotEnd > gap.end || slotStart > latest) break;
        slots.push({
          start_at: new Date(slotStart),
          end_at: slotEnd,
          start_local: formatKampala(slotStart, 'HH:mm'),
          end_local: formatKampala(slotEnd, 'HH:mm')
        });
        slotStart = slotEnd;
      }
    }
    let capacity = null;
    if (req.query.module_id) {
      try {
        capacity = await capacityPreview(req.query.module_id, req.query.semester_id || null);
      } catch (error) {
        capacity = { error: error.message };
      }
    }
    res.json({
      facility: {
        id: facility.id,
        name: facility.name,
        category: facility.category,
        capacity: facility.capacity,
        status: facility.status,
        requires_approval: facility.requires_approval
      },
      day,
      day_start: bounds.start,
      day_end: bounds.end,
      busy,
      free_slots: slots,
      capacity,
      limits: {
        min_notice_minutes: settings.min_notice_minutes,
        max_advance_booking_days: settings.max_advance_booking_days,
        max_booking_duration_minutes: settings.max_booking_duration_minutes
      }
    });
  })
);

router.get(
  '/:id',
  asyncHandler(async (req, res) => {
    const [booking, checkinWindow] = await Promise.all([
      getBookingDetail({ bookingId: req.params.id, user: req.user }),
      checkinWindowConfig()
    ]);
    res.json({ booking, checkin_window: checkinWindow });
  })
);

router.patch(
  '/:id',
  bookingLimiter,
  requireRecentVerification,
  validate(updateSchema),
  asyncHandler(async (req, res) => {
    const booking = await updateBooking({
      bookingId: req.params.id,
      user: req.user,
      input: req.body,
      req
    });
    res.json({ booking });
  })
);

router.delete(
  '/:id',
  requireRecentVerification,
  validate(cancelSchema),
  asyncHandler(async (req, res) => {
    const result = await cancelBooking({
      bookingId: req.params.id,
      user: req.user,
      reason: req.body.reason,
      scope: req.body.scope,
      req
    });
    res.json(result);
  })
);

router.post(
  '/:id/cancel',
  requireRecentVerification,
  validate(cancelSchema),
  asyncHandler(async (req, res) => {
    const result = await cancelBooking({
      bookingId: req.params.id,
      user: req.user,
      reason: req.body.reason,
      scope: req.body.scope,
      req
    });
    res.json(result);
  })
);

router.post(
  '/:id/convert-online',
  requireRecentVerification,
  validate(convertSchema),
  asyncHandler(async (req, res) => {
    const booking = await convertToOnline({
      bookingId: req.params.id,
      user: req.user,
      onlinePlatform: req.body.online_platform,
      onlineLink: req.body.online_link,
      meetingPasscode: req.body.meeting_passcode,
      reason: req.body.reason,
      req
    });
    res.json({ booking });
  })
);

router.put(
  '/:id/link',
  requireRecentVerification,
  validate(linkSchema),
  asyncHandler(async (req, res) => {
    const booking = await updateOnlineLink({
      bookingId: req.params.id,
      user: req.user,
      onlinePlatform: req.body.online_platform,
      onlineLink: req.body.online_link,
      meetingPasscode: req.body.meeting_passcode,
      req
    });
    res.json({ booking });
  })
);

router.post(
  '/:id/checkin',
  validate(checkinSchema),
  asyncHandler(async (req, res) => {
    const method = checkinMethod(req.body);
    const outcome = await checkInBooking({
      bookingId: req.params.id,
      user: req.user,
      method,
      proof: req.body,
      req,
      allowOutsideWindow: false
    });
    res.json({
      checked_in: true,
      already_checked_in: outcome.already,
      checkin_method: outcome.booking.checkin_method || method,
      checked_in_at: outcome.booking.checked_in_at,
      distance_m: outcome.distance === null || outcome.distance === undefined ? null : Math.round(outcome.distance),
      booking: bookingToApi(outcome.booking, req.user)
    });
  })
);

export default router;
