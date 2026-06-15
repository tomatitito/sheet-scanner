---
id: sheet-scanner-l35
status: closed
deps: []
links: []
created: 2025-12-13T09:52:01.88104+01:00
type: bug
priority: 2
---
# P2: Missing mounted check after async setFlashMode in ScanCameraPage

In ScanCameraPage._toggleFlash() method (lines 135-148), after calling the async operation:

await _cameraController!.setFlashMode(newFlashMode);

The code immediately calls setState() without checking if the widget is still mounted:

setState(() {
  _flashEnabled = !_flashEnabled;
});

Problem: If the user navigates away while the flash mode is being set (async operation), the widget could be disposed before setState() is called, causing a 'setState() called after dispose()' error.

Fix: Add mounted check before setState:
```dart
await _cameraController!.setFlashMode(newFlashMode);
if (!mounted) return;
setState(() {
  _flashEnabled = !_flashEnabled;
});
```

File: lib/features/ocr/presentation/pages/scan_camera_page.dart:135-148
Impact: Potential runtime error when rapidly navigating away from scan page


