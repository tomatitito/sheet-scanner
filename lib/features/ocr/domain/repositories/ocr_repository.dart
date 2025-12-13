import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';

part 'ocr_repository.freezed.dart';

/// Result of OCR text recognition
@freezed
class OCRResult with _$OCRResult {
  const factory OCRResult({
    required String text,
    required double confidence,
  }) = _OCRResult;
}

/// Repository interface for OCR (Optical Character Recognition) operations.
abstract class OCRRepository {
  /// Performs text recognition on an image.
  /// [imagePath] is the file system path to the image file
  /// Returns extracted text with confidence score.
  Future<Either<Failure, OCRResult>> recognizeText(String imagePath);

  /// Processes multiple images and returns combined text.
  /// [imagePaths] are file system paths to the image files
  Future<Either<Failure, List<OCRResult>>> recognizeTextBatch(
    List<String> imagePaths,
  );

  /// Checks if OCR is available on the current platform.
  Future<Either<Failure, bool>> isOCRAvailable();
}
