# FaceAttend — Web Admin Dashboard

A Flutter Web admin dashboard for the **FaceAttend** face-recognition attendance system.
Connects to the same Supabase backend as the mobile app — no extra backend or server needed.

---

## Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Admin Credentials](#admin-credentials)
- [Screens](#screens)
- [Architecture](#architecture)
- [Database Schema](#database-schema)
- [Getting Started](#getting-started)
- [Running the App](#running-the-app)
- [Building for Production](#building-for-production)
- [Environment & Configuration](#environment--configuration)
- [Routing](#routing)
- [Services](#services)
- [Controllers](#controllers)
- [Theme & Design System](#theme--design-system)
- [CSV Export](#csv-export)
- [How It Connects to the Mobile App](#how-it-connects-to-the-mobile-app)

---

## Overview

| Feature | Details |
|---|---|
| Platform | Flutter Web (Chrome, Edge, Firefox) |
| Login | Admin credentials — same as mobile app |
| Data | Live from Supabase (same DB as mobile) |
| Charts | Weekly attendance bar chart (fl_chart) |
| Export | CSV download from the Attendance screen |
| Responsive | Desktop-optimised (1024px+), mobile fallback |

---

## Tech Stack

| Package | Version | Purpose |
|---|---|---|
| `flutter` | SDK | UI framework |
| `get` | ^4.7.2 | State management + routing |
| `supabase_flutter` | ^2.5.0 | Backend / database client |
| `fl_chart` | ^0.69.0 | Bar chart (weekly attendance) |
| `intl` | ^0.19.0 | Date & time formatting |
| `dart:html` | built-in | CSV file download in browser |

---

## Project Structure

```
attendance_web_dashboard/
│
├── lib/
│   ├── main.dart                        # App entry point, Supabase init, session check
│   │
│   ├── core/
│   │   ├── supabase_config.dart         # Supabase URL + anon key constants
│   │   ├── app_theme.dart               # Material 3 theme, colours, typography
│   │   └── routes.dart                  # GetPages + Bindings for all routes
│   │
│   ├── models/
│   │   ├── attendance_model.dart        # AttendanceModel + AttendanceStatus enum
│   │   └── employee_model.dart          # EmployeeModel
│   │
│   ├── services/
│   │   ├── web_auth_service.dart        # Login, logout, session, company ID
│   │   └── dashboard_service.dart       # All Supabase queries (parallel via Future.wait)
│   │
│   ├── controllers/
│   │   ├── auth_controller.dart         # Login form state, validation, routing
│   │   ├── overview_controller.dart     # Stats + chart + activity data
│   │   ├── employees_controller.dart    # Employee list, search, pagination
│   │   └── attendance_controller.dart   # Attendance records, date filter, CSV export
│   │
│   └── screens/
│       ├── login_screen.dart            # Split layout: branding left / form right
│       ├── dashboard_layout.dart        # Shell: 240px sidebar + topbar + content
│       ├── overview_screen.dart         # Stats cards + bar chart + activity feed
│       ├── employees_screen.dart        # Searchable table + pagination
│       └── attendance_screen.dart       # Date filter + table + CSV export
│
├── web/
│   ├── index.html                       # Flutter bootstrap, branded loading screen
│   └── manifest.json                    # PWA manifest
│
├── build/
│   └── web/                             # Production build output (ready to deploy)
│
└── pubspec.yaml
```

---

## Admin Credentials

The web dashboard uses the **same Supabase Auth** as the Flutter mobile app.
There are no separate dashboard accounts — one admin account works everywhere.

---

### Where do credentials come from?

When someone **registers** in the Flutter mobile app (Sign Up screen), the app:
1. Creates a Supabase Auth user
2. Creates a row in `companies` table
3. Creates a row in `profiles` table with `role = 'admin'`

Those same email + password are used to log in here.

---

### Login rules

| Condition | Result |
|---|---|
| Valid email + password, `profiles.role = 'admin'` | ✅ Access granted → loads your company data |
| Valid email + password, `profiles.role = 'employee'` | ❌ Blocked — "Only admin accounts can access the dashboard" |
| Wrong email or password | ❌ Supabase auth error shown |
| No profile found in DB | ❌ Signed out silently |

---

### How to create an admin account

**Option A — Use the Flutter mobile app (recommended)**
1. Open the Flutter attendance app on Android/iOS
2. Tap **Sign Up**
3. Fill in: Name, Email, Password, Employee ID (optional)
4. Tap **Register** → creates your admin account + company automatically
5. Use that same email + password on the web dashboard

**Option B — Create directly in Supabase**
1. Go to [supabase.com](https://supabase.com) → your project
2. **Authentication → Users → Add User** → enter email + password
3. **Table Editor → profiles → Insert Row**:

```
id          → (paste the user UUID from step 2)
company_id  → (UUID of your company from the companies table)
name        → Your Name
role        → admin
is_active   → true
is_face_registered → false
```

---

### Verify your role in Supabase

If login is blocked with "Access Denied":

1. Go to [supabase.com](https://supabase.com) → your project
2. **Table Editor → profiles**
3. Find your row (match by email in the `auth.users` table)
4. Check `role` column — must be `admin` (not `employee`)
5. If it says `employee`, click the cell and change it to `admin`

---

### Session persistence

- The dashboard remembers your session after refresh (Supabase stores the token in browser `localStorage`)
- You stay logged in until you click **Logout** in the sidebar or the Supabase token expires (default: 1 hour, auto-refreshed while active)
- Closing and reopening the browser tab will restore your session automatically

---

### Security — how the dashboard enforces admin-only access

From [`lib/services/web_auth_service.dart`](lib/services/web_auth_service.dart):

```dart
// After Supabase Auth login succeeds, the role is checked:
if (data['role'] != 'admin') {
  await _client.auth.signOut();   // immediately sign out
  // shows "Only admin accounts can access the dashboard"
  return;
}
```

Even if someone has valid Supabase credentials, they cannot access the dashboard unless their `profiles.role` is exactly `'admin'`.

---

## Screens

### 1. Login Screen (`/login`)

- Split layout on desktop: gradient blue branding panel (left) + white form panel (right)
- Mobile: single centred card
- Fields: Email + Password (toggle visibility)
- Validates admin role — employees cannot log in to the dashboard
- On success: navigates to `/dashboard`

```
┌─────────────────────────────────────────────────────────┐
│  ██████████████████  │  Email ________________________  │
│                      │                                  │
│   FaceAttend         │  Password _____________________  │
│   Admin Dashboard    │                                  │
│                      │       [ Sign In ]                │
│  Face recognition    │                                  │
│  attendance system   │                                  │
└─────────────────────────────────────────────────────────┘
```

---

### 2. Dashboard Layout (Shell)

Wraps all authenticated screens. Contains:

**Sidebar (240px fixed)**
- Logo + "FaceAttend" branding at top
- Navigation items with icons:
  - Overview (`/dashboard`)
  - Employees (`/dashboard/employees`)
  - Attendance (`/dashboard/attendance`)
- Active item highlighted with light blue background
- Logout button at bottom

**Top Bar**
- Current page title
- Today's date
- Admin name + company name (from Supabase session)

```
┌──────────────┬──────────────────────────────────────────┐
│  FaceAttend  │  Overview          Admin: John · Acme Co │
│              ├──────────────────────────────────────────┤
│  Overview  ◀ │                                          │
│  Employees   │         [ content area ]                 │
│  Attendance  │                                          │
│              │                                          │
│  [Logout]    │                                          │
└──────────────┴──────────────────────────────────────────┘
```

---

### 3. Overview Screen (`/dashboard`)

**Stat Cards Row (5 cards)**

| Card | Icon | Colour |
|---|---|---|
| Total Employees | people | Blue |
| Faces Registered | face | Green |
| Present Today | check_circle | Blue |
| Late Today | schedule | Orange |
| Absent Today | cancel | Red |

**Weekly Attendance Bar Chart**
- X-axis: last 7 days (Mon → today)
- Two bar groups per day: Present (blue) + Late (orange)
- Powered by `fl_chart` `BarChart`
- Legend below chart

**Today's Activity Feed**
- Last 10 check-ins for today across all employees
- Shows: employee name, check-in time, status chip (Present / Late)

**Attendance Rate**
- Calculated as: `(present + late) / totalEmployees × 100`
- Displayed as percentage

---

### 4. Employees Screen (`/dashboard/employees`)

- **Search bar** — filters by name or employee ID in real time
- **Data table** with columns:

| # | Name | Employee ID | Department | Designation | Face Registered | Status |
|---|---|---|---|---|---|---|
| 1 | John Smith | EMP001 | Engineering | Developer | ✅ Registered | Active |
| 2 | Jane Doe | EMP002 | HR | Manager | ❌ Not Registered | Active |

- **Face Registered chip**: green "Registered" / red "Not Registered"
- **Status chip**: green "Active" / grey "Inactive"
- **Pagination**: 10 rows per page, Prev / Next buttons
- **Refresh button** top-right

---

### 5. Attendance Screen (`/dashboard/attendance`)

**Filters**
- From Date picker + To Date picker
- Apply button (loads filtered records)
- Default: last 30 days

**Summary Chips**
- X Present (blue)
- X Late (orange)
- X Absent (red)

**Data Table**

| Date | Name | Emp ID | Check In | Check Out | Break | Working Hours | Status |
|---|---|---|---|---|---|---|---|
| 15 Jan | John | EMP001 | 9:05 AM | 6:02 PM | 45m | 7h 12m | Present |
| 15 Jan | Jane | EMP002 | 9:47 AM | — | — | 6h 30m | Late |

- Times formatted as `9:05 AM`
- Duration formatted as `7h 12m`
- Status shown as coloured chip
- Pagination: 10 rows per page

**CSV Export**
- Clicking "Export CSV" downloads a `.csv` file using `dart:html`
- Filename: `attendance_YYYY-MM-DD.csv`
- Columns: Date, Employee Name, Employee ID, Check In, Check Out, Break Duration, Working Hours, Status

---

## Architecture

```
View (Screen)
    │ Obx()
    ▼
Controller (GetxController)
    │ calls
    ▼
Service (GetxService)
    │ queries
    ▼
Supabase Client
    │
    ▼
Supabase Database (same as mobile app)
```

- **Services** are registered as permanent singletons (`permanent: true`)
- **Controllers** are lazy-loaded per route via `Bindings`
- All reactive state uses `RxInt`, `RxBool`, `RxList`, `RxString`
- UI rebuilds via `Obx()` wrappers — no `setState` anywhere

---

## Database Schema

The dashboard reads from these Supabase tables (shared with the mobile app):

### `companies`
| Column | Type | Notes |
|---|---|---|
| id | uuid (PK) | Company identifier |
| name | text | Company name |
| email | text | Admin email |

### `profiles`
| Column | Type | Notes |
|---|---|---|
| id | uuid (PK) | Same as Supabase auth user id |
| company_id | uuid (FK) | Links to companies |
| name | text | Full name |
| employee_id | text | e.g. EMP001 |
| role | text | `admin` or `employee` |
| department | text | e.g. Engineering |
| designation | text | e.g. Developer |
| is_face_registered | bool | Face enrolled for kiosk |
| is_active | bool | Soft-delete flag |

### `attendance`
| Column | Type | Notes |
|---|---|---|
| id | uuid (PK) | |
| user_id | uuid (FK) | Links to profiles |
| company_id | uuid (FK) | Links to companies |
| date | date | Local date (YYYY-MM-DD) |
| check_in_time | timestamptz | UTC |
| check_out_time | timestamptz | UTC, nullable |
| break_start_time | timestamptz | UTC, nullable |
| break_end_time | timestamptz | UTC, nullable |
| status | text | `present`, `late`, `absent` |
| check_in_image_url | text | Signed URL (7 days) |
| check_out_image_url | text | Signed URL (7 days) |

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.0.0` installed
- Chrome browser
- The mobile app's Supabase project already set up

### Install dependencies

```bash
cd attendance_web_dashboard
flutter pub get
```

---

## Running the App

```bash
# Run in Chrome (development)
flutter run -d chrome

# Run on a specific port
flutter run -d chrome --web-port 3000
```

Open `http://localhost:3000` in Chrome.

**Login** with the same admin email and password used in the Flutter mobile app.

---

## Building for Production

```bash
flutter build web --release
```

Output is in `build/web/`. Deploy this folder to any static host:

| Host | Command |
|---|---|
| Firebase Hosting | `firebase deploy` |
| Netlify | Drag & drop `build/web/` folder |
| Vercel | `vercel --prod` |
| GitHub Pages | Push `build/web/` to `gh-pages` branch |
| Any VPS | Serve `build/web/` with nginx/caddy |

---

## Environment & Configuration

Supabase credentials are in [`lib/core/supabase_config.dart`](lib/core/supabase_config.dart):

```dart
class SupabaseConfig {
  static const url     = 'https://srprdlitfssulcrgvrsj.supabase.co';
  static const anonKey = 'sb_publishable__nxT4SVxA5C8_CjM-I8XPg_ixuwiQzY';
}
```

To inject at build time instead (recommended for CI/CD):

```bash
flutter build web \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Then in `supabase_config.dart`:
```dart
static const url     = String.fromEnvironment('SUPABASE_URL', defaultValue: '...');
static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '...');
```

---

## Routing

| Route | Screen | Binding |
|---|---|---|
| `/login` | `LoginScreen` | `AuthBinding` |
| `/dashboard` | `DashboardLayout` → `OverviewScreen` | `DashboardBinding` |
| `/dashboard/employees` | `DashboardLayout` → `EmployeesScreen` | `EmployeesBinding` |
| `/dashboard/attendance` | `DashboardLayout` → `AttendanceScreen` | `AttendanceBinding` |
| `/404` | Not Found page | — |

All routes defined in [`lib/core/routes.dart`](lib/core/routes.dart).

---

## Services

### `WebAuthService` ([lib/services/web_auth_service.dart](lib/services/web_auth_service.dart))

| Method / Property | Description |
|---|---|
| `init()` | Restore session on app start |
| `login(email, password)` | Sign in, verify role == admin, store company ID |
| `logout()` | Sign out, redirect to login |
| `isLoggedIn` | `bool` — checks Supabase current session |
| `currentCompanyId` | `RxString` — company UUID for data filtering |
| `adminName` | Admin's full name from profile |
| `companyName` | Company name from DB |

---

### `DashboardService` ([lib/services/dashboard_service.dart](lib/services/dashboard_service.dart))

All queries are company-scoped (filtered by `company_id`).

| Method | Returns | Notes |
|---|---|---|
| `fetchOverviewStats(companyId)` | `Map<String, int>` | 5 queries in parallel via `Future.wait` |
| `fetchWeeklyAttendance(companyId)` | `List<Map>` | Last 7 days, date + presentCount + lateCount |
| `fetchTodayActivity(companyId)` | `List<Map>` | Last 10 check-ins, joins `profiles` |
| `fetchEmployees(companyId)` | `List<EmployeeModel>` | All active non-admin employees |
| `fetchAttendanceRecords(companyId, from, to)` | `List<Map>` | Date-filtered, joins employee name |

---

## Controllers

### `AuthController`
- `emailController`, `passwordController` — form fields
- `formKey` — form validation
- `isLoading`, `obscurePassword` — reactive state
- `login()` — validates, calls service, routes by role
- `logout()` — clears session, goes to `/login`

### `OverviewController`
- `totalEmployees`, `registeredFaces`, `presentToday`, `lateToday`, `absentToday` — `RxInt`
- `weeklyData` — `RxList<Map>` for bar chart
- `todayActivity` — `RxList<Map>` for activity feed
- `attendanceRate` — computed `double`
- `loadAll()` — parallel fetch on `onInit`
- `refresh()` — re-fetches all data

### `EmployeesController`
- `employees`, `filteredEmployees` — `RxList<EmployeeModel>`
- `searchQuery` — `RxString`, filters in real time
- `currentPage`, `totalPages` — pagination state
- `fetchEmployees()` — loads from service

### `AttendanceController`
- `records` — `RxList<Map>` with employee name included
- `fromDate`, `toDate` — `Rx<DateTime>` filter range
- `presentCount`, `lateCount`, `absentCount` — computed from records
- `applyFilter(from, to)` — re-fetches with new date range
- `exportCsv()` — builds CSV string + triggers browser download

---

## Theme & Design System

Defined in [`lib/core/app_theme.dart`](lib/core/app_theme.dart).

### Colours

| Token | Value | Usage |
|---|---|---|
| `primaryColor` | `#1565C0` | Buttons, active nav, chart bars |
| `primaryLight` | `#1E88E5` | Hover states |
| `primaryDark` | `#0D47A1` | Sidebar background |
| `successColor` | `#43A047` | Present chip, registered badge |
| `warningColor` | `#FB8C00` | Late chip, late bar in chart |
| `errorColor` | `#E53935` | Absent chip, error states |
| `backgroundGrey` | `#F5F7FA` | Page background |
| `cardBackground` | `#FFFFFF` | Card / table background |
| `textPrimary` | `#1A1F36` | Headings, values |
| `textSecondary` | `#6B7280` | Labels, subtitles |
| `sidebarBackground` | `#0D47A1` | Sidebar dark blue |

### Typography (Material 3)

| Style | Size | Weight | Usage |
|---|---|---|---|
| `headlineMedium` | 22px | 700 | Page titles |
| `headlineSmall` | 18px | 600 | Section titles |
| `titleLarge` | 16px | 600 | Card headers |
| `titleMedium` | 14px | 500 | Table column headers |
| `bodyLarge` | 15px | 400 | Table cell values |
| `bodyMedium` | 14px | 400 | Secondary text |
| `bodySmall` | 12px | 400 | Chips, timestamps |

### Cards
- Elevation: 0 (flat with border)
- Border: `1px solid #E5E7EB`
- Border radius: `16px`
- Background: white

---

## CSV Export

The Attendance screen exports a `.csv` file directly from the browser using `dart:html`:

```dart
// attendance_controller.dart
void exportCsv() {
  final buffer = StringBuffer();
  // Header row
  buffer.writeln('Date,Employee Name,Employee ID,Check In,Check Out,Break,Working Hours,Status');
  // Data rows
  for (final record in records) {
    buffer.writeln('${record['date']},${record['name']},...');
  }
  // Trigger download
  final blob = html.Blob([buffer.toString()], 'text/csv');
  final url  = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..setAttribute('download', 'attendance_${DateTime.now().toIso8601String().split('T').first}.csv')
    ..click();
  html.Url.revokeObjectUrl(url);
}
```

The downloaded file opens directly in Excel or Google Sheets.

---

## How It Connects to the Mobile App

Both apps share **exactly the same Supabase project** — no data duplication:

```
┌─────────────────────┐         ┌─────────────────────┐
│  Flutter Mobile App │         │  Flutter Web Dashboard│
│  (Android / iOS)    │         │  (Chrome browser)     │
│                     │         │                       │
│  Employee scans     │         │  Admin views stats    │
│  face → check in    │         │  exports CSV          │
│  via kiosk          │         │  monitors attendance  │
└──────────┬──────────┘         └──────────┬────────────┘
           │                               │
           │  supabase_flutter             │  supabase_flutter
           │                               │
           ▼                               ▼
    ┌─────────────────────────────────────────┐
    │         Supabase Backend                │
    │                                         │
    │  companies │ profiles │ attendance      │
    │  Auth      │ Storage  │ Realtime        │
    └─────────────────────────────────────────┘
```

| Mobile App does | Web Dashboard does |
|---|---|
| Employee face registration | View face registration status |
| Check in / check out | View today's attendance |
| Break start / end | View break durations |
| Kiosk identify employee | Export attendance CSV |
| Admin invites employees | Monitor present / late / absent |

---

## Quick Reference

```bash
# Install dependencies
flutter pub get

# Run in Chrome
flutter run -d chrome

# Build for production
flutter build web --release

# Deploy build output
# → Copy build/web/ to your hosting provider
```

---

*Part of the FaceAttend attendance management system.*
