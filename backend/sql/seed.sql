-- Demo seed for the Campus Navigation and Facility Booking App.
-- Safe to re-run: fixed ids plus ON CONFLICT DO NOTHING. Demo passwords are intentionally public.
-- Demo password: Campus#2026 (super admin: ChangeMe#2026). Demo PIN for all users: 246810.

BEGIN;

INSERT INTO departments (id, code, name) VALUES
  ('d1000000-0000-4000-8000-000000000001', 'CSC', 'Computer Science'),
  ('d1000000-0000-4000-8000-000000000002', 'ENG', 'Engineering'),
  ('d1000000-0000-4000-8000-000000000003', 'BIZ', 'Business')
ON CONFLICT (id) DO NOTHING;

INSERT INTO programmes (id, department_id, code, name, duration_years) VALUES
  ('a1000000-0000-4000-8000-000000000001', 'd1000000-0000-4000-8000-000000000001', 'BSE', 'Bachelor of Software Engineering', 4),
  ('a1000000-0000-4000-8000-000000000002', 'd1000000-0000-4000-8000-000000000001', 'BCS', 'Bachelor of Computer Science', 3),
  ('a1000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000003', 'BBA', 'Bachelor of Business Administration', 3)
ON CONFLICT (id) DO NOTHING;

UPDATE semesters SET is_current = false WHERE is_current = true;

INSERT INTO semesters (id, name, start_date, end_date, is_current) VALUES
  ('e1000000-0000-4000-8000-000000000001', 'Current Semester (seed)', current_date - 60, current_date + 60, true),
  ('e1000000-0000-4000-8000-000000000002', 'Previous Semester (seed)', current_date - 220, current_date - 90, false)
ON CONFLICT (id) DO UPDATE SET
  start_date = EXCLUDED.start_date,
  end_date = EXCLUDED.end_date,
  is_current = EXCLUDED.is_current;

INSERT INTO classes (id, programme_id, department_id, code, name, year_of_study, intake, stream, default_study_mode) VALUES
  ('c1000000-0000-4000-8000-000000000001', 'a1000000-0000-4000-8000-000000000001', 'd1000000-0000-4000-8000-000000000001', 'BSE-2-DAY', 'BSE Year 2 - Day', 2, '2025', 'Day', 'physical'),
  ('c1000000-0000-4000-8000-000000000002', 'a1000000-0000-4000-8000-000000000002', 'd1000000-0000-4000-8000-000000000001', 'BCS-1-ONLINE', 'BCS Year 1 - Online', 1, '2026', 'Online', 'online'),
  ('c1000000-0000-4000-8000-000000000003', 'a1000000-0000-4000-8000-000000000003', 'd1000000-0000-4000-8000-000000000003', 'BBA-1-DAY', 'BBA Year 1 - Day', 1, '2026', 'Day', 'physical')
ON CONFLICT (id) DO NOTHING;

INSERT INTO users
  (id, id_number, name, email, phone, password_hash, pin_hash, role, department_id, class_id, study_mode,
   qr_token_hash, qr_handle, qr_secret, email_verified_at, consent_at, last_verified_at)
VALUES
  ('f1000000-0000-4000-8000-000000000001', 'SUPER001', 'Super Admin', 'super@campus.ac.ug', '+256700000001',
    crypt('ChangeMe#2026', gen_salt('bf', 10)), crypt('246810', gen_salt('bf', 10)), 'super_admin', NULL, NULL, 'physical',
    encode(digest('SAq7Xk2mP9vL4tR8wY1nZ6bC', 'sha256'), 'hex'), 'h-super-001', 'JBSWY3DPEHPK3PXPJBSWY3DPEHPK3PXP', now(), now(), now()),
  ('f1000000-0000-4000-8000-000000000002', 'ADM001', 'CS Department Admin', 'csadmin@campus.ac.ug', '+256700000002',
    crypt('Campus#2026', gen_salt('bf', 10)), crypt('246810', gen_salt('bf', 10)), 'department_admin', 'd1000000-0000-4000-8000-000000000001', NULL, 'physical',
    encode(digest('ADm3Kp8sV2xN7qL5wR9tY4cD', 'sha256'), 'hex'), 'h-admin-001', 'KRSXG5CTMVRXEZLUKRSXG5CTMVRXEZLU', now(), now(), now()),
  ('f1000000-0000-4000-8000-000000000003', 'LEC001', 'Dr. Sarah Nabwire', 'lecturer@campus.ac.ug', '+256700000003',
    crypt('Campus#2026', gen_salt('bf', 10)), crypt('246810', gen_salt('bf', 10)), 'lecturer', 'd1000000-0000-4000-8000-000000000001', NULL, 'physical',
    encode(digest('LEc6Tq1vB8nM3xP7rK2wY9sF', 'sha256'), 'hex'), 'h-lec-001', 'MFRGGZDFMZTWQ2LKMFRGGZDFMZTWQ2LK', now(), now(), now()),
  ('f1000000-0000-4000-8000-000000000004', 'LEC002', 'Mr. Daniel Okello', 'lecturer2@campus.ac.ug', '+256700000004',
    crypt('Campus#2026', gen_salt('bf', 10)), crypt('246810', gen_salt('bf', 10)), 'lecturer', 'd1000000-0000-4000-8000-000000000001', NULL, 'physical',
    encode(digest('LEc9Wp4zH6nJ2vR5tM8qK1xB', 'sha256'), 'hex'), 'h-lec-002', 'NBSWY3DPEB3W64TMMQWK2ZDFNBSWY3DP', now(), now(), now()),
  ('f1000000-0000-4000-8000-000000000005', 'REP001', 'Alice Nakato', 'rep@campus.ac.ug', '+256700000005',
    crypt('Campus#2026', gen_salt('bf', 10)), crypt('246810', gen_salt('bf', 10)), 'class_rep', 'd1000000-0000-4000-8000-000000000001', 'c1000000-0000-4000-8000-000000000001', 'physical',
    encode(digest('REp2Nv7kL9xQ4tW6yB1mR8cZ', 'sha256'), 'hex'), 'h-rep-001', 'ONSWG4TFOQZWK5DFONSWG4TFOQZWK5DF', now(), now(), now()),
  ('f1000000-0000-4000-8000-000000000006', 'DEP001', 'Brian Kasule', 'deputy@campus.ac.ug', '+256700000006',
    crypt('Campus#2026', gen_salt('bf', 10)), crypt('246810', gen_salt('bf', 10)), 'deputy_rep', 'd1000000-0000-4000-8000-000000000001', 'c1000000-0000-4000-8000-000000000001', 'physical',
    encode(digest('DEp5Mx8qT3vK7nR2wL9yB4cF', 'sha256'), 'hex'), 'h-dep-001', 'PFSXGZLSOJUXGZLSOJUXGZLSOJUXGZLS', now(), now(), now()),
  ('f1000000-0000-4000-8000-000000000007', 'STU001', 'Grace Auma', 'student.physical@campus.ac.ug', '+256700000007',
    crypt('Campus#2026', gen_salt('bf', 10)), crypt('246810', gen_salt('bf', 10)), 'student', 'd1000000-0000-4000-8000-000000000001', 'c1000000-0000-4000-8000-000000000001', 'physical',
    encode(digest('STu3Kq9mN5vX7tR2wY8pL1bC', 'sha256'), 'hex'), 'h-stu-001', 'QFSXGZLSOJUXGZLSOJUXGZLSOJUXGZLS', now(), now(), now()),
  ('f1000000-0000-4000-8000-000000000008', 'STU002', 'Peter Ssemakula', 'student.online@campus.ac.ug', '+256700000008',
    crypt('Campus#2026', gen_salt('bf', 10)), crypt('246810', gen_salt('bf', 10)), 'student', 'd1000000-0000-4000-8000-000000000001', 'c1000000-0000-4000-8000-000000000001', 'online',
    encode(digest('STu6Pm2nW8xR4tK9yB3qL7vD', 'sha256'), 'hex'), 'h-stu-002', 'RFSXGZLSOJUXGZLSOJUXGZLSOJUXGZLS', now(), now(), now()),
  ('f1000000-0000-4000-8000-000000000009', 'STU003', 'Joan Nansubuga', 'student.hybrid@campus.ac.ug', '+256700000009',
    crypt('Campus#2026', gen_salt('bf', 10)), crypt('246810', gen_salt('bf', 10)), 'student', 'd1000000-0000-4000-8000-000000000001', 'c1000000-0000-4000-8000-000000000001', 'hybrid',
    encode(digest('STu1Qw5vN9mK3xT7rL2pY8bF', 'sha256'), 'hex'), 'h-stu-003', 'SFSXGZLSOJUXGZLSOJUXGZLSOJUXGZLS', now(), now(), now())
ON CONFLICT (id) DO NOTHING;

INSERT INTO modules (id, code, name, department_id, lecturer_id) VALUES
  ('91000000-0000-4000-8000-000000000001', 'CSC2101', 'Databases', 'd1000000-0000-4000-8000-000000000001', 'f1000000-0000-4000-8000-000000000003'),
  ('91000000-0000-4000-8000-000000000002', 'CSC2201', 'Web Development', 'd1000000-0000-4000-8000-000000000001', 'f1000000-0000-4000-8000-000000000004'),
  ('91000000-0000-4000-8000-000000000003', 'CSC1101', 'Introduction to Programming', 'd1000000-0000-4000-8000-000000000001', 'f1000000-0000-4000-8000-000000000003'),
  ('91000000-0000-4000-8000-000000000004', 'BBA1101', 'Principles of Management', 'd1000000-0000-4000-8000-000000000003', NULL)
ON CONFLICT (id) DO NOTHING;

INSERT INTO class_modules (class_id, module_id, semester_id) VALUES
  ('c1000000-0000-4000-8000-000000000001', '91000000-0000-4000-8000-000000000001', 'e1000000-0000-4000-8000-000000000001'),
  ('c1000000-0000-4000-8000-000000000001', '91000000-0000-4000-8000-000000000002', 'e1000000-0000-4000-8000-000000000001'),
  ('c1000000-0000-4000-8000-000000000002', '91000000-0000-4000-8000-000000000003', 'e1000000-0000-4000-8000-000000000001'),
  ('c1000000-0000-4000-8000-000000000003', '91000000-0000-4000-8000-000000000004', 'e1000000-0000-4000-8000-000000000001')
ON CONFLICT DO NOTHING;

INSERT INTO enrolments (user_id, module_id, semester_id, delivery_mode_override) VALUES
  ('f1000000-0000-4000-8000-000000000005', '91000000-0000-4000-8000-000000000001', 'e1000000-0000-4000-8000-000000000001', NULL),
  ('f1000000-0000-4000-8000-000000000006', '91000000-0000-4000-8000-000000000001', 'e1000000-0000-4000-8000-000000000001', NULL),
  ('f1000000-0000-4000-8000-000000000007', '91000000-0000-4000-8000-000000000001', 'e1000000-0000-4000-8000-000000000001', NULL),
  ('f1000000-0000-4000-8000-000000000008', '91000000-0000-4000-8000-000000000001', 'e1000000-0000-4000-8000-000000000001', NULL),
  ('f1000000-0000-4000-8000-000000000009', '91000000-0000-4000-8000-000000000001', 'e1000000-0000-4000-8000-000000000001', NULL),
  ('f1000000-0000-4000-8000-000000000005', '91000000-0000-4000-8000-000000000002', 'e1000000-0000-4000-8000-000000000001', NULL),
  ('f1000000-0000-4000-8000-000000000006', '91000000-0000-4000-8000-000000000002', 'e1000000-0000-4000-8000-000000000001', NULL),
  ('f1000000-0000-4000-8000-000000000007', '91000000-0000-4000-8000-000000000002', 'e1000000-0000-4000-8000-000000000001', NULL),
  ('f1000000-0000-4000-8000-000000000008', '91000000-0000-4000-8000-000000000002', 'e1000000-0000-4000-8000-000000000001', 'physical'),
  ('f1000000-0000-4000-8000-000000000009', '91000000-0000-4000-8000-000000000002', 'e1000000-0000-4000-8000-000000000001', NULL)
ON CONFLICT DO NOTHING;

INSERT INTO class_reps (user_id, class_id, semester_id, is_deputy, is_active, is_available, assigned_by) VALUES
  ('f1000000-0000-4000-8000-000000000005', 'c1000000-0000-4000-8000-000000000001', 'e1000000-0000-4000-8000-000000000001', false, true, true, 'f1000000-0000-4000-8000-000000000002'),
  ('f1000000-0000-4000-8000-000000000006', 'c1000000-0000-4000-8000-000000000001', 'e1000000-0000-4000-8000-000000000001', true, true, true, 'f1000000-0000-4000-8000-000000000002')
ON CONFLICT DO NOTHING;

INSERT INTO facilities
  (id, name, category, department_id, building, floor, wing, room_number, location_description,
   latitude, longitude, capacity, status, requires_approval, requires_authorized_role,
   last_verified_at, checkin_mode, checkin_radius_m, qr_secret, qr_version, photo_url)
VALUES
  ('b2000000-0000-4000-8000-000000000001', 'Lecture Hall 3', 'lecture_room', 'd1000000-0000-4000-8000-000000000001',
   'Block B', '2', 'East', 'B-201', 'Enter Block B through the main glass doors, take the stairs on the right to Floor 2, turn left at the notice board and follow the corridor to the double doors marked B-201.',
   0.334600, 32.570100, 120, 'active', false, true, now(), 'rotating', 100,
   'f1e2d3c4b5a697887766554433221100', 1, NULL),
  ('b2000000-0000-4000-8000-000000000002', 'Computer Lab 1', 'lab', 'd1000000-0000-4000-8000-000000000001',
   'Block C', '1', 'West', 'C-101', 'From Block C reception walk past the help desk, turn right after the printer room; Lab 1 is the first room with a blue door.',
   0.334800, 32.569700, 40, 'active', false, false, now(), 'static_geo', 100,
   'a1b2c3d4e5f60718293a4b5c6d7e8f90', 1, NULL),
  ('b2000000-0000-4000-8000-000000000003', 'Discussion Room A', 'discussion_room', 'd1000000-0000-4000-8000-000000000001',
   'Block A', '1', 'North', 'A-105', 'Enter Block A, ignore the first corridor, continue to the north wing; A-105 is beside the water dispenser.',
   0.334300, 32.570400, 8, 'active', false, false, now(), 'static_geo', 100,
   '11223344556677889900aabbccddeeff', 1, NULL),
  ('b2000000-0000-4000-8000-000000000004', 'Library Quiet Room', 'library', 'd1000000-0000-4000-8000-000000000001',
   'Main Library', '3', NULL, 'L-301', 'Take the library lift to Floor 3, turn right past the journals, the quiet room is at the end of the reading hall.',
   0.334100, 32.569900, 30, 'active', false, false, now(), 'static_geo', 120,
   'ffeeddccbbaa00998877665544332211', 1, NULL),
  ('b2000000-0000-4000-8000-000000000005', 'CS Department Office', 'office', 'd1000000-0000-4000-8000-000000000001',
   'Block B', '1', 'East', 'B-104', 'Enter Block B and turn immediately right; B-104 is opposite the departmental notice board.',
   0.334500, 32.570000, 5, 'active', false, false, now(), 'static_geo', 50,
   '00112233445566778899aabbccddeeff', 1, NULL),
  ('b2000000-0000-4000-8000-000000000006', 'Engineering Lecture Theatre', 'lecture_room', 'd1000000-0000-4000-8000-000000000002',
   'Block D', '1', NULL, 'D-001', 'Enter Block D from the engineering car park, the lecture theatre is straight ahead behind the glass foyer.',
   0.335200, 32.571000, 80, 'active', true, true, now(), 'rotating', 100,
   '99887766554433221100ffeeddccbbaa', 1, NULL)
ON CONFLICT (id) DO NOTHING;

INSERT INTO facility_equipment (facility_id, name, quantity) VALUES
  ('b2000000-0000-4000-8000-000000000001', 'projector', 1),
  ('b2000000-0000-4000-8000-000000000001', 'whiteboard', 1),
  ('b2000000-0000-4000-8000-000000000001', 'sockets', 20),
  ('b2000000-0000-4000-8000-000000000001', 'air_conditioning', 1),
  ('b2000000-0000-4000-8000-000000000002', 'pcs', 40),
  ('b2000000-0000-4000-8000-000000000002', 'projector', 1),
  ('b2000000-0000-4000-8000-000000000002', 'whiteboard', 1),
  ('b2000000-0000-4000-8000-000000000002', 'air_conditioning', 1),
  ('b2000000-0000-4000-8000-000000000003', 'whiteboard', 1),
  ('b2000000-0000-4000-8000-000000000003', 'sockets', 8),
  ('b2000000-0000-4000-8000-000000000006', 'projector', 1),
  ('b2000000-0000-4000-8000-000000000006', 'accessibility', 1)
ON CONFLICT DO NOTHING;

INSERT INTO display_devices (facility_id, key_hash, label, created_by) VALUES
  ('b2000000-0000-4000-8000-000000000001',
   encode(digest('display-key-hall3-2026-9f5a7c1e3b8d2a6f', 'sha256'), 'hex'),
   'Lecture Hall 3 door tablet', 'f1000000-0000-4000-8000-000000000001')
ON CONFLICT DO NOTHING;

INSERT INTO bookings
  (id, session_id, user_id, facility_id, module_id, lecturer_id, session_mode, online_platform, online_link,
   start_at, end_at, status, priority, source, entry_point, purpose, booked_by_role, is_locked)
VALUES
  ('b3000000-0000-4000-8000-000000000001', 'b3000000-0000-4000-8000-000000000001',
   'f1000000-0000-4000-8000-000000000005', 'b2000000-0000-4000-8000-000000000001', '91000000-0000-4000-8000-000000000001',
   'f1000000-0000-4000-8000-000000000003', 'physical', NULL, NULL,
   (current_date + 2 + time '10:00') AT TIME ZONE 'Africa/Kampala',
   (current_date + 2 + time '12:00') AT TIME ZONE 'Africa/Kampala',
   'confirmed', 50, 'manual', 'app', 'Seeded Databases lecture', 'class_rep', false),
  ('b3000000-0000-4000-8000-000000000002', 'b3000000-0000-4000-8000-000000000002',
   'f1000000-0000-4000-8000-000000000003', NULL, '91000000-0000-4000-8000-000000000001',
   'f1000000-0000-4000-8000-000000000003', 'online', 'google_meet', 'https://meet.google.com/seed-databases-online',
   (current_date + 3 + time '14:00') AT TIME ZONE 'Africa/Kampala',
   (current_date + 3 + time '16:00') AT TIME ZONE 'Africa/Kampala',
   'confirmed', 70, 'manual', 'app', 'Seeded online Databases lecture', 'lecturer', false),
  ('b3000000-0000-4000-8000-000000000003', 'b3000000-0000-4000-8000-000000000003',
   'f1000000-0000-4000-8000-000000000004', 'b2000000-0000-4000-8000-000000000001', '91000000-0000-4000-8000-000000000002',
   'f1000000-0000-4000-8000-000000000004', 'hybrid', 'zoom', 'https://zoom.us/j/1234567890',
   (current_date + 4 + time '09:00') AT TIME ZONE 'Africa/Kampala',
   (current_date + 4 + time '11:00') AT TIME ZONE 'Africa/Kampala',
   'confirmed', 70, 'manual', 'app', 'Seeded hybrid Web Development lecture', 'lecturer', false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO settings (key, value) VALUES
  ('max_booking_hours_per_day', '4'::jsonb),
  ('max_booking_hours_per_week', '12'::jsonb),
  ('max_advance_booking_days', '30'::jsonb),
  ('max_booking_duration_minutes', '240'::jsonb),
  ('min_notice_minutes', '15'::jsonb),
  ('no_show_suspension_threshold', '3'::jsonb),
  ('no_show_suspension_days', '7'::jsonb),
  ('no_show_lookback_days', '30'::jsonb),
  ('cancellation_cutoff_minutes', '0'::jsonb),
  ('no_show_grace_minutes', '15'::jsonb),
  ('checkin_open_minutes', '10'::jsonb),
  ('max_checkin_accuracy_m', '150'::jsonb),
  ('reminder_1_minutes', '60'::jsonb),
  ('reminder_2_minutes', '10'::jsonb),
  ('enable_10min_reminder', 'true'::jsonb),
  ('allow_join_recording', 'true'::jsonb),
  ('notify_online_students_physical', 'true'::jsonb),
  ('allowed_meeting_domains', '["zoom.us","meet.google.com","teams.microsoft.com"]'::jsonb),
  ('default_checkin_radius_m', '100'::jsonb),
  ('rotating_qr_required_roles', '["lecturer","class_rep","deputy_rep"]'::jsonb),
  ('join_retention_days', '365'::jsonb),
  ('delivery_log_retention_days', '365'::jsonb),
  ('otp_retention_days', '7'::jsonb),
  ('graduated_anonymize_days', '0'::jsonb),
  ('app_name', '"Campus Navigation and Facility Booking"'::jsonb),
  ('timetable_no_show_exempt', 'true'::jsonb),
  ('lecturer_no_show_exempt', 'false'::jsonb),
  ('lecture_room_no_show_exempt', 'false'::jsonb),
  ('email_provider', '"resend"'::jsonb)
ON CONFLICT (key) DO NOTHING;

INSERT INTO notifications (user_id, type, title, message, severity)
SELECT u.id, 'account', 'Welcome to Campus Navigation',
       'Your account is ready. Open My lectures to see how your modules will be delivered.',
       'info'
FROM users u
WHERE NOT EXISTS (
  SELECT 1 FROM notifications n
  WHERE n.user_id = u.id AND n.type = 'account' AND n.title = 'Welcome to Campus Navigation'
);

COMMIT;
