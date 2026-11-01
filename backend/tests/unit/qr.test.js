import test from 'node:test';
import assert from 'node:assert/strict';
import {
  buildRoomQrUrl,
  verifyRoomSignature,
  signDoorToken,
  verifyDoorToken,
  generateQrDataUrl,
  escapeHtml
} from '../../src/services/qr.js';

const facility = {
  id: '11111111-1111-4111-8111-111111111111',
  qr_version: 2,
  qr_secret: 'seed-room-secret'
};

test('room QR URLs carry the facility, version and signature', () => {
  const url = buildRoomQrUrl(facility);
  assert.match(url, /\/room\.html\?f=/);
  const parsed = new URL(url);
  assert.equal(parsed.searchParams.get('f'), facility.id);
  assert.equal(parsed.searchParams.get('v'), '2');
  assert.equal(parsed.searchParams.get('s').length, 24);
});

test('room signatures reject tampered versions and secrets', () => {
  const url = new URL(buildRoomQrUrl(facility));
  const signature = url.searchParams.get('s');
  assert.equal(verifyRoomSignature(facility, 2, signature), true);
  assert.equal(verifyRoomSignature(facility, 1, signature), false);
  assert.equal(verifyRoomSignature({ ...facility, qr_secret: 'other' }, 2, signature), false);
  assert.equal(verifyRoomSignature(facility, 2, `${signature}x`), false);
  assert.equal(verifyRoomSignature(null, 2, signature), false);
});

test('door tokens are short-lived signed payloads', () => {
  const token = signDoorToken(facility.id, 60);
  const verified = verifyDoorToken(token, facility.id);
  assert.equal(verified.valid, true);
  assert.equal(verified.payload.f, facility.id);
  assert.equal(verifyDoorToken(token, 'another-facility').valid, false);
  assert.equal(verifyDoorToken(signDoorToken(facility.id, -5), facility.id).reason, 'expired');
  assert.equal(verifyDoorToken('not-a-token', facility.id).reason, 'malformed');
  assert.equal(verifyDoorToken(`${token}x`, facility.id).reason, 'signature');
  const [payload] = token.split('.');
  assert.equal(verifyDoorToken(`${payload}.bad`, facility.id).valid, false);
});

test('QR data URLs and HTML escaping are safe', async () => {
  const dataUrl = await generateQrDataUrl('https://example.test/room', { width: 64 });
  assert.match(dataUrl, /^data:image\/png;base64,/);
  assert.equal(escapeHtml('<script>alert("x")</script>'), '&lt;script&gt;alert(&quot;x&quot;)&lt;/script&gt;');
});
