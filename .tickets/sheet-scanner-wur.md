---
id: sheet-scanner-wur
status: closed
deps: []
links: []
created: 2025-12-13T09:50:29.19616+01:00
type: bug
priority: 0
---
# Critical: OCRScanCubit created but never disposed causing memory leak

In lib/features/ocr/presentation/pages/scan_camera_page.dart:43, OCRScanCubit is created via getIt<OCRScanCubit>() but never disposed when the widget is disposed (line 183-187).

Since Cubits are registered as singletons (separate issue), this is even worse - the cubit persists forever and accumulates state.

Impact: Memory leak, event stream subscriptions not canceled, potential crashes.

Fix: Add cubit disposal in dispose():
@override
void dispose() {
  WidgetsBinding.instance.removeObserver(this);
  _cameraController?.dispose();
  _ocrScanCubit.close(); // Add this
  super.dispose();
}


