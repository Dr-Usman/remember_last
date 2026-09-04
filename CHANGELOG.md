# Changelog

All notable changes to RememberLast are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.0] - 2026-09-04

### Added

- In-app language picker (system default or override) with Flutter gen_l10n support for 21 locales. Non-English copy is machine-translated for a first pass.

### Changed

- Language picker redesigned as a bottom-sheet grid; theme selection aligned to primary blue.
- Dependencies and tooling bumps (Flutter CI 3.47.2, file_picker 12.2 API, Drift codegen refresh).

## [1.1.0] - 2026-09-02

### Added

- Optional Mixpanel usage analytics with first-launch consent dialog and Settings toggle.
- Screen view and occurrence logging (anonymous; no activity titles, notes, or personal content).
- Settings About actions: share app, rate app, contact us, and more from developer.

### Changed

- Privacy policy updated to disclose optional Mixpanel analytics and how to opt out.
- Contact us subtitle describes feedback instead of showing the email address.
- Rate app opens the store listing directly (not the quota-limited in-app review sheet).
- Home sort control moved into the search row for a denser filter bar.

### Fixed

- Crash when canceling the category rename or add dialog caused by disposing the text field controller too early.
- Contact us mail subject used `+` instead of spaces in some mail apps.
- Text fields dismiss the keyboard when tapping outside.
- Rate app doing nothing on repeat taps after dismissing the in-app review prompt.

## [1.0.0] - 2026-07-21

### Added

- Offline-first last done tracker for activities with elapsed time and status indicators.
- Quick log, full history with backdated entries, categories, search, filter, and sort.
- Insights with average intervals and bar chart.
- JSON export/import backup.
- Light and dark brand themes.
- In-app and hosted privacy policy for Play Store listing.
- GitHub Actions CI, multi-platform releases, and GitHub Pages web deploy.
