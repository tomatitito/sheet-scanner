---
id: sheet-scanner-6zc
status: closed
deps: []
links: []
created: 2025-12-13T09:51:32.041376+01:00
type: bug
priority: 1
---
# Scan flow navigation leaves user stranded multiple levels deep

The scan → OCR review → save flow has navigation issues that strand users:

1. User opens AddSheetPage (modal bottom sheet from HomePage)
2. Taps 'Scan Sheet Music' button (add_sheet_page.dart:323)
3. Navigates to /scan with context.push() (line 323)
4. After OCR, navigates to /ocr-review with context.push() (scan_camera_page.dart:217)
5. After save, OCRReviewPage calls Navigator.pop() (ocr_review_page.dart:142)
6. User is back at scan camera page (should be at home)

The navigation stack becomes: Home → AddSheetPage (modal) → Scan → OCR Review
After save: Home → AddSheetPage (modal) → Scan

Impact: User must navigate back through multiple screens after completing a simple scan workflow.

Fix: Use context.go('/') or pop multiple times to return directly to home after successful save.


