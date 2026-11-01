import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { config } from '../config.js';
import { acquire, closePool, sleeping } from './pool.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const schemaPath = path.resolve(here, '..', '..', 'sql', 'schema.sql');

async function main() {
  if (!config.databaseUrl) {
    console.error('DATABASE_URL is required. Add your Neon pooled connection string to backend/.env or the environment.');
    process.exitCode = 1;
    return;
  }
  const sql = await fs.readFile(schemaPath, 'utf8');
  let client;
  let lastError;
  for (let attempt = 1; attempt <= 3; attempt += 1) {
    try {
      client = await acquire(3);
      break;
    } catch (error) {
      lastError = error;
      if (attempt < 3) await sleeping(attempt * 1000);
    }
  }
  if (!client) throw lastError;
  try {
    console.log('Applying sql/schema.sql to the database...');
    await client.query(sql);
    const info = await client.query('SELECT current_database() AS database, now() AS now');
    console.log(`Schema applied successfully to ${info.rows[0].database} at ${info.rows[0].now.toISOString()}`);
  } catch (error) {
    try {
      await client.query('ROLLBACK');
    } catch {
      // The failed statement may already have aborted the transaction.
    }
    console.error('Migration failed:', error.message);
    if (error.position) console.error('SQL position:', error.position);
    process.exitCode = 1;
  } finally {
    client.release();
    await closePool();
  }
}

main().catch(async (error) => {
  console.error('Migration failed:', error.message);
  await closePool().catch(() => {});
  process.exitCode = 1;
});
