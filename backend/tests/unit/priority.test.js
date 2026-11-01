import test from 'node:test';
import assert from 'node:assert/strict';
import { PRIORITY, priorityForRole, canDisplace, displacementReason } from '../../src/services/priority.js';

test('role priorities match the documented order', () => {
  assert.equal(priorityForRole('exam'), PRIORITY.exam);
  assert.equal(priorityForRole('lecturer', 'exam'), PRIORITY.exam);
  assert.equal(priorityForRole('class_rep', 'timetable'), PRIORITY.official_timetable);
  assert.equal(priorityForRole('lecturer'), PRIORITY.lecturer);
  assert.equal(priorityForRole('class_rep'), PRIORITY.class_rep);
  assert.equal(priorityForRole('deputy_rep'), PRIORITY.deputy_rep);
  assert.equal(priorityForRole('student'), PRIORITY.student);
  assert.equal(priorityForRole('unknown'), PRIORITY.other);
});

test('lecturers can displace rep bookings only for the same module', () => {
  const existing = {
    status: 'confirmed',
    is_locked: false,
    source: 'manual',
    priority: PRIORITY.class_rep,
    module_id: 'module-1',
    booked_by_role: 'class_rep'
  };
  assert.equal(
    canDisplace({ newPriority: PRIORITY.lecturer, newRole: 'lecturer', newModuleId: 'module-1', existing }),
    true
  );
  assert.equal(
    canDisplace({ newPriority: PRIORITY.lecturer, newRole: 'lecturer', newModuleId: 'module-2', existing }),
    false
  );
});

test('displacement requires manual, unlocked, active rep bookings', () => {
  const base = {
    status: 'confirmed',
    is_locked: false,
    source: 'manual',
    priority: PRIORITY.class_rep,
    module_id: 'module-1',
    booked_by_role: 'deputy_rep'
  };
  assert.equal(canDisplace({ newPriority: PRIORITY.lecturer, newRole: 'class_rep', newModuleId: 'module-1', existing: base }), false);
  assert.equal(canDisplace({ newPriority: PRIORITY.class_rep, newRole: 'lecturer', newModuleId: 'module-1', existing: base }), false);
  assert.equal(canDisplace({ newPriority: PRIORITY.lecturer, newRole: 'lecturer', newModuleId: 'module-1', existing: { ...base, source: 'timetable' } }), false);
  assert.equal(canDisplace({ newPriority: PRIORITY.lecturer, newRole: 'lecturer', newModuleId: 'module-1', existing: { ...base, is_locked: true } }), false);
  assert.equal(canDisplace({ newPriority: PRIORITY.lecturer, newRole: 'lecturer', newModuleId: 'module-1', existing: { ...base, status: 'cancelled' } }), false);
  assert.equal(canDisplace({ newPriority: PRIORITY.lecturer, newRole: 'lecturer', newModuleId: 'module-1', existing: { ...base, booked_by_role: 'student' } }), false);
  assert.equal(canDisplace({ newPriority: PRIORITY.lecturer, newRole: 'lecturer', newModuleId: 'module-1', existing: null }), false);
});

test('displacement reason identifies the module', () => {
  assert.match(displacementReason('lecturer', { module_id: 'module-1' }), /module-1/);
});
