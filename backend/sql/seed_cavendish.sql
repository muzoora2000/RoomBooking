-- Cavendish University Uganda — Full Seed
-- 4 depts | 21 programmes | 51 classes | 31 lecturers | 335 modules | 29 facilities
-- Safe to re-run: ON CONFLICT DO UPDATE / DO NOTHING

BEGIN;

-- ── Extend modules table (idempotent) ────────────────────────────────────────
ALTER TABLE modules ADD COLUMN IF NOT EXISTS programme_id UUID;
ALTER TABLE modules ADD COLUMN IF NOT EXISTS credit_units INT DEFAULT 3;

-- ── Departments ───────────────────────────────────────────────────────────────
INSERT INTO departments(id,code,name) VALUES
  ('96178a5a-1a50-43ad-ace6-045b0e7dd47a','FST','Faculty of Science and Technology'),
  ('0d35fa69-de7f-4e05-b800-16c07321e75f','BUS','Faculty of Business'),
  ('422a6c15-127f-47d5-a044-e7547d35dcb6','SES','Faculty of Social and Environmental Studies'),
  ('06a806fc-0d90-4c27-877d-1025a3ebdbd1','HEC','Faculty of Health and Environmental Sciences')
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name;

-- ── Semester ──────────────────────────────────────────────────────────────────
INSERT INTO semesters(id,name,start_date,end_date,is_current) VALUES
  ('af9a8e4b-4808-4b3f-b9c3-905be5215722','Semester I 2026/2027','2026-08-01','2026-12-31',true)
ON CONFLICT(name) DO UPDATE SET is_current=true;

-- ── Programmes ────────────────────────────────────────────────────────────────
INSERT INTO programmes(id,department_id,code,name,duration_years) VALUES
  ('73593c0f-0478-45b5-a87d-a8e87f5ea274','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BIT','Bachelor of Science in Information Technology',3),
  ('16fe7428-a4af-4fb3-a543-b1e0fad14ed5','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BSE','Bachelor of Science in Software Engineering',3),
  ('ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BCS','Bachelor of Computer Science',3),
  ('ac00b024-3929-4702-9a14-b216830ab328','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DIT','Diploma in Information Technology',2),
  ('406f66f5-ea30-4071-9d85-d6029d0fcb05','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MIT','Master of Information Technology',2),
  ('ec2c1740-c4d5-4056-854f-50cf368c00ab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BDSA','Bachelor of Data Science and Analytics',3),
  ('88dfce47-1365-4820-be5c-669abfc2dd42','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DDSA','Diploma in Data Science and Analytics',2),
  ('46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA','Bachelor of Business Administration',3),
  ('41e287d8-9ca6-412e-9a3c-ed2e389036da','0d35fa69-de7f-4e05-b800-16c07321e75f','DBA','Diploma in Business Administration',2),
  ('7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA','Master of Business Administration',2),
  ('11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BJCS','Bachelor of Journalism and Communication Studies',3),
  ('22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BPAM','Bachelor of Public Administration and Management',3),
  ('33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BIRDS','Bachelor of International Relations and Diplomatic Studies',3),
  ('44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BEHS','Bachelor of Environmental Health Sciences',3),
  ('55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','BPH','Bachelor of Public Health',3),
  ('66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MPH','Master of Public Health',2),
  ('77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','ADHM','Advanced Diploma in Health Management',1),
  ('88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MSS','Master of Social Sciences',2),
  ('99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MEM','Master of Environmental Management',2),
  ('aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MPM','Master of Project Management',2),
  ('bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MIRDS','Master of International Relations and Diplomatic Studies',2)
ON CONFLICT(department_id,code) DO UPDATE SET name=EXCLUDED.name,duration_years=EXCLUDED.duration_years;

-- ── Classes (51 year-groups) ──────────────────────────────────────────────────
-- code pattern: <PROG>-<YEAR>-DAY  department_id from programme
INSERT INTO classes(id,programme_id,department_id,code,name,year_of_study) VALUES
  ('c1a55000-0001-4000-8000-000000000001','73593c0f-0478-45b5-a87d-a8e87f5ea274','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BIT-1-DAY','BIT Year 1',1),
  ('c1a55000-0001-4000-8000-000000000002','73593c0f-0478-45b5-a87d-a8e87f5ea274','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BIT-2-DAY','BIT Year 2',2),
  ('c1a55000-0001-4000-8000-000000000003','73593c0f-0478-45b5-a87d-a8e87f5ea274','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BIT-3-DAY','BIT Year 3',3),
  ('c1a55000-0001-4000-8000-000000000004','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BSE-1-DAY','BSE Year 1',1),
  ('c1a55000-0001-4000-8000-000000000005','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BSE-2-DAY','BSE Year 2',2),
  ('c1a55000-0001-4000-8000-000000000006','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BSE-3-DAY','BSE Year 3',3),
  ('c1a55000-0001-4000-8000-000000000007','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BCS-1-DAY','BCS Year 1',1),
  ('c1a55000-0001-4000-8000-000000000008','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BCS-2-DAY','BCS Year 2',2),
  ('c1a55000-0001-4000-8000-000000000009','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BCS-3-DAY','BCS Year 3',3),
  ('c1a55000-0001-4000-8000-000000000010','ac00b024-3929-4702-9a14-b216830ab328','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DIT-1-DAY','DIT Year 1',1),
  ('c1a55000-0001-4000-8000-000000000011','ac00b024-3929-4702-9a14-b216830ab328','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DIT-2-DAY','DIT Year 2',2),
  ('c1a55000-0001-4000-8000-000000000012','406f66f5-ea30-4071-9d85-d6029d0fcb05','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MIT-1-DAY','MIT Year 1',1),
  ('c1a55000-0001-4000-8000-000000000013','406f66f5-ea30-4071-9d85-d6029d0fcb05','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MIT-2-DAY','MIT Year 2',2),
  ('c1a55000-0001-4000-8000-000000000014','ec2c1740-c4d5-4056-854f-50cf368c00ab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BDSA-1-DAY','BDSA Year 1',1),
  ('c1a55000-0001-4000-8000-000000000015','ec2c1740-c4d5-4056-854f-50cf368c00ab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BDSA-2-DAY','BDSA Year 2',2),
  ('c1a55000-0001-4000-8000-000000000016','ec2c1740-c4d5-4056-854f-50cf368c00ab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BDSA-3-DAY','BDSA Year 3',3),
  ('c1a55000-0001-4000-8000-000000000017','88dfce47-1365-4820-be5c-669abfc2dd42','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DDSA-1-DAY','DDSA Year 1',1),
  ('c1a55000-0001-4000-8000-000000000018','88dfce47-1365-4820-be5c-669abfc2dd42','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DDSA-2-DAY','DDSA Year 2',2),
  ('c1a55000-0001-4000-8000-000000000019','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-1-DAY','BBA Year 1',1),
  ('c1a55000-0001-4000-8000-000000000020','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-2-DAY','BBA Year 2',2),
  ('c1a55000-0001-4000-8000-000000000021','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-3-DAY','BBA Year 3',3),
  ('c1a55000-0001-4000-8000-000000000022','41e287d8-9ca6-412e-9a3c-ed2e389036da','0d35fa69-de7f-4e05-b800-16c07321e75f','DBA-1-DAY','DBA Year 1',1),
  ('c1a55000-0001-4000-8000-000000000023','41e287d8-9ca6-412e-9a3c-ed2e389036da','0d35fa69-de7f-4e05-b800-16c07321e75f','DBA-2-DAY','DBA Year 2',2),
  ('c1a55000-0001-4000-8000-000000000024','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA-1-DAY','MBA Year 1',1),
  ('c1a55000-0001-4000-8000-000000000025','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA-2-DAY','MBA Year 2',2),
  ('c1a55000-0001-4000-8000-000000000026','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BJCS-1-DAY','BJCS Year 1',1),
  ('c1a55000-0001-4000-8000-000000000027','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BJCS-2-DAY','BJCS Year 2',2),
  ('c1a55000-0001-4000-8000-000000000028','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BJCS-3-DAY','BJCS Year 3',3),
  ('c1a55000-0001-4000-8000-000000000029','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BPAM-1-DAY','BPAM Year 1',1),
  ('c1a55000-0001-4000-8000-000000000030','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BPAM-2-DAY','BPAM Year 2',2),
  ('c1a55000-0001-4000-8000-000000000031','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BPAM-3-DAY','BPAM Year 3',3),
  ('c1a55000-0001-4000-8000-000000000032','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BIRDS-1-DAY','BIRDS Year 1',1),
  ('c1a55000-0001-4000-8000-000000000033','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BIRDS-2-DAY','BIRDS Year 2',2),
  ('c1a55000-0001-4000-8000-000000000034','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BIRDS-3-DAY','BIRDS Year 3',3),
  ('c1a55000-0001-4000-8000-000000000035','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BEHS-1-DAY','BEHS Year 1',1),
  ('c1a55000-0001-4000-8000-000000000036','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BEHS-2-DAY','BEHS Year 2',2),
  ('c1a55000-0001-4000-8000-000000000037','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BEHS-3-DAY','BEHS Year 3',3),
  ('c1a55000-0001-4000-8000-000000000038','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','BPH-1-DAY','BPH Year 1',1),
  ('c1a55000-0001-4000-8000-000000000039','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','BPH-2-DAY','BPH Year 2',2),
  ('c1a55000-0001-4000-8000-000000000040','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','BPH-3-DAY','BPH Year 3',3),
  ('c1a55000-0001-4000-8000-000000000041','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MPH-1-DAY','MPH Year 1',1),
  ('c1a55000-0001-4000-8000-000000000042','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MPH-2-DAY','MPH Year 2',2),
  ('c1a55000-0001-4000-8000-000000000043','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','ADHM-1-DAY','ADHM Year 1',1),
  ('c1a55000-0001-4000-8000-000000000044','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MSS-1-DAY','MSS Year 1',1),
  ('c1a55000-0001-4000-8000-000000000045','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MSS-2-DAY','MSS Year 2',2),
  ('c1a55000-0001-4000-8000-000000000046','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MEM-1-DAY','MEM Year 1',1),
  ('c1a55000-0001-4000-8000-000000000047','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MEM-2-DAY','MEM Year 2',2),
  ('c1a55000-0001-4000-8000-000000000048','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MPM-1-DAY','MPM Year 1',1),
  ('c1a55000-0001-4000-8000-000000000049','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MPM-2-DAY','MPM Year 2',2),
  ('c1a55000-0001-4000-8000-000000000050','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MIRDS-1-DAY','MIRDS Year 1',1),
  ('c1a55000-0001-4000-8000-000000000051','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MIRDS-2-DAY','MIRDS Year 2',2)
ON CONFLICT(id) DO NOTHING;

-- ── Lecturers ─────────────────────────────────────────────────────────────────
-- password_hash = bcrypt of 'Cavendish@2026'
-- qr_token_hash, qr_handle, qr_secret must be unique per user
INSERT INTO users(id,id_number,name,email,password_hash,role,department_id,qr_token_hash,qr_handle,qr_secret) VALUES
  ('47835404-5a90-4960-bee7-2b7cb6f9f4df','LEC-FST-001','Ms. Nanyonjo Evelyn','e.nanyonjo@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','qrth-fst-001','qrh-fst-001','qrs-fst-001'),
  ('1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','LEC-FST-002','Mr. Maganda Evans','m.maganda@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','qrth-fst-002','qrh-fst-002','qrs-fst-002'),
  ('57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','LEC-FST-003','Ms. Deborah Mackenzie','d.mackenzie@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','qrth-fst-003','qrh-fst-003','qrs-fst-003'),
  ('22640f68-e8c9-43e7-bd70-59ba276acbbb','LEC-FST-004','Mr. Mpubani David','d.mpubani@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','qrth-fst-004','qrh-fst-004','qrs-fst-004'),
  ('def38337-4c53-49c3-b348-7612934115ad','LEC-FST-005','Mr. Ivan Mugumya','i.mugumya@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','qrth-fst-005','qrh-fst-005','qrs-fst-005'),
  ('6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','LEC-FST-006','Mr. Mpiima Dennis','d.mpiima@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','qrth-fst-006','qrh-fst-006','qrs-fst-006'),
  ('c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','LEC-FST-007','Mr. Kasumba Shadrach','s.kasumba@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','qrth-fst-007','qrh-fst-007','qrs-fst-007'),
  ('dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','LEC-FST-008','Mr. Ssejjemba Martin','m.ssejjemba@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','qrth-fst-008','qrh-fst-008','qrs-fst-008'),
  ('7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','LEC-FST-009','Ms. Bridget Nuwagaba','b.nuwagaba@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','qrth-fst-009','qrh-fst-009','qrs-fst-009'),
  ('aee10928-3a11-4b2e-9e41-0b34d0f2f19b','LEC-FST-010','Dr. Racheal Ainembabazi','r.ainembabazi@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','qrth-fst-010','qrh-fst-010','qrs-fst-010'),
  ('bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78','LEC-BUS-001','Mr. Kawiso Martin Wilfred','m.kawiso@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','qrth-bus-001','qrh-bus-001','qrs-bus-001'),
  ('a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3','LEC-BUS-002','Mr. Bakyayita David','d.bakyayita@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','qrth-bus-002','qrh-bus-002','qrs-bus-002'),
  ('b24b5d9e-6c6f-4e60-97b8-d9e0f1a2b3c4','LEC-BUS-003','Mr. Muhwezi Moses','m.muhwezi@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','qrth-bus-003','qrh-bus-003','qrs-bus-003'),
  ('c35c6eaf-7d70-4f70-88c9-e0f1a2b3c4d5','LEC-BUS-004','Mr. Bamuswankwire Charles','c.bamuswankwire@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','qrth-bus-004','qrh-bus-004','qrs-bus-004'),
  ('d46d7fba-8e80-4080-89d0-f1a2b3c4d5e6','LEC-BUS-005','Mr. Senyonga Martin','m.senyonga@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','qrth-bus-005','qrh-bus-005','qrs-bus-005'),
  ('e57e8acb-9f90-4090-80e1-a2b3c4d5e6f7','LEC-BUS-006','Mr. Mwesigwa Henry','h.mwesigwa@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','qrth-bus-006','qrh-bus-006','qrs-bus-006'),
  ('f68f9bdc-0fa0-4fa0-a1f2-b3c4d5e6f7a8','LEC-BUS-007','Ms. Nakiganda Harriet','h.nakiganda@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','qrth-bus-007','qrh-bus-007','qrs-bus-007'),
  ('a79a0ced-1fb1-4fb1-b2a3-c4d5e6f7a8b9','LEC-BUS-008','Mr. Sseguya Ivan','i.sseguya@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','qrth-bus-008','qrh-bus-008','qrs-bus-008'),
  ('b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0','LEC-SES-001','Ms. Namakula Elizabeth','e.namakula@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','qrth-ses-001','qrh-ses-001','qrs-ses-001'),
  ('c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1','LEC-SES-002','Ms. Nnagadya Sumayah','s.nnagadya@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','qrth-ses-002','qrh-ses-002','qrs-ses-002'),
  ('da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2','LEC-SES-003','Dr. Fiona Tumusiime','f.tumusiime@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','qrth-ses-003','qrh-ses-003','qrs-ses-003'),
  ('eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3','LEC-SES-004','Dr. Kibukamusoke Martha','m.kibukamusoke@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','qrth-ses-004','qrh-ses-004','qrs-ses-004'),
  ('fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4','LEC-SES-005','Mr. Denis Wamimbi','d.wamimbi@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','qrth-ses-005','qrh-ses-005','qrs-ses-005'),
  ('ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5','LEC-SES-006','Mr. Jonathan Tabalanga','j.tabalanga@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','qrth-ses-006','qrh-ses-006','qrs-ses-006'),
  ('be617354-8fe8-4fe8-89ba-d1e2f3a4b5c6','LEC-SES-007','Dr. Abdulrazak Yugua Madu','a.madu@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','qrth-ses-007','qrh-ses-007','qrs-ses-007'),
  ('cf728465-9fe9-4fe9-8acb-e2f3a4b5c6d7','LEC-SES-008','Prof. Love Aruguobiani','l.aruguobiani@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','qrth-ses-008','qrh-ses-008','qrs-ses-008'),
  ('d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','LEC-HEC-001','Ms. Khawa Namajja','k.namajja@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','qrth-hec-001','qrh-hec-001','qrs-hec-001'),
  ('e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','LEC-HEC-002','Ms. Juliet Bandaru','j.bandaru@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','qrth-hec-002','qrh-hec-002','qrs-hec-002'),
  ('f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','LEC-HEC-003','Mr. Bruce Nabaasa','b.nabaasa@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','qrth-hec-003','qrh-hec-003','qrs-hec-003'),
  ('a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','LEC-HEC-004','Mr. Murami Taibu','m.taibu@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','qrth-hec-004','qrh-hec-004','qrs-hec-004'),
  ('b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','LEC-HEC-005','Mr. Deo Nsubuga','d.nsubuga@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','qrth-hec-005','qrh-hec-005','qrs-hec-005')
ON CONFLICT(id) DO UPDATE SET name=EXCLUDED.name,role=EXCLUDED.role,department_id=EXCLUDED.department_id,password_hash=EXCLUDED.password_hash;

-- ── Facilities (29 rooms) ─────────────────────────────────────────────────────
-- category must be one of: lecture_room, discussion_room, lab, office, library
-- UNIQUE(building, room_number) so ON CONFLICT uses that
-- FST Block A (12 rooms)
INSERT INTO facilities(id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES
  ('f1000001-0000-0000-0000-000000000001','LR1 - Lecture Hall A','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Ground Floor','East','LR1','Main lecture hall, ground floor Block A',0.317300,32.571600,120,'active','static_geo',100,'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4',1),
  ('f1000001-0000-0000-0000-000000000002','LR2 - Lecture Hall B','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Ground Floor','West','LR2','Ground floor west wing Block A',0.317400,32.571700,100,'active','static_geo',100,'b2c3d4e5f6a7b2c3d4e5f6a7b2c3d4e5',1),
  ('f1000001-0000-0000-0000-000000000003','LR3 - Seminar Room A','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','First Floor','East','LR3','First floor seminar room east wing',0.317500,32.571800,60,'active','static_geo',100,'c3d4e5f6a7b8c3d4e5f6a7b8c3d4e5f6',1),
  ('f1000001-0000-0000-0000-000000000004','LR4 - Seminar Room B','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','First Floor','West','LR4','First floor seminar room west wing',0.317600,32.571900,60,'active','static_geo',100,'d4e5f6a7b8c9d4e5f6a7b8c9d4e5f6a7',1),
  ('f1000001-0000-0000-0000-000000000005','LR5 - Computer Lab A','lab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Second Floor','East','LR5','FST computer lab east wing',0.317700,32.572000,40,'active','static_geo',100,'e5f6a7b8c9d0e5f6a7b8c9d0e5f6a7b8',1),
  ('f1000001-0000-0000-0000-000000000006','LR6 - Computer Lab B','lab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Second Floor','West','LR6','FST computer lab west wing',0.317800,32.572100,40,'active','static_geo',100,'f6a7b8c9d0e1f6a7b8c9d0e1f6a7b8c9',1),
  ('f1000001-0000-0000-0000-000000000007','LR7 - Tutorial Room A','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Second Floor','North','LR7','Small tutorial room north wing',0.317900,32.572200,30,'active','static_geo',100,'a7b8c9d0e1f2a7b8c9d0e1f2a7b8c9d0',1),
  ('f1000001-0000-0000-0000-000000000008','LR8 - Tutorial Room B','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Second Floor','South','LR8','Small tutorial room south wing',0.318000,32.572300,30,'active','static_geo',100,'b8c9d0e1f2a3b8c9d0e1f2a3b8c9d0e1',1),
  ('f1000001-0000-0000-0000-000000000009','LR9 - Lecture Hall C','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Ground Floor','North','LR9','Large lecture hall north side',0.317100,32.571500,80,'active','static_geo',100,'c9d0e1f2a3b4c9d0e1f2a3b4c9d0e1f2',1),
  ('f1000001-0000-0000-0000-000000000010','LR10 - Seminar Room C','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','First Floor','North','LR10','Mid-size seminar room first floor',0.317200,32.571400,50,'active','static_geo',100,'d0e1f2a3b4c5d0e1f2a3b4c5d0e1f2a3',1),
  ('f1000001-0000-0000-0000-000000000011','LR11 - Computer Lab C','lab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Third Floor','East','LR11','Advanced computing lab',0.318100,32.572400,35,'active','static_geo',100,'e1f2a3b4c5d6e1f2a3b4c5d6e1f2a3b4',1),
  ('f1000001-0000-0000-0000-000000000012','LR12 - Smart Classroom A','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Third Floor','West','LR12','Smart classroom with projectors',0.318200,32.572500,45,'active','static_geo',100,'f2a3b4c5d6e7f2a3b4c5d6e7f2a3b4c5',1)
ON CONFLICT(building,room_number) DO UPDATE SET name=EXCLUDED.name,category=EXCLUDED.category,department_id=EXCLUDED.department_id,floor=EXCLUDED.floor,wing=EXCLUDED.wing,location_description=EXCLUDED.location_description,capacity=EXCLUDED.capacity,status=EXCLUDED.status,latitude=EXCLUDED.latitude,longitude=EXCLUDED.longitude;

-- BUS Block B (8 rooms)
INSERT INTO facilities(id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES
  ('f1000001-0000-0000-0000-000000000013','LR13 - Business Lecture Hall A','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','Ground Floor','East','LR13','Main business lecture hall',0.318500,32.572500,120,'active','static_geo',100,'a3b4c5d6e7f8a3b4c5d6e7f8a3b4c5d6',1),
  ('f1000001-0000-0000-0000-000000000014','LR14 - Business Lecture Hall B','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','Ground Floor','West','LR14','Secondary business lecture hall',0.318600,32.572600,80,'active','static_geo',100,'b4c5d6e7f8a9b4c5d6e7f8a9b4c5d6e7',1),
  ('f1000001-0000-0000-0000-000000000015','LR15 - Business Seminar Room A','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','First Floor','East','LR15','Business seminar room east',0.318700,32.572700,50,'active','static_geo',100,'c5d6e7f8a9b0c5d6e7f8a9b0c5d6e7f8',1),
  ('f1000001-0000-0000-0000-000000000016','LR16 - Business Seminar Room B','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','First Floor','West','LR16','Business seminar room west',0.318800,32.572800,40,'active','static_geo',100,'d6e7f8a9b0c1d6e7f8a9b0c1d6e7f8a9',1),
  ('f1000001-0000-0000-0000-000000000017','LR17 - Business Computer Lab','lab','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','Second Floor','East','LR17','Business computing lab',0.318900,32.572900,30,'active','static_geo',100,'e7f8a9b0c1d2e7f8a9b0c1d2e7f8a9b0',1),
  ('f1000001-0000-0000-0000-000000000018','LR18 - Case Study Room A','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','Second Floor','West','LR18','MBA case study room',0.319000,32.573000,35,'active','static_geo',100,'f8a9b0c1d2e3f8a9b0c1d2e3f8a9b0c1',1),
  ('f1000001-0000-0000-0000-000000000019','LR19 - Case Study Room B','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','Second Floor','North','LR19','MBA case study room B',0.319100,32.573100,35,'active','static_geo',100,'a9b0c1d2e3f4a9b0c1d2e3f4a9b0c1d2',1),
  ('f1000001-0000-0000-0000-000000000020','LR20 - Business Tutorial Room','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','Third Floor','East','LR20','Small business tutorial room',0.319200,32.573200,30,'active','static_geo',100,'b0c1d2e3f4a5b0c1d2e3f4a5b0c1d2e3',1)
ON CONFLICT(building,room_number) DO UPDATE SET name=EXCLUDED.name,category=EXCLUDED.category,department_id=EXCLUDED.department_id,floor=EXCLUDED.floor,wing=EXCLUDED.wing,location_description=EXCLUDED.location_description,capacity=EXCLUDED.capacity,status=EXCLUDED.status,latitude=EXCLUDED.latitude,longitude=EXCLUDED.longitude;

-- SES Block C (5 rooms)
INSERT INTO facilities(id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES
  ('f1000001-0000-0000-0000-000000000021','LR21 - Social Sciences Lecture Hall','lecture_room','422a6c15-127f-47d5-a044-e7547d35dcb6','Block C','Ground Floor','East','LR21','Main social sciences lecture hall',0.319300,32.573200,100,'active','static_geo',100,'c1d2e3f4a5b6c1d2e3f4a5b6c1d2e3f4',1),
  ('f1000001-0000-0000-0000-000000000022','LR22 - Media Lab A','lab','422a6c15-127f-47d5-a044-e7547d35dcb6','Block C','First Floor','East','LR22','Journalism media production lab',0.319400,32.573300,40,'active','static_geo',100,'d2e3f4a5b6c7d2e3f4a5b6c7d2e3f4a5',1),
  ('f1000001-0000-0000-0000-000000000023','LR23 - Media Lab B','lab','422a6c15-127f-47d5-a044-e7547d35dcb6','Block C','First Floor','West','LR23','Journalism media lab B',0.319500,32.573400,35,'active','static_geo',100,'e3f4a5b6c7d8e3f4a5b6c7d8e3f4a5b6',1),
  ('f1000001-0000-0000-0000-000000000024','LR24 - Social Sciences Seminar Room','lecture_room','422a6c15-127f-47d5-a044-e7547d35dcb6','Block C','Second Floor','East','LR24','SES seminar and discussion room',0.319600,32.573500,50,'active','static_geo',100,'f4a5b6c7d8e9f4a5b6c7d8e9f4a5b6c7',1),
  ('f1000001-0000-0000-0000-000000000025','LR25 - Conference Room A','lecture_room','422a6c15-127f-47d5-a044-e7547d35dcb6','Block C','Second Floor','West','LR25','Multi-purpose conference room',0.319700,32.573600,45,'active','static_geo',100,'a5b6c7d8e9f0a5b6c7d8e9f0a5b6c7d8',1)
ON CONFLICT(building,room_number) DO UPDATE SET name=EXCLUDED.name,category=EXCLUDED.category,department_id=EXCLUDED.department_id,floor=EXCLUDED.floor,wing=EXCLUDED.wing,location_description=EXCLUDED.location_description,capacity=EXCLUDED.capacity,status=EXCLUDED.status,latitude=EXCLUDED.latitude,longitude=EXCLUDED.longitude;

-- HEC Block D (4 rooms)
INSERT INTO facilities(id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES
  ('f1000001-0000-0000-0000-000000000026','LR26 - Health Sciences Lecture Hall','lecture_room','06a806fc-0d90-4c27-877d-1025a3ebdbd1','Block D','Ground Floor','East','LR26','Main health sciences lecture hall',0.319800,32.573700,100,'active','static_geo',100,'b6c7d8e9f0a1b6c7d8e9f0a1b6c7d8e9',1),
  ('f1000001-0000-0000-0000-000000000027','LR27 - Health Sciences Lab A','lab','06a806fc-0d90-4c27-877d-1025a3ebdbd1','Block D','First Floor','East','LR27','Public health computer lab',0.319900,32.573800,40,'active','static_geo',100,'c7d8e9f0a1b2c7d8e9f0a1b2c7d8e9f0',1),
  ('f1000001-0000-0000-0000-000000000028','LR28 - Health Sciences Seminar Room','lecture_room','06a806fc-0d90-4c27-877d-1025a3ebdbd1','Block D','First Floor','West','LR28','HEC seminar and tutorial room',0.320000,32.573900,50,'active','static_geo',100,'d8e9f0a1b2c3d8e9f0a1b2c3d8e9f0a1',1),
  ('f1000001-0000-0000-0000-000000000029','LR29 - Community Health Lab','lab','06a806fc-0d90-4c27-877d-1025a3ebdbd1','Block D','Second Floor','East','LR29','Community health practical lab',0.320100,32.574000,35,'active','static_geo',100,'e9f0a1b2c3d4e9f0a1b2c3d4e9f0a1b2',1)
ON CONFLICT(building,room_number) DO UPDATE SET name=EXCLUDED.name,category=EXCLUDED.category,department_id=EXCLUDED.department_id,floor=EXCLUDED.floor,wing=EXCLUDED.wing,location_description=EXCLUDED.location_description,capacity=EXCLUDED.capacity,status=EXCLUDED.status,latitude=EXCLUDED.latitude,longitude=EXCLUDED.longitude;

COMMIT;
