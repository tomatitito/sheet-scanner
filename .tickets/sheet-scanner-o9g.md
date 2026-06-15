---
id: sheet-scanner-o9g
status: closed
deps: []
links: []
created: 2025-12-13T09:49:49.692982+01:00
type: bug
priority: 1
---
# P1: Late final nullable anti-pattern in ScanCameraPage

_cameraController declared as 'late final CameraController?' (scan_camera_page.dart:27) is an anti-pattern. The 'late' modifier with nullable type means if camera initialization fails, any access will throw LateInitializationError instead of safely handling null.

Multiple forced unwraps (_cameraController!) at lines 67, 91, 140, 242 assume non-null but initialization can fail.

Should be either:
- CameraController? (nullable, no late) with null checks, OR
- late CameraController (non-nullable) with error boundary

File: lib/features/ocr/presentation/pages/scan_camera_page.dart:27


