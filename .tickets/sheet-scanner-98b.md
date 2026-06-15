---
id: sheet-scanner-98b
status: closed
deps: []
links: []
created: 2025-12-13T09:53:02.83819+01:00
type: task
priority: 1
---
# P1: Extremely low test coverage (4 tests for 100+ files)

Project has only 4 test files covering ~100+ source files, indicating <5% test coverage.

Missing tests for:
- All Cubits (home, browse, add_sheet, edit_sheet, ocr_review, search, tag, backup)
- All UseCases (add, update, delete, search, tags, backup)
- All Repositories
- All DataSources (except 1 backup test)
- Most presentation pages
- Database layer
- Error handling paths

Critical paths with ZERO tests:
- Navigation flows (we found bugs here!)
- State management (singleton cubit bug would be caught)
- FTS index maintenance (P0 bug would be caught)
- Error recovery scenarios

Recommendation: Add tests for at least:
1. All cubits (state transitions)
2. Critical use cases (CRUD operations)
3. Navigation flows (integration tests)
4. Error paths in datasources

## Notes

Added comprehensive test suite for domain layer: 80+ new tests covering core errors, Either type, entities, use cases, and cubits. Test count increased from ~50 to 194 tests. Tests follow AAA pattern with proper mocking and edge case coverage.


