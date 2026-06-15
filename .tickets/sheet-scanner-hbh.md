---
id: sheet-scanner-hbh
status: closed
deps: []
links: []
created: 2025-12-13T09:52:09.563656+01:00
type: bug
priority: 2
---
# OCR text parsing logic is overly simplistic and fragile

In lib/features/ocr/presentation/pages/scan_camera_page.dart:207-214, OCR results are parsed using a naive approach:

final lines = extractedText.split('\n').where((line) => line.trim().isNotEmpty).toList();
final detectedTitle = lines.isNotEmpty ? lines.first : '';
final detectedComposer = lines.length > 1 ? lines[1] : '';

This assumes:
1. Title is always the first non-empty line
2. Composer is always the second non-empty line
3. No other metadata or formatting

Real sheet music covers have varied layouts, multiple text blocks, and different arrangements. This simple parsing will often extract the wrong text.

Impact: Poor OCR accuracy, users must manually fix most scans.

Fix: Implement smarter text parsing:
- Look for common keywords (Composer:, By:, etc.)
- Use text size/position heuristics if available from OCR engine
- Allow users to select which text is title vs composer


