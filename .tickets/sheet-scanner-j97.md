---
id: sheet-scanner-j97
status: closed
deps: []
links: []
created: 2025-12-13T09:53:27.075117+01:00
type: bug
priority: 0
---
# P1: FTS5 table not created as virtual table

SheetMusicFtsTable (database.dart:42-50) is defined as regular Drift table, not FTS5 virtual table.

This means:
1. Table is created as normal SQLite table, not FTS5
2. Full-text search queries will fail or be very slow
3. FTS5 MATCH syntax won't work

Drift requires custom SQL for FTS5 virtual tables. Should use customStatement in onCreate migration:

CREATE VIRTUAL TABLE sheet_music_fts USING fts5(id, title, composer, notes)

And set up triggers to auto-sync with main table.

This is likely why P0 bug sheet-scanner-6ib exists - FTS not properly configured.

File: lib/core/database/database.dart:42-50


