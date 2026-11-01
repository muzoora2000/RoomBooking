import { DateTime, Duration } from 'luxon';
import { config } from '../config.js';

const ZONE = config.timezone;

export function zone() {
  return ZONE;
}

export function nowUtc() {
  return new Date();
}

export function toDate(value) {
  if (value instanceof Date) return value;
  if (typeof value === 'string' && value.trim() !== '') {
    const parsed = new Date(value);
    if (!Number.isNaN(parsed.getTime())) return parsed;
  }
  if (typeof value === 'number') return new Date(value);
  throw new Error(`Invalid date/time value: ${value}`);
}

export function fromKampala(dateString, timeString) {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(dateString || '')) throw new Error('Date must be YYYY-MM-DD');
  if (!/^\d{2}:\d{2}$/.test(timeString || '')) throw new Error('Time must be HH:MM');
  const dt = DateTime.fromISO(`${dateString}T${timeString}`, { zone: ZONE });
  if (!dt.isValid) throw new Error(`Invalid Kampala date/time: ${dt.invalidExplanation}`);
  return dt.toUTC().toJSDate();
}

export function fromKampalaISO(localIso) {
  const dt = DateTime.fromISO(localIso, { zone: ZONE });
  if (!dt.isValid) throw new Error(`Invalid Kampala date/time: ${dt.invalidExplanation}`);
  return dt.toUTC().toJSDate();
}

export function formatKampala(value, format = 'ccc dd LLL yyyy, HH:mm') {
  const dt = DateTime.fromJSDate(toDate(value), { zone: 'utc' }).setZone(ZONE);
  return dt.toFormat(format);
}

export function formatKampalaRange(start, end, format = 'ccc dd LLL yyyy, HH:mm') {
  return `${formatKampala(start, format)} - ${formatKampala(end, 'HH:mm')}`;
}

export function kampalaDate(value = new Date()) {
  return DateTime.fromJSDate(toDate(value), { zone: 'utc' }).setZone(ZONE).toISODate();
}

export function kampalaTime(value = new Date()) {
  return DateTime.fromJSDate(toDate(value), { zone: 'utc' }).setZone(ZONE).toFormat('HH:mm');
}

export function kampalaDayBounds(dateString) {
  const start = DateTime.fromISO(dateString, { zone: ZONE }).startOf('day');
  if (!start.isValid) throw new Error('Invalid date');
  return {
    start: start.toUTC().toJSDate(),
    end: start.plus({ days: 1 }).toUTC().toJSDate(),
    label: start.toFormat('ccc dd LLL yyyy')
  };
}

export function kampalaWeekBounds(value = new Date()) {
  const dt = DateTime.fromJSDate(toDate(value), { zone: 'utc' }).setZone(ZONE);
  const start = dt.startOf('week');
  return {
    start: start.toUTC().toJSDate(),
    end: start.plus({ weeks: 1 }).toUTC().toJSDate()
  };
}

export function roundUpToMinutes(value, minutes = 5) {
  const dt = DateTime.fromJSDate(toDate(value), { zone: 'utc' });
  const rounded = dt.plus({ minutes: (minutes - (dt.minute % minutes)) % minutes }).set({ second: 0, millisecond: 0 });
  return rounded.toJSDate();
}

export function addMinutes(value, minutes) {
  return DateTime.fromJSDate(toDate(value), { zone: 'utc' }).plus({ minutes }).toJSDate();
}

export function addDays(value, days) {
  return DateTime.fromJSDate(toDate(value), { zone: 'utc' }).plus({ days }).toJSDate();
}

export function addHours(value, hours) {
  return DateTime.fromJSDate(toDate(value), { zone: 'utc' }).plus({ hours }).toJSDate();
}

export function minutesBetween(start, end) {
  return DateTime.fromJSDate(toDate(end), { zone: 'utc' }).diff(
    DateTime.fromJSDate(toDate(start), { zone: 'utc' }),
    'minutes'
  ).minutes;
}

export function durationMinutes(start, end) {
  return Math.round(minutesBetween(start, end));
}

export function isSameKampalaDay(a, b) {
  return kampalaDate(a) === kampalaDate(b);
}

export function isoUtc(value) {
  return toDate(value).toISOString();
}

export function semesterWindowText(semester) {
  return `${DateTime.fromISO(String(semester.start_date)).toFormat('dd LLL yyyy')} - ${DateTime.fromISO(
    String(semester.end_date)
  ).toFormat('dd LLL yyyy')}`;
}

export function toKampalaDayIso(value) {
  return DateTime.fromJSDate(toDate(value), { zone: 'utc' }).setZone(ZONE).toISODate();
}

export function eachWeek(start, until) {
  const dates = [];
  let cursor = DateTime.fromJSDate(toDate(start), { zone: 'utc' });
  const end = DateTime.fromJSDate(toDate(until), { zone: 'utc' }).endOf('day');
  let guard = 0;
  while (cursor <= end && guard < 520) {
    dates.push(cursor.toJSDate());
    cursor = cursor.plus({ weeks: 1 });
    guard += 1;
  }
  return dates;
}

export function dayGrid(start, end, stepMinutes = 30) {
  const slots = [];
  let cursor = DateTime.fromJSDate(toDate(start), { zone: 'utc' });
  const finish = DateTime.fromJSDate(toDate(end), { zone: 'utc' });
  while (cursor < finish) {
    const next = cursor.plus({ minutes: stepMinutes });
    slots.push({ start: cursor.toJSDate(), end: (next > finish ? finish : next).toJSDate() });
    cursor = next;
  }
  return slots;
}

export function humanDuration(minutes) {
  return Duration.fromObject({ minutes }).toHuman({ unitDisplay: 'short', maximumFractionDigits: 0 });
}
