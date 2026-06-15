---
id: sheet-scanner-xs9
status: closed
deps: []
links: []
created: 2025-12-13T09:53:27.233391+01:00
type: task
priority: 2
---
# P2: Missing database indices on foreign keys and search columns

Database tables have no indices defined, causing slow queries as data grows.

Missing indices:
1. SheetMusicTagsTable.sheetMusicId (foreign key, used in joins)
2. SheetMusicTagsTable.tagId (foreign key, used in joins)  
3. SheetMusicTable.title (used in LIKE searches, sorting)
4. SheetMusicTable.composer (used in LIKE searches, sorting)
5. SheetMusicTable.createdAt (used for sorting)

Without indices:
- All joins require full table scans
- Tag lookups scan entire sheet_music_tags table
- Sort by date scans all sheets

Drift supports index definitions. Should add:
- .index([sheetMusicId]) to SheetMusicTagsTable
- .index([tagId]) to SheetMusicTagsTable  
- .index([title, composer, createdAt]) to SheetMusicTable

File: lib/core/database/database.dart:10-50


