import app from './src/app.js';
import { config, assertServerEnvironment } from './src/config.js';
import { closePool, healthCheck } from './src/db/pool.js';
import { processNotificationQueue } from './src/services/queue.js';

assertServerEnvironment();

let queueTimer = null;
let shuttingDown = false;

const server = app.listen(config.port, async () => {
  console.log(`[api] listening on port ${config.port} in ${config.env} mode`);
  try {
    const database = await healthCheck();
    console.log(`[api] database connected: ${database.database}`);
  } catch (error) {
    console.error('[api] database health check failed:', error.message);
  }
  queueTimer = setInterval(async () => {
    try {
      await processNotificationQueue(25);
    } catch (error) {
      console.error('[queue] background processing failed:', error.message);
    }
  }, 60_000);
  queueTimer.unref?.();
});

server.keepAliveTimeout = 65_000;
server.headersTimeout = 70_000;

async function shutdown(signal) {
  if (shuttingDown) return;
  shuttingDown = true;
  console.log(`[api] received ${signal}; shutting down`);
  if (queueTimer) clearInterval(queueTimer);
  server.close(async () => {
    try {
      await closePool();
    } catch (error) {
      console.error('[api] error closing database pool:', error.message);
    }
    process.exit(0);
  });
  setTimeout(() => {
    console.error('[api] shutdown timed out');
    process.exit(1);
  }, 15_000).unref();
}

process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
process.on('unhandledRejection', (reason) => {
  console.error('[api] unhandled rejection:', reason);
});
process.on('uncaughtException', (error) => {
  console.error('[api] uncaught exception:', error);
  shutdown('uncaughtException');
});
