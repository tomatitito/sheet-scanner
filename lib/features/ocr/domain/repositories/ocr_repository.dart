import 'dart:io';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';

/// Result of OCR text recognition
class OCRResult {
  final String text;
  final double confidence;

  OCRResult({
    required this.text,
    required this.confidence,
  });
}

/// Repository interface for OCR (Optical Character Recognition) operations.
abstract class OCRRepository {
  /// Performs text recognition on an image.
  /// Returns extracted text with confidence score.
  Future<Either<Failure, OCRResult>> recognizeText(File imageFile);

  /// Processes multiple images and returns combined text.
  Future<Either<Failure, List<OCRResult>>> recognizeTextBatch(
    List<File> imageFiles,
  );

  /// Checks if OCR is available on the current platform.
  Future<Either<Failure, bool>> isOCRAvailable();
}
