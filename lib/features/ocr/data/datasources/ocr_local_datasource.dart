import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:logging/logging.dart';
import 'package:sheet_scanner/features/ocr/data/services/image_preprocessing_service.dart';

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
/// Includes image preprocessing pipeline for improved OCR accuracy.
class OCRLocalDataSourceImpl implements OCRLocalDataSource {
  late final TextRecognizer _textRecognizer;
  late final ImagePreprocessingService _preprocessingService;
  final _logger = Logger('OCRLocalDataSourceImpl');

  OCRLocalDataSourceImpl() {
    _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    _preprocessingService = ImagePreprocessingService();
  }

  @override
  Future<(String text, double confidence)> recognizeText(
    String imagePath,
  ) async {
    String? preprocessedPath;
    try {
      _logger.info('Starting OCR for: $imagePath');

      // Preprocess the image for better OCR accuracy
      preprocessedPath = await _preprocessingService.preprocessImage(imagePath);
      _logger.info('Image preprocessed: $preprocessedPath');

      // Process the preprocessed image with ML Kit
      final inputImage = InputImage.fromFilePath(preprocessedPath);
      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Calculate weighted average of element-level confidence scores from ML Kit
      // ML Kit provides confidence scores for each text element since v0.7.0
      double totalConfidence = 0.0;
      int elementCount = 0;

      for (final block in recognizedText.blocks) {
        for (final line in block.lines) {
          for (final element in line.elements) {
            // TextElement has a confidence property (0.0 to 1.0)
            // Handle null confidence values (fallback to 0.0)
            final elementConfidence = element.confidence ?? 0.0;
            totalConfidence += elementConfidence;
            elementCount++;
          }
        }
      }

      // Calculate average confidence; default to 0.0 if no elements found
      final confidence = elementCount > 0
          ? (totalConfidence / elementCount).clamp(0.0, 1.0)
          : 0.0;

      _logger.info(
        'OCR complete: ${recognizedText.text.length} chars, '
        'confidence: ${(confidence * 100).toStringAsFixed(1)}%',
      );

      return (recognizedText.text, confidence);
    } catch (e) {
      _logger.severe('OCR failed: $e');
      rethrow;
    } finally {
      // Clean up preprocessed temporary file
      if (preprocessedPath != null && preprocessedPath != imagePath) {
        await _preprocessingService.cleanupTempFiles([preprocessedPath]);
      }
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
