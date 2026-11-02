/**
 * generate_seed.js
 * Run: node src/db/generate_seed.js
 * Reads the Cavendish timetable Excel and produces sql/seed_cavendish.sql
 */
import { createRequire } from 'node:module';
import { writeFileSync } from 'node:fs';
import { randomUUID } from 'node:crypto';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const XLSX = require('xlsx');
const here = path.dirname(fileURLToPath(import.meta.url));

const EXCEL = 'C:/Users/Personal/.gemini/antigravity/brain/a9c48d15-8212-488d-91d4-fb96d3d3838d/.user_uploaded/media_1793589894713_2c03681f.xlsx';
const OUT = path.resolve(here, '..', '..', 'sql', 'seed_cavendish.sql');

// ── Bcrypt placeholder (matches "Cavendish@2026") ────────────────────────────
const BCRYPT = '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy';

// ── Departments ───────────────────────────────────────────────────────────────
const DEPTS = [
  { id: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', code: 'FST', name: 'Faculty of Science and Technology' },
  { id: '0d35fa69-de7f-4e05-b800-16c07321e75f', code: 'BUS', name: 'Faculty of Business' },
  { id: '422a6c15-127f-47d5-a044-e7547d35dcb6', code: 'SES', name: 'Faculty of Social and Environmental Studies' },
  { id: '06a806fc-0d90-4c27-877d-1025a3ebdbd1', code: 'HEC', name: 'Faculty of Health and Environmental Sciences' },
];
const DEPT_BY_ID = Object.fromEntries(DEPTS.map(d => [d.id, d]));

// ── Programme → dept mapping ──────────────────────────────────────────────────
const PROGS = [
  // FST
  { id: '73593c0f-0478-45b5-a87d-a8e87f5ea274', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', code: 'BIT',   name: 'Bachelor of Science in Information Technology',   years: 3 },
  { id: '16fe7428-a4af-4fb3-a543-b1e0fad14ed5', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', code: 'BSE',   name: 'Bachelor of Science in Software Engineering',      years: 3 },
  { id: 'ab14f4ae-0ab9-425a-8a1e-82ac52a467cc', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', code: 'BCS',   name: 'Bachelor of Computer Science',                   years: 3 },
  { id: 'ac00b024-3929-4702-9a14-b216830ab328', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', code: 'DIT',   name: 'Diploma in Information Technology',               years: 2 },
  { id: '406f66f5-ea30-4071-9d85-d6029d0fcb05', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', code: 'MIT',   name: 'Master of Information Technology',               years: 2 },
  { id: 'ec2c1740-c4d5-4056-854f-50cf368c00ab', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', code: 'BDSA',  name: 'Bachelor of Data Science and Analytics',         years: 3 },
  { id: '88dfce47-1365-4820-be5c-669abfc2dd42', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', code: 'DDSA',  name: 'Diploma in Data Science and Analytics',          years: 2 },
  // BUS
  { id: '46a86d77-2f4c-4f44-a5ed-83d51354b863', dept: '0d35fa69-de7f-4e05-b800-16c07321e75f', code: 'BBA',   name: 'Bachelor of Business Administration',            years: 3 },
  { id: '41e287d8-9ca6-412e-9a3c-ed2e389036da', dept: '0d35fa69-de7f-4e05-b800-16c07321e75f', code: 'DBA',   name: 'Diploma in Business Administration',             years: 2 },
  { id: '7ccf2f00-fc18-49f2-a479-52e834f32aaa', dept: '0d35fa69-de7f-4e05-b800-16c07321e75f', code: 'MBA',   name: 'Master of Business Administration',              years: 2 },
  // SES
  { id: 'a1b2c3d4-1234-5678-abcd-000000000001', dept: '422a6c15-127f-47d5-a044-e7547d35dcb6', code: 'BJCS',  name: 'Bachelor of Journalism and Communication Studies', years: 3 },
  { id: 'a1b2c3d4-1234-5678-abcd-000000000002', dept: '422a6c15-127f-47d5-a044-e7547d35dcb6', code: 'BPAM',  name: 'Bachelor of Public Administration and Management', years: 3 },
  { id: 'a1b2c3d4-1234-5678-abcd-000000000003', dept: '422a6c15-127f-47d5-a044-e7547d35dcb6', code: 'BIRDS', name: 'Bachelor of International Relations and Diplomatic Studies', years: 3 },
  { id: 'a1b2c3d4-1234-5678-abcd-000000000004', dept: '422a6c15-127f-47d5-a044-e7547d35dcb6', code: 'BEHS',  name: 'Bachelor of Environmental Health Sciences',       years: 3 },
  // HEC
  { id: 'b1b2c3d4-1234-5678-abcd-000000000001', dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1', code: 'BPH',   name: 'Bachelor of Public Health',                     years: 3 },
  { id: 'b1b2c3d4-1234-5678-abcd-000000000002', dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1', code: 'MPH',   name: 'Master of Public Health',                       years: 2 },
  { id: 'b1b2c3d4-1234-5678-abcd-000000000003', dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1', code: 'ADHM',  name: 'Advanced Diploma in Health Management',          years: 1 },
  { id: 'b1b2c3d4-1234-5678-abcd-000000000004', dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1', code: 'MSS',   name: 'Master of Social Sciences',                     years: 2 },
  { id: 'b1b2c3d4-1234-5678-abcd-000000000005', dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1', code: 'MEM',   name: 'Master of Environmental Management',             years: 2 },
  { id: 'b1b2c3d4-1234-5678-abcd-000000000006', dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1', code: 'MPM',   name: 'Master of Project Management',                  years: 2 },
  { id: 'b1b2c3d4-1234-5678-abcd-000000000007', dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1', code: 'MIRDS', name: 'Master of International Relations and Diplomatic Studies', years: 2 },
];
const PROG_BY_CODE = Object.fromEntries(PROGS.map(p => [p.code, p]));

// ── Code prefix → programme mapping ──────────────────────────────────────────
function guessProgFromCode(code) {
  const prefixes = ['BDSA','DDSA','BJCS','BPAM','BIRDS','BEHS','MIRDS','ADHM','BIT','BSE','BCS','DIT','MIT','BBA','DBA','MBA','BPH','MPH','MSS','MEM','MPM'];
  for (const p of prefixes) {
    if (code.startsWith(p)) return PROG_BY_CODE[p] || null;
  }
  // shared codes like COM, BJC, IDS, BPA, COM
  if (code.startsWith('COM')) return PROG_BY_CODE['BCS'];
  if (code.startsWith('BJC')) return PROG_BY_CODE['BJCS'];
  if (code.startsWith('IDS') || code.startsWith('IRDS')) return PROG_BY_CODE['BIRDS'];
  if (code.startsWith('BPA') || code.startsWith('IPA')) return PROG_BY_CODE['BPAM'];
  return null;
}

// ── Parse Excel: extract all course-code → {name, lecturer, sheet} entries ───
const wb = XLSX.readFile(EXCEL);
const courseMap = {}; // code → { name, lecturer }

for (const shName of wb.SheetNames) {
  const ws = wb.Sheets[shName];
  if (!ws) continue;
  const rows = XLSX.utils.sheet_to_json(ws, { header: 1, defval: '' });
  for (let i = 0; i < rows.length - 1; i++) {
    const row = rows[i];
    const nextRow = rows[i + 1] || [];
    for (let j = 0; j < row.length; j++) {
      const cell = String(row[j]).trim();
      const lecCell = String(nextRow[j] || '').trim();
      if (/^[A-Z]{2,6}\d{3,4}/.test(cell) && cell.includes(':')) {
        const colonIdx = cell.indexOf(':');
        const rawCode = cell.substring(0, colonIdx).trim();
        const name = cell.substring(colonIdx + 1).trim();
        // Handle combined codes like "BBA116/DBA116" - register both
        const codes = rawCode.split('/').map(c => c.trim()).filter(c => /^[A-Z]{2,6}\d{3,4}$/.test(c));
        for (const code of codes) {
          if (code && name && !courseMap[code]) {
            courseMap[code] = { name, lecturer: lecCell || null };
          }
        }
      }
    }
  }
}

console.log(`Parsed ${Object.keys(courseMap).length} unique course codes from Excel`);

// ── Build lecturer registry (name → {id, email, dept}) ────────────────────────
// Map lecturer names from Excel to the seeded user records
const LECTURERS = [
  { id: '47835404-5a90-4960-bee7-2b7cb6f9f4df', name: 'Ms. Nanyonjo Evelyn',      email: 'e.nanyonjo@cavendish.ac.ug',   dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a' },
  { id: '1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1', name: 'Mr. Maganda Evans',         email: 'm.maganda@cavendish.ac.ug',    dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a' },
  { id: '57b2fc7a-f5a8-4a0a-a558-ee8759a4981f', name: 'Ms. Deborah Mackenzie',      email: 'd.mackenzie@cavendish.ac.ug',  dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a' },
  { id: '22640f68-e8c9-43e7-bd70-59ba276acbbb', name: 'Mr. Mpubani David',           email: 'd.mpubani@cavendish.ac.ug',    dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a' },
  { id: 'def38337-4c53-49c3-b348-7612934115ad', name: 'Mr. Ivan Mugumya',            email: 'i.mugumya@cavendish.ac.ug',    dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a' },
  { id: '6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f', name: 'Mr. Mpiima Dennis',           email: 'd.mpiima@cavendish.ac.ug',     dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a' },
  { id: 'c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847', name: 'Mr. Kasumba Shadrach',        email: 's.kasumba@cavendish.ac.ug',    dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a' },
  { id: 'dce6f48f-a7e1-4b28-bad2-20ba1d81bebe', name: 'Mr. Ssejjemba Martin',        email: 'm.ssejjemba@cavendish.ac.ug',  dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a' },
  { id: '7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11', name: 'Ms. Bridget Nuwagaba',        email: 'b.nuwagaba@cavendish.ac.ug',   dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a' },
  { id: 'aee10928-3a11-4b2e-9e41-0b34d0f2f19b', name: 'Dr. Racheal Ainembabazi',     email: 'r.ainembabazi@cavendish.ac.ug',dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a' },
  // BUS
  { id: 'bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78', name: 'Mr. Kawiso Martin Wilfred',   email: 'm.kawiso@cavendish.ac.ug',     dept: '0d35fa69-de7f-4e05-b800-16c07321e75f' },
  { id: '1a3a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3', name: 'Mr. Bakyayita David',         email: 'd.bakyayita@cavendish.ac.ug',  dept: '0d35fa69-de7f-4e05-b800-16c07321e75f' },
  { id: '2b4b5d9e-6c6f-5e6g-c7b8-d9e0f1a2b3c4', name: 'Mr. Muhwezi Moses',            email: 'm.muhwezi@cavendish.ac.ug',    dept: '0d35fa69-de7f-4e05-b800-16c07321e75f' },
  { id: '3c5c6eaf-7d7g-6f7h-d8c9-e0f1a2b3c4d5', name: 'Mr. Bamuswankwire Charles',    email: 'c.bamuswankwire@cavendish.ac.ug', dept: '0d35fa69-de7f-4e05-b800-16c07321e75f' },
  { id: '4d6d7fbg-8e8h-7g8i-e9d0-f1a2b3c4d5e6', name: 'Mr. Senyonga Martin',          email: 'm.senyonga@cavendish.ac.ug',   dept: '0d35fa69-de7f-4e05-b800-16c07321e75f' },
  { id: '5e7e8gch-9f9i-8h9j-f0e1-a2b3c4d5e6f7', name: 'Mr. Mwesigwa Henry',           email: 'h.mwesigwa@cavendish.ac.ug',   dept: '0d35fa69-de7f-4e05-b800-16c07321e75f' },
  { id: '6f8f9hdi-0g0j-9i0k-g1f2-b3c4d5e6f7g8', name: 'Ms. Nakiganda Harriet',        email: 'h.nakiganda@cavendish.ac.ug',  dept: '0d35fa69-de7f-4e05-b800-16c07321e75f' },
  { id: '7g9g0iej-1h1k-0j1l-h2g3-c4d5e6f7g8h9', name: 'Mr. Sseguya Ivan',             email: 'i.sseguya@cavendish.ac.ug',    dept: '0d35fa69-de7f-4e05-b800-16c07321e75f' },
  // SES
  { id: '8h0h1jfk-2i2l-1k2m-i3h4-d5e6f7g8h9i0', name: 'Ms. Namakula Elizabeth',      email: 'e.namakula@cavendish.ac.ug',   dept: '422a6c15-127f-47d5-a044-e7547d35dcb6' },
  { id: '9i1i2kgl-3j3m-2l3n-j4i5-e6f7g8h9i0j1', name: 'Ms. Nnagadya Sumayah',        email: 's.nnagadya@cavendish.ac.ug',   dept: '422a6c15-127f-47d5-a044-e7547d35dcb6' },
  { id: 'ai2j3lhm-4k4n-3m4o-k5j6-f7g8h9i0j1k2', name: 'Dr. Fiona Tumusiime',         email: 'f.tumusiime@cavendish.ac.ug',  dept: '422a6c15-127f-47d5-a044-e7547d35dcb6' },
  { id: 'bj3k4min-5l5o-4n5p-l6k7-g8h9i0j1k2l3', name: 'Dr. Kibukamusoke Martha',     email: 'm.kibukamusoke@cavendish.ac.ug',dept: '422a6c15-127f-47d5-a044-e7547d35dcb6' },
  { id: 'ck4l5njo-6m6p-5o6q-m7l8-h9i0j1k2l3m4', name: 'Mr. Denis Wamimbi',           email: 'd.wamimbi@cavendish.ac.ug',    dept: '422a6c15-127f-47d5-a044-e7547d35dcb6' },
  { id: 'dl5m6okp-7n7q-6p7r-n8m9-i0j1k2l3m4n5', name: 'Mr. Jonathan Tabalanga',      email: 'j.tabalanga@cavendish.ac.ug',  dept: '422a6c15-127f-47d5-a044-e7547d35dcb6' },
  { id: 'em6n7plq-8o8r-7q8s-o9n0-j1k2l3m4n5o6', name: 'Dr. Abdulrazak Yugua Madu',   email: 'a.madu@cavendish.ac.ug',       dept: '422a6c15-127f-47d5-a044-e7547d35dcb6' },
  { id: 'fn7o8qmr-9p9s-8r9t-p0o1-k2l3m4n5o6p7', name: 'Prof. Love Aruguobiani',      email: 'l.aruguobiani@cavendish.ac.ug',dept: '422a6c15-127f-47d5-a044-e7547d35dcb6' },
  // HEC
  { id: 'go8p9rns-0q0t-9s0u-q1p2-l3m4n5o6p7q8', name: 'Ms. Khawa Namajja',           email: 'k.namajja@cavendish.ac.ug',    dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1' },
  { id: 'hp9q0sot-1r1u-0t1v-r2q3-m4n5o6p7q8r9', name: 'Ms. Juliet Bandaru',          email: 'j.bandaru@cavendish.ac.ug',    dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1' },
  { id: 'iq0r1tpu-2s2v-1u2w-s3r4-n5o6p7q8r9s0', name: 'Mr. Bruce Nabaasa',           email: 'b.nabaasa@cavendish.ac.ug',    dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1' },
  { id: 'jr1s2uqv-3t3w-2v3x-t4s5-o6p7q8r9s0t1', name: 'Mr. Murami Taibu',            email: 'm.taibu@cavendish.ac.ug',      dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1' },
  { id: 'ks2t3vrw-4u4x-3w4y-u5t6-p7q8r9s0t1u2', name: 'Mr. Deo Nsubuga',             email: 'd.nsubuga@cavendish.ac.ug',    dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1' },
];

// Build lookup: fuzzy name → id
function normName(s) {
  return String(s).toLowerCase()
    .replace(/^(mr\.|ms\.|mrs\.|dr\.|prof\.)\s*/i, '')
    .replace(/[^a-z]/g, '');
}
const LEC_BY_NORM = {};
for (const l of LECTURERS) {
  LEC_BY_NORM[normName(l.name)] = l;
}
function findLecturer(rawName) {
  if (!rawName) return null;
  // direct
  const n = normName(rawName);
  if (LEC_BY_NORM[n]) return LEC_BY_NORM[n];
  // partial: check if any key starts with n or n starts with key
  for (const [key, lec] of Object.entries(LEC_BY_NORM)) {
    if (key.includes(n.slice(0, 8)) || n.includes(key.slice(0, 8))) return lec;
  }
  return null;
}

// ── Semester ──────────────────────────────────────────────────────────────────
const SEM_ID = 'af9a8e4b-4808-4b3f-b9c3-905be5215722';

// ── Build modules list ────────────────────────────────────────────────────────
const modules = [];
for (const [code, { name, lecturer }] of Object.entries(courseMap)) {
  const prog = guessProgFromCode(code);
  const dept = prog ? prog.dept : '96178a5a-1a50-43ad-ace6-045b0e7dd47a';
  const lec = findLecturer(lecturer);
  modules.push({
    id: randomUUID(),
    code,
    name,
    dept,
    prog_id: prog ? prog.id : null,
    lecturer_id: lec ? lec.id : null,
    lecturer_name: lecturer || null,
  });
}

// ── Classes per programme ─────────────────────────────────────────────────────
const CLASSES = [];
for (const prog of PROGS) {
  for (let yr = 1; yr <= prog.years; yr++) {
    CLASSES.push({
      id: randomUUID(),
      prog_id: prog.id,
      dept: prog.dept,
      code: `${prog.code}-Y${yr}`,
      name: `${prog.code} Year ${yr}`,
      year: yr,
    });
  }
}

// ── Facilities (Cavendish campus rooms) ───────────────────────────────────────
// lat/lng: Cavendish University Uganda, Kampala (~0.3173, 32.5716)
const BASE_LAT = 0.3173;
const BASE_LNG = 32.5716;
function mkQrSecret() { return randomUUID().replace(/-/g, ''); }

const FACILITIES = [
  // Block A — FST
  { id: 'f1000001-0000-0000-0000-000000000001', name: 'LR1 - Lecture Hall A',           cat: 'lecture_room', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', bldg: 'Block A', floor: 'Ground Floor', wing: 'East',  room: 'LR1',   desc: 'Main lecture hall, ground floor Block A - FST',          cap: 120 },
  { id: 'f1000001-0000-0000-0000-000000000002', name: 'LR2 - Lecture Hall B',           cat: 'lecture_room', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', bldg: 'Block A', floor: 'Ground Floor', wing: 'West',  room: 'LR2',   desc: 'Lecture hall ground floor west wing - FST',              cap: 100 },
  { id: 'f1000001-0000-0000-0000-000000000003', name: 'LR3 - Seminar Room A',           cat: 'lecture_room', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', bldg: 'Block A', floor: 'First Floor',  wing: 'East',  room: 'LR3',   desc: 'First floor seminar room - FST',                         cap:  60 },
  { id: 'f1000001-0000-0000-0000-000000000004', name: 'LR4 - Seminar Room B',           cat: 'lecture_room', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', bldg: 'Block A', floor: 'First Floor',  wing: 'West',  room: 'LR4',   desc: 'First floor seminar room west - FST',                    cap:  60 },
  { id: 'f1000001-0000-0000-0000-000000000005', name: 'LR5 - Tutorial Room A',          cat: 'lecture_room', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', bldg: 'Block A', floor: 'Second Floor', wing: 'East',  room: 'LR5',   desc: 'Tutorial room second floor - FST',                       cap:  40 },
  { id: 'f1000001-0000-0000-0000-000000000006', name: 'IT Lab 1 - Computer Lab',        cat: 'lab',          dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', bldg: 'Block A', floor: 'Ground Floor', wing: 'North', room: 'LAB1',  desc: 'Computer lab with 50 workstations - FST',                cap:  50 },
  { id: 'f1000001-0000-0000-0000-000000000007', name: 'IT Lab 2 - Software Lab',        cat: 'lab',          dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', bldg: 'Block A', floor: 'First Floor',  wing: 'North', room: 'LAB2',  desc: 'Software engineering and networking lab - FST',          cap:  40 },
  { id: 'f1000001-0000-0000-0000-000000000008', name: 'IT Lab 3 - Data Science Lab',    cat: 'lab',          dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', bldg: 'Block A', floor: 'Second Floor', wing: 'North', room: 'LAB3',  desc: 'Data science and analytics lab - FST',                   cap:  35 },
  // Block B — Business
  { id: 'f2000001-0000-0000-0000-000000000001', name: 'LR6 - Business Lecture Hall A',  cat: 'lecture_room', dept: '0d35fa69-de7f-4e05-b800-16c07321e75f', bldg: 'Block B', floor: 'Ground Floor', wing: 'East',  room: 'LR6',   desc: 'Main lecture hall Block B - Business Faculty',           cap: 120 },
  { id: 'f2000001-0000-0000-0000-000000000002', name: 'LR7 - Business Lecture Hall B',  cat: 'lecture_room', dept: '0d35fa69-de7f-4e05-b800-16c07321e75f', bldg: 'Block B', floor: 'Ground Floor', wing: 'West',  room: 'LR7',   desc: 'Lecture hall west wing Block B - Business',              cap: 100 },
  { id: 'f2000001-0000-0000-0000-000000000003', name: 'LR8 - Business Seminar A',       cat: 'lecture_room', dept: '0d35fa69-de7f-4e05-b800-16c07321e75f', bldg: 'Block B', floor: 'First Floor',  wing: 'East',  room: 'LR8',   desc: 'Seminar room first floor - Business Faculty',            cap:  60 },
  { id: 'f2000001-0000-0000-0000-000000000004', name: 'LR9 - Business Seminar B',       cat: 'lecture_room', dept: '0d35fa69-de7f-4e05-b800-16c07321e75f', bldg: 'Block B', floor: 'First Floor',  wing: 'West',  room: 'LR9',   desc: 'Seminar room first floor west - Business',               cap:  60 },
  { id: 'f2000001-0000-0000-0000-000000000005', name: 'LR10 - MBA Seminar Room',        cat: 'lecture_room', dept: '0d35fa69-de7f-4e05-b800-16c07321e75f', bldg: 'Block B', floor: 'Second Floor', wing: 'East',  room: 'LR10',  desc: 'MBA and postgraduate seminar room - Business',           cap:  50 },
  { id: 'f2000001-0000-0000-0000-000000000006', name: 'Business IT Lab',                cat: 'lab',          dept: '0d35fa69-de7f-4e05-b800-16c07321e75f', bldg: 'Block B', floor: 'Ground Floor', wing: 'North', room: 'BLAB1', desc: 'Computer lab for Business and Accounting students',      cap:  40 },
  // Block C — SES
  { id: 'f3000001-0000-0000-0000-000000000001', name: 'LR11 - Social Studies Hall A',   cat: 'lecture_room', dept: '422a6c15-127f-47d5-a044-e7547d35dcb6', bldg: 'Block C', floor: 'Ground Floor', wing: 'East',  room: 'LR11',  desc: 'Main lecture hall Block C - SES Faculty',                cap: 100 },
  { id: 'f3000001-0000-0000-0000-000000000002', name: 'LR12 - Social Studies Hall B',   cat: 'lecture_room', dept: '422a6c15-127f-47d5-a044-e7547d35dcb6', bldg: 'Block C', floor: 'Ground Floor', wing: 'West',  room: 'LR12',  desc: 'Lecture hall west Block C - SES',                        cap:  80 },
  { id: 'f3000001-0000-0000-0000-000000000003', name: 'LR13 - Social Sciences Seminar', cat: 'lecture_room', dept: '422a6c15-127f-47d5-a044-e7547d35dcb6', bldg: 'Block C', floor: 'First Floor',  wing: 'East',  room: 'LR13',  desc: 'Seminar room first floor - SES Faculty',                 cap:  50 },
  { id: 'f3000001-0000-0000-0000-000000000004', name: 'LR14 - Law and Governance Room', cat: 'lecture_room', dept: '422a6c15-127f-47d5-a044-e7547d35dcb6', bldg: 'Block C', floor: 'First Floor',  wing: 'West',  room: 'LR14',  desc: 'Tutorial room for Law and Governance students',          cap:  40 },
  // Block C/D — HEC
  { id: 'f4000001-0000-0000-0000-000000000001', name: 'LR15 - Health Sciences Hall A',  cat: 'lecture_room', dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1', bldg: 'Block C', floor: 'Second Floor', wing: 'East',  room: 'LR15',  desc: 'Lecture hall second floor - HEC Faculty',                cap: 100 },
  { id: 'f4000001-0000-0000-0000-000000000002', name: 'LR16 - Health Sciences Hall B',  cat: 'lecture_room', dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1', bldg: 'Block C', floor: 'Second Floor', wing: 'West',  room: 'LR16',  desc: 'Lecture hall second floor west - HEC',                   cap:  80 },
  { id: 'f4000001-0000-0000-0000-000000000003', name: 'LR17 - Environmental Seminar',   cat: 'lecture_room', dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1', bldg: 'Block D', floor: 'Ground Floor', wing: 'East',  room: 'LR17',  desc: 'Seminar room Block D - Environmental Science',           cap:  50 },
  { id: 'f4000001-0000-0000-0000-000000000004', name: 'Health Sciences Lab',            cat: 'lab',          dept: '06a806fc-0d90-4c27-877d-1025a3ebdbd1', bldg: 'Block D', floor: 'Ground Floor', wing: 'West',  room: 'HLAB1', desc: 'Health sciences practical lab - HEC Faculty',            cap:  40 },
  // Shared
  { id: 'f5000001-0000-0000-0000-000000000001', name: 'Main Auditorium',                cat: 'lecture_room', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', bldg: 'Main Building', floor: 'Ground Floor', wing: 'Centre', room: 'AUD1',  desc: 'Main campus auditorium - all faculties', cap: 300 },
  { id: 'f5000001-0000-0000-0000-000000000002', name: 'Conference Room 1',              cat: 'discussion_room', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', bldg: 'Main Building', floor: 'First Floor', wing: 'East', room: 'CONF1', desc: 'Conference and meeting room - Main Building', cap: 30 },
  { id: 'f5000001-0000-0000-0000-000000000003', name: 'Conference Room 2',              cat: 'discussion_room', dept: '0d35fa69-de7f-4e05-b800-16c07321e75f', bldg: 'Main Building', floor: 'First Floor', wing: 'West', room: 'CONF2', desc: 'Conference and meeting room west - Main Building', cap: 30 },
  { id: 'f5000001-0000-0000-0000-000000000004', name: 'Library Reading Hall',           cat: 'library',      dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', bldg: 'Library Block', floor: 'Ground Floor', wing: 'Centre', room: 'LIB1', desc: 'Main campus library reading hall', cap: 80 },
  { id: 'f5000001-0000-0000-0000-000000000005', name: 'Library Quiet Study Room',       cat: 'discussion_room', dept: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', bldg: 'Library Block', floor: 'First Floor', wing: 'East', room: 'LIB2', desc: 'Quiet study room - Library Block', cap: 25 },
  { id: 'f5000001-0000-0000-0000-000000000006', name: 'Student Discussion Room A',      cat: 'discussion_room', dept: '0d35fa69-de7f-4e05-b800-16c07321e75f', bldg: 'Block B', floor: 'Second Floor', wing: 'West', room: 'DISC1', desc: 'Student group discussion room - Block B', cap: 20 },
  { id: 'f5000001-0000-0000-0000-000000000007', name: 'Student Discussion Room B',      cat: 'discussion_room', dept: '422a6c15-127f-47d5-a044-e7547d35dcb6', bldg: 'Block C', floor: 'Second Floor', wing: 'West', room: 'DISC2', desc: 'Student group discussion room - Block C', cap: 20 },
];

// ── Equipment per facility ────────────────────────────────────────────────────
const EQUIPMENT = [
  ['f1000001-0000-0000-0000-000000000001','Projector',2],['f1000001-0000-0000-0000-000000000001','Whiteboard',2],['f1000001-0000-0000-0000-000000000001','Microphone',1],
  ['f1000001-0000-0000-0000-000000000002','Projector',1],['f1000001-0000-0000-0000-000000000002','Whiteboard',2],
  ['f1000001-0000-0000-0000-000000000003','Projector',1],['f1000001-0000-0000-0000-000000000003','Whiteboard',1],
  ['f1000001-0000-0000-0000-000000000004','Projector',1],['f1000001-0000-0000-0000-000000000004','Whiteboard',1],
  ['f1000001-0000-0000-0000-000000000005','Whiteboard',1],
  ['f1000001-0000-0000-0000-000000000006','Computer',50],['f1000001-0000-0000-0000-000000000006','Projector',1],
  ['f1000001-0000-0000-0000-000000000007','Computer',40],['f1000001-0000-0000-0000-000000000007','Projector',1],
  ['f1000001-0000-0000-0000-000000000008','Computer',35],['f1000001-0000-0000-0000-000000000008','Projector',1],
  ['f2000001-0000-0000-0000-000000000001','Projector',2],['f2000001-0000-0000-0000-000000000001','Whiteboard',2],['f2000001-0000-0000-0000-000000000001','Microphone',1],
  ['f2000001-0000-0000-0000-000000000002','Projector',1],['f2000001-0000-0000-0000-000000000002','Whiteboard',2],
  ['f2000001-0000-0000-0000-000000000003','Projector',1],['f2000001-0000-0000-0000-000000000003','Whiteboard',1],
  ['f2000001-0000-0000-0000-000000000004','Projector',1],
  ['f2000001-0000-0000-0000-000000000005','Projector',1],
  ['f2000001-0000-0000-0000-000000000006','Computer',40],['f2000001-0000-0000-0000-000000000006','Projector',1],
  ['f3000001-0000-0000-0000-000000000001','Projector',2],['f3000001-0000-0000-0000-000000000001','Whiteboard',2],
  ['f3000001-0000-0000-0000-000000000002','Projector',1],['f3000001-0000-0000-0000-000000000002','Whiteboard',2],
  ['f3000001-0000-0000-0000-000000000003','Projector',1],['f3000001-0000-0000-0000-000000000003','Whiteboard',1],
  ['f3000001-0000-0000-0000-000000000004','Whiteboard',1],
  ['f4000001-0000-0000-0000-000000000001','Projector',2],['f4000001-0000-0000-0000-000000000001','Whiteboard',2],
  ['f4000001-0000-0000-0000-000000000002','Projector',1],['f4000001-0000-0000-0000-000000000002','Whiteboard',2],
  ['f4000001-0000-0000-0000-000000000003','Projector',1],['f4000001-0000-0000-0000-000000000003','Whiteboard',1],
  ['f4000001-0000-0000-0000-000000000004','Microscope',10],
  ['f5000001-0000-0000-0000-000000000001','Projector',4],['f5000001-0000-0000-0000-000000000001','Microphone',4],['f5000001-0000-0000-0000-000000000001','Whiteboard',2],
  ['f5000001-0000-0000-0000-000000000002','Projector',1],['f5000001-0000-0000-0000-000000000002','Whiteboard',1],
  ['f5000001-0000-0000-0000-000000000003','Projector',1],['f5000001-0000-0000-0000-000000000003','Whiteboard',1],
  ['f5000001-0000-0000-0000-000000000004','Computer',10],
  ['f5000001-0000-0000-0000-000000000005','Whiteboard',1],
];

// ── SQL helpers ───────────────────────────────────────────────────────────────
const q = (v) => v === null ? 'NULL' : `'${String(v).replace(/'/g, "''")}'`;

// ── Generate SQL ──────────────────────────────────────────────────────────────
const lines = [];
lines.push(`-- Cavendish University Uganda — Full Timetable Seed`);
lines.push(`-- Generated: ${new Date().toISOString()}`);
lines.push(`-- Safe to re-run: uses ON CONFLICT DO UPDATE / DO NOTHING`);
lines.push('');
lines.push('BEGIN;');
lines.push('');

// Departments
lines.push('-- Departments (Faculties)');
for (const d of DEPTS) {
  lines.push(`INSERT INTO departments (id, code, name) VALUES (${q(d.id)},${q(d.code)},${q(d.name)}) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name;`);
}

// Semester
lines.push('');
lines.push('-- Semester');
lines.push(`INSERT INTO semesters (id, name, start_date, end_date, is_current) VALUES (${q(SEM_ID)},'Semester I 2026/2027','2026-08-01','2026-12-31',true) ON CONFLICT (name) DO UPDATE SET is_current = true;`);

// Programmes
lines.push('');
lines.push('-- Programmes');
for (const p of PROGS) {
  lines.push(`INSERT INTO programmes (id, department_id, code, name, duration_years) VALUES (${q(p.id)},${q(p.dept)},${q(p.code)},${q(p.name)},${p.years}) ON CONFLICT (department_id, code) DO UPDATE SET name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;`);
}

// Classes
lines.push('');
lines.push('-- Classes (one per year per programme)');
for (const c of CLASSES) {
  lines.push(`INSERT INTO classes (id, programme_id, department_id, code, name, year_of_study, intake, stream) VALUES (${q(c.id)},${q(c.prog_id)},${q(c.dept)},${q(c.code)},${q(c.name)},${c.year},'Main','Day') ON CONFLICT (programme_id, name, intake, stream) DO NOTHING;`);
}

// Lecturers (users with role=lecturer)
lines.push('');
lines.push('-- Lecturers');
for (const l of LECTURERS) {
  const qrHash = randomUUID().replace(/-/g,'');
  const handle = `CU-${randomUUID().substring(0,8).toUpperCase()}`;
  const secret = randomUUID().replace(/-/g,'').substring(0,48);
  lines.push(`INSERT INTO users (id, id_number, name, email, role, department_id, password_hash, qr_token_hash, qr_handle, qr_secret, study_mode, is_active) VALUES (${q(l.id)},${q('LEC-' + l.email.split('@')[0].toUpperCase())},${q(l.name)},${q(l.email)},'lecturer',${q(l.dept)},${q(BCRYPT)},${q(qrHash)},${q(handle)},${q(secret)},'physical',true) ON CONFLICT (email) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, role = 'lecturer';`);
}

// Modules (with programme_id added via ALTER TABLE if needed)
lines.push('');
lines.push('-- Add programme_id and credit_units columns to modules if missing');
lines.push(`ALTER TABLE modules ADD COLUMN IF NOT EXISTS programme_id uuid REFERENCES programmes(id) ON DELETE SET NULL;`);
lines.push(`ALTER TABLE modules ADD COLUMN IF NOT EXISTS credit_units integer NOT NULL DEFAULT 3 CHECK (credit_units BETWEEN 1 AND 10);`);
lines.push('');
lines.push('-- Modules');
for (const m of modules) {
  lines.push(`INSERT INTO modules (id, code, name, department_id, programme_id, lecturer_id, credit_units) VALUES (${q(m.id)},${q(m.code)},${q(m.name)},${q(m.dept)},${q(m.prog_id)},${q(m.lecturer_id)},3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;`);
}

// Facilities — with correct columns
lines.push('');
lines.push('-- Facilities (Lecture Rooms, Labs, Library)');
for (let i = 0; i < FACILITIES.length; i++) {
  const f = FACILITIES[i];
  const lat = (BASE_LAT + (i * 0.0001)).toFixed(6);
  const lng = (BASE_LNG + (i * 0.0001)).toFixed(6);
  const secret = mkQrSecret();
  lines.push(`INSERT INTO facilities (id, name, category, department_id, building, floor, wing, room_number, location_description, latitude, longitude, capacity, status, checkin_mode, checkin_radius_m, qr_secret, qr_version) VALUES (${q(f.id)},${q(f.name)},${q(f.cat)},${q(f.dept)},${q(f.bldg)},${q(f.floor)},${q(f.wing)},${q(f.room)},${q(f.desc)},${lat},${lng},${f.cap},'active','static_geo',50,${q(secret)},1) ON CONFLICT (id) DO UPDATE SET name=EXCLUDED.name, category=EXCLUDED.category, building=EXCLUDED.building, floor=EXCLUDED.floor, wing=EXCLUDED.wing, room_number=EXCLUDED.room_number, location_description=EXCLUDED.location_description, capacity=EXCLUDED.capacity, status=EXCLUDED.status, latitude=EXCLUDED.latitude, longitude=EXCLUDED.longitude;`);
}

// Equipment
lines.push('');
lines.push('-- Facility Equipment');
for (const [fid, name, qty] of EQUIPMENT) {
  lines.push(`INSERT INTO facility_equipment (facility_id, name, quantity) VALUES (${q(fid)},${q(name)},${qty}) ON CONFLICT (facility_id, name) DO UPDATE SET quantity = EXCLUDED.quantity;`);
}

lines.push('');
lines.push('COMMIT;');
lines.push('');
lines.push(`-- Summary:`);
lines.push(`-- Departments: ${DEPTS.length}`);
lines.push(`-- Programmes:  ${PROGS.length}`);
lines.push(`-- Classes:     ${CLASSES.length}`);
lines.push(`-- Modules:     ${modules.length}`);
lines.push(`-- Lecturers:   ${LECTURERS.length}`);
lines.push(`-- Facilities:  ${FACILITIES.length}`);

writeFileSync(OUT, lines.join('\n'), 'utf8');
console.log(`\nWrote ${lines.length} lines to ${OUT}`);
console.log(`Summary: ${DEPTS.length} depts, ${PROGS.length} progs, ${CLASSES.length} classes, ${modules.length} modules, ${LECTURERS.length} lecturers, ${FACILITIES.length} facilities`);
