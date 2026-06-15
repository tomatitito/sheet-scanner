---
id: sheet-scanner-lle
status: closed
deps: []
links: []
created: 2025-12-13T09:51:00.74638+01:00
type: bug
priority: 1
---
# OCR review navigation uses push instead of go/replacement breaking back flow

In lib/features/ocr/presentation/pages/scan_camera_page.dart:217-225, after OCR completes, the code uses context.push('/ocr-review') to navigate. This pushes OCR review onto the stack ON TOP of the scan camera page.

Expected flow: Scan → OCR Review → Save → Home (2 screens back)
Actual flow: Scan → OCR Review → Back button shows Scan camera again → Home (3 screens back)

Impact: Confusing navigation - user must tap back twice, seeing the camera screen again unexpectedly.

Fix: Use context.go('/ocr-review') or context.pushReplacement() to replace the scan page.


