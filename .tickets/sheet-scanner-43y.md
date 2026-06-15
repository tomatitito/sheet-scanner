---
id: sheet-scanner-43y
status: closed
deps: []
links: []
created: 2025-12-13T09:49:50.120926+01:00
type: bug
priority: 1
---
# P1: Unnecessary navigation stack growth in OCR flow

ScanCameraPage navigates to '/ocr-review' (line 217) without popping itself first. This creates navigation stack: AddSheetPage -> ScanCameraPage -> OCRReviewPage.

When user saves in OCR review and pops, they go back to ScanCameraPage (which shows camera preview), not AddSheetPage.

Should either:
1. Pop scan page before pushing review: context.go('/ocr-review'), OR
2. Pop scan page when navigating: context.pop(); context.push('/ocr-review')

This compounds the navigation bug in sheet-scanner-XXX (OCR-to-add flow).

File: lib/features/ocr/presentation/pages/scan_camera_page.dart:217


