import test from 'node:test';
import assert from 'node:assert/strict';
import { assertCheckinWindow } from '../../src/services/checkin.js';

const start = new Date('2026-11-01T10:00:00.000Z');
const booking = { start_at: start };
const settings = { checkin_open_minutes: 20, no_show_grace_minutes: 5 };
const at = (minutes) => new Date(start.getTime() + minutes * 60_000);

test('check-in window honours configured open and grace minutes', async () => {
  await assert.rejects(
    () => assertCheckinWindow(booking, settings, { now: at(-25) }),
    (error) => error.status === 409 && error.code === 'CHECKIN_NOT_OPEN'
  );
  await assert.doesNotReject(() => assertCheckinWindow(booking, settings, { now: at(-19) }));
  await assert.doesNotReject(() => assertCheckinWindow(booking, settings, { now: at(4) }));
  await assert.rejects(
    () => assertCheckinWindow(booking, settings, { now: at(6) }),
    (error) => error.status === 409 && error.code === 'CHECKIN_CLOSED'
  );
});

test('administrative check-in can bypass the configured window', async () => {
  await assert.doesNotReject(() =>
    assertCheckinWindow(booking, settings, { now: at(-60), allowOutside: true })
  );
});
