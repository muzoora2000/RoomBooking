import { forbidden } from '../lib/errors.js';

export function requireRole(...roles) {
  const allowed = new Set(roles);
  return function roleGuard(req, res, next) {
    if (!req.user) return next(forbidden('Sign in required'));
    if (!allowed.has(req.user.role)) {
      return next(forbidden(`This action requires one of these roles: ${[...allowed].join(', ')}`, 'ROLE_REQUIRED'));
    }
    return next();
  };
}

export const requireStudent = requireRole('student', 'class_rep', 'deputy_rep');
export const requireScheduler = requireRole('class_rep', 'deputy_rep', 'lecturer', 'department_admin', 'super_admin');
export const requireLecturer = requireRole('lecturer');
export const requireAdmin = requireRole('department_admin', 'super_admin');
export const requireSuperAdmin = requireRole('super_admin');

export function requireDepartmentScope(req, res, next) {
  if (!req.user) return next(forbidden());
  if (req.user.role === 'super_admin') return next();
  if (!['department_admin'].includes(req.user.role)) {
    return next(forbidden('Department administrator access required', 'DEPARTMENT_ADMIN_REQUIRED'));
  }
  if (!req.user.department_id) return next(forbidden('Your account is not assigned to a department'));
  req.departmentScope = req.user.department_id;
  return next();
}

export function assertDepartmentAccess(user, departmentId) {
  if (!user) throw forbidden();
  if (user.role === 'super_admin') return;
  if (user.role === 'department_admin' && user.department_id === departmentId) return;
  throw forbidden('You can only manage records in your own department', 'DEPARTMENT_SCOPE');
}
