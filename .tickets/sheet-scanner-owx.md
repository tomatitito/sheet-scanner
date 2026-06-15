---
id: sheet-scanner-owx
status: closed
deps: []
links: []
created: 2025-12-13T09:52:34.626551+01:00
type: task
priority: 2
---
# P2: Backup and search repositories have incomplete implementations

Two repository implementation files have TODO comments indicating incomplete implementations:

1. **BackupRepositoryImpl** (lib/features/backup/data/repositories/backup_repository_impl.dart:7)
   - Comment: 'TODO: Complete implementation with actual backup logic'
   - File exists but may have stub/incomplete methods

2. **SearchRepositoryImpl** (lib/features/search/data/repositories/search_repository_impl.dart:10)
   - Comment: 'TODO: Complete implementation with actual search logic'
   - File exists but may have stub/incomplete methods

These TODOs suggest the repository layer might not be fully functional. Should verify:
- What methods are implemented vs stubbed
- Whether this affects app functionality
- If tests are passing for incomplete features

Related TODO in BackupLocalDataSource (line 117):
- Missing image paths in backup schema: 'TODO: Add image paths once schema includes them'

Files:
- lib/features/backup/data/repositories/backup_repository_impl.dart
- lib/features/search/data/repositories/search_repository_impl.dart  
- lib/features/backup/data/datasources/backup_local_datasource.dart:117


