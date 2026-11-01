import test from 'node:test';
import assert from 'node:assert/strict';
import {
  fromKampala,
  formatKampala,
  kampalaDate,
  kampalaDayBounds,
  kampalaWeekBounds,
  roundUpToMinutes,
  addMinutes,
  durationMinutes,
  isSameKampalaDay,
  dayGrid
} from '../../src/lib/time.js';

test('Kampala input converts to UTC', () => {
  assert.equal(fromKampala('2026-10-31', '14:30').toISOString(), '2026-10-31T11:30:00.000Z');
  assert.equal(formatKampala('2026-10-31T11:30:00.000Z'), 'Sat 31 Oct 2026, 14:30');
});

test('invalid Kampala input is rejected', () => {
  assert.throws(() => fromKampala('2026/10/31', '14:30'));
  assert.throws(() => fromKampala('2026-10-31', '2:30'));
});

test('Kampala day and week boundaries cross UTC correctly', () => {
  const day = kampalaDayBounds('2026-10-31');
  assert.equal(day.start.toISOString(), '2026-10-30T21:00:00.000Z');
  assert.equal(day.end.toISOString(), '2026-10-31T21:00:00.000Z');
  const week = kampalaWeekBounds(new Date('2026-10-31T09:00:00.000Z'));
  assert.equal(week.start.toISOString(), '2026-10-25T21:00:00.000Z');
  assert.equal(week.end.toISOString(), '2026-11-01T21:00:00.000Z');
});

test('day helpers use Kampala dates', () => {
  assert.equal(kampalaDate('2026-10-30T22:00:00.000Z'), '2026-10-31');
  assert.equal(isSameKampalaDay('2026-10-30T22:00:00.000Z', '2026-10-31T05:00:00.000Z'), true);
  assert.equal(isSameKampalaDay('2026-10-30T20:59:00.000Z', '2026-10-31T05:00:00.000Z'), false);
});

test('rounding, adding and durations are deterministic in UTC', () => {
  const rounded = roundUpToMinutes(new Date('2026-10-31T11:33:00.000Z'), 5);
  assert.equal(rounded.toISOString(), '2026-10-31T11:35:00.000Z');
  assert.equal(addMinutes('2026-10-31T11:35:00.000Z', 90).toISOString(), '2026-10-31T13:05:00.000Z');
  assert.equal(durationMinutes('2026-10-31T11:35:00.000Z', '2026-10-31T13:05:00.000Z'), 90);
});

test('day grid never passes the end boundary', () => {
  const slots = dayGrid('2026-10-31T08:00:00.000Z', '2026-10-31T08:45:00.000Z', 30);
  assert.equal(slots.length, 2);
  assert.equal(slots[0].end.toISOString(), '2026-10-31T08:30:00.000Z');
  assert.equal(slots[1].end.toISOString(), '2026-10-31T08:45:00.000Z');
});
