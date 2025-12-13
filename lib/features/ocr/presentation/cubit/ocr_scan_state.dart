import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sheet_scanner/core/error/failures.dart';

part 'ocr_scan_state.freezed.dart';

/// States for the OCR scanning workflow
@freezed
class OCRScanState with _$OCRScanState {
  /// Initial state - camera not yet initialized
  const factory OCRScanState.initial() = _Initial;

  /// Camera is ready for capture
  const factory OCRScanState.cameraReady() = _CameraReady;

  /// Capturing image from camera
  const factory OCRScanState.capturing() = _Capturing;

  /// Image captured, processing OCR
  const factory OCRScanState.processing({
    required String imagePath,
    required double progress,
    String? currentOperation,
  }) = _Processing;

  /// OCR processing complete, results ready for review
  const factory OCRScanState.ocrComplete({
    required String imagePath,
    required String extractedText,
    required double confidence,
  }) = _OCRComplete;

  /// Error occurred during scanning or OCR
  const factory OCRScanState.error({
    required Failure failure,
    String? imagePath,
  }) = _Error;

  /// Camera permission denied
  const factory OCRScanState.permissionDenied() = _PermissionDenied;
}
