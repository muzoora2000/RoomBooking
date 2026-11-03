from docx import Document
from docx.shared import Pt, RGBColor, Inches, Cm
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
import copy

# ── Colours ──────────────────────────────────────────────────────────────────
NAVY       = RGBColor(0x1a, 0x3a, 0x6e)
NAVY_DARK  = RGBColor(0x10, 0x26, 0x50)
GOLD       = RGBColor(0xe7, 0xa5, 0x31)
WHITE      = RGBColor(0xFF, 0xFF, 0xFF)
MUTED      = RGBColor(0x5a, 0x6a, 0x85)
INK        = RGBColor(0x0f, 0x1a, 0x2e)
SUCCESS    = RGBColor(0x1c, 0x6b, 0x3a)
NAVY_SOFT  = RGBColor(0xdd, 0xe5, 0xf5)
LINE       = RGBColor(0xd5, 0xdc, 0xea)
BG         = RGBColor(0xf4, 0xf6, 0xfa)

doc = Document()

# ── Page margins ─────────────────────────────────────────────────────────────
for section in doc.sections:
    section.top_margin    = Cm(2)
    section.bottom_margin = Cm(2)
    section.left_margin   = Cm(2.5)
    section.right_margin  = Cm(2.5)

# ── Helper: set paragraph shading ────────────────────────────────────────────
def shade_paragraph(para, hex_color: str):
    pPr = para._p.get_or_add_pPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), hex_color)
    pPr.append(shd)

def shade_cell(cell, hex_color: str):
    tc   = cell._tc
    tcPr = tc.get_or_add_tcPr()
    shd  = OxmlElement('w:shd')
    shd.set(qn('w:val'),   'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'),  hex_color)
    tcPr.append(shd)

def set_cell_border(cell, **kwargs):
    tc   = cell._tc
    tcPr = tc.get_or_add_tcPr()
    tcBorders = OxmlElement('w:tcBorders')
    for edge in ('left', 'top', 'right', 'bottom', 'insideH', 'insideV'):
        tag = OxmlElement(f'w:{edge}')
        tag.set(qn('w:val'),  kwargs.get('val',   'single'))
        tag.set(qn('w:sz'),   kwargs.get('sz',    '4'))
        tag.set(qn('w:space'),'0')
        tag.set(qn('w:color'),kwargs.get('color', 'D5DCEA'))
        tcBorders.append(tag)
    tcPr.append(tcBorders)

def no_border_cell(cell):
    tc   = cell._tc
    tcPr = tc.get_or_add_tcPr()
    tcBorders = OxmlElement('w:tcBorders')
    for edge in ('left', 'top', 'right', 'bottom', 'insideH', 'insideV'):
        tag = OxmlElement(f'w:{edge}')
        tag.set(qn('w:val'),  'none')
        tag.set(qn('w:sz'),   '0')
        tag.set(qn('w:space'),'0')
        tag.set(qn('w:color'),'auto')
        tcBorders.append(tag)
    tcPr.append(tcBorders)

# ── Helper: add a run with formatting ────────────────────────────────────────
def add_run(para, text, bold=False, italic=False, size=11,
            color=None, font_name='Calibri'):
    run = para.add_run(text)
    run.bold   = bold
    run.italic = italic
    run.font.size = Pt(size)
    run.font.name = font_name
    if color:
        run.font.color.rgb = color
    return run

# ── Helper: heading ───────────────────────────────────────────────────────────
def add_heading(text, level=1, color=NAVY_DARK, size=18):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(16)
    p.paragraph_format.space_after  = Pt(6)
    r = p.add_run(text)
    r.bold = True
    r.font.size = Pt(size)
    r.font.color.rgb = color
    r.font.name = 'Calibri'
    return p

# ── Helper: section label ─────────────────────────────────────────────────────
def add_section_label(text):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(20)
    p.paragraph_format.space_after  = Pt(2)
    r = p.add_run(f'▌  {text}')
    r.bold = True
    r.font.size = Pt(8.5)
    r.font.color.rgb = NAVY
    r.font.name = 'Calibri'

# ── Helper: body paragraph ────────────────────────────────────────────────────
def add_body(text, color=INK, size=10.5, space_after=6):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(space_after)
    add_run(p, text, size=size, color=color)
    return p

# ── Helper: bullet ────────────────────────────────────────────────────────────
def add_bullet(label, body, icon='●'):
    p = doc.add_paragraph()
    p.paragraph_format.left_indent  = Cm(0.4)
    p.paragraph_format.space_after  = Pt(5)
    add_run(p, f'{icon}  ', bold=True, size=10, color=NAVY)
    add_run(p, label, bold=True, size=10.5, color=INK)
    if body:
        add_run(p, f'  —  {body}', size=10, color=MUTED)

# ── Helper: navy highlight box ────────────────────────────────────────────────
def add_highlight_box(text, fill='DDE5F5', bar_color='1A3A6E', bold_text=False):
    tbl = doc.add_table(rows=1, cols=2)
    tbl.alignment = WD_TABLE_ALIGNMENT.LEFT
    tbl.style = 'Table Grid'
    # bar cell
    bar = tbl.cell(0, 0)
    bar.width = Cm(0.35)
    shade_cell(bar, bar_color)
    no_border_cell(bar)
    bar.text = ''
    # content cell
    content = tbl.cell(0, 1)
    shade_cell(content, fill)
    no_border_cell(content)
    cp = content.paragraphs[0]
    cp.paragraph_format.space_before = Pt(6)
    cp.paragraph_format.space_after  = Pt(6)
    cp.paragraph_format.left_indent  = Cm(0.3)
    add_run(cp, text, bold=bold_text, size=10.5, color=INK)
    doc.add_paragraph().paragraph_format.space_after = Pt(4)

# ── Helper: navy card (dark background) ───────────────────────────────────────
def add_navy_card(title, body):
    tbl = doc.add_table(rows=1, cols=1)
    tbl.alignment = WD_TABLE_ALIGNMENT.LEFT
    tbl.style = 'Table Grid'
    cell = tbl.cell(0, 0)
    shade_cell(cell, '1A3A6E')
    no_border_cell(cell)
    cp = cell.paragraphs[0]
    cp.paragraph_format.space_before = Pt(8)
    cp.paragraph_format.left_indent  = Cm(0.4)
    cp.paragraph_format.right_indent = Cm(0.4)
    add_run(cp, title + '\n', bold=True, size=11.5, color=WHITE)
    add_run(cp, body, size=10.5, color=RGBColor(0xcc, 0xd8, 0xf0))
    cp.paragraph_format.space_after = Pt(8)
    doc.add_paragraph().paragraph_format.space_after = Pt(4)

# ── Helper: stat row ──────────────────────────────────────────────────────────
def add_stat_row(stats):
    tbl = doc.add_table(rows=1, cols=len(stats))
    tbl.alignment = WD_TABLE_ALIGNMENT.LEFT
    tbl.style = 'Table Grid'
    for i, (num, label) in enumerate(stats):
        cell = tbl.cell(0, i)
        shade_cell(cell, '1A3A6E')
        no_border_cell(cell)
        cp = cell.paragraphs[0]
        cp.alignment = WD_ALIGN_PARAGRAPH.CENTER
        cp.paragraph_format.space_before = Pt(10)
        add_run(cp, num + '\n', bold=True, size=20, color=GOLD)
        add_run(cp, label, size=9, color=RGBColor(0xbb, 0xcc, 0xee))
        cp.paragraph_format.space_after = Pt(10)
    doc.add_paragraph().paragraph_format.space_after = Pt(6)

# ── Helper: step ──────────────────────────────────────────────────────────────
def add_step(num, title, body):
    p = doc.add_paragraph()
    p.paragraph_format.left_indent = Cm(0)
    p.paragraph_format.space_after = Pt(5)
    add_run(p, f'  {num}  ', bold=True, size=10, color=WHITE,
            font_name='Calibri')
    # number bubble via bold navy run
    r = p.runs[0]
    r.font.highlight_color = None
    add_run(p, f'  {title}  ', bold=True, size=10.5, color=NAVY)
    add_run(p, f'— {body}', size=10, color=MUTED)

# ─────────────────────────────────────────────────────────────────────────────
#  DOCUMENT CONTENT
# ─────────────────────────────────────────────────────────────────────────────

# ══ COVER ══════════════════════════════════════════════════════════════════════
cover_tbl = doc.add_table(rows=1, cols=1)
cover_tbl.style = 'Table Grid'
cover_cell = cover_tbl.cell(0, 0)
shade_cell(cover_cell, '1A3A6E')
no_border_cell(cover_cell)

cover_para = cover_cell.paragraphs[0]
cover_para.alignment = WD_ALIGN_PARAGRAPH.CENTER
cover_para.paragraph_format.space_before = Pt(24)
cover_para.paragraph_format.space_after  = Pt(24)
cover_para.paragraph_format.left_indent  = Cm(1)
cover_para.paragraph_format.right_indent = Cm(1)

add_run(cover_para, 'CAVENDISH UNIVERSITY UGANDA\n', bold=True,
        size=11, color=RGBColor(0x8e, 0xb4, 0xf0))
add_run(cover_para, 'Campus Compass\n', bold=True,
        size=32, color=WHITE)
add_run(cover_para, 'Smart Room Booking & Campus Navigation System\n',
        size=13, color=RGBColor(0xcc, 0xd8, 0xf0))
add_run(cover_para, '\n')
add_run(cover_para, 'SYSTEM MANUAL & PITCH DOCUMENT  |  IEEE CUU Student Branch  |  2026',
        size=9, color=RGBColor(0x8e, 0xa8, 0xd8))

doc.add_paragraph()

# ── Tagline ──
p = doc.add_paragraph()
p.alignment = WD_ALIGN_PARAGRAPH.CENTER
p.paragraph_format.space_after = Pt(14)
add_run(p, '"Know the room. Own the day."', italic=True, size=12, color=NAVY)

doc.add_paragraph()

# ══ 01 — THE PROBLEM ═══════════════════════════════════════════════════════════
add_section_label('01 — THE PROBLEM')
add_heading('What We Are Solving', size=16)

add_highlight_box(
    'Every day at Cavendish University Uganda, students and lecturers waste valuable time '
    'because there is no reliable way to find and book a room.',
    bold_text=True
)

add_bullet('Lecture Room Clashes',
    'Lecturers arrive to find their assigned room already occupied. Timetable clashes '
    'are only discovered when two groups show up at the same door — causing disruption '
    'and wasted contact hours.', '🏫')

add_bullet('The Revision Room Struggle',
    'Students organising group study and revision sessions — especially during exam season '
    '— have no way to check which rooms are vacant or reserve a space in advance. '
    'They wander the campus losing study time they cannot afford to lose.', '📚')

add_bullet('Manual, Slow Coordination',
    'Class representatives must physically visit the admin office or make phone calls '
    'just to request a room. Notice boards and spreadsheets are updated too slowly '
    'to reflect real availability.', '📋')

add_bullet('Empty Rooms, No Visibility',
    'Rooms sit empty because nobody knows they are available. The university has the '
    'physical space — the problem is that this information is invisible to the people '
    'who need it most.', '🚪')

# ══ 02 — THE SOLUTION ══════════════════════════════════════════════════════════
add_section_label('02 — THE SOLUTION')
add_heading('How Campus Compass Works', size=16)

add_body(
    'Campus Compass is a Progressive Web App (PWA) — no download, no installation. '
    'Any student or staff member opens it in their browser and immediately has access '
    'to live room availability, bookings, schedules, and notifications.'
)

features = [
    ('🔍 Find Any Space — Live',
     'Search lecture halls, seminar rooms, labs, and discussion rooms by building, '
     'capacity, or equipment. Availability is shown in real time — no guessing, no walking around.'),
    ('📚 Instant Revision Room Booking',
     'Students browse all available spaces, filter by group size and facilities, and reserve '
     'a revision or study room in seconds — from their phone, without visiting any office. '
     'The system automatically prevents double bookings and sends a confirmation.'),
    ('🏫 Clash-Free Lecture Scheduling',
     'Priority rules, capacity checks, and database-level exclusion constraints guarantee '
     'that two sessions can never occupy the same room at the same time. Timetable conflicts '
     'are caught automatically before they cause disruption.'),
    ('📱 QR Check-In at the Door',
     'Every room has a door display screen. Students and lecturers scan a rotating QR code '
     'on arrival to confirm attendance — secure, instant, and privacy-friendly.'),
    ('🎓 Physical, Online & Hybrid Sessions',
     'The system supports all three modes. Online meeting links and passcodes are delivered '
     'securely only to authorised participants — never on public displays or notice boards.'),
    ('🔔 Smart Notifications',
     'Booking confirmations, reminders, cancellations, and no-show alerts are delivered via '
     'email, SMS (Africa\'s Talking), and browser push notifications.'),
    ('🖥 Room Door Display Screen',
     'Each room\'s display shows the current session, the next booking, live occupancy status, '
     'and a QR code for check-in. Any screen (TV, tablet, monitor) can be a door display.'),
    ('⚙️ Admin Control Dashboard',
     'Department administrators manage rooms, timetables, users, bookings, and notifications '
     'from a single dashboard. Super admins have full oversight across all departments.'),
]
for title, body in features:
    add_bullet(title, body, '▶')

# ══ 03 — HOW TO USE ════════════════════════════════════════════════════════════
add_section_label('03 — HOW TO USE IT')
add_heading('Step-by-Step User Journey', size=16)

add_heading('👩‍🎓 Student Booking a Revision Room', level=2, color=NAVY, size=12)
student_steps = [
    ('1', 'Open Campus Compass', 'Visit the app URL on any phone or laptop — no installation needed.'),
    ('2', 'Log in with Student ID', 'Enter your university ID and password. A one-time PIN is sent for verification.'),
    ('3', 'Browse Available Rooms', 'Tap "Find a room", filter by date, time, capacity, and room type.'),
    ('4', 'Book in Seconds', 'Select a room, enter session name and group size, confirm. Clash check is instant.'),
    ('5', 'Receive Confirmation', 'A confirmation is sent via email and SMS with all booking details.'),
    ('6', 'Check In on Arrival', 'Scan the QR code on the room\'s door display to confirm attendance.'),
]
for num, title, body in student_steps:
    add_step(num, title, body)

doc.add_paragraph()
add_heading('👨‍🏫 Lecturer Confirming a Lecture Room', level=2, color=NAVY, size=12)
lecturer_steps = [
    ('1', 'Log in', 'Sign in with your staff ID. Upcoming lectures appear on the home screen immediately.'),
    ('2', 'View Today\'s Schedule', 'See all assigned rooms, times, and lecture details — before leaving home.'),
    ('3', 'Get Reminders', 'Automatic reminders are sent 30 minutes before each session via SMS and push notification.'),
    ('4', 'Arrive and Check In', 'Scan the door QR code. The room display updates to show your lecture as active.'),
    ('5', 'Share Online Link', 'For hybrid/online sessions, a secure meeting link is sent only to enrolled students.'),
]
for num, title, body in lecturer_steps:
    add_step(num, title, body)

# ══ 04 — USER ROLES ════════════════════════════════════════════════════════════
add_section_label('04 — USER ROLES')
add_heading('Who Uses Campus Compass', size=16)

roles = [
    ('👩‍🎓', 'Student',
     'Browse rooms, book revision spaces, view timetable, join lectures, check in at the door.'),
    ('📣', 'Class Representative',
     'Book rooms on behalf of their class, manage class bookings, coordinate revision sessions.'),
    ('👨‍🏫', 'Lecturer',
     'View assigned lecture rooms, check schedule, manage sessions, check in on arrival.'),
    ('🏢', 'Department Admin',
     'Manage rooms, approve bookings, create timetable slots, oversee department activity.'),
    ('🔑', 'Super Admin',
     'Full control over all departments, users, facilities, settings, and operational reports.'),
    ('🖥', 'Door Display',
     'A dedicated screen mode for room entrances — current session, next booking, live QR code.'),
]

roles_tbl = doc.add_table(rows=len(roles), cols=3)
roles_tbl.style = 'Table Grid'
roles_tbl.alignment = WD_TABLE_ALIGNMENT.LEFT

for i, (icon, role, desc) in enumerate(roles):
    c0, c1, c2 = roles_tbl.cell(i, 0), roles_tbl.cell(i, 1), roles_tbl.cell(i, 2)
    shade_cell(c0, 'DDE5F5')
    set_cell_border(c0); set_cell_border(c1); set_cell_border(c2)

    p0 = c0.paragraphs[0]
    p0.alignment = WD_ALIGN_PARAGRAPH.CENTER
    add_run(p0, icon, size=14)

    p1 = c1.paragraphs[0]
    add_run(p1, role, bold=True, size=10.5, color=NAVY)

    p2 = c2.paragraphs[0]
    add_run(p2, desc, size=10, color=MUTED)

doc.add_paragraph()

# ══ 05 — FEATURES TABLE ════════════════════════════════════════════════════════
add_section_label('05 — FEATURE OVERVIEW')
add_heading('What the System Includes', size=16)

feature_rows = [
    ('Real-time room availability',   'Students, Lecturers, Admins', '✓ Live'),
    ('Revision room booking',          'Students, Class Reps',        '✓ Live'),
    ('Lecture room scheduling',        'Lecturers, Dept Admins',      '✓ Live'),
    ('QR code check-in',               'Students, Lecturers',         '✓ Live'),
    ('Door display screen',            'All campus visitors',         '✓ Live'),
    ('Email & SMS notifications',      'All users',                   '✓ Live'),
    ('Hybrid / Online session support','Lecturers, Students',         '✓ Live'),
    ('No-show auto-release',           'All users',                   '✓ Live'),
    ('Admin dashboard',                'Dept Admins, Super Admin',    '✓ Live'),
    ('Offline support (PWA)',          'All users',                   '✓ Live'),
]

ft = doc.add_table(rows=len(feature_rows)+1, cols=3)
ft.style = 'Table Grid'
ft.alignment = WD_TABLE_ALIGNMENT.LEFT

headers = ['Feature', 'Who Benefits', 'Status']
for j, h in enumerate(headers):
    c = ft.cell(0, j)
    shade_cell(c, '1A3A6E')
    no_border_cell(c)
    p = c.paragraphs[0]
    add_run(p, h, bold=True, size=9.5, color=WHITE)

for i, (feat, who, status) in enumerate(feature_rows):
    row = i + 1
    shade = 'F4F6FA' if i % 2 == 1 else 'FFFFFF'
    for j in range(3):
        shade_cell(ft.cell(row, j), shade)
        set_cell_border(ft.cell(row, j))

    p0 = ft.cell(row, 0).paragraphs[0]
    add_run(p0, feat, bold=True, size=10, color=INK)

    p1 = ft.cell(row, 1).paragraphs[0]
    add_run(p1, who, size=10, color=MUTED)

    p2 = ft.cell(row, 2).paragraphs[0]
    add_run(p2, status, bold=True, size=10, color=SUCCESS)

doc.add_paragraph()

# ══ 06 — IMPACT ════════════════════════════════════════════════════════════════
add_section_label('06 — THE IMPACT')
add_heading('What This Means for Cavendish University', size=16)

add_stat_row([
    ('29',  'Rooms across campus already in the system'),
    ('335', 'Modules mapped to rooms and timetable slots'),
    ('0',   'App downloads needed — works in any browser'),
])

add_highlight_box(
    '⏱  Time Saved — Students and lecturers no longer spend time walking campus looking '
    'for rooms or queuing at administration offices. Every booking takes under 60 seconds.',
    fill='DFF3E6', bar_color='1C6B3A'
)
add_highlight_box(
    '🏫  Better Space Utilisation — Rooms are released automatically when no one checks in, '
    'ensuring available spaces are visible and bookable — not locked away in a spreadsheet.',
    fill='FFF3D6', bar_color='E7A531'
)
add_highlight_box(
    '📚  Fairer Access for Students — Every student has equal, transparent access to book a '
    'revision room — not just those who know which administrator to call.',
    fill='DDE5F5', bar_color='1A3A6E'
)
add_highlight_box(
    '⚡  Reduced Admin Workload — Reminders, no-show releases, clash detection, and booking '
    'confirmations all run automatically. Administrators focus on decisions, not manual work.',
    fill='DDE5F5', bar_color='1A3A6E'
)

# ══ 07 — TECHNOLOGY ════════════════════════════════════════════════════════════
add_section_label('07 — TECHNOLOGY')
add_heading('Built for Africa, Designed to Scale', size=16)

add_body(
    'Campus Compass is built with proven, production-grade technology and deployed on '
    'free-tier cloud services — meaning it costs very little to run and can scale to '
    'the entire university without significant IT investment.'
)

tech_stack = [
    'Node.js 20', 'Express API', 'PostgreSQL', 'Neon (Cloud DB)',
    'Vercel (Frontend)', 'Render (Backend)', 'Progressive Web App (PWA)',
    "Africa's Talking SMS", 'Web Push Notifications', 'QR Code Check-In',
    'GitHub CI/CD', 'Africa/Kampala Timezone',
]
p = doc.add_paragraph()
p.paragraph_format.space_after = Pt(10)
for t in tech_stack:
    add_run(p, f'  {t}  ', bold=True, size=9.5, color=NAVY)
    add_run(p, ' ', size=9)

add_navy_card(
    'Why a Progressive Web App (PWA)?',
    'A PWA works on any phone or laptop browser — Android, iPhone, Windows, or Chromebook. '
    'No Play Store, no App Store, no storage space needed. Students on limited data plans '
    'benefit from intelligent caching that makes the app work even with poor connectivity. '
    'This removes every barrier to adoption at Cavendish University Uganda.'
)

# ══ 08 — WHY IT IS WORTH IT ════════════════════════════════════════════════════
add_section_label('08 — WHY THIS IDEA IS WORTH IT AT CAVENDISH')
add_heading('What Makes Campus Compass Worth Exploring', size=16)

worth_it = [
    ('✅ It Already Works',
     'Campus Compass is not a concept or a wireframe. It is a fully functional system with '
     '29 rooms, 335 modules, 31 lecturers, and 21 programmes already loaded — built '
     'specifically for Cavendish University Uganda.'),
    ('🎯 Solves a Real Daily Problem',
     'Every student and lecturer on campus experiences the room problem every single day. '
     'This is not a theoretical pain point — it is a real, measurable cost to teaching '
     'quality and student productivity.'),
    ('💰 Low Cost to Deploy',
     'The entire system runs on free-tier cloud services. The university does not need to '
     'buy servers, install software, or hire a dedicated IT team to run it.'),
    ('📈 Scales With the University',
     'As Cavendish grows — more students, more rooms, more departments — Campus Compass '
     'scales with it. Labs, seminar rooms, and any bookable facility can be added easily.'),
    ('🌍 Built for Uganda',
     "Africa's Talking SMS integration, Kampala timezone, and offline PWA support make "
     'this system designed for the real conditions students and staff face on campus — '
     'not imported from a different context.'),
]
for title, body in worth_it:
    add_highlight_box(f'{title}\n{body}', fill='DDE5F5', bar_color='1A3A6E')

# ══ FOOTER ═════════════════════════════════════════════════════════════════════
doc.add_paragraph()
footer_tbl = doc.add_table(rows=1, cols=1)
footer_tbl.style = 'Table Grid'
fc = footer_tbl.cell(0, 0)
shade_cell(fc, '102650')
no_border_cell(fc)
fp = fc.paragraphs[0]
fp.alignment = WD_ALIGN_PARAGRAPH.CENTER
fp.paragraph_format.space_before = Pt(12)
fp.paragraph_format.space_after  = Pt(12)
add_run(fp, 'Campus Compass  |  Cavendish University Uganda\n',
        bold=True, size=11, color=WHITE)
add_run(fp, 'IEEE CUU Student Branch  |  Innovation Pitch 2026\n',
        size=9.5, color=RGBColor(0x8e, 0xa8, 0xd8))
add_run(fp, '"Know the room. Own the day."',
        italic=True, size=9, color=RGBColor(0x66, 0x88, 0xbb))

# ── Save ──────────────────────────────────────────────────────────────────────
output_path = r'd:\PROJECTS\LECTURE ROOM BOOKING\docs\Campus_Compass_Manual.docx'
doc.save(output_path)
print(f'Saved: {output_path}')
