---
id: sheet-scanner-6ib
status: closed
deps: []
links: []
created: 2025-12-13T09:52:29.306272+01:00
type: bug
priority: 0
---
# P0: FTS index not maintained on sheet music insert

Critical bug: Full-text search index inconsistency

insertSheetMusic (sheet_music_local_datasource.dart:55-65) inserts into sheetMusicTable but NOT sheetMusicFtsTable.
deleteSheetMusic (line 96-106) deletes from BOTH tables.

This causes:
1. New sheets won't appear in search results
2. FTS index becomes stale
3. Full-text search effectively broken for new data

Search will only find sheets that existed before a certain point, missing all newly added sheets.

Related: Database should use triggers to auto-maintain FTS index, not manual sync in datasource.

Files:
- lib/features/sheet_music/data/datasources/sheet_music_local_datasource.dart:55-65,96-106
- lib/core/database/database.dart (check for FTS triggers)


