---
id: sheet-scanner-b0w
status: closed
deps: []
links: []
created: 2025-12-13T09:53:26.905186+01:00
type: bug
priority: 1
---
# P1: N+1 query problem in getAllTagsWithCount

Database.getAllTagsWithCount (database.dart:114-126) loops through all tags and makes separate query for each to count usage.

With 100 tags = 101 database queries (1 for tags, 100 for counts).

Should use single JOIN query:
SELECT t.*, COUNT(st.sheet_music_id) as count
FROM tags t
LEFT JOIN sheet_music_tags st ON t.id = st.tag_id  
GROUP BY t.id

File: lib/core/database/database.dart:114-126


