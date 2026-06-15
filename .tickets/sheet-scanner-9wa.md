---
id: sheet-scanner-9wa
status: closed
deps: []
links: []
created: 2025-12-13T09:50:26.865742+01:00
type: bug
priority: 0
---
# Critical: Unsafe type casts in OCR review route cause runtime crashes

In lib/core/router/app_router.dart:42-55, the /ocr-review route uses unsafe type casts without null checks on individual map fields:
- Line 43: state.extra as Map<String, dynamic>? checks for null map
- Lines 50-53: Direct casts (extra['imagePath'] as String) without null safety

If the map is missing expected keys or has wrong types, the app will crash with a type error at runtime.

Impact: App crashes when navigating to OCR review with malformed data.

Fix: Add null-safety checks for each field:
final imagePath = extra['imagePath'] as String?;
if (imagePath == null) return ErrorWidget();
Or use a typed data class instead of Map<String, dynamic>.


