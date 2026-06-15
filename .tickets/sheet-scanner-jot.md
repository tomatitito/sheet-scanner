---
id: sheet-scanner-jot
status: closed
deps: []
links: []
created: 2025-12-13T09:49:50.340322+01:00
type: bug
priority: 2
---
# P2: No error recovery for empty camera list

When availableCameras() returns empty list (line 50-56), user gets a SnackBar error but page remains stuck showing CircularProgressIndicator.

Should provide:
1. Clear error UI explaining no camera available
2. Option to pick from gallery as alternative
3. Button to go back to previous page

File: lib/features/ocr/presentation/pages/scan_camera_page.dart:52-56


