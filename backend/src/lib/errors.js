export class AppError extends Error {
  constructor(status, code, message, details = undefined) {
    super(message);
    this.name = 'AppError';
    this.status = status;
    this.code = code;
    this.details = details;
  }
}

export const badRequest = (message, details, code = 'BAD_REQUEST') => new AppError(400, code, message, details);
export const unauthorized = (message = 'Authentication required', code = 'UNAUTHORIZED') =>
  new AppError(401, code, message);
export const forbidden = (message = 'You do not have permission to do that', code = 'FORBIDDEN') =>
  new AppError(403, code, message);
export const notFound = (message = 'Not found', code = 'NOT_FOUND') => new AppError(404, code, message);
export const conflict = (message, details, code = 'CONFLICT') => new AppError(409, code, message, details);
export const unprocessable = (message, details, code = 'UNPROCESSABLE') =>
  new AppError(422, code, message, details);
export const tooMany = (message = 'Too many requests', details) =>
  new AppError(429, 'RATE_LIMITED', message, details);

export function asyncHandler(fn) {
  return function wrapped(req, res, next) {
    Promise.resolve(fn(req, res, next)).catch(next);
  };
}

export function isPgExclusionViolation(error) {
  return error && (error.code === '23P01' || /conflicting key value violates exclusion constraint/i.test(error.message || ''));
}

export function isPgUniqueViolation(error) {
  return error && (error.code === '23505' || /duplicate key value violates unique constraint/i.test(error.message || ''));
}

export function pgConstraint(error) {
  return error?.constraint || null;
}
