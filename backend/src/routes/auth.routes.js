import express from 'express';
import { z } from 'zod';
import { asyncHandler } from '../lib/errors.js';
import { validate } from '../middleware/validate.js';
import { authenticate } from '../middleware/auth.js';
import { authLimiter, otpLimiter } from '../middleware/rateLimit.js';
import {
  activateAccount,
  forgotPassword,
  loginWithPassword,
  loginWithRotatingQr,
  logout,
  qrLookup,
  reportMisuse,
  requestStepUp,
  resetPassword,
  verifyLoginOtp,
  verifyLoginPin,
  verifyStepUp
} from '../services/auth.js';

const router = express.Router();

const deviceId = z.string().min(8).max(200);
const optionalPin = z.string().min(4).max(12).optional();

const qrSchema = z.object({
  token: z.string().min(16).max(500),
  device_id: deviceId
});

const passwordSchema = z.object({
  id_number: z.string().min(2).max(50),
  password: z.string().min(1).max(200),
  device_id: deviceId,
  trust_device: z.boolean().optional().default(false)
});

const otpSchema = z.object({
  otp_id: z.string().uuid(),
  code: z.string().regex(/^\d{6}$/, 'Enter the 6-digit code'),
  device_id: deviceId,
  trust_device: z.boolean().optional().default(false)
});

const pinLoginSchema = z.object({
  otp_id: z.string().uuid(),
  pin: z.string().regex(/^\d{4,8}$/, 'PIN must be 4 to 8 digits'),
  device_id: deviceId,
  trust_device: z.boolean().optional().default(false)
});

const rotatingSchema = z.object({
  handle: z.string().min(4).max(60),
  code: z.string().min(4).max(12),
  device_id: deviceId,
  trust_device: z.boolean().optional().default(false)
});

const stepUpVerifySchema = z
  .object({
    otp_id: z.string().uuid().optional(),
    code: z.string().regex(/^\d{6}$/).optional(),
    pin: z.string().regex(/^\d{4,8}$/).optional()
  })
  .refine((value) => (value.otp_id && value.code) || value.pin, {
    message: 'Enter the one-time code or your PIN'
  });

const activateSchema = z.object({
  token: z.string().min(16).max(500),
  password: z.string().min(8).max(200),
  pin: z.string().regex(/^\d{4,8}$/).optional(),
  consent: z.literal(true)
});

const forgotSchema = z.object({ email: z.string().email().max(200) });
const resetSchema = z.object({
  token: z.string().min(16).max(500),
  password: z.string().min(8).max(200)
});
const misuseSchema = z.object({
  booking_id: z.string().uuid(),
  reason: z.string().min(5).max(1000)
});

router.post(
  '/qr/lookup',
  authLimiter,
  validate(qrSchema),
  asyncHandler(async (req, res) => {
    const result = await qrLookup({
      token: req.body.token,
      deviceId: req.body.device_id,
      req
    });
    res.json(result);
  })
);

router.post(
  '/password',
  authLimiter,
  validate(passwordSchema),
  asyncHandler(async (req, res) => {
    const result = await loginWithPassword({
      idNumber: req.body.id_number,
      password: req.body.password,
      deviceId: req.body.device_id,
      trustDeviceRequested: req.body.trust_device,
      req
    });
    res.json(result);
  })
);

router.post(
  '/otp/verify',
  otpLimiter,
  validate(otpSchema),
  asyncHandler(async (req, res) => {
    const result = await verifyLoginOtp({
      otpId: req.body.otp_id,
      code: req.body.code,
      deviceId: req.body.device_id,
      trustDeviceRequested: req.body.trust_device,
      req
    });
    res.json(result);
  })
);

router.post(
  '/pin',
  otpLimiter,
  validate(pinLoginSchema),
  asyncHandler(async (req, res) => {
    const result = await verifyLoginPin({
      otpId: req.body.otp_id,
      pin: req.body.pin,
      deviceId: req.body.device_id,
      trustDeviceRequested: req.body.trust_device,
      req
    });
    res.json(result);
  })
);

router.post(
  '/rotating-qr',
  authLimiter,
  validate(rotatingSchema),
  asyncHandler(async (req, res) => {
    const result = await loginWithRotatingQr({
      handle: req.body.handle,
      code: req.body.code,
      deviceId: req.body.device_id,
      trustDeviceRequested: req.body.trust_device,
      req
    });
    res.json(result);
  })
);

router.post(
  '/step-up/request',
  otpLimiter,
  authenticate,
  asyncHandler(async (req, res) => {
    res.json(await requestStepUp({ user: req.user, req }));
  })
);

router.post(
  '/step-up/verify',
  otpLimiter,
  authenticate,
  validate(stepUpVerifySchema),
  asyncHandler(async (req, res) => {
    res.json(
      await verifyStepUp({
        user: req.user,
        otpId: req.body.otp_id,
        code: req.body.code,
        pin: req.body.pin,
        req
      })
    );
  })
);

router.post(
  '/logout',
  authenticate,
  asyncHandler(async (req, res) => {
    res.json(await logout({ user: req.user, sessionId: req.sessionId, req }));
  })
);

router.post(
  '/activate',
  authLimiter,
  validate(activateSchema),
  asyncHandler(async (req, res) => {
    const result = await activateAccount({
      token: req.body.token,
      password: req.body.password,
      pin: req.body.pin,
      consent: req.body.consent,
      req
    });
    res.json(result);
  })
);

router.post(
  '/forgot-password',
  authLimiter,
  validate(forgotSchema),
  asyncHandler(async (req, res) => {
    res.json(await forgotPassword({ email: req.body.email, req }));
  })
);

router.post(
  '/reset-password',
  authLimiter,
  validate(resetSchema),
  asyncHandler(async (req, res) => {
    res.json(await resetPassword({ token: req.body.token, password: req.body.password, req }));
  })
);

router.post(
  '/misuse-report',
  authenticate,
  validate(misuseSchema),
  asyncHandler(async (req, res) => {
    res.json(
      await reportMisuse({
        user: req.user,
        bookingId: req.body.booking_id,
        reason: req.body.reason,
        req
      })
    );
  })
);

router.get(
  '/me',
  authenticate,
  asyncHandler(async (req, res) => {
    res.json({ user: req.user, session_id: req.sessionId, auth: req.authPayload });
  })
);

export default router;
