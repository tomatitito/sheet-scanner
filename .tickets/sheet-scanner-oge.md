---
id: sheet-scanner-oge
status: closed
deps: []
links: []
created: 2025-12-13T09:50:58.494286+01:00
type: bug
priority: 1
---
# No camera permission check before initialization

In lib/features/ocr/presentation/pages/scan_camera_page.dart:48-83, the camera is initialized without checking or requesting permissions first. The code imports permission_handler (line 10) but never uses it.

The permission check only happens after a failure via _ocrScanCubit.onPermissionDenied() (line 231), which is reactive rather than proactive.

Impact: Poor UX - camera initialization fails, then shows permission dialog. Should request permission first.

Fix: Add permission check at start of _initializeCamera():
final status = await Permission.camera.status;
if (!status.isGranted) {
  final result = await Permission.camera.request();
  if (!result.isGranted) {
    _ocrScanCubit.onPermissionDenied();
    return;
  }
}


