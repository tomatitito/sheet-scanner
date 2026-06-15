---
id: sheet-scanner-ned
status: closed
deps: []
links: []
created: 2025-12-13T09:50:28.505152+01:00
type: bug
priority: 1
---
# P1: OCR review 'Change Image' button does nothing

In OCRReviewPage desktop layout, there's a 'Change Image' button at line 591 with an empty onPressed handler:

```dart
OutlinedButton(
  onPressed: isSubmitting ? null : () {},  // Empty handler!
  child: const Text('Change Image'),
),
```

The button is visible and clickable but does nothing when clicked. This is misleading to users.

Expected behavior: Button should either:
1. Allow user to pick a new image from file picker/camera
2. Navigate back to scan page  
3. Be removed if functionality isn't implemented yet

Actual: Button does nothing, poor UX

File: lib/features/sheet_music/presentation/pages/ocr_review_page.dart:591
Impact: Confusing UI, button appears broken


