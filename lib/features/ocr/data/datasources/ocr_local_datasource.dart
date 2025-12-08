/// Abstract interface for OCR data source.
abstract class OCRLocalDataSource {
  /// Performs text recognition on an image file.
  /// Returns the raw text and confidence score.
  /// [imagePath] is the file system path to the image
  Future<(String text, double confidence)> recognizeText(String imagePath);

  /// Performs text recognition on multiple images.
  /// [imagePaths] are file system paths to image files
  Future<List<(String text, double confidence)>> recognizeTextBatch(
    List<String> imagePaths,
  );

  /// Checks if OCR is available on the current platform.
  Future<bool> isOCRAvailable();
}

/// Implementation of OCRLocalDataSource using Google ML Kit.
/// TODO: Implement with google_mlkit_text_recognition package.
class OCRLocalDataSourceImpl implements OCRLocalDataSource {
  @override
  Future<(String text, double confidence)> recognizeText(
    String imagePath,
  ) {
    throw UnimplementedError('recognizeText not yet implemented');
  }

  @override
  Future<List<(String text, double confidence)>> recognizeTextBatch(
    List<String> imagePaths,
  ) {
    throw UnimplementedError('recognizeTextBatch not yet implemented');
  }

  @override
  Future<bool> isOCRAvailable() {
    throw UnimplementedError('isOCRAvailable not yet implemented');
  }
}
