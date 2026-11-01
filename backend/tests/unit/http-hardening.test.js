import test from 'node:test';
import assert from 'node:assert/strict';
import request from 'supertest';
import app from '../../src/app.js';

test('unknown endpoints return a structured 404', async () => {
  const response = await request(app).get('/api/not-a-real-route');
  assert.equal(response.status, 404);
  assert.equal(response.body.code, 'NOT_FOUND');
});

test('security headers are applied to responses', async () => {
  const response = await request(app).get('/api/not-a-real-route');
  assert.equal(response.headers['x-content-type-options'], 'nosniff');
  assert.equal(response.headers['referrer-policy'], 'strict-origin-when-cross-origin');
  assert.equal(response.headers['x-powered-by'], undefined);
});

test('internal cron routes reject missing and incorrect secrets', async () => {
  const missing = await request(app).post('/api/internal/reminders').send({});
  assert.equal(missing.status, 403);
  assert.equal(missing.body.code, 'CRON_UNAUTHORISED');
  const wrong = await request(app)
    .post('/api/internal/reminders')
    .set('X-Cron-Secret', 'definitely-not-the-secret')
    .send({});
  assert.equal(wrong.status, 403);
  assert.equal(wrong.body.code, 'CRON_UNAUTHORISED');
});
