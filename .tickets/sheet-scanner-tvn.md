---
id: sheet-scanner-tvn
status: closed
deps: []
links: []
created: 2025-12-13T09:52:35.577681+01:00
type: bug
priority: 1
---
# P1: Silent exception swallowing in addTagToSheetMusic

SheetMusicLocalDataSourceImpl.addTagToSheetMusic (sheet_music_local_datasource.dart:168-177) has empty catch block that swallows ALL exceptions.

Problems:
1. Catches ALL exceptions, not just unique constraint violations
2. Database errors (connection lost, disk full) are silently ignored  
3. No logging makes debugging impossible
4. Comment says 'Tag association already exists' but ANY error gets same treatment

Should catch specific DriftException and check for unique constraint error code, log other errors.

File: lib/features/sheet_music/data/datasources/sheet_music_local_datasource.dart:168-177


