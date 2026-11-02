import fs from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { config } from '../config.js';
import { acquire, closePool, sleeping } from './pool.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const schemaPath = path.resolve(here, '..', '..', 'sql', 'schema.sql');
const seedPath   = path.resolve(here, '..', '..', 'sql', 'seed_cavendish.sql');

/**
 * Apply schema.sql then seed_cavendish.sql to the database.
 * Safe to call on every startup — all DDL uses IF NOT EXISTS guards
 * and all DML uses ON CONFLICT DO NOTHING / DO UPDATE.
 * Does NOT close the pool — the caller is responsible for that.
 */
export async function runMigration() {
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
    // Run Cavendish seed data if the file exists
    try {
      const seedSql = await fs.readFile(seedPath, 'utf8');
      console.log('Applying sql/seed_cavendish.sql (Cavendish timetable data)...');
      await client.query(seedSql);
      console.log('Seed applied successfully.');
    } catch (seedErr) {
      // Non-fatal: seed file may not exist in all environments
      if (seedErr.code !== 'ENOENT') {
        console.warn('Seed warning:', seedErr.message);
      }
    }
  } catch (error) {
    try { await client.query('ROLLBACK'); } catch { /* already aborted */ }
    console.error('Migration failed:', error.message);
    if (error.position) console.error('SQL position:', error.position);
    throw error; // re-throw so the caller can decide whether to abort startup
  } finally {
    client.release();
  }
}

// Standalone CLI entry point: node src/db/migrate.js
// Only runs when this module IS the entry point (not when imported).
if (process.argv[1] && (
  process.argv[1].endsWith('migrate.js') ||
  process.argv[1].endsWith('migrate')
)) {
  runMigration()
    .then(() => closePool())
    .catch(async (error) => {
      console.error('Migration failed:', error.message);
      await closePool().catch(() => {});
      process.exitCode = 1;
    });
}
