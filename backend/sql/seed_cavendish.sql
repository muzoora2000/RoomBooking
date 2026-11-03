-- Cavendish University Uganda - Full Seed
-- Generated: 2026-11-03T18:38:42.465Z
-- 5 depts | 29 programmes | 106 classes | 146 lecturers | 563 modules | 47 rooms
-- 1182 class/module links | 1909 weekly timetable patterns expanded across 2026-08-03..2026-12-31
-- Safe to re-run: ON CONFLICT DO UPDATE / DO NOTHING

BEGIN;

-- Keep old demo "BUS" faculty from blocking the real Faculty of Business
UPDATE departments SET code = 'DEM-BUS' WHERE code = 'BUS' AND id <> '0d35fa69-de7f-4e05-b800-16c07321e75f';

-- Remove the invented LR1..LR29 rooms from the old seed when nothing references them
DELETE FROM facilities f WHERE f.room_number ~ '^LR[0-9]+$' AND NOT EXISTS (SELECT 1 FROM bookings b WHERE b.facility_id = f.id) AND NOT EXISTS (SELECT 1 FROM timetable_slots t WHERE t.facility_id = f.id);
UPDATE facilities SET status = 'blocked' WHERE room_number ~ '^LR[0-9]+$' AND status = 'active';

-- Extend modules table (idempotent, schema.sql also defines these)
ALTER TABLE modules ADD COLUMN IF NOT EXISTS programme_id UUID REFERENCES programmes(id) ON DELETE SET NULL;
ALTER TABLE modules ADD COLUMN IF NOT EXISTS credit_units INT NOT NULL DEFAULT 3;

-- Departments
INSERT INTO departments (id,code,name) VALUES ('96178a5a-1a50-43ad-ace6-045b0e7dd47a','FST','Faculty of Science and Technology') ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO departments (id,code,name) VALUES ('0d35fa69-de7f-4e05-b800-16c07321e75f','BUS','Faculty of Business') ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO departments (id,code,name) VALUES ('422a6c15-127f-47d5-a044-e7547d35dcb6','SES','Faculty of Social and Environmental Studies') ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO departments (id,code,name) VALUES ('06a806fc-0d90-4c27-877d-1025a3ebdbd1','HEC','Faculty of Health and Environmental Sciences') ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name;
INSERT INTO departments (id,code,name) VALUES ('5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','LAW','Faculty of Law') ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name;

-- Current semester
UPDATE semesters SET is_current = false WHERE is_current = true;
INSERT INTO semesters (id,name,start_date,end_date,is_current) VALUES ('af9a8e4b-4808-4b3f-b9c3-905be5215722','Semester I 2026/2027','2026-08-01','2026-12-31',true) ON CONFLICT (name) DO UPDATE SET start_date = EXCLUDED.start_date, end_date = EXCLUDED.end_date, is_current = true;

-- Programmes
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('73593c0f-0478-45b5-a87d-a8e87f5ea274','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BIT','Bachelor of Science in Information Technology',3) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('16fe7428-a4af-4fb3-a543-b1e0fad14ed5','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BSE','Bachelor of Science in Software Engineering',4) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BCS','Bachelor of Computer Science',3) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('ac00b024-3929-4702-9a14-b216830ab328','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DIT','Diploma in Information Technology',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('406f66f5-ea30-4071-9d85-d6029d0fcb05','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MIT','Master of Information Technology',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('ec2c1740-c4d5-4056-854f-50cf368c00ab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BDSA','Bachelor of Data Science and Analytics',3) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('88dfce47-1365-4820-be5c-669abfc2dd42','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DDSA','Diploma in Data Science and Analytics',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('e1b66000-0001-4000-8000-000000000005','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DCS','Diploma in Computer Science',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('e1b66000-0001-4000-8000-000000000006','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DDA','Diploma in Data Analytics',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('e1b66000-0001-4000-8000-000000000007','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BDA','Bachelor of Data Analytics',3) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA','Bachelor of Business Administration',3) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('41e287d8-9ca6-412e-9a3c-ed2e389036da','0d35fa69-de7f-4e05-b800-16c07321e75f','DBA','Diploma in Business Administration',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA','Master of Business Administration',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('e1b66000-0001-4000-8000-000000000008','0d35fa69-de7f-4e05-b800-16c07321e75f','DPL','Diploma in Public Law',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','0d35fa69-de7f-4e05-b800-16c07321e75f','MPM','Master of Project Management',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BJC','Bachelor of Journalism and Communication',3) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BPAM','Bachelor of Public Administration and Management',3) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BIRDS','Bachelor of International Relations and Diplomatic Studies',3) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','422a6c15-127f-47d5-a044-e7547d35dcb6','MSS','Master of Social Sciences',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb','422a6c15-127f-47d5-a044-e7547d35dcb6','MIRDS','Master of International Relations and Diplomatic Studies',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('e1b66000-0001-4000-8000-000000000004','422a6c15-127f-47d5-a044-e7547d35dcb6','MED','Master of Education',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','BPH','Bachelor of Public Health',3) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MPH','Master of Public Health',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','ADHM','Advanced Diploma in Health Management',1) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','06a806fc-0d90-4c27-877d-1025a3ebdbd1','BEHS','Bachelor of Environmental Health Sciences',3) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MEM','Master of Environmental Management',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('e1b66000-0001-4000-8000-000000000009','06a806fc-0d90-4c27-877d-1025a3ebdbd1','HEC','Health Sciences Programme',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('e1b66000-0001-4000-8000-000000000001','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','LLB','Bachelor of Laws',4) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;
INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES ('e1b66000-0001-4000-8000-000000000002','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','LLM','Master of Laws',2) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;

-- Classes
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('6df972e2-6a5c-4656-9b8a-d76caac50203','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','ADHM-Y1','ADHM Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('af317c51-d1d8-49d3-a448-082ce0e81485','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y1','BBA Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('d3868dda-1c76-458e-9369-8b87940dd73e','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y1-AF','BBA Year 1 AF',1,'Main','AF') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('a8553fc9-8b86-4d6d-b355-fe8ec22ea858','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y1-BF','BBA Year 1 BF',1,'Main','BF') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('23f511a1-d7d9-4b8e-87ba-36fc6df232c7','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y1-ENT','BBA Year 1 ENT',1,'Main','ENT') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('37e8f68c-389c-41f3-8158-19b95a0988e2','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y1-G','BBA Year 1 G',1,'Main','G') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('c056eb94-71b7-47d1-bdb8-9e1177dbc2b9','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y1-HRM','BBA Year 1 HRM',1,'Main','HRM') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('43c4ca5d-d57e-4140-a929-8e3dd263d606','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y1-MKT','BBA Year 1 MKT',1,'Main','MKT') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('764903b9-d84e-43da-91fb-63eab341539c','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y1-PL','BBA Year 1 PL',1,'Main','PL') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('889aaaad-46e8-4bbd-a02e-8d963a1283e7','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y1-W','BBA Year 1 W',1,'Main','W') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('4ac2932f-bf65-44db-b20e-01042d574687','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y2','BBA Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('acd6c44b-f365-4be7-a279-36f9a4c5c806','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y2-W','BBA Year 2 W',2,'Main','W') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('04b47555-876e-48e1-a1ea-219d94ff3a0d','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y3','BBA Year 3',3,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('6054c58b-81f9-4fd1-9787-73bf9a1ce49c','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y3-AF','BBA Year 3 AF',3,'Main','AF') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('90ac8c67-1cb7-47b0-a4f3-a0f00cbf1daa','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y3-BF','BBA Year 3 BF',3,'Main','BF') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('c6014504-85c1-43f2-8c5b-9849d6b0996f','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y3-G','BBA Year 3 G',3,'Main','G') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('4ec8411c-7ec4-4852-ad72-8b91325fa79a','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y3-HRM','BBA Year 3 HRM',3,'Main','HRM') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('7014b425-71c1-4904-b633-b97cc32e22a3','46a86d77-2f4c-4f44-a5ed-83d51354b863','0d35fa69-de7f-4e05-b800-16c07321e75f','BBA-Y3-PL','BBA Year 3 PL',3,'Main','PL') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('62ecc97f-c912-4023-81b3-3687f5862361','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BCS-Y1','BCS Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('5d0e2447-da98-4c00-9d36-1f41fc925f31','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BCS-Y2','BCS Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('4d2ce790-48d1-4c05-a2aa-2c5a5da8cc7b','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BCS-Y3','BCS Year 3',3,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('5e64e9f0-314d-4ce1-93fa-9599557a674b','e1b66000-0001-4000-8000-000000000007','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BDA-Y1','BDA Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('66ea294c-3d1a-4189-8bf1-760a79cdccb6','e1b66000-0001-4000-8000-000000000007','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BDA-Y2','BDA Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('de4488af-e7da-43ce-84d8-18c604f4a9b7','e1b66000-0001-4000-8000-000000000007','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BDA-Y3','BDA Year 3',3,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('24df3f9c-cf71-4dcb-aa6c-53a451f9073f','ec2c1740-c4d5-4056-854f-50cf368c00ab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BDSA-Y1','BDSA Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('78ae03c7-c5f4-4279-b040-3707a378bcff','ec2c1740-c4d5-4056-854f-50cf368c00ab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BDSA-Y1-ONLINE','BDSA Year 1 ONLINE',1,'Main','ONLINE') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('2a7adbfb-77fd-41ec-9134-6c56dad9005a','ec2c1740-c4d5-4056-854f-50cf368c00ab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BDSA-Y2','BDSA Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('64d7dc0d-68c4-4e8d-8f41-837762de3813','ec2c1740-c4d5-4056-854f-50cf368c00ab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BDSA-Y3','BDSA Year 3',3,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('d2f9728f-0bcf-4a96-9eaa-d0758cb894e1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','06a806fc-0d90-4c27-877d-1025a3ebdbd1','BEHS-Y1','BEHS Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('b7de13d4-a049-4658-8b75-b55695a1f1fd','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','06a806fc-0d90-4c27-877d-1025a3ebdbd1','BEHS-Y2','BEHS Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('934403d1-15ea-454e-abff-4a188fd8c90b','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','06a806fc-0d90-4c27-877d-1025a3ebdbd1','BEHS-Y3','BEHS Year 3',3,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('ae8c6886-e910-4fb8-9c2f-4eef8c29691f','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BIRDS-Y1','BIRDS Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('17db8684-e51b-4bb8-b8f8-c05a520f6d61','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BIRDS-Y2','BIRDS Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('3c13da1c-3391-465e-ac48-2d8bae7abc77','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BIRDS-Y3','BIRDS Year 3',3,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('94cae4bb-e960-4b57-ba86-9c3f19fe67db','73593c0f-0478-45b5-a87d-a8e87f5ea274','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BIT-Y1','BIT Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('1095d691-b2d4-455f-acd0-2f1746b13109','73593c0f-0478-45b5-a87d-a8e87f5ea274','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BIT-Y2','BIT Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('bf54ac12-ad2c-4f83-a54b-1f0809114cd9','73593c0f-0478-45b5-a87d-a8e87f5ea274','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BIT-Y3','BIT Year 3',3,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('c28c9812-1acc-4304-b3c7-bc4ef58ba11d','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BJC-Y1','BJC Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('ad09ba55-b58a-4773-975b-f617d002267e','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BJC-Y2','BJC Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('07db7dd8-81d6-466f-836a-86540c6a3486','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BJC-Y3','BJC Year 3',3,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('109b1d40-a117-4b47-a452-4c68da6e82f8','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BJC-Y3-J','BJC Year 3 J',3,'Main','J') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('0b1b0ce4-53bc-4fd9-b542-c5295ea75391','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BJC-Y3-JOURNALISM','BJC Year 3 JOURNALISM',3,'Main','JOURNALISM') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('edcea9dc-7cf8-48ad-95ff-f3b06a8e127c','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BJC-Y3-PR','BJC Year 3 PR',3,'Main','PR') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('0d943513-a497-41db-bbb6-ca977bf900ae','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BPAM-Y1','BPAM Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('2753df51-57ab-4c4f-bcf0-cd205ee615ef','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BPAM-Y2','BPAM Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('a54dc22a-407c-4098-a8aa-14050e881d09','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','422a6c15-127f-47d5-a044-e7547d35dcb6','BPAM-Y3','BPAM Year 3',3,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('0b00d54d-e42c-44da-97b2-6e1133ff601c','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','BPH-Y1','BPH Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('4a319a1a-807d-4e36-af83-933818081cc7','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','BPH-Y2','BPH Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('0b890598-dd14-413f-921e-a5bccc5c11dd','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','BPH-Y3','BPH Year 3',3,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('cb625bd7-b54a-4f6c-8828-e443328865db','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BSE-Y1','BSE Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('979881af-8c76-461d-b446-b6cffa478b9d','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BSE-Y2','BSE Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('b19f7112-3fb9-442d-95d6-225dc7659f67','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BSE-Y3','BSE Year 3',3,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('4b5667ec-b301-4add-962c-babc0d938771','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','96178a5a-1a50-43ad-ace6-045b0e7dd47a','BSE-Y4','BSE Year 4',4,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('2af60ba5-b0b0-4d8b-9456-7f1326fbf0c6','41e287d8-9ca6-412e-9a3c-ed2e389036da','0d35fa69-de7f-4e05-b800-16c07321e75f','DBA-Y1','DBA Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('5f391cdf-a47d-46bf-b663-d2ffdfb9e5a3','41e287d8-9ca6-412e-9a3c-ed2e389036da','0d35fa69-de7f-4e05-b800-16c07321e75f','DBA-Y2','DBA Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('6ca21dd6-fa40-4040-85e3-a742b8e945f3','e1b66000-0001-4000-8000-000000000005','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DCS-Y1','DCS Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('5291aed6-8894-4177-8909-6bf27219d66c','e1b66000-0001-4000-8000-000000000005','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DCS-Y2','DCS Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('922c7252-2ef5-427a-a177-5ff147c8f25e','e1b66000-0001-4000-8000-000000000006','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DDA-Y1','DDA Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('2a9656ad-68e1-44ac-ba74-359b6c778fd6','e1b66000-0001-4000-8000-000000000006','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DDA-Y2','DDA Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('0e783b7d-f4e3-4454-8980-301e0437ba47','88dfce47-1365-4820-be5c-669abfc2dd42','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DDSA-Y1','DDSA Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('47f36c4a-32e0-4e21-a869-3d12b7c4fa8e','88dfce47-1365-4820-be5c-669abfc2dd42','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DDSA-Y2','DDSA Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('b01c3270-d944-487d-aaad-663831be4a20','ac00b024-3929-4702-9a14-b216830ab328','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DIT-Y1','DIT Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('2a9851b2-2d78-4537-aed6-ea4f0ccd4112','ac00b024-3929-4702-9a14-b216830ab328','96178a5a-1a50-43ad-ace6-045b0e7dd47a','DIT-Y2','DIT Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('2454f3b4-6677-40c5-9009-cfac51ad346b','e1b66000-0001-4000-8000-000000000008','0d35fa69-de7f-4e05-b800-16c07321e75f','DPL-Y1','DPL Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('e0dc1b0d-1c68-44db-9827-b935d0bdff0c','e1b66000-0001-4000-8000-000000000008','0d35fa69-de7f-4e05-b800-16c07321e75f','DPL-Y2','DPL Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('d7abbabc-aa93-4e55-a699-b9d9cfe3fd3b','e1b66000-0001-4000-8000-000000000009','06a806fc-0d90-4c27-877d-1025a3ebdbd1','HEC-Y1','HEC Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('64cce6a1-30d1-4907-aea1-ee1d1b32a8d2','e1b66000-0001-4000-8000-000000000009','06a806fc-0d90-4c27-877d-1025a3ebdbd1','HEC-Y1-A','HEC Year 1 A',1,'Main','A') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('17d1a7dc-8734-4506-a70c-955acf0b4e12','e1b66000-0001-4000-8000-000000000009','06a806fc-0d90-4c27-877d-1025a3ebdbd1','HEC-Y2','HEC Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('823f7788-adea-4eb2-acf1-7d37917288d0','e1b66000-0001-4000-8000-000000000001','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','LLB-Y1','LLB Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('57a00b58-5b45-4370-8133-7b9915c8ca1e','e1b66000-0001-4000-8000-000000000001','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','LLB-Y2','LLB Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('a0855a98-df95-4a2a-b8b5-8717ecb5f7c5','e1b66000-0001-4000-8000-000000000001','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','LLB-Y3','LLB Year 3',3,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('bd8343bd-5a09-4a3f-ac95-dd2a7fd1d145','e1b66000-0001-4000-8000-000000000001','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','LLB-Y4','LLB Year 4',4,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('fa94ccde-f9b4-436f-9b5f-0d0f65a4b2b1','e1b66000-0001-4000-8000-000000000002','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','LLM-Y1','LLM Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('de98b330-dbca-4ac3-8c4d-ced0ae676a7c','e1b66000-0001-4000-8000-000000000002','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','LLM-Y2','LLM Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('5fe72a9d-618f-49f4-ab91-cf463998bac3','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA-Y1','MBA Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('e46cc9b5-fb16-493d-adbb-1d2484bf52a6','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA-Y1-AF','MBA Year 1 AF',1,'Main','AF') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('bd8947ab-3b52-4e79-8c53-22468c9bac2f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA-Y1-HRM','MBA Year 1 HRM',1,'Main','HRM') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('bfb2bb8b-f7f4-4427-9099-6e671b2131e8','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA-Y1-M','MBA Year 1 M',1,'Main','M') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('014fde3c-2746-4f28-a679-3d619fb9235d','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA-Y1-PS','MBA Year 1 PS',1,'Main','PS') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('89a9bc41-5bc9-40e4-aa62-78ff3c3a6a94','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA-Y2','MBA Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('ac8bf9c7-a652-4163-bd72-98f7a111f776','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA-Y2-AF','MBA Year 2 AF',2,'Main','AF') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('d86cdd03-56f9-4863-b691-08cae5087586','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA-Y2-HRM','MBA Year 2 HRM',2,'Main','HRM') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('8ce1e66f-d7b0-4859-870d-abc8c63621fa','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA-Y2-M','MBA Year 2 M',2,'Main','M') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('b6758c21-68fe-4c28-bc3c-f37c7f51bd29','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0d35fa69-de7f-4e05-b800-16c07321e75f','MBA-Y2-PS','MBA Year 2 PS',2,'Main','PS') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('e13917ae-d76e-4c86-a415-bb6210835e5f','e1b66000-0001-4000-8000-000000000004','422a6c15-127f-47d5-a044-e7547d35dcb6','MED-Y1','MED Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('4e06d267-413c-47de-b4f2-2f25f7d058c1','e1b66000-0001-4000-8000-000000000004','422a6c15-127f-47d5-a044-e7547d35dcb6','MED-Y1-ONLINE','MED Year 1 ONLINE',1,'Main','ONLINE') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('0907ba50-0ab4-4d69-a60f-fbcf89c4fc0b','e1b66000-0001-4000-8000-000000000004','422a6c15-127f-47d5-a044-e7547d35dcb6','MED-Y2','MED Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('1d6c3e0d-26d1-43a4-81ac-7702d7dc2c5a','e1b66000-0001-4000-8000-000000000004','422a6c15-127f-47d5-a044-e7547d35dcb6','MED-Y2-ONLINE','MED Year 2 ONLINE',2,'Main','ONLINE') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('96e424a2-2584-49af-8281-7ac36622d883','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MEM-Y1','MEM Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('89e2c491-8e0a-4abb-b5b1-7097dcdc4faf','99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MEM-Y2','MEM Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('7ed45a9a-19ca-4bd0-a23d-507df85d4468','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb','422a6c15-127f-47d5-a044-e7547d35dcb6','MIRDS-Y1','MIRDS Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('39af29ee-114e-43f4-babc-7f35ab274117','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb','422a6c15-127f-47d5-a044-e7547d35dcb6','MIRDS-Y1-ONLINE','MIRDS Year 1 ONLINE',1,'Main','ONLINE') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('876eb3d6-bc89-424b-8349-372f24c813b9','bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb','422a6c15-127f-47d5-a044-e7547d35dcb6','MIRDS-Y2','MIRDS Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('abef3ce1-dcc4-43d7-9d66-ff8b875dc807','406f66f5-ea30-4071-9d85-d6029d0fcb05','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MIT-Y1','MIT Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('a21af6cf-3cbd-417a-b3e9-fc759b59824f','406f66f5-ea30-4071-9d85-d6029d0fcb05','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MIT-Y1-ONLINE','MIT Year 1 ONLINE',1,'Main','ONLINE') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('3472d35a-645f-4fa0-ada3-d196faa35d18','406f66f5-ea30-4071-9d85-d6029d0fcb05','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MIT-Y2','MIT Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('2a93002e-0d21-4421-b3db-5df30d8f9943','406f66f5-ea30-4071-9d85-d6029d0fcb05','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MIT-Y2-ONLINE','MIT Year 2 ONLINE',2,'Main','ONLINE') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('97d3ed94-16ba-4c73-a9c1-23855474b4e8','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MPH-Y1','MPH Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('054be87b-8fcf-4dd8-aab5-541bf95417bb','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MPH-Y1-ONLINE','MPH Year 1 ONLINE',1,'Main','ONLINE') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('5389bfac-c2d9-4a25-a753-05284381d2ea','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MPH-Y2','MPH Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('e49493ae-95aa-48a9-bc8b-6a97f8ec4803','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MPH-Y2-ONLINE','MPH Year 2 ONLINE',2,'Main','ONLINE') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('2da93e7b-61c8-4942-9224-05b6d637469b','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','0d35fa69-de7f-4e05-b800-16c07321e75f','MPM-Y1','MPM Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('41bb0a6f-b12c-4e69-8d94-2c1b13788077','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','0d35fa69-de7f-4e05-b800-16c07321e75f','MPM-Y2','MPM Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('88f3cb51-d467-4335-abc0-7b0952bffa1f','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','422a6c15-127f-47d5-a044-e7547d35dcb6','MSS-Y1','MSS Year 1',1,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('04211b9b-0b84-4cef-8f1b-8576b59899e9','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','422a6c15-127f-47d5-a044-e7547d35dcb6','MSS-Y2','MSS Year 2',2,'Main','Day') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;
INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES ('adc071fb-50e3-4897-bf47-c8d5429a8267','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','422a6c15-127f-47d5-a044-e7547d35dcb6','MSS-Y2-ONLINE','MSS Year 2 ONLINE',2,'Main','ONLINE') ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;

-- Lecturers (login password: Cavendish@2026)
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('be617354-8fe8-4fe8-89ba-d1e2f3a4b5c6','LEC-DR-ABDULRAZAK-YUGUA-MADU','Dr. Abdulrazak Yugua Madu','a.madu@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','f76983fa6da9c2db85bf440218033e1f4c5f289af532681639885911e4aeaab6','CU-D5FA2D4338','95d7446cf44fb6f23e579694094b778ee5d10341db60cd8b707d677bbdeb8eec','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('5ce17e91-6f5b-438f-a4d7-67e0726f0e8f','LEC-PROF-ABDULRAZAK-YUGUDA-M','Prof. Abdulrazak Yuguda Madu','amadu@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','123aee32d0123a457d4f3c2fa7488968c224d750d88645aa6153b530db5dbdd4','CU-8C2FCCDF78','cff74553e05654143029c7be88b7a0016e6300550b50d577124ab870ebd94646','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('ec59df84-8249-4043-8a87-b1b85354c8a4','LEC-MS-AGNES-WANDIRA-NTENDE','Ms. Agnes Wandira Ntende','antende@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','d455f75d49cc434c6bb1c7a92af97382bf80ba1f1c9f5c52072df1c5eae13838','CU-146F811E1A','13b95fb9410067b9f911b329fcd57ad93cc918b748d53d5550c616a6ca67473a','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('622f90d0-0a3b-4ffc-b5b1-8e60d990a39b','LEC-DR-AKAMPURIRA-PATIENCE','Dr. Akampurira Patience','pakampurira@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','f0f42120527100532a3d25d59f97901525b825d22c890521e2fad25c4e2ed065','CU-84568E993E','d607c58f76ece60e6b58d6d941424a10dbbef521ad5abf261c0535b27d7c1e17','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('b7abbad5-122a-49d9-a827-2948901f5d67','LEC-MR-ALEX-NABWISO','Mr. Alex Nabwiso','anabwiso@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','c2a17c19a1c35ba7943322341d5d79aca5b8482c5208a9722f0c4391233e69f8','CU-D9F22B924A','6fc750cd5c2548f0ade325a648979382debc0fdf3a240550e6357d86460b282e','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('f32de772-b345-4c97-ad24-ac5c40cac152','LEC-PROF-ALEX-THOMAS-IJJO','Prof. Alex Thomas Ijjo','prof.alex.thomas.ijjo@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','ae3d855ddbb14c261c84144bc433a3882a1ffb3cad129fad83b91972d5e80648','CU-4140C32865','f1cc7c80fd8fb79a58844cdcdc77e81b2bcd15843216d6a2c1a75f1658bb3dc1','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('81ca4b30-14ad-48b6-8e5a-0049fc1b7b3c','LEC-MR-ALLEN-YOBOKA','Mr. Allen Yoboka','ayoboka@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','58225f47089227a5b7d980a7f6c81ed377cb538892fb677cb374518485db72e3','CU-AE7D52B51A','9c40310d5970d850adf5af3f9d90a1c97dff662813f4eff79002b17dd29efcab','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('2e467318-632f-4dde-91ac-495d504e0aca','LEC-DR-ANYONA-O-EVANS','Dr. Anyona O. Evans','aondigi@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','eed3d5bb2cf4e59c3543c0fce81e19b66926b9a5a103ca9ec8723e9f4c8c202f','CU-6E72DD101C','7db7a11870741977e767738c706a54ad8637f7a648274099004824433b402515','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('a97bc7fe-d8d9-4560-9a41-19d0a0d305ef','LEC-DR-ASHIRU-TUKUR-INUWA','Dr. Ashiru Tukur Inuwa','iashiru@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','3f822f35700038779a02e85b3596fa899fe2318f0fb6eb851ae981ae03de15f7','CU-4661A0E775','f29887ff7d3a01c8aa54d6787b8d5c6513ca5675bf0b19bf15c8f605619000fa','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('4ecccefa-3928-4186-81de-b60c80998d77','LEC-PROF-ATULOMAH-NNODIMELE','Prof.Atulomah Nnodimele','prof.atulomah.nnodimele@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','d622d91767357d993248d208281df51f38963337dea89b6b294b427abc55a47f','CU-ACCCB7BD5B','a754e0fbac8d59258f5e6e64cb570e2ec7ddb38d4bb6ea45de597a787ed6559a','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('dde0b8b1-1865-475e-888c-22c29a4eeff9','LEC-MR-AYASI-BIN-ASADI','Mr.Ayasi Bin-Asadi','aasadi@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','877f6958d3aa5249ea9f2eab222bb32a3dfab1e1da89af74f13cc1aa1ee5e5d4','CU-C18ACAC1DC','9cb42c43ca9d1ca42553827d6f8dd14ae9638189b3d05f78b9e1362d2758d711','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3','LEC-MR-BAKYAYITA-DAVID','Mr. Bakyayita David','d.bakyayita@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','fbf0566b58602d80f2a4a6629d062b7e83402b6a69ee64c6c8053a84c65546b2','CU-BCE65C1D19','0b7955bd50bd0912e4a00344f5af1994e8dfb4b945e5ebfc24021381b9643afb','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('cc78b85d-92b6-45e1-a869-3a26d17a1e4a','LEC-MR-BALIRWA-MOSES','Mr.Balirwa Moses','moses.balirwa@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','2fb642af5ad9f1ef5dd36612b233485d1d544e22a3fce8eff4ef4a0fc7f38cda','CU-566B4B1FE6','a9b790fe547a0efbd17e9bb0129a85fb18a37448a233d28379bcfe02c532980b','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('c35c6eaf-7d70-4f70-88c9-e0f1a2b3c4d5','LEC-MR-BAMUSWANKWIRE-CHARLES','Mr. Bamuswankwire Charles','c.bamuswankwire@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','cf6d9e92edec34c4e0c06bd877c275e725df07bc0b74fe059112687c605b0b73','CU-6F931B2DA2','d8bbbbd10b029a5cecb4e8a3a82eed7720b329f9effc8a56609ec851f8746e6e','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('1f20f39f-cf5e-4beb-a853-771e6cc91c93','LEC-MS-BARBRA-KISAKYE','Ms.Barbra Kisakye','bkisakye@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','56ac28cfc460860acd798009d632f682efc342b102b20e75ef3d20e587773e3b','CU-7F2C420B07','0f66c70a7f9c6afd94addff3401a408e27aa62a9548a598e97f51765e84fdb2a','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('13019d4a-21de-4616-aee5-76ad71492938','LEC-DR-BELLO-FOLARANMI-FATAI','Dr. Bello Folaranmi Fatai','dr.bello.folaranmi.fatai@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','355756c2166f0296cd6422b2e554a1266dcd5ad01971cab0d7226120dbc0d2eb','CU-6C4B76E56A','3994506c6caa063e3c7949cf629c20331fee0cfac9a6545388e8a9bd149a27a4','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('de345d62-f4a2-4f20-9804-c4b0c9f882ef','LEC-BISASO-RITA-REGINA','Bisaso Rita Regina','rbisaso@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','6717ede35d251faab2f8b3f9fc295fa0211cbdcb93acf6fd120d435631bfdaab','CU-0E87B88EBE','6be39b44e78e16a5fe377ad735799d6489935bc20210250c4a31c9562cb1f7c8','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('8c6771a7-4931-463d-b0bb-be2d5f2ece2f','LEC-DR-BOB-DRANI','Dr. Bob Drani','dr.bob.drani@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','5e50e2fec130f45f4581f70ae87198acafa269529b82177bd114413ca43ee464','CU-E6B8F723B4','45884712e0466b7a320a516b24558a4bd3d534071b8d7f9f0f1ff850142323a2','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('0264fe58-61d4-4d6c-96ea-98db8fb0ac5f','LEC-BRENDA-TUSINGWIRE-JAKIRA','Brenda Tusingwire Jakira','btusingwire@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','fe162228db545800aa6fa1a209338c7f635633d15da075398fbfb403cc6c6bf3','CU-E788476F53','ace82a6238adc70c890b205a88541add0338564b5008dc3bc76fd1219b629b5d','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('28d5a4bf-1d42-427a-99e2-a145882f750e','LEC-MR-BRIAN-KIRIMA','Mr. Brian Kirima','bkirima@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','3b234b731b25b0782778ec71f0f1379b10c6dc8e45a0313b123401b767e0590c','CU-88C412C339','b3127862082be11a1caae94858da60a215d4b54007e7326eaa018d8fffbbe352','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11','LEC-MS-BRIDGET-NUWAGABA','Ms. Bridget Nuwagaba','b.nuwagaba@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','80e0689807abc4097519cfca14105695488760ef5a22e84c9618e3b1e9efcb1b','CU-8DFFE05BA7','578967b79a2212abd854c20c78b5b5240b7160c088286eedc77a5402ce382d77','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0','LEC-MR-BRUCE-NABAASA','Mr. Bruce Nabaasa','b.nabaasa@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','e016ed768d8eb5efb1ddb7fa52220f1557fcad13ad10a03cdc2358209ad716f1','CU-EC05AEA10E','f61993aee7b1e9f12bf3157959b037fa8c125edfcd062173b64b13befca724a8','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('aa0e0cca-d56a-4111-8e69-d3394e6f8d6d','LEC-MS-CATHERINE-NANSUBUGA','Ms. Catherine Nansubuga','cnansubuga@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','2fe4109deeeafa3e1d2b54ade1cac1abc992d32874cf551cb4a6868fefd66566','CU-2E676E6472','0353858b032ccb69914860f26fa04c41c3822a9774f2837a7b0b91a2e76e54f0','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('646fe3f0-10f2-4801-afde-5f5bd24cc73e','LEC-DR-CHINWE-PEACE','Dr.Chinwe Peace','ichinwe@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','637e1f310592d2d71f9e1af2b7afe8b63ed1140692e41fb33033e0d5a47e2d1f','CU-745E542F52','85c1c936f5cf880e775d1581d4c9c101dc8a3571937494819d1782e46d333821','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('716d1f74-b603-4f0f-ac42-f1b67c5efe66','LEC-DR-DANIEL-WALYEMERA','Dr. Daniel Walyemera','dwalyemera@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','fc553701e7fcfa06363f0f972534e70c6419987b7436b837f6fdfbe892a28590','CU-6251E55766','f4f6ac73984b115ed5b45cd986dcbbb350139eb5910142a157e0f050e341b7b8','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('57b2fc7a-f5a8-4a0a-a558-ee8759a4981f','LEC-MS-DEBORAH-MACKENZIE','Ms. Deborah Mackenzie','d.mackenzie@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','04c32bd4e800568a4b34d298757c9ed6d775c156775383b066b630d77f2ba4ad','CU-2108AAAF0A','5206235df420288eee8c6144b5d8371730e48f46a7574c85367f77de4bc04a58','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('d476996b-03c6-4c57-88b6-cc6953925903','LEC-MS-DENISE-BABIRYE','Ms. Denise Babirye','dbabirye@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','b0109e11499acee724bc1af1cad8b5d469b03d4601628cf245a948473f5b9d6f','CU-18303E51D1','1f2d2ac4f36cfc9a18fc3cdaa82f46c5dff6da85afbe4a5baa51b69fb5b22257','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4','LEC-MR-DENIS-WAMIMBI','Mr. Denis Wamimbi','d.wamimbi@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','ac05caf3b3f7fdec75ece2fd8ca7d507031fd989c5ad555ff7c9116c0a02d107','CU-2BB09B14E2','c14083c814e43739934074283bf4c2462def55423bf20f713d877010ced63256','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2','LEC-MR-DEO-NSUBUGA','Mr. Deo Nsubuga','d.nsubuga@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','49ed34bb1ad2d25df9345ae232d482d30e1df22d4f86d80c0edd7f1033e6f178','CU-34ACBE36C8','b9735269766c8d55c8a49ce3239819d2e558823fbceba567abf31e1008960668','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('05ab10f4-68a7-4f83-a82a-b662b3574dd7','LEC-DR-DORCUS-KALEMBE','Dr. Dorcus Kalembe','dkalembe@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','802727ceffdb7ca583b400fba83f5f138b3a2d62b2b751ac3987759fa75fd5c1','CU-F943B81F37','6629552d5bb4131dba2488e972a458ff7f2964b0c9d374debdfab245cc9bb3f1','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('62f8ae87-777b-4b50-aab2-6a93b6880241','LEC-DR-EMMANUEL-BAGENDA','Dr. Emmanuel Bagenda','ebagenda@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','78001f096cb258e7cc6c1aaed2428c4b4e0a27609504f5c806addd7a63c23643','CU-A22DD26BAB','ffa477fb578910c4c5a580e373ec7b0163fe97e6b0bb2e9311a4cb3a657fb9a8','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('4b10edab-7d64-471e-976f-adbe88a3e655','LEC-MR-EMMANUEL-OFOYURU','Mr. Emmanuel Ofoyuru','eofoyuru@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','a25e1f55056877e89dead907ddc3e52311067218d5e2efa90a69858ddd7d9acf','CU-BCF5F18DF8','99efde1a809864f325552b0442357f9e752d303517b63e5ee58acd8530d95cb2','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('22d76b7c-91e4-4a24-9e33-750834537da4','LEC-DR-ENE-BONGILI-GOODNESS','Dr. Ene Bongili Goodness','dr.ene.bongili.goodness@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','42dcd74dd51ad9a5632ffeea2fdd230b324db71dd18e58d43b42000aa84ec0ba','CU-D35D71CD34','9deead21ee038e7b7552070e98f3a755a93def6a257c1e442c01da51df4c0bd8','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('328e043e-56f9-4311-8172-1b4df729f145','LEC-ERIC-OMONYI','Eric Omonyi','eric.omonyi@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','425e14c9235a8b05d70cacf7f99be1c59146c6a028865c6f77166f8e64de5692','CU-27EFFBE7A2','152364fa72cbc42be0f61a1cf58d12291430034261819a51f237f74666a9afd2','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('d0c037f9-c6ab-4457-ad78-d016954df586','LEC-MR-ESIBO-OMADA','Mr. Esibo Omada','eomaada@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','e6b0bd8b95ad0640cfbef5de0358d5a9ee4335db16d516ba1ebe71c15759d2aa','CU-6829D26492','4ad3045ed04f9aa0e39feaf59891f865aea219230f8e8cbaceebf9463616eedc','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('69d032d2-c432-4c24-8801-f59b948f2e6f','LEC-DR-FAITH-AHABYOONA-MUGIS','Dr. Faith Ahabyoona Mugisha','fahabyoona@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','b393a12a19abbc9ae07070c6559386ca0c7e34db4b80b2af7d1d27c2fbf57c06','CU-68E903EA3A','64c067567691c5f167c0fc6c62374bcb56b0f1910aa8f1ae0775f8560ced158d','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2','LEC-DR-FIONA-TUMUSIIME','Dr. Fiona Tumusiime','f.tumusiime@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','4994cf857b71b9caa24a370b67803ad6d424c97f81d947466d1e19852421b5e7','CU-2C8EA8A44C','fe3c8a938e7d381ed355c8af44fa1745128e95cee73aa7c4f07d77d09fb719c2','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('7afc7ef4-d142-4778-9b72-29d3c9a0b6be','LEC-GALIWANGO-CHARLES-JOVANS','Galiwango Charles Jovans','galiwango.charles.jovans@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','c331bfb54861311383ad90511fe555cdf804111960828b61996e4a219a307702','CU-C983DA6018','e4147b094a319ad9314e7e418d48fddb04be1fbdd7f1d77c2825c3d7c0ea6802','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('80aabbc7-ba9a-4b15-96b7-ba4e87de6140','LEC-MR-GODFREY-AYERANGA','Mr. Godfrey Ayeranga','gayeranga@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','15f47b05dafa8255765de1b402b33b93cda7dc9a06a727cbac85804dfda529bb','CU-7AE22C67CB','25a1ba58d0b49cf93f96ec4ed3857d15a24908c2cbfad811f063f45f99249c5a','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('40ac889f-82c1-4014-af80-95b51cc94f3e','LEC-MS-HABIBA-NJERI-NGUGI','Ms. Habiba Njeri Ngugi','hngugi@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','870fa580c9a25b14003e6b166d0d6746f413e2b04e44d04da17895976843c02a','CU-94026383A0','d47fbf9da8449fd3672c007abcf0ef628b7f092e52b7b0a2571f72515543875c','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('93834083-3e91-4f8f-8cb5-f69789a0c1a0','LEC-MR-HAKIM-SALUM','Mr. Hakim Salum','hsalum@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','1df71f9cc5bfb46de3fd18fd3d3998471dd28f39ec06b686ef552aea3835fb86','CU-F2ABCEE501','578111ae4c913907ec7c9d0c40d8acc80caa8207ba1b3db747e02af3d8196d0b','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('a545ca9e-b304-4a15-b6cc-bc2ab49dddce','LEC-PROF-HARUNA-AYUBA','Prof. Haruna Ayuba','prof.haruna.ayuba@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','2d50be68d4824078f72754290717ffd042a250ac5bb606334dad25e38d6077e7','CU-8DB58EF217','025b72920e6107045dcc42287b71029083e5b6ef755ceabe80d0c05e03ea9e40','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('7af19cce-b1f0-4770-8090-0e942721663d','LEC-HASSAN-TUGUME','Hassan Tugume','htugume@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','a33c642d6cb5675b42b7a2017a1a8ed235c3005e7215e4af345f5d9d5cc739ee','CU-2AA2DD2E5C','dc85f3f6bc957f728fe8cf5322fcdbcc2d5af79d13728496bcf1729436d61a15','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('e47b172f-4104-411a-85f6-b4e0c209d8be','LEC-MR-HERMAN-TUHAIRWE','Mr. Herman Tuhairwe','htuhairwe@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','2954e32599a98ba8c2f622b21649311980ae65e64918a86901bf4f8bd90446cd','CU-DBD699494D','394fd096ff13062471095883abd6304867880520cd367ed37014538b925f3837','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('a3409096-f90d-43ac-af8b-4776d16ae3c6','LEC-DR-HUTHAIFAH-BUSUULWA','Dr. Huthaifah Busuulwa','hbusuulwa@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','e76a1bd6fb8ed186b5113221325f7384d8f2142c1e144c81e83501a964b10efb','CU-B843B72897','3c91c1fb9a2c47e29228b27ad04d102d9bb584485671ab9063bf4bd18bca4649','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('e550342a-6d2f-4487-b076-e1dd5d354d29','LEC-MS-IRIET-CAROLINE-NAMAJJ','Ms.Iriet Caroline Namajja','inamaja@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','b423b248a3970a7c35d91a014cb6a3607dee305dcfb3747e8163e89ea1e8885d','CU-FCA552CD11','8313b07e9ad2c11370d269e8aa29665d2d296fc8949572626b00ac5dd6b811e8','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('def38337-4c53-49c3-b348-7612934115ad','LEC-MR-IVAN-MUGUMYA','Mr. Ivan Mugumya','i.mugumya@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','a7bc1a73505d12472a0bb4a681596085d4cee04cca22b050a0b903cd21e6fd39','CU-EF5CF30944','737abec82c8e3aed84e4a50806fa1707b8496dcb53bcb93463c4908f2701bf97','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('6bc87c82-c6e2-4553-b120-0788ea05da23','LEC-DR-JANEPHER-SAMBAGA','Dr. Janepher Sambaga','jsambaga@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','64006c2d298d7055e68155df6877bc620c84431599215b238b20dee2b3f7f2b9','CU-DF70AD8558','fd4f936a1ceec47433205c89952b0b56ddbbd9aa955a13afed6262c9c5f3a597','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('e28f11aa-0f8f-4ec1-9090-89f45609f9dc','LEC-DR-JB-SSEMAKULA','Dr. JB Ssemakula','jbssemakula@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','7526a1e12fbc50fae650044fcc726c9057080588ac8c67f2570d10637a2282b6','CU-B3DBB23254','16d519a886a0ec08fe71e82ba9f00efd7b217bd44538b25b183db4f15d008ef5','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('cbdf9c6c-b096-45a9-92b0-12dd4a5ded62','LEC-MR-JIMMY-MWESIGYE','Mr. Jimmy Mwesigye','jmwesigye@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','7e18a9d000e9ff9ea6c7e82ecf23e93e4f5aba97e40c57498fde215955b882bd','CU-270CBDE7C7','d2b21b3a71e0f13702908f043922c376259998203ae5a12a89cac20ef8dba274','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5','LEC-MR-JONATHAN-TABALANGA','Mr. Jonathan Tabalanga','j.tabalanga@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','f4e5dbc67bc53e2ea89fc3af702320e5c0667b8515884cf79b34e1723fe524d3','CU-93AF85F35B','0848d63f0cd7f11c7e5d2204d91d55bb9836cc2ba46489d82d9668b2dd8c759d','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('3be662be-54eb-46b4-aa44-2b3ea30b52ce','LEC-DR-JOSEPH-YIGA-BALEKE','Dr. Joseph Yiga Baleke','jbaleke@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','ee56129f83677b52e9f42d47cd5b60d4fd1846aee2679c0fc5917a3726f98290','CU-6681FECE75','d8b614edf18f68accbbb427da6e112a3b4a0fc4922b208e1e188dacfeeca382d','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('53167307-9a23-4931-bcd9-d7d3bd234bbb','LEC-DR-JUDE-KAGOORO','Dr. Jude Kagooro','jkagoro@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','9a8dc2294e5b696ccbec507d056c96d4f8d114d71696306942b32336775b9e72','CU-7B4252F1EA','abfa899929db9cdf76abb8eb5c40dc6083c3c7545244caacd8e366bea118ea62','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9','LEC-MS-JULIET-BANDARU','Ms. Juliet Bandaru','j.bandaru@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','3355fdb946b954f01d4c68f56e0d66152b2beb384b88d9957111dd712cb92a48','CU-636628861B','38819499354a49353f9c002071bc8c3a5d2bbccabbae6e7e30fd7c4e5d8f0665','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('179067cf-9d42-468a-bf84-56962097261f','LEC-DR-KABANGI-MOSES','Dr. Kabangi Moses','dr.kabangi.moses@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','2b067a10d93a473da524cd67b91792bb7a1530bf0678a2cbfc3de1d86aa1a314','CU-D894B2DA2E','17a372f0172839b389e1abdb373874b9e533e73071333c388d460192b735c4b4','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('ea81a46a-2685-4f87-b958-3f5fdbbb3c3c','LEC-MS-KABASINGUZI-CHRISTINE','Ms.Kabasinguzi Christine','ckabasinguzi@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','20ec7837817dd2509129d9fa76e39c1b89e86cc18a08ea1c1b4b919cccb8cf26','CU-383FCD726B','6d46b7103c6b5f6cc6e302537e016815eb5136c054a82ac0ca4e4b78f363f489','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847','LEC-MR-KASUMBA-SHADRACH','Mr. Kasumba Shadrach','s.kasumba@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','cfeee5b424a0c6740beb0d833fcdb1a3f71795fbad7b6714b774f17ac7d13b64','CU-C1F6F4A977','cc9039cbbd6f8764140e5f21580fef7b869ba7564ac471a83b01a3f0365ca6b2','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('98bd6033-b693-4368-96a3-66a8edd4141e','LEC-DR-KATONO-YUSUF','Dr. Katono Yusuf','ykatono@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','31477b99caebdfeb2006df94eb4681eb42087d2d7e95b9ece4b4611ca7b81f25','CU-A2A494E4D0','a4ff26f6dd19420d854fd63c2155b7df4f49edf03a8a4f31ae1e62ca05c4c317','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('5749d87d-1d37-4018-9780-32c3fa32a9ca','LEC-MR-KATUMBA-DAVID','Mr. Katumba David','mr.katumba.david@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','56bcb3d824b7602242d3379eeb4822d46994d68072c344d934f360d668e163e3','CU-3A24CABECD','e9c32ced7b57f0e781a7a79b80151cce95c8508df29337f7ea16e83a7dfc176c','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78','LEC-MR-KAWISO-MARTIN-WILFRED','Mr. Kawiso Martin Wilfred','m.kawiso@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','2bd2d596e91476eb550b1be26ab3b2321358a7d2f20e0428489f9794da996a71','CU-9FFA7B2362','3f03724385e3878a4de616a118924eb74ba3d8945b0404fe4cea4ab96c12b582','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('c28e32a8-f3ff-460b-9e3c-6cba0ba811d3','LEC-KAYANJA-JOSEPH','Kayanja Joseph','jKayanga@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','103df4e71d9aa9094236921f98f12102e6a309ed56b92ddcc442db9ab27b432b','CU-83A5555276','08ee1519894e03c0c0fd561e750eed3e15dbf2aec38c5aa9e426d318519331a2','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('fa4b7144-17a6-4791-9ca5-25b78f629c18','LEC-MS-KEMBABAZI-COMFORT','Ms. Kembabazi Comfort','ckembabazi@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','04bc0f0e45459fbc8f0cec9edbb6be9b37f51137c333b55be3ba055d2aa9f6b6','CU-2D4F8DC4B7','ca8fd7d4fcce0faf039716fb0ced68d3b850df11b5e5ee568248da73cd64b568','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('6837f8b1-3740-4cb8-b39e-a0538e6ff3a0','LEC-KENNETH-A','Kenneth A','kenneth.a@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','0e583397ae2004d548c054a08a7292783a496a27300fb1abaa25e103e2a6ab1e','CU-6F3C93F60E','2de60fcfaef4ada75469fbac6034d0d09147a6aa4d400776ef56b687eed490bc','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8','LEC-MS-KHAWA-NAMAJJA','Ms. Khawa Namajja','k.namajja@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','efa778c4fd98284d5f2f92bea585a5b3d43f34bc332c3c18f6c7918d7991b4fe','CU-CCE0C13A44','9058c36d209efda3e8d04071916952936e38e127dbc52044a991a55d505092aa','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3','LEC-DR-KIBUKAMUSOKE-MARTHA','Dr. Kibukamusoke Martha','m.kibukamusoke@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','411757458a1aeafd8ca904f29d966a5280b4faf55e0fa89374d6ab3c396f2a8b','CU-3FF2E791CD','5e7747cdb0d5d762cd872b014fff7937ee430644deccf33f397bbd515946bb3b','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('40580b57-e389-475e-a791-5d8d5e51b1e8','LEC-PROF-KIMWISE-ALONE','Prof. Kimwise Alone','kalone@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','44702a5813311f41de135f4e94ce0d2e119b94b6bb00c1cdc3b428bb3a3d8433','CU-2F7CD9119D','89222c0ae23d0aa2ac78d28c69925e348522aef4a320a2c0ddc289bd0cbd5059','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('04c05b03-239c-4938-949a-9db56fdcc103','LEC-MR-KUMAKECH-MICHAEL','Mr.Kumakech Michael','mkumakech@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','647f1f5978393c5278f2b8cd7a6ba388e16772e44388622d026410adb63b5dbf','CU-721430DDF3','b7f75ed84718d99adce49e97ad297f3e58e740f3c32d930910e211dda0bf328c','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('6a6f6b86-9785-47bf-bdb5-73051d9acb6b','LEC-MR-KWESIGA-BOSCO','Mr. Kwesiga Bosco','bkwesiga@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','272ff9bceffd1a294205e2c60c81429e6ce5a65b7dadf6a1ee9a2f410b674c29','CU-AC56D9F700','4d83dd244c76d2e6045527a302c264c285b8830a71c7536892072bc2dd844ed0','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('0cdb4518-8623-497f-966b-c28043ace08f','LEC-MS-LELIA-KATUSIIME','Ms. Lelia Katusiime','lkatusiime@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','0089ae502f170aeb6107ceda551e9eab96d1ca6b51dd4f8b9233ce1d9843aa6e','CU-FD3403FA4B','2127087831791a4701599581f6a7e2512b83f4a74e1c080928c15a655b0a41cc','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('cf728465-9fe9-4fe9-8acb-e2f3a4b5c6d7','LEC-PROF-LOVE-ARUGUOBIANI','Prof. Love Aruguobiani','l.aruguobiani@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','70f3107a937686f002ea84e84663ec7de7213da5f343f75e5ac142010b6c2c30','CU-7D7E6213EB','9a0de35c2b4dfe86a0dc8425e5d17f088a5778f553f97e58506783895faface4','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1','LEC-MR-MAGANDA-EVANS','Mr. Maganda Evans','m.maganda@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','4865d49edb9890f95b16e107dad29e47655def242bc106868ee879dfc25fb566','CU-96464DBE60','b12a3c1c0dd1ecd2e6010f785df27f0b7ebea595316f1c3099121d18ac68cd38','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('be31f7c7-6319-44df-a6e7-216f1cabf6f8','LEC-MR-MAGANDA-EVANS-TABINGW','Mr.Maganda Evans Tabingwa','emaganda@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','2e154e89b09bba9fde9b6295e3cf9d1d080d45b18e4824f88f7ea2c51759879b','CU-F34819A70D','a7cb4a185654436a411d93b0386e7f0f665a9aba32d558f2060dee5e3b4d0ad8','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('0fd2a1d2-9b26-472c-bd86-5051a9fc8436','LEC-MR-MAKWASI-CHRISTOPHER','Mr. Makwasi Christopher','cmakwasi@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','079176c1981b82dfd5284ecd4117e3e52d9e0101dda22e87ecb9de41432e0cfd','CU-7127C943F9','af7dd99a47ef6fb56fc252b824d8e4afd33bf14fe1e10d7f84646a21f1a534f6','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('4156e748-16a1-4737-9a86-d24dd0ddcbd5','LEC-MS-MARY-NYACHIEO','Ms. Mary Nyachieo','mnyachieo@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','ba8815d2985ce5a7f4c2cf0c5f5f5a2261872724eaed3b6221d99d8b3dc90d5c','CU-79DEF0FC73','5355abb1c12db26d7e73dd54e27711a027a3bb51f5906fe36276277727bf97d9','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('6c3d9c6d-80a2-449a-ab8e-571f31d7691a','LEC-DR-MAYANJA-SAMUEL','Dr. Mayanja Samuel','smayanja@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','d019bd6901d606c3cef91f2f274ae1e6d6392aeceb68dcc1520dd104669652b5','CU-668FBE73E5','77cb950b31596cb63fde6c28ef7639fe3e02402d277797025f2666cc7adb898a','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('d2242310-57c2-484c-9f75-5888c5aaa883','LEC-DR-MBABAZI-ANNET','Dr. Mbabazi Annet','ambabazi@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','8c51d2290896a337703c08da110a2dc363aaa2fb06bbec565ca3b43a89b71417','CU-E1A80B9CEB','2241601e56d4204ad6b5b243e86dc8e2c74599694674c618012a69f195b31599','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('bc49574b-49f5-469e-96b9-b1267ee50f22','LEC-MR-MILTON-TURYAREEBA','Mr. Milton Turyareeba','mturyareeba@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','6b09a2cdd87f4ee3de6052a0ef2753cfea12951edfc1cb73093eb1d72698d36f','CU-77AB0A59A5','efb3e5b1f98ac700e3d656ae0d041f030b2588c9279b11e848e1528736b05e9a','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('1072fa4c-0760-40fb-b131-9befeea849a3','LEC-MR-MOSES-KAYIMA-NYANZI','Mr. Moses Kayima Nyanzi','mkayima@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','983581662fb9c42396fee02eeca51e0bfc9574e9bb90c240fc47c7f0fbfa4d47','CU-A208A7FCE4','b9d8e57e1adb7c905beb94357ba12b3de6bc174620f7176d6d7a40f3850a9df4','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f','LEC-MR-MPIIMA-DENNIS','Mr. Mpiima Dennis','d.mpiima@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','94bb3c0c2e7cb35d43ec80aadffe37f7c6ff10ca25ac841acc4cbd9da9de507b','CU-B3EBE049DF','ccc51d59cf72694ec1f4f3b36b7b7cb181ea236bc4d2838c98516dbc6be67a7c','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('22640f68-e8c9-43e7-bd70-59ba276acbbb','LEC-MR-MPUBANI-DAVID','Mr. Mpubani David','d.mpubani@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','a248b47bac6018af7d423a1b4273ddb5070f0457182cfcc1eff877f5572ecae0','CU-6F8908FD91','a60bff25fa19a8a4dc2841063e078e4462606f25259cccb42032b65178f942e7','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('74ee4b63-7440-4f0f-a46b-19ea8a4ed456','LEC-MR-MUDOOLA-HERBERT','Mr.Mudoola Herbert','hmudoola@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','170c51aff79ddede2e9c422aea5d58bb032790779d53541e8b4233d61010a7d8','CU-F22807C9AE','f6c7d80b6b3b0608d0a42e5b15cf7c0d125c273f0da7e6036f6c69b933cc2f84','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('45ee3159-0492-4023-9be1-fa28e9d8bf94','LEC-DR-MUGABI-FRANCIS','Dr. Mugabi Francis','fmugabi@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','b5719df04dfa3a74d99e4a5d1c98d8a6d49d87177e0168b5a6e55bd81cdc5a58','CU-2629D6A081','9240bced28a6316113af9e512aa163a8868fc1d17b8211dffd01b44b0cbd1d17','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('084255b4-5f4e-4eba-a3bc-d4b241f3d9f5','LEC-DR-MUHAMMAD-MUHAMMAD-KUD','Dr. Muhammad Muhammad Kudu','dr.muhammad.muhammad.kudu@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','4ddf20eca7c522cb7ddf4bf3cf7fdafbdf2c159bd9b09caa06e20dd65cbb4ed8','CU-E96D7F257E','703d1e427c59fe1f75490e313428c88d23ae1a1a1961957644be64c01255cc3e','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('b24b5d9e-6c6f-4e60-97b8-d9e0f1a2b3c4','LEC-MR-MUHWEZI-MOSES','Mr. Muhwezi Moses','m.muhwezi@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','999ef03396179689de29eb93b2c740b73462ab9a97af1766e1c55b09fd7a38a0','CU-176A30E2A1','77e0607db363140a781e49c30cba1b1ed33d8983fc510b11bb6851710aafbc9e','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1','LEC-MR-MURAMI-TAIBU','Mr. Murami Taibu','m.taibu@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','e013a5c85bbbcb7743b7bc04858b38b1a6b56f4b2c6d7b38e6cc97e46b96becd','CU-479250B069','aa89f9afb25e03bf8a1650d07e56ae7c1cc0990ae087d2f99691100e75a1fccd','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('99d7e1aa-c930-49a2-9d97-45fc68a03711','LEC-PROF-MUSA-DAHIRU','Prof. Musa Dahiru','dmusa@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','1aaa304d8460af870915b3a8525c4171d99a7b691d59cad34c414bc0777668e1','CU-0A9B8FECDB','5d040e9168c5b73c90d31355464082b05cc9f78a32d962eb01cf15830db98fd0','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('71d9384d-05aa-4a97-9317-3abe1f14d4f9','LEC-DR-MUTYA-TOMASI','Dr. Mutya Tomasi','dr.mutya.tomasi@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','d880a02680ca30e9c38b7f51272a4002f1d5209da658ae21c6cfbbadf77b9778','CU-C59DFD845D','78a4c4a917e589f22bba3b22460c0ce155785d7341ff296e018376f8a74d28cc','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('e57e8acb-9f90-4090-80e1-a2b3c4d5e6f7','LEC-MR-MWESIGWA-HENRY','Mr. Mwesigwa Henry','h.mwesigwa@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','cfd02b1e64045966ecd0b3cb02265a4f15cede7ad6bf14296cfc926d228c0a18','CU-080DF1D1C5','dd20491d1e75300e790003005ac4d7db0ee5af09b2bf02615f5c424dd49462e1','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('a995e09a-d0ec-4c3a-8161-e11f7e70f5e4','LEC-MS-NABBANJA-TEDDY','Ms.Nabbanja Teddy','tnabbanja@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','43041bd417ef0cfd914c211c715ec4ab1b1c4eb643de761d5727fb5bca3001b6','CU-ADA8CCA7B9','9d7f94900d983d3e557c8fb008005a035f0e2a154c0b86991e5950ea6a177985','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('1d26ebc3-1c74-43fb-9261-3514e85c8747','LEC-MS-NAKAZZI-MARIA','Ms. Nakazzi Maria','snamazzi@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','7ea024d14390f7b3a6dfa2f90b5fa9e13dfd9c879ecd988279519034af3be079','CU-FA1772936F','ee7af1bc43c082a67357ef5b45e6a7767c6cda4481e75b48c6be403fea0042a4','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('f68f9bdc-0fa0-4fa0-a1f2-b3c4d5e6f7a8','LEC-MS-NAKIGANDA-HARRIET','Ms. Nakiganda Harriet','h.nakiganda@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','cbf41d5b01b0f8c46a382b8d2f83f325efddb72150ea003b575b6c194707d1c8','CU-C1E4DB3350','eb1b066ed7e6e25d53c8b467d5fd78f8941f1190d8cf5ea929f0652f9b4741bc','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0','LEC-MS-NAMAKULA-ELIZABETH','Ms. Namakula Elizabeth','e.namakula@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','1379050b71905f2aeb47533a5c441dcdc57e84b884357d3c15c07dc9ed237efa','CU-13EFB78C1D','a6c22531912c7a6d5f2ee85e0d6e1103b8f32a313909f6d78e048a2899f81742','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('40e8500b-3e15-4446-8cd9-9052435c6717','LEC-DR-NANSEREKO-RACHEAL-KAB','Dr. Nansereko Racheal Kabuye','rkabuye@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','69d0233a1e47c513c60f3352345f213ae76f894ddd59e1295f64f5e8de4e8b3e','CU-703D7C8ACC','b114a3fa9ffa0fadae19841d7772a682b0469b6ff9e6ac234fb0980297713bda','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('47835404-5a90-4960-bee7-2b7cb6f9f4df','LEC-MS-NANYONJO-EVELYN','Ms. Nanyonjo Evelyn','e.nanyonjo@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','43e2e8da98423e63d7aac3dc6fa0ae5ff306fd7970dc664a97678b659644d342','CU-C956502302','8547d29ab9b5a36f7227a039b068fcfed3a65c8d361f12302b90233fcfad8e34','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('c0f3071f-f74b-41d7-a3c3-01b39cfbbd46','LEC-NAOMI-EVELYN-ABENAKYO','Naomi Evelyn Abenakyo','eabenakyo@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','d5dd8546e8ebc7b500b57411f98850a11befbf0f121b5c5f6311b89b9d54ace5','CU-57E17E7393','276f832c78c74c655bc65704c0278db0c812ddd10c1b28d1a853b58ce42a7152','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('de615d4f-d8c4-4dc7-bff0-389508668cd5','LEC-MS-NASSOZI-BEATRICE','Ms. Nassozi Beatrice','bnassozi@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','225bec04cace642dd01f7d55cff5dfe89b3526555a63030b061dc4a1111fbdc8','CU-C3D226EAAA','565ef20cbac67d6b834559e7ec6f0e71b13072cae2c11dfb75e5eb557c1b4c66','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('ea57ad78-f907-4a6d-a9b8-8652908b901d','LEC-MR-NGABIRANO-RICHARD','Mr. Ngabirano Richard','mr.ngabirano.richard@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','84fe907e941422c94105036e62c6eee4eca0e69883668244f10988b502151d16','CU-4164A6CB3D','fd084249c58e678d1fcff7f5d3c23181025eaaaf2024ae0c5629f60bacd8e446','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('4bb7f5f2-4740-4271-881b-a81771bdc8ed','LEC-MS-NIMUSIIMA-EDINAH','Ms. Nimusiima Edinah','enimusiima@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','137e554a19c570cc0d91a03a61d8d166e7cc635c3d55cd1bbae4cc7db982e851','CU-B756ADF660','bd977d7717d15a7b744895a9e00f84e0cdb28024e804a994881cc17d1d09e346','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('696d8165-f8fe-451b-8041-a45dae05eb52','LEC-MR-NKOLOOGI-BLASIUS','Mr. Nkoloogi Blasius','mr.nkoloogi.blasius@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','9a8f9b1a865d2349131a5609d4661454cd6e71d95c3a24937523d61afa7656d9','CU-D4A835C73C','783c326d88bd406b84734f088a43f397633400182f3321efd2b50ff544134615','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('5e6494d5-e109-452a-9703-386a1a04409c','LEC-MR-NKOLOOGI-BULAISUS','Mr. Nkoloogi Bulaisus','nblasius@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','2a5844ff749be95fe8f24414b5609bdf290a30183f95fe3ba94432ba6b421a43','CU-A388C52A50','02d35fd96082bcfeff673d498999a09cfd04ccffdb8547e43f43c1507b891428','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1','LEC-MS-NNAGADYA-SUMAYAH','Ms. Nnagadya Sumayah','s.nnagadya@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','7c6419219dd2d4c84e80de6d7d3678ff54436a96cbab46e5cd264405a3cc0fca','CU-7C0217BB5A','554049a61ffd56a348ba045c92850e5b28abb8ddf0357b18eefab7868fa5ffaa','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('747d4ce8-8206-437a-ae42-9a84186617b8','LEC-PROF-NOAH-MIDAMBA','Prof.Noah Midamba','prof.noah.midamba@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','5add508cf8044c20cf47b4ca811239ab91aee3e809aa5993672c834c7cc56673','CU-1106114303','c296e578d35574774708ea8b2b420f4b78962a5910d8f9cd1cb8d10239be2cee','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('541b518a-6462-4693-b7f5-9d0be6e6551d','LEC-MS-NOAM-EVERLYN-ABENAKYO','Ms.Noam Everlyn Abenakyo','ms.noam.everlyn.abenakyo@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','05bf39c59089dc4979a19639285dcb41943ad4591e9a94bac7980bf50e3e71b8','CU-AF7A1B389C','8a110a52b4d08dae41edfb03f3b5bf62a6cca4fdfab8aa025448bf7a4b2d7f4f','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('57518cc9-c8aa-44ab-8908-2d066176afe0','LEC-ASSOC-PROF-NORMAN-MUGARU','Assoc. Prof. Norman Mugarura','nmugarura@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','f3bbae205e8de9ec61ea986720c74efe1cb404a4d90aff8ca662899f7639d1aa','CU-B9B883F249','467edfd1d4b960ed40c7ff3c2fd9124fb17bf6f6479a798219be5b47f85c1f9f','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('0b659423-f265-435d-9adc-07870a4dbda1','LEC-MR-OCHWO-GEOFFREY','Mr.Ochwo Geoffrey','gochwo@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','d9f19ff35a250989965949b3a897471f11b285eb411dad43cfff13f3e684b611','CU-09C46CE9AD','77d370fe2fd23b156416e9c049c1a5d7c55fe82f799dd5c746274df066c4eded','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('90f6d13a-6a53-4220-a8fc-b24b4f53b8ea','LEC-MR-OKELLO-PASQUALINE','Mr. Okello Pasqualine','mr.okello.pasqualine@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','39637052341482a6f46fdf8982ab5c512fa571b537cf3d4590723cb57c0bdb90','CU-F80331ECF2','12083162066c70e6f9b5fd2974e1c3a6608db6eb973c0e9f39e80ba6375427f1','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('2f7e03e2-0dd0-4c32-b02d-398a62cb055b','LEC-PROF-OLOMOLA-OMOLADE','Prof. Olomola Omolade','prof.olomola.omolade@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','f0136b2e2809d1d749b395535df41c1fbb94aa572896c994ac6ea3fde15736ae','CU-FF6D1F4C1A','ef0b7e9ee1d002963f011f813b0863aa0dda86ca123bf095caeb9515cebaad50','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('0b6273ef-d8fa-4b4b-b6b0-4a932aeb3b4f','LEC-PROF-OLUBAYI-OLUBAYI','Prof. Olubayi Olubayi','prof.olubayi.olubayi@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','a233517c84f534ca91cfc28de01fec6b9b688e3470b80eb9be2b01c3f12880f0','CU-CA7F4FD1F7','f1738a19333957dc095504c66635c7601d9971e38da7f2d36d8b487ebc8836ed','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('f963764d-3be5-4944-987f-de6b0872d7d8','LEC-MR-OPIO-GREGORY','Mr. Opio Gregory','gopio@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','700e05f26a295db74795c68f9a5665c854b48880e6995b4e2ed7768bebf78687','CU-AEA966E874','f76d64462951d96dcbc6d5667940f2633b5e54fbc811930e640b31e178b898c1','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('0c2fec54-c238-417a-a260-80a43d6d953e','LEC-OSCAR-CORREIA','Oscar Correia','oscar.correia@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','ef7b364d02a842d87290170580e5cc09e1bb42b0a1c29d50c330fec09f113221','CU-88247C5E43','562e3c102c25c6165ba5d682665cf0ca98ccb945e9d998dcac8d713dbaf3e990','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('90049613-0de6-4fbd-a908-9f51e48e0ff6','LEC-PASCHAL-KIBINGO','Paschal Kibingo','paschal.kibingo@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','de922c1d808fe6c96fda96f315752fa40d2a640ac0531a209876f1eca247c2bc','CU-FE461D038F','71f539959782f7e651a920d663c4839ce53427088de03a20111280b7492dd34d','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('bd4fb816-ccf4-48e3-8618-477ffcacc3df','LEC-DR-PULE-SAMUEL','Dr. Pule Samuel','spule@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','2f38cf02cc99f9dd40c15a4d4f65a4eda5b69efc137a53aa59f4ec322ba8eaef','CU-EDA95ED248','488aa1590a86e8b87366f3d95233d3aaffa1e07a7270df5534e55a02b849fc61','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('aee10928-3a11-4b2e-9e41-0b34d0f2f19b','LEC-DR-RACHEAL-AINEMBABAZI','Dr. Racheal Ainembabazi','r.ainembabazi@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','0d1553c0d28a14ba0bda1b4edc16a126f7189a7f6d65bf0cefd6b1fbe9b9d4ae','CU-9347573126','bc6d2962f9488eb3b0b2ebc2f71a735036edfc5961eb6937ebef1a9ca4ff8d5c','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('ac5d7730-aeb7-4e60-9f78-b11d744e43da','LEC-RENE-ENO-AKPA','Rene Eno Akpa','rnkongho@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','425b9ee2648d1059f638a216442df6a652f9d8b955489c5f0e856e9b62be4354','CU-FF6522837D','845ae7d97ede04fb8c03001eff69b7bec3645ff4858c31ae7792c8011f930387','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('5b690ac2-1b30-42d6-add3-8078738a8f83','LEC-MR-RICHARD-WATENYERA','Mr. Richard Watenyera','rwatenyera@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','a8343f4f42db59acc5ef4bf8c0f5254829f93fca13726138156b07bc2f3e3dc2','CU-7D6E05DC9B','08ea8674a05a9217f792200cb094658ae527eddedf3f7e5b890ae8415da69a03','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('3a5ea5f6-d68e-414a-a0ef-2abe3aaf27ab','LEC-MR-ROBERT-ATENG','Mr. Robert Ateng','mr.robert.ateng@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','17cf9392d4495b3288b5f3314eee69a62724ad1459aa41d90b65ae35fb2b41d1','CU-34FEAB739A','a136697b2ed17ea81e9792975b62a37a472a6bcec1827702e0abd374c8930da9','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('e269d819-125d-4336-8290-1d20a61ffe02','LEC-DR-ROBERT-MUGAGGA','Dr. Robert Mugagga','dr.robert.mugagga@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','4b4bf2d542ffd06fff6a16e834bce50bbdba81d44852899ed0f4e7f22ea1d274','CU-428BA7DA3D','ea463f6d4f65e6eb3cf6265faf5e2c202b6f9cbc18bcf837b8afa70ff0a4a12e','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('91feeff5-6cd9-4527-a532-d628dd199328','LEC-MR-RONALD-OLAR','Mr. Ronald Olar','rolar@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','a2d81044e033ac56ea0ef462d067cb93f944c163edaa9c0a793782f8251aca5a','CU-A74CC77425','e27729a2b4f661cc63dc89807a7bdc412b6ef715e2c1c4ff1df2b1e78dd03906','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('aaa04952-174f-451d-8b1a-6635b4831b00','LEC-MR-SAMSON-RUBAYIHAYO','Mr. Samson Rubayihayo','rsamson@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','0bb5f70cac012eaeb29689bee916b5d6b8a3d8cb098841c120311d413b2d256d','CU-C47A9EFCD3','fae2d70060a843732613bd42cd948491b3b761d29ee55347ec36e10b5900ba31','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('3efe4d57-67b6-40dd-88ab-c3805ef97e4d','LEC-SARAH-NAMAZZI','Sarah Namazzi','sarah.namazzi.1@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','5446d469bcaf9c59c1c923bfff9cb87dddf9222e3ff70cb23a8b96cff1ea532c','CU-DC095E6FE4','e32efb1f3e2fa3d68e237bae81b0e350e3cb8f96677bf081ddcb7f9ef2c2c56c','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('d46d7fba-8e80-4080-89d0-f1a2b3c4d5e6','LEC-MR-SENYONGA-MARTIN','Mr. Senyonga Martin','m.senyonga@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','d35a8bb3a6d84bc055191dd0751595ea78f6ebfc72627799999b90c6fb4d7c94','CU-7B1721F97E','bbda6a6f3b68dbe7299e1f2f9c3195b52ebb8ec49b5e8d7d187d1985e6ee2f8b','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('0ded251d-080e-4fe3-b787-1be53043b83b','LEC-DR-SHALLON-ATUHAIRE','Dr. Shallon Atuhaire','satuhaire@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','2b91decf33f140bdec3b61d117e1853b661bda0cb3b7a7ae03f116e70e5568a7','CU-D48C660410','bd142688b4fc57e856936596a51b08d3d9421efb711e2268069ce96ec915e825','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('2356b72e-5824-43d7-8970-9571744b5bb1','LEC-DR-SHUAIB-MUHAMMAD-RABIU','Dr. Shuaib Muhammad Rabiu','dr.shuaib.muhammad.rabiu@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','e48339f3850453abb2d35c4610ed711764b70ab9b44c3eb1645089185ee379b2','CU-5EB28D1876','e0a58aa83739744cd14578be9eca167e86a6c8e71b17789f211b22ddfa08d00f','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('d2d34e55-ed3a-442d-bd05-93761827f693','LEC-DR-SIMON-MUTUNGI','Dr. Simon Mutungi','dr.simon.mutungi@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','4abfafa0f09948bb09b8ec568c5950c9eb7860756d139cf1ab70b67b8617eef5','CU-D5C9854B37','c82c8acc6c297f9c99f875bdc4371a9cb71e0d9c4dd0df592e66b439f51bff2e','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('90c1c369-8855-4032-8b61-46f7da81b8f1','LEC-PROF-SOLOMON-MUCHWA-ASII','Prof. Solomon Muchwa Asiimwe','prof.solomon.muchwa.asiimwe@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','1a0b3e576db0c2f53572f8d2d09ff4afd9e7017ecc8fb26c5645b9b3312ee821','CU-8725EAFC9D','6e80be4f6fb3ec24955a97f59e31591467100b1845b0c21e94d5a61a68019d00','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('a69fa820-b3f8-4fe4-902a-0d82e50c36d6','LEC-MR-SOSTINE-NGABIRANO','Mr. Sostine Ngabirano','sngabirano@cavendish.ac.ug','lecturer','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','7206f41f4be16bc4f98bfc37bfe883816764abf047078b8f649e33af7c42250b','CU-8A36686818','ce52a7d451d8e48216b286da9166c1786faeedf4ef4727a4ea56a7cb81f18285','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('784d6282-cc5f-4746-932e-c3b42793812b','LEC-DR-SSEGAWA-JAMES','Dr.Ssegawa James','kssegawa@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','6bb9a8be019618697eeb07cfdc018c38ad4853b734a43850c882c88616b1d821','CU-F20633D797','3f7b4d95628eba2d916f7a3e3924a57e804df595620d5f83816710b9520f2e8a','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('a79a0ced-1fb1-4fb1-b2a3-c4d5e6f7a8b9','LEC-MR-SSEGUYA-IVAN','Mr. Sseguya Ivan','i.sseguya@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','b0ed295eb9e8e078998916ee886533f3287fe8753cada908d9c3030c93853df2','CU-0A7FCE07B8','0095a4a88fca206610f18eb9fbd0e7cae86147b6ea5c17e67ca6c20fa22fd152','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('dce6f48f-a7e1-4b28-bad2-20ba1d81bebe','LEC-MR-SSEJJEMBA-MARTIN','Mr. Ssejjemba Martin','m.ssejjemba@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','57405e7f6f3c6a26ac7fed6c0255d7a81ddf0363d3a9f38e2c99c4996878e826','CU-0492C4A26A','a9f723b43d96797c2d1b5a239765a19370939a4c0cd220847d72cf61d646364c','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('4d0005ed-880d-4761-af9b-00ad3460637d','LEC-MR-SSEKALO-ISHMAEL','Mr. Ssekalo Ishmael','mr.ssekalo.ishmael@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','4e247d981080009d6bdfa85d8657a85fffc95c53f97510a6dd6df92f1beb4360','CU-664D6F8351','cc4c8c96f8520db030fec36524977691c8fbc1817c41dddd4738d95eeda2192a','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('0981d0e1-d1a1-443b-ae3d-8be8799e71d0','LEC-MR-SSEKALO-ISMAEL','Mr. Ssekalo Ismael','issekalo@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','64dd38cd5404367ba23f0bf98b0f54a7b07b0cbc83bf5bd06d77282e3bf746c8','CU-C090366A97','6d168dda504d31735f818480a7a6e86973b5559a96812d84e70f69a8ce834de2','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('6a9272e6-723a-4858-973b-28b5900cc818','LEC-MR-SSEKAWU-BARNABAS','Mr. Ssekawu Barnabas','mr.ssekawu.barnabas@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','833988e6ef6620bf5be8d6858d2362d41ef35baee26a309ba96c946ef3dc3fad','CU-5AF88DCAD6','b74334c02e23ae275346e1bfceca4ed4b542a34e8e232edfe63fa457b7d169d2','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('5b8a404e-8b17-43d0-a09c-8414649481b2','LEC-MR-SSEMAKULA-HABIIB-MUSA','Mr.Ssemakula Habiib Musa','hssemakula@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','b609bdfc1794d02327e4f5903893eb9e42aa6557ceeaf5fb6607ea2290ef959d','CU-DB21BB8AC5','32d90620552d0c745201ff6ef08743c3e7d15c2874b401cc7745f216dae8df6d','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('d6f30389-4ed2-4e9c-9095-d47837e041b2','LEC-MR-SSENGENDO-MOSES','Mr. Ssengendo Moses','mr.ssengendo.moses@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','dcc3ac55b426cf1374ae6fbd162445e2f79b1f4ba716ab45cd06cf799ee098e8','CU-7D97030F89','256755c33e99fa3fd8a05b6b4846f2e548db545b63786e235e6efcf099744988','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('0b7f4997-a2f9-4ffb-8ced-68c50dec2e15','LEC-DR-SUNDAY-UCHE-A','Dr. Sunday Uche A.','dr.sunday.uche.a@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','4781c2ff1a5fdcd6fcedf84527d43814019fff91583c742f1d8d689071914e1a','CU-E1D3D1DF1B','019425ab34192c201d276f9a84344eb3853d6d8ca9c7938162e5eca047cc3481','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('fed2c3b0-c35d-442d-a7ab-2e905c524bda','LEC-MR-TAREMWA-DANSON','Mr.Taremwa Danson','dtaremwa@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','71367c8d18777d5e132cf22c3af5248505725c5d23e9cf23dcbc1a09abe0725b','CU-77E5F6C974','02eca4a3d5cd10521ee316289c7a2b93eecdc22c3a53a3b06ff82b77389f4943','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('523e3bd4-989a-422d-ab05-247a7579796a','LEC-TBA','TBA','tba@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','33edf7587512b3c87e0fbec09c127fece6c8d0b502e8735437d11e9a1b4c2888','CU-4CC07B3765','4ba570944e0be92bb6fb60669d5c2baa89fa286beb66a6371308dea2fc0b104d','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('6f576a3a-a80d-4ff6-a436-6726f48eac77','LEC-DR-THOMAS-RUSSEL','Dr. Thomas Russel','trussel@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','a4f40a96f2bf1e204eace83166ca28e21b18a3f691ff15714d8f764e2129b23b','CU-AC74DC7BBC','e644b683c4b27f1965d09828dd41defe5b97dfedcccbea1993788d08d1f64012','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('aa89cbdd-b719-4c60-a3cb-49837feea2ff','LEC-MR-TUHAISE-ROBERT','Mr.Tuhaise Robert','rtuhaise@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','c9403da4380c32379d381d1d9778c0e5fdece2e48d82c5773021482ab563db9b','CU-AAEC9A8656','051324ddf10aaf009582bb46cac0c9ef48529d6ebb4079d5765ec9512da4cf1b','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('d9daf77e-d52f-44e1-958a-5ba9b6811c99','LEC-DR-TUMUSIIME-ANDREW-GAHW','Dr. Tumusiime Andrew Gahwera','dr.tumusiime.andrew.gahwera@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','eb74ca76c578e957efbbe0dde50603a47e02e3fb0e917b4ba846b4eafcc6f242','CU-A0AB162731','3cb95be9ca007c34528f604894ea629d2539d6ac37b526b55c284e38e670671e','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('3e85330a-5024-4b3a-8746-7e8fa4cbf75c','LEC-MR-VICENT-SSEKUNDI','Mr. Vicent Ssekundi','vssekundi@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','12cab156499bf570fb3a9b9d36f15bc215c92c2e1e8dd4267e9d10399ba621a8','CU-879C796FFA','ab9de5c528527f2a20a70ed0209954db8b9f5f7ed10ab9c945d20985ecb81a23','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('47ca1e41-120b-49a2-ab3d-fe3cad7ea20c','LEC-PROF-WABULE-ALICE','Prof. Wabule Alice','awabule@cavendish.ac.ug','lecturer','422a6c15-127f-47d5-a044-e7547d35dcb6','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','619ad87af530cdf9adccd32f1c592b5f5a2361bc377c83d0ac0658c66324f76b','CU-FDBD18B993','ab62263744bcc457c8c1b803ca5a6b08aa7933d91eac788c7ba433f7d5c4ba9d','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('90e5cc94-c996-4854-8300-0f480d255a96','LEC-WAFULA-SOLOMON','Wafula Solomon','swafula@cavendish.ac.ug','lecturer','06a806fc-0d90-4c27-877d-1025a3ebdbd1','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','06f46c6ec2de91bbee3e0aa051f861cd696163d3fc215a5763ef612c9c3851bf','CU-426625C061','da9fcc90c20227bb061245c4f50dfe015d48fc5fbec80dd20bbbdffafce2ee71','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('f747cb88-b0df-4cb2-9158-d7a61695b470','LEC-MR-WAIRINDI-DANIEL-KATON','Mr.Wairindi Daniel Katongole','dkatongole@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','c5c029fc93bc46fb16d9f72de903311d8258618123f267a6c0c9d452a9840522','CU-C84DBE5DA1','158e2947b398260658be18806754fb5cf7d8fe1c14cc53d0f06bde970b72a6bb','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('0f4a1369-cfa8-4246-a139-cc3bf1b79e02','LEC-DR-WILBERFORCE-TINDYEBWA','Dr. Wilberforce Tindyebwa','dr.wilberforce.tindyebwa@cavendish.ac.ug','lecturer','0d35fa69-de7f-4e05-b800-16c07321e75f','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','9a4af06d3739ea84394eb807ab944717b3debb9f66b99181cd11ca91e059b177','CU-FEB2392B79','5ad94f6b97c293ebc2d309c607a702cccb68bd64fd7f3b55bea27973d63da6b8','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;
INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES ('2de1a8ec-b004-4be9-904e-887f72f1075c','LEC-YIGA-MULINDWA','Yiga Mulindwa','yiga.mulindwa@cavendish.ac.ug','lecturer','96178a5a-1a50-43ad-ace6-045b0e7dd47a','$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2','439a4be6ae510354e1c67b6000ff133152ca288dafe48712c1bc3a1863f3fffd','CU-0B7AD0783E','0a4c9c7ccb14a27f0fc13c9c653d8bf2b3b22fd1d319098bf20eee5201925f71','physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;

-- Modules
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('27440a23-56c5-4d9d-a535-c9b45cb2bf37','ADHM1101','Information technology in Health Services Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','47835404-5a90-4960-bee7-2b7cb6f9f4df',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4bf8699e-5235-4d64-8c02-e5c4b99df60c','ADHM1102','Basic English Language Communication Skills','06a806fc-0d90-4c27-877d-1025a3ebdbd1','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('efeb260b-713c-4d9e-a689-7340d648eb32','ADHM1103','Managing Primary Health Care Services','06a806fc-0d90-4c27-877d-1025a3ebdbd1','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','328e043e-56f9-4311-8172-1b4df729f145',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('d83a2ca6-16b4-4089-a21e-3d3939cb96d6','ADHM1104','Fundamentals of Epidemiology and Biostatistics','06a806fc-0d90-4c27-877d-1025a3ebdbd1','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','90e5cc94-c996-4854-8300-0f480d255a96',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('84bc9f5a-e2d0-4c8b-b837-ae3be666372f','ADHM1105','Fundamentals of Financial Management in Health care','06a806fc-0d90-4c27-877d-1025a3ebdbd1','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','328e043e-56f9-4311-8172-1b4df729f145',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cc70cbc6-6574-4c45-a201-53b0aa65bbbb','ADHM1106','Health Service Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('532273f1-86d9-455a-852f-4d0851dcb1d9','ADHM1201','Environmental and Occupational Health and Safety','06a806fc-0d90-4c27-877d-1025a3ebdbd1','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','def38337-4c53-49c3-b348-7612934115ad',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('7d197f32-c5c6-4efa-abbb-a25100b751d4','ADHM1202','Human Resource Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','90e5cc94-c996-4854-8300-0f480d255a96',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c00a4c8e-3b58-4d21-9338-3abbf745c186','ADHM1203','Management and Maintenance of Health Material Resources','06a806fc-0d90-4c27-877d-1025a3ebdbd1','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','328e043e-56f9-4311-8172-1b4df729f145',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e174adf9-022b-458c-974c-3a67ab59cb1f','ADHM1204','Project Planning and Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','90e5cc94-c996-4854-8300-0f480d255a96',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b3512e0f-4edb-4f32-8304-5fba829d8a50','ADHM1205','Mobilization of Resources for Health Services','06a806fc-0d90-4c27-877d-1025a3ebdbd1','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','328e043e-56f9-4311-8172-1b4df729f145',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cbe911e9-54e3-4714-a57e-f30c74d22f28','ADHM1206','Fundamentals of Action Research in Health Services Research','06a806fc-0d90-4c27-877d-1025a3ebdbd1','77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb','90e5cc94-c996-4854-8300-0f480d255a96',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0c4e4af0-2682-4a73-bb9f-645c95332ac1','AGM212','Entrepreneurship & Small Business Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','6bc87c82-c6e2-4553-b120-0788ea05da23',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ca2f56de-6e4f-493c-a62d-e94a2740d0c1','BAC215','Auditing I','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','de345d62-f4a2-4f20-9804-c4b0c9f882ef',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('799a27fc-661c-4dce-862d-1e1dcb4fb9d2','BAC313','Advanced Accounting I','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','05ab10f4-68a7-4f83-a82a-b662b3574dd7',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('842e2fab-7a75-4907-a19c-b5ef57d6c009','BAC314','Public Sector Accounting','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','de345d62-f4a2-4f20-9804-c4b0c9f882ef',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('5a07a7b6-16e1-4d9b-8689-d7a7dc0185f0','BAC316','Computerized Accounting I','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','22640f68-e8c9-43e7-bd70-59ba276acbbb',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('20ee1444-dd2a-4261-8206-57f22d14e4ec','BAC321','Auditing II','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','22640f68-e8c9-43e7-bd70-59ba276acbbb',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ca6508a6-7dd6-40e5-b30a-cfa8d570154d','BAC322','Advanced Accounting II','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','69d032d2-c432-4c24-8801-f59b948f2e6f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('002ebbd0-bb8e-4af9-aaf0-ba99cb233fb1','BAC326','Computerized Accounting II','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','0fd2a1d2-9b26-472c-bd86-5051a9fc8436',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b211ddfa-f05c-423f-94f8-fcc76ca01eff','BAC327','Treasury Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','3be662be-54eb-46b4-aa44-2b3ea30b52ce',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ee36ab7e-1619-4c23-b0f7-ad8df26e247e','BBA112','Financial Accounting','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','f747cb88-b0df-4cb2-9158-d7a61695b470',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('84df1a33-9665-4ee1-8ea2-80d7e8014dc9','BBA113','Communication Skills and Learning Skills for Employability','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6de537b0-5863-4c5b-91e6-7d3260523ac4','BBA115','Business Administration','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','05ab10f4-68a7-4f83-a82a-b662b3574dd7',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ac55c76f-f6c8-46c9-b9ff-80dc4f45bc9e','BBA116','Basic Statistics','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b7375fac-a5a2-4a20-bc11-0951a572ac4e','BBA122','Quantitative Methods for Business','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8589f97c-7d04-4632-87d2-da3ffc602e6f','BBA123','Macroeconomics','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','1d26ebc3-1c74-43fb-9261-3514e85c8747',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0a525659-a999-42b5-b22f-c8d79a79e24e','BBA124','Principles of Marketing','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','98bd6033-b693-4368-96a3-66a8edd4141e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ef146d40-db2c-4722-b249-5797060bdb89','BBA125','Business Law','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','40e8500b-3e15-4446-8cd9-9052435c6717',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c27565a8-4abd-4539-a18e-576655da7a54','BBA211','Managerial Accounting','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','22640f68-e8c9-43e7-bd70-59ba276acbbb',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ea9d9858-0da3-460e-8461-012ff44d6f07','BBA212','Organisational Behavior','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','de615d4f-d8c4-4dc7-bff0-389508668cd5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('d2fa4b41-afeb-4c27-a9e0-64353524acde','BBA214','Entrepreneurship & Small Business Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','6bc87c82-c6e2-4553-b120-0788ea05da23',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c37b7984-3415-4ed0-8f12-d47b4cfd24ae','BBA215','Human Resource Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','91feeff5-6cd9-4527-a532-d628dd199328',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('f064b6c0-8dd2-44ab-9fbf-d235f1bfc64c','BBA216','Operations Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','de615d4f-d8c4-4dc7-bff0-389508668cd5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3d98cf99-0240-4e63-a012-4d0383abb250','BBA221','Strategic Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','f747cb88-b0df-4cb2-9158-d7a61695b470',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('204ef6d4-cd78-415e-866d-95b528c678ef','BBA223','Taxation I','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','bc49574b-49f5-469e-96b9-b1267ee50f22',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1c6061d0-2501-45de-8b93-4678d02de344','BBA224','Business Ethics','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','cbdf9c6c-b096-45a9-92b0-12dd4a5ded62',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3e863076-8f78-4481-ac2e-21b619bd12be','BBA311','Principles of Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','1d26ebc3-1c74-43fb-9261-3514e85c8747',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0898b3a9-8033-4121-b341-5b1eab119f47','BBA313','Quality Systems Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('f03ebefc-e0ca-44ff-88fb-b3c82d92c44e','BBA314','Investment Analysis','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','7af19cce-b1f0-4770-8090-0e942721663d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('21430891-4a07-4553-91f7-c72b4d2871f5','BBA315','Marketing Strategy','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','98bd6033-b693-4368-96a3-66a8edd4141e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3431ed0f-342d-4c40-8fc2-f9904d2daa17','BBA317','Taxation II','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','3be662be-54eb-46b4-aa44-2b3ea30b52ce',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9bf12604-1805-4040-8320-26e932801de5','BBA321','Auditing II','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1d666046-3469-4140-9d46-a2363d48ae9d','BBA322','Project Planning and Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','1d26ebc3-1c74-43fb-9261-3514e85c8747',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9dce9966-861c-4ec9-bfb7-2c47c376b643','BBA323','Business Risk Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','f747cb88-b0df-4cb2-9158-d7a61695b470',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e8fea878-9a84-48e6-b5cd-921008d615b8','BBA324','Managing Change in Organisations','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','1d26ebc3-1c74-43fb-9261-3514e85c8747',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3f3ecf20-66ef-40d6-9a0a-0e645f681392','BBA325','International Business','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c4ce8125-0704-42eb-a319-ae0952bbd7a4','BBF222','Financial Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','0fd2a1d2-9b26-472c-bd86-5051a9fc8436',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c7278241-5123-4669-9113-927a5492f6a8','BBF311','Banking Technologies and Systems Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','de345d62-f4a2-4f20-9804-c4b0c9f882ef',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('19091cab-4bfd-4990-8710-895fd921e7db','BBF313','Banking Operations','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','05ab10f4-68a7-4f83-a82a-b662b3574dd7',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('7059d4a1-f8f1-40ea-8656-5ee494b618d3','BBF315','Corporate and Merchant Banking','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','bc49574b-49f5-469e-96b9-b1267ee50f22',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('f6540463-998a-4394-9d3f-9309c8e3e9c2','BBF316','Public Finance Administration and Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','69d032d2-c432-4c24-8801-f59b948f2e6f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ac995bb6-6e16-44aa-90fe-d590b3c051c0','BBF317','Company Law','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','bc49574b-49f5-469e-96b9-b1267ee50f22',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b5dd06a5-9f25-485c-992f-707ac17228cd','BBF322','Regulatory Framework of Financial Institutions','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','de345d62-f4a2-4f20-9804-c4b0c9f882ef',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9ae668fc-14cd-4619-aff8-685f89c4ece0','BBF323','Security Analysis and Portfolio Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','7af19cce-b1f0-4770-8090-0e942721663d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4c19cae4-0773-4251-8ed1-c61f6cad8fdc','BBF325','Banking Law','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','0fd2a1d2-9b26-472c-bd86-5051a9fc8436',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('14611d83-b716-4d56-882a-1e228ee756b6','BBF326','International Finance','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','f747cb88-b0df-4cb2-9158-d7a61695b470',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ecba096c-6020-4e0f-af2e-fa10d6031b68','BDA1201','Design Thinking','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000007','1f20f39f-cf5e-4beb-a853-771e6cc91c93',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('482ff3c1-9e91-45a7-b141-570fe9786af2','BDA1202','R Programming','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000007','e28f11aa-0f8f-4ec1-9090-89f45609f9dc',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('db020d67-a32d-4286-9fc6-aaa6c828a064','BDA2101','Data Ethics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000007','a995e09a-d0ec-4c3a-8161-e11f7e70f5e4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e55f589d-5fa8-41a0-bf16-480a29a06c91','BDA2102','Data Wrangling','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000007','d9daf77e-d52f-44e1-958a-5ba9b6811c99',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e7cd6035-3082-4725-9be8-9d2a0f86b931','BDA2104','ASP.NET & C#','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000007','696d8165-f8fe-451b-8041-a45dae05eb52',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('af55f3fc-ebe8-4990-9832-cc678471e828','BDA2201','Microprocessor and Microcontroller','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000007','e28f11aa-0f8f-4ec1-9090-89f45609f9dc',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('441139e7-26c2-4a4e-9018-b4e868be91c5','BDA2202','Front End Development','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000007','696d8165-f8fe-451b-8041-a45dae05eb52',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3d260092-6a59-4e6f-93ed-fd14af6d2343','BDA2203','Analysis and Visualization','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000007','7afc7ef4-d142-4778-9b72-29d3c9a0b6be',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1951663d-a14e-4b63-bb99-02ee62ddb170','BDA3101','Augmented and Virtual Reality','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000007','7afc7ef4-d142-4778-9b72-29d3c9a0b6be',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('997a0e51-9b70-43f0-b3dd-17c9a916100e','BDA3103','Advanced Artificial Intelligence & Robotics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000007','646fe3f0-10f2-4801-afde-5f5bd24cc73e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9a08e890-3cb2-4294-86be-4a006523243e','BDA3105','Advanced Data Science','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000007','1f20f39f-cf5e-4beb-a853-771e6cc91c93',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('f886788c-181b-448c-8d9d-8cc9ab0540bb','BIS313','Business Systems Modelling','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','1f20f39f-cf5e-4beb-a853-771e6cc91c93',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('403376d8-a337-4c08-8218-9e67bf99e5da','BIT110','Introduction to Information and Communication Technologies','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','47835404-5a90-4960-bee7-2b7cb6f9f4df',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e02c54bc-ed05-4235-952c-840c24f72ba7','BIT111','Discrete Mathematics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','be31f7c7-6319-44df-a6e7-216f1cabf6f8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6fd26efc-16e6-429a-a273-f4e9cbdafc06','BIT113','Fundamentals of Information Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','40580b57-e389-475e-a791-5d8d5e51b1e8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c8d49597-51c2-4349-b336-c74d9b43de7d','BIT121','Database Dvelopment & Management I/Fundamentals of Database Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','47835404-5a90-4960-bee7-2b7cb6f9f4df',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9c516262-1293-429d-85b3-e898ca3bbf9f','BIT122','Internet Technology and Web design/Internet and Web Programming 1','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','5e6494d5-e109-452a-9703-386a1a04409c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('68670dfe-f68e-4af7-9531-457451fb7662','BIT123','Computer Applications','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','a995e09a-d0ec-4c3a-8161-e11f7e70f5e4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('73ad3666-16a4-4ef5-a502-d370869c381a','BIT124','E-commerce','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','40ac889f-82c1-4014-af80-95b51cc94f3e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('dea1864d-9321-47d2-8e86-5b01eaa9720c','BIT125','Information Systems Management','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','40ac889f-82c1-4014-af80-95b51cc94f3e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6e6b5baf-e4ca-4bb6-bd6a-41965cc4020c','BIT212','Systems Analysis and Design','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','40ac889f-82c1-4014-af80-95b51cc94f3e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('d6638caa-dea0-4972-af19-f11c57cc1fc8','BIT213','Web Development and Management/ Advanced internet & Web programming','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('235aa447-31b1-4e58-80c5-53ce0609b395','BIT214','Computer Networks and Data Communications','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','aa89cbdd-b719-4c60-a3cb-49837feea2ff',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0e39b949-4b56-4669-8f03-9073590b2236','BIT215','Database Development and Administration','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','47835404-5a90-4960-bee7-2b7cb6f9f4df',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('664f0905-41fe-4a7f-a5b9-2b06948092ae','BIT222','Research Methodology in Computing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','784d6282-cc5f-4746-932e-c3b42793812b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('989825b5-9148-40a5-9170-61f35dd5943a','BIT223','Computer Assembly, Repair and Maintenance','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','aa89cbdd-b719-4c60-a3cb-49837feea2ff',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1552cf78-cb15-4519-be66-129c69af0dd0','BIT225','Emerging Trends in Information Technology','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','1f20f39f-cf5e-4beb-a853-771e6cc91c93',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('2eb199a8-63ab-418e-9ce5-ba83672cb11b','BIT311','ICT Project Planning and Management | Managing Software Engineering Projects','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','cc78b85d-92b6-45e1-a869-3a26d17a1e4a',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('44065f80-2989-4575-ab47-3e3f402a456d','BIT312','Mobile Application Development/Mobile Application Development 1','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','fed2c3b0-c35d-442d-a7ab-2e905c524bda',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('76512bca-4424-483d-8d5a-b2234dd8c605','BIT314','Network Configuration and Management','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','aa89cbdd-b719-4c60-a3cb-49837feea2ff',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('641c6e68-4e36-456e-80cd-6e1de9fd40ed','BIT315','Introduction to Multimedia Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','be31f7c7-6319-44df-a6e7-216f1cabf6f8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('09aa9229-06f0-42d1-88b1-00eb82d6b62d','BIT321','Professional Issues in Computing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','cc78b85d-92b6-45e1-a869-3a26d17a1e4a',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('dc35fc30-aa83-44ce-8bf5-a5f4a4353b88','BIT322','Distributed System Development','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('437ab51b-a79c-471b-bc1d-1b7078537c53','BIT323','User Interface Design','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','1f20f39f-cf5e-4beb-a853-771e6cc91c93',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0d10c1e8-684f-4ba1-af5f-2f54eedf14a8','BIT324','Network and Information Security','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','aa89cbdd-b719-4c60-a3cb-49837feea2ff',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('74217cb3-c399-4ecc-9ebb-ceda1d9a7f00','BIT325','Information Systems Audit','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','be31f7c7-6319-44df-a6e7-216f1cabf6f8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ddd1fdf8-a57d-4b14-9602-52d1b37090e9','BJC110','Communication Skills and Learning Skills for Employability','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','2e467318-632f-4dde-91ac-495d504e0aca',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('308a3aea-97c8-4538-bbf6-d71a4f06c017','BJC112','Introduction to Behavioral Science','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('58294315-b397-424d-9657-54566ebd4d1f','BJC115','Introduction to Journalism & Media organisation','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','74ee4b63-7440-4f0f-a46b-19ea8a4ed456',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8b7fce45-2f7c-41e2-a55c-8d680479ae39','BJC116','Basic Academic Writing Skills','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','2e467318-632f-4dde-91ac-495d504e0aca',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3cf01972-f61c-481e-bca9-70066daecddd','BJC121','Mass Media and Society','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a97bc7fe-d8d9-4560-9a41-19d0a0d305ef',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('479b65ae-876b-4660-8580-911873690323','BJC122','Introduction to Public Relations','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','0264fe58-61d4-4d6c-96ea-98db8fb0ac5f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('15c00a52-d3db-40af-9f7f-bddf963fa79c','BJC123','Introduction to Broadcasting','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','0264fe58-61d4-4d6c-96ea-98db8fb0ac5f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('32ec0630-09c3-414f-a3d8-ebbfc7966c35','BJC124','News Writing & Reporting','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','c28e32a8-f3ff-460b-9e3c-6cba0ba811d3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('832c35e6-8c66-4981-a5dd-26c9065f88e4','BJC125','History of the Media and Communication','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a97bc7fe-d8d9-4560-9a41-19d0a0d305ef',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ab42ad89-f465-4d78-aa27-870cbde06ed2','BJC127','Introduction to Media writing','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('bf4c1584-237c-4a64-abef-18677d864a7a','BJC128','Computer Applications for Media','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('75ca409e-68ad-46ba-8649-6f8dec285d31','BJC211','Audience Analysis and Media Research','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5b8a404e-8b17-43d0-a09c-8414649481b2',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ff3a07ea-3d71-47b4-97d7-affa8e3cecb5','BJC212','Advanced Writing','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','2e467318-632f-4dde-91ac-495d504e0aca',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('bf709ba0-1a5a-42d5-90e3-36d0738ceceb','BJC213','Media and Communication Policy','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','74ee4b63-7440-4f0f-a46b-19ea8a4ed456',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a99e8829-4515-47b3-894b-f144a34a605e','BJC214','Photojournalism','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','0b659423-f265-435d-9adc-07870a4dbda1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0c010295-ad6e-45fe-bb62-877abd3d08ab','BJC217','Media and Communication Theories','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a97bc7fe-d8d9-4560-9a41-19d0a0d305ef',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('2c7fba90-17ca-4dba-96f3-9ed485cac01f','BJC221','Principles of Advertising','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5b8a404e-8b17-43d0-a09c-8414649481b2',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ed108d1b-200c-4776-9320-75efaf8e8113','BJC224','Media Management','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','74ee4b63-7440-4f0f-a46b-19ea8a4ed456',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('aecd7c1e-2581-4c1b-9f73-e8753aa6db8c','BJC225','Development Communication','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('72bcc8f0-fc63-4d9d-a212-3d213b232ef6','BJC226','Media Law & Ethics','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a97bc7fe-d8d9-4560-9a41-19d0a0d305ef',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('74beca70-2eb1-42f5-b183-ef308802d213','BJC229','Commercial Photography','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('befe6f0f-4e7e-48a9-b364-92553a87391e','BJC311','The Art of Public Speaking','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a97bc7fe-d8d9-4560-9a41-19d0a0d305ef',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('7779b9d2-c8c7-4364-8f48-e89440545676','BJC312','Public Relations and Media Practice','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','c28e32a8-f3ff-460b-9e3c-6cba0ba811d3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cc476be4-25c1-4164-99bb-502771bf4283','BJC313','Television Production','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','0264fe58-61d4-4d6c-96ea-98db8fb0ac5f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a1b923af-9596-4ba9-9cc8-e42d0efeba45','BJC314','Multimedia and Animation','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('098adb37-c09d-4490-a434-c902b0c699b0','BJC315','Investigative Journalism','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','0264fe58-61d4-4d6c-96ea-98db8fb0ac5f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('5b49f441-7c9d-43f7-944f-447490e25535','BJC321','Journalism Safety','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('f7059d7b-a256-44df-b5bf-3c888d6e1c51','BJC322','Newspaper and Magazine design','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','0b659423-f265-435d-9adc-07870a4dbda1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9a0bd287-f95e-4e17-91da-cc92bfa87df5','BJC323','Radio Production','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','c28e32a8-f3ff-460b-9e3c-6cba0ba811d3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6090e2e7-eb21-4009-ac8e-6e4b92e9a54d','BJC324','Politics of Developments','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5ce17e91-6f5b-438f-a4d7-67e0726f0e8f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6e31de81-61b7-4ca3-97c5-80a5b56156fd','BJC325','Environmental Journalism','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('f0109a10-46d5-4b62-a5fe-03d0b9b47fec','BJC326','Media, Human rights and Gender','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5b8a404e-8b17-43d0-a09c-8414649481b2',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('d175caa1-39dd-4bfa-8c82-66d5a4cd3f68','BJC327','Environmental Journalism','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','0264fe58-61d4-4d6c-96ea-98db8fb0ac5f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('19eb8fcb-a83e-4b52-9cdc-cf89928f8b56','BJC328','Fake news and media production','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('2ec281e2-1161-4a85-8100-3911a218f70a','BJC329','Online and Digital Journalism','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6ff5bb98-d369-4d86-bf74-2a2dd2225ff6','BPA111','Public Administration and Management','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','d2242310-57c2-484c-9f75-5888c5aaa883',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('01f00351-43f8-407d-80f6-fabefce2d929','BPA112','Public Finance Administration and Management','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5ce17e91-6f5b-438f-a4d7-67e0726f0e8f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ebd4238a-8727-4d37-84eb-849cb4c4da62','BPA113','Introduction to Critical thinking','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','6f576a3a-a80d-4ff6-a436-6726f48eac77',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c998c838-fa1d-491e-9fff-65a44ce273a6','BPA116','Theory and Management of Organisations','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','e550342a-6d2f-4487-b076-e1dd5d354d29',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cd8ac452-8848-45a9-8528-5ea827b02cb2','BPA121','Introduction to Political Science and Classical Thought','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','3e85330a-5024-4b3a-8746-7e8fa4cbf75c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b1e8e7ec-4537-4a66-a56c-9cc3d76e8295','BPA122','Governance and Public Sector Management','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','622f90d0-0a3b-4ffc-b5b1-8e60d990a39b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('2a3c2db9-3a52-42ef-87d4-a9ac5adf1c90','BPA123','Decentralization and Local Government Administration','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','f963764d-3be5-4944-987f-de6b0872d7d8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('64b01657-8e9f-4f49-bc26-4aa7ffa14e16','BPA124','Organisational Psychology','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','de615d4f-d8c4-4dc7-bff0-389508668cd5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('59211b4c-e0d8-4f24-98b4-b6ba9e601708','BPA125','Gender in Public Administration and Management','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','622f90d0-0a3b-4ffc-b5b1-8e60d990a39b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9e40d6f1-1bb1-4717-bf04-4b5c850ab555','BPA126','International Political Economy','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','ac5d7730-aeb7-4e60-9f78-b11d744e43da',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6805cd51-d4eb-4339-a92f-628d867cb264','BPA211','Leadership and Change Management','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','d2242310-57c2-484c-9f75-5888c5aaa883',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4b613cb4-7606-403b-a9ce-91ffec0acd5d','BPA213','Regional planning and Management','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e10c9e4a-d896-40bc-99cb-a6ab80f33d25','BPA215','Environmental Management and Sustainable Development','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5ce17e91-6f5b-438f-a4d7-67e0726f0e8f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('805da78e-7d99-4102-a500-addc2bd16353','BPA216','Human and Social Servises Systems','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','e550342a-6d2f-4487-b076-e1dd5d354d29',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('d72c1711-4282-4b5a-a730-616e885be313','BPA217','Development Public Administration and Management','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5ce17e91-6f5b-438f-a4d7-67e0726f0e8f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('145dd7e8-58be-4d8b-82bf-58f04481159f','BPA221','Economics for Public Administration and management','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','3e85330a-5024-4b3a-8746-7e8fa4cbf75c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('45c8844e-9a7c-401b-8781-28c4596278d2','BPA225','Government and Politics in Africa','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','622f90d0-0a3b-4ffc-b5b1-8e60d990a39b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('7e1ad836-5520-46c5-99ac-6523b2693d89','BPA226','Demography and Population Studies','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','3e85330a-5024-4b3a-8746-7e8fa4cbf75c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8af53abb-7320-4c28-b218-b03cd62c8e87','BPA312','Public Policy, Planning Analysis and Management','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','e550342a-6d2f-4487-b076-e1dd5d354d29',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('dd721596-809c-497e-a475-4ccee7453826','BPA313','Civil Society Development and NGOs Management','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','3e85330a-5024-4b3a-8746-7e8fa4cbf75c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('31cc54df-e680-4339-bd38-6d44044f56a4','BPA314','Constitutionalism and Administrative Law','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5b690ac2-1b30-42d6-add3-8078738a8f83',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ea064ee9-8a00-4bde-9028-d1792d255d6e','BPA316','Management of Public Enterprises','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','e550342a-6d2f-4487-b076-e1dd5d354d29',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3e601610-30a2-49c4-b4b2-76f511337e85','BPA322','Disaster Preparedness and Management','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','ac5d7730-aeb7-4e60-9f78-b11d744e43da',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0baf05f8-e7c9-4921-8862-afda6d64e132','BPA323','Human Rights, Social Justice and Democracy','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5ce17e91-6f5b-438f-a4d7-67e0726f0e8f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0a84f54e-579d-4b2f-b949-4af086326fec','BPA324','Ethics and Professionalism in Public Administration','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','47ca1e41-120b-49a2-ab3d-fe3cad7ea20c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('bd17ddaa-8d0b-41cb-97ad-21aa7853478d','BPA325','Human Rights and Social Justice','422a6c15-127f-47d5-a044-e7547d35dcb6','22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5ce17e91-6f5b-438f-a4d7-67e0726f0e8f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('5652d17f-62fb-4d38-b9d0-3cba5c019f3d','BPH112','Health and Health Behavior','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('f3a2f2f3-8407-4b1e-9342-38fc5a29e324','BPH113','Human Biology','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ac15698f-4986-4a51-97e0-7fabcd361245','BPH114','Introduction to Public Health and Ethics','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','6a6f6b86-9785-47bf-bdb5-73051d9acb6b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('23b2c309-cba5-4e36-a4a4-573b9a92ec4e','BPH121','First Aid and Emergency Rescue','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','90e5cc94-c996-4854-8300-0f480d255a96',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('536b5d5c-ad01-4c33-b592-bb5a521db446','BPH122','Public Health Microbiology and Disease Surveillance','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','99d7e1aa-c930-49a2-9d97-45fc68a03711',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e53b4b7b-1d58-4766-9c13-3c64032ce6f9','BPH124','Communicable and Non-communicable Diseases','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('725f6e69-4dab-4421-aebc-f27738ff6a2c','BPH211','Public Health Nutrition','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','0ded251d-080e-4fe3-b787-1be53043b83b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('482fe535-78c6-4905-bf8f-abb6d73944d8','BPH212','Principles of Environmental Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','6a6f6b86-9785-47bf-bdb5-73051d9acb6b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('7d6d3a83-91ba-453a-be4f-c5a39526e009','BPH215','Principles of Health Promotion','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('92fb424d-7640-44e3-aeec-910d2674785f','BPH216','Principles of Disease Control','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','6a6f6b86-9785-47bf-bdb5-73051d9acb6b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ee9652d4-5f04-4da2-9c0c-3b8dab6e5a17','BPH221','Public Health in Emergency Situations','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a4be9099-f488-48c3-9163-3b23f3aa681f','BPH222','Principles of Health Education and Advocacy','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','6a6f6b86-9785-47bf-bdb5-73051d9acb6b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('fa5c115c-85bc-4c87-b62d-96b3010a5775','BPH224','Health Policy Planning and Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('58e105e7-bfb0-44ae-92a1-3c46cd3b6d9f','BPH311','Community Health Practice','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','6a6f6b86-9785-47bf-bdb5-73051d9acb6b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('400f62fb-8ebf-458a-a59e-399d0c918eec','BPH313','Family and Reproductive Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','0ded251d-080e-4fe3-b787-1be53043b83b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('40850041-2e08-48c8-9b07-dbadb40b8d01','BPH314','Social Marketing for Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('66196518-5e32-4415-9fa4-a1159087a528','BPH321','Health Economics and Financing','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('72c76baa-7209-4223-bea0-8f42bdb86b87','BPH323','Health Informatics [ Elective]','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','6a6f6b86-9785-47bf-bdb5-73051d9acb6b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4086b4e2-8827-4154-b780-69826e150358','BPH324','Mental Health [ Elective]','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('67e3e374-02ad-4780-8597-4cb43e1bf043','BPH326','Health Service Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb','d0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4bad28fb-2438-404f-a128-e78ecf58a7f6','BPR321','International Public Relations and Diplomacy','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5b8a404e-8b17-43d0-a09c-8414649481b2',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c35d3d61-ed35-44bc-b652-b5203e9f9332','BPR322','PR Strategies, Planning and Programming','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','c28e32a8-f3ff-460b-9e3c-6cba0ba811d3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0a1ff2ef-0620-4430-8961-a64cef56522d','BPR323','Politics of Communication and Propaganda','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','74ee4b63-7440-4f0f-a46b-19ea8a4ed456',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('34038981-5411-475c-98dd-d61f01766a1d','BPR324','Media and conflict management','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','c28e32a8-f3ff-460b-9e3c-6cba0ba811d3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c16ed47e-064c-4ffb-8ef9-7ed8b238ae7a','BPR325','Media, Identity and Representation','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5b8a404e-8b17-43d0-a09c-8414649481b2',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('97bc1930-b72d-4994-850a-123624b0c2aa','BPR326','Introduction to Public Relation Consultancy','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('368f8ede-0b8d-4a33-96ca-592c77915d28','BPR327','Public Relation Consultancy and Media Monitoring','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','74ee4b63-7440-4f0f-a46b-19ea8a4ed456',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('72c0aef2-8368-4614-8913-2952a6dfb5ff','BPR329','Digital Content for Brand Communications','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','74ee4b63-7440-4f0f-a46b-19ea8a4ed456',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ae6f9c50-5ab1-4257-b78a-1ec02dba621e','BSE111','Calculus for software engineering','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6cf170dd-c370-4a95-b856-ac2ab103e2a1','BSE121','Database Dvelopment & Management I/Fundamentals of Database Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','5e6494d5-e109-452a-9703-386a1a04409c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a6ee3dcb-d2be-4e52-b40d-7b63c5743de4','BSE212','Software Engineering/Principles of Software Engineering','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','784d6282-cc5f-4746-932e-c3b42793812b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('2131e19b-1665-4a61-8e46-72f2e76acad0','BSE213','Web Development and Management/ Advanced internet & Web programming','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ab5502ba-dc1d-4be5-a317-399ff48cf1fc','BSE221','Formal Methods in Software Engineering','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','784d6282-cc5f-4746-932e-c3b42793812b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('fde6588b-78fd-4fcc-ad52-e36c2b6b545f','BSE222','Advanced Object Oriented Programming','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','fed2c3b0-c35d-442d-a7ab-2e905c524bda',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('7bd2a8af-f954-48d4-8f11-8ed2c15dbd22','BSE224','Python Engineering','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','0c2fec54-c238-417a-a260-80a43d6d953e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('66a6e359-f067-45af-a909-952da67dfde0','BSE226','Software Requirements Engineering','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','be31f7c7-6319-44df-a6e7-216f1cabf6f8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3c7a3c73-5b5d-44d1-9842-da1433d3466c','BSE311','Mobile Application Development/Mobile Application Development 1','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','fed2c3b0-c35d-442d-a7ab-2e905c524bda',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9a04e9d5-0d07-4b73-a50b-8f08d860bd34','BSE314','Internet of things','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','5e6494d5-e109-452a-9703-386a1a04409c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('fcfbc893-92ab-4341-8d7e-3c12b036624f','BSE321','Software Metrics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','fed2c3b0-c35d-442d-a7ab-2e905c524bda',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e04841e0-b10b-49cd-88e6-3d61965d45c8','BSE322','Advanced Mobile Applications Development','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','1f20f39f-cf5e-4beb-a853-771e6cc91c93',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('396c2042-6cb1-4832-98c6-520053c8addc','BSE323','Software Architecture & Patterns','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4ae9eaa2-d4c6-4983-abac-952505bad5a9','BSE324','Mobile Communications Systems and Applications','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('5275e37a-a8b8-4fd5-8852-23ce9728885f','BSE326','Software Evolution','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','646fe3f0-10f2-4801-afde-5f5bd24cc73e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3eea365d-bd9d-4aec-8d33-6729c02a316a','BSE327','Advanced Mobile Applications Development','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','1f20f39f-cf5e-4beb-a853-771e6cc91c93',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8d245e76-ae11-45a1-a94a-1a462af131a1','BSE411','Software Quality Assurance and Testing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','784d6282-cc5f-4746-932e-c3b42793812b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b67151e9-12d0-47bf-91c9-c7c5609b2fdf','BSE412','Embedded Systems Development','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','5e6494d5-e109-452a-9703-386a1a04409c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('19eb408a-f5bd-4f40-a58b-ab5231f46c1e','BSE414','Computer Games Development','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','4b10edab-7d64-471e-976f-adbe88a3e655',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('53eaea8e-30bb-4e68-b256-1bd6c147695b','BSE417','Network Application Development','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','e28f11aa-0f8f-4ec1-9090-89f45609f9dc',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('58f16202-1ef6-4edc-af67-fa02f29d0c09','BSE422','Managing Software Engineering Projects','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1f8628a9-81d1-45fc-8de9-432b3c95a8f8','BSE426','Software Security','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','aa89cbdd-b719-4c60-a3cb-49837feea2ff',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('2085e0f8-1552-476d-932c-2d7c2b9679d7','BSE427','Professional Issues in Computing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','16fe7428-a4af-4fb3-a543-b1e0fad14ed5','cc78b85d-92b6-45e1-a869-3a26d17a1e4a',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c3b974d1-8569-4315-889c-4b29ba81e10a','BSF323','Security Analysis and Portfolio Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('16fea509-b064-455b-9f02-a794478a3029','COM111','Mathematics for Computing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','fed2c3b0-c35d-442d-a7ab-2e905c524bda',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('821ebd9b-71e4-435b-97d1-fb55f01d80ff','COM113','Computer Architecture and Organisation','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','be31f7c7-6319-44df-a6e7-216f1cabf6f8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b13988a6-6054-4d30-a7df-b459c6986c28','COM122','Principles of Programming','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','04c05b03-239c-4938-949a-9db56fdcc103',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9147b5ce-f29a-4567-a308-9f8b1b21101e','COM123','Numerical Analysis and Computation','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','45ee3159-0492-4023-9be1-fa28e9d8bf94',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('fd4cf681-4583-4450-bedf-e9e23dc8311e','COM211','Object oriented programming','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','e28f11aa-0f8f-4ec1-9090-89f45609f9dc',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('88140ddd-b7d5-488d-97ca-ec4fc8e3056b','COM212','Data Structures and Algorithms','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','fed2c3b0-c35d-442d-a7ab-2e905c524bda',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('038e9c8b-5233-484a-b5cc-60eafc58240e','COM221','Operating Systems Principles','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','04c05b03-239c-4938-949a-9db56fdcc103',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1022b4f3-4d05-4544-bfe5-9d58ea1e2be0','COM224','Software Engineering/Principles of Software Engineering','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','784d6282-cc5f-4746-932e-c3b42793812b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('751486d5-f8d8-4b8c-b72b-a23cbd7d6e6c','COM225','Embedded Systems Development','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','5e6494d5-e109-452a-9703-386a1a04409c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('7f45cf9b-f814-4cdd-a7ac-2141faedd720','COM311','Compiler Design','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','5e6494d5-e109-452a-9703-386a1a04409c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a3751c7e-811c-47b8-92ec-73ba8ee1b7bc','COM312','Artificial Intelligence and Expert Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','646fe3f0-10f2-4801-afde-5f5bd24cc73e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e7d3bb2a-64e2-461a-b4a6-6b3a4b6cffff','COM321','Simulation & Modelling - Elective','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','04c05b03-239c-4938-949a-9db56fdcc103',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a4729851-c2da-4a67-9d6d-e6f3cacc9ccb','COM322','Analysis and Design of Algorithm','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('667a0f25-40a0-44a0-9e3e-d9046b42d1b6','COM323','Computer graphics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','04c05b03-239c-4938-949a-9db56fdcc103',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a5abf76d-e773-4a34-8d00-31044cca0d2f','COM324','Machine Learning','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ab14f4ae-0ab9-425a-8a1e-82ac52a467cc','646fe3f0-10f2-4801-afde-5f5bd24cc73e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4e983b28-22be-447f-8875-f39b64a55321','DBA112','Financial Accounting','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','f747cb88-b0df-4cb2-9158-d7a61695b470',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1edaf82d-4085-432b-9d96-466b4ee7e5ab','DBA113','Communication Skills and Learning Skills for Employability','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('049c6133-b907-4dbf-a8d2-42161485a9dc','DBA115','Business Administration','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','05ab10f4-68a7-4f83-a82a-b662b3574dd7',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('5ce12865-7069-4205-a80d-0e8876bc119d','DBA116','Basic Statistics','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3bcd6816-8638-4cd0-a925-3b6bb17faa06','DBA122','Quantitative Methods for Business','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('7b960eb4-ec3a-4acc-9c37-55dfc95f154f','DBA124','Principles of Marketing','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','98bd6033-b693-4368-96a3-66a8edd4141e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('62e4010b-33a0-413d-ad61-640d3afa7ba6','DBA125','Business Law','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','40e8500b-3e15-4446-8cd9-9052435c6717',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('925a5c2e-b84c-4da7-a9fc-0ccfd6f49f22','DBA126','Stores and Inventory Management','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','4bb7f5f2-4740-4271-881b-a81771bdc8ed',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6807f80e-c7d9-4421-99c3-3e9029663b35','DBA127','Principles of Management','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1d8f964e-7f00-49e8-bc67-ad0ad8b29f9a','DBA128','Macroeconomics','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e3649617-833f-4919-a993-2cd645791320','DBA211','Managerial Accounting','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','22640f68-e8c9-43e7-bd70-59ba276acbbb',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1a5e5746-6b7d-44e9-a9ef-158f6c034460','DBA212','Information Systems Management','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','40ac889f-82c1-4014-af80-95b51cc94f3e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('36c6926e-d54d-4580-9f75-47881f50f107','DBA213','Entrepreneurship & Small Business Management','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','6bc87c82-c6e2-4553-b120-0788ea05da23',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('70c78b43-3e40-4e38-b5e5-d051e270e354','DBA215','Human Resource Management','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','91feeff5-6cd9-4527-a532-d628dd199328',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('d0afb76b-cf02-402f-9e75-5512f2cddfd3','DBA216','Procurement Management','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','4bb7f5f2-4740-4271-881b-a81771bdc8ed',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('49c736f4-0b67-450d-b3bf-995fed18796d','DBA221','Auditing I','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','7af19cce-b1f0-4770-8090-0e942721663d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4e61eaeb-636c-4540-a931-6324e2271ec3','DBA222','Financial Management','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','69d032d2-c432-4c24-8801-f59b948f2e6f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('823a905d-9aaf-49cf-b9c1-197bebb58208','DBA223','Taxation I','0d35fa69-de7f-4e05-b800-16c07321e75f','41e287d8-9ca6-412e-9a3c-ed2e389036da','7af19cce-b1f0-4770-8090-0e942721663d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0e92c673-0a2c-4189-9602-232ef90354ae','DCS111','Fundamentals of Mathematics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000005','45ee3159-0492-4023-9be1-fa28e9d8bf94',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('aeac750c-2f25-4f70-991d-2292bb2ec214','DCS112','Introduction to Operating Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000005','fed2c3b0-c35d-442d-a7ab-2e905c524bda',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('29333858-bb24-44e5-88b9-5c1b551585ef','DDA1106','Digital Electronics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000006','5e6494d5-e109-452a-9703-386a1a04409c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('7ddbd59f-cb67-44fc-a6da-83fea7979d9a','DDA1201','Numerical Analysis and Computation','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000006','45ee3159-0492-4023-9be1-fa28e9d8bf94',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1e75725b-05a8-42cb-9eb9-0cef69753e88','DDA1203','R Programming','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000006','e28f11aa-0f8f-4ec1-9090-89f45609f9dc',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('30845572-0bb7-4d60-adec-bac57a4d1e01','DDA1204','Internet Technology and Web design/Internet and Web Programming 1','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000006','5e6494d5-e109-452a-9703-386a1a04409c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('999337d7-0df2-43ad-b643-223a2c45868f','DDA1205','Data Science Essentials','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000006','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9da11f07-3a23-4705-955e-2af0b7da0b29','DDA1206','Design Thinking','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000006','1f20f39f-cf5e-4beb-a853-771e6cc91c93',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('265f9465-bfe1-440c-ba92-13b40e81456f','DDA2102','Statistical Data Analysis','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000006','d9daf77e-d52f-44e1-958a-5ba9b6811c99',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c3226cb9-2bdf-47fd-b289-9daf8bc1b524','DDA2103','Business Cloud Computing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000006','a995e09a-d0ec-4c3a-8161-e11f7e70f5e4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('fd02295d-009d-404e-a0b6-e4742c1b2218','DDA2201','Analysis and Visualization','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000006','7afc7ef4-d142-4778-9b72-29d3c9a0b6be',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ec63a410-0fe9-4351-b28e-dd2638e3f7e6','DDA2202','Data Wrangling','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000006','d9daf77e-d52f-44e1-958a-5ba9b6811c99',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('61973558-f35b-440f-9f1e-c12a90c8926c','DDA2203','Emerging Trends in Information Technology','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000006','1f20f39f-cf5e-4beb-a853-771e6cc91c93',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e878adfd-0881-40e9-91e2-cbf6c045cc1e','DDA2204','Tools for Data science and Analytics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000006','57b2fc7a-f5a8-4a0a-a558-ee8759a4981f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('18a78720-68c4-473b-a3f4-65fff2ae5256','DDA2206','Front End Development','96178a5a-1a50-43ad-ace6-045b0e7dd47a','e1b66000-0001-4000-8000-000000000006','696d8165-f8fe-451b-8041-a45dae05eb52',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('024d43fc-1fe1-4ff4-bd77-358e38de17bd','DIT110','Introduction to Information and Communication Technologies','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ac00b024-3929-4702-9a14-b216830ab328','47835404-5a90-4960-bee7-2b7cb6f9f4df',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('af246d7e-a497-4c8b-acb5-865b8ca029fc','DIT224','Introduction to Multimedia Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','ac00b024-3929-4702-9a14-b216830ab328','be31f7c7-6319-44df-a6e7-216f1cabf6f8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b144a106-c9a0-45b1-b406-da4c5effe3c5','DJC110','Communication Skills and Learning Skills for Employability','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5b8a404e-8b17-43d0-a09c-8414649481b2',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('48bc32e6-50ea-4eb8-b7fa-3224f944c923','DPS111','Introduction to law & Legal Systems','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','28d5a4bf-1d42-427a-99e2-a145882f750e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c9fc1c77-cafd-4a0e-baa5-f159ff78b195','DPS112','General Principles of Constitutional law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','b7abbad5-122a-49d9-a827-2948901f5d67',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('971e9e68-6a1b-476d-9937-4202cd8353bd','DPS113','Criminal law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','28d5a4bf-1d42-427a-99e2-a145882f750e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e221412c-0dc1-443a-85b7-7fa8b91368d6','DPS114','Contract Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','b7abbad5-122a-49d9-a827-2948901f5d67',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9fe3aa0a-57a7-4405-b2d7-3aea040a39da','DPS115','Administrative Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','b7abbad5-122a-49d9-a827-2948901f5d67',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e3313cf3-0c52-492e-aa02-66eda7645e23','DPS116','Law of Evidence','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','28d5a4bf-1d42-427a-99e2-a145882f750e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4f1f50da-2b82-4602-a366-4f5e07c0f7b9','DPS211','Health and the Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b78e5e6d-b7d5-4d9b-9c7f-8d2f02f59190','DPS212','Introduction to Human Rights','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('79ccce9e-320e-4af1-b8aa-13ee4149ffa8','DPS213','Forensic Justice and Criminology 2','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('24e0e2d2-2a76-49a6-833e-9b5e096e8bcf','DPS214','Elements of Commercial Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('86222f1e-bb6e-4b56-aadc-7758e065f0f2','DPS215','Labour law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b1cb8849-7cee-4553-8061-76a444d4e2ff','DPS216','Civil Procedure','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('bb7b4b8e-a934-477a-ac4e-6a161dd7a24d','EHS111','Human Environment','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','90049613-0de6-4fbd-a908-9f51e48e0ff6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8abe634c-d7f9-4e50-87fd-4de0169d92a4','EHS112','Principles of Epidemiology','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('2a6b06c2-41ee-45a8-9cfe-18bdec03671e','EHS113','Health Laboratory Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','def38337-4c53-49c3-b348-7612934115ad',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ce0a8adb-95a4-4175-8ced-adb9502e20c0','EHS121','Biostatistics','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c28af6df-9616-482a-ada6-a540aaab057d','EHS122','Solid and Hazardous Wastes management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','90049613-0de6-4fbd-a908-9f51e48e0ff6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4a5720b9-9bd2-484b-9302-9dc84c80ccfd','EHS124','Introduction to Hydrology and Hydraulics','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','def38337-4c53-49c3-b348-7612934115ad',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b5513036-7244-4d34-8eda-a53449e343f2','EHS125','Environmental Health Microbiology','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','179067cf-9d42-468a-bf84-56962097261f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('680f4f76-2026-4ccd-9377-59e8c64ac7f6','EHS212','Environmental Pollution','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','90049613-0de6-4fbd-a908-9f51e48e0ff6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1d129678-aa99-4643-9afc-5ba4fdaf715f','EHS213','Excreta and Waste Water Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','def38337-4c53-49c3-b348-7612934115ad',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3da8446f-81bb-4bbf-94a3-c4a777c79bae','EHS214','Principles of Demography and Population Dynamics','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('d747b152-1a8e-41a6-813c-c82db183c265','EHS215','Behavior Change Communication for Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','90049613-0de6-4fbd-a908-9f51e48e0ff6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4751190d-351b-4583-abbc-960fdc6f1da1','EHS216','Vector and Vermin control','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('67b230e3-9b79-4896-bda3-193e5b8ce5c5','EHS221','Safe Water Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','def38337-4c53-49c3-b348-7612934115ad',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('47cbcab3-69d6-4961-ba49-eea433a827a6','EHS222','Town and Country Planning','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','179067cf-9d42-468a-bf84-56962097261f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('496e6712-d4e9-4a10-889f-3460e7439afb','EHS223','Occupational Health and Safety','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','def38337-4c53-49c3-b348-7612934115ad',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6acc3316-b1cb-4101-9b7a-99b28bf6c13d','EHS224','Building Technology I','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','179067cf-9d42-468a-bf84-56962097261f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a44ba2d0-5c0a-4552-8fc4-7e110610d9eb','EHS225','Food Hygiene and Food Safety','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','179067cf-9d42-468a-bf84-56962097261f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b54a64f2-540a-46de-aa72-4a17c6be9970','EHS312','Environmental and Public Health Law','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8329a4e9-d429-4b62-8fd5-d6813433f64e','EHS313','Health Monitoring and Evaluation','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4b010fc1-fc23-4248-90a4-fa23a4894f52','EHS314','Building Technology II','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','179067cf-9d42-468a-bf84-56962097261f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('eae6b0ba-c034-477e-ba1e-8d8feb1c2e1d','EHS315','Environmental Impact Assessment-Elective','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','328e043e-56f9-4311-8172-1b4df729f145',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('fb480f20-3016-40b1-a778-4cadefe70913','EHS316','Global health-Elective','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','90049613-0de6-4fbd-a908-9f51e48e0ff6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1665c603-33b0-4b73-9512-098d0edb9fe8','EHS321','Natural and Alternative Medicine','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ef12be2b-b363-4ac4-ad26-1178e4122a96','EHS322','Health Policy Planning and Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b9619451-043a-4978-8e17-020e898f24ae','EHS323','Institutional Health Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa','def38337-4c53-49c3-b348-7612934115ad',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e23dab6f-c8ac-4afc-bbd2-3dd896cd7f10','ENT312','Electronic Business','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','523e3bd4-989a-422d-ab05-247a7579796a',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ba19ee41-b1e0-44dd-bf79-a640ed35c4c5','FOA120','Foundation in Law -Elective','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','aaa04952-174f-451d-8b1a-6635b4831b00',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('bd100383-0bca-407f-81de-1715d119816b','FOA121','Principles of Accounting -Elective','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','7af19cce-b1f0-4770-8090-0e942721663d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('95d77c40-7e1c-4e3d-867b-ee3be7e77402','FOA122','Introduction to Critical thinking','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','6f576a3a-a80d-4ff6-a436-6726f48eac77',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4ba27059-885c-4889-b1b5-8bc910ab055f','FOA123','Business Administration -Elective','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','4bb7f5f2-4740-4271-881b-a81771bdc8ed',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c8af87ae-723a-4e9c-af3a-0144403efec3','FOA124','Introduction to Political Science and Classical Thought','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','3e85330a-5024-4b3a-8746-7e8fa4cbf75c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cbe26ac1-3ea8-493f-acbb-5aef02b1e365','FOS111','Foundation Physical and Inorganic Chemistry','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','3efe4d57-67b6-40dd-88ab-c3805ef97e4d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0f25c3ff-8cd3-499a-b096-c26f9e142de1','FOS112','Foundation Physics I','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','45ee3159-0492-4023-9be1-fa28e9d8bf94',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('10abc891-80fa-440f-abd4-890bf364f6e3','FOS125','Foundation Statistics','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('2a650dd3-7e61-4df7-ad14-acb9e5cab2df','FOS126','Foundation Physics II','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','45ee3159-0492-4023-9be1-fa28e9d8bf94',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('69ce4f4d-8da0-4ca3-bcfd-60bbb6d80c7c','FOS127','Foundation Organic and Analytic Chemistry','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','3efe4d57-67b6-40dd-88ab-c3805ef97e4d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('17244018-33e5-4b92-8c64-a748b26745fc','FOU110','Foundational Mathematics - Group 1','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','45ee3159-0492-4023-9be1-fa28e9d8bf94',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('52f38b4f-2b94-4e74-9db7-b9b8e3674d67','FOU112','Communication and Study Skills','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('d083db80-0945-41f1-a882-6c91cee29ced','FOU113','Introduction to development studies','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','f963764d-3be5-4944-987f-de6b0872d7d8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c430c85e-1ad6-4b25-82c1-6e85e7682825','FOU114','English','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b2fea44f-6e31-44a1-a1f2-be018bbc5208','HEC111','Computing and Study Skills','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','a995e09a-d0ec-4c3a-8161-e11f7e70f5e4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('993dd58b-024e-490c-8e11-71e494436fe5','HEC112','Foundation Biology I','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','fa4b7144-17a6-4791-9ca5-25b78f629c18',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('966d96ac-7a8c-4ff9-a334-b8a69961147c','HEC113','Reading and writing skills for beginners','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','2e467318-632f-4dde-91ac-495d504e0aca',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('096c8b90-9456-4648-a8db-248706aa6739','HEC115','Introduction to Animal Physiology','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','fa4b7144-17a6-4791-9ca5-25b78f629c18',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6dac8ed7-f8f2-4f52-9308-ed34b5b5acf4','HEC122','Ethical Practice and Professionalism','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a3409096-f90d-43ac-af8b-4776d16ae3c6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8f90f3e0-d786-41ce-87fd-0e0343c878d2','HEC123','Foundation Biology II','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','fa4b7144-17a6-4791-9ca5-25b78f629c18',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('988e1ecf-c329-43da-b499-2cd9373efdd2','HEC124','Introduction to Plant Physiology','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','fa4b7144-17a6-4791-9ca5-25b78f629c18',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6c495d17-0f90-4b39-b531-25af4502822d','HEC125','Basic Entrepreneurial skills-Elective','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','de345d62-f4a2-4f20-9804-c4b0c9f882ef',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('de452cdd-7c2e-4b8f-89ca-e54bfa3cf265','HEC126','Introduction to Physical Chemistry','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','3efe4d57-67b6-40dd-88ab-c3805ef97e4d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('eda41e8b-b408-4c52-91ed-7c60b0b0d713','HEC128','Life Skills Education','96178a5a-1a50-43ad-ace6-045b0e7dd47a','73593c0f-0478-45b5-a87d-a8e87f5ea274','47ca1e41-120b-49a2-ab3d-fe3cad7ea20c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('01ea4c1b-7eb8-4348-805e-0016e104142f','HRM311','Human Resource Information System','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','cbdf9c6c-b096-45a9-92b0-12dd4a5ded62',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9038d7a5-8d01-453a-8e85-b1aae975adaa','HRM312','Benefits and Compensation','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','cbdf9c6c-b096-45a9-92b0-12dd4a5ded62',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e30f0a96-4059-46cb-aff5-5fdbe5706a23','HRM313','Organisational Environment Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','de615d4f-d8c4-4dc7-bff0-389508668cd5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('212a07ad-b409-484a-9e69-00c63344e524','HRM314','Human Resource Policy and Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','91feeff5-6cd9-4527-a532-d628dd199328',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('28f9e86c-2e89-491e-8fcd-26d67566247b','HRM315','Human Resource Training and Development','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ba8005d5-05a2-4b58-97e8-ff60a2ac5965','HRM316','Organisational Leadership','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','6bc87c82-c6e2-4553-b120-0788ea05da23',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9138f699-ffa1-410d-86fb-5570d2b7313e','HRM321','Career Planning and Counselling','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','91feeff5-6cd9-4527-a532-d628dd199328',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b0cd389d-09d4-495e-940f-5d5280638334','HRM322','Occupational Health and Safety','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','0981d0e1-d1a1-443b-ae3d-8be8799e71d0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('afa86d67-9414-4fba-922e-7b57d18134a0','HRM323','Strategic Human Resource Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','91feeff5-6cd9-4527-a532-d628dd199328',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('517de1d3-690c-4339-88cc-ba83afaf674e','HRM325','Organizational Psychology','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','de615d4f-d8c4-4dc7-bff0-389508668cd5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('16043f92-975c-4989-91f4-5f8aecacb00a','IRDS111','Introduction to International Relations','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('dceba44a-d7c8-4e29-a9c3-1cfe129a1956','IRDS112','Introduction to Diplomacy','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','6f576a3a-a80d-4ff6-a436-6726f48eac77',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9f8bb3b1-1cb9-4342-b0a1-4f2eac9da83e','IRDS114','Protocol and Etiquette','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('808ab5c4-2587-4d5f-906c-6ba87fb58279','IRDS121','Introduction to Political Science and Classical Thought','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','3e85330a-5024-4b3a-8746-7e8fa4cbf75c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('bc149569-703e-4668-a46a-a6d422c40f6c','IRDS122','Government and Politics in Africa','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','622f90d0-0a3b-4ffc-b5b1-8e60d990a39b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cb6c9125-667d-4935-9869-1d86790ef69b','IRDS124','International Law','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5b690ac2-1b30-42d6-add3-8078738a8f83',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('00c25a6a-21cc-4575-8f6f-2bd50aad01ca','IRDS125','International Political Economy','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','ac5d7730-aeb7-4e60-9f78-b11d744e43da',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ef206281-9740-401b-9e37-dca6d6133902','IRDS128','The United Nations Systems','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','6f576a3a-a80d-4ff6-a436-6726f48eac77',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0cf51d2d-a94d-4671-b4be-64fd5549f7f8','IRDS129','Terrorism and Related Global Issues','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5b690ac2-1b30-42d6-add3-8078738a8f83',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a6170aeb-edee-4664-be00-89b0536b2b43','IRDS211','Africa and International Relations','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','53167307-9a23-4931-bcd9-d7d3bd234bbb',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8bc5ecc8-0d8a-46f1-884d-c9c5777ae040','IRDS213','Public Administration and Management','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','13019d4a-21de-4616-aee5-76ad71492938',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3cfa415e-92ee-4669-8b39-0cb2cc3cbbdc','IRDS214','Gender in Public Administration and Management','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','622f90d0-0a3b-4ffc-b5b1-8e60d990a39b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a75fda91-81cf-4d3c-8fc9-c598abae9caa','IRDS215','Regional Integration and Globalization','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('bb94b579-047b-4d0e-97d7-096db869fbbc','IRDS216','International Investment, Trade and Business Management','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e9bb7e9d-48bd-40e0-801d-7be9e7c22ff8','IRDS217','Religion, Conflict and Peace Studies','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','d0c037f9-c6ab-4457-ad78-d016954df586',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('12e84bd6-6169-4d5b-b488-81fe23e58efb','IRDS222','Foreign Policy Analysis','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a3409096-f90d-43ac-af8b-4776d16ae3c6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('2d32a61f-e3de-4883-aa15-c47578327231','IRDS223','Comparative Political Systems','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','622f90d0-0a3b-4ffc-b5b1-8e60d990a39b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ba7af52f-2998-48fc-b3ca-fb005b8afb6e','IRDS224','International Politics of the Environment','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('eeb1c557-f878-4a53-92d5-b0d54c3cf954','IRDS225','Conflict Resolution, Management and Transformation','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','622f90d0-0a3b-4ffc-b5b1-8e60d990a39b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('7a5b04b8-8e43-4a67-8a45-fc86c27c8f33','IRDS227','Advanced Theory of Diplomacy','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('dba7a8f2-1400-4ca7-804f-93f205ef48da','IRDS311','Security Studies','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','6f576a3a-a80d-4ff6-a436-6726f48eac77',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('7760c7ec-656c-409e-a774-7558497fb35f','IRDS312','Displaced Person and Forced Migration studies','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','d0c037f9-c6ab-4457-ad78-d016954df586',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('79293d4b-5579-4549-9c96-6b8d457de615','IRDS313','International Justice Mechanisms and International Criminal Justice','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','ac5d7730-aeb7-4e60-9f78-b11d744e43da',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e6b9fe7a-01e4-4caa-b947-ce13871243db','IRDS314','International Politics, Media and Conflict','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a3409096-f90d-43ac-af8b-4776d16ae3c6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('268de938-063c-4528-958a-b5aec8830fbd','IRDS315','International Development','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','3e85330a-5024-4b3a-8746-7e8fa4cbf75c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9c246dc6-1774-417d-b3b8-08cbad1f2999','IRDS316','Global Geopolitical Analysis','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','ac5d7730-aeb7-4e60-9f78-b11d744e43da',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ae80522a-c880-45fb-81b7-4ee5c759e92f','IRDS317','Civil Military Relations','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','53167307-9a23-4931-bcd9-d7d3bd234bbb',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c1b93e8f-4c20-4d01-ab63-904498e3f19e','IRDS321','Ethics in international relations','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','47ca1e41-120b-49a2-ab3d-fe3cad7ea20c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ac6b6da8-e899-41a5-8a60-10c0db6fb52c','IRDS322','Africa and Contemporary International Security','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','f963764d-3be5-4944-987f-de6b0872d7d8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1e0b5aaa-a704-4e43-9032-24b1b79a16b9','IRDS323','Strategic Intelligence, Modern Warfare and Human Rights','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('38651289-a722-4993-8ef9-f8abde14bba4','IRDS324','Cyber Security and International Security','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','f963764d-3be5-4944-987f-de6b0872d7d8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('39b5d93a-8b0c-49f9-b802-5bbf87dffdc8','IRDS325','International Public Relations and Strategic Communication','422a6c15-127f-47d5-a044-e7547d35dcb6','33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a3409096-f90d-43ac-af8b-4776d16ae3c6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('61abdf71-df0f-421e-9a07-4c8e18ab5e16','LLB111','Introducing Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','ec59df84-8249-4043-8a87-b1b85354c8a4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1fa2459d-4916-42c6-a645-8ab32d0485ed','LLB112','Constitutional History','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','716d1f74-b603-4f0f-ac42-f1b67c5efe66',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3275fe6d-e620-4423-9e2d-22fa3f6860cd','LLB113','Criminal Law I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','aaa04952-174f-451d-8b1a-6635b4831b00',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3d32a70a-c2fa-45e3-9069-e6a6fbb5e607','LLB114','Law of Contract I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','57518cc9-c8aa-44ab-8908-2d066176afe0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ea7ae678-37ab-4786-8b07-ef512e7f8c13','LLB115','Law & Development','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','62f8ae87-777b-4b50-aab2-6a93b6880241',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cae5e46c-9e3d-4a30-84ef-6c56c812d165','LLB121','Legal Methods','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','ec59df84-8249-4043-8a87-b1b85354c8a4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('64707973-267a-443f-bc20-df24c6a6b39f','LLB122','Constitutional Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','1072fa4c-0760-40fb-b131-9befeea849a3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9ecb548a-4910-4b5f-89c8-d2147caf41bc','LLB123','Criminal Law II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','e47b172f-4104-411a-85f6-b4e0c209d8be',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8257092f-51a8-4563-a792-79768d34e223','LLB124','Law of Contract II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','aa0e0cca-d56a-4111-8e69-d3394e6f8d6d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a2068ccc-9ce5-47a6-82fe-b4856161dc57','LLB125','Nature & History of Torts','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','d476996b-03c6-4c57-88b6-cc6953925903',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('af3bb4f0-b94d-46dc-b262-73d5f77d6c3b','LLB211','Family Law I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','28d5a4bf-1d42-427a-99e2-a145882f750e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a487691b-5a49-41aa-90d1-d2ddb51b7e5d','LLB212','Land Law I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','4156e748-16a1-4737-9a86-d24dd0ddcbd5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('5b09cfe3-1ace-41f0-85de-2039c3563c92','LLB213','Evidence Law I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','d476996b-03c6-4c57-88b6-cc6953925903',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('414ab6ef-9d50-4dd5-b8c8-190c807c69fe','LLB214','Negligence & Strict Liability','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','d476996b-03c6-4c57-88b6-cc6953925903',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e9aedaa3-fd9c-46b2-8e8f-9dd9578a829d','LLB215','Equity and Trusts','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','80aabbc7-ba9a-4b15-96b7-ba4e87de6140',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6c7d882d-e3d4-4097-83f3-d24a62099d8d','LLB221','Family Law II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','0cdb4518-8623-497f-966b-c28043ace08f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e09d347b-4220-4767-aba5-26dcfbb321c6','LLB222','Land Law II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','aa0e0cca-d56a-4111-8e69-d3394e6f8d6d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9a34a464-a2df-42ca-867f-7932c80815ec','LLB223','Evidence Law II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','e47b172f-4104-411a-85f6-b4e0c209d8be',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('12552102-efac-4b5c-8926-43ec9eb4b2c6','LLB224','Administrative Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','b7abbad5-122a-49d9-a827-2948901f5d67',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0e54e570-f456-4c83-a38c-5d912e5d6514','LLB225','Social Research','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8bda7971-3d58-4450-a040-ba14d98bbaba','LLB311','Criminal Procedure','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','e47b172f-4104-411a-85f6-b4e0c209d8be',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e4b24c56-3458-42ce-a7b4-1399f6d37ce5','LLB312','Business Associations I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','0cdb4518-8623-497f-966b-c28043ace08f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('bea43b33-e57f-4dd1-97e8-f27d78eccca1','LLB313','Jurisprudence I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','81ca4b30-14ad-48b6-8e5a-0049fc1b7b3c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c799023f-8666-4255-83e9-23c4ffc6a923','LLB314','Sale of Goods','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','0cdb4518-8623-497f-966b-c28043ace08f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a0b8ed0f-92a1-408a-9c49-b300f3fa6a84','LLB315','Law of Banking','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','1072fa4c-0760-40fb-b131-9befeea849a3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b2982dba-5042-4519-994a-7e2eb802e69d','LLB322','Jurisprudence II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','716d1f74-b603-4f0f-ac42-f1b67c5efe66',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('51068da9-2f5f-4000-ba70-7547e4495001','LLB323','Business Associations II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','b7abbad5-122a-49d9-a827-2948901f5d67',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0f24f2fc-9300-48d9-8c1c-6232fdb1ec39','LLB324','Alternative Dispute Resolution','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','93834083-3e91-4f8f-8cb5-f69789a0c1a0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a3c6d340-8197-412b-9c65-88aa0a8feb3f','LLB325','Computers and the Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','ec59df84-8249-4043-8a87-b1b85354c8a4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a4af52d2-93c8-4151-a15f-34cedc7750d3','LLB327','Insurance Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','aa0e0cca-d56a-4111-8e69-d3394e6f8d6d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3687d0bf-4fbf-4a97-a424-e932e2a11192','LLB411','Civil Procedure I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','81ca4b30-14ad-48b6-8e5a-0049fc1b7b3c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ed2e14d8-fdb0-4b88-adf9-1f1bbd30b8bd','LLB412','Revenue and Taxation Law I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','4156e748-16a1-4737-9a86-d24dd0ddcbd5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('7326cd33-0b88-424b-9216-1e3ec5735db3','LLB413','International Law I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','62f8ae87-777b-4b50-aab2-6a93b6880241',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('fcc0e869-9165-48e0-b99e-32c47d501b66','LLB414','Labour Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','93834083-3e91-4f8f-8cb5-f69789a0c1a0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1728da09-94af-4d96-8e95-fd8e87ccfe1c','LLB416','Intellectual Property Law I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','aaa04952-174f-451d-8b1a-6635b4831b00',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b5c662ba-96cb-4c92-be8c-e2aa93ee1868','LLB421','Civil Procedure II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','4156e748-16a1-4737-9a86-d24dd0ddcbd5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('fb3736e4-cf5e-421b-88e9-025260a90873','LLB422','Revenue Law and Taxation II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','a69fa820-b3f8-4fe4-902a-0d82e50c36d6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1966d7cf-b16e-4598-9d45-b44b7128c0fd','LLB424','International Law II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','62f8ae87-777b-4b50-aab2-6a93b6880241',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('044d711a-1fef-461c-ab85-e6497ce7bb64','LLB426','Intellectual Property Law II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000001','1072fa4c-0760-40fb-b131-9befeea849a3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('40839681-2e5c-48aa-be36-c5780c74df6b','LLM711','Jurisprudence and Legal Theory','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','81ca4b30-14ad-48b6-8e5a-0049fc1b7b3c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3b4b8974-74df-4a8f-bb2e-e885498e1ac5','LLM712','Oil and Gas Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','e269d819-125d-4336-8290-1d20a61ffe02',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e0d98897-8d6e-4ad4-b02b-2a3bd39368ce','LLM713','Corporate Governance','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','57518cc9-c8aa-44ab-8908-2d066176afe0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1b0a491b-0f62-4725-87b4-c54190dedd77','LLM714','International Criminal Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','e269d819-125d-4336-8290-1d20a61ffe02',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('431477d4-239a-44bb-a44f-395341ce5088','LLM715','International & Regional Child Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','2f7e03e2-0dd0-4c32-b02d-398a62cb055b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('94e188f4-e8f7-43ea-b0c8-c7848ec05221','LLM716','Intellectual Property Law I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','a69fa820-b3f8-4fe4-902a-0d82e50c36d6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cca518ec-c5fb-44db-a339-b579dcd6c294','LLM717','Forensic Justice and Criminology I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('f3b08eda-f606-4429-b36e-6a71598697bc','LLM718','Public International Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','5b690ac2-1b30-42d6-add3-8078738a8f83',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e56b2f97-5936-4421-8ea9-e0c367b46cfc','LLM719','Human rights in Domestic perspective','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','80aabbc7-ba9a-4b15-96b7-ba4e87de6140',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4fd890ec-5943-48db-bbc7-655decddfb44','LLM721','Governance and Anti-Corruption I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','716d1f74-b603-4f0f-ac42-f1b67c5efe66',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9ed591db-56bd-4d3a-a133-20cab37c0925','LLM7210','Forced migration and refugee law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','2f7e03e2-0dd0-4c32-b02d-398a62cb055b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e6356f11-da77-4309-be95-bb7ae7c1ad36','LLM7211','International Law of Banking and Financial Institutions','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3663dd7a-d898-41c3-8a10-2a74ecc006a8','LLM722','Natural Resources I','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','e269d819-125d-4336-8290-1d20a61ffe02',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a0d5752b-9db3-4cc8-94c4-d7d3e8177772','LLM725','World Trade Organisation & Regional Integration Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','d2d34e55-ed3a-442d-bd05-93761827f693',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('bd40b815-e409-4e13-8666-9d9d65850527','LLM726','Intellectual Property II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','a69fa820-b3f8-4fe4-902a-0d82e50c36d6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('43ef463a-721d-46ef-8df0-596bb69f73b8','LLM727','Forensic Justice and Criminology II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('01534f49-f15b-46ef-a4fe-74c0f042329b','LLM729','International Tax Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','a69fa820-b3f8-4fe4-902a-0d82e50c36d6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0360d415-9861-4e92-9535-1c885e0a2914','LLM811','Research Methodology I (Compulsory)','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('24003559-ed06-427b-b142-c6bbe273d7a5','LLM812','Governance and Anti-Corruption II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','d2d34e55-ed3a-442d-bd05-93761827f693',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('d7ce9fdf-4173-4c90-9574-9e9984b65cfc','LLM813','Alternative Dispute Resolution','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','93834083-3e91-4f8f-8cb5-f69789a0c1a0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6cd380c1-e162-4251-b8da-466bd8672032','LLM814','International and Regional Human Rights Law','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','2f7e03e2-0dd0-4c32-b02d-398a62cb055b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('11402fe4-bcab-4873-a3e8-9da659f1c35b','LLM817','International Commercial Transactions','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','d2d34e55-ed3a-442d-bd05-93761827f693',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3f559888-d513-4c7f-adff-0698f0bfdd4b','LLM818','Natural Resources II','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','e1b66000-0001-4000-8000-000000000002','e269d819-125d-4336-8290-1d20a61ffe02',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('eea00073-4fad-4d61-bc03-985d3f96b0b2','MBA710','Management Theory and Practice','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','6c3d9c6d-80a2-449a-ab8e-571f31d7691a',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('33d1a277-f5ac-4471-ab0d-262dd1bd184c','MBA711','Finance for Managers,Strategic Financial Management','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','22640f68-e8c9-43e7-bd70-59ba276acbbb',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('12d6861e-66fc-42c6-977b-91555c06c00f','MBA712','Marketing Management','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','98bd6033-b693-4368-96a3-66a8edd4141e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('945518f4-ffde-4d58-a4aa-88a86d08856f','MBA716','Managing Operations and Projects','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cd45312c-f4fb-43bf-8ac1-88f00a2971f3','MBA721','Strategic Management','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','6c3d9c6d-80a2-449a-ab8e-571f31d7691a',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4d2e0b7a-1fef-4aa3-8305-2bc826434c5b','MBA724','Managing Change in Organisations','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0981d0e1-d1a1-443b-ae3d-8be8799e71d0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ef5470c8-be33-4bfd-8ffa-78476fa10f75','MBA725','Economics for Managers','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','f32de772-b345-4c97-ad24-ac5c40cac152',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('93d251ca-bfc6-4232-8a70-fcc4418f5b56','MBA726','Financial Accounting','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','05ab10f4-68a7-4f83-a82a-b662b3574dd7',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('74161cc7-026f-482a-9feb-86e6ff0027a7','MBA727','Human Resource Management in Education','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('fc47a970-be06-4ab1-81ee-d63311c9fc4e','MBA728','Scholarly Writing and Publication Skills','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0b6273ef-d8fa-4b4b-b6b0-4a932aeb3b4f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('646d82cb-4911-40c0-b813-120a220c9fce','MBA729','Computer Applications in Research','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','40580b57-e389-475e-a791-5d8d5e51b1e8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e0869160-07ef-4bd2-b2ea-092d2729be4e','MBA811','Business Decision Techniques','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','f32de772-b345-4c97-ad24-ac5c40cac152',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1f3e600d-47f5-4048-9b74-c37ad46258f0','MBA813','Business Ethics and Corporate Governance','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','6bc87c82-c6e2-4553-b120-0788ea05da23',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ab0a0866-8fe9-4618-9b4f-22f784f8467c','MBA815','Organisational Leadership','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0f4a1369-cfa8-4246-a139-cc3bf1b79e02',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3c78a017-2085-4abd-9c67-e3738b816e1e','MBF811','Taxation Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','3be662be-54eb-46b4-aa44-2b3ea30b52ce',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('721ef0c8-1bd0-41f2-b186-6780ad66b892','MBF813','Management Accounting','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','3be662be-54eb-46b4-aa44-2b3ea30b52ce',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ce3ee9ed-93c4-4b80-ae88-cb56aef7cce3','MBF815','Corporate Finance and Financial Markets','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','0fd2a1d2-9b26-472c-bd86-5051a9fc8436',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('96c48382-4d7c-4ff0-aad3-0717b2559a91','MBF816','Advanced Accounting and Financial Reporting','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','05ab10f4-68a7-4f83-a82a-b662b3574dd7',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c438298b-022e-439d-8fa5-1824e0e9b4fe','MBF817','Auditing and Assurance','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','0fd2a1d2-9b26-472c-bd86-5051a9fc8436',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('585847fd-396f-47dc-8eae-56e9a44d55e8','MED713','Cost Analysis and Financial Resource Management','422a6c15-127f-47d5-a044-e7547d35dcb6','e1b66000-0001-4000-8000-000000000004','d2242310-57c2-484c-9f75-5888c5aaa883',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('dea01145-ec0a-44c2-afb9-dbe443f44689','MED714','Economics of Education','422a6c15-127f-47d5-a044-e7547d35dcb6','e1b66000-0001-4000-8000-000000000004','1d26ebc3-1c74-43fb-9261-3514e85c8747',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('59cd25c5-db41-44d2-b73f-49d5a5fcdc3c','MED721','Legal Aspects in Education Management','422a6c15-127f-47d5-a044-e7547d35dcb6','e1b66000-0001-4000-8000-000000000004','0f4a1369-cfa8-4246-a139-cc3bf1b79e02',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c711664a-45aa-48d8-b7e2-9f5e954bb738','MED722','Ethics in Higher Education','422a6c15-127f-47d5-a044-e7547d35dcb6','e1b66000-0001-4000-8000-000000000004','d2242310-57c2-484c-9f75-5888c5aaa883',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('237e7ca4-99dc-4319-a55d-2b8b24c0bf9d','MED723','Educational Planning and Administration','422a6c15-127f-47d5-a044-e7547d35dcb6','e1b66000-0001-4000-8000-000000000004','622f90d0-0a3b-4ffc-b5b1-8e60d990a39b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('d040f645-55e7-4989-bde0-5e7e66c3f418','MED812','Educational Policy Making and Analysis','422a6c15-127f-47d5-a044-e7547d35dcb6','e1b66000-0001-4000-8000-000000000004','d2242310-57c2-484c-9f75-5888c5aaa883',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b8d2cb88-8a01-4c6c-9600-738778c5ccbe','MED813','School Supervision and Inspection','422a6c15-127f-47d5-a044-e7547d35dcb6','e1b66000-0001-4000-8000-000000000004','0f4a1369-cfa8-4246-a139-cc3bf1b79e02',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('800c13d4-1be2-45ed-b68e-b2f41cf03d32','MHR722','Organisational Behaviour','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b7cb7473-7824-4d28-a9ac-8050f47f9515','MHR811','Organisational Development','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','de615d4f-d8c4-4dc7-bff0-389508668cd5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0e7a1f6c-4c19-48a6-96b9-c3301bc462d0','MHR814','Human Resource Information Systems','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','cbdf9c6c-b096-45a9-92b0-12dd4a5ded62',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('565aae9a-b39a-439b-8d72-6bb50a235ead','MHR815','Industrial Relations and Labor Law','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','0981d0e1-d1a1-443b-ae3d-8be8799e71d0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a4aff06f-41bb-48b5-826b-59126bbe03e1','MIR711','Theories of International Relations','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','90c1c369-8855-4032-8b61-46f7da81b8f1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('59f6c14f-561b-408c-ae17-3129b7b8dc6b','MIR712','International Law','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','5b690ac2-1b30-42d6-add3-8078738a8f83',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0ffe3e35-3fbc-4deb-8676-f2aef86db0a8','MIR714','International Humanitarian Law','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cf8ac63d-dd03-44ae-b92c-af3315a296b6','MIR715','Democracy and Human Rights','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a3409096-f90d-43ac-af8b-4776d16ae3c6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('61105d58-c88e-462c-a2af-40c7af609450','MIR721','Africa in International Relations','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','53167307-9a23-4931-bcd9-d7d3bd234bbb',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6a573513-79d5-4934-abe7-cfd4c0e16483','MIR722','Foreign Policy Analysis','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','a3409096-f90d-43ac-af8b-4776d16ae3c6',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('f93f9357-abc5-4972-b560-3f7aa0dc5006','MIR723','International Organisations','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','3e85330a-5024-4b3a-8746-7e8fa4cbf75c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('641e8416-9b8e-4120-ac8d-96eb8693460e','MIR724','International Political Economy','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','f963764d-3be5-4944-987f-de6b0872d7d8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b695a27c-c497-4ef6-ae9d-4ab9256d4218','MIR811','International Politics of the Environment and National security','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','747d4ce8-8206-437a-ae42-9a84186617b8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9d18c9b0-ec07-4bfa-b4a4-a87d2b46e3ed','MIR812','The Politics of Intervention','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','d0c037f9-c6ab-4457-ad78-d016954df586',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('96d1c2fb-70a7-49b8-8a04-12616d5a50fe','MIR814','Theory and Practice of Modern Diplomacy','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6efcdd76-4617-4f87-9ec9-b9a46486f63c','MIT712','Management Information System','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','a995e09a-d0ec-4c3a-8161-e11f7e70f5e4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('aa6fe1ed-144a-4bab-830c-47d4fef51d3b','MIT715','E-Governance','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','a995e09a-d0ec-4c3a-8161-e11f7e70f5e4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ea12132d-2e67-42f8-af6d-240750ea0dbf','MIT716','ICT for Development & Innovation','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','be31f7c7-6319-44df-a6e7-216f1cabf6f8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('669f8e46-8c94-455a-bdb4-c4ed78617007','MIT717','Requirement Engineering','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','784d6282-cc5f-4746-932e-c3b42793812b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9e76a49a-ccd0-46e9-8cca-55cd8e53b9d7','MIT718','Legal and Ethical aspects of Computing','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','cc78b85d-92b6-45e1-a869-3a26d17a1e4a',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b0e6168f-58d3-4d1e-9f8e-9d482580c223','MIT721','Computer Networks & Telecommunications','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','e28f11aa-0f8f-4ec1-9090-89f45609f9dc',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('5acb0c7c-7f91-414c-aec6-a0a609786609','MIT722','Advanced Database Systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','04c05b03-239c-4938-949a-9db56fdcc103',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8c4d8d0a-c0bd-4dd1-9cf6-7ffd61fe4f65','MIT723','Web Application Engineering','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','e28f11aa-0f8f-4ec1-9090-89f45609f9dc',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('827b485a-588f-4602-a89d-56c9d89ffe91','MIT725','Data Warehousing and Data Mining','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','04c05b03-239c-4938-949a-9db56fdcc103',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('f168d66e-89b4-4989-b207-5d3194245334','MIT727','Information Technology Project Management','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','cc78b85d-92b6-45e1-a869-3a26d17a1e4a',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('057d2b1b-1dac-42a5-9a6d-b2b86a3220c5','MIT728','Data Analytics and Visualization','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','646fe3f0-10f2-4801-afde-5f5bd24cc73e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('65c78ad4-9362-451a-b0ac-4dba76452f55','MIT729','Research Methods in Information Technology','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','40580b57-e389-475e-a791-5d8d5e51b1e8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c544ae85-7658-4393-b569-7def0749e35b','MIT821','Systems Analysis and Design','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','784d6282-cc5f-4746-932e-c3b42793812b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b585da96-8df3-4438-9e31-8a22ebd5d7f0','MIT822','Security of Information systems','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','aa89cbdd-b719-4c60-a3cb-49837feea2ff',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('80689a21-7b25-492f-a516-9abb9f436ede','MIT823','Artificial Intelligence & Intelligent system','96178a5a-1a50-43ad-ace6-045b0e7dd47a','406f66f5-ea30-4071-9d85-d6029d0fcb05','646fe3f0-10f2-4801-afde-5f5bd24cc73e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ca479583-f899-46bb-9a49-ed9fe6e48806','MKT311','Consumer Behaviour','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','98bd6033-b693-4368-96a3-66a8edd4141e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8c3c3e08-e7b4-47fe-aaec-fce7b1a27749','MKT312','Service Marketing','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','40e8500b-3e15-4446-8cd9-9052435c6717',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('afc690f6-f7eb-43a9-a07d-b091bcd63240','MKT313','Marketing Research & Planning','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','541b518a-6462-4693-b7f5-9d0be6e6551d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('de3c1278-d8c4-4c92-8870-48a723c1aec9','MKT322','Industrial Marketing','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','4d0005ed-880d-4761-af9b-00ad3460637d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ce2b2420-c14e-4189-93aa-7b4886f4a5f1','MKT323','Digital Marketing','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','40e8500b-3e15-4446-8cd9-9052435c6717',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b6de43e7-d2b7-4a94-b551-147081df460f','MKT325','New Product and Services Development','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','4d0005ed-880d-4761-af9b-00ad3460637d',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('eb290684-c29d-4326-a25c-02f5ea0c5828','MKT722','New Product Development and Service Marketing','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','0981d0e1-d1a1-443b-ae3d-8be8799e71d0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('07b160e2-4938-40a6-b206-9c5899869d88','MKT723','Marketing Research','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','c0f3071f-f74b-41d7-a3c3-01b39cfbbd46',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('5cc632b7-5bcc-4640-86a6-be4c36be4075','MKT810','Strategic Marketing','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','98bd6033-b693-4368-96a3-66a8edd4141e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cbaf0fba-2526-43cb-9fc0-2ce55326aec4','MKT812','Global Marketing','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','98bd6033-b693-4368-96a3-66a8edd4141e',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4213e5c7-3308-4c11-8605-2c74ee6a68b2','MKT814','Brand Marketing and Communication Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','0981d0e1-d1a1-443b-ae3d-8be8799e71d0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('65603116-3712-4d5d-a6ea-f936aabe1e75','MPH713','Biostatistics','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','4ecccefa-3928-4186-81de-b60c80998d77',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1906f9a3-2601-436d-bc66-36260477128d','MPH714','Epidemiology','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','4ecccefa-3928-4186-81de-b60c80998d77',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('42528875-10d1-44dc-87d6-4356e4ae3b8c','MPH715','Fundamentals of Public Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','0ded251d-080e-4fe3-b787-1be53043b83b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('40367f0c-b7ad-4da4-94cd-749d40b47142','MPH716','Demography and Population Dynamics','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0d422dc4-f308-40ff-aec8-334ba3443037','MPH721','Infectious and Non-infectious Diseases Control','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','99d7e1aa-c930-49a2-9d97-45fc68a03711',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c6a844ee-fd50-4431-81aa-e157102ab7d4','MPH722','Environmental and Occupational Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','99d7e1aa-c930-49a2-9d97-45fc68a03711',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('f0190fab-5c22-48c3-86be-a6b1fdc16a31','MPH724','Scientific Writing','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','4ecccefa-3928-4186-81de-b60c80998d77',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('76f4dd16-0d34-44dd-8ebe-3aac4719c6ee','MPH725','Family and Reproductive Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','0ded251d-080e-4fe3-b787-1be53043b83b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('83cbeb8d-5eb9-414b-865e-614e670cc519','MPH726','Health Promotion','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','4ecccefa-3928-4186-81de-b60c80998d77',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a2642d38-37fe-480e-9edc-39f9ad639b07','MPH727','Monitoring and Evaluation for Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cd1f8a34-fa37-4568-b89b-d08b8fe8441b','MPH810','Health services management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','179067cf-9d42-468a-bf84-56962097261f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('557a5294-335b-40f2-a582-bcf30b6ae10c','MPH812','Health Research Methodology','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','4ecccefa-3928-4186-81de-b60c80998d77',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('1ea5647d-2d2c-48db-91ae-f4770001c007','MPH813','Health Policy Planning and Analysis','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('2e88e17b-b752-4411-a29a-080332d58859','MPH814','Health in Disaster and Emergency Situations','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','179067cf-9d42-468a-bf84-56962097261f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('3a8561c5-b60b-4df7-a191-dceac554f0e7','MPH815','Public health Nutrition','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','0ded251d-080e-4fe3-b787-1be53043b83b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4add3482-2590-4022-8206-6838dc514575','MPH816','Biostatistics II','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ef6e619e-0f9a-4787-b352-43a9cf81957a','MPH817','Large Data Analytics','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','d9daf77e-d52f-44e1-958a-5ba9b6811c99',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('adaaa99b-a0dc-47b2-8cdb-f647bcc7e971','MPH818','Clinical Trials','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','179067cf-9d42-468a-bf84-56962097261f',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e13f9242-6716-4eaf-917d-490e12f8e970','MPH819','Disease Surveillance','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','99d7e1aa-c930-49a2-9d97-45fc68a03711',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('c2fe40d5-5c9c-402e-b5a5-61b34e91dbba','MPH825','Maternal and Child Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','0ded251d-080e-4fe3-b787-1be53043b83b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('89c6b374-ed07-4862-ac38-d2f573077014','MPH826','Adolescent Health','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','0ded251d-080e-4fe3-b787-1be53043b83b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8c0543cc-0c67-4ad2-9f50-678af7429eda','MPH827','Demographic Techniques and Analysis','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','99d7e1aa-c930-49a2-9d97-45fc68a03711',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('aa6cc9c9-9bb8-4826-875f-6c8de34c9f4a','MPH828','Reproductive Health Program Management','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','22d76b7c-91e4-4a24-9e33-750834537da4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('66834c9b-265d-487a-86ae-d2f2e5c9e556','MPH829','Reproductive Health in Emergency Situations','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','22d76b7c-91e4-4a24-9e33-750834537da4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a235b183-f558-4008-b5fa-ac356367ff8f','MPH835','Monitoring and Evaluation principles and perspectives','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8c948952-c852-426a-b9b6-eb3d1683775e','MPH836','Applied Quantitative Methods and Tools In M&E','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','d9daf77e-d52f-44e1-958a-5ba9b6811c99',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('b589b2e5-45d0-48cc-b173-9cb7a0757867','MPH837','Programme Evaluation Theory and Practice','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','6a6f6b86-9785-47bf-bdb5-73051d9acb6b',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('bcc1ebaf-46eb-4b63-9a5b-79a42f586de3','MPH838','Data Management Analysis and Management Information Systems For M&E','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','d9daf77e-d52f-44e1-958a-5ba9b6811c99',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6ea30bff-56ce-4794-99b8-5df96f6ddc7c','MPH839','Capacity And Consultancy Skills Development in M&E','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('23106156-9edb-4fb8-8540-f3feceeb571c','MPH840','Epidemiology II','06a806fc-0d90-4c27-877d-1025a3ebdbd1','66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb','b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e6ef0085-d958-449a-a7e7-65b20b044f22','MPM715','Finance for Managers,Strategic Financial Management','0d35fa69-de7f-4e05-b800-16c07321e75f','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','22640f68-e8c9-43e7-bd70-59ba276acbbb',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cdbb814d-8f1c-4807-92b7-f83117df1761','MPM720','Project Planning and Management','0d35fa69-de7f-4e05-b800-16c07321e75f','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','6c3d9c6d-80a2-449a-ab8e-571f31d7691a',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e51027bb-0b6a-4ec6-9cee-b92a38a467ab','MPM721','Project Finance and Techniques','0d35fa69-de7f-4e05-b800-16c07321e75f','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','bc49574b-49f5-469e-96b9-b1267ee50f22',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('42eeede4-c7d9-457a-aa17-1aefe8186e2c','MPM722','Legal Aspects of Procurement / Project Management','0d35fa69-de7f-4e05-b800-16c07321e75f','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','40e8500b-3e15-4446-8cd9-9052435c6717',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('d40cbc16-9252-4c2d-b53b-d435606c974b','MPM811','Project Monitoring and Evaluation','0d35fa69-de7f-4e05-b800-16c07321e75f','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','f32de772-b345-4c97-ad24-ac5c40cac152',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('197963e8-2b6a-4643-843b-0de7a97b945d','MPM813','Project Implementation and Control','0d35fa69-de7f-4e05-b800-16c07321e75f','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','bd4fb816-ccf4-48e3-8618-477ffcacc3df',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4732a891-6b71-4c9f-bbe9-1179d72f760f','MPM814','Management Consultancy','0d35fa69-de7f-4e05-b800-16c07321e75f','aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb','6c3d9c6d-80a2-449a-ab8e-571f31d7691a',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('69e935d2-558b-4c35-8bb3-8fd7bb9e61c4','MSC720','Strategic International Business Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','6bc87c82-c6e2-4553-b120-0788ea05da23',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6cb0a9ee-0cbf-4d8b-a2bb-822db21109fc','MSC721','Project Risk and Procurement Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','40e8500b-3e15-4446-8cd9-9052435c6717',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('df40db8b-64fa-43c7-a584-423d37fb6420','MSC722','Legal Aspects of Procurement / Project Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','40e8500b-3e15-4446-8cd9-9052435c6717',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('fe982221-f09c-4b78-b070-dd3eada56624','MSC810','Supply Chain Operations Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','bd4fb816-ccf4-48e3-8618-477ffcacc3df',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e6aa58e1-1953-4fc9-9866-cbcaaa3cbb71','MSC814','Strategic Inventory Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','bd4fb816-ccf4-48e3-8618-477ffcacc3df',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('f0ef9618-0fa9-4c83-8cb3-f44466d3c212','MSS712','Security Studies | National, International & Global Security','422a6c15-127f-47d5-a044-e7547d35dcb6','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','90c1c369-8855-4032-8b61-46f7da81b8f1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e11d3289-4778-4802-961c-0e0efb0cb522','MSS714','Forensic Science and National Security','422a6c15-127f-47d5-a044-e7547d35dcb6','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('858b1ed2-2673-437c-bc87-d71ad7033c9e','MSS716','Criminology and Security','422a6c15-127f-47d5-a044-e7547d35dcb6','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','5b690ac2-1b30-42d6-add3-8078738a8f83',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e3fd279f-b971-4533-a0da-5deea9939509','MSS721','Human Security and Contemporary Wars','422a6c15-127f-47d5-a044-e7547d35dcb6','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','90c1c369-8855-4032-8b61-46f7da81b8f1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('6f2b6da0-d3ea-4e09-ac5e-68979f6a8ea4','MSS722','Anti-Terrorism and Counter-Terrorism Strategies','422a6c15-127f-47d5-a044-e7547d35dcb6','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','90c1c369-8855-4032-8b61-46f7da81b8f1',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('76eb02bf-bf6b-4871-bd85-e30df9d07674','MSS723','Threat, Risk Analysis and Security Management','422a6c15-127f-47d5-a044-e7547d35dcb6','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','6f576a3a-a80d-4ff6-a436-6726f48eac77',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('7306112e-1c2d-4b73-a19e-2aac5f395453','MSS724','Natural Resources Conflicts and Contemporary Wars','422a6c15-127f-47d5-a044-e7547d35dcb6','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','d0c037f9-c6ab-4457-ad78-d016954df586',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0668c4fe-6179-48af-a97a-270bfb8a831e','MSS725','Arms Proliferation, Disarmament and Arms Control','422a6c15-127f-47d5-a044-e7547d35dcb6','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','747d4ce8-8206-437a-ae42-9a84186617b8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('27300e58-4742-44ca-a1ae-5888bb1ce781','MSS810','Homeland Security, Cyber Security and Human Rights','422a6c15-127f-47d5-a044-e7547d35dcb6','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','747d4ce8-8206-437a-ae42-9a84186617b8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('2491db5d-9091-491a-a5f2-99b957247b25','MSS811','Civil-Military Relations and Security Sector','422a6c15-127f-47d5-a044-e7547d35dcb6','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','53167307-9a23-4931-bcd9-d7d3bd234bbb',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('8f28ae31-ff58-4d7c-9d55-cc6fb5ad0bd3','MSS812','International Politics of the Environment and National security','422a6c15-127f-47d5-a044-e7547d35dcb6','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','747d4ce8-8206-437a-ae42-9a84186617b8',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('5e9ff605-8721-4574-b7d8-2cc0f0f7f56e','MSS813','Geopolitical Studies, Global Peace and Security','422a6c15-127f-47d5-a044-e7547d35dcb6','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','d0c037f9-c6ab-4457-ad78-d016954df586',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('81862afd-727a-4cf5-960f-c6df3701b7d6','MSS814','World of Intelligence and Espionage','422a6c15-127f-47d5-a044-e7547d35dcb6','88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb','ac5d7730-aeb7-4e60-9f78-b11d744e43da',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('9afd4521-a386-4c94-a1ef-bc607f2d1621','NGO316','Resource Mobilization and Grants Administration','422a6c15-127f-47d5-a044-e7547d35dcb6','11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa','e550342a-6d2f-4487-b076-e1dd5d354d29',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('30dcd9c1-69fa-4c66-9efa-4cd980cf693f','PLM311','Principles of Procurement and Logistics Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','ea81a46a-2685-4f87-b958-3f5fdbbb3c3c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('0c3ed7f8-c2af-40fe-abc5-9195df5a2753','PLM314','Business Negotiations','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','6c3d9c6d-80a2-449a-ab8e-571f31d7691a',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('d069a261-f23d-4f6e-a0f3-c01aa905db31','PLM315','Global Purchasing and Supply Chain Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','ea81a46a-2685-4f87-b958-3f5fdbbb3c3c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('758e2e3e-7ee1-4596-840d-0092d50253b9','PLM316','Legal Aspects of Purchasing','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','40e8500b-3e15-4446-8cd9-9052435c6717',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ac2be648-cff2-4212-8355-d49e68f499c3','PLM317','Public and Private Procurement Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','ea81a46a-2685-4f87-b958-3f5fdbbb3c3c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('2e9ac377-9bb7-44c9-93b6-345d3e0b931a','PLM318','Risk Management in Purchasing','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','dde0b8b1-1865-475e-888c-22c29a4eeff9',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('a161b8af-9774-431f-9a63-811b00aee6d3','PLM319','Logistics & Supply Chain Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','dde0b8b1-1865-475e-888c-22c29a4eeff9',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('63d55abb-85bb-4178-b255-c81d87746b51','PLM321','Insurance Fundamentals','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('d142b7c8-dc50-496a-b3a9-cf5f682222bb','PLM322','Sustainable Purchasing','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','ea81a46a-2685-4f87-b958-3f5fdbbb3c3c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('4cf5e7ac-d07b-4e7d-8c1f-1e1cfe0665a4','PLM323','Material and Warehousing Operations','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('64549c32-7d8d-4bc8-b10e-a182e8a057a9','PLM324','Strategic Procurement','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','dde0b8b1-1865-475e-888c-22c29a4eeff9',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('cd2bd057-8d0a-412f-9f69-ef796005a2f2','PLM325','Public and Private Procurement Management','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863',NULL,3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('85466c2b-9155-4df6-8005-d7b5022997ae','PLM326','Inventory & Warehousing Operations','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','bd4fb816-ccf4-48e3-8618-477ffcacc3df',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('68c7e5b3-c53d-4136-88b2-6d3b36015930','PLM327','Procurement Audit & Investigations','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','ea81a46a-2685-4f87-b958-3f5fdbbb3c3c',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('ba4845c7-9a62-4bc4-94e1-4b0e1777d585','PLM328','E-Procurement & Software Applications','0d35fa69-de7f-4e05-b800-16c07321e75f','46a86d77-2f4c-4f44-a5ed-83d51354b863','bd4fb816-ccf4-48e3-8618-477ffcacc3df',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('984043c1-ac12-467e-b5fe-a7fc6de3334b','RSC001','Research Methods in International Relations','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','d2242310-57c2-484c-9f75-5888c5aaa883',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;
INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES ('e1d9882d-8d9a-4390-95ad-06b9573277b4','RSC003','Research Methodology and Consultancy','0d35fa69-de7f-4e05-b800-16c07321e75f','7ccf2f00-fc18-49f2-a479-52e834f32aaa','0f4a1369-cfa8-4246-a139-cc3bf1b79e02',3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;

-- Rooms
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('3cd471a3-0d26-495e-9e23-ea41663161cb','KG-10 Lecture Room','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','KG Block','Ground',NULL,'KG-10','KG-10 - KG Block, Cavendish University Uganda.',0.317300,32.571600,60,'active','static_geo',50,'88bd83710786585d660cbe0d22e5325f0e94dfc106be9f7f0a2f97512f306624',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('52e34f0c-4208-40cb-b1bb-c4b38e9301cd','KG-11 Lecture Room','lecture_room','422a6c15-127f-47d5-a044-e7547d35dcb6','KG Block','Ground',NULL,'KG-11','KG-11 - KG Block, Cavendish University Uganda.',0.317420,32.571600,60,'active','static_geo',50,'3c599bb1847ae36bb5baa14db26cc49ead4caf9b9c25c8572c2f0bf335d656f6',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('28c25afc-61e6-424d-b4b5-26aaeb69abee','KG-13 Lecture Room','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','KG Block','Ground',NULL,'KG-13','KG-13 - KG Block, Cavendish University Uganda.',0.317540,32.571600,60,'active','static_geo',50,'4ddbf1840ce996bae2a26954b269cc0cfdc66de5b8796366aaac4509af283f7c',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('0a67b70b-09e7-4187-8636-7cefe1de3ac1','KG-14 Lecture Room','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','KG Block','Ground',NULL,'KG-14','KG-14 - KG Block, Cavendish University Uganda.',0.317660,32.571600,60,'active','static_geo',50,'f1a9813bfab18db9e9bfe5a1febeea7fa1c2e147decc63af5e98bf9ea1513e9b',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('369de1c7-541a-4cb3-b07b-3d2177abb081','KG-15 Lecture Room','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','KG Block','Ground',NULL,'KG-15','KG-15 - KG Block, Cavendish University Uganda.',0.317780,32.571600,60,'active','static_geo',50,'8fc1dc4791f949588a335912cf627c191ed76a664c935e23fc79870db9a9eb26',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('a004639f-3f4d-4474-9eba-7f2d9d9baeeb','KG-21 Lecture Room','lecture_room','422a6c15-127f-47d5-a044-e7547d35dcb6','KG Block','Ground',NULL,'KG-21','KG-21 - KG Block, Cavendish University Uganda.',0.317900,32.571600,60,'active','static_geo',50,'fd57605c5e20562d51c4b0e4f8cdded6351837af35ff5d037a203608305b73e5',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('2d693696-3933-4bf3-9a2c-f30a634bfe79','KG-24 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','KG Block','Ground',NULL,'KG-24','KG-24 - KG Block, Cavendish University Uganda.',0.318020,32.571600,60,'active','static_geo',50,'eeff2ec373321b55ee11dc06db3c5d4b10a355c8c9485c4f5db68cfc967e17e3',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('f4d573fd-688e-42df-b851-f82eb382064c','KG-25 Lecture Room','lecture_room','422a6c15-127f-47d5-a044-e7547d35dcb6','KG Block','Ground',NULL,'KG-25','KG-25 - KG Block, Cavendish University Uganda.',0.318140,32.571600,60,'active','static_geo',50,'1f47b82009522e2f7c4ee7f15f38b609b9227c457bbd41c04def11f088d8a61e',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('a2146506-c078-4d10-8b14-bc843ef2b73b','KG-26 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','KG Block','Ground',NULL,'KG-26','KG-26 - KG Block, Cavendish University Uganda.',0.318260,32.571600,60,'active','static_geo',50,'192d64e2c89f636099cd2ba03c3f662b20439fd14dabbbbddca7952488057061',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('9cc0434b-9df4-439f-8dab-1da361497c54','KG-27 Lecture Room','lecture_room','422a6c15-127f-47d5-a044-e7547d35dcb6','KG Block','Ground',NULL,'KG-27','KG-27 - KG Block, Cavendish University Uganda.',0.318380,32.571600,60,'active','static_geo',50,'e0c5a31b146c51bc3cf673e1b3237178c79e99a7e78da8ef63c85beb09b445e0',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('cedab87c-b2e5-4e87-b703-3fbf24b677f4','KG-28 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','KG Block','Ground',NULL,'KG-28','KG-28 - KG Block, Cavendish University Uganda.',0.318500,32.571600,60,'active','static_geo',50,'12f4a9580a97189f2d899fc12703deaad4eac20c2c61fe9dc89fe1b351d37b0b',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('db63d9bf-812b-4168-b0d8-b66c99f5dba0','KG-29 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','KG Block','Ground',NULL,'KG-29','KG-29 - KG Block, Cavendish University Uganda.',0.318620,32.571600,60,'active','static_geo',50,'ebe410425eb2140b5d81dfd1d716d97f8d4a8db60f8bbc2781a20935a7a27416',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('59355c59-2a2f-4ee0-86fa-2d9a39617ea7','KG-4 Lecture Room','lecture_room','422a6c15-127f-47d5-a044-e7547d35dcb6','KG Block','Ground',NULL,'KG-4','KG-4 - KG Block, Cavendish University Uganda.',0.317300,32.571720,60,'active','static_geo',50,'1d17566bb03f9f618f4a1c3d0696b1b2f3a173353dc5d7b83e977e8c5917a52f',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('1b587bd4-928a-4c6f-ac1c-c8a3b158dd69','KG-5 Lecture Room','lecture_room','422a6c15-127f-47d5-a044-e7547d35dcb6','KG Block','Ground',NULL,'KG-5','KG-5 - KG Block, Cavendish University Uganda.',0.317420,32.571720,60,'active','static_geo',50,'48405030d961119292be62d4d07a6d2f05a671efc452d39f611cd27f046ed098',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('a67b56a1-e81a-4651-ba1e-50ca6850e27d','KG-6 Lecture Room','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','KG Block','Ground',NULL,'KG-6','KG-6 - KG Block, Cavendish University Uganda.',0.317540,32.571720,60,'active','static_geo',50,'426d955de4fb98f19084c427dc7a35a55ead91d33c9bd317c865c8897c7877ba',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('0e37ca9d-1c8a-46c0-afb0-217af2512dad','KG-7 Lecture Room','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','KG Block','Ground',NULL,'KG-7','KG-7 - KG Block, Cavendish University Uganda.',0.317660,32.571720,60,'active','static_geo',50,'2d7b3b67e1d453bbd6bf525e200743e2c18205ad9c64c9a44a68d7f76c3fe99a',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('ad6cb1eb-f8e7-4dff-b451-e914e65490d7','KG-9 Lecture Room','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','KG Block','Ground',NULL,'KG-9','KG-9 - KG Block, Cavendish University Uganda.',0.317780,32.571720,60,'active','static_geo',50,'b42ce170de96f088eef8d3f70bd49c28c3b3bceacb5e172b061859c369f4b94f',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('c4bf37e8-0159-4f73-a839-22dccbf43983','KG-LAB-29 Laboratory','lab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','KG Block','Ground',NULL,'KG-LAB-29','KG-LAB-29 - KG Block, Cavendish University Uganda.',0.317900,32.571720,30,'active','static_geo',50,'74023bb8a8aee5268c5717007cd84ccea773a66fd41f0ca7e27a727d5eb32442',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('a0ddad85-0194-4c65-b078-b85343776f33','KG-LAB-30 Laboratory','lab','96178a5a-1a50-43ad-ace6-045b0e7dd47a','KG Block','Ground',NULL,'KG-LAB-30','KG-LAB-30 - KG Block, Cavendish University Uganda.',0.318020,32.571720,30,'active','static_geo',50,'b2ea7ae77fe649e393efaa18fff24f2578347dddeee3701caed559e6b1a97ae5',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('47dcd496-fbb2-4b5a-a3b8-be6896abd17b','LAB-1 Laboratory','lab','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','Laboratory Block','Ground',NULL,'LAB-1','LAB-1 - Laboratory Block, Cavendish University Uganda.',0.318140,32.571720,30,'active','static_geo',50,'ac172b7f767fb6f5e0838c217dd9231c35cbb16367ed8a526dbef59aeb43a0e0',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('eb8c8c97-49c4-484d-9e13-509ae18c714e','LLB1 Lecture Room','lecture_room','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','Law Block','Ground',NULL,'LLB1','LLB1 - Law Block, Cavendish University Uganda.',0.318260,32.571720,40,'active','static_geo',50,'9858fc5c3179a36655ae11cfff55c352f06b19a8745e822694b6cb05731819ca',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('5b163c4c-99ef-4016-8b04-2d265a9b2e2c','LLB2 Lecture Room','lecture_room','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','Law Block','Ground',NULL,'LLB2','LLB2 - Law Block, Cavendish University Uganda.',0.318380,32.571720,40,'active','static_geo',50,'21856450cd221513abf292886beb48b36ff6583d0ec005e0a1f6c01ece0a57ac',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('70ccffdc-7d06-42e5-93bf-9a8cdfd4e781','LLB3 Lecture Room','lecture_room','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','Law Block','Ground',NULL,'LLB3','LLB3 - Law Block, Cavendish University Uganda.',0.318500,32.571720,40,'active','static_geo',50,'69b09b830d0d99be28cb5a119add0f952a7ebf527e910df6ff2050c771f5537a',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('e46025c6-bc72-482b-88f0-101b115cf68f','LLB4 Lecture Room','lecture_room','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','Law Block','Ground',NULL,'LLB4','LLB4 - Law Block, Cavendish University Uganda.',0.318620,32.571720,40,'active','static_geo',50,'2845a65375b67deddd065126cc1e384c1c7e8af95d74000786ae01b4a2dea476',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('8a63e821-6811-4bd8-a8d8-4af6eb65b405','LLM Lecture Room','lecture_room','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','Law Block','Ground',NULL,'LLM','LLM - Law Block, Cavendish University Uganda.',0.317300,32.571840,40,'active','static_geo',50,'55dfa893123bfd18bce2d986c98e81f9ef8d5fa079909b1d610001101b931a87',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('7d777e60-432e-4e05-85d2-3a943e3a68ee','MKN-05 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MKN Block','Ground',NULL,'MKN-05','MKN-05 - MKN Block, Cavendish University Uganda.',0.317420,32.571840,50,'active','static_geo',50,'cd6b5d1fe2e861dd521a7f9e91c9f9c148711e8eddb2db772ac9b55adafc5fb5',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('3ebf9e8b-97a8-49b1-b97c-fdb7bb7063e0','MKN-08 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MKN Block','Ground',NULL,'MKN-08','MKN-08 - MKN Block, Cavendish University Uganda.',0.317540,32.571840,50,'active','static_geo',50,'07ee42f7216574c1d5b9dd0e6cf43fc2c61053334605c7fee80f7e7b6e58b597',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('5c86023f-e5a5-4f02-a32b-2d7030469db3','MKN-09 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MKN Block','Ground',NULL,'MKN-09','MKN-09 - MKN Block, Cavendish University Uganda.',0.317660,32.571840,50,'active','static_geo',50,'40008c6b127598a4d6fd9eb75883113da9a20634d770f204051339774d96aa54',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('7a4b5c5c-2500-42e9-8b66-22d60c798de7','MKN-10 Lecture Room','lecture_room','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MKN Block','Ground',NULL,'MKN-10','MKN-10 - MKN Block, Cavendish University Uganda.',0.317780,32.571840,50,'active','static_geo',50,'625d47c594221a1889198e6bab2339ee242f5ca5c5f9bb4932bb327db2cead5a',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('d37f5956-eac6-4b22-9dee-c9b691f6b9ee','MKN-14 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MKN Block','Ground',NULL,'MKN-14','MKN-14 - MKN Block, Cavendish University Uganda.',0.317900,32.571840,50,'active','static_geo',50,'836b3ca5ccc4348ec146782cda2d2d7f379e6ead60dacf3a02e7a25c5bb75752',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('0b51826d-dfe4-434d-8588-d68e95bd96af','MKN-15 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MKN Block','Ground',NULL,'MKN-15','MKN-15 - MKN Block, Cavendish University Uganda.',0.318020,32.571840,50,'active','static_geo',50,'387ed3183255bd571d46bcd133cbd3152c7b9442761b1643874b899391a298de',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('4b733d3c-89a2-4cda-8305-e9d24387101b','MKN-16 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MKN Block','Ground',NULL,'MKN-16','MKN-16 - MKN Block, Cavendish University Uganda.',0.318140,32.571840,50,'active','static_geo',50,'f3474dda9d722df89add1b856dd1a4135a8e3dd5fdb59ae21945fe1edb43f7d6',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('1cd725ce-78c7-4d4a-900f-68e5caa495aa','MKN-17 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MKN Block','Ground',NULL,'MKN-17','MKN-17 - MKN Block, Cavendish University Uganda.',0.318260,32.571840,50,'active','static_geo',50,'10585e1eedeb0bea6ebc8c5a259c5022ae42f33a0063dde7cd8f3e1b5ce373a4',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('5f28f221-fdf3-434a-9fdb-e34600bd4dcf','MKN-18 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','MKN Block','Ground',NULL,'MKN-18','MKN-18 - MKN Block, Cavendish University Uganda.',0.318380,32.571840,50,'active','static_geo',50,'904968a5c37a22b771486019e9d859a2d0d5ea040a47346d338a19f4a3e68494',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('c57a22c8-e804-4543-b402-36f25b2376a9','MKN-19 Lecture Room','lecture_room','06a806fc-0d90-4c27-877d-1025a3ebdbd1','MKN Block','Ground',NULL,'MKN-19','MKN-19 - MKN Block, Cavendish University Uganda.',0.318500,32.571840,50,'active','static_geo',50,'30c35db8dab42686af758c01018ea69b037fe52213a3a03d1fbd8cb682993661',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('0fa397db-692f-41f7-85f2-b48504cdb212','MOOT-COURT Discussion Room','discussion_room','5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e','Law Block','Ground',NULL,'MOOT-COURT','MOOT-COURT - Law Block, Cavendish University Uganda.',0.318620,32.571840,80,'active','static_geo',50,'9b874b395c3d3f3437fdf895fdef5f7997c57ea576d00655de3ac01bd78ec942',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('cc873e27-32db-486d-a026-f9377f639bda','SI-011 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','SI Block','Ground',NULL,'SI-011','SI-011 - SI Block, Cavendish University Uganda.',0.317300,32.571960,50,'active','static_geo',50,'d5428c4621af6d0b1f6211c302d407f9cd247fe8228b77ce177566aed28f5edc',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('68f14234-7c8d-4fc3-b2a6-9fd3627b934d','SI-012 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','SI Block','Ground',NULL,'SI-012','SI-012 - SI Block, Cavendish University Uganda.',0.317420,32.571960,50,'active','static_geo',50,'16b5bf551c6bbfcac10602d28c86a7051a4ecaef22132531d516b09752d7a751',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('7d44b705-3a79-4b6f-9440-74ffd7fb209a','SI-102 Lecture Room','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','SI Block','Ground',NULL,'SI-102','SI-102 - SI Block, Cavendish University Uganda.',0.317540,32.571960,50,'active','static_geo',50,'964f909f6f2b1e90fa9c0ff06d4a65d3cf2d18462ba9c05df18d84bbfce7d005',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('8af12b07-3208-4c79-ad06-cec76966905f','SI-105 Lecture Room','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','SI Block','Ground',NULL,'SI-105','SI-105 - SI Block, Cavendish University Uganda.',0.317660,32.571960,50,'active','static_geo',50,'af75d44ff9c36c9fcf9ad466c3e94da4a667262d97cfdeecba6b194bda7265b2',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('5f890b50-2c0f-4f42-b91f-3d717bc741d2','SI-112 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','SI Block','Ground',NULL,'SI-112','SI-112 - SI Block, Cavendish University Uganda.',0.317780,32.571960,50,'active','static_geo',50,'624894748652f7e0a21a2c44693c49bf3903a4ec8e6fa49e844d5673b1b8d53e',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('832d78aa-368d-4490-af72-60b1572884d1','SI-202 Lecture Room','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','SI Block','Ground',NULL,'SI-202','SI-202 - SI Block, Cavendish University Uganda.',0.317900,32.571960,50,'active','static_geo',50,'3b09b2a1b36064d202233ea066dff2073434357aabbc84902864731e0fa85e1f',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('eb9c5fdd-064c-41d1-aa64-73d37bbc8ca1','SI-205 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','SI Block','Ground',NULL,'SI-205','SI-205 - SI Block, Cavendish University Uganda.',0.318020,32.571960,50,'active','static_geo',50,'2f36cc1fdaf5c2e5bc51f852aeb1f3a90464a9835d09f9008c3e66891276420b',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('baebe5e1-c3e8-49c0-847e-f04da88ec648','SI-212 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','SI Block','Ground',NULL,'SI-212','SI-212 - SI Block, Cavendish University Uganda.',0.318140,32.571960,50,'active','static_geo',50,'a4c1618aed9a8264c82d70403dbd6576f13fad4283543983b1c7536e6452f05e',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('d8951f23-e363-4c8b-aea2-37f5d3d3354a','SI-214 Lecture Room','lecture_room','96178a5a-1a50-43ad-ace6-045b0e7dd47a','SI Block','Ground',NULL,'SI-214','SI-214 - SI Block, Cavendish University Uganda.',0.318260,32.571960,50,'active','static_geo',50,'ba9d8b6da5f8861267a085e34302b06fa29d3e4ca46409fddfae65cac51df47e',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('0ed702e0-7d67-46ee-825a-690888e4b116','SI-B01 Lecture Room','lecture_room','0d35fa69-de7f-4e05-b800-16c07321e75f','SI Block','Ground',NULL,'SI-B01','SI-B01 - SI Block, Cavendish University Uganda.',0.318380,32.571960,50,'active','static_geo',50,'41873f60d14b7416af757ee5159f2ed69424bc074cd7de7464c6df99c09ab00a',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';
INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES ('7a5003ab-905a-4504-b97f-4e7e590ab401','SI-B12 Lecture Room','lecture_room','422a6c15-127f-47d5-a044-e7547d35dcb6','SI Block','Ground',NULL,'SI-B12','SI-B12 - SI Block, Cavendish University Uganda.',0.318500,32.571960,50,'active','static_geo',50,'ed899ee9c4d410c8f553c3b2508510439a45ebc1f7747b27638e31219ab93e88',1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';

-- Room equipment
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-10' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-10' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-11' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-11' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-13' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-13' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-14' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-14' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-15' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-15' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-21' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-21' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-24' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-24' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-25' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-25' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-26' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-26' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-27' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-27' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-28' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-28' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-29' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-29' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-4' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-4' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-5' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-5' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-6' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-6' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-7' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-7' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-9' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-9' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Computers',30 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-LAB-29' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-LAB-29' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-LAB-29' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Computers',30 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-LAB-30' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-LAB-30' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'KG Block' AND room_number = 'KG-LAB-30' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Computers',30 FROM facilities WHERE building = 'Laboratory Block' AND room_number = 'LAB-1' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'Laboratory Block' AND room_number = 'LAB-1' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'Laboratory Block' AND room_number = 'LAB-1' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'Law Block' AND room_number = 'LLB1' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'Law Block' AND room_number = 'LLB1' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'Law Block' AND room_number = 'LLB2' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'Law Block' AND room_number = 'LLB2' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'Law Block' AND room_number = 'LLB3' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'Law Block' AND room_number = 'LLB3' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'Law Block' AND room_number = 'LLB4' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'Law Block' AND room_number = 'LLB4' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'Law Block' AND room_number = 'LLM' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'Law Block' AND room_number = 'LLM' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-05' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-05' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-08' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-08' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-09' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-09' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-10' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-10' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-14' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-14' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-15' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-15' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-16' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-16' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-17' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-17' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-18' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-18' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-19' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'MKN Block' AND room_number = 'MKN-19' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'Law Block' AND room_number = 'MOOT-COURT' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'Law Block' AND room_number = 'MOOT-COURT' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-011' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-011' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-012' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-012' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-102' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-102' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-105' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-105' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-112' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-112' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-202' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-202' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-205' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-205' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-212' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-212' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-214' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-214' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-B01' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-B01' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Projector',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-B12' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;
INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,'Whiteboard',1 FROM facilities WHERE building = 'SI Block' AND room_number = 'SI-B12' ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;

-- Class/module links
INSERT INTO class_modules (class_id,module_id,semester_id)
SELECT DISTINCT c.id, m.id, s.id
FROM (VALUES
  ('ADHM1101','ADHM-Y1'),
  ('ADHM1102','ADHM-Y1'),
  ('ADHM1103','ADHM-Y1'),
  ('ADHM1104','ADHM-Y1'),
  ('ADHM1105','ADHM-Y1'),
  ('ADHM1106','ADHM-Y1'),
  ('ADHM1106','BPH-Y3'),
  ('ADHM1201','ADHM-Y1'),
  ('ADHM1202','ADHM-Y1'),
  ('ADHM1203','ADHM-Y1'),
  ('ADHM1204','ADHM-Y1'),
  ('ADHM1205','ADHM-Y1'),
  ('ADHM1206','ADHM-Y1'),
  ('AGM212','BBA-Y2'),
  ('AGM212','BBA-Y2-W'),
  ('AGM212','BCS-Y3'),
  ('AGM212','BIT-Y2'),
  ('AGM212','BSE-Y4'),
  ('AGM212','DBA-Y2'),
  ('BAC215','BBA-Y2'),
  ('BAC215','BBA-Y2-W'),
  ('BAC215','DBA-Y2'),
  ('BAC313','BBA-Y3'),
  ('BAC313','BBA-Y3-AF'),
  ('BAC314','BBA-Y3'),
  ('BAC314','BBA-Y3-AF'),
  ('BAC316','BBA-Y3'),
  ('BAC316','BBA-Y3-AF'),
  ('BAC316','BBA-Y3-BF'),
  ('BAC321','BBA-Y3'),
  ('BAC321','BBA-Y3-AF'),
  ('BAC321','BBA-Y3-BF'),
  ('BAC322','BBA-Y3'),
  ('BAC322','BBA-Y3-AF'),
  ('BAC326','BBA-Y3'),
  ('BAC326','BBA-Y3-AF'),
  ('BAC327','BBA-Y3'),
  ('BAC327','BBA-Y3-AF'),
  ('BBA112','BBA-Y1'),
  ('BBA112','BBA-Y1-AF'),
  ('BBA112','BBA-Y1-BF'),
  ('BBA112','BBA-Y1-ENT'),
  ('BBA112','BBA-Y1-G'),
  ('BBA112','BBA-Y1-HRM'),
  ('BBA112','BBA-Y1-MKT'),
  ('BBA112','BBA-Y1-PL'),
  ('BBA112','BBA-Y1-W'),
  ('BBA112','DBA-Y1'),
  ('BBA113','BBA-Y1'),
  ('BBA113','BBA-Y1-AF'),
  ('BBA113','BBA-Y1-BF'),
  ('BBA113','BBA-Y1-ENT'),
  ('BBA113','BBA-Y1-G'),
  ('BBA113','BBA-Y1-HRM'),
  ('BBA113','BBA-Y1-MKT'),
  ('BBA113','BBA-Y1-PL'),
  ('BBA113','BBA-Y1-W'),
  ('BBA113','DBA-Y1'),
  ('BBA115','BBA-Y1'),
  ('BBA115','BBA-Y1-AF'),
  ('BBA115','BBA-Y1-BF'),
  ('BBA115','BBA-Y1-ENT'),
  ('BBA115','BBA-Y1-G'),
  ('BBA115','BBA-Y1-HRM'),
  ('BBA115','BBA-Y1-MKT'),
  ('BBA115','BBA-Y1-PL'),
  ('BBA115','BBA-Y1-W'),
  ('BBA115','DBA-Y1'),
  ('BBA116','BBA-Y1'),
  ('BBA116','BBA-Y1-AF'),
  ('BBA116','BBA-Y1-BF'),
  ('BBA116','BBA-Y1-ENT'),
  ('BBA116','BBA-Y1-G'),
  ('BBA116','BBA-Y1-HRM'),
  ('BBA116','BBA-Y1-MKT'),
  ('BBA116','BBA-Y1-PL'),
  ('BBA116','BBA-Y1-W'),
  ('BBA116','BCS-Y1'),
  ('BBA116','BDA-Y1'),
  ('BBA116','BDSA-Y1'),
  ('BBA116','BIT-Y1'),
  ('BBA116','DBA-Y1'),
  ('BBA116','DDA-Y1'),
  ('BBA116','DDSA-Y1'),
  ('BBA122','BBA-Y1'),
  ('BBA122','BBA-Y1-W'),
  ('BBA122','DBA-Y1'),
  ('BBA123','BBA-Y1'),
  ('BBA123','BBA-Y1-W'),
  ('BBA123','DBA-Y1'),
  ('BBA124','BBA-Y1'),
  ('BBA124','BBA-Y1-W'),
  ('BBA124','DBA-Y1'),
  ('BBA125','BBA-Y1'),
  ('BBA125','BBA-Y1-W'),
  ('BBA125','DBA-Y1'),
  ('BBA211','BBA-Y2'),
  ('BBA211','BBA-Y2-W'),
  ('BBA211','DBA-Y2'),
  ('BBA212','BBA-Y2'),
  ('BBA212','BBA-Y2-W'),
  ('BBA214','BBA-Y2'),
  ('BBA214','BBA-Y2-W'),
  ('BBA214','BCS-Y3'),
  ('BBA214','BIT-Y2'),
  ('BBA214','BSE-Y4'),
  ('BBA214','DBA-Y2'),
  ('BBA215','BBA-Y2'),
  ('BBA215','BBA-Y2-W'),
  ('BBA215','BPAM-Y3'),
  ('BBA215','DBA-Y2'),
  ('BBA216','BBA-Y2'),
  ('BBA216','BBA-Y2-W'),
  ('BBA216','DBA-Y2'),
  ('BBA221','BBA-Y2'),
  ('BBA221','BBA-Y2-W'),
  ('BBA223','BBA-Y2'),
  ('BBA223','BBA-Y2-W'),
  ('BBA223','DBA-Y2'),
  ('BBA224','BBA-Y2'),
  ('BBA224','BBA-Y2-W'),
  ('BBA311','BBA-Y1'),
  ('BBA311','BBA-Y1-W'),
  ('BBA311','DBA-Y1'),
  ('BBA313','BBA-Y3'),
  ('BBA313','BBA-Y3-G'),
  ('BBA314','BBA-Y3'),
  ('BBA314','BBA-Y3-AF'),
  ('BBA314','BBA-Y3-BF'),
  ('BBA314','BBA-Y3-G'),
  ('BBA315','BBA-Y3'),
  ('BBA315','BBA-Y3-G'),
  ('BBA317','BBA-Y3'),
  ('BBA317','BBA-Y3-AF'),
  ('BBA321','BBA-Y3-AF'),
  ('BBA321','BBA-Y3-BF'),
  ('BBA321','BBA-Y3-G'),
  ('BBA322','BBA-Y3'),
  ('BBA322','BBA-Y3-G'),
  ('BBA322','BBA-Y3-HRM'),
  ('BBA322','BPAM-Y3'),
  ('BBA322','BPH-Y3'),
  ('BBA323','BBA-Y3'),
  ('BBA323','BBA-Y3-G'),
  ('BBA324','BBA-Y3'),
  ('BBA324','BBA-Y3-BF'),
  ('BBA324','BBA-Y3-G'),
  ('BBA324','BBA-Y3-HRM'),
  ('BBA324','BPAM-Y2'),
  ('BBA325','BBA-Y3-G'),
  ('BBF222','BBA-Y2'),
  ('BBF222','BBA-Y2-W'),
  ('BBF311','BBA-Y3'),
  ('BBF311','BBA-Y3-BF'),
  ('BBF313','BBA-Y3'),
  ('BBF313','BBA-Y3-BF'),
  ('BBF315','BBA-Y3'),
  ('BBF315','BBA-Y3-BF'),
  ('BBF316','BBA-Y3'),
  ('BBF316','BBA-Y3-AF'),
  ('BBF316','BBA-Y3-BF'),
  ('BBF316','BBA-Y3-G'),
  ('BBF316','BPAM-Y1'),
  ('BBF317','BBA-Y3'),
  ('BBF317','BBA-Y3-AF'),
  ('BBF322','BBA-Y3'),
  ('BBF322','BBA-Y3-BF'),
  ('BBF323','BBA-Y3'),
  ('BBF323','BBA-Y3-BF'),
  ('BBF325','BBA-Y3'),
  ('BBF325','BBA-Y3-AF'),
  ('BBF325','BBA-Y3-BF'),
  ('BBF326','BBA-Y3'),
  ('BBF326','BBA-Y3-BF'),
  ('BBF326','BBA-Y3-G'),
  ('BDA1201','BDSA-Y1'),
  ('BDA1201','DDA-Y1'),
  ('BDA1201','DDSA-Y1'),
  ('BDA1202','BDSA-Y1'),
  ('BDA1202','DDA-Y1'),
  ('BDA1202','DDSA-Y1'),
  ('BDA2101','BDSA-Y2'),
  ('BDA2102','BDSA-Y2'),
  ('BDA2102','DDSA-Y2'),
  ('BDA2104','BDSA-Y2'),
  ('BDA2201','BDSA-Y2'),
  ('BDA2202','BDSA-Y2'),
  ('BDA2202','DDSA-Y2'),
  ('BDA2203','BDSA-Y2'),
  ('BDA2203','DDSA-Y2'),
  ('BDA3101','BDSA-Y3'),
  ('BDA3103','BDSA-Y3'),
  ('BDA3105','BDSA-Y3'),
  ('BIS313','BCS-Y2'),
  ('BIS313','BIT-Y3'),
  ('BIT110','BBA-Y1'),
  ('BIT110','BBA-Y1-AF'),
  ('BIT110','BBA-Y1-BF'),
  ('BIT110','BBA-Y1-ENT'),
  ('BIT110','BBA-Y1-G'),
  ('BIT110','BBA-Y1-HRM'),
  ('BIT110','BBA-Y1-MKT'),
  ('BIT110','BBA-Y1-PL'),
  ('BIT110','BBA-Y1-W'),
  ('BIT110','BCS-Y1'),
  ('BIT110','BDA-Y1'),
  ('BIT110','BDSA-Y1'),
  ('BIT110','BEHS-Y1'),
  ('BIT110','BIRDS-Y1'),
  ('BIT110','BIT-Y1'),
  ('BIT110','BJC-Y1'),
  ('BIT110','BPAM-Y1'),
  ('BIT110','BPH-Y1'),
  ('BIT110','BSE-Y1'),
  ('BIT110','DBA-Y1'),
  ('BIT110','DDA-Y1'),
  ('BIT110','DDSA-Y1'),
  ('BIT110','DIT-Y1'),
  ('BIT111','BCS-Y1'),
  ('BIT111','BDA-Y1'),
  ('BIT111','BDSA-Y1'),
  ('BIT111','BDSA-Y1-ONLINE'),
  ('BIT111','BIT-Y1'),
  ('BIT111','BSE-Y1'),
  ('BIT113','BIT-Y1'),
  ('BIT113','DIT-Y1'),
  ('BIT121','BCS-Y2'),
  ('BIT121','BDSA-Y2'),
  ('BIT121','BIT-Y1'),
  ('BIT121','BSE-Y1'),
  ('BIT121','DDSA-Y2'),
  ('BIT121','DIT-Y1'),
  ('BIT122','BCS-Y1'),
  ('BIT122','BDSA-Y1'),
  ('BIT122','BIT-Y1'),
  ('BIT122','BSE-Y1'),
  ('BIT122','DDA-Y1'),
  ('BIT122','DDSA-Y1'),
  ('BIT122','DIT-Y1'),
  ('BIT123','BIT-Y1'),
  ('BIT123','DIT-Y1'),
  ('BIT124','BCS-Y1'),
  ('BIT124','BIT-Y1'),
  ('BIT124','BSE-Y3'),
  ('BIT124','DIT-Y2'),
  ('BIT125','BBA-Y3'),
  ('BIT125','BBA-Y3-G'),
  ('BIT125','BIT-Y1'),
  ('BIT125','DBA-Y2'),
  ('BIT212','BCS-Y1'),
  ('BIT212','BIT-Y2'),
  ('BIT212','BSE-Y1'),
  ('BIT212','DIT-Y2'),
  ('BIT213','BCS-Y2'),
  ('BIT213','BIT-Y2'),
  ('BIT213','BSE-Y2'),
  ('BIT213','DCS-Y2'),
  ('BIT213','DIT-Y2'),
  ('BIT214','BCS-Y2'),
  ('BIT214','BDSA-Y1'),
  ('BIT214','BDSA-Y1-ONLINE'),
  ('BIT214','BIT-Y2'),
  ('BIT214','BSE-Y2'),
  ('BIT214','DCS-Y2'),
  ('BIT214','DDSA-Y2'),
  ('BIT214','DIT-Y2'),
  ('BIT215','BCS-Y2'),
  ('BIT215','BIT-Y2'),
  ('BIT215','BSE-Y2'),
  ('BIT215','DIT-Y2'),
  ('BIT222','BCS-Y2'),
  ('BIT222','BDSA-Y2'),
  ('BIT222','BIT-Y2'),
  ('BIT222','BSE-Y2'),
  ('BIT222','DIT-Y2'),
  ('BIT223','BIT-Y2'),
  ('BIT223','DIT-Y2'),
  ('BIT225','BCS-Y3'),
  ('BIT225','BIT-Y2'),
  ('BIT225','DDSA-Y2'),
  ('BIT225','DIT-Y2'),
  ('BIT311','BCS-Y3'),
  ('BIT311','BIT-Y3'),
  ('BIT311','BSE-Y4'),
  ('BIT312','BCS-Y3'),
  ('BIT312','BIT-Y3'),
  ('BIT312','BSE-Y3'),
  ('BIT314','BCS-Y3'),
  ('BIT314','BIT-Y3'),
  ('BIT314','BSE-Y3'),
  ('BIT315','BIT-Y3'),
  ('BIT315','DIT-Y2'),
  ('BIT321','BCS-Y3'),
  ('BIT321','BIT-Y3'),
  ('BIT321','BSE-Y4'),
  ('BIT321','DIT-Y2'),
  ('BIT322','BIT-Y3'),
  ('BIT323','BIT-Y3'),
  ('BIT323','BSE-Y3'),
  ('BIT323','DCS-Y2'),
  ('BIT324','BCS-Y3'),
  ('BIT324','BIT-Y3'),
  ('BIT325','BIT-Y3'),
  ('BJC110','BBA-Y1'),
  ('BJC110','BBA-Y1-AF'),
  ('BJC110','BBA-Y1-BF'),
  ('BJC110','BBA-Y1-ENT'),
  ('BJC110','BBA-Y1-G'),
  ('BJC110','BBA-Y1-HRM'),
  ('BJC110','BBA-Y1-MKT'),
  ('BJC110','BBA-Y1-PL'),
  ('BJC110','BBA-Y1-W'),
  ('BJC110','BCS-Y1'),
  ('BJC110','BDA-Y1'),
  ('BJC110','BDSA-Y1'),
  ('BJC110','BEHS-Y1'),
  ('BJC110','BIRDS-Y1'),
  ('BJC110','BIT-Y1'),
  ('BJC110','BJC-Y1'),
  ('BJC110','BPAM-Y1'),
  ('BJC110','BPH-Y1'),
  ('BJC110','BSE-Y1'),
  ('BJC110','DBA-Y1'),
  ('BJC110','DDA-Y1'),
  ('BJC110','DDSA-Y1'),
  ('BJC110','DIT-Y1'),
  ('BJC112','BJC-Y1'),
  ('BJC115','BJC-Y1'),
  ('BJC116','BIRDS-Y1'),
  ('BJC116','BJC-Y1'),
  ('BJC116','BPAM-Y1'),
  ('BJC121','BJC-Y1'),
  ('BJC122','BJC-Y1'),
  ('BJC123','BJC-Y1'),
  ('BJC124','BJC-Y2'),
  ('BJC125','BJC-Y1'),
  ('BJC127','BJC-Y1'),
  ('BJC128','BJC-Y1'),
  ('BJC211','BJC-Y2'),
  ('BJC212','BJC-Y2'),
  ('BJC213','BJC-Y2'),
  ('BJC214','BJC-Y2'),
  ('BJC217','BJC-Y2'),
  ('BJC221','BJC-Y2'),
  ('BJC224','BJC-Y2'),
  ('BJC225','BJC-Y2'),
  ('BJC226','BJC-Y2'),
  ('BJC229','BJC-Y2'),
  ('BJC311','BJC-Y3'),
  ('BJC312','BJC-Y3'),
  ('BJC313','BJC-Y3'),
  ('BJC313','BJC-Y3-J'),
  ('BJC313','BJC-Y3-PR'),
  ('BJC314','BJC-Y3'),
  ('BJC315','BJC-Y3'),
  ('BJC321','BJC-Y3'),
  ('BJC322','BJC-Y3'),
  ('BJC322','BJC-Y3-J'),
  ('BJC323','BJC-Y3'),
  ('BJC323','BJC-Y3-JOURNALISM'),
  ('BJC324','BJC-Y3'),
  ('BJC324','BJC-Y3-JOURNALISM'),
  ('BJC325','BJC-Y3'),
  ('BJC326','BJC-Y3'),
  ('BJC326','BJC-Y3-J'),
  ('BJC327','BJC-Y3'),
  ('BJC327','BJC-Y3-J'),
  ('BJC328','BJC-Y3'),
  ('BJC328','BJC-Y3-J'),
  ('BJC329','BJC-Y3'),
  ('BJC329','BJC-Y3-J'),
  ('BPA111','BIRDS-Y2'),
  ('BPA111','BPAM-Y1'),
  ('BPA112','BBA-Y3'),
  ('BPA112','BPAM-Y1'),
  ('BPA113','BPAM-Y2'),
  ('BPA113','HEC-Y1'),
  ('BPA116','BBA-Y3-G'),
  ('BPA116','BBA-Y3-HRM'),
  ('BPA116','BPAM-Y1'),
  ('BPA121','BIRDS-Y1'),
  ('BPA121','BJC-Y1'),
  ('BPA121','BPAM-Y1'),
  ('BPA121','HEC-Y1'),
  ('BPA121','HEC-Y1-A'),
  ('BPA122','BPAM-Y1'),
  ('BPA123','BPAM-Y1'),
  ('BPA124','BBA-Y3'),
  ('BPA124','BBA-Y3-HRM'),
  ('BPA124','BPAM-Y1'),
  ('BPA124','BPAM-Y3'),
  ('BPA125','BIRDS-Y2'),
  ('BPA125','BPAM-Y2'),
  ('BPA126','BIRDS-Y1'),
  ('BPA126','BPAM-Y1'),
  ('BPA211','BBA-Y3'),
  ('BPA211','BPAM-Y2'),
  ('BPA213','BPAM-Y2'),
  ('BPA215','BPAM-Y2'),
  ('BPA216','BPAM-Y2'),
  ('BPA217','BPAM-Y2'),
  ('BPA221','BPAM-Y1'),
  ('BPA225','BIRDS-Y1'),
  ('BPA225','BPAM-Y2'),
  ('BPA226','BPAM-Y2'),
  ('BPA312','BPAM-Y3'),
  ('BPA313','BPAM-Y3'),
  ('BPA314','BPAM-Y3'),
  ('BPA316','BPAM-Y3'),
  ('BPA322','BPAM-Y3'),
  ('BPA323','BPAM-Y3'),
  ('BPA324','BPAM-Y3'),
  ('BPA325','BPAM-Y3'),
  ('BPH112','BPH-Y1'),
  ('BPH113','BEHS-Y1'),
  ('BPH113','BPH-Y1'),
  ('BPH114','BPH-Y1'),
  ('BPH121','BPH-Y1'),
  ('BPH122','BPH-Y1'),
  ('BPH124','BEHS-Y1'),
  ('BPH124','BPH-Y1'),
  ('BPH211','BEHS-Y2'),
  ('BPH211','BPH-Y2'),
  ('BPH212','BPH-Y1'),
  ('BPH215','BPH-Y2'),
  ('BPH216','BPH-Y2'),
  ('BPH221','BEHS-Y3'),
  ('BPH221','BPH-Y2'),
  ('BPH221','DDA-Y1'),
  ('BPH222','BPH-Y2'),
  ('BPH222','DDA-Y1'),
  ('BPH224','BPH-Y2'),
  ('BPH224','DDA-Y1'),
  ('BPH311','BEHS-Y3'),
  ('BPH311','BPH-Y3'),
  ('BPH313','BPH-Y3'),
  ('BPH314','BPH-Y3'),
  ('BPH321','BEHS-Y3'),
  ('BPH321','BPH-Y3'),
  ('BPH323','BPH-Y2'),
  ('BPH323','BPH-Y3'),
  ('BPH324','BPH-Y3'),
  ('BPH326','BPH-Y3'),
  ('BPR321','BJC-Y3'),
  ('BPR321','BJC-Y3-PR'),
  ('BPR322','BJC-Y3'),
  ('BPR322','BJC-Y3-PR'),
  ('BPR323','BJC-Y3'),
  ('BPR323','BJC-Y3-PR'),
  ('BPR324','BJC-Y3'),
  ('BPR324','BJC-Y3-PR'),
  ('BPR325','BJC-Y3'),
  ('BPR325','BJC-Y3-PR'),
  ('BPR326','BJC-Y3-PR'),
  ('BPR327','BJC-Y3'),
  ('BPR327','BJC-Y3-PR'),
  ('BPR329','BJC-Y3'),
  ('BPR329','BJC-Y3-PR'),
  ('BSE111','BDA-Y1'),
  ('BSE111','BDSA-Y1'),
  ('BSE111','BSE-Y1'),
  ('BSE121','BCS-Y1'),
  ('BSE121','BCS-Y2'),
  ('BSE121','BDSA-Y1'),
  ('BSE121','BDSA-Y2'),
  ('BSE121','BIT-Y1'),
  ('BSE121','BSE-Y1'),
  ('BSE121','DDA-Y1'),
  ('BSE121','DDSA-Y1'),
  ('BSE121','DDSA-Y2'),
  ('BSE121','DIT-Y1'),
  ('BSE212','BCS-Y2'),
  ('BSE212','BIT-Y2'),
  ('BSE212','BSE-Y2'),
  ('BSE213','BCS-Y2'),
  ('BSE213','BIT-Y2'),
  ('BSE213','BSE-Y2'),
  ('BSE213','DCS-Y2'),
  ('BSE213','DIT-Y2'),
  ('BSE221','BSE-Y2'),
  ('BSE222','BDSA-Y2'),
  ('BSE222','BSE-Y2'),
  ('BSE224','BCS-Y2'),
  ('BSE224','BDA-Y1'),
  ('BSE224','BDSA-Y1'),
  ('BSE224','BSE-Y2'),
  ('BSE224','DDA-Y1'),
  ('BSE224','DDSA-Y1'),
  ('BSE226','BSE-Y2'),
  ('BSE311','BCS-Y3'),
  ('BSE311','BIT-Y3'),
  ('BSE311','BSE-Y3'),
  ('BSE314','BDSA-Y2'),
  ('BSE314','BSE-Y3'),
  ('BSE314','DDA-Y1'),
  ('BSE314','DDSA-Y1'),
  ('BSE321','BSE-Y4'),
  ('BSE322','BSE-Y3'),
  ('BSE323','BSE-Y4'),
  ('BSE324','BSE-Y3'),
  ('BSE326','BSE-Y3'),
  ('BSE327','BSE-Y3'),
  ('BSE411','BSE-Y4'),
  ('BSE412','BCS-Y2'),
  ('BSE412','BSE-Y4'),
  ('BSE414','BSE-Y4'),
  ('BSE417','BSE-Y4'),
  ('BSE422','BSE-Y4'),
  ('BSE426','BSE-Y4'),
  ('BSE427','BCS-Y3'),
  ('BSE427','BIT-Y3'),
  ('BSE427','BSE-Y4'),
  ('BSE427','DIT-Y2'),
  ('BSF323','BBA-Y3-BF'),
  ('COM111','BCS-Y1'),
  ('COM113','BCS-Y1'),
  ('COM113','BSE-Y1'),
  ('COM113','DIT-Y1'),
  ('COM122','BCS-Y1'),
  ('COM122','BIT-Y1'),
  ('COM122','BSE-Y1'),
  ('COM122','DIT-Y1'),
  ('COM123','BCS-Y1'),
  ('COM123','BDSA-Y1'),
  ('COM123','BSE-Y1'),
  ('COM123','DDA-Y1'),
  ('COM123','DDSA-Y1'),
  ('COM211','BCS-Y2'),
  ('COM211','BDSA-Y1'),
  ('COM211','BDSA-Y1-ONLINE'),
  ('COM211','BIT-Y2'),
  ('COM211','BSE-Y2'),
  ('COM211','DCS-Y2'),
  ('COM212','BCS-Y2'),
  ('COM212','BDSA-Y2'),
  ('COM212','BSE-Y2'),
  ('COM221','BCS-Y2'),
  ('COM221','BDSA-Y2'),
  ('COM221','BIT-Y2'),
  ('COM221','BSE-Y2'),
  ('COM224','BCS-Y2'),
  ('COM224','BIT-Y2'),
  ('COM224','BSE-Y2'),
  ('COM225','BCS-Y2'),
  ('COM225','BSE-Y4'),
  ('COM311','BCS-Y3'),
  ('COM311','BSE-Y3'),
  ('COM312','BCS-Y3'),
  ('COM312','BSE-Y3'),
  ('COM321','BCS-Y2'),
  ('COM321','BCS-Y3'),
  ('COM321','BDSA-Y2'),
  ('COM321','BSE-Y3'),
  ('COM322','BCS-Y3'),
  ('COM323','BCS-Y3'),
  ('COM324','BCS-Y3'),
  ('COM324','BDSA-Y3'),
  ('COM324','BSE-Y3'),
  ('DBA112','BBA-Y1'),
  ('DBA112','BBA-Y1-AF'),
  ('DBA112','BBA-Y1-BF'),
  ('DBA112','BBA-Y1-ENT'),
  ('DBA112','BBA-Y1-G'),
  ('DBA112','BBA-Y1-HRM'),
  ('DBA112','BBA-Y1-MKT'),
  ('DBA112','BBA-Y1-PL'),
  ('DBA112','BBA-Y1-W'),
  ('DBA112','DBA-Y1'),
  ('DBA113','BBA-Y1'),
  ('DBA113','BBA-Y1-AF'),
  ('DBA113','BBA-Y1-BF'),
  ('DBA113','BBA-Y1-ENT'),
  ('DBA113','BBA-Y1-G'),
  ('DBA113','BBA-Y1-HRM'),
  ('DBA113','BBA-Y1-MKT'),
  ('DBA113','BBA-Y1-PL'),
  ('DBA113','BBA-Y1-W'),
  ('DBA113','DBA-Y1'),
  ('DBA115','BBA-Y1'),
  ('DBA115','DBA-Y1'),
  ('DBA116','BBA-Y1'),
  ('DBA116','BBA-Y1-AF'),
  ('DBA116','BBA-Y1-BF'),
  ('DBA116','BBA-Y1-ENT'),
  ('DBA116','BBA-Y1-G'),
  ('DBA116','BBA-Y1-HRM'),
  ('DBA116','BBA-Y1-MKT'),
  ('DBA116','BBA-Y1-PL'),
  ('DBA116','BBA-Y1-W'),
  ('DBA116','BCS-Y1'),
  ('DBA116','BDA-Y1'),
  ('DBA116','BDSA-Y1'),
  ('DBA116','BIT-Y1'),
  ('DBA116','DBA-Y1'),
  ('DBA116','DDA-Y1'),
  ('DBA116','DDSA-Y1'),
  ('DBA122','BBA-Y1'),
  ('DBA122','BBA-Y1-W'),
  ('DBA122','DBA-Y1'),
  ('DBA124','BBA-Y1'),
  ('DBA124','BBA-Y1-W'),
  ('DBA124','DBA-Y1'),
  ('DBA125','BBA-Y1'),
  ('DBA125','BBA-Y1-W'),
  ('DBA125','DBA-Y1'),
  ('DBA126','DBA-Y1'),
  ('DBA127','BBA-Y1'),
  ('DBA127','BBA-Y1-W'),
  ('DBA127','DBA-Y1'),
  ('DBA128','BBA-Y1'),
  ('DBA128','BBA-Y1-W'),
  ('DBA128','DBA-Y1'),
  ('DBA211','BBA-Y2'),
  ('DBA211','BBA-Y2-W'),
  ('DBA211','DBA-Y2'),
  ('DBA212','BBA-Y3'),
  ('DBA212','BBA-Y3-G'),
  ('DBA212','BIT-Y1'),
  ('DBA212','DBA-Y2'),
  ('DBA213','BBA-Y2'),
  ('DBA213','BBA-Y2-W'),
  ('DBA213','BCS-Y3'),
  ('DBA213','BIT-Y2'),
  ('DBA213','BSE-Y4'),
  ('DBA213','DBA-Y2'),
  ('DBA215','BBA-Y2'),
  ('DBA215','BBA-Y2-W'),
  ('DBA215','BPAM-Y3'),
  ('DBA215','DBA-Y2'),
  ('DBA216','DBA-Y2'),
  ('DBA221','BBA-Y2'),
  ('DBA221','DBA-Y2'),
  ('DBA222','DBA-Y2'),
  ('DBA223','BBA-Y2'),
  ('DBA223','DBA-Y2'),
  ('DCS111','DDA-Y1'),
  ('DCS111','DDSA-Y1'),
  ('DCS111','DIT-Y1'),
  ('DCS112','DIT-Y1'),
  ('DDA1106','BDA-Y1'),
  ('DDA1106','BDSA-Y1'),
  ('DDA1106','DDA-Y1'),
  ('DDA1106','DDSA-Y1'),
  ('DDA1201','BCS-Y1'),
  ('DDA1201','BDSA-Y1'),
  ('DDA1201','BSE-Y1'),
  ('DDA1201','DDA-Y1'),
  ('DDA1201','DDSA-Y1'),
  ('DDA1203','BDSA-Y1'),
  ('DDA1203','DDA-Y1'),
  ('DDA1203','DDSA-Y1'),
  ('DDA1204','BCS-Y1'),
  ('DDA1204','BDSA-Y1'),
  ('DDA1204','BIT-Y1'),
  ('DDA1204','BSE-Y1'),
  ('DDA1204','DDA-Y1'),
  ('DDA1204','DDSA-Y1'),
  ('DDA1204','DIT-Y1'),
  ('DDA1205','DDA-Y1'),
  ('DDA1205','DDSA-Y1'),
  ('DDA1206','BDSA-Y1'),
  ('DDA1206','DDA-Y1'),
  ('DDA1206','DDSA-Y1'),
  ('DDA2102','DDSA-Y2'),
  ('DDA2103','BDSA-Y3'),
  ('DDA2103','DDSA-Y2'),
  ('DDA2201','BDSA-Y2'),
  ('DDA2201','DDSA-Y2'),
  ('DDA2202','BDSA-Y2'),
  ('DDA2202','DDSA-Y2'),
  ('DDA2203','BCS-Y3'),
  ('DDA2203','BIT-Y2'),
  ('DDA2203','DDSA-Y2'),
  ('DDA2203','DIT-Y2'),
  ('DDA2204','DDSA-Y2'),
  ('DDA2206','BDSA-Y2'),
  ('DDA2206','DDSA-Y2'),
  ('DIT110','BBA-Y1'),
  ('DIT110','BBA-Y1-W'),
  ('DIT110','BCS-Y1'),
  ('DIT110','BDSA-Y1'),
  ('DIT110','BEHS-Y1'),
  ('DIT110','BIRDS-Y1'),
  ('DIT110','BIT-Y1'),
  ('DIT110','BJC-Y1'),
  ('DIT110','BPAM-Y1'),
  ('DIT110','BPH-Y1'),
  ('DIT110','BSE-Y1'),
  ('DIT110','DBA-Y1'),
  ('DIT110','DDSA-Y1'),
  ('DIT110','DIT-Y1'),
  ('DIT224','BIT-Y3'),
  ('DIT224','DIT-Y2'),
  ('DJC110','BBA-Y1'),
  ('DJC110','BCS-Y1'),
  ('DJC110','BDSA-Y1'),
  ('DJC110','BEHS-Y1'),
  ('DJC110','BIRDS-Y1'),
  ('DJC110','BIT-Y1'),
  ('DJC110','BJC-Y1'),
  ('DJC110','BPAM-Y1'),
  ('DJC110','BPH-Y1'),
  ('DJC110','BSE-Y1'),
  ('DJC110','DBA-Y1'),
  ('DJC110','DDSA-Y1'),
  ('DJC110','DIT-Y1'),
  ('DPS111','DPL-Y1'),
  ('DPS112','DPL-Y1'),
  ('DPS113','DPL-Y1'),
  ('DPS114','DPL-Y1'),
  ('DPS115','DPL-Y1'),
  ('DPS116','DPL-Y1'),
  ('DPS211','DPL-Y2'),
  ('DPS213','DPL-Y2'),
  ('DPS214','DPL-Y2'),
  ('DPS215','DPL-Y2'),
  ('DPS216','DPL-Y2'),
  ('EHS111','BEHS-Y1'),
  ('EHS112','BEHS-Y1'),
  ('EHS112','BPH-Y1'),
  ('EHS113','BEHS-Y1'),
  ('EHS121','BEHS-Y1'),
  ('EHS121','BPH-Y1'),
  ('EHS122','BEHS-Y1'),
  ('EHS124','BEHS-Y1'),
  ('EHS125','BEHS-Y1'),
  ('EHS212','BEHS-Y2'),
  ('EHS213','BEHS-Y2'),
  ('EHS214','BEHS-Y2'),
  ('EHS214','BPH-Y2'),
  ('EHS215','BEHS-Y2'),
  ('EHS216','BEHS-Y2'),
  ('EHS221','BEHS-Y2'),
  ('EHS222','BEHS-Y2'),
  ('EHS223','BEHS-Y2'),
  ('EHS223','BPH-Y2'),
  ('EHS223','DDA-Y1'),
  ('EHS224','BEHS-Y2'),
  ('EHS225','BEHS-Y2'),
  ('EHS312','BEHS-Y3'),
  ('EHS313','BEHS-Y3'),
  ('EHS313','BPH-Y3'),
  ('EHS314','BEHS-Y3'),
  ('EHS315','BEHS-Y3'),
  ('EHS316','BEHS-Y3'),
  ('EHS321','BEHS-Y3'),
  ('EHS322','BEHS-Y3'),
  ('EHS322','BPH-Y3'),
  ('EHS323','BEHS-Y3'),
  ('EHS323','BPH-Y3'),
  ('ENT312','BBA-Y3'),
  ('FOA120','HEC-Y1'),
  ('FOA121','HEC-Y1'),
  ('FOA122','BPAM-Y2'),
  ('FOA122','HEC-Y1'),
  ('FOA123','HEC-Y1'),
  ('FOA124','BIRDS-Y1'),
  ('FOA124','BJC-Y1'),
  ('FOA124','BPAM-Y1'),
  ('FOA124','HEC-Y1'),
  ('FOA124','HEC-Y1-A'),
  ('FOS111','HEC-Y1'),
  ('FOS112','HEC-Y1'),
  ('FOS125','HEC-Y1'),
  ('FOS126','HEC-Y1'),
  ('FOS127','HEC-Y1'),
  ('FOU110','HEC-Y1'),
  ('FOU112','HEC-Y1'),
  ('FOU113','HEC-Y1'),
  ('FOU114','HEC-Y1'),
  ('HEC111','HEC-Y1'),
  ('HEC112','HEC-Y1'),
  ('HEC113','HEC-Y1'),
  ('HEC115','HEC-Y1'),
  ('HEC122','HEC-Y1'),
  ('HEC123','HEC-Y1'),
  ('HEC124','HEC-Y1'),
  ('HEC125','HEC-Y1'),
  ('HEC126','HEC-Y1'),
  ('HEC128','HEC-Y1'),
  ('HRM311','BBA-Y3'),
  ('HRM311','BBA-Y3-HRM'),
  ('HRM312','BBA-Y3'),
  ('HRM312','BBA-Y3-HRM'),
  ('HRM313','BBA-Y3'),
  ('HRM313','BBA-Y3-HRM'),
  ('HRM314','BBA-Y3'),
  ('HRM314','BBA-Y3-HRM'),
  ('HRM315','BBA-Y3'),
  ('HRM315','BBA-Y3-HRM'),
  ('HRM316','BBA-Y3'),
  ('HRM316','BBA-Y3-G'),
  ('HRM316','BBA-Y3-HRM'),
  ('HRM321','BBA-Y3'),
  ('HRM321','BBA-Y3-HRM'),
  ('HRM322','BBA-Y3'),
  ('HRM322','BBA-Y3-HRM'),
  ('HRM323','BBA-Y3'),
  ('HRM323','BBA-Y3-HRM'),
  ('HRM325','BBA-Y3'),
  ('HRM325','BBA-Y3-HRM'),
  ('HRM325','BPAM-Y1'),
  ('IRDS111','BIRDS-Y1'),
  ('IRDS112','BIRDS-Y1'),
  ('IRDS114','BIRDS-Y1'),
  ('IRDS121','BIRDS-Y1'),
  ('IRDS121','BJC-Y1'),
  ('IRDS121','BPAM-Y1'),
  ('IRDS121','HEC-Y1'),
  ('IRDS121','HEC-Y1-A'),
  ('IRDS122','BIRDS-Y1'),
  ('IRDS122','BPAM-Y2'),
  ('IRDS124','BIRDS-Y1'),
  ('IRDS125','BIRDS-Y1'),
  ('IRDS125','BPAM-Y1'),
  ('IRDS128','BIRDS-Y1'),
  ('IRDS129','BIRDS-Y1'),
  ('IRDS211','BIRDS-Y2'),
  ('IRDS213','BIRDS-Y2'),
  ('IRDS213','BPAM-Y1'),
  ('IRDS214','BIRDS-Y2'),
  ('IRDS214','BPAM-Y2'),
  ('IRDS215','BIRDS-Y2'),
  ('IRDS216','BIRDS-Y2'),
  ('IRDS217','BIRDS-Y2'),
  ('IRDS222','BIRDS-Y2'),
  ('IRDS223','BIRDS-Y2'),
  ('IRDS224','BIRDS-Y2'),
  ('IRDS225','BIRDS-Y2'),
  ('IRDS227','BIRDS-Y2'),
  ('IRDS311','BIRDS-Y3'),
  ('IRDS311','BPAM-Y3'),
  ('IRDS312','BIRDS-Y3'),
  ('IRDS313','BIRDS-Y3'),
  ('IRDS314','BIRDS-Y3'),
  ('IRDS315','BIRDS-Y3'),
  ('IRDS316','BIRDS-Y3'),
  ('IRDS317','BIRDS-Y3'),
  ('IRDS321','BIRDS-Y3'),
  ('IRDS322','BIRDS-Y3'),
  ('IRDS323','BIRDS-Y3'),
  ('IRDS324','BIRDS-Y3'),
  ('IRDS325','BIRDS-Y3'),
  ('LLB111','LLB-Y1'),
  ('LLB112','LLB-Y1'),
  ('LLB113','LLB-Y1'),
  ('LLB114','LLB-Y1'),
  ('LLB115','LLB-Y1'),
  ('LLB121','LLB-Y1'),
  ('LLB122','LLB-Y1'),
  ('LLB123','LLB-Y1'),
  ('LLB124','LLB-Y1'),
  ('LLB125','LLB-Y1'),
  ('LLB211','LLB-Y2'),
  ('LLB212','LLB-Y2'),
  ('LLB213','LLB-Y2'),
  ('LLB214','LLB-Y2'),
  ('LLB215','LLB-Y2'),
  ('LLB221','LLB-Y2'),
  ('LLB222','LLB-Y2'),
  ('LLB223','LLB-Y2'),
  ('LLB224','LLB-Y2'),
  ('LLB225','LLB-Y2'),
  ('LLB311','LLB-Y3'),
  ('LLB312','LLB-Y3'),
  ('LLB313','LLB-Y3'),
  ('LLB314','LLB-Y3'),
  ('LLB315','LLB-Y3'),
  ('LLB322','LLB-Y3'),
  ('LLB323','LLB-Y3'),
  ('LLB324','LLB-Y3'),
  ('LLB325','LLB-Y3'),
  ('LLB327','LLB-Y3'),
  ('LLB411','LLB-Y4'),
  ('LLB412','LLB-Y4'),
  ('LLB413','LLB-Y4'),
  ('LLB414','LLB-Y4'),
  ('LLB416','LLB-Y4'),
  ('LLB421','LLB-Y4'),
  ('LLB422','LLB-Y4'),
  ('LLB424','LLB-Y4'),
  ('LLB426','LLB-Y4'),
  ('LLM711','LLM-Y1'),
  ('LLM712','LLM-Y1'),
  ('LLM713','LLM-Y1'),
  ('LLM714','LLM-Y1'),
  ('LLM715','LLM-Y1'),
  ('LLM716','LLM-Y1'),
  ('LLM717','LLM-Y1'),
  ('LLM718','LLM-Y1'),
  ('LLM721','LLM-Y1'),
  ('LLM7210','LLM-Y1'),
  ('LLM7211','LLM-Y1'),
  ('LLM722','LLM-Y1'),
  ('LLM725','LLM-Y1'),
  ('LLM726','LLM-Y1'),
  ('LLM727','LLM-Y1'),
  ('LLM729','LLM-Y1'),
  ('LLM811','LLM-Y1'),
  ('LLM812','LLM-Y1'),
  ('LLM813','LLM-Y1'),
  ('LLM814','LLM-Y1'),
  ('LLM817','LLM-Y1'),
  ('LLM818','LLM-Y1'),
  ('MBA710','MBA-Y1'),
  ('MBA710','MED-Y1'),
  ('MBA710','MEM-Y1'),
  ('MBA710','MPM-Y1'),
  ('MBA711','MBA-Y1'),
  ('MBA711','MPH-Y1'),
  ('MBA711','MPM-Y1'),
  ('MBA712','MBA-Y1'),
  ('MBA712','MPM-Y1'),
  ('MBA716','MBA-Y1'),
  ('MBA716','MPM-Y1'),
  ('MBA721','MBA-Y1'),
  ('MBA724','MPM-Y2'),
  ('MBA725','MBA-Y1'),
  ('MBA726','MBA-Y1'),
  ('MBA727','MBA-Y1-HRM'),
  ('MBA727','MBA-Y2'),
  ('MBA727','MED-Y2'),
  ('MBA727','MEM-Y2'),
  ('MBA727','MPM-Y1'),
  ('MBA728','MBA-Y1'),
  ('MBA728','MED-Y1'),
  ('MBA728','MEM-Y1'),
  ('MBA728','MIRDS-Y1'),
  ('MBA728','MIT-Y1'),
  ('MBA728','MPM-Y1'),
  ('MBA728','MSS-Y1'),
  ('MBA729','MBA-Y1'),
  ('MBA729','MED-Y1'),
  ('MBA729','MEM-Y1'),
  ('MBA729','MIT-Y1'),
  ('MBA729','MPM-Y1'),
  ('MBA811','MBA-Y1-M'),
  ('MBA811','MBA-Y2'),
  ('MBA811','MBA-Y2-M'),
  ('MBA813','MBA-Y1-M'),
  ('MBA813','MBA-Y2'),
  ('MBA813','MPM-Y2'),
  ('MBA815','MBA-Y1-M'),
  ('MBA815','MBA-Y2'),
  ('MBA815','MBA-Y2-M'),
  ('MBF811','MBA-Y1-AF'),
  ('MBF811','MBA-Y2'),
  ('MBF811','MBA-Y2-AF'),
  ('MBF813','MBA-Y1-AF'),
  ('MBF813','MBA-Y1-M'),
  ('MBF813','MBA-Y2'),
  ('MBF813','MBA-Y2-M'),
  ('MBF815','MBA-Y1-AF'),
  ('MBF815','MBA-Y2'),
  ('MBF815','MBA-Y2-AF'),
  ('MBF816','MBA-Y1-AF'),
  ('MBF816','MBA-Y1-M'),
  ('MBF816','MBA-Y2'),
  ('MBF816','MBA-Y2-M'),
  ('MBF817','MBA-Y1-AF'),
  ('MBF817','MBA-Y2'),
  ('MBF817','MBA-Y2-AF'),
  ('MED713','MED-Y1'),
  ('MED713','MED-Y1-ONLINE'),
  ('MED713','MEM-Y1'),
  ('MED714','MED-Y1'),
  ('MED714','MED-Y1-ONLINE'),
  ('MED714','MEM-Y1'),
  ('MED721','MED-Y1'),
  ('MED721','MED-Y1-ONLINE'),
  ('MED721','MEM-Y1'),
  ('MED722','MED-Y1'),
  ('MED722','MED-Y1-ONLINE'),
  ('MED722','MEM-Y1'),
  ('MED723','MED-Y1'),
  ('MED723','MED-Y1-ONLINE'),
  ('MED723','MEM-Y1'),
  ('MED812','MED-Y2'),
  ('MED812','MED-Y2-ONLINE'),
  ('MED812','MEM-Y2'),
  ('MED813','MED-Y2'),
  ('MED813','MED-Y2-ONLINE'),
  ('MED813','MEM-Y2'),
  ('MHR722','MBA-Y1-HRM'),
  ('MHR722','MBA-Y2'),
  ('MHR722','MED-Y2'),
  ('MHR722','MEM-Y2'),
  ('MHR722','MIT-Y1'),
  ('MHR811','MBA-Y1-HRM'),
  ('MHR811','MBA-Y2'),
  ('MHR811','MBA-Y2-HRM'),
  ('MHR814','MBA-Y1-HRM'),
  ('MHR814','MBA-Y2'),
  ('MHR814','MED-Y2'),
  ('MHR814','MEM-Y2'),
  ('MHR815','MBA-Y1-HRM'),
  ('MHR815','MBA-Y2'),
  ('MHR815','MBA-Y2-HRM'),
  ('MIR711','MIRDS-Y1'),
  ('MIR711','MSS-Y1'),
  ('MIR712','MIRDS-Y1'),
  ('MIR714','LLM-Y1'),
  ('MIR714','MIRDS-Y1'),
  ('MIR715','MIRDS-Y1'),
  ('MIR721','MIRDS-Y1'),
  ('MIR721','MIRDS-Y1-ONLINE'),
  ('MIR722','MIRDS-Y1'),
  ('MIR723','MIRDS-Y1'),
  ('MIR724','MIRDS-Y1'),
  ('MIR811','MIRDS-Y2'),
  ('MIR811','MSS-Y2'),
  ('MIR812','MIRDS-Y2'),
  ('MIR814','MIRDS-Y2'),
  ('MIT712','MIT-Y1'),
  ('MIT712','MIT-Y1-ONLINE'),
  ('MIT715','MIT-Y1'),
  ('MIT715','MIT-Y1-ONLINE'),
  ('MIT716','MIT-Y1'),
  ('MIT716','MIT-Y1-ONLINE'),
  ('MIT717','MIT-Y1'),
  ('MIT717','MIT-Y1-ONLINE'),
  ('MIT718','MIT-Y1'),
  ('MIT718','MIT-Y1-ONLINE'),
  ('MIT721','MIT-Y2'),
  ('MIT721','MIT-Y2-ONLINE'),
  ('MIT722','MIT-Y2'),
  ('MIT722','MIT-Y2-ONLINE'),
  ('MIT723','MIT-Y2'),
  ('MIT723','MIT-Y2-ONLINE'),
  ('MIT725','MIT-Y1'),
  ('MIT725','MIT-Y1-ONLINE'),
  ('MIT727','MIT-Y1'),
  ('MIT727','MIT-Y1-ONLINE'),
  ('MIT728','MIT-Y1'),
  ('MIT728','MIT-Y1-ONLINE'),
  ('MIT729','MIT-Y1'),
  ('MIT729','MIT-Y1-ONLINE'),
  ('MIT821','MIT-Y2'),
  ('MIT821','MIT-Y2-ONLINE'),
  ('MIT822','MIT-Y2'),
  ('MIT822','MIT-Y2-ONLINE'),
  ('MIT823','MIT-Y2'),
  ('MIT823','MIT-Y2-ONLINE'),
  ('MKT311','BBA-Y3'),
  ('MKT312','BBA-Y3'),
  ('MKT313','BBA-Y3'),
  ('MKT322','BBA-Y3'),
  ('MKT323','BBA-Y3'),
  ('MKT325','BBA-Y3'),
  ('MPH713','MPH-Y1'),
  ('MPH714','MPH-Y1'),
  ('MPH714','MPH-Y1-ONLINE'),
  ('MPH715','MPH-Y1'),
  ('MPH716','MPH-Y1'),
  ('MPH721','MPH-Y1'),
  ('MPH721','MPH-Y1-ONLINE'),
  ('MPH722','MPH-Y1'),
  ('MPH722','MPH-Y1-ONLINE'),
  ('MPH724','MPH-Y1'),
  ('MPH724','MPH-Y1-ONLINE'),
  ('MPH725','MPH-Y1'),
  ('MPH726','MPH-Y1'),
  ('MPH726','MPH-Y2'),
  ('MPH726','MPH-Y2-ONLINE'),
  ('MPH727','MPH-Y1'),
  ('MPH727','MPH-Y2'),
  ('MPH810','MPH-Y2'),
  ('MPH812','MPH-Y1'),
  ('MPH812','MPH-Y1-ONLINE'),
  ('MPH812','MPH-Y2'),
  ('MPH813','MPH-Y2'),
  ('MPH814','MPH-Y2'),
  ('MPH815','MPH-Y1'),
  ('MPH815','MPH-Y2'),
  ('MPH816','MPH-Y2'),
  ('MPH817','MPH-Y2'),
  ('MPH818','MPH-Y2'),
  ('MPH819','MPH-Y2'),
  ('MPH825','MPH-Y2'),
  ('MPH826','MPH-Y2'),
  ('MPH827','MPH-Y2'),
  ('MPH828','MPH-Y2'),
  ('MPH829','MPH-Y2'),
  ('MPH835','MPH-Y2'),
  ('MPH836','MPH-Y2'),
  ('MPH837','MPH-Y2'),
  ('MPH838','MPH-Y2'),
  ('MPH839','MPH-Y2'),
  ('MPH840','MPH-Y2'),
  ('MPM715','MBA-Y1'),
  ('MPM715','MPH-Y1'),
  ('MPM715','MPM-Y1'),
  ('MPM720','MED-Y1'),
  ('MPM720','MEM-Y1'),
  ('MPM720','MPM-Y1'),
  ('MPM721','MPM-Y1'),
  ('MPM722','MBA-Y1-PS'),
  ('MPM722','MBA-Y2'),
  ('MPM722','MPM-Y1'),
  ('MPM811','MPM-Y2'),
  ('MPM813','MPM-Y2'),
  ('MPM814','MPM-Y2'),
  ('MSC720','MBA-Y1-PS'),
  ('MSC720','MBA-Y2'),
  ('MSC720','MBA-Y2-PS'),
  ('MSC721','MBA-Y1-PS'),
  ('MSC721','MBA-Y2'),
  ('MSC721','MBA-Y2-PS'),
  ('MSC722','MBA-Y1-PS'),
  ('MSC722','MBA-Y2'),
  ('MSC722','MPM-Y1'),
  ('MSC810','MBA-Y1-PS'),
  ('MSC810','MBA-Y2'),
  ('MSC810','MBA-Y2-PS'),
  ('MSC814','MBA-Y1-PS'),
  ('MSC814','MBA-Y2'),
  ('MSC814','MBA-Y2-PS'),
  ('MSS712','MIRDS-Y1'),
  ('MSS712','MSS-Y1'),
  ('MSS714','MSS-Y1'),
  ('MSS716','MSS-Y1'),
  ('MSS721','MSS-Y1'),
  ('MSS722','MSS-Y1'),
  ('MSS723','MSS-Y1'),
  ('MSS724','MIRDS-Y2'),
  ('MSS724','MSS-Y1'),
  ('MSS725','MSS-Y1'),
  ('MSS810','MSS-Y2'),
  ('MSS811','MSS-Y2'),
  ('MSS811','MSS-Y2-ONLINE'),
  ('MSS812','MIRDS-Y2'),
  ('MSS812','MSS-Y2'),
  ('MSS813','MIRDS-Y2'),
  ('MSS813','MSS-Y2'),
  ('MSS814','MSS-Y2'),
  ('NGO316','BPAM-Y2'),
  ('PLM311','BBA-Y1'),
  ('PLM311','BBA-Y1-W'),
  ('PLM314','BBA-Y3'),
  ('PLM314','BBA-Y3-G'),
  ('PLM314','BBA-Y3-PL'),
  ('PLM315','BBA-Y3'),
  ('PLM315','BBA-Y3-PL'),
  ('PLM316','BBA-Y3'),
  ('PLM316','BBA-Y3-PL'),
  ('PLM317','BBA-Y3'),
  ('PLM317','BBA-Y3-PL'),
  ('PLM317','BPAM-Y3'),
  ('PLM318','BBA-Y3'),
  ('PLM318','BBA-Y3-PL'),
  ('PLM319','BBA-Y3'),
  ('PLM319','BBA-Y3-PL'),
  ('PLM321','BBA-Y3-PL'),
  ('PLM322','BBA-Y3'),
  ('PLM322','BBA-Y3-PL'),
  ('PLM323','BBA-Y3-PL'),
  ('PLM324','BBA-Y3'),
  ('PLM324','BBA-Y3-PL'),
  ('PLM325','BBA-Y3-PL'),
  ('PLM325','BPAM-Y3'),
  ('PLM326','BBA-Y3'),
  ('PLM326','BBA-Y3-PL'),
  ('PLM327','BBA-Y3'),
  ('PLM327','BBA-Y3-PL'),
  ('PLM328','BBA-Y3'),
  ('PLM328','BBA-Y3-PL'),
  ('RSC001','BBA-Y2'),
  ('RSC001','BBA-Y2-W'),
  ('RSC001','BEHS-Y2'),
  ('RSC001','BIRDS-Y2'),
  ('RSC001','BJC-Y2'),
  ('RSC001','BPAM-Y2'),
  ('RSC001','BPH-Y1'),
  ('RSC001','BPH-Y2'),
  ('RSC001','DBA-Y2'),
  ('RSC001','DDA-Y1'),
  ('RSC003','MBA-Y1'),
  ('RSC003','MED-Y1'),
  ('RSC003','MEM-Y1'),
  ('RSC003','MIRDS-Y1'),
  ('RSC003','MPM-Y1'),
  ('RSC003','MSS-Y1')
) AS p(module_code,class_code)
CROSS JOIN (SELECT id FROM semesters WHERE name = 'Semester I 2026/2027') s
JOIN modules m ON m.code = p.module_code
JOIN classes c ON c.code = p.class_code
ON CONFLICT (class_id,module_id,semester_id) DO NOTHING;

-- Timetable slots: expand each weekly pattern across the teaching period
INSERT INTO timetable_slots (id,semester_id,class_id,module_id,lecturer_id,facility_id,start_at,end_at,session_mode)
SELECT md5(concat_ws('|', p.module_code, p.class_code, (w.week_start + (p.day_num - 1))::text, p.start_time::text, p.room_code))::uuid,
       s.id, c.id, m.id, u.id, f.id, t.start_at, t.end_at, p.session_mode
FROM (VALUES
  ('ADHM1101',NULL,'MKN-05','e.nanyonjo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('ADHM1101','ADHM-Y1','MKN-05','e.nanyonjo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('ADHM1101','ADHM-Y1','MKN-16','e.nanyonjo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('ADHM1102',NULL,'MKN-18','e.namakula@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('ADHM1102','ADHM-Y1','MKN-16','btusingwire@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('ADHM1102','ADHM-Y1','MKN-18','btusingwire@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('ADHM1103',NULL,'SI-212','eric.omonyi@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('ADHM1103','ADHM-Y1','MKN-16','bkwesiga@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('ADHM1103','ADHM-Y1','SI-212','bkwesiga@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('ADHM1104',NULL,'SI-212','swafula@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('ADHM1104','ADHM-Y1','SI-212','d.nsubuga@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('ADHM1104','ADHM-Y1','MKN-16','d.nsubuga@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('ADHM1105',NULL,'SI-011','eric.omonyi@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('ADHM1105','ADHM-Y1','MKN-15','b.nabaasa@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('ADHM1105','ADHM-Y1','MKN-16','b.nabaasa@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('ADHM1106',NULL,'MKN-14','k.namajja@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('ADHM1106','ADHM-Y1','MKN-14','k.namajja@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('ADHM1106','ADHM-Y1','MKN-16','k.namajja@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('ADHM1106','BPH-Y3','MKN-17','k.namajja@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('ADHM1201',NULL,'MKN-05','i.mugumya@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('ADHM1201','ADHM-Y1','MKN-05','i.mugumya@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('ADHM1201','ADHM-Y1','MKN-17','i.mugumya@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('ADHM1202',NULL,'MKN-18','swafula@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('ADHM1202','ADHM-Y1','MKN-17','m.taibu@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('ADHM1202','ADHM-Y1','MKN-18','m.taibu@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('ADHM1203',NULL,'MKN-05','eric.omonyi@cavendish.ac.ug',6,'14:30'::time,'16:45'::time,'hybrid'),
  ('ADHM1203','ADHM-Y1','MKN-05','b.nabaasa@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'hybrid'),
  ('ADHM1203','ADHM-Y1','MKN-17','b.nabaasa@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('ADHM1204',NULL,'MKN-05','swafula@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'hybrid'),
  ('ADHM1204','ADHM-Y1','MKN-05','bkwesiga@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'hybrid'),
  ('ADHM1204','ADHM-Y1','MKN-17','bkwesiga@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('ADHM1205',NULL,'MKN-05','eric.omonyi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'hybrid'),
  ('ADHM1205','ADHM-Y1','MKN-05','m.taibu@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'hybrid'),
  ('ADHM1205','ADHM-Y1','MKN-17','m.taibu@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('ADHM1206',NULL,'MKN-05','swafula@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'hybrid'),
  ('ADHM1206','ADHM-Y1','MKN-05','b.nabaasa@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'hybrid'),
  ('ADHM1206','ADHM-Y1','MKN-17','b.nabaasa@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('AGM212','BBA-Y2-W','KG-15','jsambaga@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('AGM212','BBA-Y2','KG-15','jsambaga@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('AGM212','BBA-Y2','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('AGM212','BBA-Y2','KG-14','dkatongole@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('AGM212','BBA-Y2','KG-15','dkatongole@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('AGM212','BCS-Y3','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('AGM212','BIT-Y2','KG-15','jsambaga@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('AGM212','BIT-Y2','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('AGM212','BSE-Y4','KG-15','jsambaga@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('AGM212','BSE-Y4','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('AGM212','DBA-Y2','KG-15','jsambaga@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('AGM212','DBA-Y2','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BAC215','BBA-Y2-W','KG-11','rbisaso@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BAC215','BBA-Y2','KG-14','d.mpubani@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BAC215','BBA-Y2','KG-15','rbisaso@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BAC215','BBA-Y2','KG-11','d.mpubani@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BAC215','DBA-Y2','KG-14','d.mpubani@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BAC313','BBA-Y3-AF','KG-11','dkalembe@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('BAC313','BBA-Y3-AF','SI-105','dkalembe@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BAC313','BBA-Y3','KG-9','dkalembe@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BAC313','BBA-Y3','KG-10','dkalembe@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BAC314','BBA-Y3-AF','KG-13','rbisaso@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BAC314','BBA-Y3-AF','KG-6','rbisaso@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BAC314','BBA-Y3','SI-105','jbaleke@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BAC314','BBA-Y3','KG-6','jbaleke@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('BAC316','BBA-Y3-AF','KG-9','d.mpubani@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BAC316','BBA-Y3-AF','KG-7','d.mpubani@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BAC316','BBA-Y3-BF','KG-9','d.mpubani@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BAC316','BBA-Y3-BF','KG-7','d.mpubani@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BAC316','BBA-Y3','SI-214','d.mpubani@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BAC316','BBA-Y3','SI-214','d.mpubani@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BAC321','BBA-Y3-AF','KG-13','d.mpubani@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BAC321','BBA-Y3-AF','KG-13','d.mpubani@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BAC321','BBA-Y3-BF','KG-13','d.mpubani@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BAC321','BBA-Y3-BF','KG-13','d.mpubani@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BAC321','BBA-Y3','KG-13','d.mpubani@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BAC321','BBA-Y3','KG-13','d.mpubani@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BAC322','BBA-Y3-AF','KG-14','fahabyoona@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BAC322','BBA-Y3-AF','KG-14','fahabyoona@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('BAC322','BBA-Y3','KG-6','fahabyoona@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BAC322','BBA-Y3','KG-6','fahabyoona@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('BAC326','BBA-Y3-AF','KG-6','cmakwasi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BAC326','BBA-Y3-AF','KG-7','cmakwasi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BAC326','BBA-Y3','KG-7','cmakwasi@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BAC326','BBA-Y3','KG-7','cmakwasi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BAC327','BBA-Y3-AF','KG-11','jbaleke@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BAC327','BBA-Y3-AF','SI-205','jbaleke@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BAC327','BBA-Y3','KG-7','jbaleke@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BAC327','BBA-Y3','SI-205','jbaleke@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BBA112','BBA-Y1-AF','KG-15','dkatongole@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BBA112','BBA-Y1-BF','KG-15','dkatongole@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BBA112','BBA-Y1-ENT','KG-15','dkatongole@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BBA112','BBA-Y1-G','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA112','BBA-Y1-HRM','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA112','BBA-Y1-MKT','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA112','BBA-Y1-PL','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA112','BBA-Y1-W','KG-14','dkatongole@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BBA112','BBA-Y1','KG-15','snamazzi@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BBA112','BBA-Y1','KG-14','snamazzi@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('BBA112','DBA-Y1','KG-15','dkatongole@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BBA112','DBA-Y1','KG-15','snamazzi@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BBA113','BBA-Y1-AF','KG-14','d.bakyayita@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA113','BBA-Y1-BF','KG-14','d.bakyayita@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA113','BBA-Y1-ENT','KG-14','d.bakyayita@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA113','BBA-Y1-G','KG-14','d.bakyayita@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA113','BBA-Y1-HRM','KG-14','d.bakyayita@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA113','BBA-Y1-MKT','KG-14','d.bakyayita@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA113','BBA-Y1-PL','KG-14','d.bakyayita@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA113','BBA-Y1-W','KG-15','d.bakyayita@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA113','BBA-Y1','KG-14','d.bakyayita@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA113','BBA-Y1','KG-15','d.bakyayita@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA113','DBA-Y1','KG-14','d.bakyayita@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA115','BBA-Y1-AF','KG-15','dkalembe@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BBA115','BBA-Y1-BF','KG-15','dkalembe@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BBA115','BBA-Y1-ENT','KG-15','dkalembe@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BBA115','BBA-Y1-G','KG-15','dkalembe@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBA115','BBA-Y1-HRM','KG-15','dkalembe@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBA115','BBA-Y1-MKT','KG-15','dkalembe@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBA115','BBA-Y1-PL','KG-15','dkalembe@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBA115','BBA-Y1-W','KG-15','dkalembe@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('BBA115','BBA-Y1','KG-15','dkalembe@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA115','BBA-Y1','KG-15','dkalembe@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('BBA115','DBA-Y1','KG-15','dkalembe@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BBA115','DBA-Y1','KG-15','dkalembe@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA116','BBA-Y1-AF','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBA116','BBA-Y1-BF','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBA116','BBA-Y1-ENT','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBA116','BBA-Y1-G','KG-15','m.kawiso@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BBA116','BBA-Y1-HRM','KG-15','m.kawiso@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BBA116','BBA-Y1-MKT','KG-15','m.kawiso@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BBA116','BBA-Y1-PL','KG-15','m.kawiso@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BBA116','BBA-Y1-W','KG-15','m.kawiso@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BBA116','BBA-Y1','KG-15','m.kawiso@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BBA116','BBA-Y1','KG-15','m.kawiso@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BBA116','BCS-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBA116','BCS-Y1','KG-15','m.kawiso@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBA116','BDA-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBA116','BDSA-Y1','KG-15','m.kawiso@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBA116','BDSA-Y1','KG-15','m.kawiso@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BBA116','BIT-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBA116','BIT-Y1','KG-15','m.kawiso@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBA116','DBA-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBA116','DBA-Y1','KG-15','m.kawiso@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BBA116','DDA-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BBA116','DDSA-Y1','KG-15','m.kawiso@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBA116','DDSA-Y1','KG-15','m.kawiso@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BBA122','BBA-Y1-W','KG-13','m.kawiso@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BBA122','BBA-Y1','SI-112','mr.robert.ateng@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BBA122','BBA-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BBA122','BBA-Y1','KG-13','mr.robert.ateng@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA122','BBA-Y1','KG-9','mr.robert.ateng@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA122','DBA-Y1','SI-112','mr.robert.ateng@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BBA122','DBA-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BBA123','BBA-Y1-W','KG-14','snamazzi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('BBA123','BBA-Y1','SI-B01','dr.wilberforce.tindyebwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBA123','BBA-Y1','KG-14','snamazzi@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BBA123','BBA-Y1','SI-105','dr.wilberforce.tindyebwa@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BBA123','DBA-Y1','SI-B01','dr.wilberforce.tindyebwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBA123','DBA-Y1','KG-14','snamazzi@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BBA124','BBA-Y1-W','KG-14','ykatono@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BBA124','BBA-Y1','KG-14','ms.noam.everlyn.abenakyo@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBA124','BBA-Y1','KG-15','ykatono@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BBA124','BBA-Y1','KG-14','ms.noam.everlyn.abenakyo@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BBA124','DBA-Y1','KG-14','ms.noam.everlyn.abenakyo@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBA124','DBA-Y1','KG-15','ykatono@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BBA125','BBA-Y1-W','KG-14','rkabuye@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BBA125','BBA-Y1','KG-15','rkabuye@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BBA125','BBA-Y1','KG-14','rkabuye@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BBA125','DBA-Y1','KG-15','rkabuye@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BBA211','BBA-Y2-W','KG-13','d.mpubani@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BBA211','BBA-Y2','KG-14','d.mpubani@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BBA211','BBA-Y2','KG-14','mr.ngabirano.richard@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BBA211','BBA-Y2','KG-13','mr.ngabirano.richard@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA211','BBA-Y2','KG-13','mr.ngabirano.richard@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('BBA211','DBA-Y2','KG-14','d.mpubani@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BBA211','DBA-Y2','KG-14','mr.ngabirano.richard@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BBA212','BBA-Y2-W','KG-15','bnassozi@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BBA212','BBA-Y2','KG-14','bnassozi@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BBA212','BBA-Y2','KG-14','bnassozi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBA212','BBA-Y2','KG-15','bnassozi@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BBA214','BBA-Y2-W','KG-15','jsambaga@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('BBA214','BBA-Y2','KG-15','jsambaga@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA214','BBA-Y2','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA214','BBA-Y2','KG-14','dkatongole@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('BBA214','BBA-Y2','KG-15','dkatongole@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('BBA214','BCS-Y3','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA214','BIT-Y2','KG-15','jsambaga@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA214','BIT-Y2','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA214','BSE-Y4','KG-15','jsambaga@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA214','BSE-Y4','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA214','DBA-Y2','KG-15','jsambaga@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA214','DBA-Y2','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA215','BBA-Y2-W','KG-13','rolar@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BBA215','BBA-Y2','KG-14','rolar@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BBA215','BBA-Y2','KG-14','rolar@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BBA215','BBA-Y2','KG-13','rolar@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BBA215','BPAM-Y3','KG-14','rolar@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BBA215','BPAM-Y3','KG-14','rolar@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BBA215','DBA-Y2','KG-14','rolar@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BBA215','DBA-Y2','KG-14','rolar@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BBA216','BBA-Y2-W','KG-13','bnassozi@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('BBA216','BBA-Y2','KG-14','bnassozi@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BBA216','BBA-Y2','KG-9','dr.mutya.tomasi@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBA216','BBA-Y2','KG-13','dr.mutya.tomasi@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA216','BBA-Y2','KG-13','dr.mutya.tomasi@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('BBA216','DBA-Y2','KG-14','bnassozi@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BBA216','DBA-Y2','KG-9','dr.mutya.tomasi@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBA221','BBA-Y2-W','KG-10','dkatongole@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('BBA221','BBA-Y2','KG-9','dr.shuaib.muhammad.rabiu@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBA221','BBA-Y2','KG-14','dkatongole@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBA221','BBA-Y2','KG-13','dr.shuaib.muhammad.rabiu@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BBA221','BBA-Y2','KG-10','dr.shuaib.muhammad.rabiu@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('BBA223','BBA-Y2-W','KG-10','mturyareeba@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('BBA223','BBA-Y2','KG-9','cmakwasi@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA223','BBA-Y2','KG-14','mturyareeba@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BBA223','BBA-Y2','KG-10',NULL,6,'14:45'::time,'16:45'::time,'physical'),
  ('BBA223','BBA-Y2','KG-6','mr.ngabirano.richard@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('BBA223','DBA-Y2','KG-9','cmakwasi@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA224','BBA-Y2-W','KG-14','jmwesigye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA224','BBA-Y2','KG-14','jmwesigye@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BBA224','BBA-Y2','KG-14','jmwesigye@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BBA224','BBA-Y2','KG-14','jmwesigye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA311','BBA-Y1-W','KG-14','snamazzi@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BBA311','BBA-Y1','KG-14','mr.robert.ateng@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('BBA311','BBA-Y1','KG-15','snamazzi@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BBA311','BBA-Y1','KG-14','mr.robert.ateng@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BBA311','DBA-Y1','KG-14','mr.robert.ateng@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('BBA311','DBA-Y1','KG-15','snamazzi@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BBA313',NULL,'KG-6','m.kawiso@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA313','BBA-Y3-G','KG-6','m.kawiso@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA313','BBA-Y3-G','KG-6','dkatongole@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA313','BBA-Y3','KG-9','dkatongole@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BBA313','BBA-Y3','KG-6','dkatongole@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BBA314','BBA-Y3-AF','KG-9','htugume@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA314','BBA-Y3-AF','KG-9','htugume@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BBA314','BBA-Y3-BF','KG-9','htugume@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA314','BBA-Y3-BF','KG-9','htugume@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BBA314','BBA-Y3-G','KG-9','htugume@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA314','BBA-Y3-G','KG-9','htugume@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BBA314','BBA-Y3','KG-13','dr.mutya.tomasi@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BBA314','BBA-Y3','KG-10','dr.mutya.tomasi@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BBA315',NULL,'KG-7','ykatono@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('BBA315','BBA-Y3-G','KG-9','ykatono@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BBA315','BBA-Y3-G','KG-7','ykatono@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BBA315','BBA-Y3','KG-9','ykatono@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BBA315','BBA-Y3','KG-7','ykatono@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BBA317','BBA-Y3-AF','KG-11','jbaleke@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA317','BBA-Y3-AF','KG-10','jbaleke@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA317','BBA-Y3','KG-9','jbaleke@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BBA317','BBA-Y3','KG-10','jbaleke@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA322',NULL,'KG-7','snamazzi@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BBA322','BBA-Y3-G','KG-13','snamazzi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BBA322','BBA-Y3-G','KG-7','snamazzi@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BBA322','BBA-Y3-HRM','KG-13','snamazzi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BBA322','BBA-Y3','KG-10','snamazzi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BBA322','BBA-Y3','KG-7','snamazzi@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BBA322','BPAM-Y3','KG-10','snamazzi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BBA322','BPAM-Y3','KG-13','snamazzi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BBA322','BPH-Y3','KG-13','snamazzi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BBA322','BPH-Y3','MKN-15','bkwesiga@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BBA323',NULL,'KG-7','dkatongole@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BBA323','BBA-Y3-G','KG-7','dkatongole@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BBA323','BBA-Y3-G','KG-7','dkatongole@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('BBA323','BBA-Y3','KG-10','dkatongole@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BBA323','BBA-Y3','KG-7','dkatongole@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('BBA324',NULL,'KG-6','snamazzi@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA324','BBA-Y3-G','KG-11','snamazzi@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BBA324','BBA-Y3-G','KG-6',NULL,7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA324','BBA-Y3-HRM','KG-11','snamazzi@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BBA324','BBA-Y3-HRM','KG-6',NULL,7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA324','BBA-Y3','SI-105','ambabazi@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBA324','BBA-Y3','KG-6','ambabazi@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBA324','BPAM-Y2','SI-105','ambabazi@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BBF222','BBA-Y2-W','KG-10','cmakwasi@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('BBF222','BBA-Y2','KG-10','cmakwasi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BBF222','BBA-Y2','KG-9','cmakwasi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BBF222','BBA-Y2','KG-10','cmakwasi@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBF222','BBA-Y2','KG-10','cmakwasi@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('BBF311','BBA-Y3-BF','KG-10','rbisaso@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BBF311','BBA-Y3','KG-11','dr.mutya.tomasi@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BBF313','BBA-Y3-BF','KG-7','dkalembe@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BBF313','BBA-Y3-BF','SI-105','dkalembe@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BBF313','BBA-Y3','KG-7','dkalembe@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BBF315','BBA-Y3-BF','KG-9','mturyareeba@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBF315','BBA-Y3-BF','KG-6','mturyareeba@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BBF315','BBA-Y3',NULL,'mturyareeba@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'online'),
  ('BBF316','BBA-Y3-AF','KG-15','fahabyoona@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BBF316','BBA-Y3-AF','KG-6','fahabyoona@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BBF316','BBA-Y3-AF','SI-202','prof.alex.thomas.ijjo@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BBF316','BBA-Y3-BF','KG-15','fahabyoona@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BBF316','BBA-Y3-BF','KG-6','fahabyoona@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BBF316','BBA-Y3-BF','SI-202','prof.alex.thomas.ijjo@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BBF316','BBA-Y3-G','KG-15','fahabyoona@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BBF316','BBA-Y3-G','KG-6','fahabyoona@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BBF316','BBA-Y3-G','SI-202','prof.alex.thomas.ijjo@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BBF316','BBA-Y3','SI-105','prof.alex.thomas.ijjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBF316','BBA-Y3','SI-202','prof.alex.thomas.ijjo@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('BBF316','BPAM-Y1','SI-105','prof.alex.thomas.ijjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBF317','BBA-Y3-AF','KG-13','mturyareeba@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BBF317','BBA-Y3-AF','KG-6','mturyareeba@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('BBF317','BBA-Y3','KG-9','mturyareeba@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BBF317','BBA-Y3','KG-14','mturyareeba@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('BBF322','BBA-Y3-BF','KG-13','rbisaso@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BBF322','BBA-Y3-BF','KG-6','dr.mutya.tomasi@cavendish.ac.ug',7,'12:30'::time,'16:30'::time,'physical'),
  ('BBF322','BBA-Y3','KG-11','dr.mutya.tomasi@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BBF323','BBA-Y3-BF','KG-10','htugume@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BBF323','BBA-Y3','KG-10','mr.ngabirano.richard@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BBF325','BBA-Y3-BF','KG-13','cmakwasi@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BBF325','BBA-Y3','KG-13','mturyareeba@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BBF326',NULL,'KG-6','dkatongole@cavendish.ac.ug',6,'16:45'::time,'18:45'::time,'physical'),
  ('BBF326','BBA-Y3-BF','KG-10','dkatongole@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BBF326','BBA-Y3-BF','KG-6','dkatongole@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('BBF326','BBA-Y3-G','KG-10','dkatongole@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BBF326','BBA-Y3-G','KG-6','dkatongole@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('BBF326','BBA-Y3','KG-13','dkatongole@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BBF326','BBA-Y3','KG-14','dkatongole@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BDA1201','BDSA-Y1','SI-012','bkisakye@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BDA1201','BDSA-Y1',NULL,'bkisakye@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('BDA1201','DDA-Y1','SI-012','bkisakye@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BDA1201','DDSA-Y1','SI-012','bkisakye@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BDA1201','DDSA-Y1',NULL,'bkisakye@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('BDA1202','BDSA-Y1','SI-011','mr.ssengendo.moses@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BDA1202','BDSA-Y1',NULL,'mr.ssengendo.moses@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('BDA1202','DDA-Y1','SI-011','jbssemakula@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BDA1202','DDSA-Y1','SI-011','mr.ssengendo.moses@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BDA1202','DDSA-Y1',NULL,'mr.ssengendo.moses@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('BDA2101','BDSA-Y2','SI-011','tnabbanja@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BDA2101','BDSA-Y2',NULL,'tnabbanja@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('BDA2102','BDSA-Y2','SI-102','dr.tumusiime.andrew.gahwera@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BDA2102','BDSA-Y2',NULL,'dr.tumusiime.andrew.gahwera@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('BDA2102','DDSA-Y2','SI-102','dr.tumusiime.andrew.gahwera@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BDA2102','DDSA-Y2',NULL,'dr.tumusiime.andrew.gahwera@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('BDA2104','BDSA-Y2','SI-012','mr.nkoloogi.blasius@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BDA2104','BDSA-Y2',NULL,'mr.nkoloogi.blasius@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('BDA2201','BDSA-Y2','SI-102','jbssemakula@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BDA2201','BDSA-Y2',NULL,'jbssemakula@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('BDA2202','BDSA-Y2','SI-212','mr.nkoloogi.blasius@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BDA2202','BDSA-Y2',NULL,'mr.nkoloogi.blasius@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('BDA2202','DDSA-Y2','SI-212','mr.nkoloogi.blasius@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BDA2202','DDSA-Y2',NULL,'mr.nkoloogi.blasius@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('BDA2203','BDSA-Y2','SI-105','galiwango.charles.jovans@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BDA2203','BDSA-Y2',NULL,'galiwango.charles.jovans@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('BDA2203','DDSA-Y2','SI-105','galiwango.charles.jovans@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BDA2203','DDSA-Y2',NULL,'galiwango.charles.jovans@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('BDA3101','BDSA-Y3','SI-102','galiwango.charles.jovans@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BDA3101','BDSA-Y3',NULL,'galiwango.charles.jovans@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('BDA3103','BDSA-Y3',NULL,'ichinwe@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'online'),
  ('BDA3103','BDSA-Y3',NULL,'ichinwe@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('BDA3105','BDSA-Y3','SI-102','bkisakye@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BDA3105','BDSA-Y3',NULL,'bkisakye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('BIS313','BCS-Y2','SI-105','bkisakye@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('BIS313','BCS-Y2','SI-105','bkisakye@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BIS313','BIT-Y3','SI-105','bkisakye@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('BIS313','BIT-Y3','SI-105','bkisakye@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BIT110','BBA-Y1-AF','SI-214','e.nanyonjo@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BBA-Y1-BF','SI-214','e.nanyonjo@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BBA-Y1-ENT','SI-214','e.nanyonjo@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BBA-Y1-G','SI-214','e.nanyonjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT110','BBA-Y1-HRM','SI-214','e.nanyonjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT110','BBA-Y1-MKT','SI-214','e.nanyonjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT110','BBA-Y1-PL','SI-214','e.nanyonjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT110','BBA-Y1-W','MKN-05','e.nanyonjo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BBA-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT110','BBA-Y1','MKN-05','e.nanyonjo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BCS-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT110','BCS-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BDA-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BDSA-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BDSA-Y1','MKN-05','e.nanyonjo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BEHS-Y1','MKN-05','e.nanyonjo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BIRDS-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BIT-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BJC-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BPAM-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BPH-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','BPH-Y1','MKN-05','e.nanyonjo@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BIT110','BSE-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT110','BSE-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','DBA-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT110','DBA-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','DDA-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','DDSA-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','DDSA-Y1','MKN-05','e.nanyonjo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('BIT110','DIT-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BIT111','BCS-Y1','SI-B01','emaganda@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BIT111','BDA-Y1','SI-B01','emaganda@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BIT111','BDSA-Y1-ONLINE',NULL,'emaganda@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('BIT111','BDSA-Y1','SI-B01','emaganda@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BIT111','BDSA-Y1',NULL,'emaganda@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('BIT111','BIT-Y1','SI-B01','emaganda@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BIT111','BSE-Y1','SI-B01','emaganda@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BIT113','BIT-Y1','SI-205','kalone@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BIT113','DIT-Y1','SI-205','kalone@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BIT121','BCS-Y2','SI-112','e.nanyonjo@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BIT121','BCS-Y2','SI-B01','galiwango.charles.jovans@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BIT121','BDSA-Y2','SI-B01','galiwango.charles.jovans@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BIT121','BDSA-Y2',NULL,'galiwango.charles.jovans@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('BIT121','BIT-Y1','SI-112','e.nanyonjo@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BIT121','BIT-Y1','SI-B01','galiwango.charles.jovans@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BIT121','BSE-Y1','SI-112','e.nanyonjo@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BIT121','BSE-Y1','SI-B01','galiwango.charles.jovans@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BIT121','DDSA-Y2','SI-B01','galiwango.charles.jovans@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BIT121','DDSA-Y2',NULL,'galiwango.charles.jovans@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('BIT121','DIT-Y1','SI-112','e.nanyonjo@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BIT121','DIT-Y1','SI-B01','galiwango.charles.jovans@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BIT122','BCS-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BIT122','BDSA-Y1','SI-214','d.mackenzie@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BIT122','BDSA-Y1',NULL,'d.mackenzie@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('BIT122','BIT-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BIT122','BSE-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BIT122','DDA-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BIT122','DDSA-Y1','SI-214','d.mackenzie@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BIT122','DDSA-Y1',NULL,'d.mackenzie@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('BIT122','DIT-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BIT123','BIT-Y1','SI-214','kenneth.a@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('BIT123','BIT-Y1','SI-214','tnabbanja@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BIT123','DIT-Y1','SI-214','kenneth.a@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('BIT123','DIT-Y1','SI-214','tnabbanja@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BIT124','BCS-Y1','SI-112','hngugi@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BIT124','BCS-Y1','SI-B01','hngugi@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BIT124','BIT-Y1','SI-112','hngugi@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BIT124','BIT-Y1','SI-B01','hngugi@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BIT124','BSE-Y3','SI-112','hngugi@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BIT124','BSE-Y3','SI-B01','hngugi@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BIT124','DIT-Y2','SI-112','hngugi@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BIT124','DIT-Y2','SI-B01','hngugi@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BIT125',NULL,'KG-6','hngugi@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('BIT125','BBA-Y3-G','SI-205','hngugi@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BIT125','BBA-Y3-G','KG-6','hngugi@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('BIT125','BBA-Y3','SI-012','hngugi@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BIT125','BBA-Y3','SI-011','hngugi@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BIT125','BIT-Y1','SI-012','hngugi@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BIT125','BIT-Y1','SI-205','hngugi@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BIT125','DBA-Y2','SI-012','hngugi@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BIT125','DBA-Y2','SI-205','hngugi@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BIT212','BCS-Y1','SI-112','hngugi@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('BIT212','BCS-Y1','SI-214','kalone@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BIT212','BIT-Y2','SI-112','hngugi@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('BIT212','BIT-Y2','SI-214','kalone@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BIT212','BSE-Y1','SI-112','hngugi@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('BIT212','BSE-Y1','SI-214','kalone@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BIT212','DIT-Y2','SI-112','hngugi@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('BIT212','DIT-Y2','SI-214','kalone@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BIT213','BCS-Y2','SI-112','mr.nkoloogi.blasius@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BIT213','BCS-Y2','SI-112','d.mackenzie@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BIT213','BIT-Y2','SI-112','mr.nkoloogi.blasius@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BIT213','BIT-Y2','SI-112','d.mackenzie@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BIT213','BSE-Y2','SI-112','mr.nkoloogi.blasius@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BIT213','BSE-Y2','SI-112','d.mackenzie@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BIT213','DCS-Y2','SI-112','d.mackenzie@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BIT213','DIT-Y2','SI-112','mr.nkoloogi.blasius@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BIT213','DIT-Y2','SI-112','d.mackenzie@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BIT214','BCS-Y2','SI-214','rtuhaise@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BIT214','BDSA-Y1-ONLINE',NULL,'rtuhaise@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('BIT214','BDSA-Y1','SI-214','rtuhaise@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BIT214','BDSA-Y1',NULL,'rtuhaise@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('BIT214','BIT-Y2','SI-214','rtuhaise@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BIT214','BSE-Y2','SI-214','rtuhaise@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BIT214','DCS-Y2','SI-214','rtuhaise@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BIT214','DDSA-Y2','SI-214','rtuhaise@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BIT214','DDSA-Y2',NULL,'rtuhaise@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('BIT214','DIT-Y2','SI-214','rtuhaise@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BIT215','BCS-Y2','SI-214','e.nanyonjo@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BIT215','BIT-Y2','SI-214','e.nanyonjo@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BIT215','BSE-Y2','SI-214','e.nanyonjo@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BIT215','DIT-Y2','SI-214','e.nanyonjo@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BIT222','BCS-Y2',NULL,'ichinwe@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'online'),
  ('BIT222','BCS-Y2','SI-112','kssegawa@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BIT222','BDSA-Y2',NULL,'ichinwe@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'online'),
  ('BIT222','BDSA-Y2',NULL,'ichinwe@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('BIT222','BIT-Y2',NULL,'ichinwe@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'online'),
  ('BIT222','BIT-Y2','SI-112','kssegawa@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BIT222','BSE-Y2',NULL,'ichinwe@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'online'),
  ('BIT222','BSE-Y2','SI-112','kssegawa@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BIT222','DIT-Y2',NULL,'ichinwe@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'online'),
  ('BIT222','DIT-Y2','SI-112','kssegawa@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BIT223','BIT-Y2','SI-112','rtuhaise@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BIT223','DIT-Y2','SI-112','rtuhaise@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BIT225','BCS-Y3','SI-205','bkisakye@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BIT225','BIT-Y2','SI-205','bkisakye@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BIT225','DDSA-Y2','SI-205','bkisakye@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BIT225','DDSA-Y2',NULL,'bkisakye@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('BIT225','DIT-Y2','SI-205','bkisakye@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BIT311','BCS-Y3','SI-112','moses.balirwa@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BIT311','BCS-Y3','SI-112','moses.balirwa@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BIT311','BIT-Y3','SI-112','moses.balirwa@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BIT311','BIT-Y3','SI-112','moses.balirwa@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BIT311','BSE-Y4','SI-112','moses.balirwa@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BIT311','BSE-Y4','SI-112','moses.balirwa@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BIT312','BCS-Y3','SI-105','dtaremwa@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BIT312','BIT-Y3','SI-105','dtaremwa@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BIT312','BSE-Y3','SI-105','dtaremwa@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BIT314','BCS-Y3','SI-214','rtuhaise@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BIT314','BIT-Y3','SI-214','rtuhaise@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BIT314','BSE-Y3','SI-214','rtuhaise@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BIT315','BIT-Y3','SI-105','emaganda@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BIT315','DIT-Y2','SI-105','emaganda@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BIT321','BCS-Y3','SI-112','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT321','BCS-Y3','SI-205','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT321','BIT-Y3','SI-112','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT321','BIT-Y3','SI-205','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT321','BSE-Y4','SI-112','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT321','BSE-Y4','SI-205','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT321','DIT-Y2','SI-112','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT321','DIT-Y2','SI-205','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BIT322','BIT-Y3','SI-105','d.mackenzie@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BIT322','BIT-Y3','SI-011','d.mackenzie@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BIT323','BIT-Y3','SI-202','bkisakye@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BIT323','BSE-Y3','SI-202','bkisakye@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BIT323','DCS-Y2','SI-202','bkisakye@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BIT324','BCS-Y3','SI-214','rtuhaise@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BIT324','BIT-Y3','SI-214','rtuhaise@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BIT325','BIT-Y3','SI-202','emaganda@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BJC110','BBA-Y1-AF','SI-B01','e.namakula@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BJC110','BBA-Y1-BF','SI-B01','e.namakula@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BJC110','BBA-Y1-ENT','SI-B01','e.namakula@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BJC110','BBA-Y1-G','SI-B01','e.namakula@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','BBA-Y1-HRM','SI-B01','e.namakula@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','BBA-Y1-MKT','SI-B01','e.namakula@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','BBA-Y1-PL','SI-B01','e.namakula@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','BBA-Y1-W','MKN-18','e.namakula@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'hybrid'),
  ('BJC110','BBA-Y1','SI-112','hssemakula@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BJC110','BBA-Y1','KG-15','hssemakula@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('BJC110','BCS-Y1','SI-112','hssemakula@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','BCS-Y1','SI-B01','e.namakula@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','BDA-Y1','SI-B01','e.namakula@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','BDSA-Y1','SI-112','hssemakula@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','BDSA-Y1','KG-15','hssemakula@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('BJC110','BEHS-Y1','MKN-18','btusingwire@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BJC110','BEHS-Y1','MKN-18','e.namakula@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'hybrid'),
  ('BJC110','BIRDS-Y1','KG-14','aondigi@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BJC110','BIT-Y1','SI-112','hssemakula@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','BIT-Y1','SI-B01','e.namakula@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','BJC-Y1','KG-14','aondigi@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BJC110','BPAM-Y1','KG-14','aondigi@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BJC110','BPH-Y1','MKN-18','btusingwire@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','BPH-Y1','SI-B01','e.namakula@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','BSE-Y1','SI-112','hssemakula@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','BSE-Y1','SI-B01','e.namakula@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','DBA-Y1','SI-112','hssemakula@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BJC110','DBA-Y1','SI-B01','e.namakula@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BJC110','DDA-Y1','SI-B01','e.namakula@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','DDSA-Y1','SI-112','hssemakula@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','DDSA-Y1','KG-15','hssemakula@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('BJC110','DIT-Y1','SI-112','hssemakula@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BJC110','DIT-Y1','SI-B01','e.namakula@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BJC112','BJC-Y1','SI-012','m.kibukamusoke@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BJC112','BJC-Y1','SI-011','m.kibukamusoke@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BJC115','BJC-Y1','KG-6','hmudoola@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BJC116','BIRDS-Y1','KG-9','aondigi@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BJC116','BJC-Y1','KG-9','aondigi@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BJC116','BPAM-Y1','KG-9','aondigi@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BJC121','BJC-Y1',NULL,'iashiru@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'online'),
  ('BJC121','BJC-Y1','KG-6','dr.sunday.uche.a@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BJC122','BJC-Y1','KG-13','dr.sunday.uche.a@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BJC122','BJC-Y1','KG-7','btusingwire@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BJC123','BJC-Y1','KG-10','btusingwire@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('BJC124','BJC-Y2','KG-6','jKayanga@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BJC124','BJC-Y2','KG-13','jKayanga@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BJC125','BJC-Y1','KG-6','dr.sunday.uche.a@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BJC125','BJC-Y1',NULL,'iashiru@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'online'),
  ('BJC127','BJC-Y1','SI-011','e.namakula@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BJC127','BJC-Y1','KG-5','e.namakula@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BJC128','BJC-Y1','KG-6','s.nnagadya@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BJC128','BJC-Y1','KG-7','s.nnagadya@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BJC211','BJC-Y2','KG-5','hssemakula@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BJC211','BJC-Y2','KG-7','dr.sunday.uche.a@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BJC212','BJC-Y2','KG-10','aondigi@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BJC212','BJC-Y2','KG-10','aondigi@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BJC213','BJC-Y2','KG-4','hmudoola@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BJC213','BJC-Y2','KG-4','hmudoola@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BJC214','BJC-Y2','KG-6','gochwo@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BJC214','BJC-Y2','KG-4','gochwo@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BJC217','BJC-Y2',NULL,'iashiru@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'online'),
  ('BJC217','BJC-Y2','KG-4','dr.sunday.uche.a@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BJC221','BJC-Y2','KG-6','hssemakula@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BJC221','BJC-Y2','KG-11','hssemakula@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BJC224','BJC-Y2','KG-6','hmudoola@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('BJC225','BJC-Y2','SI-012','m.kibukamusoke@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BJC225','BJC-Y2','SI-012','m.kibukamusoke@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BJC226','BJC-Y2',NULL,'iashiru@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'online'),
  ('BJC226','BJC-Y2','KG-11','dr.sunday.uche.a@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BJC229','BJC-Y2','KG-5','s.nnagadya@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BJC311','BJC-Y3','SI-011','e.namakula@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BJC311','BJC-Y3',NULL,'iashiru@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'online'),
  ('BJC312','BJC-Y3','KG-13','jKayanga@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BJC312','BJC-Y3','KG-6','jKayanga@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BJC313','BJC-Y3-J','KG-7','btusingwire@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BJC313','BJC-Y3-PR','KG-7','btusingwire@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BJC313','BJC-Y3','KG-7','btusingwire@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BJC314','BJC-Y3','KG-4','s.nnagadya@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BJC314','BJC-Y3','KG-7','s.nnagadya@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BJC315','BJC-Y3','KG-15','btusingwire@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BJC315','BJC-Y3','KG-9','btusingwire@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BJC322','BJC-Y3-J','KG-5','gochwo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BJC322','BJC-Y3','KG-5','gochwo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BJC323','BJC-Y3-JOURNALISM','KG-9','jKayanga@cavendish.ac.ug',2,'16:45'::time,'18:45'::time,'physical'),
  ('BJC323','BJC-Y3','KG-9','jKayanga@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BJC324','BJC-Y3-JOURNALISM',NULL,'amadu@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'online'),
  ('BJC324','BJC-Y3',NULL,'amadu@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'online'),
  ('BJC326','BJC-Y3-J','KG-9','hssemakula@cavendish.ac.ug',4,'16:45'::time,'18:45'::time,'physical'),
  ('BJC326','BJC-Y3','KG-5','hssemakula@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BJC327','BJC-Y3-J','KG-13','btusingwire@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BJC327','BJC-Y3','KG-11','btusingwire@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BJC328','BJC-Y3-J','KG-5','s.nnagadya@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BJC328','BJC-Y3','KG-5','s.nnagadya@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BJC329','BJC-Y3-J','KG-5','s.nnagadya@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BJC329','BJC-Y3','KG-7','s.nnagadya@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BPA111','BIRDS-Y2','SI-012','dr.bello.folaranmi.fatai@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BPA111','BIRDS-Y2','SI-102','ambabazi@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BPA111','BPAM-Y1','SI-012','dr.bello.folaranmi.fatai@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BPA111','BPAM-Y1','SI-102','ambabazi@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BPA112','BBA-Y3','SI-105','prof.alex.thomas.ijjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BPA112','BPAM-Y1','SI-105','prof.alex.thomas.ijjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BPA112','BPAM-Y1',NULL,'amadu@cavendish.ac.ug',2,'16:00'::time,'18:00'::time,'online'),
  ('BPA113','BPAM-Y2','SI-B01','trussel@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BPA113','BPAM-Y2','SI-112','inamaja@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BPA113','HEC-Y1','SI-B01','trussel@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BPA113','HEC-Y1','SI-112','inamaja@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BPA116','BBA-Y3-G','KG-6',NULL,7,'10:15'::time,'12:15'::time,'physical'),
  ('BPA116','BBA-Y3-HRM','KG-6',NULL,7,'10:15'::time,'12:15'::time,'physical'),
  ('BPA116','BPAM-Y1','SI-011','inamaja@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BPA116','BPAM-Y1','SI-012','inamaja@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BPA121','BIRDS-Y1','SI-B01','vssekundi@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BPA121','BIRDS-Y1','SI-B01','mr.okello.pasqualine@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BPA121','BJC-Y1','SI-B01','vssekundi@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BPA121','BJC-Y1','SI-B01','mr.okello.pasqualine@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BPA121','BPAM-Y1','SI-B01','vssekundi@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BPA121','BPAM-Y1','SI-B01','mr.okello.pasqualine@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BPA121','HEC-Y1-A','SI-B01','vssekundi@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BPA121','HEC-Y1','SI-B01','mr.okello.pasqualine@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BPA122','BPAM-Y1','KG-11','pakampurira@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BPA122','BPAM-Y1','KG-6','pakampurira@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BPA123','BPAM-Y1','KG-11','eomaada@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BPA123','BPAM-Y1','KG-11','gopio@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BPA124','BBA-Y3-HRM','KG-6','bnassozi@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BPA124','BBA-Y3','KG-9','bnassozi@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('BPA124','BBA-Y3','KG-6','bnassozi@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('BPA124','BPAM-Y1','KG-9','bnassozi@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('BPA124','BPAM-Y3','KG-7','bnassozi@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BPA125','BIRDS-Y2','KG-6','eomaada@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BPA125','BIRDS-Y2','KG-11','pakampurira@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BPA125','BPAM-Y2','KG-6','eomaada@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BPA125','BPAM-Y2','KG-11','pakampurira@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BPA126','BIRDS-Y1','KG-11','rnkongho@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BPA126','BIRDS-Y1','KG-11','prof.haruna.ayuba@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BPA126','BPAM-Y1','KG-11','rnkongho@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BPA126','BPAM-Y1','KG-11','prof.haruna.ayuba@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BPA211','BBA-Y3','SI-105','ambabazi@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BPA211','BBA-Y3','KG-6','ambabazi@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BPA211','BPAM-Y2','SI-105','ambabazi@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BPA211','BPAM-Y2','SI-011','ambabazi@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BPA213','BPAM-Y2','KG-11','j.tabalanga@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BPA215','BPAM-Y2',NULL,'amadu@cavendish.ac.ug',1,'16:00'::time,'18:00'::time,'online'),
  ('BPA215','BPAM-Y2','SI-011','awabule@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BPA216','BPAM-Y2','KG-10','inamaja@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BPA216','BPAM-Y2','KG-11','inamaja@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BPA217','BPAM-Y2',NULL,'amadu@cavendish.ac.ug',4,'16:00'::time,'18:00'::time,'online'),
  ('BPA217','BPAM-Y2',NULL,'amadu@cavendish.ac.ug',4,'16:15'::time,'18:15'::time,'online'),
  ('BPA221','BPAM-Y1','KG-9','vssekundi@cavendish.ac.ug',1,'16:45'::time,'18:45'::time,'physical'),
  ('BPA221','BPAM-Y1','KG-6','mr.okello.pasqualine@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BPA225','BIRDS-Y1','KG-11','pakampurira@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BPA225','BIRDS-Y1','KG-10','pakampurira@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BPA225','BPAM-Y2','KG-11','pakampurira@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BPA225','BPAM-Y2','KG-10','pakampurira@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BPA226','BPAM-Y2','SI-012','vssekundi@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BPA226','BPAM-Y2',NULL,'mr.katumba.david@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'online'),
  ('BPA312','BPAM-Y3',NULL,'amadu@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'online'),
  ('BPA312','BPAM-Y3','KG-6','inamaja@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BPA313','BPAM-Y3','SI-011','mr.okello.pasqualine@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BPA313','BPAM-Y3','KG-13','vssekundi@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BPA314','BPAM-Y3','KG-14','rwatenyera@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BPA316','BPAM-Y3','SI-012','inamaja@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BPA316','BPAM-Y3','SI-202','inamaja@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BPA322','BPAM-Y3',NULL,'amadu@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'online'),
  ('BPA322','BPAM-Y3','KG-10','rnkongho@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BPA323','BPAM-Y3',NULL,'amadu@cavendish.ac.ug',3,'16:00'::time,'18:00'::time,'online'),
  ('BPA324','BPAM-Y3','KG-7','awabule@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('BPA324','BPAM-Y3','KG-13','awabule@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BPA325','BPAM-Y3',NULL,'amadu@cavendish.ac.ug',3,'16:00'::time,'18:00'::time,'online'),
  ('BPH112','BPH-Y1','MKN-15','k.namajja@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BPH112','BPH-Y1','MKN-14','k.namajja@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BPH113','BEHS-Y1','MKN-16','b.nabaasa@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BPH113','BPH-Y1','MKN-17','b.nabaasa@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BPH114','BPH-Y1','MKN-15','bkwesiga@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BPH121','BPH-Y1','MKN-15','swafula@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BPH122','BPH-Y1',NULL,'dmusa@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'online'),
  ('BPH122','BPH-Y1','MKN-09','ckembabazi@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BPH124','BEHS-Y1','MKN-14','yiga.mulindwa@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('BPH124','BEHS-Y1','MKN-14','b.nabaasa@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('BPH124','BPH-Y1','MKN-16','yiga.mulindwa@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BPH124','BPH-Y1','MKN-16','b.nabaasa@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BPH211','BEHS-Y2','MKN-16','satuhaire@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BPH211','BPH-Y2','MKN-08','satuhaire@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BPH211','BPH-Y2','MKN-15','satuhaire@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BPH212','BPH-Y1','MKN-08','mr.ssekawu.barnabas@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BPH212','BPH-Y1','MKN-16','bkwesiga@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BPH215','BPH-Y2','MKN-10','k.namajja@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BPH215','BPH-Y2','MKN-15','k.namajja@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BPH216','BPH-Y2','MKN-16','bkwesiga@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BPH216','BPH-Y2','MKN-16','yiga.mulindwa@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BPH221','BEHS-Y3','MKN-17','k.namajja@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('BPH221','BPH-Y2','MKN-15','k.namajja@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('BPH221','BPH-Y2','MKN-16','k.namajja@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BPH221','DDA-Y1','SI-012','k.namajja@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BPH222','BPH-Y2','MKN-16','dr.ene.bongili.goodness@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BPH222','BPH-Y2','MKN-15','bkwesiga@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BPH222','DDA-Y1','SI-205','j.bandaru@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BPH224','BPH-Y2','MKN-17','d.nsubuga@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BPH224','BPH-Y2','MKN-16','d.nsubuga@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BPH224','DDA-Y1','SI-011','d.nsubuga@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BPH311','BEHS-Y3','MKN-18','bkwesiga@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('BPH311','BPH-Y3','MKN-16','bkwesiga@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BPH311','BPH-Y3','MKN-16','yiga.mulindwa@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BPH313','BPH-Y3','MKN-10','dr.ene.bongili.goodness@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BPH313','BPH-Y3','MKN-18','satuhaire@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BPH314','BPH-Y3','MKN-17','b.nabaasa@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BPH314','BPH-Y3','MKN-17','mr.katumba.david@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BPH321','BEHS-Y3','MKN-17','m.taibu@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('BPH321','BPH-Y3','MKN-05','m.taibu@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BPH321','BPH-Y3','MKN-16','m.taibu@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('BPH323','BPH-Y2','MKN-16','bkwesiga@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BPH323','BPH-Y3','MKN-17','k.namajja@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BPH326','BPH-Y3','MKN-17','k.namajja@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('BPR321','BJC-Y3-PR','KG-5','hssemakula@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BPR321','BJC-Y3','KG-4','hssemakula@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BPR322','BJC-Y3-PR','KG-9','jKayanga@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('BPR322','BJC-Y3','KG-9','jKayanga@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('BPR323','BJC-Y3-PR','KG-5','hmudoola@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BPR323','BJC-Y3','KG-5','hmudoola@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BPR324','BJC-Y3-PR','KG-7','jKayanga@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BPR324','BJC-Y3','KG-10','jKayanga@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BPR325','BJC-Y3-PR','KG-7','hssemakula@cavendish.ac.ug',3,'16:45'::time,'18:45'::time,'physical'),
  ('BPR325','BJC-Y3','KG-13','hssemakula@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BPR327','BJC-Y3-PR','KG-7','hmudoola@cavendish.ac.ug',3,'14:45'::time,'16:45'::time,'physical'),
  ('BPR327','BJC-Y3','KG-5','hmudoola@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BPR329','BJC-Y3-PR','KG-5','hmudoola@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BPR329','BJC-Y3','KG-5','hmudoola@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('BSE111','BDA-Y1','SI-102','d.mackenzie@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE111','BDSA-Y1','SI-205','d.mackenzie@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE111','BDSA-Y1',NULL,'d.mackenzie@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('BSE111','BSE-Y1','SI-102','d.mackenzie@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE111','BSE-Y1','SI-205','d.mackenzie@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE121','BCS-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BSE121','BCS-Y2','SI-112','e.nanyonjo@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE121','BCS-Y2','SI-B01','galiwango.charles.jovans@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE121','BDSA-Y1','SI-214','d.mackenzie@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BSE121','BDSA-Y1',NULL,'d.mackenzie@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('BSE121','BDSA-Y2','SI-B01','galiwango.charles.jovans@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE121','BDSA-Y2',NULL,'galiwango.charles.jovans@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('BSE121','BIT-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BSE121','BIT-Y1','SI-112','e.nanyonjo@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE121','BIT-Y1','SI-B01','galiwango.charles.jovans@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE121','BSE-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BSE121','BSE-Y1','SI-112','e.nanyonjo@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE121','BSE-Y1','SI-B01','galiwango.charles.jovans@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE121','DDA-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BSE121','DDSA-Y1','SI-214','d.mackenzie@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BSE121','DDSA-Y1',NULL,'d.mackenzie@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('BSE121','DDSA-Y2','SI-B01','galiwango.charles.jovans@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE121','DDSA-Y2',NULL,'galiwango.charles.jovans@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('BSE121','DIT-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BSE121','DIT-Y1','SI-112','e.nanyonjo@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE121','DIT-Y1','SI-B01','galiwango.charles.jovans@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE212','BCS-Y2','SI-205','kssegawa@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BSE212','BCS-Y2','SI-205','dr.tumusiime.andrew.gahwera@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BSE212','BIT-Y2','SI-205','kssegawa@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BSE212','BIT-Y2','SI-205','dr.tumusiime.andrew.gahwera@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BSE212','BSE-Y2','SI-205','kssegawa@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BSE212','BSE-Y2','SI-205','dr.tumusiime.andrew.gahwera@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BSE213','BCS-Y2','SI-112','mr.nkoloogi.blasius@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BSE213','BCS-Y2','SI-112','d.mackenzie@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BSE213','BIT-Y2','SI-112','mr.nkoloogi.blasius@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BSE213','BIT-Y2','SI-112','d.mackenzie@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BSE213','BSE-Y2','SI-112','mr.nkoloogi.blasius@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BSE213','BSE-Y2','SI-112','d.mackenzie@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BSE213','DCS-Y2','SI-112','d.mackenzie@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BSE213','DIT-Y2','SI-112','mr.nkoloogi.blasius@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BSE213','DIT-Y2','SI-112','d.mackenzie@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BSE221','BSE-Y2','SI-202','kssegawa@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE221','BSE-Y2','SI-102','emaganda@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BSE222','BDSA-Y2','SI-212','dtaremwa@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BSE222','BDSA-Y2',NULL,'dtaremwa@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('BSE222','BSE-Y2','SI-212','dtaremwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BSE222','BSE-Y2','SI-212','dtaremwa@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('BSE224','BCS-Y2','SI-202','oscar.correia@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'hybrid'),
  ('BSE224','BCS-Y2','SI-214','galiwango.charles.jovans@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BSE224','BDA-Y1','SI-202','oscar.correia@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'hybrid'),
  ('BSE224','BDSA-Y1','SI-214','galiwango.charles.jovans@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BSE224','BDSA-Y1',NULL,'galiwango.charles.jovans@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('BSE224','BSE-Y2','SI-202','oscar.correia@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'hybrid'),
  ('BSE224','BSE-Y2','SI-214','galiwango.charles.jovans@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BSE224','DDA-Y1','SI-202','oscar.correia@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'hybrid'),
  ('BSE224','DDSA-Y1','SI-214','galiwango.charles.jovans@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BSE224','DDSA-Y1',NULL,'galiwango.charles.jovans@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('BSE226','BSE-Y2','SI-105','emaganda@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('BSE226','BSE-Y2','SI-102','tnabbanja@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE311','BCS-Y3','SI-105','dtaremwa@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BSE311','BIT-Y3','SI-105','dtaremwa@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BSE311','BSE-Y3','SI-105','dtaremwa@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('BSE314','BDSA-Y2','SI-012','mr.nkoloogi.blasius@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('BSE314','BDSA-Y2',NULL,'mr.nkoloogi.blasius@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('BSE314','BSE-Y3','SI-012','mr.nkoloogi.blasius@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('BSE314','BSE-Y3','SI-202','nblasius@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BSE314','DDA-Y1','SI-202','nblasius@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('BSE314','DDSA-Y1','SI-012','mr.nkoloogi.blasius@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('BSE314','DDSA-Y1',NULL,'mr.nkoloogi.blasius@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('BSE321','BSE-Y4','SI-212','dtaremwa@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BSE322','BSE-Y3','SI-214','bkisakye@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('BSE323','BSE-Y4','SI-202','d.mackenzie@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BSE323','BSE-Y4','SI-102','d.mackenzie@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('BSE326','BSE-Y3',NULL,'mkumakech@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'online'),
  ('BSE326','BSE-Y3',NULL,'ichinwe@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'online'),
  ('BSE327','BSE-Y3','SI-212','bkisakye@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('BSE411','BSE-Y4','SI-202','kssegawa@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('BSE412','BCS-Y2','SI-112','mr.nkoloogi.blasius@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BSE412','BCS-Y2','SI-212','nblasius@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE412','BSE-Y4','SI-112','mr.nkoloogi.blasius@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BSE412','BSE-Y4','SI-212','nblasius@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('BSE414','BSE-Y4','SI-012','eofoyuru@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('BSE414','BSE-Y4','SI-102','eofoyuru@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BSE417','BSE-Y4','SI-202','jbssemakula@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('BSE426','BSE-Y4','SI-212','rtuhaise@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('BSE426','BSE-Y4','SI-212','rtuhaise@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('BSE427','BCS-Y3','SI-112','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BSE427','BCS-Y3','SI-205','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BSE427','BIT-Y3','SI-112','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BSE427','BIT-Y3','SI-205','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BSE427','BSE-Y4','SI-112','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BSE427','BSE-Y4','SI-205','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BSE427','DIT-Y2','SI-112','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('BSE427','DIT-Y2','SI-205','moses.balirwa@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('COM111','BCS-Y1','SI-202','dtaremwa@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('COM111','BCS-Y1','SI-205','dtaremwa@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('COM113','BCS-Y1','SI-105','emaganda@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('COM113','BCS-Y1','SI-112','emaganda@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('COM113','BSE-Y1','SI-105','emaganda@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('COM113','BSE-Y1','SI-112','emaganda@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('COM113','DIT-Y1','SI-105','emaganda@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('COM113','DIT-Y1','SI-112','emaganda@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('COM122','BCS-Y1','SI-B01','mkumakech@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('COM122','BIT-Y1','SI-B01','mkumakech@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('COM122','BSE-Y1','SI-B01','mkumakech@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('COM122','DIT-Y1','SI-B01','mkumakech@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('COM123','BCS-Y1','SI-105','fmugabi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('COM123','BCS-Y1','SI-105','mr.ssengendo.moses@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('COM123','BDSA-Y1','SI-105','mr.ssengendo.moses@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('COM123','BDSA-Y1',NULL,'mr.ssengendo.moses@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('COM123','BSE-Y1','SI-105','fmugabi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('COM123','BSE-Y1','SI-105','mr.ssengendo.moses@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('COM123','DDA-Y1','SI-105','fmugabi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('COM123','DDSA-Y1','SI-105','mr.ssengendo.moses@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('COM123','DDSA-Y1',NULL,'mr.ssengendo.moses@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('COM211','BCS-Y2','SI-112','jbssemakula@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('COM211','BDSA-Y1-ONLINE',NULL,'jbssemakula@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('COM211','BDSA-Y1','SI-112','jbssemakula@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('COM211','BDSA-Y1',NULL,'jbssemakula@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('COM211','BIT-Y2','SI-112','jbssemakula@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('COM211','BSE-Y2','SI-112','jbssemakula@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('COM211','DCS-Y2','SI-112','jbssemakula@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('COM212','BCS-Y2','SI-205','dtaremwa@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('COM212','BDSA-Y2','SI-205','dtaremwa@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('COM212','BDSA-Y2',NULL,'dtaremwa@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('COM212','BSE-Y2','SI-205','dtaremwa@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('COM221','BCS-Y2','SI-B01','mkumakech@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('COM221','BCS-Y2','SI-B01','tnabbanja@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('COM221','BDSA-Y2','SI-B01','tnabbanja@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('COM221','BDSA-Y2',NULL,'tnabbanja@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'online'),
  ('COM221','BIT-Y2','SI-B01','mkumakech@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('COM221','BIT-Y2','SI-B01','tnabbanja@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('COM221','BSE-Y2','SI-B01','mkumakech@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('COM221','BSE-Y2','SI-B01','tnabbanja@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('COM224','BCS-Y2','SI-205','kssegawa@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('COM224','BCS-Y2','SI-205','dr.tumusiime.andrew.gahwera@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('COM224','BIT-Y2','SI-205','kssegawa@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('COM224','BIT-Y2','SI-205','dr.tumusiime.andrew.gahwera@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('COM224','BSE-Y2','SI-205','kssegawa@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('COM224','BSE-Y2','SI-205','dr.tumusiime.andrew.gahwera@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('COM225','BCS-Y2','SI-112','mr.nkoloogi.blasius@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('COM225','BCS-Y2','SI-212','nblasius@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('COM225','BSE-Y4','SI-112','mr.nkoloogi.blasius@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('COM225','BSE-Y4','SI-212','nblasius@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('COM311','BCS-Y3','SI-011','mr.nkoloogi.blasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('COM311','BCS-Y3','SI-212','nblasius@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('COM311','BSE-Y3','SI-011','mr.nkoloogi.blasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('COM311','BSE-Y3','SI-212','nblasius@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('COM312','BCS-Y3',NULL,'ichinwe@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'online'),
  ('COM312','BSE-Y3',NULL,'ichinwe@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'online'),
  ('COM321','BCS-Y2','SI-105','mkumakech@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('COM321','BCS-Y2','SI-105','mkumakech@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('COM321','BCS-Y3','SI-105','mkumakech@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('COM321','BDSA-Y2','SI-105','mkumakech@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('COM321','BSE-Y3','SI-105','mkumakech@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('COM323','BCS-Y3','SI-212','mkumakech@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('COM323','BCS-Y3','SI-212','mkumakech@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('COM324','BCS-Y3',NULL,'ichinwe@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'online'),
  ('COM324','BDSA-Y3',NULL,'ichinwe@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'online'),
  ('COM324','BDSA-Y3',NULL,'ichinwe@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('COM324','BSE-Y3',NULL,'ichinwe@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'online'),
  ('DBA112','BBA-Y1-AF','KG-15','dkatongole@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DBA112','BBA-Y1-BF','KG-15','dkatongole@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DBA112','BBA-Y1-ENT','KG-15','dkatongole@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DBA112','BBA-Y1-G','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA112','BBA-Y1-HRM','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA112','BBA-Y1-MKT','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA112','BBA-Y1-PL','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA112','BBA-Y1-W','KG-14','dkatongole@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('DBA112','BBA-Y1','KG-15','snamazzi@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('DBA112','BBA-Y1','KG-14','snamazzi@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('DBA112','DBA-Y1','KG-15','dkatongole@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DBA112','DBA-Y1','KG-15','snamazzi@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('DBA113','BBA-Y1-AF','KG-14','d.bakyayita@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA113','BBA-Y1-BF','KG-14','d.bakyayita@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA113','BBA-Y1-ENT','KG-14','d.bakyayita@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA113','BBA-Y1-G','KG-14','d.bakyayita@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DBA113','BBA-Y1-HRM','KG-14','d.bakyayita@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DBA113','BBA-Y1-MKT','KG-14','d.bakyayita@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DBA113','BBA-Y1-PL','KG-14','d.bakyayita@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DBA113','BBA-Y1-W','KG-15','d.bakyayita@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('DBA113','BBA-Y1','KG-14','d.bakyayita@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA113','BBA-Y1','KG-15','d.bakyayita@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('DBA113','DBA-Y1','KG-14','d.bakyayita@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA115','BBA-Y1','KG-15','dkalembe@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DBA115','BBA-Y1','KG-15','dkalembe@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('DBA115','DBA-Y1','KG-15','dkalembe@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DBA116','BBA-Y1-AF','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DBA116','BBA-Y1-BF','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DBA116','BBA-Y1-ENT','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DBA116','BBA-Y1-G','KG-15','m.kawiso@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('DBA116','BBA-Y1-HRM','KG-15','m.kawiso@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('DBA116','BBA-Y1-MKT','KG-15','m.kawiso@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('DBA116','BBA-Y1-PL','KG-15','m.kawiso@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('DBA116','BBA-Y1-W','KG-15','m.kawiso@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('DBA116','BBA-Y1','KG-15','m.kawiso@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DBA116','BBA-Y1','KG-15','m.kawiso@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('DBA116','BCS-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DBA116','BCS-Y1','KG-15','m.kawiso@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('DBA116','BDA-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DBA116','BDSA-Y1','KG-15','m.kawiso@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('DBA116','BDSA-Y1','KG-15','m.kawiso@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('DBA116','BIT-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DBA116','BIT-Y1','KG-15','m.kawiso@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('DBA116','DBA-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DBA116','DBA-Y1','KG-15','m.kawiso@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DBA116','DDA-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('DBA116','DDSA-Y1','KG-15','m.kawiso@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('DBA116','DDSA-Y1','KG-15','m.kawiso@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('DBA122','BBA-Y1-W','KG-13','m.kawiso@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('DBA122','BBA-Y1','SI-112','mr.robert.ateng@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('DBA122','BBA-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('DBA122','BBA-Y1','KG-13','mr.robert.ateng@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('DBA122','BBA-Y1','KG-9','mr.robert.ateng@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('DBA122','DBA-Y1','SI-112','mr.robert.ateng@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('DBA122','DBA-Y1','KG-15','m.kawiso@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('DBA124','BBA-Y1-W','KG-14','ykatono@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('DBA124','BBA-Y1','KG-14','ms.noam.everlyn.abenakyo@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('DBA124','BBA-Y1','KG-15','ykatono@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('DBA124','BBA-Y1','KG-14','ms.noam.everlyn.abenakyo@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('DBA124','DBA-Y1','KG-14','ms.noam.everlyn.abenakyo@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('DBA124','DBA-Y1','KG-15','ykatono@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('DBA125','BBA-Y1-W','KG-14','rkabuye@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('DBA125','BBA-Y1','KG-15','rkabuye@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('DBA125','BBA-Y1','KG-14','rkabuye@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('DBA125','DBA-Y1','KG-15','rkabuye@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('DBA126','DBA-Y1','KG-9','enimusiima@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DBA126','DBA-Y1','KG-13','ms.noam.everlyn.abenakyo@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DBA211','BBA-Y2-W','KG-13','d.mpubani@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('DBA211','BBA-Y2','KG-14','d.mpubani@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('DBA211','BBA-Y2','KG-14','mr.ngabirano.richard@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('DBA211','BBA-Y2','KG-13','mr.ngabirano.richard@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('DBA211','BBA-Y2','KG-13','mr.ngabirano.richard@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('DBA211','DBA-Y2','KG-14','d.mpubani@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('DBA211','DBA-Y2','KG-14','mr.ngabirano.richard@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('DBA212',NULL,'KG-6','hngugi@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('DBA212','BBA-Y3-G','SI-205','hngugi@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('DBA212','BBA-Y3-G','KG-6','hngugi@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('DBA212','BBA-Y3','SI-012','hngugi@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DBA212','BBA-Y3','SI-011','hngugi@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('DBA212','BIT-Y1','SI-012','hngugi@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DBA212','BIT-Y1','SI-205','hngugi@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('DBA212','DBA-Y2','SI-012','hngugi@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DBA212','DBA-Y2','SI-205','hngugi@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('DBA213','BBA-Y2-W','KG-15','jsambaga@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('DBA213','BBA-Y2','KG-15','jsambaga@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DBA213','BBA-Y2','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA213','BBA-Y2','KG-14','dkatongole@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('DBA213','BBA-Y2','KG-15','dkatongole@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('DBA213','BCS-Y3','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA213','BIT-Y2','KG-15','jsambaga@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DBA213','BIT-Y2','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA213','BSE-Y4','KG-15','jsambaga@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DBA213','BSE-Y4','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA213','DBA-Y2','KG-15','jsambaga@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DBA213','DBA-Y2','KG-15','dkatongole@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA215','BBA-Y2-W','KG-13','rolar@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('DBA215','BBA-Y2','KG-14','rolar@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('DBA215','BBA-Y2','KG-14','rolar@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('DBA215','BBA-Y2','KG-13','rolar@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('DBA215','BPAM-Y3','KG-14','rolar@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('DBA215','BPAM-Y3','KG-14','rolar@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('DBA215','DBA-Y2','KG-14','rolar@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('DBA215','DBA-Y2','KG-14','rolar@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('DBA216','DBA-Y2','KG-13','enimusiima@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA216','DBA-Y2','KG-13','aasadi@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('DBA221','BBA-Y2','KG-14','d.mpubani@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('DBA221','DBA-Y2','KG-10','htugume@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('DBA221','DBA-Y2','KG-14','d.mpubani@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('DBA222','DBA-Y2','KG-7','fahabyoona@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DBA222','DBA-Y2','KG-6','fahabyoona@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('DBA223','BBA-Y2','KG-9','cmakwasi@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DBA223','DBA-Y2','KG-9','cmakwasi@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DBA223','DBA-Y2','KG-9','htugume@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('DCS111','DDA-Y1','SI-205','fmugabi@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DCS111','DDSA-Y1','SI-205','dtaremwa@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('DCS111','DDSA-Y1',NULL,'dtaremwa@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('DCS111','DIT-Y1','SI-205','dtaremwa@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('DCS111','DIT-Y1','SI-205','fmugabi@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DCS112','DIT-Y1','SI-205','dtaremwa@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('DCS112','DIT-Y1','SI-212','e.nanyonjo@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('DDA1106','BDA-Y1','SI-102','nblasius@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('DDA1106','BDSA-Y1','SI-102','d.mackenzie@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DDA1106','BDSA-Y1',NULL,'d.mackenzie@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('DDA1106','DDA-Y1','SI-102','nblasius@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('DDA1106','DDSA-Y1','SI-102','d.mackenzie@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DDA1106','DDSA-Y1',NULL,'d.mackenzie@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('DDA1201','BCS-Y1','SI-105','fmugabi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DDA1201','BCS-Y1','SI-105','mr.ssengendo.moses@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('DDA1201','BDSA-Y1','SI-105','mr.ssengendo.moses@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('DDA1201','BDSA-Y1',NULL,'mr.ssengendo.moses@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('DDA1201','BSE-Y1','SI-105','fmugabi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DDA1201','BSE-Y1','SI-105','mr.ssengendo.moses@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('DDA1201','DDA-Y1','SI-105','fmugabi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DDA1201','DDSA-Y1','SI-105','mr.ssengendo.moses@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('DDA1201','DDSA-Y1',NULL,'mr.ssengendo.moses@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('DDA1203','BDSA-Y1','SI-011','mr.ssengendo.moses@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('DDA1203','BDSA-Y1',NULL,'mr.ssengendo.moses@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('DDA1203','DDA-Y1','SI-011','jbssemakula@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('DDA1203','DDSA-Y1','SI-011','mr.ssengendo.moses@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('DDA1203','DDSA-Y1',NULL,'mr.ssengendo.moses@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('DDA1204','BCS-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('DDA1204','BDSA-Y1','SI-214','d.mackenzie@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('DDA1204','BDSA-Y1',NULL,'d.mackenzie@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('DDA1204','BIT-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('DDA1204','BSE-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('DDA1204','DDA-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('DDA1204','DDSA-Y1','SI-214','d.mackenzie@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('DDA1204','DDSA-Y1',NULL,'d.mackenzie@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('DDA1204','DIT-Y1','SI-214','nblasius@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('DDA1205','DDA-Y1','SI-011','d.mackenzie@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DDA1205','DDSA-Y1','SI-012','hngugi@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('DDA1205','DDSA-Y1',NULL,'hngugi@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('DDA1206','BDSA-Y1','SI-012','bkisakye@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('DDA1206','BDSA-Y1',NULL,'bkisakye@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('DDA1206','DDA-Y1','SI-012','bkisakye@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('DDA1206','DDSA-Y1','SI-012','bkisakye@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('DDA1206','DDSA-Y1',NULL,'bkisakye@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('DDA2102','DDSA-Y2','SI-102','dr.tumusiime.andrew.gahwera@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('DDA2102','DDSA-Y2',NULL,'dr.tumusiime.andrew.gahwera@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('DDA2103','BDSA-Y3','SI-012','tnabbanja@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('DDA2103','BDSA-Y3',NULL,'tnabbanja@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('DDA2103','DDSA-Y2','SI-012','tnabbanja@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('DDA2103','DDSA-Y2',NULL,'tnabbanja@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('DDA2201','BDSA-Y2','SI-105','galiwango.charles.jovans@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DDA2201','BDSA-Y2',NULL,'galiwango.charles.jovans@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('DDA2201','DDSA-Y2','SI-105','galiwango.charles.jovans@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('DDA2201','DDSA-Y2',NULL,'galiwango.charles.jovans@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('DDA2202','BDSA-Y2','SI-102','dr.tumusiime.andrew.gahwera@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('DDA2202','BDSA-Y2',NULL,'dr.tumusiime.andrew.gahwera@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('DDA2202','DDSA-Y2','SI-102','dr.tumusiime.andrew.gahwera@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('DDA2202','DDSA-Y2',NULL,'dr.tumusiime.andrew.gahwera@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('DDA2203','BCS-Y3','SI-205','bkisakye@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('DDA2203','BIT-Y2','SI-205','bkisakye@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('DDA2203','DDSA-Y2','SI-205','bkisakye@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('DDA2203','DDSA-Y2',NULL,'bkisakye@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('DDA2203','DIT-Y2','SI-205','bkisakye@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('DDA2204','DDSA-Y2',NULL,'d.mackenzie@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('DDA2206','BDSA-Y2','SI-212','mr.nkoloogi.blasius@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('DDA2206','BDSA-Y2',NULL,'mr.nkoloogi.blasius@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('DDA2206','DDSA-Y2','SI-212','mr.nkoloogi.blasius@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('DDA2206','DDSA-Y2',NULL,'mr.nkoloogi.blasius@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('DIT110','BBA-Y1-W','MKN-05','e.nanyonjo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('DIT110','BBA-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DIT110','BBA-Y1','MKN-05','e.nanyonjo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('DIT110','BCS-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DIT110','BDSA-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('DIT110','BDSA-Y1','MKN-05','e.nanyonjo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('DIT110','BEHS-Y1','MKN-05','e.nanyonjo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('DIT110','BIRDS-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('DIT110','BIT-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('DIT110','BJC-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('DIT110','BPAM-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('DIT110','BPH-Y1','MKN-05','e.nanyonjo@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('DIT110','BSE-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DIT110','DBA-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('DIT110','DDSA-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('DIT110','DDSA-Y1','MKN-05','e.nanyonjo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('DIT110','DIT-Y1','SI-214','e.nanyonjo@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('DIT224','BIT-Y3','SI-105','emaganda@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('DIT224','DIT-Y2','SI-105','emaganda@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('DJC110','BBA-Y1','SI-112','hssemakula@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('DJC110','BBA-Y1','KG-15','hssemakula@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('DJC110','BCS-Y1','SI-112','hssemakula@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DJC110','BDSA-Y1','SI-112','hssemakula@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DJC110','BDSA-Y1','KG-15','hssemakula@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('DJC110','BEHS-Y1','MKN-18','btusingwire@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('DJC110','BEHS-Y1','MKN-18','btusingwire@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('DJC110','BIRDS-Y1','KG-14','aondigi@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('DJC110','BIT-Y1','SI-112','hssemakula@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DJC110','BJC-Y1','KG-14','aondigi@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('DJC110','BPAM-Y1','KG-14','aondigi@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('DJC110','BPH-Y1','MKN-18','btusingwire@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DJC110','BSE-Y1','SI-112','hssemakula@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DJC110','DBA-Y1','SI-112','hssemakula@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('DJC110','DDSA-Y1','SI-112','hssemakula@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DJC110','DDSA-Y1','KG-15','hssemakula@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('DJC110','DIT-Y1','SI-112','hssemakula@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('DPS111','DPL-Y1','LLB1','bkirima@cavendish.ac.ug',4,'10:00'::time,'12:00'::time,'physical'),
  ('DPS112','DPL-Y1','LLM','anabwiso@cavendish.ac.ug',2,'14:00'::time,'16:00'::time,'physical'),
  ('DPS113','DPL-Y1','LLB1','bkirima@cavendish.ac.ug',2,'10:00'::time,'12:00'::time,'physical'),
  ('DPS114','DPL-Y1','LLB1','anabwiso@cavendish.ac.ug',5,'10:00'::time,'12:00'::time,'physical'),
  ('DPS115','DPL-Y1','LLB1','anabwiso@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('DPS116','DPL-Y1','LLM','bkirima@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('DPS211','DPL-Y2','LLM',NULL,5,'14:00'::time,'16:00'::time,'physical'),
  ('DPS213','DPL-Y2','LLM',NULL,4,'14:00'::time,'16:00'::time,'physical'),
  ('DPS214','DPL-Y2','LLB2',NULL,4,'12:00'::time,'14:00'::time,'physical'),
  ('DPS215','DPL-Y2','LLB2',NULL,3,'12:00'::time,'14:00'::time,'physical'),
  ('DPS216','DPL-Y2','LLB2',NULL,3,'08:00'::time,'10:00'::time,'physical'),
  ('EHS111','BEHS-Y1','MKN-17','paschal.kibingo@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('EHS112','BEHS-Y1','MKN-15','d.nsubuga@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('EHS112','BPH-Y1','MKN-14','d.nsubuga@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('EHS112','BPH-Y1','MKN-14','d.nsubuga@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('EHS113','BEHS-Y1','MKN-09','i.mugumya@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('EHS121','BEHS-Y1','MKN-14','d.nsubuga@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('EHS121','BEHS-Y1','MKN-15','d.nsubuga@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('EHS121','BPH-Y1','MKN-14','d.nsubuga@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('EHS122','BEHS-Y1','MKN-15','paschal.kibingo@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('EHS124','BEHS-Y1','MKN-08','i.mugumya@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('EHS124','BEHS-Y1','MKN-09','i.mugumya@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('EHS125','BEHS-Y1','MKN-16','dr.kabangi.moses@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('EHS212','BEHS-Y2','MKN-18','paschal.kibingo@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('EHS213','BEHS-Y2','MKN-09','i.mugumya@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('EHS214','BEHS-Y2','MKN-09','mr.katumba.david@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('EHS214','BEHS-Y2','MKN-09','m.taibu@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('EHS214','BPH-Y2','MKN-15','mr.katumba.david@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('EHS214','BPH-Y2','MKN-16','m.taibu@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('EHS215','BEHS-Y2','MKN-16','paschal.kibingo@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('EHS216','BEHS-Y2','MKN-18','m.taibu@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('EHS221','BEHS-Y2','MKN-16','i.mugumya@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('EHS222','BEHS-Y2','MKN-16','dr.kabangi.moses@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('EHS223','BEHS-Y2','MKN-10','i.mugumya@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('EHS223','BEHS-Y2','MKN-15','i.mugumya@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('EHS223','BPH-Y2','MKN-15','i.mugumya@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('EHS223','BPH-Y2','MKN-16','i.mugumya@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('EHS223','DDA-Y1','SI-011','i.mugumya@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('EHS224','BEHS-Y2','MKN-16','dr.kabangi.moses@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('EHS224','BEHS-Y2','MKN-17','dr.kabangi.moses@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('EHS225','BEHS-Y2','MKN-17','dr.kabangi.moses@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('EHS312','BEHS-Y3','MKN-17','m.taibu@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('EHS312','BEHS-Y3','MKN-17','m.taibu@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('EHS313','BEHS-Y3','MKN-10','mr.katumba.david@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('EHS313','BEHS-Y3','MKN-14','b.nabaasa@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('EHS313','BPH-Y3','MKN-10','mr.katumba.david@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('EHS313','BPH-Y3','MKN-17','b.nabaasa@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('EHS314','BEHS-Y3','MKN-15','dr.kabangi.moses@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('EHS315','BEHS-Y3','MKN-14','eric.omonyi@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('EHS316','BEHS-Y3','MKN-15','paschal.kibingo@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('EHS321','BEHS-Y3','MKN-17','m.taibu@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('EHS322','BEHS-Y3','MKN-18','d.nsubuga@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('EHS322','BEHS-Y3','MKN-18','d.nsubuga@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('EHS323','BEHS-Y3','MKN-16','i.mugumya@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('EHS323','BEHS-Y3','MKN-16','m.taibu@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('EHS323','BPH-Y3','MKN-15','i.mugumya@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('EHS323','BPH-Y3','MKN-17','m.taibu@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('ENT312','BBA-Y3',NULL,'tba@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('FOA120','HEC-Y1','SI-105','anabwiso@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('FOA120','HEC-Y1','SI-205','rsamson@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('FOA121','HEC-Y1','KG-15','mr.ngabirano.richard@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('FOA121','HEC-Y1','KG-6','htugume@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('FOA122','BPAM-Y2','SI-B01','trussel@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('FOA122','BPAM-Y2','SI-112','inamaja@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('FOA122','HEC-Y1','SI-B01','trussel@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('FOA122','HEC-Y1','SI-112','inamaja@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('FOA123','HEC-Y1','SI-112','mr.robert.ateng@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('FOA123','HEC-Y1','KG-13','enimusiima@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('FOA124','BIRDS-Y1','SI-B01','vssekundi@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('FOA124','BIRDS-Y1','SI-B01','mr.okello.pasqualine@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('FOA124','BJC-Y1','SI-B01','vssekundi@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('FOA124','BJC-Y1','SI-B01','mr.okello.pasqualine@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('FOA124','BPAM-Y1','SI-B01','vssekundi@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('FOA124','BPAM-Y1','SI-B01','mr.okello.pasqualine@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('FOA124','HEC-Y1-A','SI-B01','vssekundi@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('FOA124','HEC-Y1','SI-B01','mr.okello.pasqualine@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('FOS111','HEC-Y1','MKN-18','sarah.namazzi.1@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('FOS111','HEC-Y1','MKN-09','mr.ssekawu.barnabas@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('FOS112','HEC-Y1','MKN-09','mr.ssengendo.moses@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('FOS112','HEC-Y1','MKN-17','fmugabi@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('FOS125','HEC-Y1','MKN-14','m.kawiso@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('FOS125','HEC-Y1','MKN-14','m.kawiso@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('FOS126','HEC-Y1','MKN-10','mr.ssengendo.moses@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('FOS126','HEC-Y1','MKN-08','fmugabi@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('FOS127','HEC-Y1','MKN-18','sarah.namazzi.1@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('FOS127','HEC-Y1','MKN-09','mr.ssekawu.barnabas@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('FOU110','HEC-Y1','SI-112','fmugabi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('FOU110','HEC-Y1','MKN-18','mr.ssengendo.moses@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('FOU110','HEC-Y1','SI-B01','mr.ssengendo.moses@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('FOU110','HEC-Y1','MKN-14','fmugabi@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('FOU112','HEC-Y1','SI-B01','e.namakula@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('FOU112','HEC-Y1','MKN-18','e.namakula@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('FOU113','HEC-Y1','MKN-17','gopio@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('FOU113','HEC-Y1','SI-112','mr.okello.pasqualine@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('FOU113','HEC-Y1','MKN-17','mr.okello.pasqualine@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('FOU113','HEC-Y1','KG-10','gopio@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('FOU114','HEC-Y1','SI-B01','e.namakula@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('FOU114','HEC-Y1','MKN-18','e.namakula@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('HEC111','HEC-Y1','MKN-05','dr.muhammad.muhammad.kudu@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('HEC111','HEC-Y1','SI-214','tnabbanja@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('HEC111','HEC-Y1','MKN-05','tnabbanja@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('HEC112','HEC-Y1','MKN-18','ckembabazi@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('HEC112','HEC-Y1','MKN-18','ckembabazi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('HEC113','HEC-Y1','SI-B01','aondigi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('HEC113','HEC-Y1','KG-14','aondigi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('HEC115','HEC-Y1','MKN-18','ckembabazi@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('HEC115','HEC-Y1','MKN-18','ckembabazi@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('HEC122','HEC-Y1','KG-15','awabule@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('HEC122','HEC-Y1','KG-15','hbusuulwa@cavendish.ac.ug',5,'16:45'::time,'18:45'::time,'physical'),
  ('HEC123','HEC-Y1','MKN-18','ckembabazi@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('HEC123','HEC-Y1','MKN-18','ckembabazi@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('HEC124','HEC-Y1','MKN-09','ckembabazi@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('HEC124','HEC-Y1','MKN-18','ckembabazi@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('HEC125','HEC-Y1','KG-15','rbisaso@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('HEC125','HEC-Y1','KG-6','ms.noam.everlyn.abenakyo@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('HEC126','HEC-Y1','MKN-19','mr.ssekawu.barnabas@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('HEC126','HEC-Y1','MKN-18','sarah.namazzi.1@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('HEC128','HEC-Y1','MKN-14','awabule@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('HEC128','HEC-Y1','MKN-15','awabule@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('HRM311','BBA-Y3-HRM','KG-11','jmwesigye@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('HRM311','BBA-Y3-HRM','KG-11','jmwesigye@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('HRM311','BBA-Y3','KG-15','jmwesigye@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('HRM311','BBA-Y3','KG-11','jmwesigye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('HRM312','BBA-Y3-HRM','KG-7','jmwesigye@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('HRM312','BBA-Y3-HRM','KG-10','jmwesigye@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('HRM312','BBA-Y3-HRM','KG-10','jmwesigye@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('HRM312','BBA-Y3','KG-7','jmwesigye@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('HRM312','BBA-Y3','KG-10','jmwesigye@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('HRM313','BBA-Y3-HRM','KG-7','bnassozi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('HRM313','BBA-Y3-HRM','KG-9','bnassozi@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('HRM313','BBA-Y3','KG-6','bnassozi@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('HRM313','BBA-Y3','KG-9','bnassozi@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('HRM314','BBA-Y3-HRM','KG-6','rolar@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('HRM314','BBA-Y3-HRM','KG-7','smayanja@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('HRM314','BBA-Y3-HRM','KG-7','rolar@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('HRM314','BBA-Y3','SI-102','smayanja@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('HRM314','BBA-Y3','SI-011','smayanja@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('HRM315','BBA-Y3-HRM','KG-9','d.bakyayita@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('HRM315','BBA-Y3-HRM','KG-7','d.bakyayita@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('HRM315','BBA-Y3','KG-7','d.bakyayita@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('HRM315','BBA-Y3','SI-105','d.bakyayita@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('HRM316','BBA-Y3-G','KG-7','jsambaga@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('HRM316','BBA-Y3-G','KG-11','jsambaga@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('HRM316','BBA-Y3-HRM','KG-7','jsambaga@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('HRM316','BBA-Y3-HRM','KG-11','jsambaga@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('HRM316','BBA-Y3','KG-13','ambabazi@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('HRM316','BBA-Y3','KG-11','ambabazi@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('HRM321',NULL,'KG-9','rolar@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('HRM321','BBA-Y3-HRM','KG-6','rolar@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('HRM321','BBA-Y3-HRM','KG-9','bnassozi@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('HRM321','BBA-Y3','KG-11','bnassozi@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('HRM321','BBA-Y3','KG-9','bnassozi@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('HRM322',NULL,'KG-10','issekalo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('HRM322','BBA-Y3-HRM','SI-102','issekalo@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('HRM322','BBA-Y3-HRM','KG-10','rolar@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('HRM322','BBA-Y3','KG-6','rolar@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('HRM322','BBA-Y3','KG-10','rolar@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('HRM323',NULL,NULL,'rolar@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('HRM323','BBA-Y3-HRM','KG-5','rolar@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('HRM323','BBA-Y3-HRM','KG-13','rolar@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('HRM323','BBA-Y3','KG-5','rolar@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('HRM323','BBA-Y3','KG-13','rolar@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('HRM325',NULL,NULL,'bnassozi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('HRM325','BBA-Y3-HRM','KG-7','bnassozi@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('HRM325','BBA-Y3-HRM','KG-6','bnassozi@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('HRM325','BBA-Y3','KG-9','bnassozi@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('HRM325','BBA-Y3','KG-6','bnassozi@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('HRM325','BPAM-Y1','KG-9','bnassozi@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('HRM325','BPAM-Y1','KG-7','bnassozi@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS111','BIRDS-Y1','KG-10','j.tabalanga@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS112','BIRDS-Y1','KG-10','trussel@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('IRDS112','BIRDS-Y1','KG-10','pakampurira@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('IRDS114','BIRDS-Y1','KG-14','d.wamimbi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS114','BIRDS-Y1','KG-7','d.wamimbi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS121','BIRDS-Y1','SI-B01','vssekundi@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS121','BIRDS-Y1','SI-B01','mr.okello.pasqualine@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS121','BJC-Y1','SI-B01','vssekundi@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS121','BJC-Y1','SI-B01','mr.okello.pasqualine@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS121','BPAM-Y1','SI-B01','vssekundi@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS121','BPAM-Y1','SI-B01','mr.okello.pasqualine@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS121','HEC-Y1-A','SI-B01','vssekundi@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS121','HEC-Y1','SI-B01','mr.okello.pasqualine@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS122','BIRDS-Y1','KG-11','pakampurira@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('IRDS122','BIRDS-Y1','KG-10','pakampurira@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS122','BPAM-Y2','KG-11','pakampurira@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('IRDS122','BPAM-Y2','KG-10','pakampurira@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS124','BIRDS-Y1','KG-10','rwatenyera@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS124','BIRDS-Y1','KG-7','rwatenyera@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS125','BIRDS-Y1','KG-11','rnkongho@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('IRDS125','BIRDS-Y1','KG-11','prof.haruna.ayuba@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('IRDS125','BPAM-Y1','KG-11','rnkongho@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('IRDS125','BPAM-Y1','KG-11','prof.haruna.ayuba@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('IRDS128','BIRDS-Y1','KG-11','trussel@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS128','BIRDS-Y1','KG-11','j.tabalanga@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('IRDS129','BIRDS-Y1','KG-10','rwatenyera@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS211','BIRDS-Y2',NULL,'jkagoro@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'online'),
  ('IRDS211','BIRDS-Y2',NULL,'jkagoro@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'online'),
  ('IRDS213','BIRDS-Y2','SI-012','dr.bello.folaranmi.fatai@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('IRDS213','BPAM-Y1','SI-012','dr.bello.folaranmi.fatai@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('IRDS214','BIRDS-Y2','KG-6','eomaada@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('IRDS214','BIRDS-Y2','KG-11','pakampurira@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS214','BPAM-Y2','KG-6','eomaada@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('IRDS214','BPAM-Y2','KG-11','pakampurira@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS215','BIRDS-Y2','KG-13','j.tabalanga@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS215','BIRDS-Y2','KG-11','dr.bello.folaranmi.fatai@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('IRDS216','BIRDS-Y2','KG-9','j.tabalanga@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS217','BIRDS-Y2','SI-011','awabule@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS217','BIRDS-Y2','KG-11','eomaada@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS222','BIRDS-Y2','KG-13','hbusuulwa@cavendish.ac.ug',4,'16:45'::time,'18:45'::time,'physical'),
  ('IRDS222','BIRDS-Y2','KG-13','prof.haruna.ayuba@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS223','BIRDS-Y2','KG-6','pakampurira@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS223','BIRDS-Y2','KG-6','pakampurira@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS224','BIRDS-Y2','KG-11','j.tabalanga@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('IRDS224','BIRDS-Y2','KG-9','dr.bob.drani@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('IRDS225','BIRDS-Y2','KG-7','pakampurira@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS225','BIRDS-Y2','KG-10','pakampurira@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('IRDS227','BIRDS-Y2','KG-6','j.tabalanga@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS227','BIRDS-Y2','KG-6','j.tabalanga@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('IRDS311','BIRDS-Y3','KG-10','dr.bello.folaranmi.fatai@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS311','BIRDS-Y3','KG-10','trussel@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS311','BPAM-Y3','KG-10','dr.bello.folaranmi.fatai@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS311','BPAM-Y3','KG-10','trussel@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS312','BIRDS-Y3','KG-10','eomaada@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('IRDS312','BIRDS-Y3','KG-7','eomaada@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('IRDS313','BIRDS-Y3','KG-10','rnkongho@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS313','BIRDS-Y3','KG-10','prof.haruna.ayuba@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS314','BIRDS-Y3','KG-7','hbusuulwa@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS314','BIRDS-Y3','KG-7','hbusuulwa@cavendish.ac.ug',2,'16:45'::time,'18:45'::time,'physical'),
  ('IRDS315','BIRDS-Y3','KG-15','vssekundi@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('IRDS315','BIRDS-Y3','KG-9','j.tabalanga@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS316','BIRDS-Y3',NULL,'dr.bob.drani@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'online'),
  ('IRDS316','BIRDS-Y3','KG-6','rnkongho@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS317','BIRDS-Y3',NULL,'jkagoro@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'online'),
  ('IRDS321','BIRDS-Y3','KG-9','awabule@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS321','BIRDS-Y3','KG-10','awabule@cavendish.ac.ug',4,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS322','BIRDS-Y3','KG-13','j.tabalanga@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS322','BIRDS-Y3','KG-7','gopio@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('IRDS323','BIRDS-Y3','KG-11','d.wamimbi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('IRDS324','BIRDS-Y3','KG-14','gopio@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('IRDS325','BIRDS-Y3','KG-13','hbusuulwa@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('IRDS325','BIRDS-Y3','KG-13','hbusuulwa@cavendish.ac.ug',1,'16:45'::time,'18:45'::time,'physical'),
  ('LLB111','LLB-Y1','LLB1','antende@cavendish.ac.ug',1,'10:00'::time,'12:00'::time,'physical'),
  ('LLB111','LLB-Y1','LLB1','antende@cavendish.ac.ug',3,'10:00'::time,'12:00'::time,'physical'),
  ('LLB111','LLB-Y1','LLB1','antende@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('LLB111','LLB-Y1','LLB1','antende@cavendish.ac.ug',7,'10:00'::time,'12:00'::time,'physical'),
  ('LLB112','LLB-Y1','LLB1','dwalyemera@cavendish.ac.ug',1,'14:00'::time,'16:00'::time,'physical'),
  ('LLB112','LLB-Y1','LLB1','dwalyemera@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('LLB112','LLB-Y1','LLB1','dwalyemera@cavendish.ac.ug',6,'14:00'::time,'16:00'::time,'physical'),
  ('LLB112','LLB-Y1','MOOT-COURT','dwalyemera@cavendish.ac.ug',7,'14:00'::time,'16:00'::time,'physical'),
  ('LLB113','LLB-Y1','LLB1','rsamson@cavendish.ac.ug',1,'12:00'::time,'14:00'::time,'physical'),
  ('LLB113','LLB-Y1','LLB1','rsamson@cavendish.ac.ug',5,'12:00'::time,'14:00'::time,'physical'),
  ('LLB113','LLB-Y1','LLB1','gayeranga@cavendish.ac.ug',7,'12:00'::time,'14:00'::time,'physical'),
  ('LLB113','LLB-Y1','LLB1','gayeranga@cavendish.ac.ug',7,'16:00'::time,'18:00'::time,'physical'),
  ('LLB114','LLB-Y1','LLB1','nmugarura@cavendish.ac.ug',4,'10:00'::time,'12:00'::time,'physical'),
  ('LLB114','LLB-Y1','LLB1','nmugarura@cavendish.ac.ug',4,'12:00'::time,'14:00'::time,'physical'),
  ('LLB114','LLB-Y1','LLB1','nmugarura@cavendish.ac.ug',6,'10:00'::time,'12:00'::time,'physical'),
  ('LLB114','LLB-Y1','LLB1','nmugarura@cavendish.ac.ug',6,'16:00'::time,'18:00'::time,'physical'),
  ('LLB115','LLB-Y1','LLB1','ebagenda@cavendish.ac.ug',3,'12:00'::time,'14:00'::time,'physical'),
  ('LLB115','LLB-Y1','LLB1','ebagenda@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('LLB115','LLB-Y1','LLB1','ebagenda@cavendish.ac.ug',6,'12:00'::time,'14:00'::time,'physical'),
  ('LLB115','LLB-Y1','LLB1','ebagenda@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('LLB121','LLB-Y1','LLB2','antende@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('LLB121','LLB-Y1','LLB1','antende@cavendish.ac.ug',2,'10:00'::time,'12:00'::time,'physical'),
  ('LLB121','LLB-Y1','LLB2','antende@cavendish.ac.ug',6,'10:00'::time,'12:00'::time,'physical'),
  ('LLB121','LLB-Y1','LLB2','antende@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('LLB122','LLB-Y1','LLB2','mkayima@cavendish.ac.ug',2,'14:00'::time,'16:00'::time,'physical'),
  ('LLB122','LLB-Y1','LLB2','mkayima@cavendish.ac.ug',4,'12:00'::time,'14:00'::time,'physical'),
  ('LLB122','LLB-Y1','LLB2','mkayima@cavendish.ac.ug',6,'16:00'::time,'18:00'::time,'physical'),
  ('LLB122','LLB-Y1','LLB2','mkayima@cavendish.ac.ug',7,'10:00'::time,'12:00'::time,'physical'),
  ('LLB123','LLB-Y1','LLB3','htuhairwe@cavendish.ac.ug',1,'10:00'::time,'12:00'::time,'physical'),
  ('LLB123','LLB-Y1','LLB2','htuhairwe@cavendish.ac.ug',3,'10:00'::time,'12:00'::time,'physical'),
  ('LLB123','LLB-Y1','LLB2','htuhairwe@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('LLB123','LLB-Y1','LLB2','htuhairwe@cavendish.ac.ug',7,'16:00'::time,'18:00'::time,'physical'),
  ('LLB124','LLB-Y1','LLB2','cnansubuga@cavendish.ac.ug',1,'14:00'::time,'16:00'::time,'physical'),
  ('LLB124','LLB-Y1','LLB2','cnansubuga@cavendish.ac.ug',4,'14:00'::time,'16:00'::time,'physical'),
  ('LLB124','LLB-Y1','LLB2','cnansubuga@cavendish.ac.ug',6,'14:00'::time,'16:00'::time,'physical'),
  ('LLB124','LLB-Y1','LLB2','cnansubuga@cavendish.ac.ug',7,'14:00'::time,'16:00'::time,'physical'),
  ('LLB125','LLB-Y1','LLB2','dbabirye@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('LLB125','LLB-Y1','LLB2','dbabirye@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('LLB125','LLB-Y1','LLB2','dbabirye@cavendish.ac.ug',6,'12:00'::time,'14:00'::time,'physical'),
  ('LLB125','LLB-Y1','LLB2','dbabirye@cavendish.ac.ug',7,'12:00'::time,'14:00'::time,'physical'),
  ('LLB211','LLB-Y2','LLB3','bkirima@cavendish.ac.ug',1,'12:00'::time,'14:00'::time,'physical'),
  ('LLB211','LLB-Y2','LLB3','bkirima@cavendish.ac.ug',4,'14:00'::time,'16:00'::time,'physical'),
  ('LLB211','LLB-Y2','LLB2','bkirima@cavendish.ac.ug',6,'12:00'::time,'14:00'::time,'physical'),
  ('LLB211','LLB-Y2','LLB2','bkirima@cavendish.ac.ug',7,'14:00'::time,'16:00'::time,'physical'),
  ('LLB212','LLB-Y2','LLB2','mnyachieo@cavendish.ac.ug',1,'10:00'::time,'12:00'::time,'physical'),
  ('LLB212','LLB-Y2','LLB2','mnyachieo@cavendish.ac.ug',2,'10:00'::time,'12:00'::time,'physical'),
  ('LLB212','LLB-Y2','LLB2','mnyachieo@cavendish.ac.ug',6,'10:00'::time,'12:00'::time,'physical'),
  ('LLB212','LLB-Y2','LLB2','mnyachieo@cavendish.ac.ug',6,'16:00'::time,'18:00'::time,'physical'),
  ('LLB213','LLB-Y2','LLB3','dbabirye@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('LLB213','LLB-Y2','LLB2','dbabirye@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('LLB213','LLB-Y2','LLB2','dbabirye@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('LLB213','LLB-Y2','LLB2','dbabirye@cavendish.ac.ug',7,'10:00'::time,'12:00'::time,'physical'),
  ('LLB214','LLB-Y2','MOOT-COURT','dbabirye@cavendish.ac.ug',2,'12:00'::time,'14:00'::time,'physical'),
  ('LLB214','LLB-Y2','LLB3','dbabirye@cavendish.ac.ug',4,'12:00'::time,'14:00'::time,'physical'),
  ('LLB214','LLB-Y2','LLB2','dbabirye@cavendish.ac.ug',6,'14:00'::time,'16:00'::time,'physical'),
  ('LLB214','LLB-Y2','LLB2','dbabirye@cavendish.ac.ug',7,'16:00'::time,'18:00'::time,'physical'),
  ('LLB215','LLB-Y2','LLB3','gayeranga@cavendish.ac.ug',1,'14:00'::time,'16:00'::time,'physical'),
  ('LLB215','LLB-Y2','LLB2','gayeranga@cavendish.ac.ug',5,'14:00'::time,'16:00'::time,'physical'),
  ('LLB215','LLB-Y2','LLB2','gayeranga@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('LLB215','LLB-Y2','LLB2','gayeranga@cavendish.ac.ug',7,'18:00'::time,'20:00'::time,'physical'),
  ('LLB221','LLB-Y2','LAB-1','lkatusiime@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('LLB221','LLB-Y2','LLB4','lkatusiime@cavendish.ac.ug',3,'16:00'::time,'18:00'::time,'physical'),
  ('LLB221','LLB-Y2','LLB4','lkatusiime@cavendish.ac.ug',7,'10:00'::time,'12:00'::time,'physical'),
  ('LLB221','LLB-Y2','LAB-1','lkatusiime@cavendish.ac.ug',7,'12:00'::time,'14:00'::time,'physical'),
  ('LLB222','LLB-Y2','LLB4','cnansubuga@cavendish.ac.ug',3,'10:00'::time,'12:00'::time,'physical'),
  ('LLB222','LLB-Y2','LLB4','cnansubuga@cavendish.ac.ug',3,'12:00'::time,'14:00'::time,'physical'),
  ('LLB222','LLB-Y2','LLB3','cnansubuga@cavendish.ac.ug',6,'12:00'::time,'14:00'::time,'physical'),
  ('LLB222','LLB-Y2','LLB3','cnansubuga@cavendish.ac.ug',7,'16:00'::time,'18:00'::time,'physical'),
  ('LLB223','LLB-Y2','LLB3','htuhairwe@cavendish.ac.ug',2,'10:00'::time,'12:00'::time,'physical'),
  ('LLB223','LLB-Y2','LLB1','htuhairwe@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('LLB223','LLB-Y2','LLB3','htuhairwe@cavendish.ac.ug',6,'16:00'::time,'18:00'::time,'physical'),
  ('LLB223','LLB-Y2','LLB3','htuhairwe@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('LLB224','LLB-Y2','LLB1','anabwiso@cavendish.ac.ug',3,'14:45'::time,'16:45'::time,'physical'),
  ('LLB224','LLB-Y2','LLB1','anabwiso@cavendish.ac.ug',5,'10:00'::time,'12:00'::time,'physical'),
  ('LLB224','LLB-Y2','LLB3','bkirima@cavendish.ac.ug',6,'10:00'::time,'12:00'::time,'physical'),
  ('LLB224','LLB-Y2','LLB1','bkirima@cavendish.ac.ug',7,'14:00'::time,'16:00'::time,'physical'),
  ('LLB225','LLB-Y2','LLB3','m.kibukamusoke@cavendish.ac.ug',4,'14:45'::time,'16:45'::time,'physical'),
  ('LLB225','LLB-Y2','LLB2','m.kibukamusoke@cavendish.ac.ug',4,'16:00'::time,'18:00'::time,'physical'),
  ('LLB225','LLB-Y2','LLB3','m.kibukamusoke@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('LLB225','LLB-Y2','LLB3','m.kibukamusoke@cavendish.ac.ug',6,'14:00'::time,'16:00'::time,'physical'),
  ('LLB311','LLB-Y3','LLB4','htuhairwe@cavendish.ac.ug',1,'12:00'::time,'14:00'::time,'physical'),
  ('LLB311','LLB-Y3','LLB2','htuhairwe@cavendish.ac.ug',3,'12:00'::time,'14:00'::time,'physical'),
  ('LLB311','LLB-Y3','LLB4','htuhairwe@cavendish.ac.ug',6,'12:00'::time,'14:00'::time,'physical'),
  ('LLB311','LLB-Y3','LLB3','htuhairwe@cavendish.ac.ug',7,'12:00'::time,'14:00'::time,'physical'),
  ('LLB312','LLB-Y3','LLB1','lkatusiime@cavendish.ac.ug',2,'14:00'::time,'16:00'::time,'physical'),
  ('LLB312','LLB-Y3','LLB1','lkatusiime@cavendish.ac.ug',3,'14:00'::time,'16:00'::time,'physical'),
  ('LLB312','LLB-Y3','LLB4','lkatusiime@cavendish.ac.ug',6,'14:00'::time,'16:00'::time,'physical'),
  ('LLB312','LLB-Y3','LLB3','lkatusiime@cavendish.ac.ug',7,'14:00'::time,'16:00'::time,'physical'),
  ('LLB313','LLB-Y3','LLB3','ayoboka@cavendish.ac.ug',3,'10:00'::time,'12:00'::time,'physical'),
  ('LLB313','LLB-Y3','LLB2','ayoboka@cavendish.ac.ug',5,'12:00'::time,'14:00'::time,'physical'),
  ('LLB313','LLB-Y3','LLB4','ayoboka@cavendish.ac.ug',6,'10:00'::time,'12:00'::time,'physical'),
  ('LLB313','LLB-Y3','LLB4','ayoboka@cavendish.ac.ug',7,'10:00'::time,'12:00'::time,'physical'),
  ('LLB314','LLB-Y3','LLB4','lkatusiime@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('LLB314','LLB-Y3','LLB3','lkatusiime@cavendish.ac.ug',5,'14:00'::time,'16:00'::time,'physical'),
  ('LLB314','LLB-Y3','LLB4','lkatusiime@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('LLB314','LLB-Y3','LLB4','lkatusiime@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('LLB315','LLB-Y3','LLB2','mkayima@cavendish.ac.ug',2,'12:00'::time,'14:00'::time,'physical'),
  ('LLB315','LLB-Y3','LLB4','mkayima@cavendish.ac.ug',4,'10:00'::time,'12:00'::time,'physical'),
  ('LLB315','LLB-Y3','MOOT-COURT','mkayima@cavendish.ac.ug',6,'18:00'::time,'20:00'::time,'physical'),
  ('LLB315','LLB-Y3','LLB4','mkayima@cavendish.ac.ug',7,'16:00'::time,'18:00'::time,'physical'),
  ('LLB322','LLB-Y3','LLM','dwalyemera@cavendish.ac.ug',1,'10:00'::time,'12:00'::time,'physical'),
  ('LLB322','LLB-Y3','LLB3','dwalyemera@cavendish.ac.ug',2,'16:00'::time,'18:00'::time,'physical'),
  ('LLB322','LLB-Y3','LAB-1','dwalyemera@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('LLB322','LLB-Y3','LAB-1','dwalyemera@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('LLB323','LLB-Y3','LLB4','anabwiso@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('LLB323','LLB-Y3','LLB4','anabwiso@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('LLB323','LLB-Y3','MOOT-COURT','anabwiso@cavendish.ac.ug',7,'10:00'::time,'12:00'::time,'physical'),
  ('LLB323','LLB-Y3','LLB4','anabwiso@cavendish.ac.ug',7,'14:00'::time,'16:00'::time,'physical'),
  ('LLB324','LLB-Y3','LLB3','hsalum@cavendish.ac.ug',2,'14:00'::time,'16:00'::time,'physical'),
  ('LLB324','LLB-Y3','LLB3','hsalum@cavendish.ac.ug',5,'10:00'::time,'12:00'::time,'physical'),
  ('LLB324','LLB-Y3','LAB-1','hsalum@cavendish.ac.ug',6,'14:00'::time,'16:00'::time,'physical'),
  ('LLB324','LLB-Y3','LAB-1','hsalum@cavendish.ac.ug',7,'16:00'::time,'18:00'::time,'physical'),
  ('LLB325','LLB-Y3','LLB3','antende@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('LLB325','LLB-Y3','LLB3','antende@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('LLB325','LLB-Y3','LAB-1','antende@cavendish.ac.ug',6,'12:00'::time,'14:00'::time,'physical'),
  ('LLB325','LLB-Y3','LLB4','antende@cavendish.ac.ug',7,'12:00'::time,'14:00'::time,'physical'),
  ('LLB327','LLB-Y3','LLB3','cnansubuga@cavendish.ac.ug',1,'16:00'::time,'18:00'::time,'physical'),
  ('LLB327','LLB-Y3','LLB3','cnansubuga@cavendish.ac.ug',4,'16:00'::time,'18:00'::time,'physical'),
  ('LLB327','LLB-Y3','LLB3','cnansubuga@cavendish.ac.ug',6,'10:00'::time,'12:00'::time,'physical'),
  ('LLB327','LLB-Y3','MOOT-COURT','cnansubuga@cavendish.ac.ug',6,'16:00'::time,'18:00'::time,'physical'),
  ('LLB411','LLB-Y4','LLM','ayoboka@cavendish.ac.ug',3,'08:00'::time,'10:00'::time,'physical'),
  ('LLB411','LLB-Y4','LLB2','ayoboka@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('LLB411','LLB-Y4','LLB4','ayoboka@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('LLB411','LLB-Y4','LLB4','ayoboka@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('LLB412','LLB-Y4','LLB4','mnyachieo@cavendish.ac.ug',1,'14:00'::time,'16:00'::time,'physical'),
  ('LLB412','LLB-Y4','LLB4','mnyachieo@cavendish.ac.ug',2,'12:00'::time,'14:00'::time,'physical'),
  ('LLB412','LLB-Y4','LLB4','mnyachieo@cavendish.ac.ug',6,'15:00'::time,'16:00'::time,'physical'),
  ('LLB412','LLB-Y4','LLB4','mnyachieo@cavendish.ac.ug',7,'16:00'::time,'17:00'::time,'physical'),
  ('LLB413','LLB-Y4','LLM','ebagenda@cavendish.ac.ug',3,'10:00'::time,'12:00'::time,'physical'),
  ('LLB413','LLB-Y4','LLB4','ebagenda@cavendish.ac.ug',4,'14:00'::time,'16:00'::time,'physical'),
  ('LLB413','LLB-Y4','LLB4','ebagenda@cavendish.ac.ug',6,'10:00'::time,'11:00'::time,'physical'),
  ('LLB413','LLB-Y4','LLB4','ebagenda@cavendish.ac.ug',7,'10:00'::time,'12:00'::time,'physical'),
  ('LLB414','LLB-Y4','LLM','hsalum@cavendish.ac.ug',3,'12:00'::time,'14:00'::time,'physical'),
  ('LLB414','LLB-Y4','LLM','hsalum@cavendish.ac.ug',4,'10:00'::time,'12:00'::time,'physical'),
  ('LLB414','LLB-Y4','LLB4','hsalum@cavendish.ac.ug',6,'12:00'::time,'13:00'::time,'physical'),
  ('LLB414','LLB-Y4','LLB4','hsalum@cavendish.ac.ug',7,'11:00'::time,'12:00'::time,'physical'),
  ('LLB416','LLB-Y4','LLB4','rsamson@cavendish.ac.ug',2,'14:00'::time,'16:00'::time,'physical'),
  ('LLB416','LLB-Y4','LLB4','rsamson@cavendish.ac.ug',4,'12:00'::time,'14:00'::time,'physical'),
  ('LLB416','LLB-Y4','LLB4','rsamson@cavendish.ac.ug',6,'16:30'::time,'17:30'::time,'physical'),
  ('LLB416','LLB-Y4','LLB4','rsamson@cavendish.ac.ug',7,'12:00'::time,'14:00'::time,'physical'),
  ('LLB421','LLB-Y4','LLM','mnyachieo@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('LLB421','LLB-Y4','LLM','mnyachieo@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('LLB421','LLB-Y4','MOOT-COURT','mnyachieo@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('LLB421','LLB-Y4','MOOT-COURT','mnyachieo@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('LLB422','LLB-Y4','LLM','sngabirano@cavendish.ac.ug',2,'12:00'::time,'14:00'::time,'physical'),
  ('LLB422','LLB-Y4','LLB1','sngabirano@cavendish.ac.ug',5,'16:00'::time,'18:00'::time,'physical'),
  ('LLB422','LLB-Y4','MOOT-COURT','sngabirano@cavendish.ac.ug',7,'10:00'::time,'12:00'::time,'physical'),
  ('LLB422','LLB-Y4','LAB-1','sngabirano@cavendish.ac.ug',7,'16:00'::time,'18:00'::time,'physical'),
  ('LLB424','LLB-Y4','LLM','ebagenda@cavendish.ac.ug',1,'16:00'::time,'18:00'::time,'physical'),
  ('LLB424','LLB-Y4','LLM','ebagenda@cavendish.ac.ug',2,'10:00'::time,'12:00'::time,'physical'),
  ('LLB424','LLB-Y4','MOOT-COURT','ebagenda@cavendish.ac.ug',6,'10:00'::time,'12:00'::time,'physical'),
  ('LLB424','LLB-Y4','MOOT-COURT','ebagenda@cavendish.ac.ug',7,'12:00'::time,'14:00'::time,'physical'),
  ('LLB426','LLB-Y4','LLM','mkayima@cavendish.ac.ug',1,'12:00'::time,'14:00'::time,'physical'),
  ('LLB426','LLB-Y4','LLM','mkayima@cavendish.ac.ug',1,'14:00'::time,'16:00'::time,'physical'),
  ('LLB426','LLB-Y4','MOOT-COURT','mkayima@cavendish.ac.ug',6,'14:00'::time,'16:00'::time,'physical'),
  ('LLB426','LLB-Y4','MOOT-COURT','mkayima@cavendish.ac.ug',7,'14:00'::time,'16:00'::time,'physical'),
  ('LLM711','LLM-Y1','LLM','ayoboka@cavendish.ac.ug',6,'14:00'::time,'16:00'::time,'physical'),
  ('LLM712','LLM-Y1','LAB-1','dr.robert.mugagga@cavendish.ac.ug',7,'12:00'::time,'14:00'::time,'physical'),
  ('LLM713','LLM-Y1','LLM','nmugarura@cavendish.ac.ug',6,'12:00'::time,'14:00'::time,'physical'),
  ('LLM714','LLM-Y1','MOOT-COURT','dr.robert.mugagga@cavendish.ac.ug',7,'10:00'::time,'12:00'::time,'physical'),
  ('LLM715','LLM-Y1','LLM','prof.olomola.omolade@cavendish.ac.ug',7,'16:00'::time,'18:00'::time,'physical'),
  ('LLM716','LLM-Y1','LLM','sngabirano@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('LLM717','LLM-Y1','LLM','d.wamimbi@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('LLM718','LLM-Y1','LLM','rwatenyera@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('LLM719',NULL,'LLM','gayeranga@cavendish.ac.ug',7,'14:00'::time,'16:00'::time,'physical'),
  ('LLM721','LLM-Y1','LLM','dwalyemera@cavendish.ac.ug',6,'12:00'::time,'14:00'::time,'physical'),
  ('LLM7210','LLM-Y1','LLM','prof.olomola.omolade@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('LLM7211','LLM-Y1','LLM',NULL,6,'10:00'::time,'11:00'::time,'physical'),
  ('LLM722','LLM-Y1','LAB-1','dr.robert.mugagga@cavendish.ac.ug',6,'16:00'::time,'18:00'::time,'physical'),
  ('LLM725','LLM-Y1','LLM','dr.simon.mutungi@cavendish.ac.ug',6,'16:00'::time,'17:00'::time,'physical'),
  ('LLM726','LLM-Y1','LLM','sngabirano@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('LLM727','LLM-Y1','LLM','d.wamimbi@cavendish.ac.ug',7,'14:00'::time,'16:00'::time,'physical'),
  ('LLM729','LLM-Y1','LLM','sngabirano@cavendish.ac.ug',6,'12:00'::time,'14:00'::time,'physical'),
  ('LLM811','LLM-Y1','MOOT-COURT','m.kibukamusoke@cavendish.ac.ug',6,'12:00'::time,'14:00'::time,'physical'),
  ('LLM812','LLM-Y1','LLM','dr.simon.mutungi@cavendish.ac.ug',6,'10:00'::time,'12:00'::time,'physical'),
  ('LLM813','LLM-Y1','LLM','hsalum@cavendish.ac.ug',7,'10:00'::time,'12:00'::time,'physical'),
  ('LLM814','LLM-Y1','LLM','prof.olomola.omolade@cavendish.ac.ug',6,'14:00'::time,'16:00'::time,'physical'),
  ('LLM817','LLM-Y1','LLM','dr.simon.mutungi@cavendish.ac.ug',7,'10:00'::time,'11:00'::time,'physical'),
  ('LLM818','LLM-Y1','LAB-1','dr.robert.mugagga@cavendish.ac.ug',6,'14:00'::time,'16:00'::time,'physical'),
  ('MBA710','MBA-Y1','SI-B01','smayanja@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MBA710','MED-Y1','SI-B01','smayanja@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MBA710','MEM-Y1','SI-B01','smayanja@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MBA710','MPM-Y1','SI-B01','smayanja@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MBA711','MBA-Y1','SI-B01','d.mpubani@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'hybrid'),
  ('MBA711','MPH-Y1','SI-B01','d.mpubani@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'hybrid'),
  ('MBA711','MPM-Y1','SI-B01','d.mpubani@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'hybrid'),
  ('MBA712','MBA-Y1','SI-B01','ykatono@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MBA712','MPM-Y1','SI-B01','ykatono@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MBA716','MBA-Y1','KG-15','m.kawiso@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MBA716','MBA-Y1','KG-15','dr.shuaib.muhammad.rabiu@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MBA716','MPM-Y1','KG-15','m.kawiso@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MBA716','MPM-Y1','KG-15','dr.shuaib.muhammad.rabiu@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MBA721','MBA-Y1','SI-105','smayanja@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('MBA724','MPM-Y2','SI-011','mr.ssekalo.ishmael@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MBA724','MPM-Y2','SI-011','mr.ssekalo.ishmael@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MBA724','MPM-Y2',NULL,'issekalo@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MBA725','MBA-Y1','SI-B01','prof.alex.thomas.ijjo@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MBA726','MBA-Y1','SI-105','dkalembe@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MBA726','MBA-Y1','SI-205','fahabyoona@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MBA727','MBA-Y1-HRM','KG-15','d.bakyayita@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MBA727','MBA-Y2','KG-15','d.bakyayita@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MBA727','MED-Y2','KG-15','d.bakyayita@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MBA727','MEM-Y2','KG-15','d.bakyayita@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MBA727','MPM-Y1','KG-15','d.bakyayita@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MBA728','MBA-Y1','SI-205','prof.olubayi.olubayi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MBA728','MED-Y1','SI-205','prof.olubayi.olubayi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MBA728','MEM-Y1','SI-205','kalone@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MBA728','MIRDS-Y1','SI-205','prof.olubayi.olubayi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MBA728','MIT-Y1','SI-205','prof.olubayi.olubayi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MBA728','MPM-Y1','SI-205','prof.olubayi.olubayi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MBA728','MSS-Y1','SI-205','prof.olubayi.olubayi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MBA729','MBA-Y1','SI-214','kalone@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MBA729','MED-Y1','SI-214','kalone@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MBA729','MEM-Y1','SI-214','ykatono@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MBA729','MIT-Y1','SI-214','kalone@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MBA729','MPM-Y1','SI-214','kalone@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MBA811','MBA-Y1-M','SI-212','m.kawiso@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MBA811','MBA-Y1-M','SI-102','prof.alex.thomas.ijjo@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MBA811','MBA-Y2-M','SI-212','m.kawiso@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MBA811','MBA-Y2','SI-212','m.kawiso@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MBA813','MBA-Y1-M','SI-012','rolar@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MBA813','MBA-Y1-M','SI-012','jsambaga@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MBA813','MBA-Y2','SI-012','rolar@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MBA813','MPM-Y2','SI-012','rolar@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MBA813','MPM-Y2','SI-012','jsambaga@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MBA815','MBA-Y1-M','SI-102','dr.wilberforce.tindyebwa@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MBA815','MBA-Y1-M','SI-102','dr.wilberforce.tindyebwa@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MBA815','MBA-Y2-M','SI-102','dr.wilberforce.tindyebwa@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MBA815','MBA-Y2','SI-102','dr.wilberforce.tindyebwa@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MBF811','MBA-Y1-AF','SI-205','jbaleke@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MBF811','MBA-Y2-AF','SI-205','jbaleke@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MBF811','MBA-Y2','SI-205','jbaleke@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MBF813','MBA-Y1-AF','SI-102','jbaleke@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('MBF813','MBA-Y1-M','SI-102','jbaleke@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('MBF813','MBA-Y2-M','SI-102','fahabyoona@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('MBF813','MBA-Y2','SI-102','fahabyoona@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MBF815','MBA-Y1-AF','SI-202','cmakwasi@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MBF815','MBA-Y2-AF','SI-202','cmakwasi@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MBF815','MBA-Y2','SI-202','cmakwasi@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MBF816','MBA-Y1-AF','SI-105','dkalembe@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MBF816','MBA-Y1-M','SI-105','dkalembe@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MBF816','MBA-Y2-M','SI-105','dkalembe@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MBF816','MBA-Y2','SI-105','dkalembe@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MBF817','MBA-Y1-AF','SI-214','cmakwasi@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MBF817','MBA-Y2-AF','SI-214','mr.ngabirano.richard@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MBF817','MBA-Y2','SI-214','mr.ngabirano.richard@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('MED713','MED-Y1-ONLINE',NULL,'ambabazi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MED713','MED-Y1',NULL,'ambabazi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MED713','MED-Y1','SI-105','ambabazi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MED713','MEM-Y1',NULL,'ambabazi@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MED714','MED-Y1-ONLINE',NULL,'snamazzi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('MED714','MED-Y1',NULL,'snamazzi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('MED714','MEM-Y1',NULL,'snamazzi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MED721','MED-Y1-ONLINE',NULL,'dr.wilberforce.tindyebwa@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('MED721','MED-Y1',NULL,'dr.wilberforce.tindyebwa@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('MED721','MED-Y1',NULL,'dr.wilberforce.tindyebwa@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MED721','MEM-Y1',NULL,'dr.wilberforce.tindyebwa@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('MED722','MED-Y1-ONLINE',NULL,'e.namakula@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MED722','MED-Y1',NULL,'ambabazi@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MED722','MEM-Y1',NULL,'e.namakula@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MED723','MED-Y1-ONLINE',NULL,'pakampurira@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MED723','MED-Y1',NULL,'pakampurira@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MED723','MEM-Y1',NULL,'pakampurira@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MED812','MED-Y2-ONLINE',NULL,'ambabazi@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MED812','MED-Y2',NULL,'ambabazi@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MED812','MEM-Y2',NULL,'ambabazi@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('MED813','MED-Y2-ONLINE',NULL,'dr.wilberforce.tindyebwa@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MED813','MED-Y2',NULL,'dr.wilberforce.tindyebwa@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MED813','MEM-Y2',NULL,'dr.wilberforce.tindyebwa@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MHR722','MBA-Y1-HRM',NULL,'d.bakyayita@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MHR722','MBA-Y1-HRM','SI-105','d.bakyayita@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MHR722','MBA-Y2','SI-105','d.bakyayita@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MHR722','MED-Y2',NULL,'d.bakyayita@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MHR722','MED-Y2','SI-105','d.bakyayita@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MHR722','MEM-Y2','SI-105','d.bakyayita@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MHR722','MIT-Y1',NULL,'d.bakyayita@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MHR722','MIT-Y1','SI-105','d.bakyayita@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MHR811','MBA-Y1-HRM','SI-112','smayanja@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MHR811','MBA-Y1-HRM','SI-112','bnassozi@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MHR811','MBA-Y2-HRM','SI-112','smayanja@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MHR811','MBA-Y2','SI-112','smayanja@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MHR814','MBA-Y1-HRM','SI-012','jmwesigye@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MHR814','MBA-Y2','SI-012','jmwesigye@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MHR814','MED-Y2','SI-012','jmwesigye@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MHR814','MEM-Y2','SI-012','jmwesigye@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MHR815','MBA-Y1-HRM','SI-212','issekalo@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MHR815','MBA-Y1-HRM','SI-212','mr.ssekalo.ishmael@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MHR815','MBA-Y2-HRM','SI-212','mr.ssekalo.ishmael@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MHR815','MBA-Y2','SI-212','mr.ssekalo.ishmael@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MIR711','MIRDS-Y1','KG-9','prof.solomon.muchwa.asiimwe@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MIR711','MSS-Y1','KG-9','prof.solomon.muchwa.asiimwe@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MIR712','MIRDS-Y1','KG-9','rwatenyera@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MIR712','MIRDS-Y1','SI-B01','rwatenyera@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MIR714','LLM-Y1','KG-13','d.wamimbi@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MIR714','MIRDS-Y1','KG-13','d.wamimbi@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MIR715','MIRDS-Y1','KG-9','hbusuulwa@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MIR721','MIRDS-Y1-ONLINE',NULL,'jkagoro@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MIR721','MIRDS-Y1',NULL,'jkagoro@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('MIR721','MIRDS-Y1',NULL,'jkagoro@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MIR722','MIRDS-Y1','KG-13','hbusuulwa@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MIR722','MIRDS-Y1','KG-7','hbusuulwa@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MIR723','MIRDS-Y1','KG-6','rwatenyera@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MIR723','MIRDS-Y1','KG-6','vssekundi@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('MIR724','MIRDS-Y1','KG-13','gopio@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MIR724','MIRDS-Y1','SI-212','dr.bob.drani@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MIR811','MIRDS-Y2','KG-11','prof.noah.midamba@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'hybrid'),
  ('MIR811','MIRDS-Y2','KG-7','prof.noah.midamba@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('MIR811','MSS-Y2','KG-11','prof.noah.midamba@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'hybrid'),
  ('MIR811','MSS-Y2','KG-7','prof.noah.midamba@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('MIR812','MIRDS-Y2','KG-9','eomaada@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MIR812','MIRDS-Y2','KG-13','eomaada@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MIR814','MIRDS-Y2','KG-11','j.tabalanga@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MIT712','MIT-Y1-ONLINE',NULL,'tnabbanja@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('MIT712','MIT-Y1',NULL,'tnabbanja@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('MIT715','MIT-Y1-ONLINE',NULL,'dr.muhammad.muhammad.kudu@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MIT715','MIT-Y1',NULL,'tnabbanja@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MIT716','MIT-Y1-ONLINE',NULL,'emaganda@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MIT716','MIT-Y1',NULL,'emaganda@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MIT717','MIT-Y1-ONLINE',NULL,'hngugi@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MIT717','MIT-Y1',NULL,'kssegawa@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MIT718','MIT-Y1-ONLINE',NULL,'moses.balirwa@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('MIT718','MIT-Y1',NULL,'moses.balirwa@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('MIT721','MIT-Y2-ONLINE',NULL,'jbssemakula@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('MIT721','MIT-Y2',NULL,'jbssemakula@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('MIT722','MIT-Y2-ONLINE',NULL,'mkumakech@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MIT722','MIT-Y2',NULL,'mkumakech@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MIT723','MIT-Y2-ONLINE',NULL,'jbssemakula@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MIT723','MIT-Y2',NULL,'jbssemakula@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MIT725','MIT-Y1-ONLINE',NULL,'mkumakech@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('MIT725','MIT-Y1',NULL,'mkumakech@cavendish.ac.ug',7,'14:30'::time,'16:30'::time,'online'),
  ('MIT725','MIT-Y1',NULL,'mkumakech@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('MIT727','MIT-Y1-ONLINE',NULL,'moses.balirwa@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MIT727','MIT-Y1',NULL,'moses.balirwa@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MIT728','MIT-Y1-ONLINE',NULL,'ichinwe@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MIT728','MIT-Y1',NULL,'ichinwe@cavendish.ac.ug',6,'14:30'::time,'16:30'::time,'online'),
  ('MIT728','MIT-Y1',NULL,'ichinwe@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MIT729','MIT-Y1-ONLINE',NULL,'kalone@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MIT729','MIT-Y1',NULL,'kalone@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MIT821','MIT-Y2-ONLINE',NULL,'hngugi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('MIT821','MIT-Y2',NULL,'kssegawa@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('MIT822','MIT-Y2-ONLINE',NULL,'rtuhaise@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MIT822','MIT-Y2',NULL,'rtuhaise@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MIT823','MIT-Y2-ONLINE',NULL,'ichinwe@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MIT823','MIT-Y2',NULL,'ichinwe@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MKT311','BBA-Y3',NULL,'ykatono@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MKT312','BBA-Y3',NULL,'rkabuye@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MKT313','BBA-Y3',NULL,'ms.noam.everlyn.abenakyo@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MKT322','BBA-Y3',NULL,'mr.ssekalo.ishmael@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MKT323','BBA-Y3',NULL,'rkabuye@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MKT325','BBA-Y3',NULL,'mr.ssekalo.ishmael@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MKT722',NULL,NULL,'issekalo@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('MKT723',NULL,NULL,'eabenakyo@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MKT810',NULL,NULL,'ykatono@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MKT812',NULL,NULL,'ykatono@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MKT814',NULL,NULL,'issekalo@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('MPH713','MPH-Y1',NULL,'prof.atulomah.nnodimele@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('MPH713','MPH-Y1','MKN-15','m.kawiso@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MPH713','MPH-Y1','MKN-17','m.kawiso@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MPH714','MPH-Y1-ONLINE',NULL,'prof.atulomah.nnodimele@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MPH714','MPH-Y1',NULL,'prof.atulomah.nnodimele@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MPH715','MPH-Y1','MKN-09','satuhaire@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MPH715','MPH-Y1','MKN-09','satuhaire@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MPH716','MPH-Y1',NULL,'dmusa@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('MPH716','MPH-Y1','MKN-08','m.kawiso@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MPH721','MPH-Y1-ONLINE',NULL,'dmusa@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MPH721','MPH-Y1',NULL,'dmusa@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MPH722','MPH-Y1-ONLINE',NULL,'i.mugumya@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MPH722','MPH-Y1',NULL,'dmusa@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('MPH722','MPH-Y1',NULL,'i.mugumya@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MPH724','MPH-Y1-ONLINE',NULL,'prof.atulomah.nnodimele@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('MPH724','MPH-Y1',NULL,'prof.atulomah.nnodimele@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('MPH725','MPH-Y1','MKN-09','satuhaire@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MPH725','MPH-Y1','MKN-09','satuhaire@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MPH726','MPH-Y1',NULL,'prof.atulomah.nnodimele@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('MPH726','MPH-Y2-ONLINE',NULL,'prof.atulomah.nnodimele@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MPH726','MPH-Y2',NULL,'prof.atulomah.nnodimele@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MPH727','MPH-Y1','MKN-14','b.nabaasa@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MPH727','MPH-Y2',NULL,'b.nabaasa@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('MPH810','MPH-Y2','MKN-05','dr.kabangi.moses@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MPH810','MPH-Y2',NULL,'dmusa@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MPH812','MPH-Y1-ONLINE',NULL,'prof.atulomah.nnodimele@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MPH812','MPH-Y1',NULL,'prof.atulomah.nnodimele@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('MPH812','MPH-Y1',NULL,'prof.atulomah.nnodimele@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MPH812','MPH-Y2',NULL,'prof.atulomah.nnodimele@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MPH813','MPH-Y2','MKN-17','d.nsubuga@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MPH814','MPH-Y2','MKN-15','dr.ene.bongili.goodness@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MPH814','MPH-Y2','MKN-15','dr.kabangi.moses@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MPH815','MPH-Y1','MKN-05','satuhaire@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MPH815','MPH-Y2','MKN-05','satuhaire@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MPH816','MPH-Y2',NULL,'m.kawiso@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MPH817','MPH-Y2',NULL,'dr.tumusiime.andrew.gahwera@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'online'),
  ('MPH818','MPH-Y2',NULL,'dr.kabangi.moses@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MPH819','MPH-Y2',NULL,'dmusa@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'online'),
  ('MPH825','MPH-Y2',NULL,'satuhaire@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MPH826','MPH-Y2',NULL,'satuhaire@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('MPH827','MPH-Y2',NULL,'dmusa@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MPH828','MPH-Y2',NULL,'dr.ene.bongili.goodness@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MPH829','MPH-Y2',NULL,'dr.ene.bongili.goodness@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MPH835','MPH-Y2',NULL,'b.nabaasa@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'online'),
  ('MPH836','MPH-Y2',NULL,'dr.tumusiime.andrew.gahwera@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'online'),
  ('MPH837','MPH-Y2',NULL,'bkwesiga@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MPH838','MPH-Y2',NULL,'dr.tumusiime.andrew.gahwera@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MPH839','MPH-Y2',NULL,'b.nabaasa@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MPH840','MPH-Y2',NULL,'d.nsubuga@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MPM715','MBA-Y1','SI-B01','d.mpubani@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'hybrid'),
  ('MPM715','MPH-Y1','SI-B01','d.mpubani@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'hybrid'),
  ('MPM715','MPM-Y1','SI-B01','d.mpubani@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'hybrid'),
  ('MPM720','MED-Y1','SI-202','smayanja@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MPM720','MEM-Y1','SI-102','dr.shuaib.muhammad.rabiu@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MPM720','MPM-Y1','SI-202','smayanja@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MPM720','MPM-Y1','SI-102','dr.shuaib.muhammad.rabiu@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MPM721','MPM-Y1','SI-011','mturyareeba@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MPM721','MPM-Y1','SI-011','mr.ngabirano.richard@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('MPM721','MPM-Y1','SI-012','mr.ngabirano.richard@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MPM722','MBA-Y1-PS',NULL,'rkabuye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MPM722','MBA-Y1-PS','KG-7','rkabuye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MPM722','MBA-Y2','SI-012','rkabuye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MPM722','MPM-Y1',NULL,'rkabuye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MPM722','MPM-Y1','KG-7','rkabuye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MPM722','MPM-Y1','SI-012','rkabuye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MPM811','MPM-Y2',NULL,'prof.alex.thomas.ijjo@cavendish.ac.ug',6,'16:45'::time,'18:45'::time,'online'),
  ('MPM811','MPM-Y2','SI-102','prof.alex.thomas.ijjo@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MPM813','MPM-Y2','SI-112','snamazzi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MPM813','MPM-Y2','SI-202','spule@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MPM814','MPM-Y2',NULL,'smayanja@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MPM814','MPM-Y2','SI-102','smayanja@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MSC720','MBA-Y1-PS','SI-011','ms.noam.everlyn.abenakyo@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MSC720','MBA-Y1-PS','SI-011','jsambaga@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MSC720','MBA-Y2-PS','SI-011','ms.noam.everlyn.abenakyo@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MSC720','MBA-Y2','SI-011','ms.noam.everlyn.abenakyo@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MSC721','MBA-Y1-PS','SI-202','rkabuye@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MSC721','MBA-Y2-PS','SI-202','rkabuye@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MSC721','MBA-Y2','SI-202','rkabuye@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MSC722','MBA-Y1-PS',NULL,'rkabuye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MSC722','MBA-Y1-PS','KG-7','rkabuye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MSC722','MBA-Y2','SI-012','rkabuye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MSC722','MPM-Y1',NULL,'rkabuye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'online'),
  ('MSC722','MPM-Y1','KG-7','rkabuye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MSC722','MPM-Y1','SI-012','rkabuye@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MSC810','MBA-Y1-PS','SI-202','spule@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MSC810','MBA-Y2-PS','SI-202','spule@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MSC810','MBA-Y2','SI-202','spule@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MSC814','MBA-Y1-PS','SI-212','spule@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MSC814','MBA-Y2-PS','SI-212','spule@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MSC814','MBA-Y2','SI-212','spule@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('MSS712','MIRDS-Y1','KG-13','prof.solomon.muchwa.asiimwe@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MSS712','MIRDS-Y1','SI-011','prof.solomon.muchwa.asiimwe@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MSS712','MSS-Y1','KG-13','prof.solomon.muchwa.asiimwe@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MSS712','MSS-Y1','SI-011','prof.solomon.muchwa.asiimwe@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MSS714','MSS-Y1','KG-11','d.wamimbi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MSS716','MSS-Y1','KG-11','rwatenyera@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MSS716','MSS-Y1','SI-102','rwatenyera@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MSS721','MSS-Y1','KG-11','prof.solomon.muchwa.asiimwe@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MSS722','MSS-Y1','SI-011','prof.solomon.muchwa.asiimwe@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('MSS723','MSS-Y1','KG-7','dr.bello.folaranmi.fatai@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('MSS723','MSS-Y1','KG-7','dr.bello.folaranmi.fatai@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MSS723','MSS-Y1','SI-B12','trussel@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MSS724','MIRDS-Y2','KG-10','eomaada@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MSS724','MSS-Y1','KG-10','eomaada@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MSS725','MSS-Y1','SI-012','prof.noah.midamba@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('MSS725','MSS-Y1',NULL,'prof.noah.midamba@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'online'),
  ('MSS725','MSS-Y1','KG-7','prof.noah.midamba@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MSS810','MSS-Y2',NULL,'prof.noah.midamba@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'online'),
  ('MSS810','MSS-Y2','KG-7','prof.noah.midamba@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('MSS811','MSS-Y2-ONLINE',NULL,'jkagoro@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MSS811','MSS-Y2',NULL,'jkagoro@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'online'),
  ('MSS811','MSS-Y2','KG-10','jkagoro@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('MSS812','MIRDS-Y2','KG-11','prof.noah.midamba@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'hybrid'),
  ('MSS812','MIRDS-Y2','KG-7','prof.noah.midamba@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('MSS812','MSS-Y2','KG-11','prof.noah.midamba@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'hybrid'),
  ('MSS812','MSS-Y2','KG-7','prof.noah.midamba@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('MSS813','MIRDS-Y2','KG-11','eomaada@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MSS813','MSS-Y2','KG-11','eomaada@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('MSS814','MSS-Y2','KG-9','dr.bello.folaranmi.fatai@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('MSS814','MSS-Y2','KG-6','rnkongho@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('NGO316','BPAM-Y2','SI-011','inamaja@cavendish.ac.ug',4,'08:00'::time,'10:00'::time,'physical'),
  ('NGO316','BPAM-Y2','SI-011','inamaja@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('PLM311','BBA-Y1-W','KG-15','ckabasinguzi@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('PLM311','BBA-Y1','KG-15','ckabasinguzi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('PLM311','BBA-Y1','KG-14','ckabasinguzi@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('PLM311','BBA-Y1','KG-15','ckabasinguzi@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('PLM314','BBA-Y3-G','KG-7','smayanja@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('PLM314','BBA-Y3-G','SI-105','smayanja@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('PLM314','BBA-Y3-PL','KG-7','smayanja@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('PLM314','BBA-Y3-PL','SI-105','smayanja@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('PLM314','BBA-Y3','KG-7','mr.ssekalo.ishmael@cavendish.ac.ug',1,'08:00'::time,'10:00'::time,'physical'),
  ('PLM314','BBA-Y3','SI-105','mr.ssekalo.ishmael@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('PLM315','BBA-Y3-PL','KG-6','ckabasinguzi@cavendish.ac.ug',3,'10:15'::time,'12:15'::time,'physical'),
  ('PLM315','BBA-Y3-PL','KG-6','ckabasinguzi@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('PLM315','BBA-Y3','KG-7','dr.shuaib.muhammad.rabiu@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('PLM315','BBA-Y3','KG-6','dr.shuaib.muhammad.rabiu@cavendish.ac.ug',6,'12:30'::time,'14:30'::time,'physical'),
  ('PLM316','BBA-Y3-PL','KG-9','rkabuye@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('PLM316','BBA-Y3-PL','KG-9','rkabuye@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('PLM316','BBA-Y3','KG-9','rkabuye@cavendish.ac.ug',4,'12:30'::time,'14:30'::time,'physical'),
  ('PLM316','BBA-Y3','KG-9','rkabuye@cavendish.ac.ug',7,'08:00'::time,'10:00'::time,'physical'),
  ('PLM317','BBA-Y3-PL','KG-10','ckabasinguzi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('PLM317','BBA-Y3-PL','KG-6','ckabasinguzi@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('PLM317','BBA-Y3','KG-10','ckabasinguzi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('PLM317','BBA-Y3','KG-6','ckabasinguzi@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('PLM317','BPAM-Y3','KG-10','ckabasinguzi@cavendish.ac.ug',2,'10:15'::time,'12:15'::time,'physical'),
  ('PLM318','BBA-Y3-PL','KG-11','aasadi@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('PLM318','BBA-Y3-PL','KG-7','aasadi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('PLM318','BBA-Y3','KG-10','aasadi@cavendish.ac.ug',2,'14:45'::time,'16:45'::time,'physical'),
  ('PLM318','BBA-Y3','KG-7','aasadi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('PLM319','BBA-Y3-PL','KG-9','aasadi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('PLM319','BBA-Y3-PL','KG-11','aasadi@cavendish.ac.ug',7,'10:15'::time,'12:15'::time,'physical'),
  ('PLM319','BBA-Y3','KG-13','aasadi@cavendish.ac.ug',2,'12:30'::time,'14:30'::time,'physical'),
  ('PLM319','BBA-Y3','KG-11','aasadi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('PLM322',NULL,'KG-6','ckabasinguzi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('PLM322','BBA-Y3-PL','KG-7','ckabasinguzi@cavendish.ac.ug',5,'14:45'::time,'16:45'::time,'physical'),
  ('PLM322','BBA-Y3-PL','KG-6','ckabasinguzi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('PLM322','BBA-Y3','KG-11','ckabasinguzi@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('PLM322','BBA-Y3','KG-5','ckabasinguzi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('PLM324',NULL,'KG-7','aasadi@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('PLM324','BBA-Y3-PL','KG-9','aasadi@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('PLM324','BBA-Y3-PL','KG-7','aasadi@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('PLM324','BBA-Y3','KG-10','aasadi@cavendish.ac.ug',2,'08:00'::time,'10:00'::time,'physical'),
  ('PLM324','BBA-Y3','KG-7','aasadi@cavendish.ac.ug',7,'12:30'::time,'14:30'::time,'physical'),
  ('PLM326',NULL,'KG-6','spule@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('PLM326','BBA-Y3-PL','KG-7','spule@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('PLM326','BBA-Y3-PL','KG-6','spule@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('PLM326','BBA-Y3','KG-7','spule@cavendish.ac.ug',5,'08:00'::time,'10:00'::time,'physical'),
  ('PLM326','BBA-Y3','KG-6','spule@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('PLM327',NULL,'KG-13','ckabasinguzi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('PLM327','BBA-Y3-PL','KG-9','ckabasinguzi@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('PLM327','BBA-Y3-PL','KG-13','ckabasinguzi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('PLM327','BBA-Y3','KG-11','ckabasinguzi@cavendish.ac.ug',1,'14:45'::time,'16:45'::time,'physical'),
  ('PLM327','BBA-Y3','KG-13','ckabasinguzi@cavendish.ac.ug',6,'14:45'::time,'16:45'::time,'physical'),
  ('PLM328',NULL,'KG-11','spule@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('PLM328','BBA-Y3-PL','KG-11','spule@cavendish.ac.ug',1,'12:30'::time,'14:30'::time,'physical'),
  ('PLM328','BBA-Y3-PL','KG-11','spule@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('PLM328','BBA-Y3','KG-7','spule@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('PLM328','BBA-Y3','KG-11','spule@cavendish.ac.ug',7,'14:45'::time,'16:45'::time,'physical'),
  ('RSC001','BBA-Y2-W','MKN-14','ambabazi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'hybrid'),
  ('RSC001','BBA-Y2','SI-B01','ambabazi@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('RSC001','BBA-Y2','KG-10','ambabazi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('RSC001','BBA-Y2','KG-7','ambabazi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'physical'),
  ('RSC001','BEHS-Y2','MKN-14','ambabazi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'hybrid'),
  ('RSC001','BIRDS-Y2','SI-105','ambabazi@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('RSC001','BIRDS-Y2','KG-15','ambabazi@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('RSC001','BJC-Y2','SI-105','ambabazi@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('RSC001','BJC-Y2','KG-15','ambabazi@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('RSC001','BPAM-Y2','SI-105','ambabazi@cavendish.ac.ug',3,'12:30'::time,'14:30'::time,'physical'),
  ('RSC001','BPH-Y1','MKN-15','ambabazi@cavendish.ac.ug',6,'10:15'::time,'12:15'::time,'hybrid'),
  ('RSC001','BPH-Y2','MKN-15','dr.ene.bongili.goodness@cavendish.ac.ug',1,'10:15'::time,'12:15'::time,'physical'),
  ('RSC001','BPH-Y2','KG-15','ambabazi@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('RSC001','DBA-Y2','KG-15','ambabazi@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('RSC001','DBA-Y2','SI-B01','ambabazi@cavendish.ac.ug',5,'12:30'::time,'14:30'::time,'physical'),
  ('RSC001','DDA-Y1','KG-15','spule@cavendish.ac.ug',5,'10:15'::time,'12:15'::time,'physical'),
  ('RSC003','MBA-Y1','SI-B01','dr.wilberforce.tindyebwa@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('RSC003','MED-Y1','SI-B01','dr.wilberforce.tindyebwa@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('RSC003','MEM-Y1','SI-B01','ykatono@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('RSC003','MIRDS-Y1','SI-B01','dr.wilberforce.tindyebwa@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('RSC003','MPM-Y1','SI-B01','dr.wilberforce.tindyebwa@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical'),
  ('RSC003','MSS-Y1','SI-B01','dr.wilberforce.tindyebwa@cavendish.ac.ug',6,'08:00'::time,'10:00'::time,'physical')
) AS p(module_code,class_code,room_code,lecturer_email,day_num,start_time,end_time,session_mode)
CROSS JOIN (SELECT id FROM semesters WHERE name = 'Semester I 2026/2027') s
JOIN modules m ON m.code = p.module_code
LEFT JOIN classes c ON c.code = p.class_code
LEFT JOIN facilities f ON f.room_number = p.room_code
LEFT JOIN users u ON lower(u.email) = lower(p.lecturer_email)
CROSS JOIN LATERAL (SELECT generate_series(date '2026-08-03', date '2026-12-21', interval '7 days')::date AS week_start) w
CROSS JOIN LATERAL (SELECT (w.week_start + (p.day_num - 1) + p.start_time) AT TIME ZONE 'Africa/Kampala' AS start_at,
                            (w.week_start + (p.day_num - 1) + p.end_time) AT TIME ZONE 'Africa/Kampala' AS end_at) t
ON CONFLICT (id) DO NOTHING;

-- Marker so server startup does not replay this seed on every boot
INSERT INTO settings (key,value) VALUES ('cavendish_seed_applied','true'::jsonb) ON CONFLICT (key) DO UPDATE SET value = 'true'::jsonb, updated_at = now();

COMMIT;

-- Summary: 5 depts | 29 programmes | 106 classes | 146 lecturers | 563 modules | 47 rooms | 1182 class/module links | 1909 weekly patterns