---
id: sheet-scanner-la5
status: closed
deps: []
links: []
created: 2025-12-13T09:52:39.813343+01:00
type: bug
priority: 2
---
# No network error handling despite potential network operations

The codebase has no NetworkFailure or connectivity error handling, but may need network access in the future for:
- Cloud backup/sync
- OCR service API calls (if using cloud OCR)
- Image cloud storage
- Multi-device sync

Current error types in failures.dart:
- DatabaseFailure
- FileSystemFailure  
- OCRFailure
- SearchFailure
- BackupFailure
- ValidationFailure
- PermissionFailure
- PlatformFailure

But no NetworkFailure for network-related errors.

Impact: If network features are added, no standardized way to handle connectivity errors.

Fix: 
1. Add NetworkFailure to failures.dart
2. Add connectivity checking utility
3. Add offline mode indicators
4. Plan for graceful degradation when offline


