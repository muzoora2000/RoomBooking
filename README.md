# Campus Navigation and Facility Booking

A production-oriented campus app for finding rooms, booking spaces, joining lectures, checking in at the door, and managing operations. The API is Node 20 + Express with PostgreSQL (Neon compatible). The client is a dependency-free HTML/CSS/ES-module PWA.

## Repository layout

```
backend/          Express API, PostgreSQL schema, seed, unit and integration tests
frontend/         Static PWA served by Vercel or by the API
.github/          CI and scheduled operations workflows
render.yaml       Render blueprint for the API
```

## Requirements

- Node.js 20 or newer
- PostgreSQL 15 or newer, or a Neon database
- npm
- Optional provider accounts: Resend or Brevo for email, Africa's Talking for SMS, and a VAPID key pair for web push

## Local setup

```bash
cd backend
cp .env.example .env
npm install
npm run migrate
npm run seed
npm run dev
```

On Windows PowerShell use `Copy-Item .env.example .env` instead of `cp`. Then set `DATABASE_URL` in `backend/.env` to a reachable PostgreSQL or Neon database before running `npm run migrate`.

For the simplest local run, open the app at `http://localhost:4000`. The API serves the `frontend` directory when it is present. Set `FRONTEND_URL=http://localhost:4000` so QR and email links also point at the same server.

To serve the frontend separately, set `FRONTEND_URL=http://localhost:5173` and serve `frontend` with any static server. The API reads `.env` from both `backend/.env` and the repository root `.env`.

## Environment variables

Required in production:

| Variable | Purpose |
| --- | --- |
| `DATABASE_URL` | Neon pooled PostgreSQL connection string with `sslmode=require` |
| `JWT_SECRET` | Bearer token signing secret, at least 32 random bytes |
| `OTP_PEPPER` | Separate secret used to hash one-time codes |
| `QR_SIGNING_SECRET` | Room QR signing secret |
| `DOOR_TOKEN_SECRET` | Short-lived door check-in token secret |
| `CRON_SECRET` | Shared secret for `/api/internal/*` |
| `FRONTEND_URL` | Comma-separated allowed frontend origins; the first is used for links and QR codes |

Provider variables:

| Variable | Purpose |
| --- | --- |
| `EMAIL_PROVIDER` | `resend` (default) or `brevo` |
| `EMAIL_API_KEY` | Provider API key |
| `EMAIL_FROM` | Verified sender identity |
| `AT_API_KEY`, `AT_USERNAME`, `AT_SENDER_ID` | Africa's Talking SMS |
| `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, `VAPID_SUBJECT` | Web push |
| `JWT_EXPIRES_IN` | Login token lifetime, default `8h` |
| `OTP_EXPIRY_MINUTES` | One-time code lifetime, default `5` |
| `APP_TIMEZONE` | Display and input timezone, default `Africa/Kampala` |
| `TRUST_DEVICE_DAYS` | Trusted device lifetime, default `30` |
| `STEP_UP_HOURS` | Scheduling role re-verification interval, default `8` |
| `PGSSL` | `require` for Neon, `disable` only for a local non-SSL database |

Missing email, SMS, or push credentials do not silently disappear. Delivery attempts are recorded with a failure reason, and administrators receive a `system_alert`. Missing production secrets fail startup.

## Database

- `backend/sql/schema.sql` is the source of truth. It is idempotent and creates extensions, tables, indexes, constraints, triggers, and exclusion rules.
- All timestamps are `TIMESTAMPTZ` in UTC. User-entered times and display times use `Africa/Kampala`.
- `backend/sql/seed.sql` is safe to re-run. It creates demo departments, classes, modules, facilities, timetable slots, users, bookings, and settings.
- A booking uses the same generated UUID for `bookings.id` and `bookings.session_id`.
- Room availability is protected by GiST exclusion constraints plus application-side clash and priority checks.
- `no_shows.booking_id` is unique so a booking can be marked as a no-show only once.
- Internal cron and notification workers make all state changes idempotent.

Seed credentials:

| Account | Role | Password |
| --- | --- | --- |
| `SUPER001` | `super_admin` | `ChangeMe#2026` |
| `ADM001` | `department_admin` | `Campus#2026` |
| `LEC001`, `LEC002` | `lecturer` | `Campus#2026` |
| `REP001` | `class_rep` | `Campus#2026` |
| `DEP001` | `deputy_rep` | `Campus#2026` |
| `STU001`, `STU002`, `STU003` | `student` (physical, online, hybrid) | `Campus#2026` |

Demo PIN for every seeded account: `246810`.

Raw ID QR tokens and the demo display key are defined in `backend/sql/seed.sql`. Change all demo credentials and secrets before any real deployment.

## Tests

Unit tests do not need a database:

```bash
cd backend
npm test
```

Integration tests are skipped unless `TEST_DATABASE_URL` is set. Prepare a disposable database first:

```bash
export DATABASE_URL='postgresql://user:pass@host:5432/campus_test?sslmode=require'
npm run migrate
npm run seed
export TEST_DATABASE_URL="$DATABASE_URL"
npm test
```

PowerShell:

```powershell
$env:DATABASE_URL = 'postgresql://user:pass@host:5432/campus_test?sslmode=require'
npm run migrate
npm run seed
$env:TEST_DATABASE_URL = $env:DATABASE_URL
npm test
```

The integration suite verifies health, seeded password login, PIN second factor, bearer authentication, and structured 404 handling. The CI workflow also runs both suites against PostgreSQL 16, checks backend syntax, and checks every frontend ES module.

## Deployment

### 1. Neon

Create a Neon database and copy the pooled connection string. Apply the schema and seed once from a trusted machine:

```bash
cd backend
DATABASE_URL='your-neon-url' npm run migrate
DATABASE_URL='your-neon-url' npm run seed
```

Keep the direct or pooled URL in Render as `DATABASE_URL`. The API disables certificate verification for Neon's managed TLS chain; do not use `PGSSL=disable` in production.

### 2. Render API

`render.yaml` defines the web service:

- Root directory: `backend`
- Build: `npm ci --omit=dev`
- Start: `npm start`
- Health check: `/health`
- Required secrets are marked `sync: false` and must be entered in Render.

Set `FRONTEND_URL` to the final Vercel URL, for example `https://campus.example.vercel.app`, so CORS and generated links are correct. Render injects `PORT`; do not set it manually.

### 3. Vercel frontend

Create a Vercel project with `frontend` as the project root and no build command. `frontend/vercel.json` sets security headers, service-worker caching rules, and an API proxy.

Replace the proxy destination in `frontend/vercel.json`:

```json
"destination": "https://YOUR-RENDER-SERVICE.onrender.com/api/:path*"
```

Alternatively, point the client directly at the API by setting `campus-api-base` in the page meta tag, `localStorage['campus.apiBase']`, or `window.CAMPUS_API_BASE` before `js/config.js` loads. The same-origin proxy is preferred because it avoids browser CORS configuration and keeps the frontend API origin stable.

### 4. Scheduled operations

Two GitHub Actions workflows call the protected internal endpoints:

- `cron.yml` every five minutes: reminders, no-show release, notification queue.
- `housekeeping.yml` daily: retention cleanup.

Create repository secrets:

- `RENDER_API_URL`, for example `https://campus-api.onrender.com`
- `CRON_SECRET`, the same value configured on Render

The API also runs its notification queue every 60 seconds in-process. The scheduled endpoint remains responsible for reminders, no-show release, and retention because Render free instances can sleep.

## Operational notes

- `GET /health` and `GET /api/health` report database connectivity.
- Internal endpoints require `X-Cron-Secret` or a bearer cron secret and use constant-time comparison.
- Rate limits are stricter for authentication and OTP endpoints; test mode raises them for the integration suite.
- Login tokens are bearer-only, expire after eight hours, and are revoked through `auth_sessions.revoked_at`.
- Scheduling roles require verification within eight hours; stale sessions receive `STEP_UP_REQUIRED` with HTTP 428.
- Door displays use a separate twelve-hour display token and a rotating 60-second door QR token.
- Online meeting links and passcodes are only returned to authorised users. They never appear on public room pages, door displays, reports, audit logs, or notification message text.
- SMS may include an online link only when the user opted in with `sms_link_opt_in`.

## Troubleshooting

- **`DATABASE_URL is not set`**: create `backend/.env` or provide the environment variable.
- **Migration fails on extensions**: use PostgreSQL 15+ with `btree_gist` and `pgcrypto` available, or Neon.
- **Login returns `otp_required`**: that is expected for new devices and for scheduling roles. Enter the emailed/SMS code or the account PIN.
- **No emails or SMS arrive**: check the provider keys and the admin `system_alert`; failed deliveries are also visible in notification delivery records.
- **Frontend calls fail on Vercel**: replace the proxy destination in `frontend/vercel.json` or set the API base explicitly.
- **Display cannot connect**: create the display device in the admin page, then enter its device ID and one-time display key. The key can be remembered locally on a kiosk.

See `docs/end-to-end-checklist.md` for release verification.
