---
id: sheet-scanner-44q
status: closed
deps: []
links: []
created: 2025-12-13T09:52:29.477273+01:00
type: task
priority: 2
---
# P2: No batch/transaction support for bulk operations

BulkOperationsCubit exists but datasource has no batch delete method. Each delete is a separate transaction.

Deleting 100 sheets = 100 separate database transactions, very slow.

Should add:
- deleteBatch(List<int> ids) with single transaction
- updateBatch() for bulk updates
- Use Drift's batch() API for atomic multi-row operations

File: lib/features/sheet_music/data/datasources/sheet_music_local_datasource.dart


