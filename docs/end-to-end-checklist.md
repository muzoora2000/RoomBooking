# End-to-end release checklist

Use a staging database and staging provider keys. Do not run destructive checks against production data.

## Database and startup

- [ ] `DATABASE_URL` points at the intended database and uses SSL.
- [ ] `npm run migrate` completes without errors.
- [ ] `npm run seed` completes and can be run twice without duplicates.
- [ ] All production secrets are set and are not the repository defaults.
- [ ] `GET /health` returns `ok: true` and the expected database name.
- [ ] Render logs show a successful database health check and queue startup.

## Authentication and security

- [ ] Password login from a new device requires OTP and sends a new-device security notification.
- [ ] PIN login completes the same challenge and issues a bearer token.
- [ ] ID QR lookup always requires OTP or PIN.
- [ ] Trusted-device login works for a non-scheduling role.
- [ ] Lecturer, class rep, and deputy rep always face the second factor even on a trusted device.
- [ ] A scheduling role with stale verification receives HTTP 428 `STEP_UP_REQUIRED`.
- [ ] Logout revokes the session; the old token immediately fails `/api/auth/me`.
- [ ] Activation, password reset, and expired challenge links fail clearly.
- [ ] Repeated failed check-ins flag the account and alert administrators.
- [ ] Anonymous users cannot read online links or passcodes from room, report, audit, or notification payloads.
- [ ] CORS rejects an origin that is not in `FRONTEND_URL`.

## Rooms and bookings

- [ ] Guest room search works without signing in.
- [ ] Room detail shows only public location and schedule information.
- [ ] Booking creation rejects invalid durations, excessive notice windows, and clashes.
- [ ] Double-booking a room and time is rejected by the exclusion constraint.
- [ ] A student can book only a discussion room or library.
- [ ] A lecture-room or lab booking requires a module session.
- [ ] Study-mode overrides change effective physical attendance capacity.
- [ ] Daily and weekly fairness limits apply to students and reps but not lecturers or admins.
- [ ] Walk-up room QR booking bypasses notice/advance limits but still enforces duration, fairness, and no-show suspension.
- [ ] A lecturer can displace only a class rep booking for the same module.
- [ ] A displaced rep receives a critical in-app notification and the booking is marked displaced.
- [ ] Cancelling a booking releases the room and notifies affected recipients.

## Check-in and door display

- [ ] Check-in opens ten minutes before the start and closes fifteen minutes after by default.
- [ ] Rotating door token check-in succeeds inside the room window.
- [ ] Expired, tampered, or wrong-room door tokens fail with a clear code.
- [ ] Static GPS check-in rejects poor accuracy and distances outside the room radius.
- [ ] An authorised admin can check in outside the window and the audit log records `admin`.
- [ ] The door display refuses an invalid device ID or display key.
- [ ] A valid display shows current and next sessions, Kampala time, and a QR that refreshes every 60 seconds.
- [ ] A revoked or logged-out display cannot fetch room data.
- [ ] No-show release runs after the grace period and records exactly one no-show row per booking.
- [ ] Hybrid no-show converts the session to online; physical no-show releases the room.
- [ ] Exempt timetable, lecturer, and lecture-room settings are respected.

## Lectures and notifications

- [ ] My lectures lists physical, hybrid, and online sessions according to enrolments and effective study mode.
- [ ] Online join opens fifteen minutes before the start and closes at the end.
- [ ] Join clicks are recorded, and online links remain hidden from unauthorised users.
- [ ] Confirmation, update, cancellation, reminder, and displacement notifications reach enrolled users only.
- [ ] In-app notifications respect read state and preferences.
- [ ] Email, SMS, and push deliveries are queued, attempted, and recorded with success or failure.
- [ ] Missing provider credentials produce a failed delivery record and an admin `system_alert`.
- [ ] SMS includes an online link only when the recipient opted in.
- [ ] Reminder cron does not send duplicates.
- [ ] The notification queue retries transient failures and stops after its attempt limit.

## Administration and reporting

- [ ] Department admins see only their department; super admins see everything.
- [ ] User activation, deactivation, QR revocation, and role changes are audited.
- [ ] Facility, room, block, equipment, and display administration works.
- [ ] Timetable CSV import validates headers, modules, times, and clashes before committing.
- [ ] Exam blocks prevent conflicting ordinary bookings.
- [ ] Issue reports can be triaged and resolved.
- [ ] Study-mode and data requests can be approved or declined with notification delivery.
- [ ] CSV and QR-sheet exports generate real data and never leak online links.
- [ ] Audit search filters by actor, action, entity, and date.
- [ ] Settings validation rejects unknown keys and invalid types.
- [ ] Housekeeping deletes only expired records and leaves retention-controlled rows intact.

## PWA and accessibility

- [ ] The manifest loads with the correct name, theme, icons, and shortcuts.
- [ ] The service worker precaches the app shell and serves the offline page when navigation fails.
- [ ] `sw.js` is not cached stale by Vercel.
- [ ] Every page has a working navigation shell, focusable controls, labels, and a visible keyboard focus state.
- [ ] Login, reset, activation, room, bookings, lectures, notifications, settings, admin, and display pages render on phone and desktop widths.
- [ ] The display page renders kiosk-safe dark mode and recovers from temporary network loss.

## Deployment

- [ ] Render starts with `npm ci --omit=dev` and passes `/health`.
- [ ] Vercel serves the frontend over HTTPS and the API proxy or API base points at Render.
- [ ] `FRONTEND_URL` matches the deployed Vercel origin and QR links open the deployed room page.
- [ ] GitHub secrets `RENDER_API_URL` and `CRON_SECRET` are set.
- [ ] Manual dispatch of `cron.yml` succeeds for reminders, no-show release, and queue processing.
- [ ] Manual dispatch of `housekeeping.yml` succeeds.
- [ ] A test account can complete login, booking, check-in, join, and notification flows end to end.
- [ ] Demo credentials and default secrets have been rotated before production use.
