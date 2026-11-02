-- Cavendish University Uganda — Full Seed
-- 4 depts | 21 programmes | 51 classes | 31 lecturers | 335 modules | 29 facilities
-- Generated: 2026-11-02  |  Safe to re-run: ON CONFLICT DO UPDATE / DO NOTHING

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
INSERT INTO classes(id,programme_id,name,year_of_study) VALUES
  ('c1a55000-0001-4000-8000-000000000001','73593c0f-0478-45b5-a87d-a8e87f5ea274','BIT Year 1',1),
  ('c1a55000-0001-4000-8000-000000000002','73593c0f-0478-45b5-a87d-a8e87f5ea274','BIT Year 2',2),
  ('c1a55000-0001-4000-8000-000000000003','73593c0f-0478-45b5-a87d-a8e87f5ea274','BIT Year 3',3),
  ('c1a55000-0001-4000-8000-000000000004','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','BSE Year 1',1),
  ('c1a55000-0001-4000-8000-000000000005','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','BSE Year 2',2),
  ('c1a55000-0001-4000-8000-000000000006','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','BSE Year 3',3),
  ('c1a55000-0001-4000-8000-000000000007','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','BCS Year 1',1),
  ('c1a55000-0001-4000-8000-000000000008','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','BCS Year 2',2),
  ('c1a55000-0001-4000-8000-000000000009','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','BCS Year 3',3),
  ('c1a55000-0001-4000-8000-000000000010','ac00b024-3929-4702-9a14-b216830ab328','DIT Year 1',1),
  ('c1a55000-0001-4000-8000-000000000011','ac00b024-3929-4702-9a14-b216830ab328','DIT Year 2',2),
  ('c1a55000-0001-4000-8000-000000000012','406f66f5-ea30-4071-9d85-d6029d0fcb05','MIT Year 1',1),
  ('c1a55000-0001-4000-8000-000000000013','406f66f5-ea30-4071-9d85-d6029d0fcb05','MIT Year 2',2),
  ('c1a55000-0001-4000-8000-000000000014','ec2c1740-c4d5-4056-854f-50cf368c00ab','BDSA Year 1',1),
  ('c1a55000-0001-4000-8000-000000000015','ec2c1740-c4d5-4056-854f-50cf368c00ab','BDSA Year 2',2),
  ('c1a55000-0001-4000-8000-000000000016','ec2c1740-c4d5-4056-854f-50cf368c00ab','BDSA Year 3',3),
  ('c1a55000-0001-4000-8000-000000000017','88dfce47-1365-4820-be5c-669abfc2dd42','DDSA Year 1',1),
  ('c1a55000-0001-4000-8000-000000000018','88dfce47-1365-4820-be5c-669abfc2dd42','DDSA Year 2',2),
  ('c1a55000-0001-4000-8000-000000000019','46a86d77-2f4c-4f44-a5ed-83d51354b863','BBA Year 1',1),
  ('c1a55000-0001-4000-8000-000000000020','46a86d77-2f4c-4f44-a5ed-83d51354b863','BBA Year 2',2),
  ('c1a55000-0001-4000-8000-000000000021','46a86d77-2f4c-4f44-a5ed-83d51354b863','BBA Year 3',3),
  ('c1a55000-0001-4000-8000-000000000022','41e287d8-9ca6-412e-9a3c-ed2e389036da','DBA Year 1',1),
  ('c1a55000-0001-4000-8000-000000000023','41e287d8-9ca6-412e-9a3c-ed2e389036da','DBA Year 2',2),
  ('c1a55000-0001-4000-8000-000000000024','7ccf2f00-fc18-49f2-a479-52e834f32aaa','MBA Year 1',1),
  ('c1a55000-0001-4000-8000-000000000025','7ccf2f00-fc18-49f2-a479-52e834f32aaa','MBA Year 2',2),
  ('c1a55000-0001-4000-8000-000000000026','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','BJCS Year 1',1),
  ('c1a55000-0001-4000-8000-000000000027','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','BJCS Year 2',2),
  ('c1a55000-0001-4000-8000-000000000028','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','BJCS Year 3',3),
  ('c1a55000-0001-4000-8000-000000000029','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','BPAM Year 1',1),
  ('c1a55000-0001-4000-8000-000000000030','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','BPAM Year 2',2),
  ('c1a55000-0001-4000-8000-000000000031','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','BPAM Year 3',3),
  ('c1a55000-0001-4000-8000-000000000032','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','BIRDS Year 1',1),
  ('c1a55000-0001-4000-8000-000000000033','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','BIRDS Year 2',2),
  ('c1a55000-0001-4000-8000-000000000034','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','BIRDS Year 3',3),
  ('c1a55000-0001-4000-8000-000000000035','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','BEHS Year 1',1),
  ('c1a55000-0001-4000-8000-000000000036','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','BEHS Year 2',2),
  ('c1a55000-0001-4000-8000-000000000037','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','BEHS Year 3',3),
  ('c1a55000-0001-4000-8000-000000000038','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','BPH Year 1',1),
  ('c1a55000-0001-4000-8000-000000000039','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','BPH Year 2',2),
  ('c1a55000-0001-4000-8000-000000000040','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','BPH Year 3',3),
  ('c1a55000-0001-4000-8000-000000000041','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','MPH Year 1',1),
  ('c1a55000-0001-4000-8000-000000000042','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','MPH Year 2',2),
  ('c1a55000-0001-4000-8000-000000000043','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','ADHM Year 1',1),
  ('c1a55000-0001-4000-8000-000000000044','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','MSS Year 1',1),
  ('c1a55000-0001-4000-8000-000000000045','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','MSS Year 2',2),
  ('c1a55000-0001-4000-8000-000000000046','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb','MEM Year 1',1),
  ('c1a55000-0001-4000-8000-000000000047','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb','MEM Year 2',2),
  ('c1a55000-0001-4000-8000-000000000048','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','MPM Year 1',1),
  ('c1a55000-0001-4000-8000-000000000049','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','MPM Year 2',2),
  ('c1a55000-0001-4000-8000-000000000050','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb','MIRDS Year 1',1),
  ('c1a55000-0001-4000-8000-000000000051','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb','MIRDS Year 2',2)
ON CONFLICT(id) DO NOTHING;

-- ── Lecturers (31 users with role='lecturer') ─────────────────────────────────
-- Default password: Cavendish@2026
INSERT INTO users(id,name,email,password,role,department_id) VALUES
  ('47835404-5a90-4960-bee7-2b7cb6f9f4df','Ms. Nanyonjo Evelyn','e.nanyonjo@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a'),
  ('1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','Mr. Maganda Evans','m.maganda@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a'),
  ('57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','Ms. Deborah Mackenzie','d.mackenzie@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a'),
  ('22640f68-e8c9-43e7-bd70-59ba276acbbb','Mr. Mpubani David','d.mpubani@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a'),
  ('def38337-4c53-49c3-b348-7612934115ad','Mr. Ivan Mugumya','i.mugumya@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a'),
  ('6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','Mr. Mpiima Dennis','d.mpiima@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a'),
  ('c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','Mr. Kasumba Shadrach','s.kasumba@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a'),
  ('dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','Mr. Ssejjemba Martin','m.ssejjemba@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a'),
  ('7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','Ms. Bridget Nuwagaba','b.nuwagaba@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a'),
  ('aee10928-3a11-4b2e-9e41-0b34d0f2f19b','Dr. Racheal Ainembabazi','r.ainembabazi@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a'),
  ('bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78','Mr. Kawiso Martin Wilfred','m.kawiso@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f'),
  ('a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3','Mr. Bakyayita David','d.bakyayita@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f'),
  ('b24b5d9e-6c6f-4e60-97b8-d9e0f1a2b3c4','Mr. Muhwezi Moses','m.muhwezi@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f'),
  ('c35c6eaf-7d70-4f70-88c9-e0f1a2b3c4d5','Mr. Bamuswankwire Charles','c.bamuswankwire@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f'),
  ('d46d7fba-8e80-4080-89d0-f1a2b3c4d5e6','Mr. Senyonga Martin','m.senyonga@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f'),
  ('e57e8acb-9f90-4090-80e1-a2b3c4d5e6f7','Mr. Mwesigwa Henry','h.mwesigwa@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f'),
  ('f68f9bdc-0fa0-4fa0-a1f2-b3c4d5e6f7a8','Ms. Nakiganda Harriet','h.nakiganda@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f'),
  ('a79a0ced-1fb1-4fb1-b2a3-c4d5e6f7a8b9','Mr. Sseguya Ivan','i.sseguya@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f'),
  ('b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0','Ms. Namakula Elizabeth','e.namakula@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6'),
  ('c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1','Ms. Nnagadya Sumayah','s.nnagadya@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6'),
  ('da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2','Dr. Fiona Tumusiime','f.tumusiime@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6'),
  ('eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3','Dr. Kibukamusoke Martha','m.kibukamusoke@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6'),
  ('fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4','Mr. Denis Wamimbi','d.wamimbi@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6'),
  ('ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5','Mr. Jonathan Tabalanga','j.tabalanga@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6'),
  ('be617354-8fe8-4fe8-89ba-d1e2f3a4b5c6','Dr. Abdulrazak Yugua Madu','a.madu@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6'),
  ('cf728465-9fe9-4fe9-8acb-e2f3a4b5c6d7','Prof. Love Aruguobiani','l.aruguobiani@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6'),
  ('d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','Ms. Khawa Namajja','k.namajja@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1'),
  ('e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','Ms. Juliet Bandaru','j.bandaru@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1'),
  ('f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','Mr. Bruce Nabaasa','b.nabaasa@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1'),
  ('a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','Mr. Murami Taibu','m.taibu@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1'),
  ('b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','Mr. Deo Nsubuga','d.nsubuga@cavendish.ac.ug','$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1')
ON CONFLICT(id) DO UPDATE SET name=EXCLUDED.name,role=EXCLUDED.role,department_id=EXCLUDED.department_id;


-- ── Modules: BIT (28) ─────────────────────────────────────────────────────────
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000001','BIT1101','Introduction to Information Technology','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000002','BIT1102','Computer Programming I','96178a5a-1a50-43ad-ace6-045b0e7dd47a','1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000003','BIT1103','Mathematics for Computing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000004','BIT1104','Communication Skills','96178a5a-1a50-43ad-ace6-045b0e7dd47a','22640f68-e8c9-43e7-bd70-59ba276acbbb','73593c0f-0478-45b5-a87d-a8e87f5ea274',2),
('d0d01e00-0001-4000-8000-000000000005','BIT1105','Introduction to Databases','96178a5a-1a50-43ad-ace6-045b0e7dd47a','def38337-4c53-49c3-b348-7612934115ad','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000006','BIT2101','Data Structures and Algorithms','96178a5a-1a50-43ad-ace6-045b0e7dd47a','6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','73593c0f-0478-45b5-a87d-a8e87f5ea274',4),
('d0d01e00-0001-4000-8000-000000000007','BIT2102','Computer Networks','96178a5a-1a50-43ad-ace6-045b0e7dd47a','c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000008','BIT2103','Operating Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000009','BIT2104','Web Development I','96178a5a-1a50-43ad-ace6-045b0e7dd47a','7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000010','BIT2105','Software Engineering Principles','96178a5a-1a50-43ad-ace6-045b0e7dd47a','aee10928-3a11-4b2e-9e41-0b34d0f2f19b','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000011','BIT2201','Database Management Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','73593c0f-0478-45b5-a87d-a8e87f5ea274',4),
('d0d01e00-0001-4000-8000-000000000012','BIT2202','System Analysis and Design','96178a5a-1a50-43ad-ace6-045b0e7dd47a','1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000013','BIT2203','Object-Oriented Programming','96178a5a-1a50-43ad-ace6-045b0e7dd47a','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000014','BIT2204','Web Development II','96178a5a-1a50-43ad-ace6-045b0e7dd47a','22640f68-e8c9-43e7-bd70-59ba276acbbb','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000015','BIT2205','Project Management','96178a5a-1a50-43ad-ace6-045b0e7dd47a','def38337-4c53-49c3-b348-7612934115ad','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000016','BIT3101','Network Administration','96178a5a-1a50-43ad-ace6-045b0e7dd47a','6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000017','BIT3102','Information Security','96178a5a-1a50-43ad-ace6-045b0e7dd47a','c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000018','BIT3103','Mobile Application Development','96178a5a-1a50-43ad-ace6-045b0e7dd47a','dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000019','BIT3104','Cloud Computing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000020','BIT3105','Artificial Intelligence','96178a5a-1a50-43ad-ace6-045b0e7dd47a','aee10928-3a11-4b2e-9e41-0b34d0f2f19b','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000021','BIT3201','E-Commerce Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000022','BIT3202','Research Methods in IT','96178a5a-1a50-43ad-ace6-045b0e7dd47a','1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','73593c0f-0478-45b5-a87d-a8e87f5ea274',2),
('d0d01e00-0001-4000-8000-000000000023','BIT3203','IT Project','96178a5a-1a50-43ad-ace6-045b0e7dd47a','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','73593c0f-0478-45b5-a87d-a8e87f5ea274',6),
('d0d01e00-0001-4000-8000-000000000024','BIT3204','Human Computer Interaction','96178a5a-1a50-43ad-ace6-045b0e7dd47a','22640f68-e8c9-43e7-bd70-59ba276acbbb','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000025','BIT3205','Entrepreneurship and Innovation','96178a5a-1a50-43ad-ace6-045b0e7dd47a','def38337-4c53-49c3-b348-7612934115ad','73593c0f-0478-45b5-a87d-a8e87f5ea274',2),
('d0d01e00-0001-4000-8000-000000000026','BIT3206','Digital Forensics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000027','BIT3207','Internet of Things','96178a5a-1a50-43ad-ace6-045b0e7dd47a','c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','73593c0f-0478-45b5-a87d-a8e87f5ea274',3),
('d0d01e00-0001-4000-8000-000000000028','BIT3208','Systems Administration','96178a5a-1a50-43ad-ace6-045b0e7dd47a','dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','73593c0f-0478-45b5-a87d-a8e87f5ea274',3)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: BSE (25)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000029','BSE1101','Fundamentals of Programming','96178a5a-1a50-43ad-ace6-045b0e7dd47a','7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000030','BSE1102','Discrete Mathematics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','aee10928-3a11-4b2e-9e41-0b34d0f2f19b','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000031','BSE1103','Introduction to Software Engineering','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000032','BSE1104','Technical Communication','96178a5a-1a50-43ad-ace6-045b0e7dd47a','1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',2),
('d0d01e00-0001-4000-8000-000000000033','BSE1105','Computer Organisation','96178a5a-1a50-43ad-ace6-045b0e7dd47a','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000034','BSE2101','Data Structures','96178a5a-1a50-43ad-ace6-045b0e7dd47a','22640f68-e8c9-43e7-bd70-59ba276acbbb','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',4),
('d0d01e00-0001-4000-8000-000000000035','BSE2102','Algorithm Design and Analysis','96178a5a-1a50-43ad-ace6-045b0e7dd47a','def38337-4c53-49c3-b348-7612934115ad','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000036','BSE2103','Software Requirements Engineering','96178a5a-1a50-43ad-ace6-045b0e7dd47a','6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000037','BSE2104','Database Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000038','BSE2105','Object-Oriented Design','96178a5a-1a50-43ad-ace6-045b0e7dd47a','dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000039','BSE2201','Software Architecture','96178a5a-1a50-43ad-ace6-045b0e7dd47a','7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000040','BSE2202','Software Testing and Quality Assurance','96178a5a-1a50-43ad-ace6-045b0e7dd47a','aee10928-3a11-4b2e-9e41-0b34d0f2f19b','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000041','BSE2203','Operating Systems Concepts','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000042','BSE2204','Software Networking','96178a5a-1a50-43ad-ace6-045b0e7dd47a','1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000043','BSE2205','Software Project Management','96178a5a-1a50-43ad-ace6-045b0e7dd47a','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000044','BSE3101','Mobile Software Development','96178a5a-1a50-43ad-ace6-045b0e7dd47a','22640f68-e8c9-43e7-bd70-59ba276acbbb','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000045','BSE3102','Distributed Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','def38337-4c53-49c3-b348-7612934115ad','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000046','BSE3103','Software Security','96178a5a-1a50-43ad-ace6-045b0e7dd47a','6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000047','BSE3104','Agile Development Methodologies','96178a5a-1a50-43ad-ace6-045b0e7dd47a','c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000048','BSE3105','Artificial Intelligence for Software','96178a5a-1a50-43ad-ace6-045b0e7dd47a','dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000049','BSE3201','DevOps and Continuous Integration','96178a5a-1a50-43ad-ace6-045b0e7dd47a','7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000050','BSE3202','Research Methods in Software Engineering','96178a5a-1a50-43ad-ace6-045b0e7dd47a','aee10928-3a11-4b2e-9e41-0b34d0f2f19b','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',2),
('d0d01e00-0001-4000-8000-000000000051','BSE3203','Software Engineering Project','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',6),
('d0d01e00-0001-4000-8000-000000000052','BSE3204','Human-Centred Design','96178a5a-1a50-43ad-ace6-045b0e7dd47a','1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',3),
('d0d01e00-0001-4000-8000-000000000053','BSE3205','Entrepreneurship in Technology','96178a5a-1a50-43ad-ace6-045b0e7dd47a','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',2)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: BCS (22)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000054','BCS1101','Introduction to Computer Science','96178a5a-1a50-43ad-ace6-045b0e7dd47a','22640f68-e8c9-43e7-bd70-59ba276acbbb','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000055','BCS1102','Programming Fundamentals','96178a5a-1a50-43ad-ace6-045b0e7dd47a','def38337-4c53-49c3-b348-7612934115ad','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000056','BCS1103','Discrete Mathematics for CS','96178a5a-1a50-43ad-ace6-045b0e7dd47a','6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000057','BCS1104','Academic Writing and Communication','96178a5a-1a50-43ad-ace6-045b0e7dd47a','c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',2),
('d0d01e00-0001-4000-8000-000000000058','BCS2101','Data Structures and Algorithms','96178a5a-1a50-43ad-ace6-045b0e7dd47a','dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',4),
('d0d01e00-0001-4000-8000-000000000059','BCS2102','Computer Architecture','96178a5a-1a50-43ad-ace6-045b0e7dd47a','7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000060','BCS2103','Operating Systems Concepts','96178a5a-1a50-43ad-ace6-045b0e7dd47a','aee10928-3a11-4b2e-9e41-0b34d0f2f19b','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000061','BCS2104','Database Theory','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000062','BCS2105','Theory of Computation','96178a5a-1a50-43ad-ace6-045b0e7dd47a','1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000063','BCS2201','Compiler Design','96178a5a-1a50-43ad-ace6-045b0e7dd47a','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000064','BCS2202','Computer Networks Fundamentals','96178a5a-1a50-43ad-ace6-045b0e7dd47a','22640f68-e8c9-43e7-bd70-59ba276acbbb','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000065','BCS2203','Artificial Intelligence','96178a5a-1a50-43ad-ace6-045b0e7dd47a','def38337-4c53-49c3-b348-7612934115ad','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000066','BCS2204','Software Engineering','96178a5a-1a50-43ad-ace6-045b0e7dd47a','6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000067','BCS3101','Machine Learning','96178a5a-1a50-43ad-ace6-045b0e7dd47a','c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000068','BCS3102','Distributed Computing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000069','BCS3103','Computer Graphics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000070','BCS3104','Information Retrieval','96178a5a-1a50-43ad-ace6-045b0e7dd47a','aee10928-3a11-4b2e-9e41-0b34d0f2f19b','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000071','BCS3105','Cybersecurity Fundamentals','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000072','BCS3201','Parallel Computing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',3),
('d0d01e00-0001-4000-8000-000000000073','BCS3202','Research Methods in CS','96178a5a-1a50-43ad-ace6-045b0e7dd47a','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',2),
('d0d01e00-0001-4000-8000-000000000074','BCS3203','Computer Science Project','96178a5a-1a50-43ad-ace6-045b0e7dd47a','22640f68-e8c9-43e7-bd70-59ba276acbbb','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',6),
('d0d01e00-0001-4000-8000-000000000075','BCS3204','Ethics in Computing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','def38337-4c53-49c3-b348-7612934115ad','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',2)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: DIT (14)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000076','DIT1101','Introduction to Computing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','ac00b024-3929-4702-9a14-b216830ab328',3),
('d0d01e00-0001-4000-8000-000000000077','DIT1102','Computer Applications','96178a5a-1a50-43ad-ace6-045b0e7dd47a','c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','ac00b024-3929-4702-9a14-b216830ab328',3),
('d0d01e00-0001-4000-8000-000000000078','DIT1103','Basic Programming','96178a5a-1a50-43ad-ace6-045b0e7dd47a','dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','ac00b024-3929-4702-9a14-b216830ab328',3),
('d0d01e00-0001-4000-8000-000000000079','DIT1104','Mathematics for IT','96178a5a-1a50-43ad-ace6-045b0e7dd47a','7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','ac00b024-3929-4702-9a14-b216830ab328',3),
('d0d01e00-0001-4000-8000-000000000080','DIT1105','Business Communication','96178a5a-1a50-43ad-ace6-045b0e7dd47a','aee10928-3a11-4b2e-9e41-0b34d0f2f19b','ac00b024-3929-4702-9a14-b216830ab328',2),
('d0d01e00-0001-4000-8000-000000000081','DIT1106','Introduction to Networking','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','ac00b024-3929-4702-9a14-b216830ab328',3),
('d0d01e00-0001-4000-8000-000000000082','DIT1107','Web Design Basics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','ac00b024-3929-4702-9a14-b216830ab328',3),
('d0d01e00-0001-4000-8000-000000000083','DIT2101','Database Applications','96178a5a-1a50-43ad-ace6-045b0e7dd47a','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','ac00b024-3929-4702-9a14-b216830ab328',3),
('d0d01e00-0001-4000-8000-000000000084','DIT2102','System Administration','96178a5a-1a50-43ad-ace6-045b0e7dd47a','22640f68-e8c9-43e7-bd70-59ba276acbbb','ac00b024-3929-4702-9a14-b216830ab328',3),
('d0d01e00-0001-4000-8000-000000000085','DIT2103','Network Support','96178a5a-1a50-43ad-ace6-045b0e7dd47a','def38337-4c53-49c3-b348-7612934115ad','ac00b024-3929-4702-9a14-b216830ab328',3),
('d0d01e00-0001-4000-8000-000000000086','DIT2104','Web Development','96178a5a-1a50-43ad-ace6-045b0e7dd47a','6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','ac00b024-3929-4702-9a14-b216830ab328',3),
('d0d01e00-0001-4000-8000-000000000087','DIT2105','IT Support and Maintenance','96178a5a-1a50-43ad-ace6-045b0e7dd47a','c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','ac00b024-3929-4702-9a14-b216830ab328',3),
('d0d01e00-0001-4000-8000-000000000088','DIT2106','IT Project Management','96178a5a-1a50-43ad-ace6-045b0e7dd47a','dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','ac00b024-3929-4702-9a14-b216830ab328',3),
('d0d01e00-0001-4000-8000-000000000089','DIT2107','Diploma IT Project','96178a5a-1a50-43ad-ace6-045b0e7dd47a','7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','ac00b024-3929-4702-9a14-b216830ab328',6)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: MIT (12)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000090','MIT1101','Advanced Database Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','aee10928-3a11-4b2e-9e41-0b34d0f2f19b','406f66f5-ea30-4071-9d85-d6029d0fcb05',4),
('d0d01e00-0001-4000-8000-000000000091','MIT1102','Research Methods in IT','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','406f66f5-ea30-4071-9d85-d6029d0fcb05',3),
('d0d01e00-0001-4000-8000-000000000092','MIT1103','Enterprise Architecture','96178a5a-1a50-43ad-ace6-045b0e7dd47a','1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','406f66f5-ea30-4071-9d85-d6029d0fcb05',3),
('d0d01e00-0001-4000-8000-000000000093','MIT1104','IT Governance and Management','96178a5a-1a50-43ad-ace6-045b0e7dd47a','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','406f66f5-ea30-4071-9d85-d6029d0fcb05',3),
('d0d01e00-0001-4000-8000-000000000094','MIT1105','Advanced Networking','96178a5a-1a50-43ad-ace6-045b0e7dd47a','22640f68-e8c9-43e7-bd70-59ba276acbbb','406f66f5-ea30-4071-9d85-d6029d0fcb05',3),
('d0d01e00-0001-4000-8000-000000000095','MIT1106','Cloud Infrastructure','96178a5a-1a50-43ad-ace6-045b0e7dd47a','def38337-4c53-49c3-b348-7612934115ad','406f66f5-ea30-4071-9d85-d6029d0fcb05',3),
('d0d01e00-0001-4000-8000-000000000096','MIT2101','Data Analytics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','406f66f5-ea30-4071-9d85-d6029d0fcb05',3),
('d0d01e00-0001-4000-8000-000000000097','MIT2102','Information Systems Security','96178a5a-1a50-43ad-ace6-045b0e7dd47a','c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','406f66f5-ea30-4071-9d85-d6029d0fcb05',3),
('d0d01e00-0001-4000-8000-000000000098','MIT2103','Project Management for IT Leaders','96178a5a-1a50-43ad-ace6-045b0e7dd47a','dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','406f66f5-ea30-4071-9d85-d6029d0fcb05',3),
('d0d01e00-0001-4000-8000-000000000099','MIT2104','Emerging Technologies','96178a5a-1a50-43ad-ace6-045b0e7dd47a','7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','406f66f5-ea30-4071-9d85-d6029d0fcb05',3),
('d0d01e00-0001-4000-8000-000000000100','MIT2105','Digital Transformation','96178a5a-1a50-43ad-ace6-045b0e7dd47a','aee10928-3a11-4b2e-9e41-0b34d0f2f19b','406f66f5-ea30-4071-9d85-d6029d0fcb05',3),
('d0d01e00-0001-4000-8000-000000000101','MIT2106','Masters Research Project','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','406f66f5-ea30-4071-9d85-d6029d0fcb05',6)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: BDSA (18)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000102','BDSA1101','Introduction to Data Science','96178a5a-1a50-43ad-ace6-045b0e7dd47a','1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000103','BDSA1102','Statistics for Data Science','96178a5a-1a50-43ad-ace6-045b0e7dd47a','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000104','BDSA1103','Python Programming for Analytics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','22640f68-e8c9-43e7-bd70-59ba276acbbb','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000105','BDSA1104','Mathematics for Data Science','96178a5a-1a50-43ad-ace6-045b0e7dd47a','def38337-4c53-49c3-b348-7612934115ad','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000106','BDSA1105','Data Wrangling and Preprocessing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000107','BDSA1106','Introduction to Machine Learning','96178a5a-1a50-43ad-ace6-045b0e7dd47a','c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000108','BDSA2101','Big Data Technologies','96178a5a-1a50-43ad-ace6-045b0e7dd47a','dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000109','BDSA2102','Data Visualisation','96178a5a-1a50-43ad-ace6-045b0e7dd47a','7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000110','BDSA2103','Database Systems for Analytics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','aee10928-3a11-4b2e-9e41-0b34d0f2f19b','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000111','BDSA2104','Deep Learning','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000112','BDSA2105','Natural Language Processing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000113','BDSA2106','Time Series Analysis','96178a5a-1a50-43ad-ace6-045b0e7dd47a','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000114','BDSA3101','Advanced Machine Learning','96178a5a-1a50-43ad-ace6-045b0e7dd47a','22640f68-e8c9-43e7-bd70-59ba276acbbb','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000115','BDSA3102','Business Intelligence','96178a5a-1a50-43ad-ace6-045b0e7dd47a','def38337-4c53-49c3-b348-7612934115ad','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000116','BDSA3103','Ethics in Data Science','96178a5a-1a50-43ad-ace6-045b0e7dd47a','6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','ec2c1740-c4d5-4056-854f-50cf368c00ab',2),
('d0d01e00-0001-4000-8000-000000000117','BDSA3104','Cloud Analytics Platforms','96178a5a-1a50-43ad-ace6-045b0e7dd47a','c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','ec2c1740-c4d5-4056-854f-50cf368c00ab',3),
('d0d01e00-0001-4000-8000-000000000118','BDSA3105','Data Science Project','96178a5a-1a50-43ad-ace6-045b0e7dd47a','dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','ec2c1740-c4d5-4056-854f-50cf368c00ab',6),
('d0d01e00-0001-4000-8000-000000000119','BDSA3106','Research Methods in Data Science','96178a5a-1a50-43ad-ace6-045b0e7dd47a','7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','ec2c1740-c4d5-4056-854f-50cf368c00ab',2)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: DDSA (12)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000120','DDSA1101','Introduction to Data Analysis','96178a5a-1a50-43ad-ace6-045b0e7dd47a','aee10928-3a11-4b2e-9e41-0b34d0f2f19b','88dfce47-1365-4820-be5c-669abfc2dd42',3),
('d0d01e00-0001-4000-8000-000000000121','DDSA1102','Statistics Fundamentals','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','88dfce47-1365-4820-be5c-669abfc2dd42',3),
('d0d01e00-0001-4000-8000-000000000122','DDSA1103','Spreadsheet and Data Tools','96178a5a-1a50-43ad-ace6-045b0e7dd47a','1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','88dfce47-1365-4820-be5c-669abfc2dd42',3),
('d0d01e00-0001-4000-8000-000000000123','DDSA1104','Introduction to Python','96178a5a-1a50-43ad-ace6-045b0e7dd47a','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','88dfce47-1365-4820-be5c-669abfc2dd42',3),
('d0d01e00-0001-4000-8000-000000000124','DDSA1105','Data Collection and Cleaning','96178a5a-1a50-43ad-ace6-045b0e7dd47a','22640f68-e8c9-43e7-bd70-59ba276acbbb','88dfce47-1365-4820-be5c-669abfc2dd42',3),
('d0d01e00-0001-4000-8000-000000000125','DDSA1106','Basic Data Visualisation','96178a5a-1a50-43ad-ace6-045b0e7dd47a','def38337-4c53-49c3-b348-7612934115ad','88dfce47-1365-4820-be5c-669abfc2dd42',3),
('d0d01e00-0001-4000-8000-000000000126','DDSA2101','Machine Learning Basics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','88dfce47-1365-4820-be5c-669abfc2dd42',3),
('d0d01e00-0001-4000-8000-000000000127','DDSA2102','Database for Analytics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','88dfce47-1365-4820-be5c-669abfc2dd42',3),
('d0d01e00-0001-4000-8000-000000000128','DDSA2103','Business Data Analysis','96178a5a-1a50-43ad-ace6-045b0e7dd47a','dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','88dfce47-1365-4820-be5c-669abfc2dd42',3),
('d0d01e00-0001-4000-8000-000000000129','DDSA2104','Reporting and Dashboards','96178a5a-1a50-43ad-ace6-045b0e7dd47a','7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','88dfce47-1365-4820-be5c-669abfc2dd42',3),
('d0d01e00-0001-4000-8000-000000000130','DDSA2105','Data Ethics and Governance','96178a5a-1a50-43ad-ace6-045b0e7dd47a','aee10928-3a11-4b2e-9e41-0b34d0f2f19b','88dfce47-1365-4820-be5c-669abfc2dd42',2),
('d0d01e00-0001-4000-8000-000000000131','DDSA2106','Diploma Data Project','96178a5a-1a50-43ad-ace6-045b0e7dd47a','47835404-5a90-4960-bee7-2b7cb6f9f4df','88dfce47-1365-4820-be5c-669abfc2dd42',6)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: BBA (22)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000132','BBA1101','Principles of Management','0d35fa69-de7f-4e05-b800-16c07321e75f','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000133','BBA1102','Financial Accounting','0d35fa69-de7f-4e05-b800-16c07321e75f','a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000134','BBA1103','Business Mathematics','0d35fa69-de7f-4e05-b800-16c07321e75f','b24b5d9e-6c6f-4e60-97b8-d9e0f1a2b3c4','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000135','BBA1104','Business Communication Skills','0d35fa69-de7f-4e05-b800-16c07321e75f','c35c6eaf-7d70-4f70-88c9-e0f1a2b3c4d5','46a86d77-2f4c-4f44-a5ed-83d51354b863',2),
('d0d01e00-0001-4000-8000-000000000136','BBA1105','Micro Economics','0d35fa69-de7f-4e05-b800-16c07321e75f','d46d7fba-8e80-4080-89d0-f1a2b3c4d5e6','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000137','BBA1106','Introduction to Business Law','0d35fa69-de7f-4e05-b800-16c07321e75f','e57e8acb-9f90-4090-80e1-a2b3c4d5e6f7','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000138','BBA2101','Human Resource Management','0d35fa69-de7f-4e05-b800-16c07321e75f','f68f9bdc-0fa0-4fa0-a1f2-b3c4d5e6f7a8','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000139','BBA2102','Marketing Management','0d35fa69-de7f-4e05-b800-16c07321e75f','a79a0ced-1fb1-4fb1-b2a3-c4d5e6f7a8b9','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000140','BBA2103','Organisational Behaviour','0d35fa69-de7f-4e05-b800-16c07321e75f','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000141','BBA2104','Cost and Management Accounting','0d35fa69-de7f-4e05-b800-16c07321e75f','a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000142','BBA2105','Business Statistics','0d35fa69-de7f-4e05-b800-16c07321e75f','b24b5d9e-6c6f-4e60-97b8-d9e0f1a2b3c4','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000143','BBA2106','Operations Management','0d35fa69-de7f-4e05-b800-16c07321e75f','c35c6eaf-7d70-4f70-88c9-e0f1a2b3c4d5','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000144','BBA2201','Financial Management','0d35fa69-de7f-4e05-b800-16c07321e75f','d46d7fba-8e80-4080-89d0-f1a2b3c4d5e6','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000145','BBA2202','Entrepreneurship','0d35fa69-de7f-4e05-b800-16c07321e75f','e57e8acb-9f90-4090-80e1-a2b3c4d5e6f7','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000146','BBA2203','Supply Chain Management','0d35fa69-de7f-4e05-b800-16c07321e75f','f68f9bdc-0fa0-4fa0-a1f2-b3c4d5e6f7a8','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000147','BBA2204','Strategic Management','0d35fa69-de7f-4e05-b800-16c07321e75f','a79a0ced-1fb1-4fb1-b2a3-c4d5e6f7a8b9','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000148','BBA3101','International Business','0d35fa69-de7f-4e05-b800-16c07321e75f','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000149','BBA3102','Business Research Methods','0d35fa69-de7f-4e05-b800-16c07321e75f','a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3','46a86d77-2f4c-4f44-a5ed-83d51354b863',2),
('d0d01e00-0001-4000-8000-000000000150','BBA3103','Corporate Governance','0d35fa69-de7f-4e05-b800-16c07321e75f','b24b5d9e-6c6f-4e60-97b8-d9e0f1a2b3c4','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000151','BBA3104','E-Business','0d35fa69-de7f-4e05-b800-16c07321e75f','c35c6eaf-7d70-4f70-88c9-e0f1a2b3c4d5','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000152','BBA3105','Project Management','0d35fa69-de7f-4e05-b800-16c07321e75f','d46d7fba-8e80-4080-89d0-f1a2b3c4d5e6','46a86d77-2f4c-4f44-a5ed-83d51354b863',3),
('d0d01e00-0001-4000-8000-000000000153','BBA3106','Business Project','0d35fa69-de7f-4e05-b800-16c07321e75f','e57e8acb-9f90-4090-80e1-a2b3c4d5e6f7','46a86d77-2f4c-4f44-a5ed-83d51354b863',6)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: DBA (14)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000154','DBA1101','Business Fundamentals','0d35fa69-de7f-4e05-b800-16c07321e75f','f68f9bdc-0fa0-4fa0-a1f2-b3c4d5e6f7a8','41e287d8-9ca6-412e-9a3c-ed2e389036da',3),
('d0d01e00-0001-4000-8000-000000000155','DBA1102','Bookkeeping and Accounts','0d35fa69-de7f-4e05-b800-16c07321e75f','a79a0ced-1fb1-4fb1-b2a3-c4d5e6f7a8b9','41e287d8-9ca6-412e-9a3c-ed2e389036da',3),
('d0d01e00-0001-4000-8000-000000000156','DBA1103','Business Communication','0d35fa69-de7f-4e05-b800-16c07321e75f','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78','41e287d8-9ca6-412e-9a3c-ed2e389036da',2),
('d0d01e00-0001-4000-8000-000000000157','DBA1104','Introduction to Marketing','0d35fa69-de7f-4e05-b800-16c07321e75f','a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3','41e287d8-9ca6-412e-9a3c-ed2e389036da',3),
('d0d01e00-0001-4000-8000-000000000158','DBA1105','Office Administration','0d35fa69-de7f-4e05-b800-16c07321e75f','b24b5d9e-6c6f-4e60-97b8-d9e0f1a2b3c4','41e287d8-9ca6-412e-9a3c-ed2e389036da',3),
('d0d01e00-0001-4000-8000-000000000159','DBA1106','Business Mathematics','0d35fa69-de7f-4e05-b800-16c07321e75f','c35c6eaf-7d70-4f70-88c9-e0f1a2b3c4d5','41e287d8-9ca6-412e-9a3c-ed2e389036da',3),
('d0d01e00-0001-4000-8000-000000000160','DBA1107','Entrepreneurship Basics','0d35fa69-de7f-4e05-b800-16c07321e75f','d46d7fba-8e80-4080-89d0-f1a2b3c4d5e6','41e287d8-9ca6-412e-9a3c-ed2e389036da',3),
('d0d01e00-0001-4000-8000-000000000161','DBA2101','Financial Records Management','0d35fa69-de7f-4e05-b800-16c07321e75f','e57e8acb-9f90-4090-80e1-a2b3c4d5e6f7','41e287d8-9ca6-412e-9a3c-ed2e389036da',3),
('d0d01e00-0001-4000-8000-000000000162','DBA2102','Human Resource Basics','0d35fa69-de7f-4e05-b800-16c07321e75f','f68f9bdc-0fa0-4fa0-a1f2-b3c4d5e6f7a8','41e287d8-9ca6-412e-9a3c-ed2e389036da',3),
('d0d01e00-0001-4000-8000-000000000163','DBA2103','Business Law','0d35fa69-de7f-4e05-b800-16c07321e75f','a79a0ced-1fb1-4fb1-b2a3-c4d5e6f7a8b9','41e287d8-9ca6-412e-9a3c-ed2e389036da',3),
('d0d01e00-0001-4000-8000-000000000164','DBA2104','Customer Relations Management','0d35fa69-de7f-4e05-b800-16c07321e75f','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78','41e287d8-9ca6-412e-9a3c-ed2e389036da',3),
('d0d01e00-0001-4000-8000-000000000165','DBA2105','Project Planning','0d35fa69-de7f-4e05-b800-16c07321e75f','a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3','41e287d8-9ca6-412e-9a3c-ed2e389036da',3),
('d0d01e00-0001-4000-8000-000000000166','DBA2106','Business Computing','0d35fa69-de7f-4e05-b800-16c07321e75f','b24b5d9e-6c6f-4e60-97b8-d9e0f1a2b3c4','41e287d8-9ca6-412e-9a3c-ed2e389036da',3),
('d0d01e00-0001-4000-8000-000000000167','DBA2107','Diploma Business Project','0d35fa69-de7f-4e05-b800-16c07321e75f','c35c6eaf-7d70-4f70-88c9-e0f1a2b3c4d5','41e287d8-9ca6-412e-9a3c-ed2e389036da',6)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: MBA (12)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000168','MBA1101','Managerial Economics','0d35fa69-de7f-4e05-b800-16c07321e75f','d46d7fba-8e80-4080-89d0-f1a2b3c4d5e6','7ccf2f00-fc18-49f2-a479-52e834f32aaa',4),
('d0d01e00-0001-4000-8000-000000000169','MBA1102','Financial Analysis and Reporting','0d35fa69-de7f-4e05-b800-16c07321e75f','e57e8acb-9f90-4090-80e1-a2b3c4d5e6f7','7ccf2f00-fc18-49f2-a479-52e834f32aaa',4),
('d0d01e00-0001-4000-8000-000000000170','MBA1103','Organisational Leadership','0d35fa69-de7f-4e05-b800-16c07321e75f','f68f9bdc-0fa0-4fa0-a1f2-b3c4d5e6f7a8','7ccf2f00-fc18-49f2-a479-52e834f32aaa',3),
('d0d01e00-0001-4000-8000-000000000171','MBA1104','Research Methods in Business','0d35fa69-de7f-4e05-b800-16c07321e75f','a79a0ced-1fb1-4fb1-b2a3-c4d5e6f7a8b9','7ccf2f00-fc18-49f2-a479-52e834f32aaa',3),
('d0d01e00-0001-4000-8000-000000000172','MBA1105','Corporate Strategy','0d35fa69-de7f-4e05-b800-16c07321e75f','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78','7ccf2f00-fc18-49f2-a479-52e834f32aaa',3),
('d0d01e00-0001-4000-8000-000000000173','MBA1106','Marketing Strategy','0d35fa69-de7f-4e05-b800-16c07321e75f','a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3','7ccf2f00-fc18-49f2-a479-52e834f32aaa',3),
('d0d01e00-0001-4000-8000-000000000174','MBA2101','International Finance','0d35fa69-de7f-4e05-b800-16c07321e75f','b24b5d9e-6c6f-4e60-97b8-d9e0f1a2b3c4','7ccf2f00-fc18-49f2-a479-52e834f32aaa',3),
('d0d01e00-0001-4000-8000-000000000175','MBA2102','Business Analytics','0d35fa69-de7f-4e05-b800-16c07321e75f','c35c6eaf-7d70-4f70-88c9-e0f1a2b3c4d5','7ccf2f00-fc18-49f2-a479-52e834f32aaa',3),
('d0d01e00-0001-4000-8000-000000000176','MBA2103','Change Management','0d35fa69-de7f-4e05-b800-16c07321e75f','d46d7fba-8e80-4080-89d0-f1a2b3c4d5e6','7ccf2f00-fc18-49f2-a479-52e834f32aaa',3),
('d0d01e00-0001-4000-8000-000000000177','MBA2104','Ethics and Corporate Governance','0d35fa69-de7f-4e05-b800-16c07321e75f','e57e8acb-9f90-4090-80e1-a2b3c4d5e6f7','7ccf2f00-fc18-49f2-a479-52e834f32aaa',3),
('d0d01e00-0001-4000-8000-000000000178','MBA2105','Innovation and Entrepreneurship','0d35fa69-de7f-4e05-b800-16c07321e75f','f68f9bdc-0fa0-4fa0-a1f2-b3c4d5e6f7a8','7ccf2f00-fc18-49f2-a479-52e834f32aaa',3),
('d0d01e00-0001-4000-8000-000000000179','MBA2106','MBA Research Project','0d35fa69-de7f-4e05-b800-16c07321e75f','a79a0ced-1fb1-4fb1-b2a3-c4d5e6f7a8b9','7ccf2f00-fc18-49f2-a479-52e834f32aaa',6)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: BJCS (20)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000180','BJCS1101','Introduction to Journalism','422a6c15-127f-47d5-a044-e7547d35dcb6','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000181','BJCS1102','Communication Theory','422a6c15-127f-47d5-a044-e7547d35dcb6','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000182','BJCS1103','Writing for Media','422a6c15-127f-47d5-a044-e7547d35dcb6','da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000183','BJCS1104','Media Law and Ethics','422a6c15-127f-47d5-a044-e7547d35dcb6','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000184','BJCS1105','Introduction to Broadcasting','422a6c15-127f-47d5-a044-e7547d35dcb6','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000185','BJCS2101','Reporting and Editing','422a6c15-127f-47d5-a044-e7547d35dcb6','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000186','BJCS2102','Digital Journalism','422a6c15-127f-47d5-a044-e7547d35dcb6','be617354-8fe8-4fe8-89ba-d1e2f3a4b5c6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000187','BJCS2103','Public Relations','422a6c15-127f-47d5-a044-e7547d35dcb6','cf728465-9fe9-4fe9-8acb-e2f3a4b5c6d7','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000188','BJCS2104','Media Production','422a6c15-127f-47d5-a044-e7547d35dcb6','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000189','BJCS2105','Social Media Communication','422a6c15-127f-47d5-a044-e7547d35dcb6','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000190','BJCS2201','Investigative Journalism','422a6c15-127f-47d5-a044-e7547d35dcb6','da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000191','BJCS2202','Television Production','422a6c15-127f-47d5-a044-e7547d35dcb6','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000192','BJCS2203','Radio Broadcasting','422a6c15-127f-47d5-a044-e7547d35dcb6','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000193','BJCS2204','Photojournalism','422a6c15-127f-47d5-a044-e7547d35dcb6','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000194','BJCS3101','Media Management','422a6c15-127f-47d5-a044-e7547d35dcb6','be617354-8fe8-4fe8-89ba-d1e2f3a4b5c6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000195','BJCS3102','International Communication','422a6c15-127f-47d5-a044-e7547d35dcb6','cf728465-9fe9-4fe9-8acb-e2f3a4b5c6d7','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000196','BJCS3103','Research Methods in Communication','422a6c15-127f-47d5-a044-e7547d35dcb6','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',2),
('d0d01e00-0001-4000-8000-000000000197','BJCS3104','Development Communication','422a6c15-127f-47d5-a044-e7547d35dcb6','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000198','BJCS3105','Journalism Project','422a6c15-127f-47d5-a044-e7547d35dcb6','da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',6),
('d0d01e00-0001-4000-8000-000000000199','BJCS3106','New Media and Society','422a6c15-127f-47d5-a044-e7547d35dcb6','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: BPAM (20)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000200','BPAM1101','Introduction to Public Administration','422a6c15-127f-47d5-a044-e7547d35dcb6','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000201','BPAM1102','Constitutional and Administrative Law','422a6c15-127f-47d5-a044-e7547d35dcb6','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000202','BPAM1103','Political Science','422a6c15-127f-47d5-a044-e7547d35dcb6','be617354-8fe8-4fe8-89ba-d1e2f3a4b5c6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000203','BPAM1104','Sociology','422a6c15-127f-47d5-a044-e7547d35dcb6','cf728465-9fe9-4fe9-8acb-e2f3a4b5c6d7','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000204','BPAM1105','Communication Skills','422a6c15-127f-47d5-a044-e7547d35dcb6','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',2),
('d0d01e00-0001-4000-8000-000000000205','BPAM2101','Public Policy Analysis','422a6c15-127f-47d5-a044-e7547d35dcb6','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000206','BPAM2102','Local Government Administration','422a6c15-127f-47d5-a044-e7547d35dcb6','da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000207','BPAM2103','Human Resource Management in Public Sector','422a6c15-127f-47d5-a044-e7547d35dcb6','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000208','BPAM2104','Public Finance Management','422a6c15-127f-47d5-a044-e7547d35dcb6','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000209','BPAM2105','Development Administration','422a6c15-127f-47d5-a044-e7547d35dcb6','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000210','BPAM2201','Ethics in Public Administration','422a6c15-127f-47d5-a044-e7547d35dcb6','be617354-8fe8-4fe8-89ba-d1e2f3a4b5c6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000211','BPAM2202','E-Government','422a6c15-127f-47d5-a044-e7547d35dcb6','cf728465-9fe9-4fe9-8acb-e2f3a4b5c6d7','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000212','BPAM2203','Research Methods','422a6c15-127f-47d5-a044-e7547d35dcb6','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',2),
('d0d01e00-0001-4000-8000-000000000213','BPAM2204','Governance and Democracy','422a6c15-127f-47d5-a044-e7547d35dcb6','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000214','BPAM3101','Strategic Management in Public Sector','422a6c15-127f-47d5-a044-e7547d35dcb6','da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000215','BPAM3102','Anti-Corruption and Accountability','422a6c15-127f-47d5-a044-e7547d35dcb6','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000216','BPAM3103','Regional Integration','422a6c15-127f-47d5-a044-e7547d35dcb6','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000217','BPAM3104','Disaster Management','422a6c15-127f-47d5-a044-e7547d35dcb6','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000218','BPAM3105','Public Administration Project','422a6c15-127f-47d5-a044-e7547d35dcb6','be617354-8fe8-4fe8-89ba-d1e2f3a4b5c6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',6),
('d0d01e00-0001-4000-8000-000000000219','BPAM3106','NGO and Civil Society Management','422a6c15-127f-47d5-a044-e7547d35dcb6','cf728465-9fe9-4fe9-8acb-e2f3a4b5c6d7','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: BIRDS (18)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000220','BIRDS1101','Introduction to International Relations','422a6c15-127f-47d5-a044-e7547d35dcb6','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000221','BIRDS1102','History of International Relations','422a6c15-127f-47d5-a044-e7547d35dcb6','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000222','BIRDS1103','Diplomatic Theory and Practice','422a6c15-127f-47d5-a044-e7547d35dcb6','da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000223','BIRDS1104','Political Science Foundations','422a6c15-127f-47d5-a044-e7547d35dcb6','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000224','BIRDS1105','International Law','422a6c15-127f-47d5-a044-e7547d35dcb6','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000225','BIRDS2101','Foreign Policy Analysis','422a6c15-127f-47d5-a044-e7547d35dcb6','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000226','BIRDS2102','International Security Studies','422a6c15-127f-47d5-a044-e7547d35dcb6','be617354-8fe8-4fe8-89ba-d1e2f3a4b5c6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000227','BIRDS2103','International Organisations','422a6c15-127f-47d5-a044-e7547d35dcb6','cf728465-9fe9-4fe9-8acb-e2f3a4b5c6d7','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000228','BIRDS2104','Conflict Resolution and Peacebuilding','422a6c15-127f-47d5-a044-e7547d35dcb6','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000229','BIRDS2105','African Politics','422a6c15-127f-47d5-a044-e7547d35dcb6','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000230','BIRDS2201','International Trade and Economics','422a6c15-127f-47d5-a044-e7547d35dcb6','da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000231','BIRDS2202','Human Rights and International Law','422a6c15-127f-47d5-a044-e7547d35dcb6','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000232','BIRDS2203','Research Methods in IR','422a6c15-127f-47d5-a044-e7547d35dcb6','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',2),
('d0d01e00-0001-4000-8000-000000000233','BIRDS3101','Regional Integration in Africa','422a6c15-127f-47d5-a044-e7547d35dcb6','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000234','BIRDS3102','Diplomacy Practicum','422a6c15-127f-47d5-a044-e7547d35dcb6','be617354-8fe8-4fe8-89ba-d1e2f3a4b5c6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000235','BIRDS3103','Terrorism and Counter-Terrorism','422a6c15-127f-47d5-a044-e7547d35dcb6','cf728465-9fe9-4fe9-8acb-e2f3a4b5c6d7','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000236','BIRDS3104','International Development','422a6c15-127f-47d5-a044-e7547d35dcb6','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000237','BIRDS3105','International Relations Project','422a6c15-127f-47d5-a044-e7547d35dcb6','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa',6)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: BEHS (18)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000238','BEHS1101','Introduction to Environmental Health','422a6c15-127f-47d5-a044-e7547d35dcb6','da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000239','BEHS1102','Human Biology','422a6c15-127f-47d5-a044-e7547d35dcb6','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000240','BEHS1103','Environmental Science','422a6c15-127f-47d5-a044-e7547d35dcb6','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000241','BEHS1104','Epidemiology Basics','422a6c15-127f-47d5-a044-e7547d35dcb6','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000242','BEHS1105','Community Health','422a6c15-127f-47d5-a044-e7547d35dcb6','be617354-8fe8-4fe8-89ba-d1e2f3a4b5c6','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000243','BEHS2101','Occupational Health and Safety','422a6c15-127f-47d5-a044-e7547d35dcb6','cf728465-9fe9-4fe9-8acb-e2f3a4b5c6d7','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000244','BEHS2102','Water and Sanitation','422a6c15-127f-47d5-a044-e7547d35dcb6','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000245','BEHS2103','Food Safety and Hygiene','422a6c15-127f-47d5-a044-e7547d35dcb6','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000246','BEHS2104','Vector Control','422a6c15-127f-47d5-a044-e7547d35dcb6','da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000247','BEHS2105','Environmental Pollution','422a6c15-127f-47d5-a044-e7547d35dcb6','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000248','BEHS2201','Health Policy and Management','422a6c15-127f-47d5-a044-e7547d35dcb6','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000249','BEHS2202','Environmental Impact Assessment','422a6c15-127f-47d5-a044-e7547d35dcb6','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000250','BEHS2203','Research Methods in Env Health','422a6c15-127f-47d5-a044-e7547d35dcb6','be617354-8fe8-4fe8-89ba-d1e2f3a4b5c6','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',2),
('d0d01e00-0001-4000-8000-000000000251','BEHS3101','Climate Change and Health','422a6c15-127f-47d5-a044-e7547d35dcb6','cf728465-9fe9-4fe9-8acb-e2f3a4b5c6d7','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000252','BEHS3102','Industrial Hygiene','422a6c15-127f-47d5-a044-e7547d35dcb6','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000253','BEHS3103','Environmental Law','422a6c15-127f-47d5-a044-e7547d35dcb6','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000254','BEHS3104','Health Promotion','422a6c15-127f-47d5-a044-e7547d35dcb6','da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',3),
('d0d01e00-0001-4000-8000-000000000255','BEHS3105','Environmental Health Project','422a6c15-127f-47d5-a044-e7547d35dcb6','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa',6)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: BPH (18)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000256','BPH1101','Introduction to Public Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000257','BPH1102','Human Anatomy and Physiology','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000258','BPH1103','Biostatistics I','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000259','BPH1104','Health Education and Promotion','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000260','BPH1105','Environmental Health Fundamentals','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000261','BPH2101','Epidemiology','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',4),
('d0d01e00-0001-4000-8000-000000000262','BPH2102','Communicable Disease Control','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000263','BPH2103','Non-Communicable Diseases','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000264','BPH2104','Maternal and Child Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000265','BPH2105','Health Systems Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000266','BPH2201','Nutrition and Public Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000267','BPH2202','Research Methods in Public Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',2),
('d0d01e00-0001-4000-8000-000000000268','BPH2203','Health Economics','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000269','BPH3101','Global Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000270','BPH3102','Health Policy and Planning','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000271','BPH3103','Mental Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000272','BPH3104','One Health Approach','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000273','BPH3105','Public Health Project','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',6)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- Modules: MPH (12), ADHM (8), MSS (10), MEM (10), MPM (12), MIRDS (10)
INSERT INTO modules(id,code,name,department_id,lecturer_id,programme_id,credit_units) VALUES
('d0d01e00-0001-4000-8000-000000000274','MPH1101','Principles of Epidemiology','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb',4),
('d0d01e00-0001-4000-8000-000000000275','MPH1102','Biostatistics','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb',4),
('d0d01e00-0001-4000-8000-000000000276','MPH1103','Health Policy and Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000277','MPH1104','Research Methods in Public Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000278','MPH1105','Global Health Issues','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000279','MPH1106','Environmental and Occupational Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000280','MPH2101','Infectious Disease Epidemiology','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000281','MPH2102','Health Systems Strengthening','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000282','MPH2103','NCD Prevention','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000283','MPH2104','Maternal and Reproductive Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000284','MPH2105','Leadership in Public Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000285','MPH2106','MPH Research Dissertation','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb',6),
('d0d01e00-0001-4000-8000-000000000286','ADHM1101','Health Systems and Services','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000287','ADHM1102','Health Management Principles','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000288','ADHM1103','Health Economics','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000289','ADHM1104','Human Resources for Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000290','ADHM1105','Healthcare Quality Improvement','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000291','ADHM1106','Health Information Systems','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000292','ADHM1107','Leadership and Governance in Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000293','ADHM1108','Advanced Diploma Health Project','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb',6),
('d0d01e00-0001-4000-8000-000000000294','MSS1101','Sociological Theory','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000295','MSS1102','Research Methods in Social Sciences','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000296','MSS1103','Social Policy Analysis','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000297','MSS1104','Political Economy','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000298','MSS1105','Gender and Development','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000299','MSS2101','Environmental Sociology','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000300','MSS2102','Public Policy and Governance','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000301','MSS2103','African Development Studies','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000302','MSS2104','Community Development','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000303','MSS2105','MSS Research Dissertation','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb',6),
('d0d01e00-0001-4000-8000-000000000304','MEM1101','Environmental Management Systems','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000305','MEM1102','Natural Resource Economics','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000306','MEM1103','Research Methods in Env Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000307','MEM1104','Environmental Law and Policy','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000308','MEM1105','Climate Change Mitigation and Adaptation','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000309','MEM2101','Conservation Biology','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000310','MEM2102','Environmental Impact Assessment','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000311','MEM2103','Sustainable Development','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000312','MEM2104','Water Resource Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000313','MEM2105','MEM Research Dissertation','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb',6),
('d0d01e00-0001-4000-8000-000000000314','MPM1101','Project Planning and Design','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000315','MPM1102','Project Finance and Budgeting','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000316','MPM1103','Risk Management in Projects','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000317','MPM1104','Research Methods for Project Managers','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000318','MPM1105','Monitoring and Evaluation','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000319','MPM1106','Stakeholder Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000320','MPM2101','Project Leadership and Teams','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000321','MPM2102','Infrastructure Project Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000322','MPM2103','Procurement Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000323','MPM2104','Programme Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000324','MPM2105','Digital Tools for Project Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000325','MPM2106','MPM Research Project','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb',6),
('d0d01e00-0001-4000-8000-000000000326','MIRDS1101','International Relations Theory','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000327','MIRDS1102','Diplomatic Studies','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000328','MIRDS1103','International Security','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000329','MIRDS1104','Research Methods in IR and DS','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000330','MIRDS1105','International Law and Treaties','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000331','MIRDS2101','African Integration and Development','06a806fc-0d90-4c27-877d-1025a3ebdbd1','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000332','MIRDS2102','Conflict and Peace Studies','06a806fc-0d90-4c27-877d-1025a3ebdbd1','e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000333','MIRDS2103','International Trade Policy','06a806fc-0d90-4c27-877d-1025a3ebdbd1','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000334','MIRDS2104','Foreign Policy Analysis','06a806fc-0d90-4c27-877d-1025a3ebdbd1','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',3),
('d0d01e00-0001-4000-8000-000000000335','MIRDS2105','MIRDS Research Dissertation','06a806fc-0d90-4c27-877d-1025a3ebdbd1','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb',6)
ON CONFLICT(code) DO UPDATE SET name=EXCLUDED.name,lecturer_id=EXCLUDED.lecturer_id,programme_id=EXCLUDED.programme_id,credit_units=EXCLUDED.credit_units;

-- ── Facilities: 29 Lecture Rooms ──────────────────────────────────────────────
-- FST Block A (12 rooms)
INSERT INTO facilities(id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES
('f1000001-0000-0000-0000-000000000001','LR1 - Lecture Hall A','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Ground Floor','East','LR1','Main lecture hall, ground floor Block A',0.317300,32.571600,120,'active','static_geo',50,'a1b2c3d4e5f6a1b2c3d4e5f6a1b2c3d4',1),
('f1000001-0000-0000-0000-000000000002','LR2 - Lecture Hall B','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Ground Floor','West','LR2','Ground floor west wing Block A',0.317400,32.571700,100,'active','static_geo',50,'b2c3d4e5f6a7b2c3d4e5f6a7b2c3d4e5',1),
('f1000001-0000-0000-0000-000000000003','LR3 - Seminar Room A','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','First Floor','East','LR3','First floor seminar room east wing',0.317500,32.571800,60,'active','static_geo',50,'c3d4e5f6a7b8c3d4e5f6a7b8c3d4e5f6',1),
('f1000001-0000-0000-0000-000000000004','LR4 - Seminar Room B','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','First Floor','West','LR4','First floor seminar room west wing',0.317600,32.571900,60,'active','static_geo',50,'d4e5f6a7b8c9d4e5f6a7b8c9d4e5f6a7',1),
('f1000001-0000-0000-0000-000000000005','LR5 - Computer Lab A','computer_lab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Second Floor','East','LR5','FST computer lab east wing',0.317700,32.572000,40,'active','static_geo',50,'e5f6a7b8c9d0e5f6a7b8c9d0e5f6a7b8',1),
('f1000001-0000-0000-0000-000000000006','LR6 - Computer Lab B','computer_lab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Second Floor','West','LR6','FST computer lab west wing',0.317800,32.572100,40,'active','static_geo',50,'f6a7b8c9d0e1f6a7b8c9d0e1f6a7b8c9',1),
('f1000001-0000-0000-0000-000000000007','LR7 - Tutorial Room A','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Second Floor','North','LR7','Small tutorial room north wing',0.317900,32.572200,30,'active','static_geo',50,'a7b8c9d0e1f2a7b8c9d0e1f2a7b8c9d0',1),
('f1000001-0000-0000-0000-000000000008','LR8 - Tutorial Room B','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Second Floor','South','LR8','Small tutorial room south wing',0.318000,32.572300,30,'active','static_geo',50,'b8c9d0e1f2a3b8c9d0e1f2a3b8c9d0e1',1),
('f1000001-0000-0000-0000-000000000009','LR9 - Lecture Hall C','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Ground Floor','North','LR9','Large lecture hall north side',0.317100,32.571500,80,'active','static_geo',50,'c9d0e1f2a3b4c9d0e1f2a3b4c9d0e1f2',1),
('f1000001-0000-0000-0000-000000000010','LR10 - Seminar Room C','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','First Floor','North','LR10','Mid-size seminar room first floor',0.317200,32.571400,50,'active','static_geo',50,'d0e1f2a3b4c5d0e1f2a3b4c5d0e1f2a3',1),
('f1000001-0000-0000-0000-000000000011','LR11 - Computer Lab C','computer_lab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Third Floor','East','LR11','Advanced computing lab',0.318100,32.572400,35,'active','static_geo',50,'e1f2a3b4c5d6e1f2a3b4c5d6e1f2a3b4',1),
('f1000001-0000-0000-0000-000000000012','LR12 - Smart Classroom A','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','Block A','Third Floor','West','LR12','Smart classroom with projectors',0.318200,32.572500,45,'active','static_geo',50,'f2a3b4c5d6e7f2a3b4c5d6e7f2a3b4c5',1)
ON CONFLICT(id) DO UPDATE SET name=EXCLUDED.name,category=EXCLUDED.category,building=EXCLUDED.building,floor=EXCLUDED.floor,wing=EXCLUDED.wing,room_number=EXCLUDED.room_number,location_description=EXCLUDED.location_description,capacity=EXCLUDED.capacity,status=EXCLUDED.status,latitude=EXCLUDED.latitude,longitude=EXCLUDED.longitude;

-- BUS Block B (8 rooms)
INSERT INTO facilities(id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES
('f1000001-0000-0000-0000-000000000013','LR13 - Business Lecture Hall A','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','Ground Floor','East','LR13','Main business lecture hall',0.318500,32.572500,120,'active','static_geo',50,'a3b4c5d6e7f8a3b4c5d6e7f8a3b4c5d6',1),
('f1000001-0000-0000-0000-000000000014','LR14 - Business Lecture Hall B','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','Ground Floor','West','LR14','Secondary business lecture hall',0.318600,32.572600,80,'active','static_geo',50,'b4c5d6e7f8a9b4c5d6e7f8a9b4c5d6e7',1),
('f1000001-0000-0000-0000-000000000015','LR15 - Business Seminar Room A','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','First Floor','East','LR15','Business seminar room east',0.318700,32.572700,50,'active','static_geo',50,'c5d6e7f8a9b0c5d6e7f8a9b0c5d6e7f8',1),
('f1000001-0000-0000-0000-000000000016','LR16 - Business Seminar Room B','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','First Floor','West','LR16','Business seminar room west',0.318800,32.572800,40,'active','static_geo',50,'d6e7f8a9b0c1d6e7f8a9b0c1d6e7f8a9',1),
('f1000001-0000-0000-0000-000000000017','LR17 - Business Computer Lab','computer_lab','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','Second Floor','East','LR17','Business computing lab',0.318900,32.572900,30,'active','static_geo',50,'e7f8a9b0c1d2e7f8a9b0c1d2e7f8a9b0',1),
('f1000001-0000-0000-0000-000000000018','LR18 - Case Study Room A','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','Second Floor','West','LR18','MBA case study room',0.319000,32.573000,35,'active','static_geo',50,'f8a9b0c1d2e3f8a9b0c1d2e3f8a9b0c1',1),
('f1000001-0000-0000-0000-000000000019','LR19 - Case Study Room B','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','Second Floor','North','LR19','MBA case study room B',0.319100,32.573100,35,'active','static_geo',50,'a9b0c1d2e3f4a9b0c1d2e3f4a9b0c1d2',1),
('f1000001-0000-0000-0000-000000000020','LR20 - Business Tutorial Room','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','Block B','Third Floor','East','LR20','Small business tutorial room',0.319200,32.573200,30,'active','static_geo',50,'b0c1d2e3f4a5b0c1d2e3f4a5b0c1d2e3',1)
ON CONFLICT(id) DO UPDATE SET name=EXCLUDED.name,category=EXCLUDED.category,building=EXCLUDED.building,floor=EXCLUDED.floor,wing=EXCLUDED.wing,room_number=EXCLUDED.room_number,location_description=EXCLUDED.location_description,capacity=EXCLUDED.capacity,status=EXCLUDED.status,latitude=EXCLUDED.latitude,longitude=EXCLUDED.longitude;

-- SES Block C (5 rooms)
INSERT INTO facilities(id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES
('f1000001-0000-0000-0000-000000000021','LR21 - Social Sciences Lecture Hall','lecture_room','422a6c15-127f-47d5-a044-e7547d35dcb6','Block C','Ground Floor','East','LR21','Main social sciences lecture hall',0.319300,32.573200,100,'active','static_geo',50,'c1d2e3f4a5b6c1d2e3f4a5b6c1d2e3f4',1),
('f1000001-0000-0000-0000-000000000022','LR22 - Media Lab A','computer_lab','422a6c15-127f-47d5-a044-e7547d35dcb6','Block C','First Floor','East','LR22','Journalism media production lab',0.319400,32.573300,40,'active','static_geo',50,'d2e3f4a5b6c7d2e3f4a5b6c7d2e3f4a5',1),
('f1000001-0000-0000-0000-000000000023','LR23 - Media Lab B','computer_lab','422a6c15-127f-47d5-a044-e7547d35dcb6','Block C','First Floor','West','LR23','Journalism media lab B',0.319500,32.573400,35,'active','static_geo',50,'e3f4a5b6c7d8e3f4a5b6c7d8e3f4a5b6',1),
('f1000001-0000-0000-0000-000000000024','LR24 - Social Sciences Seminar Room','lecture_room','422a6c15-127f-47d5-a044-e7547d35dcb6','Block C','Second Floor','East','LR24','SES seminar and discussion room',0.319600,32.573500,50,'active','static_geo',50,'f4a5b6c7d8e9f4a5b6c7d8e9f4a5b6c7',1),
('f1000001-0000-0000-0000-000000000025','LR25 - Conference Room A','lecture_room','422a6c15-127f-47d5-a044-e7547d35dcb6','Block C','Second Floor','West','LR25','Multi-purpose conference room',0.319700,32.573600,45,'active','static_geo',50,'a5b6c7d8e9f0a5b6c7d8e9f0a5b6c7d8',1)
ON CONFLICT(id) DO UPDATE SET name=EXCLUDED.name,category=EXCLUDED.category,building=EXCLUDED.building,floor=EXCLUDED.floor,wing=EXCLUDED.wing,room_number=EXCLUDED.room_number,location_description=EXCLUDED.location_description,capacity=EXCLUDED.capacity,status=EXCLUDED.status,latitude=EXCLUDED.latitude,longitude=EXCLUDED.longitude;

-- HEC Block D (4 rooms)
INSERT INTO facilities(id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES
('f1000001-0000-0000-0000-000000000026','LR26 - Health Sciences Lecture Hall','lecture_room','06a806fc-0d90-4c27-877d-1025a3ebdbd1','Block D','Ground Floor','East','LR26','Main health sciences lecture hall',0.319800,32.573700,100,'active','static_geo',50,'b6c7d8e9f0a1b6c7d8e9f0a1b6c7d8e9',1),
('f1000001-0000-0000-0000-000000000027','LR27 - Health Sciences Lab A','computer_lab','06a806fc-0d90-4c27-877d-1025a3ebdbd1','Block D','First Floor','East','LR27','Public health computer lab',0.319900,32.573800,40,'active','static_geo',50,'c7d8e9f0a1b2c7d8e9f0a1b2c7d8e9f0',1),
('f1000001-0000-0000-0000-000000000028','LR28 - Health Sciences Seminar Room','lecture_room','06a806fc-0d90-4c27-877d-1025a3ebdbd1','Block D','First Floor','West','LR28','HEC seminar and tutorial room',0.320000,32.573900,50,'active','static_geo',50,'d8e9f0a1b2c3d8e9f0a1b2c3d8e9f0a1',1),
('f1000001-0000-0000-0000-000000000029','LR29 - Community Health Lab','lecture_room','06a806fc-0d90-4c27-877d-1025a3ebdbd1','Block D','Second Floor','East','LR29','Community health practical lab',0.320100,32.574000,35,'active','static_geo',50,'e9f0a1b2c3d4e9f0a1b2c3d4e9f0a1b2',1)
ON CONFLICT(id) DO UPDATE SET name=EXCLUDED.name,category=EXCLUDED.category,building=EXCLUDED.building,floor=EXCLUDED.floor,wing=EXCLUDED.wing,room_number=EXCLUDED.room_number,location_description=EXCLUDED.location_description,capacity=EXCLUDED.capacity,status=EXCLUDED.status,latitude=EXCLUDED.latitude,longitude=EXCLUDED.longitude;

COMMIT;
