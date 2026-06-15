---
id: sheet-scanner-ot9
status: closed
deps: []
links: []
created: 2025-12-13T09:51:28.560527+01:00
type: bug
priority: 1
---
# Settings button in scan camera page has empty handler

In lib/features/ocr/presentation/pages/scan_camera_page.dart:268-278, the Settings IconButton has an empty onPressed handler with just a comment '// Open settings modal'.

This button is visible to users but does nothing when clicked, creating confusion.

Impact: Poor UX - non-functional UI element, user frustration.

Fix: Either implement the settings functionality or remove the button until it's implemented.


