---
id: sheet-scanner-z86
status: closed
deps: []
links: []
created: 2025-12-13T09:50:59.570133+01:00
type: bug
priority: 1
---
# Lifecycle handler accesses nullable camera controller without null check

In lib/features/ocr/presentation/pages/scan_camera_page.dart:165-180, didChangeAppLifecycleState() checks _isCameraInitialized but doesn't verify _cameraController is non-null before calling methods on it (lines 170, 172, 178).

If camera initialization failed but _isCameraInitialized was set to true, or if there's a race condition, this could cause a null pointer exception.

Impact: Potential crash when app goes to background/foreground.

Fix: Change to _cameraController?.resumePreview() (optional chaining) or add explicit null checks.


