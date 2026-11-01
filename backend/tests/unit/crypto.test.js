import test from 'node:test';
import assert from 'node:assert/strict';
import {
  base32Encode,
  base32Decode,
  totpCode,
  totpRemainingSeconds,
  verifyTotp,
  normalizeUgandaPhone,
  maskEmail,
  maskPhone,
  constantTimeEqual,
  randomBase32Secret
} from '../../src/lib/crypto.js';

test('base32 secrets round-trip', () => {
  const secret = randomBase32Secret(20);
  assert.match(secret, /^[A-Z2-7]+$/);
  const decoded = base32Decode(secret);
  assert.equal(base32Encode(decoded), secret);
});

test('TOTP codes verify within the allowed window', () => {
  const secret = randomBase32Secret(20);
  const code = totpCode(secret, Date.now());
  assert.equal(verifyTotp(secret, code), true);
  assert.equal(verifyTotp(secret, code, { window: 0 }), true);
  assert.equal(verifyTotp(secret, '123456'), false);
  assert.equal(verifyTotp(secret, 'abc'), false);
  assert.ok(totpRemainingSeconds() >= 1 && totpRemainingSeconds() <= 30);
});

test('constant time comparison rejects different lengths', () => {
  assert.equal(constantTimeEqual('abc', 'abc'), true);
  assert.equal(constantTimeEqual('abc', 'abd'), false);
  assert.equal(constantTimeEqual('abc', 'abcd'), false);
});

test('Ugandan phone numbers normalize to E.164', () => {
  assert.equal(normalizeUgandaPhone('0700000007'), '+256700000007');
  assert.equal(normalizeUgandaPhone('256700000007'), '+256700000007');
  assert.equal(normalizeUgandaPhone('+256700000007'), '+256700000007');
  assert.equal(normalizeUgandaPhone('+256 700 000 007'), '+256700000007');
  assert.equal(normalizeUgandaPhone('0712345'), null);
  assert.equal(normalizeUgandaPhone(''), null);
});

test('masking never exposes full contact details', () => {
  const email = maskEmail('student.physical@campus.ac.ug');
  assert.equal(email.includes('student.physical'), false);
  assert.match(email, /@campus\.ac\.ug$/);
  const phone = maskPhone('+256700000007');
  assert.equal(phone, '+256*******07');
  assert.equal(maskEmail(''), '');
  assert.equal(maskPhone(''), '');
});
