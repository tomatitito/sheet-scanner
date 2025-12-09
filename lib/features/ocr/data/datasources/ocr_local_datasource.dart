import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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
class OCRLocalDataSourceImpl implements OCRLocalDataSource {
  late final TextRecognizer _textRecognizer;

  OCRLocalDataSourceImpl() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  }

  @override
  Future<(String text, double confidence)> recognizeText(
    String imagePath,
  ) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Calculate confidence based on text blocks
      // ML Kit doesn't provide direct confidence, so we use block count as proxy
      double confidence = 1.0;
      if (recognizedText.blocks.isEmpty) {
        confidence = 0.0;
      } else {
        // Average confidence based on number of blocks detected
        // More blocks = more reliable detection
        final blockCount = recognizedText.blocks.length;
        confidence = (blockCount / (blockCount + 5)).clamp(0.0, 1.0);
      }

      return (recognizedText.text, confidence);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<(String text, double confidence)>> recognizeTextBatch(
    List<String> imagePaths,
  ) async {
    try {
      final results = <(String, double)>[];
      for (final imagePath in imagePaths) {
        final result = await recognizeText(imagePath);
        results.add(result);
      }
      return results;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<bool> isOCRAvailable() async {
    // ML Kit is available on both iOS and Android
    // Desktop platforms can use Tesseract (future implementation)
    return true;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
