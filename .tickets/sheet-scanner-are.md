---
id: sheet-scanner-are
status: closed
deps: []
links: []
created: 2025-12-13T09:50:49.061751+01:00
type: bug
priority: 1
---
# P1: FilePickerService instantiated directly instead of via DI

AddSheetPage creates FilePickerService directly with 'new FilePickerServiceImpl()' (add_sheet_page.dart:39) instead of using dependency injection.

This breaks testability and violates clean architecture principles. Service should be injected via constructor or getIt.

Similar pattern may exist elsewhere in codebase.

File: lib/features/sheet_music/presentation/pages/add_sheet_page.dart:39


