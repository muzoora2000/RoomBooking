import { escapeHtml, emptyState, errorMessage, debounce, mountChrome } from '../ui.js';

// Mount topbar/nav (works for guests too)
mountChrome('courses');

const tabsEl    = document.getElementById('faculty-tabs');
const listEl    = document.getElementById('faculty-list');
const countEl   = document.getElementById('course-count');
const searchEl  = document.getElementById('course-search');

const API = window.CAMPUS_API_BASE || '';

let departments  = [];
let programmes   = [];
let modules      = [];
let activeDeptId = '';
let searchQuery  = '';

// ── Fetch all data in parallel ────────────────────────────────────────────────
async function loadData() {
  listEl.innerHTML = '<div class="skeleton"></div><div class="skeleton"></div><div class="skeleton"></div>';
  countEl.textContent = 'Loading…';

  const [deptRes, progRes, modRes] = await Promise.all([
    fetch(`${API}/api/org/public/departments`).then(r => r.json()),
    fetch(`${API}/api/org/public/programmes`).then(r => r.json()),
    fetch(`${API}/api/org/public/modules`).then(r => r.ok ? r.json() : { modules: [] }).catch(() => ({ modules: [] }))
  ]);

  departments = deptRes.departments || [];
  programmes  = progRes.programmes  || [];
  modules     = modRes.modules      || [];

  // Build faculty tab buttons
  tabsEl.innerHTML =
    '<button class="chip active" data-dept-id="" type="button">All Faculties</button>' +
    departments.map(d =>
      `<button class="chip" data-dept-id="${escapeHtml(d.id)}" type="button">${escapeHtml(d.name.replace('Faculty of ', ''))}</button>`
    ).join('');

  tabsEl.querySelectorAll('.chip').forEach(btn => {
    btn.addEventListener('click', () => {
      tabsEl.querySelectorAll('.chip').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      activeDeptId = btn.dataset.deptId;
      render();
    });
  });

  render();
}

// ── Render ────────────────────────────────────────────────────────────────────
function render() {
  const q = searchQuery.toLowerCase().trim();

  const visibleDepts = activeDeptId
    ? departments.filter(d => d.id === activeDeptId)
    : departments;

  let totalCourses = 0;
  let html = '';

  for (const dept of visibleDepts) {
    const deptProgs = programmes.filter(p => p.department_id === dept.id);
    if (!deptProgs.length) continue;

    // Filter progs by search
    const matchingProgs = deptProgs.filter(prog => {
      if (!q) return true;
      const progMods = modules.filter(m => m.programme_id === prog.id);
      return (
        prog.name.toLowerCase().includes(q) ||
        prog.code.toLowerCase().includes(q) ||
        progMods.some(m =>
          m.name.toLowerCase().includes(q) ||
          (m.code || '').toLowerCase().includes(q) ||
          (m.lecturer_name || '').toLowerCase().includes(q)
        )
      );
    });

    if (!matchingProgs.length) continue;

    html += `
      <section class="card" style="margin-bottom:1.2rem">
        <div class="card-head" style="padding-bottom:.6rem;border-bottom:1px solid var(--border)">
          <div>
            <div class="eyebrow">${escapeHtml(dept.code)}</div>
            <h2 style="margin:0;font-size:1.15rem">${escapeHtml(dept.name)}</h2>
          </div>
          <span class="badge">${matchingProgs.length} programme${matchingProgs.length !== 1 ? 's' : ''}</span>
        </div>
        <div style="padding-top:.6rem">
        ${matchingProgs.map(prog => {
          const allProgMods = modules.filter(m => m.programme_id === prog.id);
          const progMods = allProgMods.filter(m => {
            if (!q) return true;
            return (
              m.name.toLowerCase().includes(q) ||
              (m.code || '').toLowerCase().includes(q) ||
              (m.lecturer_name || '').toLowerCase().includes(q)
            );
          });
          totalCourses += progMods.length;

          return `
            <details class="programme-block" style="margin:.5rem 0;border:1px solid var(--border);border-radius:8px">
              <summary style="cursor:pointer;list-style:none;display:flex;align-items:center;justify-content:space-between;gap:.5rem;padding:.7rem 1rem">
                <div>
                  <strong>${escapeHtml(prog.code)}</strong>
                  <span style="margin-left:.4rem">${escapeHtml(prog.name)}</span>
                  <span class="muted small" style="margin-left:.4rem">(${prog.duration_years} yr${prog.duration_years !== 1 ? 's' : ''})</span>
                </div>
                <span class="badge secondary">${progMods.length} course${progMods.length !== 1 ? 's' : ''}</span>
              </summary>
              <div style="padding:.5rem 1rem 1rem">
                ${progMods.length
                  ? `<table style="width:100%;border-collapse:collapse;font-size:.88rem">
                      <thead>
                        <tr style="background:var(--surface-alt,#f5f7f9)">
                          <th style="text-align:left;padding:.4rem .6rem;border-bottom:1px solid var(--border)">Code</th>
                          <th style="text-align:left;padding:.4rem .6rem;border-bottom:1px solid var(--border)">Course Name</th>
                          <th style="text-align:left;padding:.4rem .6rem;border-bottom:1px solid var(--border)">Lecturer</th>
                          <th style="text-align:center;padding:.4rem .6rem;border-bottom:1px solid var(--border)">Cr.</th>
                        </tr>
                      </thead>
                      <tbody>
                        ${progMods.map((m, i) => `
                          <tr style="${i % 2 ? 'background:var(--surface-alt,#f9fafb)' : ''}">
                            <td style="padding:.35rem .6rem;border-bottom:1px solid var(--border);font-family:monospace;font-size:.82rem;white-space:nowrap">${escapeHtml(m.code || '—')}</td>
                            <td style="padding:.35rem .6rem;border-bottom:1px solid var(--border)">${escapeHtml(m.name)}</td>
                            <td style="padding:.35rem .6rem;border-bottom:1px solid var(--border);color:var(--text-muted,#666)">${escapeHtml(m.lecturer_name || '—')}</td>
                            <td style="padding:.35rem .6rem;border-bottom:1px solid var(--border);text-align:center">${m.credit_units ?? 3}</td>
                          </tr>`).join('')}
                      </tbody>
                    </table>`
                  : `<p class="muted small" style="margin:.4rem 0">No courses match your search for this programme.</p>`
                }
              </div>
            </details>`;
        }).join('')}
        </div>
      </section>`;
  }

  if (!html) {
    listEl.innerHTML = emptyState('No results', q ? `No courses match "${escapeHtml(q)}".` : 'No programmes found.');
    countEl.textContent = '0 courses';
    return;
  }

  listEl.innerHTML = html;
  const deptLabel = activeDeptId
    ? departments.find(d => d.id === activeDeptId)?.name || 'faculty'
    : `${visibleDepts.length} faculties`;
  countEl.textContent = `${totalCourses} course${totalCourses !== 1 ? 's' : ''} across ${deptLabel}`;
}

// ── Search ────────────────────────────────────────────────────────────────────
const doSearch = debounce(() => { searchQuery = searchEl.value; render(); }, 300);
searchEl.addEventListener('input', doSearch);
document.getElementById('course-search-form').addEventListener('submit', e => {
  e.preventDefault();
  searchQuery = searchEl.value;
  render();
});

// ── Start ─────────────────────────────────────────────────────────────────────
loadData().catch(err => {
  listEl.innerHTML = `<div class="notice danger">${escapeHtml(errorMessage(err))}</div>`;
  countEl.textContent = 'Could not load data';
});
