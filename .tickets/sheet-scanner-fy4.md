---
id: sheet-scanner-fy4
status: closed
deps: []
links: []
created: 2025-12-13T09:51:01.891491+01:00
type: bug
priority: 1
---
# No Cubits override close() method to clean up resources

Analysis of all 12 Cubit files shows NONE of them override close() to clean up resources:
- lib/features/sheet_music/presentation/cubit/home_cubit.dart
- lib/features/sheet_music/presentation/cubit/add_sheet_cubit.dart
- lib/features/sheet_music/presentation/cubit/edit_sheet_cubit.dart
- lib/features/sheet_music/presentation/cubit/browse_cubit.dart
- lib/features/sheet_music/presentation/cubit/sheet_detail_cubit.dart
- lib/features/sheet_music/presentation/cubit/bulk_operations_cubit.dart
- lib/features/sheet_music/presentation/cubit/ocr_review_cubit.dart
- lib/features/ocr/presentation/cubit/ocr_scan_cubit.dart (has close() but only logs, doesn't cancel operations)
- lib/features/search/presentation/cubit/search_cubit.dart
- lib/features/search/presentation/cubit/tag_cubit.dart
- lib/features/search/presentation/cubit/tag_suggestion_cubit.dart
- lib/features/backup/presentation/cubit/backup_cubit.dart

If any cubit has pending async operations, stream subscriptions, or other resources, they won't be cleaned up.

Impact: Memory leaks, continued operations after widget disposal, potential crashes.

Fix: Override close() in each cubit that needs cleanup and cancel pending operations.


