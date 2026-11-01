import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import compression from 'compression';
import path from 'node:path';
import { existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { config, isAllowedFrontendOrigin } from './config.js';
import { healthCheck } from './db/pool.js';
import { AppError } from './lib/errors.js';
import { errorHandler } from './middleware/errors.js';
import authRoutes from './routes/auth.routes.js';
import userRoutes from './routes/users.routes.js';
import facilityRoutes from './routes/facilities.routes.js';
import roomRoutes from './routes/rooms.routes.js';
import displayRoutes from './routes/display.routes.js';
import bookingRoutes from './routes/bookings.routes.js';
import lectureRoutes from './routes/lectures.routes.js';
import notificationRoutes from './routes/notifications.routes.js';
import orgRoutes from './routes/org.routes.js';
import timetableRoutes from './routes/timetable.routes.js';
import adminRoutes from './routes/admin.routes.js';
import reportRoutes from './routes/reports.routes.js';
import settingsRoutes from './routes/settings.routes.js';
import internalRoutes from './routes/internal.routes.js';

const here = path.dirname(fileURLToPath(import.meta.url));
const frontendPath = path.resolve(here, '..', '..', 'frontend');
const frontendIndex = path.join(frontendPath, 'index.html');

const app = express();
app.disable('x-powered-by');
app.set('trust proxy', 1);

app.use(
  helmet({
    contentSecurityPolicy: false,
    crossOriginResourcePolicy: { policy: 'cross-origin' },
    crossOriginEmbedderPolicy: false
  })
);
app.use(
  cors({
    origin(origin, callback) {
      if (!origin || isAllowedFrontendOrigin(origin)) return callback(null, true);
      return callback(new AppError(403, 'ORIGIN_NOT_ALLOWED', 'This origin is not allowed to call the API.'));
    },
    allowedHeaders: ['Content-Type', 'Authorization', 'X-Cron-Secret'],
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    maxAge: 86400
  })
);
app.use(compression());
app.use(express.json({ limit: '2mb' }));
app.use(express.urlencoded({ extended: false, limit: '2mb' }));
app.use((req, res, next) => {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('Referrer-Policy', 'strict-origin-when-cross-origin');
  next();
});

app.get('/health', async (req, res) => {
  try {
    const db = await healthCheck();
    res.json({ ok: true, service: 'campus-booking-api', env: config.env, database: db, time: new Date().toISOString() });
  } catch (error) {
    res.status(503).json({ ok: false, service: 'campus-booking-api', error: error.message });
  }
});
app.get('/api/health', async (req, res) => {
  try {
    const db = await healthCheck();
    res.json({ ok: true, service: 'campus-booking-api', env: config.env, database: db, time: new Date().toISOString() });
  } catch (error) {
    res.status(503).json({ ok: false, service: 'campus-booking-api', error: error.message });
  }
});

app.use('/api/auth', authRoutes);
app.use('/api/me', userRoutes);
app.use('/api/facilities', facilityRoutes);
app.use('/api/rooms', roomRoutes);
app.use('/api/display', displayRoutes);
app.use('/api/bookings', bookingRoutes);
app.use('/api/lectures', lectureRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/org', orgRoutes);
app.use('/api/timetable', timetableRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/reports', reportRoutes);
app.use('/api/settings', settingsRoutes);
app.use('/api/internal', internalRoutes);

if (existsSync(frontendPath)) {
  app.use(express.static(frontendPath, { extensions: ['html'], maxAge: config.isProduction ? '1h' : 0 }));
  app.get('*', (req, res, next) => {
    if (req.path.startsWith('/api/')) return next();
    if (!existsSync(frontendIndex)) return next();
    if (req.method !== 'GET' || !req.accepts('html')) return next();
    return res.sendFile(frontendIndex);
  });
}

app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found', code: 'NOT_FOUND', path: req.originalUrl });
});

app.use(errorHandler);

export default app;
