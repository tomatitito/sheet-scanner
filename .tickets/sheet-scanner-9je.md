---
id: sheet-scanner-9je
status: closed
deps: []
links: []
created: 2025-12-13T09:51:29.645198+01:00
type: bug
priority: 1
---
# Change Image button in OCR review desktop layout has empty handler

In lib/features/sheet_music/presentation/pages/ocr_review_page.dart:588-594, the 'Change Image' button in desktop layout has an empty onPressed handler: onPressed: isSubmitting ? null : () {}

This button is visible on desktop but does nothing when clicked.

Impact: Poor UX on desktop - non-functional button.

Fix: Either implement image change functionality or remove the button.


