---
id: sheet-scanner-we8
status: closed
deps: []
links: []
created: 2025-12-13T09:49:56.069172+01:00
type: bug
priority: 0
---
# P0: Fix broken integration tests - 16 compilation errors

The integration test file scan_to_save_workflow_test.dart has 16 compilation errors including:
- Undefined getters on AppDatabase: sheetMusic, tags, sheetMusicTags
- Undefined method 'or' on Finder type
- Undefined function 'innerJoin'
- Use of void result error

These tests are completely broken and need immediate fixing to restore test coverage for the critical scan-to-save workflow.

File: integration_test/scan_to_save_workflow_test.dart
Impact: No integration test coverage for scan workflow


