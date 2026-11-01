import { AppError } from '../lib/errors.js';

export function validate(schema, source = 'body') {
  return function validationMiddleware(req, res, next) {
    const result = schema.safeParse(req[source]);
    if (!result.success) {
      const details = result.error.issues.map((issue) => ({
        path: issue.path.join('.'),
        message: issue.message,
        code: issue.code
      }));
      return next(new AppError(400, 'VALIDATION_ERROR', 'Some fields are invalid.', details));
    }
    req[source] = result.data;
    return next();
  };
}

export function validateAll({ body, query, params }) {
  return function combinedValidation(req, res, next) {
    const details = [];
    for (const [source, schema] of Object.entries({ body, query, params })) {
      if (!schema) continue;
      const result = schema.safeParse(req[source]);
      if (!result.success) {
        for (const issue of result.error.issues) {
          details.push({ source, path: issue.path.join('.'), message: issue.message, code: issue.code });
        }
      } else {
        req[source] = result.data;
      }
    }
    if (details.length) return next(new AppError(400, 'VALIDATION_ERROR', 'Some fields are invalid.', details));
    return next();
  };
}
