---
id: sheet-scanner-aov
status: closed
deps: []
links: []
created: 2025-12-13T09:52:05.195221+01:00
type: task
priority: 2
---
# Extremely poor test coverage: 4 test files for 107 source files (3.7%)

The project has only 4 test files covering 107 Dart source files:

Test files:
- test/features/sheet_music/presentation/pages/add_sheet_page_scan_flow_test.dart
- test/features/ocr/presentation/pages/scan_camera_page_test.dart
- test/features/backup/data/datasources/backup_local_datasource_test.dart
- test/features/backup/domain/usecases/export_database_use_case_test.dart

This represents ~3.7% test coverage, which is extremely low for a production app.

Missing test coverage:
- All 12 Cubits (state management logic)
- All use cases except export_database
- All repositories
- All data sources except backup
- Most UI pages
- Router configuration
- Error handling
- Validation logic

Impact: High risk of regressions, bugs go undetected, difficult to refactor safely.

Fix: Add comprehensive test coverage, target 80%+ coverage for business logic.


