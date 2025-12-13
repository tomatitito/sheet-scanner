import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:logging/logging.dart';
import 'package:path_provider/path_provider.dart';

/// Service for preprocessing images to improve OCR accuracy.
/// Applies techniques like grayscale conversion, contrast enhancement,
/// noise reduction, and binarization.
class ImagePreprocessingService {
  final _logger = Logger('ImagePreprocessingService');

  /// Preprocess an image for better OCR accuracy.
  /// Returns the path to the preprocessed image file.
  ///
  /// Processing steps:
  /// 1. Load and decode image
  /// 2. Convert to grayscale
  /// 3. Enhance contrast using adaptive histogram equalization
  /// 4. Apply bilateral filter for noise reduction while preserving edges
  /// 5. Apply adaptive thresholding (binarization) for better text detection
  /// 6. Save preprocessed image
  Future<String> preprocessImage(String originalImagePath) async {
    try {
      _logger.info('Starting image preprocessing: $originalImagePath');

      // Load the image
      final imageBytes = await File(originalImagePath).readAsBytes();
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        _logger.warning('Failed to decode image: $originalImagePath');
        return originalImagePath; // Return original if preprocessing fails
      }

      _logger.info(
        'Image loaded: ${image.width}x${image.height} pixels',
      );

      // Step 1: Convert to grayscale for better text detection
      image = img.grayscale(image);
      _logger.fine('Converted to grayscale');

      // Step 2: Enhance contrast to make text more readable
      // Using contrast adjustment with empirically determined factor
      image = img.adjustColor(
        image,
        contrast: 1.3, // Boost contrast by 30%
        brightness: 1.05, // Slight brightness increase
      );
      _logger.fine('Enhanced contrast and brightness');

      // Step 3: Apply adaptive thresholding (binarization)
      // This converts the image to black and white, making text stand out
      image = _applyAdaptiveThreshold(image);
      _logger.fine('Applied adaptive thresholding');

      // Step 4: Denoise while preserving edges
      // This helps remove artifacts without blurring text
      image = _applyBilateralFilter(image);
      _logger.fine('Applied bilateral filter for noise reduction');

      // Save the preprocessed image
      final preprocessedPath = await _savePreprocessedImage(image);
      _logger.info('Preprocessing complete: $preprocessedPath');

      return preprocessedPath;
    } catch (e) {
      _logger.severe('Error during image preprocessing: $e');
      // Return original image path if preprocessing fails
      return originalImagePath;
    }
  }

  /// Apply adaptive thresholding to convert image to binary (black & white).
  /// This technique works better than global thresholding for images with
  /// varying lighting conditions.
  img.Image _applyAdaptiveThreshold(img.Image image) {
    final width = image.width;
    final height = image.height;
    final result = img.Image(width: width, height: height);

    // Window size for local threshold calculation (should be odd)
    const windowSize = 15;
    const offset = windowSize ~/ 2;

    // Parameter C: constant subtracted from mean (reduces noise sensitivity)
    const c = 10;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        // Calculate local mean in the window around this pixel
        int sum = 0;
        int count = 0;

        for (int wy = -offset; wy <= offset; wy++) {
          for (int wx = -offset; wx <= offset; wx++) {
            final px = x + wx;
            final py = y + wy;

            if (px >= 0 && px < width && py >= 0 && py < height) {
              final pixel = image.getPixel(px, py);
              sum += pixel.r.toInt(); // Grayscale, so r=g=b
              count++;
            }
          }
        }

        final localMean = sum / count;
        final currentPixel = image.getPixel(x, y);
        final pixelValue = currentPixel.r.toInt();

        // Apply threshold: if pixel is darker than local mean - C, make it black
        final binary = pixelValue > (localMean - c) ? 255 : 0;

        result.setPixelRgba(x, y, binary, binary, binary, 255);
      }
    }

    return result;
  }

  /// Apply bilateral filter for noise reduction while preserving edges.
  /// This is important to reduce image artifacts without making text blurry.
  img.Image _applyBilateralFilter(img.Image image) {
    // For performance, we'll use a simplified edge-preserving smoothing
    // Full bilateral filter is computationally expensive
    // Using a median filter approximation instead

    final width = image.width;
    final height = image.height;
    final result = img.Image(width: width, height: height);

    const kernelSize = 3;
    const offset = kernelSize ~/ 2;

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final values = <int>[];

        // Collect neighborhood values
        for (int ky = -offset; ky <= offset; ky++) {
          for (int kx = -offset; kx <= offset; kx++) {
            final px = x + kx;
            final py = y + ky;

            if (px >= 0 && px < width && py >= 0 && py < height) {
              final pixel = image.getPixel(px, py);
              values.add(pixel.r.toInt());
            }
          }
        }

        // Use median value (edge-preserving)
        values.sort();
        final median = values[values.length ~/ 2];

        result.setPixelRgba(x, y, median, median, median, 255);
      }
    }

    return result;
  }

  /// Save the preprocessed image to a temporary file.
  Future<String> _savePreprocessedImage(img.Image image) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filePath = '${tempDir.path}/preprocessed_$timestamp.jpg';

    // Encode as JPEG with high quality
    final bytes = img.encodeJpg(image, quality: 95);
    await File(filePath).writeAsBytes(bytes);

    return filePath;
  }

  /// Batch preprocess multiple images.
  Future<List<String>> preprocessImageBatch(List<String> imagePaths) async {
    final preprocessedPaths = <String>[];

    for (final imagePath in imagePaths) {
      final preprocessedPath = await preprocessImage(imagePath);
      preprocessedPaths.add(preprocessedPath);
    }

    return preprocessedPaths;
  }

  /// Clean up temporary preprocessed images.
  Future<void> cleanupTempFiles(List<String> filePaths) async {
    for (final path in filePaths) {
      if (path.contains('preprocessed_')) {
        try {
          await File(path).delete();
          _logger.fine('Deleted temp file: $path');
        } catch (e) {
          _logger.warning('Failed to delete temp file $path: $e');
        }
      }
    }
  }
}
