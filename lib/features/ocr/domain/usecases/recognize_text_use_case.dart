import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/ocr/domain/repositories/ocr_repository.dart';

/// Use case for performing OCR text recognition on an image.
/// Validates input and delegates to repository.
class RecognizeTextUseCase {
  final OCRRepository repository;

  RecognizeTextUseCase({required this.repository});

  /// Performs text recognition on the image at [imagePath].
  /// Returns extracted text with confidence score.
  /// [imagePath] must be a valid file system path to an image file.
  Future<Either<Failure, OCRResult>> call(String imagePath) {
    if (imagePath.trim().isEmpty) {
      return Future.value(
        Left(ValidationFailure(message: 'Image path cannot be empty')),
      );
    }
    return repository.recognizeText(imagePath);
  }
}
