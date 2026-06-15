---
id: sheet-scanner-va1
status: closed
deps: []
links: []
created: 2025-12-13T09:52:38.70644+01:00
type: bug
priority: 2
---
# No accessibility semantics for critical interactive elements

While the app has lib/core/accessibility/semantic_widgets.dart, it's not being used in critical UI elements:

Missing accessibility:
1. Scan camera page floating action button (scan_camera_page.dart:409-428) has no semantic label
2. Grid overlay toggle button (line 383) - users can't tell what it does
3. Flash toggle button (line 394) - no semantic label for current state
4. Image preview (ocr_review_page.dart:341-354) - no semantic label describing the captured image
5. Tag chips have no semantic labels for delete action
6. Confidence indicators have no screen reader announcements

Impact: App is difficult/impossible to use with screen readers, violates accessibility guidelines.

Fix: Add Semantics widgets with proper labels, hints, and state announcements to all interactive elements.


