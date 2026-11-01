import { AppError } from '../lib/errors.js';
import { durationMinutes, kampalaDate, kampalaDayBounds } from '../lib/time.js';

export function rangesOverlap(startA, endA, startB, endB) {
  return new Date(startA) < new Date(endB) && new Date(endA) > new Date(startB);
}

export async function findFacilityClash(client, { facilityId, startAt, endAt, excludeId = null }) {
  if (!facilityId) return [];
  const result = await client.query(
    `SELECT b.*, m.code AS module_code, m.name AS module_name
     FROM bookings b LEFT JOIN modules m ON m.id = b.module_id
     WHERE b.facility_id = $1
       AND b.status IN ('pending','confirmed')
       AND b.start_at < $3 AND b.end_at > $2
       AND ($4::uuid IS NULL OR b.id <> $4)
     ORDER BY b.start_at`,
    [facilityId, startAt, endAt, excludeId]
  );
  return result.rows;
}

export async function findLecturerClash(client, { lecturerId, startAt, endAt, excludeId = null }) {
  if (!lecturerId) return [];
  const result = await client.query(
    `SELECT b.*, m.code AS module_code, m.name AS module_name
     FROM bookings b LEFT JOIN modules m ON m.id = b.module_id
     WHERE b.lecturer_id = $1
       AND b.status IN ('pending','confirmed')
       AND b.start_at < $3 AND b.end_at > $2
       AND ($4::uuid IS NULL OR b.id <> $4)
     ORDER BY b.start_at`,
    [lecturerId, startAt, endAt, excludeId]
  );
  return result.rows;
}

export async function findFacilityBlock(client, { facilityId, startAt, endAt }) {
  if (!facilityId) return null;
  const result = await client.query(
    `SELECT * FROM facility_blocks
     WHERE facility_id = $1 AND start_at < $3 AND end_at > $2
     ORDER BY start_at LIMIT 1`,
    [facilityId, startAt, endAt]
  );
  return result.rows[0] || null;
}

export async function findExamBlock(client, { facilityId, startAt, endAt }) {
  if (!facilityId) return null;
  const result = await client.query(
    `SELECT eb.* FROM exam_blocks eb
     JOIN exam_block_facilities ebf ON ebf.exam_block_id = eb.id
     WHERE ebf.facility_id = $1 AND eb.start_at < $3 AND eb.end_at > $2
     ORDER BY eb.start_at LIMIT 1`,
    [facilityId, startAt, endAt]
  );
  return result.rows[0] || null;
}

export async function assertFacilityBookable(client, { facility, startAt, endAt, source = 'manual' }) {
  if (!facility) throw new AppError(400, 'FACILITY_REQUIRED', 'A room is required for a physical or hybrid session.');
  if (facility.status !== 'active') {
    throw new AppError(409, 'FACILITY_UNAVAILABLE', `${facility.name} is currently ${facility.status}. Choose another room.`);
  }
  const maintenance = await findFacilityBlock(client, { facilityId: facility.id, startAt, endAt });
  if (maintenance) {
    throw new AppError(409, 'FACILITY_BLOCKED', `${facility.name} is blocked for maintenance: ${maintenance.reason}`, {
      block_id: maintenance.id,
      start_at: maintenance.start_at,
      end_at: maintenance.end_at
    });
  }
  if (source !== 'exam') {
    const exam = await findExamBlock(client, { facilityId: facility.id, startAt, endAt });
    if (exam) {
      throw new AppError(409, 'EXAM_BLOCK', `${facility.name} is reserved for exams (${exam.name}) at that time.`, {
        exam_block_id: exam.id,
        start_at: exam.start_at,
        end_at: exam.end_at
      });
    }
  }
  return true;
}

async function getFacilityEquipment(client, facilityId) {
  const result = await client.query(
    `SELECT name, quantity FROM facility_equipment WHERE facility_id = $1 ORDER BY name`,
    [facilityId]
  );
  return result.rows;
}

function equipmentSatisfied(required, available) {
  if (!required || !required.length) return true;
  for (const requirement of required) {
    const found = available.find((entry) => entry.name === requirement.name);
    if (!found || Number(found.quantity) < Number(requirement.quantity || 1)) return false;
  }
  return true;
}

function freeGaps(dayStart, dayEnd, bookings) {
  const gaps = [];
  let cursor = new Date(dayStart);
  const sorted = [...bookings].sort((a, b) => new Date(a.start_at) - new Date(b.start_at));
  for (const booking of sorted) {
    const start = new Date(booking.start_at);
    const end = new Date(booking.end_at);
    if (start > cursor) gaps.push({ start: new Date(cursor), end: start });
    if (end > cursor) cursor = end;
  }
  if (cursor < new Date(dayEnd)) gaps.push({ start: cursor, end: new Date(dayEnd) });
  return gaps;
}

export async function suggestAlternatives({
  client,
  facility = null,
  startAt,
  endAt,
  requiredEquipment = [],
  category = null,
  capacity = null,
  excludeId = null
}) {
  if (!facility) return { same_facility: [], other_facilities: [] };
  const duration = durationMinutes(startAt, endAt);
  const day = kampalaDayBounds(kampalaDate(startAt));
  const dayBookings = await client.query(
    `SELECT start_at, end_at FROM bookings
     WHERE facility_id = $1 AND status IN ('pending','confirmed')
       AND start_at < $3 AND end_at > $2
     ORDER BY start_at`,
    [facility.id, day.start, day.end]
  );
  const gaps = freeGaps(day.start, day.end, dayBookings.rows);
  const sameFacility = [];
  for (const gap of gaps) {
    const beforeEnd = new Date(Math.min(new Date(startAt).getTime(), new Date(gap.end).getTime()));
    const beforeStart = new Date(beforeEnd.getTime() - duration * 60_000);
    if (beforeStart >= gap.start && beforeEnd > gap.start && beforeEnd <= new Date(startAt)) {
      sameFacility.push({ start_at: beforeStart, end_at: beforeEnd, label: 'Nearest free slot before on the same day' });
    }
    const afterStart = new Date(Math.max(new Date(endAt).getTime(), new Date(gap.start).getTime()));
    const afterEnd = new Date(afterStart.getTime() + duration * 60_000);
    if (afterStart >= new Date(endAt) && afterEnd <= gap.end) {
      sameFacility.push({ start_at: afterStart, end_at: afterEnd, label: 'Nearest free slot after on the same day' });
    }
    if (sameFacility.length >= 4) break;
  }
  const candidates = await client.query(
    `SELECT f.* FROM facilities f
     WHERE f.id <> $1 AND f.status = 'active'
       AND ($2::text IS NULL OR f.category = $2)
       AND ($3::int IS NULL OR f.capacity >= $3)
     ORDER BY abs(f.capacity - COALESCE($3, f.capacity)), f.name
     LIMIT 20`,
    [facility.id, category || facility.category, capacity || null]
  );
  const otherFacilities = [];
  for (const candidate of candidates.rows) {
    if (capacity && candidate.capacity < capacity) continue;
    const equipment = await getFacilityEquipment(client, candidate.id);
    if (!equipmentSatisfied(requiredEquipment, equipment)) continue;
    const conflicts = await findFacilityClash(client, {
      facilityId: candidate.id,
      startAt,
      endAt,
      excludeId
    });
    if (conflicts.length) continue;
    const maintenance = await findFacilityBlock(client, { facilityId: candidate.id, startAt, endAt });
    if (maintenance) continue;
    const exam = await findExamBlock(client, { facilityId: candidate.id, startAt, endAt });
    if (exam) continue;
    otherFacilities.push({
      id: candidate.id,
      name: candidate.name,
      category: candidate.category,
      building: candidate.building,
      floor: candidate.floor,
      wing: candidate.wing,
      room_number: candidate.room_number,
      capacity: candidate.capacity,
      latitude: candidate.latitude,
      longitude: candidate.longitude,
      equipment
    });
    if (otherFacilities.length >= 5) break;
  }
  return { same_facility: sameFacility, other_facilities: otherFacilities };
}

export async function conflictDetails(client, args) {
  return suggestAlternatives(args);
}
