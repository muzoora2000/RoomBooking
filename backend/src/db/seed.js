import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { config } from '../config.js';
import { acquire, closePool, sleeping } from './pool.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const sqlDir = path.resolve(here, '..', '..', 'sql');
const schemaPath = path.join(sqlDir, 'schema.sql');
const demoSeedPath = path.join(sqlDir, 'seed.sql');
const cavendishSeedPath = path.join(sqlDir, 'seed_cavendish.sql');

async function applyFile(client, file, label) {
  const sql = await fs.readFile(file, 'utf8');
  console.log(`Applying ${label} (safe to re-run)...`);
  await client.query(sql);
}

async function main() {
  if (!config.databaseUrl) {
    console.error('DATABASE_URL is required. Add your Neon pooled connection string to backend/.env or the environment.');
    process.exitCode = 1;
    return;
  }
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
    await applyFile(client, schemaPath, 'sql/schema.sql');
    await applyFile(client, demoSeedPath, 'sql/seed.sql');
    await applyFile(client, cavendishSeedPath, 'sql/seed_cavendish.sql');
    const counts = await client.query(`
      SELECT
        (SELECT count(*) FROM departments) AS departments,
        (SELECT count(*) FROM programmes) AS programmes,
        (SELECT count(*) FROM classes) AS classes,
        (SELECT count(*) FROM users) AS users,
        (SELECT count(*) FROM modules) AS modules,
        (SELECT count(*) FROM facilities) AS facilities,
        (SELECT count(*) FROM timetable_slots) AS timetable_slots
    `);
    console.log('Seed complete:', counts.rows[0]);
    console.log('Demo login: SUPER001 / ChangeMe#2026 (super admin), all other seeded users use Campus#2026, PIN 246810.');
  } catch (error) {
    try {
      await client.query('ROLLBACK');
    } catch {
      // Ignore rollback errors after an aborted transaction.
    }
    console.error('Seed failed:', error.message);
    if (error.position) console.error('SQL position:', error.position);
    process.exitCode = 1;
  } finally {
    client.release();
    await closePool();
  }
}

main().catch(async (error) => {
  console.error('Seed failed:', error.message);
  await closePool().catch(() => {});
  process.exitCode = 1;
});
