---
id: sheet-scanner-kk5
status: closed
deps: []
links: []
created: 2025-12-13T09:49:49.899026+01:00
type: bug
priority: 1
---
# P1: OCRScanCubit not disposed in ScanCameraPage

ScanCameraPage creates OCRScanCubit directly with getIt<> (line 43) but never calls close() in dispose() method (line 183-186). This creates a memory leak as the cubit's streams and subscriptions won't be cleaned up.

When using getIt<> to create a cubit outside of BlocProvider, must manually call cubit.close() in dispose().

File: lib/features/ocr/presentation/pages/scan_camera_page.dart:28,183


