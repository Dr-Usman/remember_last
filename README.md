# RememberLast

Offline-first **Last Done Tracker** — remember when you last did anything.

Not a habit tracker. No streaks, no pressure. Just log when you did something and see how long ago it was.

## Features

- Track any activity (water plants, car wash, call parents, etc.)
- See **last done time** and **elapsed time** (e.g. "3 days ago")
- Status indicators: Recent / Due soon / Overdue (when reminder is set)
- Quick log from home screen
- Full history per activity with custom backdated entries
- Search, filter by category, sort (recently done, overdue, A–Z)
- Swipe to delete with confirmation
- Insights with average intervals and bar chart
- JSON export/import backup
- Dark mode support
- Fully offline — no auth, no analytics

## Tech Stack

- Flutter (Material 3)
- Riverpod (state management)
- Drift (local SQLite database)
- go_router (navigation)
- fl_chart (insights)

## Getting Started

```bash
flutter pub get
dart run build_runner build
flutter run
```

## Project Structure

```
lib/
├── core/           # Database, theme, router, utils, shared widgets
├── features/
│   ├── activities/ # CRUD, home screen, form
│   ├── occurrences/# Logging, detail screen, history
│   ├── insights/   # Stats and charts
│   └── backup/     # JSON export/import
└── bootstrap/      # Seed data on first launch
```

## Regenerate Drift Code

After changing database schema:

```bash
dart run build_runner build
```
