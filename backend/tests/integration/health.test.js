import test from 'node:test';
import assert from 'node:assert/strict';

const databaseUrl = process.env.TEST_DATABASE_URL;
const skipReason = databaseUrl
  ? false
  : 'TEST_DATABASE_URL is not set. Run migrate and seed against a disposable database, then set TEST_DATABASE_URL.';

test('API health, login and protected route', { skip: skipReason }, async (t) => {
  process.env.DATABASE_URL = databaseUrl;
  process.env.NODE_ENV = 'test';

  const [{ default: request }, { default: app }, { closePool }] = await Promise.all([
    import('supertest'),
    import('../../src/app.js'),
    import('../../src/db/pool.js')
  ]);

  t.after(async () => {
    await closePool();
  });

  const health = await request(app).get('/api/health');
  assert.equal(health.status, 200);
  assert.equal(health.body.ok, true);
  assert.equal(health.body.service, 'campus-booking-api');

  const password = await request(app).post('/api/auth/password').send({
    id_number: 'SUPER001',
    password: 'ChangeMe#2026',
    device_id: 'integration-test-device-0001',
    trust_device: false
  });
  assert.equal(password.status, 200);
  assert.equal(password.body.otp_required, true);
  assert.ok(password.body.otp_id);

  const pin = await request(app).post('/api/auth/pin').send({
    otp_id: password.body.otp_id,
    pin: '246810',
    device_id: 'integration-test-device-0001',
    trust_device: false
  });
  assert.equal(pin.status, 200);
  assert.ok(pin.body.token);

  const me = await request(app).get('/api/auth/me').set('Authorization', `Bearer ${pin.body.token}`);
  assert.equal(me.status, 200);
  assert.equal(me.body.user.id_number, 'SUPER001');
  assert.equal(me.body.user.role, 'super_admin');

  const unauthorised = await request(app).get('/api/admin/overview');
  assert.equal(unauthorised.status, 401);
});

test('unknown endpoints return a structured 404', async () => {
  const { default: request } = await import('supertest');
  const { default: app } = await import('../../src/app.js');
  const response = await request(app).get('/api/not-a-real-route');
  assert.equal(response.status, 404);
  assert.equal(response.body.code, 'NOT_FOUND');
});
