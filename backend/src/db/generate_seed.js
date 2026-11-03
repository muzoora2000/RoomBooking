/**
 * generate_seed.js  â€”  node src/db/generate_seed.js
 *
 * Reads the Cavendish University timetable workbook and writes
 * sql/seed_cavendish.sql with the real faculties, programmes, classes,
 * lecturers, modules, rooms and timetable slots from the workbook.
 *
 * Requires the `xlsx` dev dependency (`npm install` in backend/).
 */
import { createRequire } from 'node:module';
import { writeFileSync } from 'node:fs';
import { createHash, randomUUID } from 'node:crypto';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const require = createRequire(import.meta.url);
const XLSX = require('xlsx');

const here = path.dirname(fileURLToPath(import.meta.url));
const EXCEL = process.env.CAVENDISH_EXCEL
  || 'C:/Users/Personal/.gemini/antigravity/brain/a9c48d15-8212-488d-91d4-fb96d3d3838d/.user_uploaded/media_1793589894713_2c03681f.xlsx';
const OUT = path.resolve(here, '..', '..', 'sql', 'seed_cavendish.sql');

const SEM_NAME = 'Semester I 2026/2027';
const SEM_START = '2026-08-01';
const SEM_END = '2026-12-31';
// Weekly occurrences are expanded from the first Monday of the teaching period.
const TEACHING_FIRST_MONDAY = '2026-08-03';
const TEACHING_LAST_MONDAY = '2026-12-21';
const BCRYPT = '$2a$10$KLY.X6MaGHVQByIhx2i/8edcUm/Dx69m6.h4oqRTOiPLW4W0Ckmu2'; // Cavendish@2026

const q = (value) => value === null || value === undefined
  ? 'NULL'
  : `'${String(value).replace(/'/g, "''")}'`;
const clean = (value) => String(value ?? '').replace(/\s+/g, ' ').trim();
const normName = (value) => clean(value)
  .toLowerCase()
  .replace(/^(mr\.?|ms\.?|mrs\.?|dr\.?|prof\.?|assoc\.?\s*prof\.?)\s*/i, '')
  .replace(/[^a-z]/g, '');
const slugify = (value) => clean(value)
  .normalize('NFKD')
  .replace(/[^\x00-\x7F]/g, '')
  .toLowerCase()
  .replace(/[^a-z0-9]+/g, '.')
  .replace(/^\.+|\.+$/g, '')
  .slice(0, 40) || 'lecturer';

function uuidFrom(value) {
  const h = createHash('sha1').update(String(value)).digest('hex');
  const variant = ((parseInt(h[16], 16) & 0x3) | 0x8).toString(16);
  return `${h.slice(0, 8)}-${h.slice(8, 12)}-4${h.slice(13, 16)}-${variant}${h.slice(17, 20)}-${h.slice(20, 32)}`;
}
const sha256 = (value) => createHash('sha256').update(String(value)).digest('hex');

// â”€â”€ Faculties â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const DEPTS = [
  { id: '96178a5a-1a50-43ad-ace6-045b0e7dd47a', code: 'FST', name: 'Faculty of Science and Technology' },
  { id: '0d35fa69-de7f-4e05-b800-16c07321e75f', code: 'BUS', name: 'Faculty of Business' },
  { id: '422a6c15-127f-47d5-a044-e7547d35dcb6', code: 'SES', name: 'Faculty of Social and Environmental Studies' },
  { id: '06a806fc-0d90-4c27-877d-1025a3ebdbd1', code: 'HEC', name: 'Faculty of Health and Environmental Sciences' },
  { id: '5a7c1e2d-3b4f-4a6c-8d9e-0f1a2b3c4d5e', code: 'LAW', name: 'Faculty of Law' },
];
const DEPT_BY_CODE = Object.fromEntries(DEPTS.map((dept) => [dept.code, dept]));
const FACULTY_TO_DEPT = {
  FST: 'FST', SCI: 'FST', SCIENCE: 'FST',
  BUS: 'BUS', BUSINESS: 'BUS',
  SES: 'SES', SOCIAL: 'SES',
  HEC: 'HEC', HEALTH: 'HEC',
  LAW: 'LAW'
};

// â”€â”€ Programmes â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const PROGS = [
  // Faculty of Science and Technology
  { id: '73593c0f-0478-45b5-a87d-a8e87f5ea274', dept: 'FST', code: 'BIT', name: 'Bachelor of Science in Information Technology', years: 3 },
  { id: '16fe7428-a4af-4fb3-a543-b1e0fad14ed5', dept: 'FST', code: 'BSE', name: 'Bachelor of Science in Software Engineering', years: 4 },
  { id: 'ab14f4ae-0ab9-425a-8a1e-82ac52a467cc', dept: 'FST', code: 'BCS', name: 'Bachelor of Computer Science', years: 3 },
  { id: 'ac00b024-3929-4702-9a14-b216830ab328', dept: 'FST', code: 'DIT', name: 'Diploma in Information Technology', years: 2 },
  { id: '406f66f5-ea30-4071-9d85-d6029d0fcb05', dept: 'FST', code: 'MIT', name: 'Master of Information Technology', years: 2 },
  { id: 'ec2c1740-c4d5-4056-854f-50cf368c00ab', dept: 'FST', code: 'BDSA', name: 'Bachelor of Data Science and Analytics', years: 3 },
  { id: '88dfce47-1365-4820-be5c-669abfc2dd42', dept: 'FST', code: 'DDSA', name: 'Diploma in Data Science and Analytics', years: 2 },
  { id: 'e1b66000-0001-4000-8000-000000000005', dept: 'FST', code: 'DCS', name: 'Diploma in Computer Science', years: 2 },
  { id: 'e1b66000-0001-4000-8000-000000000006', dept: 'FST', code: 'DDA', name: 'Diploma in Data Analytics', years: 2 },
  { id: 'e1b66000-0001-4000-8000-000000000007', dept: 'FST', code: 'BDA', name: 'Bachelor of Data Analytics', years: 3 },
  // Faculty of Business
  { id: '46a86d77-2f4c-4f44-a5ed-83d51354b863', dept: 'BUS', code: 'BBA', name: 'Bachelor of Business Administration', years: 3 },
  { id: '41e287d8-9ca6-412e-9a3c-ed2e389036da', dept: 'BUS', code: 'DBA', name: 'Diploma in Business Administration', years: 2 },
  { id: '7ccf2f00-fc18-49f2-a479-52e834f32aaa', dept: 'BUS', code: 'MBA', name: 'Master of Business Administration', years: 2 },
  { id: 'e1b66000-0001-4000-8000-000000000008', dept: 'BUS', code: 'DPL', name: 'Diploma in Public Law', years: 2 },
  { id: 'aaaaaaaa-bbbb-4bbb-bbbb-bbbbbbbbbbbb', dept: 'BUS', code: 'MPM', name: 'Master of Project Management', years: 2 },
  // Faculty of Social and Environmental Studies
  { id: '11111111-aaaa-4aaa-aaaa-aaaaaaaaaaaa', dept: 'SES', code: 'BJC', name: 'Bachelor of Journalism and Communication', years: 3 },
  { id: '22222222-aaaa-4aaa-aaaa-aaaaaaaaaaaa', dept: 'SES', code: 'BPAM', name: 'Bachelor of Public Administration and Management', years: 3 },
  { id: '33333333-aaaa-4aaa-aaaa-aaaaaaaaaaaa', dept: 'SES', code: 'BIRDS', name: 'Bachelor of International Relations and Diplomatic Studies', years: 3 },
  { id: '88888888-bbbb-4bbb-bbbb-bbbbbbbbbbbb', dept: 'SES', code: 'MSS', name: 'Master of Social Sciences', years: 2 },
  { id: 'bbbbbbbb-bbbb-4bbb-bbbb-bbbbbbbbbbbb', dept: 'SES', code: 'MIRDS', name: 'Master of International Relations and Diplomatic Studies', years: 2 },
  { id: 'e1b66000-0001-4000-8000-000000000004', dept: 'SES', code: 'MED', name: 'Master of Education', years: 2 },
  // Faculty of Health and Environmental Sciences
  { id: '55555555-bbbb-4bbb-bbbb-bbbbbbbbbbbb', dept: 'HEC', code: 'BPH', name: 'Bachelor of Public Health', years: 3 },
  { id: '66666666-bbbb-4bbb-bbbb-bbbbbbbbbbbb', dept: 'HEC', code: 'MPH', name: 'Master of Public Health', years: 2 },
  { id: '77777777-bbbb-4bbb-bbbb-bbbbbbbbbbbb', dept: 'HEC', code: 'ADHM', name: 'Advanced Diploma in Health Management', years: 1 },
  { id: '44444444-aaaa-4aaa-aaaa-aaaaaaaaaaaa', dept: 'HEC', code: 'BEHS', name: 'Bachelor of Environmental Health Sciences', years: 3 },
  { id: '99999999-bbbb-4bbb-bbbb-bbbbbbbbbbbb', dept: 'HEC', code: 'MEM', name: 'Master of Environmental Management', years: 2 },
  { id: 'e1b66000-0001-4000-8000-000000000009', dept: 'HEC', code: 'HEC', name: 'Health Sciences Programme', years: 2 },
  // Faculty of Law
  { id: 'e1b66000-0001-4000-8000-000000000001', dept: 'LAW', code: 'LLB', name: 'Bachelor of Laws', years: 4 },
  { id: 'e1b66000-0001-4000-8000-000000000002', dept: 'LAW', code: 'LLM', name: 'Master of Laws', years: 2 },
];
const PROG_BY_CODE = Object.fromEntries(PROGS.map((prog) => [prog.code, prog]));

// Known lecturers are kept with their stable IDs/emails; names found in the
// workbook but missing here are created automatically further down.
const LECTURERS = [
  { id: '47835404-5a90-4960-bee7-2b7cb6f9f4df', name: 'Ms. Nanyonjo Evelyn', email: 'e.nanyonjo@cavendish.ac.ug', dept: 'FST' },
  { id: '1739c15e-8ed4-4bf9-8f5a-ee1751a5d1f1', name: 'Mr. Maganda Evans', email: 'm.maganda@cavendish.ac.ug', dept: 'FST' },
  { id: '57b2fc7a-f5a8-4a0a-a558-ee8759a4981f', name: 'Ms. Deborah Mackenzie', email: 'd.mackenzie@cavendish.ac.ug', dept: 'FST' },
  { id: '22640f68-e8c9-43e7-bd70-59ba276acbbb', name: 'Mr. Mpubani David', email: 'd.mpubani@cavendish.ac.ug', dept: 'FST' },
  { id: 'def38337-4c53-49c3-b348-7612934115ad', name: 'Mr. Ivan Mugumya', email: 'i.mugumya@cavendish.ac.ug', dept: 'FST' },
  { id: '6e0e1cf1-5e25-4745-ac1e-6af2d4d1d24f', name: 'Mr. Mpiima Dennis', email: 'd.mpiima@cavendish.ac.ug', dept: 'FST' },
  { id: 'c0a34f28-e1e8-4e7d-87b3-dce7c7c6d847', name: 'Mr. Kasumba Shadrach', email: 's.kasumba@cavendish.ac.ug', dept: 'FST' },
  { id: 'dce6f48f-a7e1-4b28-bad2-20ba1d81bebe', name: 'Mr. Ssejjemba Martin', email: 'm.ssejjemba@cavendish.ac.ug', dept: 'FST' },
  { id: '7ed2d03f-6977-4f5f-b1f0-0e45ca9e3f11', name: 'Ms. Bridget Nuwagaba', email: 'b.nuwagaba@cavendish.ac.ug', dept: 'FST' },
  { id: 'aee10928-3a11-4b2e-9e41-0b34d0f2f19b', name: 'Dr. Racheal Ainembabazi', email: 'r.ainembabazi@cavendish.ac.ug', dept: 'FST' },
  { id: 'bf53c19e-23da-4e1e-b5e5-c4be3e1e8e78', name: 'Mr. Kawiso Martin Wilfred', email: 'm.kawiso@cavendish.ac.ug', dept: 'BUS' },
  { id: 'a13a4c8d-5b5e-4d5f-b6a7-c8d9e0f1a2b3', name: 'Mr. Bakyayita David', email: 'd.bakyayita@cavendish.ac.ug', dept: 'BUS' },
  { id: 'b24b5d9e-6c6f-4e60-97b8-d9e0f1a2b3c4', name: 'Mr. Muhwezi Moses', email: 'm.muhwezi@cavendish.ac.ug', dept: 'BUS' },
  { id: 'c35c6eaf-7d70-4f70-88c9-e0f1a2b3c4d5', name: 'Mr. Bamuswankwire Charles', email: 'c.bamuswankwire@cavendish.ac.ug', dept: 'BUS' },
  { id: 'd46d7fba-8e80-4080-89d0-f1a2b3c4d5e6', name: 'Mr. Senyonga Martin', email: 'm.senyonga@cavendish.ac.ug', dept: 'BUS' },
  { id: 'e57e8acb-9f90-4090-80e1-a2b3c4d5e6f7', name: 'Mr. Mwesigwa Henry', email: 'h.mwesigwa@cavendish.ac.ug', dept: 'BUS' },
  { id: 'f68f9bdc-0fa0-4fa0-a1f2-b3c4d5e6f7a8', name: 'Ms. Nakiganda Harriet', email: 'h.nakiganda@cavendish.ac.ug', dept: 'BUS' },
  { id: 'a79a0ced-1fb1-4fb1-b2a3-c4d5e6f7a8b9', name: 'Mr. Sseguya Ivan', email: 'i.sseguya@cavendish.ac.ug', dept: 'BUS' },
  { id: 'b80b1dfe-2fc2-4fc2-83b4-d5e6f7a8b9c0', name: 'Ms. Namakula Elizabeth', email: 'e.namakula@cavendish.ac.ug', dept: 'SES' },
  { id: 'c91c2e0f-3fd3-4fd3-84c5-e6f7a8b9c0d1', name: 'Ms. Nnagadya Sumayah', email: 's.nnagadya@cavendish.ac.ug', dept: 'SES' },
  { id: 'da2d3f10-4fe4-4fe4-85d6-f7a8b9c0d1e2', name: 'Dr. Fiona Tumusiime', email: 'f.tumusiime@cavendish.ac.ug', dept: 'SES' },
  { id: 'eb3e4021-5fe5-4fe5-86e7-a8b9c0d1e2f3', name: 'Dr. Kibukamusoke Martha', email: 'm.kibukamusoke@cavendish.ac.ug', dept: 'SES' },
  { id: 'fc4f5132-6fe6-4fe6-a7f8-b9c0d1e2f3a4', name: 'Mr. Denis Wamimbi', email: 'd.wamimbi@cavendish.ac.ug', dept: 'SES' },
  { id: 'ad506243-7fe7-4fe7-b8a9-c0d1e2f3a4b5', name: 'Mr. Jonathan Tabalanga', email: 'j.tabalanga@cavendish.ac.ug', dept: 'SES' },
  { id: 'be617354-8fe8-4fe8-89ba-d1e2f3a4b5c6', name: 'Dr. Abdulrazak Yugua Madu', email: 'a.madu@cavendish.ac.ug', dept: 'SES' },
  { id: 'cf728465-9fe9-4fe9-8acb-e2f3a4b5c6d7', name: 'Prof. Love Aruguobiani', email: 'l.aruguobiani@cavendish.ac.ug', dept: 'SES' },
  { id: 'd0839576-afe0-4fe0-8bdc-f3a4b5c6d7e8', name: 'Ms. Khawa Namajja', email: 'k.namajja@cavendish.ac.ug', dept: 'HEC' },
  { id: 'e194a687-bfe1-4fe1-8ced-a4b5c6d7e8f9', name: 'Ms. Juliet Bandaru', email: 'j.bandaru@cavendish.ac.ug', dept: 'HEC' },
  { id: 'f2a5b798-cfe2-4fe2-adfe-b5c6d7e8f9a0', name: 'Mr. Bruce Nabaasa', email: 'b.nabaasa@cavendish.ac.ug', dept: 'HEC' },
  { id: 'a3b6c8a9-dfe3-4fe3-be0f-c6d7e8f9a0b1', name: 'Mr. Murami Taibu', email: 'm.taibu@cavendish.ac.ug', dept: 'HEC' },
  { id: 'b4c7d9ba-efe4-4fe4-8f10-d7e8f9a0b1c2', name: 'Mr. Deo Nsubuga', email: 'd.nsubuga@cavendish.ac.ug', dept: 'HEC' },
];

const lecturers = new Map();
function registerLecturer(name, email, deptCode, keyOverride) {
  const display = clean(name).split('|')[0].replace(/[,;]+$/, '').trim();
  if (!display || display.length < 3 || /^(online|n\/a|none|-)$/i.test(display)) return null;
  const key = keyOverride || normName(display);
  if (!key) return null;
  const existing = lecturers.get(key);
  if (existing) {
    if (!existing.email && email) existing.email = clean(email);
    if (existing.name.length < display.length && !existing.fixed) existing.name = display;
    if (deptCode) existing.deptCounts[deptCode] = (existing.deptCounts[deptCode] || 0) + 1;
    return existing;
  }
  const entry = {
    key,
    id: null,
    name: display,
    email: clean(email) || null,
    dept: deptCode || null,
    deptCounts: {},
    fixed: false
  };
  if (deptCode) entry.deptCounts[deptCode] = 1;
  lecturers.set(key, entry);
  return entry;
}
for (const lecturer of LECTURERS) {
  const key = normName(lecturer.name);
  const entry = {
    key,
    id: lecturer.id,
    name: lecturer.name,
    email: lecturer.email,
    dept: lecturer.dept,
    deptCounts: { [lecturer.dept]: 1 },
    fixed: true
  };
  lecturers.set(key, entry);
}
function findLecturer(name) {
  const key = normName(clean(name).split('|')[0]);
  if (!key) return null;
  if (lecturers.has(key)) return lecturers.get(key);
  let best = null;
  for (const [candidate, entry] of lecturers.entries()) {
    if (key.length >= 6 && candidate.startsWith(key.slice(0, 8))) return entry;
    if (candidate.length >= 6 && key.startsWith(candidate.slice(0, 8))) {
      if (!best || candidate.length > best.key.length) best = entry;
    }
  }
  return best;
}

// â”€â”€ Workbook helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const wb = XLSX.readFile(EXCEL);
const sheet = (name) => XLSX.utils.sheet_to_json(wb.Sheets[name], { header: 1, defval: '' });
const sheetNames = new Set(wb.SheetNames);

const DAY_WORDS = {
  mon: 'Mon', monday: 'Mon',
  tue: 'Tue', tues: 'Tue', tuesday: 'Tue',
  wed: 'Wed', wednesday: 'Wed',
  thu: 'Thu', thur: 'Thu', thurs: 'Thu', thursday: 'Thu',
  fri: 'Fri', friday: 'Fri',
  sat: 'Sat', saturday: 'Sat',
  sun: 'Sun', sunday: 'Sun'
};
const DAY_NUM = { Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6, Sun: 7 };
const YEAR_WORDS = { ONE: 1, TWO: 2, THREE: 3, FOUR: 4, FIVE: 5, SIX: 6 };
const TIME_RE = /^(\d{1,2}):(\d{2})-(\d{1,2}):(\d{2})$/;
const SLOT_RE = /^(mon(?:day)?|tue(?:s|sday)?|wed(?:nesday)?|thu(?:r|rs|rsday)?|fri(?:day)?|sat(?:urday)?|sun(?:day)?)\s*:?\s*(\d{1,2}):(\d{2})\s*-\s*(\d{1,2}):(\d{2})\s*:?\s*(.*)$/i;
const MODULE_RE = /^([A-Z]{2,6}\d{2,4})/;

// The workbook stores afternoon times without PM (02:45 means 14:45).
function clockRange(startHour, startMinute, endHour, endMinute) {
  let sh = Number(startHour);
  let eh = Number(endHour);
  const startsAfternoon = sh >= 1 && sh <= 6;
  if (startsAfternoon) sh += 12;
  if (startsAfternoon && eh < 12) eh += 12;
  if (sh === 12 && eh >= 1 && eh <= 6) eh += 12;
  return {
    start: `${String(sh).padStart(2, '0')}:${startMinute}`,
    end: `${String(eh).padStart(2, '0')}:${endMinute}`
  };
}
function parseTime(value) {
  const match = TIME_RE.exec(clean(value));
  if (!match) return null;
  return clockRange(match[1], match[2], match[3], match[4]);
}
function parseSlot(value) {
  const match = SLOT_RE.exec(clean(value));
  if (!match) return null;
  const day = DAY_WORDS[match[1].toLowerCase()];
  if (!day) return null;
  return {
    day,
    ...clockRange(match[2], match[3], match[4], match[5]),
    tail: clean(match[6])
  };
}
function parseModuleCodes(value) {
  const codes = new Set();
  for (const part of String(value ?? '').split(/[,/|]/)) {
    const match = MODULE_RE.exec(clean(part).toUpperCase());
    if (match) codes.add(match[1]);
  }
  return [...codes];
}
function facultyToDeptCode(value) {
  const key = clean(value).toUpperCase().replace(/[^A-Z]/g, '');
  return FACULTY_TO_DEPT[key] || null;
}
function guessProgrammeCode(moduleCode, faculty) {
  const rules = [
    ['BIRDS', 'BIRDS'], ['BEHS', 'BEHS'], ['BPAM', 'BPAM'], ['BDSA', 'BDSA'], ['DDSA', 'DDSA'],
    ['MIRDS', 'MIRDS'], ['ADHM', 'ADHM'], ['BJCS', 'BJC'], ['BJC', 'BJC'], ['LLB', 'LLB'],
    ['LLM', 'LLM'], ['BPH', 'BPH'], ['MPH', 'MPH'], ['MBA', 'MBA'], ['MPM', 'MPM'],
    ['MEM', 'MEM'], ['MSS', 'MSS'], ['MED', 'MED'], ['MIT', 'MIT'], ['DCS', 'DCS'],
    ['DDA', 'DDA'], ['BDA', 'BDA'], ['DIT', 'DIT'], ['DPL', 'DPL'], ['BIT', 'BIT'],
    ['BSE', 'BSE'], ['BCS', 'BCS'], ['BBA', 'BBA'], ['DBA', 'DBA'], ['COM', 'BCS'],
    ['COS', 'BCS'], ['BIS', 'BIT'], ['PLM', 'BBA'], ['BAC', 'BBA'], ['BBF', 'BBA'],
    ['HRM', 'BBA'], ['BPA', 'BPAM'], ['IRDS', 'BIRDS'], ['IDS', 'BIRDS'], ['DJC', 'BJC'],
    ['EHS', 'BEHS'], ['RSC', 'MBA'], ['AGM', 'BBA'], ['BAM', 'BBA'], ['ACC', 'BBA'],
    ['FIN', 'BBA'], ['MKT', 'BBA'], ['LAW', 'LLB']
  ];
  for (const [prefix, prog] of rules) {
    if (moduleCode.startsWith(prefix)) return prog;
  }
  const facultyDept = facultyToDeptCode(faculty);
  return ({ FST: 'BIT', BUS: 'BBA', SES: 'BJC', HEC: 'BPH', LAW: 'LLB' })[facultyDept] || null;
}

const PROG_PREFIXES = [
  'BIRDS', 'BEHS', 'BPAM', 'BDSA', 'DDSA', 'MIRDS', 'ADHM', 'BJCS', 'LLB', 'LLM',
  'DCS', 'DDA', 'BDA', 'BJC', 'BPH', 'MPH', 'MBA', 'MPM', 'MEM', 'MSS', 'MED',
  'MIT', 'DIT', 'BIT', 'BSE', 'BCS', 'BBA', 'DBA', 'DPL', 'HEC', 'AF', 'BF', 'G',
  'HRM', 'MKT', 'PL', 'ENT'
];
const SPECIALISATION_TO_PROG = { AF: 'BBA', BF: 'BBA', G: 'BBA', HRM: 'BBA', MKT: 'BBA', PL: 'BBA', ENT: 'BBA' };
function parseProgrammeToken(value) {
  let token = clean(value).toUpperCase().replace(/[_ ]+/g, '-');
  token = token.replace(/^[^A-Z]+/, '');
  if (!token) return null;
  for (const prefix of PROG_PREFIXES) {
    if (token !== prefix && !token.startsWith(`${prefix}-`) && !(token.startsWith(prefix) && /^\d/.test(token.slice(prefix.length)))) continue;
    const base = SPECIALISATION_TO_PROG[prefix] || prefix;
    const prog = PROG_BY_CODE[base];
    if (!prog) continue;
    const rest = token.slice(prefix.length);
    let stream = null;
    const streamBeforeNumber = /^-([A-Z]{1,12})(?=-|$)/.exec(rest);
    if (streamBeforeNumber) stream = streamBeforeNumber[1];
    const numberSuffix = /^-\d+([A-Z]+)$/.exec(rest);
    if (!stream && numberSuffix) stream = numberSuffix[1];
    const streamAfterNumber = /^-\d+-([A-Z]{1,12})$/.exec(rest);
    if (!stream && streamAfterNumber) stream = streamAfterNumber[1];
    if (!stream && SPECIALISATION_TO_PROG[prefix] && prefix !== base) stream = prefix;
    const number = /\d+/.exec(rest);
    const year = number ? Math.ceil(Number(number[0]) / 2) : 1;
    return { prog, year: Math.min(Math.max(year, 1), 8), stream };
  }
  return null;
}
function parseProgrammeTokens(value) {
  const seen = new Set();
  const out = [];
  for (const part of String(value ?? '').split(/[,/|]+/)) {
    const parsed = parseProgrammeToken(part);
    const key = parsed ? `${parsed.prog.code}|${parsed.year}|${parsed.stream || ''}` : null;
    if (parsed && !seen.has(key)) {
      seen.add(key);
      out.push(parsed);
    }
  }
  return out;
}

// â”€â”€ Collect modules, classes, rooms, and weekly patterns â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const modules = new Map();
const classYears = new Map();
const classEntries = new Map();
const classModules = new Map();
const patterns = new Map();
const rooms = new Map();
const patternMeta = { skippedModuleCells: 0, skippedSlots: 0 };

function registerRoom(rawRoom, deptCode) {
  const text = clean(rawRoom);
  if (!text) return { code: null, hybrid: false };
  const hybrid = /\|\s*online\b/i.test(text) || /\bonline\b/i.test(text);
  let code = text
    .replace(/\s*\|\s*online\b/ig, '')
    .replace(/\bonline\b/ig, '')
    .trim()
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')
    .replace(/^-+|-+$/g, '')
    .toUpperCase();
  if (!code) return { code: null, hybrid: false };
  if (/^LLB-\d+$/.test(code)) code = code.replace('-', '');
  if (code === 'LAB') code = 'LAB-1';
  if (code === 'MOOTCOURT') code = 'MOOT-COURT';
  const entry = rooms.get(code) || { code, deptCounts: {}, hybrid };
  if (deptCode) entry.deptCounts[deptCode] = (entry.deptCounts[deptCode] || 0) + 1;
  entry.hybrid = entry.hybrid || hybrid;
  rooms.set(code, entry);
  return { code, hybrid };
}
function trackClass(prog, year, stream, moduleCode) {
  const capped = Math.min(Math.max(year, 1), Math.max(prog.years, 1));
  classYears.set(prog.code, Math.max(classYears.get(prog.code) || 0, capped));
  const streamCode = stream ? String(stream).toUpperCase().replace(/[^A-Z0-9]/g, '') : null;
  const classCode = `${prog.code}-Y${capped}${streamCode ? `-${streamCode}` : ''}`;
  classEntries.set(classCode, { prog, year: capped, stream: streamCode });
  if (moduleCode) classModules.set(`${moduleCode}|${classCode}`, { moduleCode, classCode });
  return classCode;
}
function registerModule(code, name, faculty, lecturerName, progHint) {
  const progCode = progHint || guessProgrammeCode(code, faculty);
  const prog = progCode ? PROG_BY_CODE[progCode] : null;
  const deptCode = prog ? prog.dept : (facultyToDeptCode(faculty) || 'FST');
  const displayName = clean(name) || code;
  const entry = modules.get(code) || {
    code,
    name: displayName,
    deptCode,
    progCode: prog ? prog.code : null,
    lecturerName: null
  };
  if (displayName.length > entry.name.length || entry.name === code) entry.name = displayName;
  if (!entry.lecturerName && lecturerName) entry.lecturerName = clean(lecturerName).split('|')[0].trim();
  if (!entry.progCode && prog) entry.progCode = prog.code;
  modules.set(code, entry);
  if (entry.lecturerName) registerLecturer(entry.lecturerName, null, deptCode);
  return entry;
}
function addSlot({ moduleCell, moduleName, faculty, room, lecturer, day, start, end, classCodes }) {
  const codes = parseModuleCodes(moduleCell);
  if (!codes.length) {
    patternMeta.skippedModuleCells += 1;
    return;
  }
  if (!day || !start || !end || end <= start) {
    patternMeta.skippedSlots += 1;
    return;
  }
  for (const code of codes) registerModule(code, moduleName, faculty, lecturer, null);
  const roomInfo = registerRoom(room, facultyToDeptCode(faculty) || 'FST');
  const classes = classCodes?.length ? classCodes : [null];
  for (const code of codes) {
    for (const classCode of classes) {
      if (classCode) classModules.set(`${code}|${classCode}`, { moduleCode: code, classCode });
      const lecturerName = clean(lecturer).split('|')[0].trim();
      const key = [code, classCode || '', day, start, end, roomInfo.code || 'online'].join('|');
      const current = patterns.get(key);
      if (!current || (!current.lecturerName && lecturerName)) {
        patterns.set(key, {
          moduleCode: code,
          classCode,
          roomCode: roomInfo.code,
          hybrid: roomInfo.hybrid,
          lecturerName,
          day,
          dayNum: DAY_NUM[day],
          start,
          end,
          sessionMode: !roomInfo.code ? 'online' : (roomInfo.hybrid ? 'hybrid' : 'physical')
        });
      }
    }
  }
}

// 1. Combined TT: Monday and Saturday schedule for every faculty.
if (sheetNames.has('Combined TT')) {
  for (const row of sheet('Combined TT').slice(1)) {
    const moduleCell = row[1];
    if (!parseModuleCodes(moduleCell).length) continue;
    const moduleName = row[2];
    const faculty = row[3];
    const room = row[4];
    const mondayLecturer = row[5] || '';
    const lecturerEmail = row[6] || '';
    const saturdayLecturer = row[11] || '';

    const mondaySlot = parseSlot(row[8]) || parseSlot(row[9]);
    const mondayProg = parseSlot(row[9])?.tail || '';
    if (mondaySlot) {
      const classCodes = parseProgrammeTokens(mondayProg).map((parsed) => trackClass(parsed.prog, parsed.year, parsed.stream, null));
      for (const code of parseModuleCodes(moduleCell)) {
        registerModule(code, moduleName, faculty, mondayLecturer, null);
        for (const classCode of classCodes) classModules.set(`${code}|${classCode}`, { moduleCode: code, classCode });
      }
      addSlot({
        moduleCell, moduleName, faculty, room: room || '', lecturer: mondayLecturer,
        day: mondaySlot.day, start: mondaySlot.start, end: mondaySlot.end, classCodes
      });
    }
    if (lecturerEmail && mondayLecturer) {
      registerLecturer(mondayLecturer, lecturerEmail, facultyToDeptCode(faculty));
    }

    const saturdaySlot = parseSlot(row[13]) || parseSlot(row[14]);
    const saturdayProg = parseSlot(row[14])?.tail || '';
    const saturdayRoom = room || parseSlot(row[12])?.tail || '';
    if (saturdaySlot) {
      const classCodes = parseProgrammeTokens(saturdayProg).map((parsed) => trackClass(parsed.prog, parsed.year, parsed.stream, null));
      for (const code of parseModuleCodes(moduleCell)) {
        registerModule(code, moduleName, faculty, saturdayLecturer, null);
        for (const classCode of classCodes) classModules.set(`${code}|${classCode}`, { moduleCode: code, classCode });
      }
      addSlot({
        moduleCell, moduleName, faculty, room: saturdayRoom, lecturer: saturdayLecturer,
        day: saturdaySlot.day, start: saturdaySlot.start, end: saturdaySlot.end, classCodes
      });
    }
  }
}

// 2. Weekend timetable.
if (sheetNames.has('TT-WKD (2)')) {
  for (const row of sheet('TT-WKD (2)').slice(1)) {
    const moduleCell = row[1];
    if (!parseModuleCodes(moduleCell).length) continue;
    const moduleName = row[2];
    const faculty = row[3];
    const room = row[4];
    const lecturer = row[5];
    const baseProg = row[0];
    for (const cell of [row[6], row[7], row[8], row[9]]) {
      const slot = parseSlot(cell);
      if (!slot) continue;
      const classCodes = parseProgrammeTokens(`${baseProg} ${slot.tail}`.trim()).map((parsed) => trackClass(parsed.prog, parsed.year, parsed.stream, null));
      addSlot({
        moduleCell, moduleName, faculty, room, lecturer,
        day: slot.day, start: slot.start, end: slot.end, classCodes
      });
    }
  }
}

// 3. Per-programme timetable sheets.
const SHEET_TO_PROG = {
  MSS: 'MSS', MIRDS: 'MIRDS', MPH: 'MPH', MPM: 'MPM', MEM: 'MEM', MBA: 'MBA',
  MIT: 'MIT', 'BBA-WKD': 'BBA', BEHS: 'BEHS', ADHM: 'ADHM', 'HEC- P': 'HEC',
  'HEC- H': 'HEC', 'HEC-B': 'HEC', BPH: 'BPH', DIT: 'DIT', BIT: 'BIT', BSE: 'BSE',
  BCS: 'BCS', 'DDSA (DL)': 'DDSA', 'BDSA(DL)': 'BDSA', DBA: 'DBA', BBA: 'BBA',
  BDSA: 'BDSA', DDSA: 'DDSA', BJCS: 'BJC', BPAM: 'BPAM', BIRDS: 'BIRDS', DD: 'DDA'
};
for (const [sheetName, progCode] of Object.entries(SHEET_TO_PROG)) {
  if (!sheetNames.has(sheetName)) continue;
  const prog = PROG_BY_CODE[progCode];
  if (!prog) continue;
  let currentYear = 1;
  for (const row of sheet(sheetName)) {
    const joined = row.map((cell) => clean(cell)).join(' ').toUpperCase();
    const yearMatch = /YEAR\s+(ONE|TWO|THREE|FOUR|FIVE|SIX)/.exec(joined);
    if (yearMatch) currentYear = YEAR_WORDS[yearMatch[1]];
    const dayWord = clean(row[0]).toLowerCase();
    const day = DAY_WORDS[dayWord];
    const time = parseTime(row[1]);
    const moduleCell = row[2];
    if (!day || !time || !parseModuleCodes(moduleCell).length) continue;
    const classCode = trackClass(prog, currentYear, null);
    addSlot({
      moduleCell, moduleName: row[3], faculty: prog.dept, room: row[4], lecturer: row[5],
      day, start: time.start, end: time.end, classCodes: [classCode]
    });
  }
}

// 4. Attendance sheet: modules, rooms, lecturers and class/module links.
if (sheetNames.has('Attendance')) {
  for (const row of sheet('Attendance').slice(3)) {
    const codes = parseModuleCodes(row[1]);
    if (!codes.length) continue;
    const faculty = row[3];
    const progTokens = parseProgrammeTokens(row[0]).map((parsed) => trackClass(parsed.prog, parsed.year, parsed.stream, null));
    for (const code of codes) {
      registerModule(code, row[2], faculty, row[5], null);
      const dept = facultyToDeptCode(faculty);
      if (dept) registerLecturer(row[5], null, dept);
      for (const classCode of progTokens) classModules.set(`${code}|${classCode}`, { moduleCode: code, classCode });
    }
    registerRoom(row[4], facultyToDeptCode(faculty));
  }
}

// 5. Sheet1: a flat module/room/lecturer index.
if (sheetNames.has('Sheet1')) {
  for (const row of sheet('Sheet1').slice(1)) {
    const codes = parseModuleCodes(row[0]);
    if (!codes.length) continue;
    for (const code of codes) registerModule(code, row[1], row[2], row[4], null);
    if (row[5]) registerLecturer(row[4], row[5], facultyToDeptCode(row[2]));
    registerRoom(row[3], facultyToDeptCode(row[2]));
  }
}

// â”€â”€ Finalise programmes, lecturers, rooms â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
for (const prog of PROGS) {
  const maxYear = classYears.get(prog.code) || 0;
  prog.years = Math.min(Math.max(prog.years, maxYear, 1), 8);
}
const classes = [];
const seenClassCodes = new Set();
function addClass(prog, year, stream) {
  const code = `${prog.code}-Y${year}${stream ? `-${stream}` : ''}`;
  if (seenClassCodes.has(code)) return;
  seenClassCodes.add(code);
  classes.push({
    id: uuidFrom(`class:${code}`),
    prog,
    code,
    name: `${prog.code} Year ${year}${stream ? ` ${stream}` : ''}`,
    year,
    stream: stream || 'Day'
  });
}
for (const prog of PROGS) {
  for (let year = 1; year <= prog.years; year += 1) addClass(prog, year, null);
}
for (const entry of classEntries.values()) addClass(entry.prog, entry.year, entry.stream);
classes.sort((a, b) => a.code.localeCompare(b.code));

for (const module of modules.values()) {
  const lecturer = module.lecturerName ? findLecturer(module.lecturerName) : null;
  module.lecturer = lecturer;
  if (lecturer && !lecturer.fixed) {
    lecturer.deptCounts[module.deptCode] = (lecturer.deptCounts[module.deptCode] || 0) + 1;
  }
}

const usedEmails = new Set();
const usedIdNumbers = new Set();
const usedHandles = new Set();
const finalLecturers = [...lecturers.values()]
  .filter((lecturer) => lecturer.name && lecturer.name.length >= 3)
  .sort((a, b) => a.key.localeCompare(b.key));
for (const lecturer of finalLecturers) {
  if (!lecturer.id) lecturer.id = uuidFrom(`lecturer:${lecturer.key}`);
  const counts = Object.entries(lecturer.deptCounts).sort((a, b) => b[1] - a[1]);
  if (!lecturer.fixed || !lecturer.dept) lecturer.dept = counts[0]?.[0] || 'FST';
  let email = lecturer.email || `${slugify(lecturer.name)}@cavendish.ac.ug`;
  let suffix = 1;
  while (usedEmails.has(email.toLowerCase())) {
    email = `${slugify(lecturer.name)}.${suffix++}@cavendish.ac.ug`;
  }
  lecturer.email = email;
  usedEmails.add(email.toLowerCase());

  let idNumber = `LEC-${slugify(lecturer.name).replace(/\./g, '-').toUpperCase().slice(0, 24)}`;
  let idSuffix = 1;
  while (usedIdNumbers.has(idNumber)) idNumber = `${idNumber.slice(0, 28)}-${idSuffix++}`;
  lecturer.idNumber = idNumber;
  usedIdNumbers.add(idNumber);

  let handle = `CU-${sha256(lecturer.key).slice(0, 10).toUpperCase()}`;
  let handleSuffix = 1;
  while (usedHandles.has(handle)) handle = `CU-${sha256(`${lecturer.key}-${handleSuffix++}`).slice(0, 10).toUpperCase()}`;
  lecturer.qrHandle = handle;
  usedHandles.add(handle);
  lecturer.qrTokenHash = sha256(`lec-token:${lecturer.key}`);
  lecturer.qrSecret = sha256(`lec-secret:${lecturer.key}`);
}

const finalRooms = [...rooms.values()]
  .filter((room) => room.code)
  .sort((a, b) => a.code.localeCompare(b.code));
function roomBuilding(code) {
  if (/^KG/.test(code)) return 'KG Block';
  if (/^SI/.test(code)) return 'SI Block';
  if (/^MKN/.test(code)) return 'MKN Block';
  if (/^LLB|^LLM|^MOOT/.test(code)) return 'Law Block';
  if (/LAB/.test(code)) return 'Laboratory Block';
  return 'Main Campus';
}
function roomCategory(code) {
  if (/LAB/.test(code)) return 'lab';
  if (/MOOT|DISC/.test(code)) return 'discussion_room';
  return 'lecture_room';
}
function roomCapacity(code) {
  if (/LAB/.test(code)) return 30;
  if (/MOOT/.test(code)) return 80;
  if (/^LLB|^LLM/.test(code)) return 40;
  if (/^KG/.test(code)) return 60;
  if (/^SI/.test(code)) return 50;
  if (/^MKN/.test(code)) return 50;
  return 50;
}
const facilities = finalRooms.map((room, index) => {
  const deptCounts = Object.entries(room.deptCounts).sort((a, b) => b[1] - a[1]);
  const deptCode = deptCounts[0]?.[0] || 'FST';
  const category = roomCategory(room.code);
  const building = roomBuilding(room.code);
  return {
    id: uuidFrom(`facility:${building}:${room.code}`),
    code: room.code,
    name: `${room.code} ${category === 'lab' ? 'Laboratory' : category === 'discussion_room' ? 'Discussion Room' : 'Lecture Room'}`,
    category,
    dept: DEPT_BY_CODE[deptCode] || DEPT_BY_CODE.FST,
    building,
    room: room.code,
    capacity: roomCapacity(room.code),
    latitude: (0.3173 + (index % 12) * 0.00012).toFixed(6),
    longitude: (32.5716 + Math.floor(index / 12) * 0.00012).toFixed(6)
  };
});

// â”€â”€ SQL output â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
const L = [];
const summary = {
  departments: DEPTS.length,
  programmes: PROGS.length,
  classes: classes.length,
  lecturers: finalLecturers.length,
  modules: modules.size,
  facilities: facilities.length,
  classModules: classModules.size,
  patterns: patterns.size
};
L.push('-- Cavendish University Uganda - Full Seed');
L.push(`-- Generated: ${new Date().toISOString()}`);
L.push(`-- ${summary.departments} depts | ${summary.programmes} programmes | ${summary.classes} classes | ${summary.lecturers} lecturers | ${summary.modules} modules | ${summary.facilities} rooms`);
L.push(`-- ${summary.classModules} class/module links | ${summary.patterns} weekly timetable patterns expanded across ${TEACHING_FIRST_MONDAY}..${SEM_END}`);
L.push('-- Safe to re-run: ON CONFLICT DO UPDATE / DO NOTHING');
L.push('', 'BEGIN;', '');

L.push('-- Keep old demo "BUS" faculty from blocking the real Faculty of Business');
L.push(`UPDATE departments SET code = 'DEM-BUS' WHERE code = 'BUS' AND id <> ${q(DEPT_BY_CODE.BUS.id)};`);
L.push('');
L.push('-- Remove the invented LR1..LR29 rooms from the old seed when nothing references them');
L.push("DELETE FROM facilities f WHERE f.room_number ~ '^LR[0-9]+$' AND NOT EXISTS (SELECT 1 FROM bookings b WHERE b.facility_id = f.id) AND NOT EXISTS (SELECT 1 FROM timetable_slots t WHERE t.facility_id = f.id);");
L.push("UPDATE facilities SET status = 'blocked' WHERE room_number ~ '^LR[0-9]+$' AND status = 'active';");
L.push('');

L.push('-- Extend modules table (idempotent, schema.sql also defines these)');
L.push('ALTER TABLE modules ADD COLUMN IF NOT EXISTS programme_id UUID REFERENCES programmes(id) ON DELETE SET NULL;');
L.push('ALTER TABLE modules ADD COLUMN IF NOT EXISTS credit_units INT NOT NULL DEFAULT 3;');
L.push('');

L.push('-- Departments');
for (const dept of DEPTS) {
  L.push(`INSERT INTO departments (id,code,name) VALUES (${q(dept.id)},${q(dept.code)},${q(dept.name)}) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name;`);
}

L.push('', '-- Current semester');
L.push('UPDATE semesters SET is_current = false WHERE is_current = true;');
L.push(`INSERT INTO semesters (id,name,start_date,end_date,is_current) VALUES ('af9a8e4b-4808-4b3f-b9c3-905be5215722',${q(SEM_NAME)},${q(SEM_START)},${q(SEM_END)},true) ON CONFLICT (name) DO UPDATE SET start_date = EXCLUDED.start_date, end_date = EXCLUDED.end_date, is_current = true;`);

L.push('', '-- Programmes');
for (const prog of PROGS) {
  L.push(`INSERT INTO programmes (id,department_id,code,name,duration_years) VALUES (${q(prog.id)},${q(DEPT_BY_CODE[prog.dept].id)},${q(prog.code)},${q(prog.name)},${prog.years}) ON CONFLICT (id) DO UPDATE SET department_id = EXCLUDED.department_id, code = EXCLUDED.code, name = EXCLUDED.name, duration_years = EXCLUDED.duration_years;`);
}

L.push('', '-- Classes');
for (const cls of classes) {
  L.push(`INSERT INTO classes (id,programme_id,department_id,code,name,year_of_study,intake,stream) VALUES (${q(cls.id)},${q(cls.prog.id)},${q(DEPT_BY_CODE[cls.prog.dept].id)},${q(cls.code)},${q(cls.name)},${cls.year},'Main',${q(cls.stream)}) ON CONFLICT (programme_id,name,intake,stream) DO UPDATE SET code = EXCLUDED.code, department_id = EXCLUDED.department_id, year_of_study = EXCLUDED.year_of_study;`);
}

L.push('', '-- Lecturers (login password: Cavendish@2026)');
for (const lecturer of finalLecturers) {
  L.push(`INSERT INTO users (id,id_number,name,email,role,department_id,password_hash,qr_token_hash,qr_handle,qr_secret,study_mode,is_active) VALUES (${q(lecturer.id)},${q(lecturer.idNumber)},${q(lecturer.name)},${q(lecturer.email)},'lecturer',${q(DEPT_BY_CODE[lecturer.dept].id)},${q(BCRYPT)},${q(lecturer.qrTokenHash)},${q(lecturer.qrHandle)},${q(lecturer.qrSecret)},'physical',true) ON CONFLICT (id) DO UPDATE SET id_number = EXCLUDED.id_number, name = EXCLUDED.name, email = EXCLUDED.email, role = 'lecturer', department_id = EXCLUDED.department_id;`);
}

L.push('', '-- Modules');
for (const module of [...modules.values()].sort((a, b) => a.code.localeCompare(b.code))) {
  L.push(`INSERT INTO modules (id,code,name,department_id,programme_id,lecturer_id,credit_units) VALUES (${q(uuidFrom(`module:${module.code}`))},${q(module.code)},${q(module.name)},${q(DEPT_BY_CODE[module.deptCode]?.id || DEPT_BY_CODE.FST.id)},${module.progCode ? q(PROG_BY_CODE[module.progCode].id) : 'NULL'},${module.lecturer ? q(module.lecturer.id) : 'NULL'},3) ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id, programme_id = EXCLUDED.programme_id, lecturer_id = EXCLUDED.lecturer_id;`);
}

L.push('', '-- Rooms');
for (const facility of facilities) {
  L.push(`INSERT INTO facilities (id,name,category,department_id,building,floor,wing,room_number,location_description,latitude,longitude,capacity,status,checkin_mode,checkin_radius_m,qr_secret,qr_version) VALUES (${q(facility.id)},${q(facility.name)},${q(facility.category)},${q(facility.dept.id)},${q(facility.building)},'Ground',NULL,${q(facility.room)},${q(`${facility.room} - ${facility.building}, Cavendish University Uganda.`)},${facility.latitude},${facility.longitude},${facility.capacity},'active','static_geo',50,${q(sha256(`facility:${facility.building}:${facility.room}`))},1) ON CONFLICT (building,room_number) DO UPDATE SET name = EXCLUDED.name, category = EXCLUDED.category, department_id = EXCLUDED.department_id, floor = EXCLUDED.floor, wing = EXCLUDED.wing, location_description = EXCLUDED.location_description, latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude, capacity = EXCLUDED.capacity, status = 'active';`);
}

L.push('', '-- Room equipment');
for (const facility of facilities) {
  const items = facility.category === 'lab'
    ? [['Computers', facility.capacity], ['Projector', 1], ['Whiteboard', 1]]
    : [['Projector', 1], ['Whiteboard', 1]];
  for (const [name, quantity] of items) {
    L.push(`INSERT INTO facility_equipment (facility_id,name,quantity) SELECT id,${q(name)},${quantity} FROM facilities WHERE building = ${q(facility.building)} AND room_number = ${q(facility.room)} ON CONFLICT (facility_id,name) DO UPDATE SET quantity = EXCLUDED.quantity;`);
  }
}

L.push('', '-- Class/module links');
const links = [...classModules.values()].sort((a, b) => `${a.moduleCode}|${a.classCode}`.localeCompare(`${b.moduleCode}|${b.classCode}`));
L.push('INSERT INTO class_modules (class_id,module_id,semester_id)');
L.push('SELECT DISTINCT c.id, m.id, s.id');
L.push('FROM (VALUES');
links.forEach((link, index) => {
  L.push(`  (${q(link.moduleCode)},${q(link.classCode)})${index === links.length - 1 ? '' : ','}`);
});
L.push(') AS p(module_code,class_code)');
L.push(`CROSS JOIN (SELECT id FROM semesters WHERE name = ${q(SEM_NAME)}) s`);
L.push('JOIN modules m ON m.code = p.module_code');
L.push('JOIN classes c ON c.code = p.class_code');
L.push('ON CONFLICT (class_id,module_id,semester_id) DO NOTHING;');

L.push('', '-- Timetable slots: expand each weekly pattern across the teaching period');
const weekly = [...patterns.values()].sort((a, b) => (
  `${a.moduleCode}|${a.classCode || ''}|${a.dayNum}|${a.start}|${a.roomCode || ''}`
    .localeCompare(`${b.moduleCode}|${b.classCode || ''}|${b.dayNum}|${b.start}|${b.roomCode || ''}`)
));
L.push('INSERT INTO timetable_slots (id,semester_id,class_id,module_id,lecturer_id,facility_id,start_at,end_at,session_mode)');
L.push("SELECT md5(concat_ws('|', p.module_code, p.class_code, (w.week_start + (p.day_num - 1))::text, p.start_time::text, p.room_code))::uuid,");
L.push('       s.id, c.id, m.id, u.id, f.id, t.start_at, t.end_at, p.session_mode');
L.push('FROM (VALUES');
weekly.forEach((pattern, index) => {
  const lecturer = pattern.lecturerName ? findLecturer(pattern.lecturerName) : null;
  L.push(`  (${q(pattern.moduleCode)},${pattern.classCode ? q(pattern.classCode) : 'NULL'},${pattern.roomCode ? q(pattern.roomCode) : 'NULL'},${lecturer ? q(lecturer.email) : 'NULL'},${pattern.dayNum},${q(pattern.start)}::time,${q(pattern.end)}::time,${q(pattern.sessionMode)})${index === weekly.length - 1 ? '' : ','}`);
});
L.push(') AS p(module_code,class_code,room_code,lecturer_email,day_num,start_time,end_time,session_mode)');
L.push(`CROSS JOIN (SELECT id FROM semesters WHERE name = ${q(SEM_NAME)}) s`);
L.push('JOIN modules m ON m.code = p.module_code');
L.push('LEFT JOIN classes c ON c.code = p.class_code');
L.push('LEFT JOIN facilities f ON f.room_number = p.room_code');
L.push('LEFT JOIN users u ON lower(u.email) = lower(p.lecturer_email)');
L.push(`CROSS JOIN LATERAL (SELECT generate_series(date ${q(TEACHING_FIRST_MONDAY)}, date ${q(TEACHING_LAST_MONDAY)}, interval '7 days')::date AS week_start) w`);
L.push("CROSS JOIN LATERAL (SELECT (w.week_start + (p.day_num - 1) + p.start_time) AT TIME ZONE 'Africa/Kampala' AS start_at,");
L.push("                            (w.week_start + (p.day_num - 1) + p.end_time) AT TIME ZONE 'Africa/Kampala' AS end_at) t");
L.push('ON CONFLICT (id) DO NOTHING;');

L.push('', '-- Marker so server startup does not replay this seed on every boot');
L.push("INSERT INTO settings (key,value) VALUES ('cavendish_seed_applied','true'::jsonb) ON CONFLICT (key) DO UPDATE SET value = 'true'::jsonb, updated_at = now();");
L.push('', 'COMMIT;', '');
L.push(`-- Summary: ${summary.departments} depts | ${summary.programmes} programmes | ${summary.classes} classes | ${summary.lecturers} lecturers | ${summary.modules} modules | ${summary.facilities} rooms | ${summary.classModules} class/module links | ${summary.patterns} weekly patterns`);

writeFileSync(OUT, L.join('\n'), 'utf8');
console.log(`Wrote ${OUT}`);
console.log(summary);
console.log(`Skipped ${patternMeta.skippedModuleCells} module cells and ${patternMeta.skippedSlots} incomplete slots`);
