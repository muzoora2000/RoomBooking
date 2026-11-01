import test from 'node:test';
import assert from 'node:assert/strict';
import {
  validateSettingValue,
  isAllowedMeetingLink,
  allowedPlatformForHost,
  SETTING_DEFAULTS
} from '../../src/services/settings.js';

test('numeric settings accept numeric strings and reject negatives', () => {
  assert.equal(validateSettingValue('max_booking_hours_per_day', '3'), 3);
  assert.equal(validateSettingValue('max_booking_duration_minutes', 240), 240);
  assert.throws(() => validateSettingValue('max_booking_hours_per_day', -1));
  assert.throws(() => validateSettingValue('max_booking_hours_per_day', 'abc'));
});

test('boolean settings accept booleans and string booleans', () => {
  assert.equal(validateSettingValue('enable_10min_reminder', true), true);
  assert.equal(validateSettingValue('enable_10min_reminder', 'false'), false);
  assert.throws(() => validateSettingValue('enable_10min_reminder', 'yes'));
});

test('domain settings normalize and filter values', () => {
  assert.deepEqual(validateSettingValue('allowed_meeting_domains', [' Zoom.US ', '']), ['zoom.us']);
  assert.deepEqual(validateSettingValue('rotating_qr_required_roles', ['lecturer', 'student', 'admin', 'deputy_rep']), [
    'lecturer',
    'student',
    'deputy_rep'
  ]);
  assert.throws(() => validateSettingValue('allowed_meeting_domains', []));
  assert.equal(validateSettingValue('email_provider', 'brevo'), 'brevo');
  assert.throws(() => validateSettingValue('email_provider', 'smtp'));
  assert.throws(() => validateSettingValue('not_a_setting', 1));
});

test('meeting links must be HTTPS on an allowed host', () => {
  const allowed = SETTING_DEFAULTS.allowed_meeting_domains;
  assert.equal(isAllowedMeetingLink('https://us02web.zoom.us/j/123', allowed), true);
  assert.equal(isAllowedMeetingLink('https://meet.google.com/abc-defg-hij', allowed), true);
  assert.equal(isAllowedMeetingLink('https://teams.microsoft.com/l/meetup-join/x', allowed), true);
  assert.equal(isAllowedMeetingLink('http://zoom.us/j/123', allowed), false);
  assert.equal(isAllowedMeetingLink('https://zoom.us.evil.example/j/123', allowed), false);
  assert.equal(isAllowedMeetingLink('https://evil-zoom.us/j/123', allowed), false);
  assert.equal(isAllowedMeetingLink('not a url', allowed), false);
});

test('meeting platform is derived from the host', () => {
  assert.equal(allowedPlatformForHost('https://us02web.zoom.us/j/123'), 'zoom');
  assert.equal(allowedPlatformForHost('https://meet.google.com/abc'), 'google_meet');
  assert.equal(allowedPlatformForHost('https://teams.microsoft.com/l/x'), 'teams');
  assert.equal(allowedPlatformForHost('https://example.com/x'), 'other');
  assert.equal(allowedPlatformForHost('not a url'), 'other');
});
