import rateLimit from 'express-rate-limit';
import { config } from '../config.js';

function limiter({ windowMs, max, message, code = 'RATE_LIMITED' }) {
  return rateLimit({
    windowMs,
    max: config.env === 'test' ? 100000 : max,
    standardHeaders: true,
    legacyHeaders: false,
    handler(req, res) {
      res.status(429).json({ error: message, code, details: { retry_after_seconds: Math.ceil(windowMs / 1000) } });
    }
  });
}

export const generalLimiter = limiter({
  windowMs: 15 * 60 * 1000,
  max: 600,
  message: 'Too many requests. Please slow down.'
});

export const authLimiter = limiter({
  windowMs: 15 * 60 * 1000,
  max: 30,
  message: 'Too many authentication attempts. Try again later.'
});

export const otpLimiter = limiter({
  windowMs: 10 * 60 * 1000,
  max: 10,
  message: 'Too many code requests or attempts. Try again later.'
});

export const sensitiveLimiter = limiter({
  windowMs: 60 * 1000,
  max: 60,
  message: 'Too many requests to this endpoint. Please slow down.'
});

export const bookingLimiter = limiter({
  windowMs: 60 * 1000,
  max: 30,
  message: 'Too many booking requests. Please slow down.'
});
