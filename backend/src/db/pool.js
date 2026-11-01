import pg from 'pg';
import { config } from '../config.js';

const { Pool } = pg;

const sslDisabled = config.pgSslMode === 'disable' || /sslmode=disable/i.test(config.databaseUrl);

export const pool = new Pool({
  connectionString: config.databaseUrl,
  ssl: sslDisabled ? false : { rejectUnauthorized: false },
  max: Number(process.env.PG_POOL_MAX || 5),
  idleTimeoutMillis: 30_000,
  connectionTimeoutMillis: 10_000,
  allowExitOnIdle: false
});

pool.on('error', (error) => {
  console.error('[db] idle client error', error.message);
});

const RETRYABLE = new Set([
  'ECONNRESET',
  'ECONNREFUSED',
  'ENOTFOUND',
  'ETIMEDOUT',
  'EPIPE',
  '57P01',
  '57P02',
  '57P03',
  '08000',
  '08003',
  '08006',
  '08001',
  '08004',
  '53300'
]);

function retryable(error) {
  if (!error) return false;
  if (RETRYABLE.has(error.code)) return true;
  return /connection terminated|connection timeout|terminating connection|timeout expired|ECONNREFUSED|ENOTFOUND/i.test(
    error.message || ''
  );
}

export function sleeping(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

export async function acquire(attempts = 3) {
  let lastError;
  for (let attempt = 1; attempt <= attempts; attempt += 1) {
    try {
      return await pool.connect();
    } catch (error) {
      lastError = error;
      if (!retryable(error) || attempt === attempts) break;
      const delay = 250 * 2 ** (attempt - 1) + Math.floor(Math.random() * 100);
      console.warn(`[db] connection attempt ${attempt} failed (${error.message}); retrying in ${delay}ms`);
      await sleeping(delay);
    }
  }
  throw lastError;
}

export async function query(text, params = [], attempts = 3) {
  let lastError;
  for (let attempt = 1; attempt <= attempts; attempt += 1) {
    let client;
    try {
      client = await acquire(attempts);
      return await client.query(text, params);
    } catch (error) {
      lastError = error;
      if (!retryable(error) || attempt === attempts) break;
      const delay = 250 * 2 ** (attempt - 1) + Math.floor(Math.random() * 100);
      console.warn(`[db] query attempt ${attempt} failed (${error.message}); retrying in ${delay}ms`);
      await sleeping(delay);
    } finally {
      if (client) client.release();
    }
  }
  throw lastError;
}

export async function withTransaction(fn, attempts = 3) {
  const client = await acquire(attempts);
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (error) {
    try {
      await client.query('ROLLBACK');
    } catch (rollbackError) {
      console.error('[db] rollback failed', rollbackError.message);
    }
    throw error;
  } finally {
    client.release();
  }
}

export async function healthCheck() {
  const result = await query('SELECT now() AS now, current_database() AS database, version() AS version', [], 2);
  return result.rows[0];
}

export async function closePool() {
  await pool.end();
}
