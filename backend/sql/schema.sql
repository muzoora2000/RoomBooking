-- Campus Navigation and Facility Booking App
-- PostgreSQL 15+ / Neon schema. All timestamps are TIMESTAMPTZ and are stored in UTC.
-- Run through `npm run migrate` (psql is not required).

BEGIN;

CREATE EXTENSION IF NOT EXISTS btree_gist;
CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TABLE IF NOT EXISTS departments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL UNIQUE,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS programmes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  department_id uuid NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,
  code text NOT NULL,
  name text NOT NULL,
  duration_years integer NOT NULL DEFAULT 3 CHECK (duration_years BETWEEN 1 AND 8),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (department_id, code)
);

CREATE TABLE IF NOT EXISTS semesters (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL UNIQUE,
  start_date date NOT NULL,
  end_date date NOT NULL,
  is_current boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (end_date > start_date)
);

CREATE UNIQUE INDEX IF NOT EXISTS semesters_one_current_idx
  ON semesters ((is_current)) WHERE is_current;

CREATE TABLE IF NOT EXISTS classes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  programme_id uuid NOT NULL REFERENCES programmes(id) ON DELETE RESTRICT,
  department_id uuid NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,
  name text NOT NULL,
  year_of_study integer NOT NULL CHECK (year_of_study BETWEEN 1 AND 8),
  intake text NOT NULL DEFAULT 'Main',
  stream text NOT NULL DEFAULT 'Day',
  default_study_mode text NOT NULL DEFAULT 'physical'
    CHECK (default_study_mode IN ('physical','online','hybrid')),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (programme_id, name, intake, stream)
);

CREATE TABLE IF NOT EXISTS users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  id_number text NOT NULL UNIQUE,
  name text NOT NULL,
  email text NOT NULL,
  phone text,
  password_hash text,
  pin_hash text,
  role text NOT NULL DEFAULT 'student'
    CHECK (role IN ('student','class_rep','deputy_rep','lecturer','department_admin','super_admin')),
  department_id uuid REFERENCES departments(id) ON DELETE SET NULL,
  class_id uuid REFERENCES classes(id) ON DELETE SET NULL,
  study_mode text NOT NULL DEFAULT 'physical'
    CHECK (study_mode IN ('physical','online','hybrid')),
  qr_token_hash text NOT NULL UNIQUE,
  qr_handle text NOT NULL UNIQUE,
  qr_secret text NOT NULL,
  qr_active boolean NOT NULL DEFAULT true,
  is_active boolean NOT NULL DEFAULT true,
  email_verified_at timestamptz,
  consent_at timestamptz,
  locked_until timestamptz,
  failed_attempts integer NOT NULL DEFAULT 0 CHECK (failed_attempts >= 0),
  last_verified_at timestamptz,
  sms_link_opt_in boolean NOT NULL DEFAULT false,
  flagged_for_review boolean NOT NULL DEFAULT false,
  flagged_reason text,
  anonymized_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS users_email_lower_idx ON users (lower(email));
CREATE INDEX IF NOT EXISTS users_class_idx ON users (class_id);
CREATE INDEX IF NOT EXISTS users_department_idx ON users (department_id);
CREATE INDEX IF NOT EXISTS users_role_idx ON users (role);

DROP TRIGGER IF EXISTS users_set_updated_at ON users;
CREATE TRIGGER users_set_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS modules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  department_id uuid NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,
  lecturer_id uuid REFERENCES users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS class_modules (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  class_id uuid NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  module_id uuid NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  semester_id uuid NOT NULL REFERENCES semesters(id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (class_id, module_id, semester_id)
);

CREATE TABLE IF NOT EXISTS enrolments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  module_id uuid NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  semester_id uuid NOT NULL REFERENCES semesters(id) ON DELETE CASCADE,
  delivery_mode_override text
    CHECK (delivery_mode_override IS NULL OR delivery_mode_override IN ('physical','online','hybrid')),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, module_id, semester_id)
);

CREATE INDEX IF NOT EXISTS enrolments_module_semester_idx ON enrolments (module_id, semester_id);
CREATE INDEX IF NOT EXISTS enrolments_user_idx ON enrolments (user_id);

CREATE TABLE IF NOT EXISTS class_reps (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  class_id uuid NOT NULL REFERENCES classes(id) ON DELETE CASCADE,
  semester_id uuid NOT NULL REFERENCES semesters(id) ON DELETE CASCADE,
  is_deputy boolean NOT NULL DEFAULT false,
  is_active boolean NOT NULL DEFAULT true,
  is_available boolean NOT NULL DEFAULT true,
  assigned_by uuid REFERENCES users(id) ON DELETE SET NULL,
  assigned_at timestamptz NOT NULL DEFAULT now(),
  revoked_at timestamptz
);

CREATE UNIQUE INDEX IF NOT EXISTS class_reps_one_active_role_idx
  ON class_reps (class_id, semester_id, is_deputy) WHERE is_active;
CREATE INDEX IF NOT EXISTS class_reps_user_idx ON class_reps (user_id);

CREATE TABLE IF NOT EXISTS delegations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  module_id uuid NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  from_user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  to_user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  starts_at timestamptz NOT NULL,
  ends_at timestamptz NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  revoked_at timestamptz,
  CHECK (ends_at > starts_at),
  CHECK (from_user_id <> to_user_id)
);

CREATE INDEX IF NOT EXISTS delegations_to_idx ON delegations (to_user_id, module_id);

CREATE TABLE IF NOT EXISTS facilities (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  category text NOT NULL
    CHECK (category IN ('lecture_room','discussion_room','lab','office','library')),
  department_id uuid NOT NULL REFERENCES departments(id) ON DELETE RESTRICT,
  building text NOT NULL,
  floor text NOT NULL DEFAULT 'Ground',
  wing text,
  room_number text NOT NULL,
  location_description text NOT NULL DEFAULT '',
  latitude double precision NOT NULL CHECK (latitude BETWEEN -90 AND 90),
  longitude double precision NOT NULL CHECK (longitude BETWEEN -180 AND 180),
  capacity integer NOT NULL CHECK (capacity > 0),
  status text NOT NULL DEFAULT 'active'
    CHECK (status IN ('active','blocked','maintenance')),
  requires_approval boolean NOT NULL DEFAULT false,
  requires_authorized_role boolean NOT NULL DEFAULT false,
  last_verified_at timestamptz,
  checkin_mode text NOT NULL DEFAULT 'static_geo'
    CHECK (checkin_mode IN ('rotating','static_geo')),
  checkin_radius_m integer NOT NULL DEFAULT 100 CHECK (checkin_radius_m BETWEEN 10 AND 5000),
  qr_secret text NOT NULL,
  qr_version integer NOT NULL DEFAULT 1 CHECK (qr_version > 0),
  qr_regenerated_at timestamptz NOT NULL DEFAULT now(),
  photo_url text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (building, room_number)
);

CREATE INDEX IF NOT EXISTS facilities_category_idx ON facilities (category);
CREATE INDEX IF NOT EXISTS facilities_department_idx ON facilities (department_id);
CREATE INDEX IF NOT EXISTS facilities_status_idx ON facilities (status);

DROP TRIGGER IF EXISTS facilities_set_updated_at ON facilities;
CREATE TRIGGER facilities_set_updated_at BEFORE UPDATE ON facilities
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS facility_equipment (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  facility_id uuid NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
  name text NOT NULL,
  quantity integer NOT NULL DEFAULT 1 CHECK (quantity >= 0),
  UNIQUE (facility_id, name)
);

CREATE INDEX IF NOT EXISTS facility_equipment_name_idx ON facility_equipment (name);

CREATE TABLE IF NOT EXISTS display_devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  facility_id uuid NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
  key_hash text NOT NULL,
  label text NOT NULL,
  created_by uuid REFERENCES users(id) ON DELETE SET NULL,
  last_seen_at timestamptz,
  revoked_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS display_devices_facility_idx ON display_devices (facility_id);

CREATE TABLE IF NOT EXISTS room_issues (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  facility_id uuid NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
  reported_by uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  category text NOT NULL
    CHECK (category IN ('projector','power','cleanliness','furniture','wrong_details','other')),
  description text NOT NULL,
  photo_data text CHECK (photo_data IS NULL OR octet_length(photo_data) <= 1048576),
  status text NOT NULL DEFAULT 'open'
    CHECK (status IN ('open','acknowledged','resolved')),
  acknowledged_by uuid REFERENCES users(id) ON DELETE SET NULL,
  acknowledged_at timestamptz,
  resolved_by uuid REFERENCES users(id) ON DELETE SET NULL,
  resolved_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS room_issues_status_idx ON room_issues (status);

CREATE TABLE IF NOT EXISTS auth_sessions (
  id uuid PRIMARY KEY,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id_hash text,
  ip text,
  user_agent text,
  created_at timestamptz NOT NULL DEFAULT now(),
  last_seen_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz NOT NULL,
  revoked_at timestamptz,
  revoked_reason text
);

CREATE INDEX IF NOT EXISTS auth_sessions_user_idx ON auth_sessions (user_id);

CREATE TABLE IF NOT EXISTS trusted_devices (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  device_id_hash text NOT NULL,
  label text NOT NULL DEFAULT 'Unknown device',
  user_agent text,
  first_seen_at timestamptz NOT NULL DEFAULT now(),
  last_used_at timestamptz NOT NULL DEFAULT now(),
  trusted_until timestamptz,
  revoked_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS trusted_devices_active_unique_idx
  ON trusted_devices (user_id, device_id_hash) WHERE revoked_at IS NULL;
CREATE INDEX IF NOT EXISTS trusted_devices_device_idx ON trusted_devices (device_id_hash, user_id);

CREATE TABLE IF NOT EXISTS otp_codes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  code_hash text NOT NULL,
  purpose text NOT NULL CHECK (purpose IN ('login','step_up','device')),
  channel text NOT NULL DEFAULT 'email' CHECK (channel IN ('email','sms')),
  expires_at timestamptz NOT NULL,
  attempts integer NOT NULL DEFAULT 0,
  max_attempts integer NOT NULL DEFAULT 5,
  consumed_at timestamptz,
  ip text,
  meta jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS otp_codes_user_purpose_idx ON otp_codes (user_id, purpose, created_at DESC);

CREATE TABLE IF NOT EXISTS user_activation_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash text NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  used_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash text NOT NULL UNIQUE,
  expires_at timestamptz NOT NULL,
  used_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS study_mode_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  requested_mode text NOT NULL CHECK (requested_mode IN ('physical','online','hybrid')),
  reason text NOT NULL,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','approved','rejected')),
  decided_by uuid REFERENCES users(id) ON DELETE SET NULL,
  decided_at timestamptz,
  decision_note text,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS study_mode_requests_status_idx ON study_mode_requests (status);

CREATE TABLE IF NOT EXISTS bookings (
  id uuid PRIMARY KEY,
  session_id uuid NOT NULL UNIQUE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  facility_id uuid REFERENCES facilities(id) ON DELETE RESTRICT,
  module_id uuid REFERENCES modules(id) ON DELETE SET NULL,
  lecturer_id uuid REFERENCES users(id) ON DELETE SET NULL,
  session_mode text NOT NULL DEFAULT 'physical'
    CHECK (session_mode IN ('physical','online','hybrid')),
  online_platform text
    CHECK (online_platform IS NULL OR online_platform IN ('zoom','google_meet','teams','other')),
  online_link text,
  meeting_passcode text,
  start_at timestamptz NOT NULL,
  end_at timestamptz NOT NULL,
  status text NOT NULL DEFAULT 'confirmed'
    CHECK (status IN ('pending','confirmed','rejected','cancelled','released','completed')),
  priority smallint NOT NULL DEFAULT 30 CHECK (priority BETWEEN 0 AND 100),
  source text NOT NULL DEFAULT 'manual' CHECK (source IN ('manual','timetable','exam')),
  entry_point text NOT NULL DEFAULT 'app' CHECK (entry_point IN ('app','room_qr')),
  purpose text,
  recurrence_group_id uuid,
  booked_by_role text NOT NULL,
  is_locked boolean NOT NULL DEFAULT false,
  checked_in_at timestamptz,
  checkin_method text CHECK (checkin_method IS NULL OR checkin_method IN ('rotating','static_geo','admin')),
  released_at timestamptz,
  release_reason text,
  converted_to_online_at timestamptz,
  reminder_1h_sent boolean NOT NULL DEFAULT false,
  reminder_10m_sent boolean NOT NULL DEFAULT false,
  displacement_reason text,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CHECK (end_at > start_at),
  CHECK (online_link IS NULL OR online_link LIKE 'https://%'),
  CHECK (
    (session_mode = 'online' AND facility_id IS NULL AND online_link IS NOT NULL AND online_platform IS NOT NULL)
    OR (session_mode = 'physical' AND facility_id IS NOT NULL AND online_link IS NULL AND online_platform IS NULL)
    OR (session_mode = 'hybrid' AND facility_id IS NOT NULL AND online_link IS NOT NULL AND online_platform IS NOT NULL)
  ),
  CONSTRAINT bookings_no_facility_overlap EXCLUDE USING gist (
    facility_id WITH =,
    tstzrange(start_at, end_at, '[)') WITH &&
  ) WHERE (facility_id IS NOT NULL AND status IN ('pending','confirmed')),
  CONSTRAINT bookings_no_lecturer_overlap EXCLUDE USING gist (
    lecturer_id WITH =,
    tstzrange(start_at, end_at, '[)') WITH &&
  ) WHERE (lecturer_id IS NOT NULL AND status IN ('pending','confirmed'))
);

CREATE INDEX IF NOT EXISTS bookings_facility_start_idx ON bookings (facility_id, start_at);
CREATE INDEX IF NOT EXISTS bookings_lecturer_start_idx ON bookings (lecturer_id, start_at);
CREATE INDEX IF NOT EXISTS bookings_user_idx ON bookings (user_id);
CREATE INDEX IF NOT EXISTS bookings_module_idx ON bookings (module_id);
CREATE INDEX IF NOT EXISTS bookings_status_idx ON bookings (status);
CREATE INDEX IF NOT EXISTS bookings_start_idx ON bookings (start_at);
CREATE INDEX IF NOT EXISTS bookings_recurrence_idx ON bookings (recurrence_group_id);

DROP TRIGGER IF EXISTS bookings_set_updated_at ON bookings;
CREATE TRIGGER bookings_set_updated_at BEFORE UPDATE ON bookings
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE IF NOT EXISTS session_joins (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  clicked_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (booking_id, user_id)
);

CREATE INDEX IF NOT EXISTS session_joins_booking_idx ON session_joins (booking_id);

CREATE TABLE IF NOT EXISTS timetable_slots (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  semester_id uuid NOT NULL REFERENCES semesters(id) ON DELETE CASCADE,
  class_id uuid REFERENCES classes(id) ON DELETE SET NULL,
  module_id uuid NOT NULL REFERENCES modules(id) ON DELETE CASCADE,
  lecturer_id uuid REFERENCES users(id) ON DELETE SET NULL,
  facility_id uuid REFERENCES facilities(id) ON DELETE SET NULL,
  booking_id uuid REFERENCES bookings(id) ON DELETE SET NULL,
  start_at timestamptz NOT NULL,
  end_at timestamptz NOT NULL,
  session_mode text NOT NULL CHECK (session_mode IN ('physical','online','hybrid')),
  online_platform text,
  online_link text,
  imported_by uuid REFERENCES users(id) ON DELETE SET NULL,
  imported_at timestamptz NOT NULL DEFAULT now(),
  CHECK (end_at > start_at)
);

CREATE INDEX IF NOT EXISTS timetable_slots_semester_idx ON timetable_slots (semester_id);

CREATE TABLE IF NOT EXISTS exam_blocks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  name text NOT NULL,
  department_id uuid REFERENCES departments(id) ON DELETE CASCADE,
  start_at timestamptz NOT NULL,
  end_at timestamptz NOT NULL,
  created_by uuid REFERENCES users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (end_at > start_at)
);

CREATE TABLE IF NOT EXISTS exam_block_facilities (
  exam_block_id uuid NOT NULL REFERENCES exam_blocks(id) ON DELETE CASCADE,
  facility_id uuid NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
  PRIMARY KEY (exam_block_id, facility_id)
);

CREATE TABLE IF NOT EXISTS facility_blocks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  facility_id uuid NOT NULL REFERENCES facilities(id) ON DELETE CASCADE,
  start_at timestamptz NOT NULL,
  end_at timestamptz NOT NULL,
  reason text NOT NULL,
  created_by uuid REFERENCES users(id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  CHECK (end_at > start_at)
);

CREATE INDEX IF NOT EXISTS facility_blocks_facility_idx ON facility_blocks (facility_id, start_at);

CREATE TABLE IF NOT EXISTS no_shows (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id uuid NOT NULL REFERENCES bookings(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  marked_at timestamptz NOT NULL DEFAULT now(),
  reason text NOT NULL DEFAULT 'No check-in within grace period'
);

CREATE UNIQUE INDEX IF NOT EXISTS no_shows_booking_idx ON no_shows (booking_id);
CREATE INDEX IF NOT EXISTS no_shows_user_idx ON no_shows (user_id, marked_at);

CREATE TABLE IF NOT EXISTS notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  booking_id uuid REFERENCES bookings(id) ON DELETE SET NULL,
  module_id uuid REFERENCES modules(id) ON DELETE SET NULL,
  type text NOT NULL,
  title text NOT NULL,
  message text NOT NULL,
  link text,
  severity text NOT NULL DEFAULT 'info' CHECK (severity IN ('info','warning','critical')),
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS notifications_user_idx ON notifications (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS notifications_unread_idx ON notifications (is_read, user_id);

CREATE TABLE IF NOT EXISTS notification_preferences (
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  event_type text NOT NULL,
  channel text NOT NULL CHECK (channel IN ('inapp','email','sms','push')),
  enabled boolean NOT NULL DEFAULT true,
  PRIMARY KEY (user_id, event_type, channel)
);

CREATE TABLE IF NOT EXISTS notification_queue (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  notification_id uuid NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  channel text NOT NULL CHECK (channel IN ('email','sms','push')),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','processing','sent','failed','skipped')),
  attempts integer NOT NULL DEFAULT 0,
  next_attempt_at timestamptz NOT NULL DEFAULT now(),
  last_error text,
  payload jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  processed_at timestamptz
);

CREATE INDEX IF NOT EXISTS notification_queue_pending_idx ON notification_queue (status, next_attempt_at);
CREATE INDEX IF NOT EXISTS notification_queue_user_idx ON notification_queue (user_id);

CREATE TABLE IF NOT EXISTS notification_deliveries (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  notification_id uuid NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  channel text NOT NULL CHECK (channel IN ('inapp','email','sms','push')),
  status text NOT NULL CHECK (status IN ('sent','failed','skipped')),
  provider_response text,
  error text,
  attempts integer NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS notification_deliveries_status_idx ON notification_deliveries (status, created_at DESC);

CREATE TABLE IF NOT EXISTS push_subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  endpoint text NOT NULL UNIQUE,
  p256dh text NOT NULL,
  auth text NOT NULL,
  user_agent text,
  created_at timestamptz NOT NULL DEFAULT now(),
  last_used_at timestamptz,
  revoked_at timestamptz
);

CREATE TABLE IF NOT EXISTS settings (
  key text PRIMARY KEY,
  value jsonb NOT NULL,
  updated_by uuid REFERENCES users(id) ON DELETE SET NULL,
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS audit_log (
  id bigserial PRIMARY KEY,
  user_id uuid REFERENCES users(id) ON DELETE SET NULL,
  action text NOT NULL,
  entity_type text,
  entity_id text,
  ip text,
  user_agent text,
  details jsonb NOT NULL DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS audit_log_user_idx ON audit_log (user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS audit_log_action_idx ON audit_log (action, created_at DESC);

CREATE TABLE IF NOT EXISTS data_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type text NOT NULL CHECK (type IN ('export','deletion')),
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','processing','completed','rejected')),
  requested_at timestamptz NOT NULL DEFAULT now(),
  processed_by uuid REFERENCES users(id) ON DELETE SET NULL,
  processed_at timestamptz,
  notes text
);

-- Idempotent column guards: add any columns that may be missing in existing deployments
-- (CREATE TABLE IF NOT EXISTS skips the body if the table already exists, so new columns
--  added after initial deployment must be patched with ALTER TABLE ADD COLUMN IF NOT EXISTS)
ALTER TABLE auth_sessions    ADD COLUMN IF NOT EXISTS last_seen_at  timestamptz NOT NULL DEFAULT now();
ALTER TABLE trusted_devices  ADD COLUMN IF NOT EXISTS first_seen_at timestamptz NOT NULL DEFAULT now();
ALTER TABLE trusted_devices  ADD COLUMN IF NOT EXISTS last_used_at  timestamptz NOT NULL DEFAULT now();
ALTER TABLE data_requests    ADD COLUMN IF NOT EXISTS requested_at  timestamptz NOT NULL DEFAULT now();

COMMIT;
