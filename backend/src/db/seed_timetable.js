/**
 * Cavendish University Uganda — Timetable Seed Script
 * Seeds: departments (faculties), programmes, modules, lecturer users
 *
 * Run: node src/db/seed_timetable.js
 * Safe to re-run: uses ON CONFLICT DO NOTHING / DO UPDATE
 */

import { createRequire } from 'module';
import { readFileSync } from 'fs';
import { fileURLToPath } from 'url';
import path from 'path';
import { query, withTransaction, closePool } from './pool.js';
import { config } from '../config.js';
import bcrypt from 'bcryptjs';
import crypto from 'crypto';

const here = path.dirname(fileURLToPath(import.meta.url));

// ─── Timetable data ────────────────────────────────────────────────────────────
const faculties = [
  { code: 'FST', name: 'Faculty of Science and Technology' },
  { code: 'BUS', name: 'Faculty of Business' },
  { code: 'SES', name: 'Faculty of Social and Environmental Studies' },
  { code: 'HEC', name: 'Faculty of Health and Environmental Sciences' },
];

const programmes = [
  { code: 'BIT',      name: 'Bachelor of Science in Information Technology',            faculty: 'FST', years: 3 },
  { code: 'BSE',      name: 'Bachelor of Science in Software Engineering',               faculty: 'FST', years: 3 },
  { code: 'BCS',      name: 'Bachelor of Computer Science',                              faculty: 'FST', years: 3 },
  { code: 'DIT',      name: 'Diploma in Information Technology',                         faculty: 'FST', years: 2 },
  { code: 'MIT',      name: 'Master of Information Technology',                          faculty: 'FST', years: 2 },
  { code: 'BDSA',     name: 'Bachelor of Data Science and Analytics',                    faculty: 'FST', years: 3 },
  { code: 'DDSA',     name: 'Diploma in Data Science and Analytics',                     faculty: 'FST', years: 2 },
  { code: 'BBA',      name: 'Bachelor of Business Administration',                       faculty: 'BUS', years: 3 },
  { code: 'DBA',      name: 'Diploma in Business Administration',                        faculty: 'BUS', years: 2 },
  { code: 'MBA',      name: 'Master of Business Administration',                         faculty: 'BUS', years: 2 },
  { code: 'MEM',      name: 'Master of Enterprise Management',                           faculty: 'BUS', years: 2 },
  { code: 'BPH',      name: 'Bachelor of Public Health',                                 faculty: 'HEC', years: 3 },
  { code: 'MPH',      name: 'Master of Public Health',                                   faculty: 'HEC', years: 2 },
  { code: 'ADHM',     name: 'Advanced Diploma in Health Management',                     faculty: 'HEC', years: 2 },
  { code: 'BEHS',     name: 'Bachelor of Environmental Health Sciences',                 faculty: 'HEC', years: 3 },
  { code: 'BIRDS',    name: 'Bachelor of International Relations and Diplomatic Studies', faculty: 'SES', years: 3 },
  { code: 'BPAM',     name: 'Bachelor of Public Administration and Management',          faculty: 'SES', years: 3 },
  { code: 'BJCS',     name: 'Bachelor of Journalism and Communication Studies',          faculty: 'SES', years: 3 },
  { code: 'MSS',      name: 'Master of Security Studies',                                faculty: 'SES', years: 2 },
  { code: 'MIRDS',    name: 'Master of International Relations and Diplomatic Studies',  faculty: 'SES', years: 2 },
  { code: 'MPM',      name: 'Master of Public Management',                               faculty: 'SES', years: 2 },
];

// Map faculty short code -> full name
const facultyNames = {
  FST: 'Faculty of Science and Technology',
  BUS: 'Faculty of Business',
  SES: 'Faculty of Social and Environmental Studies',
  HEC: 'Faculty of Health and Environmental Sciences',
};

// Module code -> { code, name, facultyCode }
// Derived from timetable — top representative subset per faculty
const modulesByFaculty = {
  FST: [
    { code: 'BIT110', name: 'Introduction to Information and Communication Technologies' },
    { code: 'BIT111', name: 'Discrete Mathematics' },
    { code: 'BIT112', name: 'Introduction to Programming' },
    { code: 'BIT113', name: 'Communication Skills' },
    { code: 'BIT114', name: 'Structured Systems Analysis and Design' },
    { code: 'BIT115', name: 'Database Management Systems' },
    { code: 'BIT116', name: 'Computer Networks and Data Communications' },
    { code: 'BIT211', name: 'Operating Systems' },
    { code: 'BIT212', name: 'Human Computer Interaction' },
    { code: 'BIT213', name: 'Web Technologies' },
    { code: 'BIT214', name: 'Computer Security' },
    { code: 'BIT215', name: 'Software Engineering' },
    { code: 'BIT311', name: 'Advanced Database Systems' },
    { code: 'BIT312', name: 'Mobile Application Development' },
    { code: 'BIT313', name: 'Artificial Intelligence' },
    { code: 'BSE1101', name: 'Calculus for Software Engineering' },
    { code: 'BSE1102', name: 'Introduction to Software Engineering' },
    { code: 'BSE1103', name: 'Fundamentals of Programming' },
    { code: 'BSE2101', name: 'Software Design and Architecture' },
    { code: 'BSE2102', name: 'Algorithms and Data Structures' },
    { code: 'BSE2103', name: 'Software Testing and Quality Assurance' },
    { code: 'BSE3101', name: 'Software Project Management' },
    { code: 'BSE3102', name: 'Distributed Systems' },
    { code: 'COM113', name: 'Computer Architecture and Organisation' },
    { code: 'BCS211', name: 'Theory of Computation' },
    { code: 'BCS212', name: 'Compiler Design' },
    { code: 'BDSA111', name: 'Introduction to Data Science' },
    { code: 'BDSA112', name: 'Statistics for Data Science' },
    { code: 'BDSA211', name: 'Machine Learning' },
    { code: 'BDSA212', name: 'Big Data Analytics' },
    { code: 'BDSA311', name: 'Deep Learning and Neural Networks' },
    { code: 'DIT110', name: 'Introduction to ICT' },
    { code: 'DIT211', name: 'Network Administration' },
    { code: 'MIT711', name: 'Advanced Software Engineering' },
    { code: 'MIT712', name: 'Research Methods in IT' },
    { code: 'EHS223', name: 'Occupational Health and Safety' },
    { code: 'RSC001', name: 'Research Methodology' },
  ],
  BUS: [
    { code: 'BBA111', name: 'Principles of Management' },
    { code: 'BBA112', name: 'Microeconomics' },
    { code: 'BBA113', name: 'Business Administration' },
    { code: 'BBA114', name: 'Business Law' },
    { code: 'BBA115', name: 'Financial Accounting' },
    { code: 'BBA116', name: 'Basic Statistics' },
    { code: 'BBA117', name: 'Entrepreneurship' },
    { code: 'BBA211', name: 'Marketing Management' },
    { code: 'BBA212', name: 'Human Resource Management' },
    { code: 'BBA213', name: 'Macroeconomics' },
    { code: 'BBA214', name: 'Cost Accounting' },
    { code: 'BBA215', name: 'Business Research Methods' },
    { code: 'BBA221', name: 'Strategic Management' },
    { code: 'BBA222', name: 'Operations Management' },
    { code: 'BBA223', name: 'Taxation I' },
    { code: 'BBA224', name: 'Financial Management' },
    { code: 'BBA311', name: 'International Business' },
    { code: 'BBA312', name: 'Project Management' },
    { code: 'BBA313', name: 'Corporate Governance' },
    { code: 'BSF323', name: 'Security Analysis and Portfolio Management' },
    { code: 'DBA113', name: 'Business Administration Diploma' },
    { code: 'DBA116', name: 'Basic Statistics Diploma' },
    { code: 'MBA711', name: 'Finance for Managers' },
    { code: 'MBA712', name: 'Strategic Management for Managers' },
    { code: 'MBA713', name: 'Marketing for Managers' },
    { code: 'MBA811', name: 'Leadership and Organizational Behaviour' },
    { code: 'MBF813', name: 'Management Accounting' },
    { code: 'MPM715', name: 'Strategic Financial Management' },
  ],
  SES: [
    { code: 'BJC110', name: 'Communication Skills and Learning Skills for Employability' },
    { code: 'BJC116', name: 'Basic Academic Writing Skills' },
    { code: 'BJC125', name: 'History of Media and Communication' },
    { code: 'BJC211', name: 'Media Law and Ethics' },
    { code: 'BJC212', name: 'Broadcast Journalism' },
    { code: 'BJC311', name: 'Investigative Journalism' },
    { code: 'IRDS111', name: 'Introduction to International Relations' },
    { code: 'IRDS112', name: 'Introduction to Diplomacy' },
    { code: 'IRDS113', name: 'World History' },
    { code: 'IRDS114', name: 'Protocol and Etiquette' },
    { code: 'IRDS121', name: 'Introduction to Political Science' },
    { code: 'IRDS122', name: 'Government and Politics in Africa' },
    { code: 'IRDS124', name: 'International Law' },
    { code: 'IRDS125', name: 'International Political Economy' },
    { code: 'IRDS128', name: 'The United Nations Systems' },
    { code: 'IRDS129', name: 'Terrorism and Related Global Issues' },
    { code: 'IRDS211', name: 'Africa and International Relations' },
    { code: 'IRDS213', name: 'Public Administration and Management' },
    { code: 'IRDS214', name: 'Gender and International Relations' },
    { code: 'IRDS215', name: 'Regional Integration and Globalization' },
    { code: 'IRDS216', name: 'International Investment, Trade and Business Management' },
    { code: 'IRDS217', name: 'Religion, Conflict and Peace Studies' },
    { code: 'IRDS222', name: 'Foreign Policy Analysis' },
    { code: 'IRDS223', name: 'Comparative Political Systems' },
    { code: 'IRDS224', name: 'International Politics of the Environment' },
    { code: 'IRDS225', name: 'Conflict Resolution, Management and Transformation' },
    { code: 'IRDS227', name: 'Advanced Theory of Diplomacy' },
    { code: 'IRDS311', name: 'Security Studies' },
    { code: 'IRDS312', name: 'Displaced Person and Forced Migration Studies' },
    { code: 'IRDS313', name: 'International Justice Mechanisms' },
    { code: 'IRDS314', name: 'International Politics, Media and Conflict' },
    { code: 'IRDS315', name: 'International Development' },
    { code: 'IRDS316', name: 'Global Geopolitical Analysis' },
    { code: 'IRDS317', name: 'Civil Military Relations' },
    { code: 'IRDS321', name: 'Ethics in International Relations' },
    { code: 'IRDS322', name: 'Africa and Contemporary International Security' },
    { code: 'IRDS323', name: 'Strategic Intelligence, Modern Warfare and Human Rights' },
    { code: 'IRDS324', name: 'Cyber Security and International Security' },
    { code: 'IRDS325', name: 'International Public Relations and Strategic Communication' },
    { code: 'BPA111', name: 'Public Administration and Management' },
    { code: 'BPA121', name: 'Introduction to Political Science' },
    { code: 'BPA122', name: 'Governance and Public Sector Management' },
    { code: 'BPA125', name: 'Gender in Public Admin' },
    { code: 'BPA225', name: 'Government and Politics in Africa' },
    { code: 'BPA126', name: 'International Political Economy' },
    { code: 'MSS711', name: 'Foundations of Security Studies' },
    { code: 'MSS712', name: 'National Security and Intelligence' },
    { code: 'MSS722', name: 'Anti-Terrorism and Counter-Terrorism Strategies' },
    { code: 'MIRDS711', name: 'Advanced International Relations Theory' },
    { code: 'MIRDS712', name: 'Conflict Prevention and Peace Building' },
    { code: 'RSC001', name: 'Research Methods' },
  ],
  HEC: [
    { code: 'BPH111', name: 'Introduction to Public Health' },
    { code: 'BPH112', name: 'Health and Health Behavior' },
    { code: 'BPH113', name: 'Human Biology' },
    { code: 'BPH114', name: 'Introduction to Public Health and Ethics' },
    { code: 'BPH211', name: 'Epidemiology' },
    { code: 'BPH212', name: 'Principles of Environmental Health' },
    { code: 'BPH213', name: 'Health Systems Management' },
    { code: 'BPH214', name: 'Maternal and Child Health' },
    { code: 'BPH221', name: 'Public Health in Emergency Situations' },
    { code: 'BPH222', name: 'Principles of Health Education and Advocacy' },
    { code: 'BPH224', name: 'Health Policies and Laws' },
    { code: 'BPH311', name: 'Health Economics' },
    { code: 'BPH312', name: 'Non-Communicable Diseases' },
    { code: 'BPH313', name: 'Community Health' },
    { code: 'MPH711', name: 'Advanced Epidemiology' },
    { code: 'MPH712', name: 'Global Health' },
    { code: 'MPH713', name: 'Health Research Methods' },
    { code: 'ADHM111', name: 'Health Service Administration' },
    { code: 'ADHM211', name: 'Hospital Management' },
    { code: 'BEHS111', name: 'Introduction to Environmental Health' },
    { code: 'BEHS211', name: 'Food Safety and Hygiene' },
    { code: 'BEHS311', name: 'Environmental Impact Assessment' },
    { code: 'EHS111', name: 'Environmental Health Sciences' },
    { code: 'EHS223', name: 'Occupational Health and Safety' },
    { code: 'RSC001', name: 'Research Methodology' },
  ],
};

// Lecturers from timetable with their primary faculty
const lecturersData = [
  // FST
  { name: 'Ms. Nanyonjo Evelyn',          email: 'e.nanyonjo@cavendish.ac.ug',       faculty: 'FST', title: 'Ms' },
  { name: 'Mr. Maganda Evans',             email: 'm.maganda@cavendish.ac.ug',         faculty: 'FST', title: 'Mr' },
  { name: 'Ms. Deborah Mackenzie',         email: 'd.mackenzie@cavendish.ac.ug',       faculty: 'FST', title: 'Ms' },
  { name: 'Mr. Mpubani David',             email: 'd.mpubani@cavendish.ac.ug',         faculty: 'FST', title: 'Mr' },
  { name: 'Mr. Ivan Mugumya',              email: 'i.mugumya@cavendish.ac.ug',         faculty: 'FST', title: 'Mr' },
  { name: 'Mr. Pule Samuel',               email: 'p.samuel@cavendish.ac.ug',          faculty: 'FST', title: 'Mr' },
  { name: 'Mr. Ayasi Bin-Asadi',           email: 'a.binasadi@cavendish.ac.ug',        faculty: 'FST', title: 'Mr' },
  { name: 'Dr. Martin Were',               email: 'm.were@cavendish.ac.ug',            faculty: 'FST', title: 'Dr' },
  { name: 'Ms. Grace Namukasa',            email: 'g.namukasa@cavendish.ac.ug',        faculty: 'FST', title: 'Ms' },
  { name: 'Mr. Ronald Nsubuga',            email: 'r.nsubuga@cavendish.ac.ug',         faculty: 'FST', title: 'Mr' },
  // BUS
  { name: 'Dr. Faith Ahabyoona Mugisha',  email: 'f.mugisha@cavendish.ac.ug',         faculty: 'BUS', title: 'Dr' },
  { name: 'Mr. Kawiso Martin Wilfred',     email: 'k.wilfred@cavendish.ac.ug',         faculty: 'BUS', title: 'Mr' },
  { name: 'Mr. Bakyayita David',           email: 'd.bakyayita@cavendish.ac.ug',       faculty: 'BUS', title: 'Mr' },
  { name: 'Mr. Muhwezi Moses',             email: 'm.muhwezi@cavendish.ac.ug',         faculty: 'BUS', title: 'Mr' },
  { name: 'Mr. Bamuswankwire Charles',     email: 'c.bamuswankwire@cavendish.ac.ug',   faculty: 'BUS', title: 'Mr' },
  { name: 'Dr. Shuaib Muhammad Rabiu',     email: 's.rabiu@cavendish.ac.ug',           faculty: 'BUS', title: 'Dr' },
  { name: 'Mr. Wairindi Daniel Katongole', email: 'd.katongole@cavendish.ac.ug',       faculty: 'BUS', title: 'Mr' },
  { name: 'Mr. Makwasi Christopher',       email: 'c.makwasi@cavendish.ac.ug',         faculty: 'BUS', title: 'Mr' },
  { name: 'Mr. Ddumba Vincent',            email: 'v.ddumba@cavendish.ac.ug',          faculty: 'BUS', title: 'Mr' },
  { name: 'Dr. Jane Akello',               email: 'j.akello@cavendish.ac.ug',          faculty: 'BUS', title: 'Dr' },
  // SES
  { name: 'Dr. Akampurira Patience',       email: 'p.akampurira@cavendish.ac.ug',      faculty: 'SES', title: 'Dr' },
  { name: 'Dr. Jude Kagooro',              email: 'j.kagooro@cavendish.ac.ug',         faculty: 'SES', title: 'Dr' },
  { name: 'Prof. Haruna Ayuba',            email: 'h.ayuba@cavendish.ac.ug',           faculty: 'SES', title: 'Prof' },
  { name: 'Mr. Esibo Omada',               email: 'e.omada@cavendish.ac.ug',           faculty: 'SES', title: 'Mr' },
  { name: 'Ms. Namakula Elizabeth',        email: 'e.namakula@cavendish.ac.ug',        faculty: 'SES', title: 'Ms' },
  { name: 'Mr. Jonathan Tabalanga',        email: 'j.tabalanga@cavendish.ac.ug',       faculty: 'SES', title: 'Mr' },
  { name: 'Dr. Bello Folaranmi Fatai',     email: 'f.bello@cavendish.ac.ug',           faculty: 'SES', title: 'Dr' },
  { name: 'Prof. Wabule Alice',            email: 'a.wabule@cavendish.ac.ug',          faculty: 'SES', title: 'Prof' },
  { name: 'Dr. Huthaifah Busuulwa',        email: 'h.busuulwa@cavendish.ac.ug',        faculty: 'SES', title: 'Dr' },
  { name: 'Mr. Richard Watenyera',         email: 'r.watenyera@cavendish.ac.ug',       faculty: 'SES', title: 'Mr' },
  { name: 'Mr. Okello Pasqualine',         email: 'p.okello@cavendish.ac.ug',          faculty: 'SES', title: 'Mr' },
  { name: 'Dr. Bob Drani',                 email: 'b.drani@cavendish.ac.ug',           faculty: 'SES', title: 'Dr' },
  { name: 'Prof. Solomon Muchwa Asiimwe',  email: 's.asiimwe@cavendish.ac.ug',         faculty: 'SES', title: 'Prof' },
  { name: 'Ms. Nnagadya Sumayah',          email: 's.nnagadya@cavendish.ac.ug',        faculty: 'SES', title: 'Ms' },
  { name: 'Dr. Anyona O. Evans',           email: 'a.evans@cavendish.ac.ug',           faculty: 'SES', title: 'Dr' },
  { name: 'Mr. Denis Wamimbi',             email: 'd.wamimbi@cavendish.ac.ug',         faculty: 'SES', title: 'Mr' },
  { name: 'Dr. Mbabazi Annet',             email: 'a.mbabazi@cavendish.ac.ug',         faculty: 'SES', title: 'Dr' },
  // HEC
  { name: 'Ms. Khawa Namajja',             email: 'k.namajja@cavendish.ac.ug',         faculty: 'HEC', title: 'Ms' },
  { name: 'Ms. Juliet Bandaru',            email: 'j.bandaru@cavendish.ac.ug',         faculty: 'HEC', title: 'Ms' },
  { name: 'Mr. Bruce Nabaasa',             email: 'b.nabaasa@cavendish.ac.ug',         faculty: 'HEC', title: 'Mr' },
  { name: 'Mr. Murami Taibu',              email: 'm.taibu@cavendish.ac.ug',           faculty: 'HEC', title: 'Mr' },
  { name: 'Mr. Deo Nsubuga',               email: 'd.nsubuga@cavendish.ac.ug',         faculty: 'HEC', title: 'Mr' },
  { name: 'Dr. Fiona Tumusiime',           email: 'f.tumusiime@cavendish.ac.ug',       faculty: 'HEC', title: 'Dr' },
  { name: 'Dr. Akampurira Patience',       email: 'p.akampurira@cavendish.ac.ug',      faculty: 'SES', title: 'Dr' }, // shared
  { name: 'Prof. Wabule Alice',            email: 'a.wabule@cavendish.ac.ug',          faculty: 'SES', title: 'Prof' },
];

function qrHandle() {
  return `CU-${crypto.randomBytes(4).toString('hex').toUpperCase()}`;
}
function qrSecret() {
  return crypto.randomBytes(24).toString('hex');
}
function qrTokenHash() {
  return crypto.randomBytes(32).toString('hex');
}
function idNumber(prefix, n) {
  return `${prefix}${String(n).padStart(4, '0')}`;
}

async function seed() {
  console.log('=== Cavendish University Timetable Seeder ===\n');

  const deptIds = {};   // code -> uuid
  const progIds = {};   // code -> uuid
  const userIds = {};   // email -> uuid

  // ── 1. Departments ──────────────────────────────────────────────────────────
  console.log('Seeding departments (faculties)...');
  for (const fac of faculties) {
    const res = await query(
      `INSERT INTO departments (code, name)
       VALUES ($1, $2)
       ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name
       RETURNING id`,
      [fac.code, fac.name]
    );
    deptIds[fac.code] = res.rows[0].id;
    console.log(`  ✓ ${fac.code}: ${fac.name}`);
  }

  // ── 2. Programmes as classes (one class per programme) ──────────────────────
  // First we need a semester
  let semId;
  const semRes = await query(`SELECT id FROM semesters WHERE is_current = true LIMIT 1`);
  if (semRes.rows.length) {
    semId = semRes.rows[0].id;
    console.log(`\nUsing existing current semester: ${semId}`);
  } else {
    const ins = await query(
      `INSERT INTO semesters (name, start_date, end_date, is_current)
       VALUES ('Semester I 2026/2027', '2026-08-01', '2026-12-31', true)
       ON CONFLICT (name) DO UPDATE SET is_current = true
       RETURNING id`
    );
    semId = ins.rows[0].id;
    console.log(`\nCreated semester: ${semId}`);
  }

  console.log('\nSeeding programmes (as classes)...');
  for (const prog of programmes) {
    const deptId = deptIds[prog.faculty];
    // Insert a placeholder programme row first (not a DB table, use classes directly)
    // We create one class per year of study
    for (let yr = 1; yr <= prog.years; yr++) {
      const className = `${prog.code} Year ${yr}`;
      const classCode = `${prog.code}-Y${yr}`;
      const res = await query(
        `INSERT INTO classes (programme_id, department_id, name, year_of_study, intake, stream, default_study_mode)
         SELECT p.id, $2, $3, $4, 'Main', 'Day', 'physical'
         FROM (
           SELECT id FROM programmes WHERE department_id = $2 AND code = $5 LIMIT 1
         ) p
         ON CONFLICT DO NOTHING
         RETURNING id`,
        [null, deptId, className, yr, prog.code]
      );
      // programmes table needs to be populated first
    }
  }

  // Actually insert into programmes table first
  console.log('\nSeeding programme records...');
  for (const prog of programmes) {
    const deptId = deptIds[prog.faculty];
    const res = await query(
      `INSERT INTO programmes (department_id, code, name, duration_years)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (department_id, code) DO UPDATE SET name = EXCLUDED.name, duration_years = EXCLUDED.duration_years
       RETURNING id`,
      [deptId, prog.code, prog.name, prog.years]
    );
    progIds[prog.code] = res.rows[0].id;
    console.log(`  ✓ ${prog.code}: ${prog.name}`);
  }

  // ── 3. Classes (one per programme year) ─────────────────────────────────────
  console.log('\nSeeding classes...');
  const classIds = {}; // progCode-yr -> uuid
  for (const prog of programmes) {
    const deptId = deptIds[prog.faculty];
    const progId = progIds[prog.code];
    for (let yr = 1; yr <= prog.years; yr++) {
      const className = `${prog.code} Year ${yr}`;
      const res = await query(
        `INSERT INTO classes (programme_id, department_id, name, year_of_study, intake, stream)
         VALUES ($1, $2, $3, $4, 'Main', 'Day')
         ON CONFLICT (programme_id, name, intake, stream) DO UPDATE SET year_of_study = EXCLUDED.year_of_study
         RETURNING id`,
        [progId, deptId, className, yr]
      );
      classIds[`${prog.code}-${yr}`] = res.rows[0].id;
    }
  }
  console.log(`  ✓ ${Object.keys(classIds).length} classes created`);

  // ── 4. Lecturer users ────────────────────────────────────────────────────────
  console.log('\nSeeding lecturer users...');
  const seen = new Set();
  const defaultHash = await bcrypt.hash('Cavendish@2026', 10);
  let lecN = 1000;

  for (const lec of lecturersData) {
    if (seen.has(lec.email)) continue;
    seen.add(lec.email);
    const deptId = deptIds[lec.faculty];
    const res = await query(
      `INSERT INTO users (id_number, name, email, role, department_id, password_hash,
                          qr_token_hash, qr_handle, qr_secret, study_mode, is_active)
       VALUES ($1,$2,$3,'lecturer',$4,$5,$6,$7,$8,'physical',true)
       ON CONFLICT (id_number) DO UPDATE
         SET name = EXCLUDED.name, email = EXCLUDED.email,
             department_id = EXCLUDED.department_id, role = 'lecturer'
       RETURNING id`,
      [
        idNumber('LEC', lecN++),
        lec.name,
        lec.email,
        deptId,
        defaultHash,
        qrTokenHash(),
        qrHandle(),
        qrSecret(),
      ]
    );
    userIds[lec.email] = res.rows[0].id;
    console.log(`  ✓ ${lec.name} (${lec.email})`);
  }

  // ── 5. Modules ───────────────────────────────────────────────────────────────
  console.log('\nSeeding modules...');
  const moduleIds = {}; // code -> uuid
  let totalMods = 0;
  const insertedCodes = new Set();

  for (const [facultyCode, mods] of Object.entries(modulesByFaculty)) {
    const deptId = deptIds[facultyCode];
    for (const mod of mods) {
      if (insertedCodes.has(mod.code)) continue;
      insertedCodes.add(mod.code);
      const res = await query(
        `INSERT INTO modules (code, name, department_id)
         VALUES ($1, $2, $3)
         ON CONFLICT (code) DO UPDATE SET name = EXCLUDED.name, department_id = EXCLUDED.department_id
         RETURNING id`,
        [mod.code, mod.name, deptId]
      );
      moduleIds[mod.code] = res.rows[0].id;
      totalMods++;
    }
  }
  console.log(`  ✓ ${totalMods} modules seeded`);

  // ── 6. Link modules to classes via class_modules ─────────────────────────────
  console.log('\nLinking modules to classes...');
  // Map module code prefix to programme codes
  const modProgrammeMap = {
    'BIT': ['BIT'], 'BSE': ['BSE'], 'BCS': ['BCS'], 'COM': ['BIT','BCS','BSE'],
    'DIT': ['DIT'], 'MIT': ['MIT'], 'BDSA': ['BDSA'], 'DDSA': ['DDSA'], 'DD': ['DDSA'],
    'BBA': ['BBA'], 'DBA': ['DBA'], 'MBA': ['MBA'], 'MBF': ['MBA'], 'MPM': ['MPM','MEM'],
    'BSF': ['BBA'],
    'BJC': ['BJCS'], 'IRDS': ['BIRDS','MIRDS'], 'BPA': ['BPAM','BIRDS'], 'MSS': ['MSS'],
    'MIRDS': ['MIRDS'],
    'BPH': ['BPH'], 'MPH': ['MPH'], 'ADHM': ['ADHM'], 'BEHS': ['BEHS'], 'EHS': ['BEHS','BPH'],
    'RSC': ['BIT','BSE','BCS','BDSA','BBA','BIRDS','BPAM','BJCS','BPH','BEHS'],
    'MED': ['MBA'],
  };

  let linkCount = 0;
  for (const [code, moduleId] of Object.entries(moduleIds)) {
    // Find programme prefix
    const prefix = Object.keys(modProgrammeMap).find(p => code.startsWith(p));
    const progCodes = prefix ? modProgrammeMap[prefix] : [];
    for (const progCode of progCodes) {
      const prog = programmes.find(p => p.code === progCode);
      if (!prog) continue;
      // Link to all years for this programme
      for (let yr = 1; yr <= prog.years; yr++) {
        const classId = classIds[`${progCode}-${yr}`];
        if (!classId) continue;
        try {
          await query(
            `INSERT INTO class_modules (class_id, module_id, semester_id)
             VALUES ($1,$2,$3)
             ON CONFLICT (class_id, module_id, semester_id) DO NOTHING`,
            [classId, moduleId, semId]
          );
          linkCount++;
        } catch (e) {
          // ignore conflicts
        }
      }
    }
  }
  console.log(`  ✓ ${linkCount} class-module links created`);

  // ── Done ─────────────────────────────────────────────────────────────────────
  console.log('\n=== Seed complete ===');
  console.log(`Departments: ${faculties.length}`);
  console.log(`Programmes:  ${programmes.length}`);
  console.log(`Classes:     ${Object.keys(classIds).length}`);
  console.log(`Modules:     ${totalMods}`);
  console.log(`Lecturers:   ${seen.size}`);
  console.log(`Class-module links: ${linkCount}`);
  console.log('\nAll lecturers can log in with password: Cavendish@2026');
}

seed()
  .catch(err => { console.error('Seed failed:', err); process.exitCode = 1; })
  .finally(() => closePool());
