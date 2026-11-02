import { api } from '../api.js';
import { escapeHtml, emptyState, errorMessage, debounce, mountChrome } from '../ui.js';

// Mount topbar/nav (works for guests too)
mountChrome('courses');

const tabsEl    = document.getElementById('faculty-tabs');
const listEl    = document.getElementById('faculty-list');
const countEl   = document.getElementById('course-count');
const searchEl  = document.getElementById('course-search');

// State
let departments = [];
let allModules  = [];   // flat list of { module, programme, department }
let activeDeptId = '';
let searchQuery  = '';

// ── Fetch all data ────────────────────────────────────────────────────────────
async function loadData() {
  listEl.innerHTML = '<div class="skeleton"></div><div class="skeleton"></div><div class="skeleton"></div>';

  const [deptRes, progRes, modRes] = await Promise.all([
    fetch(`${window.CAMPUS_API_BASE || ''}/api/org/public/departments`).then(r => r.json()),
    fetch(`${window.CAMPUS_API_BASE || ''}/api/org/public/programmes`).then(r => r.json()),
    // Modules endpoint requires auth — use org/modules if available, else skip gracefully
    fetch(`${window.CAMPUS_API_BASE || ''}/api/org/public/modules`).then(r => r.ok ? r.json() : { modules: [] }).catch(() => ({ modules: [] }))
  ]);

  departments = deptRes.departments || [];
  const programmes = progRes.programmes || [];
  const modules = modRes.modules || [];

  // Build flat list: attach dept name to each programme
  allModules = modules.map(m => {
    const prog = programmes.find(p => p.id === m.programme_id) || {};
    const dept = departments.find(d => d.id === (prog.department_id || m.department_id)) || {};
    return { ...m, programme_name: prog.name || '', programme_code: prog.code || '', department_id: dept.id || '', department_name: dept.name || '' };
  });

  // Build faculty tabs
  tabsEl.innerHTML = '<button class="chip active" data-dept-id="" type="button">All Faculties</button>' +
    departments.map(d =>
      `<button class="chip" data-dept-id="${escapeHtml(d.id)}" type="button">${escapeHtml(d.name.replace('Faculty of ', ''))}</button>`
    ).join('');

  tabsEl.querySelectorAll('.chip').forEach(btn => {
    btn.addEventListener('click', () => {
      tabsEl.querySelectorAll('.chip').forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      activeDeptId = btn.dataset.deptId;
      render(programmes, modules);
    });
  });

  render(programmes, modules);
}

// ── Render ────────────────────────────────────────────────────────────────────
function render(programmes, modules) {
  const q = searchQuery.toLowerCase().trim();

  // Filter departments by active tab
  const visibleDepts = activeDeptId
    ? departments.filter(d => d.id === activeDeptId)
    : departments;

  let totalCourses = 0;
  let html = '';

  for (const dept of visibleDepts) {
    const deptProgs = programmes.filter(p => p.department_id === dept.id);

    // Filter programmes by search
    const matchingProgs = deptProgs.filter(prog => {
      if (!q) return true;
      const deptModules = modules.filter(m => m.programme_id === prog.id);
      return (
        prog.name.toLowerCase().includes(q) ||
        prog.code.toLowerCase().includes(q) ||
        deptModules.some(m => m.name.toLowerCase().includes(q) || (m.code && m.code.toLowerCase().includes(q)))
      );
    });

    if (!matchingProgs.length) continue;

    html += `
      <section class="card" style="margin-bottom:1.2rem">
        <div class="card-head">
          <div>
            <div class="eyebrow">${escapeHtml(dept.code)}</div>
            <h2 style="margin:0">${escapeHtml(dept.name)}</h2>
          </div>
          <span class="badge">${matchingProgs.length} programme${matchingProgs.length !== 1 ? 's' : ''}</span>
        </div>
        ${matchingProgs.map(prog => {
          const progModules = modules.filter(m => m.programme_id === prog.id).filter(m => {
            if (!q) return true;
            return m.name.toLowerCase().includes(q) || (m.code && m.code.toLowerCase().includes(q));
          });
          totalCourses += progModules.length || 0;

          return `
            <details class="programme-block" style="margin-top:.8rem;border:1px solid var(--border);border-radius:10px;padding:.8rem 1rem">
              <summary style="cursor:pointer;list-style:none;display:flex;align-items:center;justify-content:space-between;gap:.5rem">
                <div>
                  <strong>${escapeHtml(prog.code)}</strong> — ${escapeHtml(prog.name)}
                  <span class="muted small" style="margin-left:.4rem">${prog.duration_years} year${prog.duration_years !== 1 ? 's' : ''}</span>
                </div>
                <span class="badge secondary">${progModules.length} course${progModules.length !== 1 ? 's' : ''}</span>
              </summary>
              ${progModules.length
                ? `<div style="margin-top:.8rem">
                    <table style="width:100%;border-collapse:collapse;font-size:.9rem">
                      <thead>
                        <tr style="background:var(--surface-raised,#f4f6f8)">
                          <th style="text-align:left;padding:.4rem .6rem;border-bottom:1px solid var(--border)">Code</th>
                          <th style="text-align:left;padding:.4rem .6rem;border-bottom:1px solid var(--border)">Course Name</th>
                          <th style="text-align:left;padding:.4rem .6rem;border-bottom:1px solid var(--border)">Lecturer</th>
                          <th style="text-align:center;padding:.4rem .6rem;border-bottom:1px solid var(--border)">Credits</th>
                        </tr>
                      </thead>
                      <tbody>
                        ${progModules.map((m, i) => `
                          <tr style="${i % 2 ? 'background:var(--surface-raised,#f9fafb)' : ''}">
                            <td style="padding:.4rem .6rem;border-bottom:1px solid var(--border);font-family:monospace;white-space:nowrap">${escapeHtml(m.code || '—')}</td>
                            <td style="padding:.4rem .6rem;border-bottom:1px solid var(--border)">${escapeHtml(m.name)}</td>
                            <td style="padding:.4rem .6rem;border-bottom:1px solid var(--border);color:var(--text-muted)">${escapeHtml(m.lecturer_name || '—')}</td>
                            <td style="padding:.4rem .6rem;border-bottom:1px solid var(--border);text-align:center">${m.credit_units || '—'}</td>
                          </tr>`).join('')}
                      </tbody>
                    </table>
                   </div>`
                : `<p class="muted small" style="margin-top:.6rem">No courses listed yet for this programme.</p>`
              }
            </details>`;
        }).join('')}
      </section>`;
  }

  if (!html) {
    listEl.innerHTML = emptyState('No results', q ? `No courses match "${escapeHtml(q)}".` : 'No programmes found.');
    countEl.textContent = '0 courses';
    return;
  }

  listEl.innerHTML = html;
  countEl.textContent = `${totalCourses} course${totalCourses !== 1 ? 's' : ''} across ${visibleDepts.length} faculty`;
}

// ── Search ─────────────────────────────────────────────────────────────────────
searchEl.addEventListener('input', debounce(() => {
  searchQuery = searchEl.value;
  // Re-trigger render with cached data (loadData already stored everything)
  loadData();
}, 350));

document.getElementById('course-search-form').addEventListener('submit', e => {
  e.preventDefault();
  searchQuery = searchEl.value;
  loadData();
});

// ── Start ─────────────────────────────────────────────────────────────────────
loadData().catch(err => {
  listEl.innerHTML = `<div class="notice danger">${escapeHtml(errorMessage(err))}</div>`;
  countEl.textContent = 'Could not load data';
});
