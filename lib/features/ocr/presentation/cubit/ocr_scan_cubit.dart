import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/features/ocr/domain/usecases/recognize_text_use_case.dart';

import 'ocr_scan_state.dart';

/// Cubit managing the OCR scanning workflow
/// Handles: camera capture → image processing → OCR recognition
class OCRScanCubit extends Cubit<OCRScanState> {
  final RecognizeTextUseCase recognizeTextUseCase;

  final _logger = Logger('OCRScanCubit');

  OCRScanCubit({required this.recognizeTextUseCase})
      : super(const OCRScanState.initial());

  /// Initialize camera and prepare for scanning
  Future<void> initializeCamera() async {
    try {
      _logger.info('Initializing camera for OCR scanning');
      emit(const OCRScanState.cameraReady());
    } catch (e) {
      _logger.severe('Failed to initialize camera: $e');
      emit(OCRScanState.error(
        failure: PlatformFailure(message: 'Failed to initialize camera: $e'),
      ));
    }
  }

  /// Capture image from camera and process with OCR
  Future<void> captureAndProcess(String imagePath) async {
    if (imagePath.isEmpty) {
      _logger.warning('Empty image path provided');
      emit(OCRScanState.error(
        failure: ValidationFailure(message: 'Invalid image path'),
      ));
      return;
    }

    // Verify file exists
    if (!await File(imagePath).exists()) {
      _logger.warning('Image file does not exist: $imagePath');
      emit(OCRScanState.error(
        failure: ValidationFailure(message: 'Image file not found'),
        imagePath: imagePath,
      ));
      return;
    }

    try {
      _logger.info('Starting capture with path: $imagePath');
      emit(const OCRScanState.capturing());

      // Process OCR
      await processOCR(imagePath);
    } catch (e) {
      _logger.severe('Error during capture and process: $e');
      emit(OCRScanState.error(
        failure: OCRFailure(message: 'Failed to capture: $e'),
        imagePath: imagePath,
      ));
    }
  }

  /// Process image with OCR
  Future<void> processOCR(String imagePath) async {
    try {
      _logger.info('Starting OCR processing for: $imagePath');
      emit(OCRScanState.processing(
        imagePath: imagePath,
        progress: 0.3,
        currentOperation: 'Initializing text recognition...',
      ));

      // Call the use case to recognize text
      final result = await recognizeTextUseCase(imagePath);

      result.fold(
        (failure) {
          _logger.warning('OCR recognition failed: ${failure.message}');
          emit(OCRScanState.error(
            failure: failure,
            imagePath: imagePath,
          ));
        },
        (ocrResult) {
          _logger.info(
            'OCR processing complete. '
            'Text length: ${ocrResult.text.length}, '
            'Confidence: ${ocrResult.confidence}',
          );
          emit(OCRScanState.ocrComplete(
            imagePath: imagePath,
            extractedText: ocrResult.text,
            confidence: ocrResult.confidence,
          ));
        },
      );
    } catch (e) {
      _logger.severe('Unexpected error during OCR processing: $e');
      emit(OCRScanState.error(
        failure: OCRFailure(message: 'OCR processing failed: $e'),
        imagePath: imagePath,
      ));
    }
  }

  /// Retry OCR processing after failure
  Future<void> retryOCR(String imagePath) async {
    _logger.info('Retrying OCR for: $imagePath');
    await processOCR(imagePath);
  }

  /// Handle camera permission denied
  void onPermissionDenied() {
    _logger.warning('Camera permission denied');
    emit(const OCRScanState.permissionDenied());
  }

  /// Reset to initial state
  void reset() {
    _logger.info('Resetting OCR scan state');
    emit(const OCRScanState.initial());
  }

  @override
  Future<void> close() async {
    _logger.info('Closing OCRScanCubit');
    return super.close();
  }
}
