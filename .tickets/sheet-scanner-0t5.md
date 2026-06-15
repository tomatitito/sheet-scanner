---
id: sheet-scanner-0t5
status: closed
deps: []
links: []
created: 2025-12-13T09:50:28.03811+01:00
type: bug
priority: 0
---
# Critical: Camera controller declared as 'late final CameraController?' violates Dart semantics

In lib/features/ocr/presentation/pages/scan_camera_page.dart:27, _cameraController is declared as:
late final CameraController? _cameraController;

This is semantically incorrect:
- 'late final' means it MUST be assigned before use and cannot be null
- '?' makes it nullable
- But if cameras are empty (line 52-57), the variable is never assigned, violating the late contract

Impact: Potential runtime errors when accessing _cameraController, undefined behavior.

Fix: Remove 'final' keyword: late CameraController? _cameraController;
Or properly initialize in all paths.


