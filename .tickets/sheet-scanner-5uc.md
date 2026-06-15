---
id: sheet-scanner-5uc
status: closed
deps: []
links: []
created: 2025-12-13T09:53:38.392814+01:00
type: task
priority: 2
---
# P2: No semantic labels for accessibility

Codebase has SemanticWidget helpers (lib/core/accessibility/semantic_widgets.dart) with SemanticButton, SemanticTextField, SemanticCard etc., but they're only used in 1 file (home_page_desktop.dart).

Most of the app uses raw Flutter widgets without semantic labels:
- IconButtons without tooltips or labels (scan_camera_page.dart, add_sheet_page.dart, browse_page.dart)
- Images without descriptions
- Cards without semantic labels (browse_page.dart:425-500)
- Form fields using raw TextField instead of SemanticTextField

Impact: 95% of app is inaccessible to screen readers despite having the infrastructure.

Recommendation: Replace raw widgets with SemanticButton, SemanticTextField, SemanticCard throughout the app.


