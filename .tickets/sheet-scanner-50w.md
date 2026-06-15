---
id: sheet-scanner-50w
status: closed
deps: []
links: []
created: 2025-12-13T09:49:49.523692+01:00
type: bug
priority: 0
---
# CRITICAL: Broken OCR scan-to-add navigation flow

When user taps 'Scan Sheet Music' button in AddSheetPage (line 323), they navigate to /scan, then to /ocr-review after OCR completes. However, when they save in OCRReviewPage, Navigator.pop() only pops one level back to scan page, not to AddSheetPage. Additionally, OCR results are never passed back to AddSheetPage form, making the entire scan flow useless for adding sheets.

Files affected:
- lib/features/sheet_music/presentation/pages/add_sheet_page.dart:323
- lib/features/ocr/presentation/pages/scan_camera_page.dart:217
- lib/features/sheet_music/presentation/pages/ocr_review_page.dart:142

Expected: After saving in OCR review, user should return to AddSheetPage with form pre-populated from OCR results.
Actual: User returns to scan camera page with no data transfer.


