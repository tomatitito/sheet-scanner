---
id: sheet-scanner-spc
status: closed
deps: []
links: []
created: 2025-12-13T09:51:33.228578+01:00
type: bug
priority: 1
---
# Async operations in Cubits don't check if cubit is closed before emitting

In multiple Cubits, async operations emit state changes without checking if the cubit has been closed:

Examples:
- lib/features/sheet_music/presentation/cubit/add_sheet_cubit.dart:104-111 (submitForm)
- lib/features/ocr/presentation/cubit/ocr_scan_cubit.dart:79-101 (processOCR)
- lib/features/sheet_music/presentation/cubit/home_cubit.dart:14-28 (loadSheetMusic)

If the user navigates away before the async operation completes, the cubit is closed but the operation continues and tries to emit to a closed cubit, causing errors.

Impact: 'Bloc was closed' errors in console, potential crashes.

Fix: Check isClosed before emitting:
if (!isClosed) {
  emit(newState);
}


