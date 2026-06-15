---
id: sheet-scanner-iuh
status: closed
deps: []
links: []
created: 2025-12-13T09:50:25.703265+01:00
type: bug
priority: 0
---
# Critical: Mixed navigation APIs (Navigator vs go_router) causes routing bugs

The codebase mixes legacy Navigator.pop() with go_router's context.pop() throughout multiple files. This causes inconsistent navigation behavior and breaks go_router's declarative routing.

Affected files:
- lib/main.dart:61 - Uses Navigator.pop(context) in keyboard shortcut handler
- lib/features/sheet_music/presentation/pages/home_page.dart:112,134,158 - Uses Navigator.pop
- lib/features/ocr/presentation/pages/scan_camera_page.dart:491,509,514 - Uses Navigator.pop
- lib/features/sheet_music/presentation/pages/ocr_review_page.dart:142,244,533 - Uses Navigator.pop

Impact: Unpredictable back navigation, breaks browser back button on web, inconsistent app state.

Fix: Replace ALL Navigator.pop(context) calls with context.pop() to use go_router consistently.


