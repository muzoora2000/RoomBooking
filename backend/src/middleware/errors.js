import { AppError, isPgExclusionViolation, isPgUniqueViolation } from '../lib/errors.js';

export function notFoundHandler(req, res) {
  res.status(404).json({ error: `Route not found: ${req.method} ${req.originalUrl}`, code: 'NOT_FOUND' });
}

export function errorHandler(error, req, res, next) {
  if (res.headersSent) return next(error);
  if (error instanceof AppError) {
    return res.status(error.status).json({ error: error.message, code: error.code, details: error.details });
  }
  if (isPgExclusionViolation(error)) {
    return res.status(409).json({
      error: 'That room or lecturer is already booked for the selected time.',
      code: 'BOOKING_CLASH',
      details: { constraint: error.constraint || null }
    });
  }
  if (isPgUniqueViolation(error)) {
    return res.status(409).json({
      error: 'A record with those details already exists.',
      code: 'DUPLICATE_RECORD',
      details: { constraint: error.constraint || null }
    });
  }
  if (error?.code === '23503') {
    return res.status(409).json({
      error: 'This record is still linked to other data and cannot be changed that way.',
      code: 'FOREIGN_KEY',
      details: { constraint: error.constraint || null }
    });
  }
  if (error?.code === '22P02') {
    return res.status(400).json({ error: 'One of the identifiers is invalid.', code: 'INVALID_ID' });
  }
  if (error?.type === 'entity.too.large') {
    return res.status(413).json({ error: 'The uploaded data is too large.', code: 'PAYLOAD_TOO_LARGE' });
  }
  if (error instanceof SyntaxError && error.status === 400 && 'body' in error) {
    return res.status(400).json({ error: 'Malformed JSON body.', code: 'INVALID_JSON' });
  }
  console.error('[error]', req.method, req.originalUrl, error);
  return res.status(500).json({
    error: 'An unexpected server error occurred.',
    code: 'INTERNAL_ERROR',
    details: process.env.NODE_ENV === 'production' ? undefined : { message: error.message }
  });
}
