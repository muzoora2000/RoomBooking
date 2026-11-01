import dotenv from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const here = path.dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: path.resolve(here, '..', '.env') });
dotenv.config({ path: path.resolve(here, '..', '..', '.env') });

const isProduction = process.env.NODE_ENV === 'production';

function requiredInProduction(name, developmentFallback) {
  const value = process.env[name];
  if (value) return value;
  if (isProduction) {
    throw new Error(`Missing required environment variable ${name}. Set it in Render before starting the API.`);
  }
  return developmentFallback;
}

function numberEnv(name, fallback) {
  const raw = process.env[name];
  if (raw === undefined || raw === '') return fallback;
  const parsed = Number(raw);
  if (!Number.isFinite(parsed)) throw new Error(`${name} must be a number`);
  return parsed;
}

const frontendUrls = (process.env.FRONTEND_URL || 'http://localhost:5173,http://127.0.0.1:5173')
  .split(',')
  .map((value) => value.trim().replace(/\/$/, ''))
  .filter(Boolean);

export const config = {
  env: process.env.NODE_ENV || 'development',
  isProduction,
  port: numberEnv('PORT', 4000),
  databaseUrl: process.env.DATABASE_URL || '',
  pgSslMode: process.env.PGSSL || 'require',
  jwtSecret: requiredInProduction('JWT_SECRET', 'dev-only-jwt-secret-change-me'),
  jwtExpiresIn: process.env.JWT_EXPIRES_IN || '8h',
  otpExpiryMinutes: numberEnv('OTP_EXPIRY_MINUTES', 5),
  otpPepper: requiredInProduction('OTP_PEPPER', 'dev-only-otp-pepper-change-me'),
  timezone: process.env.APP_TIMEZONE || 'Africa/Kampala',
  frontendUrls,
  primaryFrontendUrl: frontendUrls[0] || 'http://localhost:5173',
  emailProvider: (process.env.EMAIL_PROVIDER || 'resend').toLowerCase(),
  emailApiKey: process.env.EMAIL_API_KEY || '',
  emailFrom: process.env.EMAIL_FROM || 'Campus Navigation <no-reply@campus.ac.ug>',
  atApiKey: process.env.AT_API_KEY || '',
  atUsername: process.env.AT_USERNAME || '',
  atSenderId: process.env.AT_SENDER_ID || '',
  vapidPublicKey: process.env.VAPID_PUBLIC_KEY || '',
  vapidPrivateKey: process.env.VAPID_PRIVATE_KEY || '',
  vapidSubject: process.env.VAPID_SUBJECT || 'mailto:admin@campus.ac.ug',
  cronSecret: requiredInProduction('CRON_SECRET', 'dev-only-cron-secret-change-me'),
  qrSigningSecret: requiredInProduction('QR_SIGNING_SECRET', 'dev-only-qr-signing-secret-change-me'),
  doorTokenSecret: requiredInProduction('DOOR_TOKEN_SECRET', 'dev-only-door-token-secret-change-me'),
  trustDeviceDays: numberEnv('TRUST_DEVICE_DAYS', 30),
  stepUpHours: numberEnv('STEP_UP_HOURS', 8)
};

export function assertServerEnvironment() {
  if (!config.databaseUrl) {
    throw new Error('DATABASE_URL is not set. Copy .env.example to .env and add your Neon pooled connection string.');
  }
  if (config.isProduction && config.frontendUrls.some((url) => !url.startsWith('https://'))) {
    throw new Error('FRONTEND_URL must use https in production.');
  }
}

export function isAllowedFrontendOrigin(origin) {
  if (!origin) return true;
  return config.frontendUrls.includes(origin.replace(/\/$/, ''));
}
