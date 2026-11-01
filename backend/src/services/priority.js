export const PRIORITY = {
  exam: 100,
  official_timetable: 90,
  admin: 80,
  lecturer: 70,
  class_rep: 50,
  deputy_rep: 50,
  student: 30,
  other: 30
};

export function priorityForRole(role, source = 'manual') {
  if (source === 'exam') return PRIORITY.exam;
  if (source === 'timetable') return PRIORITY.official_timetable;
  return PRIORITY[role] ?? PRIORITY.other;
}

export function canDisplace({ newPriority, newRole, newModuleId, existing }) {
  if (!existing) return false;
  if (!['pending', 'confirmed'].includes(existing.status)) return false;
  if (existing.is_locked || existing.source !== 'manual') return false;
  if (newRole !== 'lecturer') return false;
  if (newPriority <= existing.priority) return false;
  if (!newModuleId || existing.module_id !== newModuleId) return false;
  if (!['class_rep', 'deputy_rep'].includes(existing.booked_by_role)) return false;
  return true;
}

export function displacementReason(newRole, existing) {
  return `A lecturer booked the same module (${existing.module_id}) for the same room and time. Bookings scheduled by class representatives are lower priority for the same module.`;
}
