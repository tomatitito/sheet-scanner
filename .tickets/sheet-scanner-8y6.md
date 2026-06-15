---
id: sheet-scanner-8y6
status: closed
deps: []
links: []
created: 2025-12-13T09:52:28.215419+01:00
type: bug
priority: 1
---
# P1: filterByDateRange loads entire database into memory

SearchLocalDataSourceImpl.filterByDateRange (search_local_datasource.dart:68-81) loads ALL sheet music into memory with database.select().get(), then filters in Dart.

With 10,000+ sheets, this causes:
- High memory usage
- Slow performance 
- Potential OutOfMemory on mobile devices

Root cause: Comment says 'Drift doesn't provide convenient DateTime comparison operators' but Drift DOES support custom expressions for date comparisons.

Should use Drift's CustomExpression for efficient SQL WHERE clause filtering.

File: lib/features/search/data/datasources/search_local_datasource.dart:68-81


