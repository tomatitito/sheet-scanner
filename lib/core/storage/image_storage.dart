import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sheet_scanner/core/error/exceptions.dart';

/// Manages local file storage for sheet music images.
/// Provides methods for saving, loading, and cleaning up images.
/// Images are automatically compressed before storage.
class ImageStorage {
  static const String _imagesDirName = 'sheet_music_images';

  /// Initialize the images directory.
  /// Called during app startup to ensure storage is ready.
  static Future<void> initialize() async {
    try {
      await _getImagesDirectory();
    } catch (e) {
      throw FileSystemException(
          message: 'Failed to initialize image storage: $e');
    }
  }

  /// Get the images directory, creating it if it doesn't exist.
  static Future<Directory> _getImagesDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory(p.join(appDir.path, _imagesDirName));

    if (!await imagesDir.exists()) {
      await imagesDir.create(recursive: true);
    }

    return imagesDir;
  }

  /// Compress an image to a reasonable size for storage.
  /// Reduces dimensions to max 1920x1080 and compresses JPEG to 85% quality.
  static Future<File> _compressImage(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        // If decoding fails, return original file
        return imageFile;
      }

      // Resize if larger than 1920x1080 (maintaining aspect ratio)
      img.Image processedImage = image;
      if (image.width > 1920 || image.height > 1080) {
        processedImage = img.copyResize(
          image,
          width: image.width > 1920 ? 1920 : null,
          height: image.height > 1080 ? 1080 : null,
          interpolation: img.Interpolation.linear,
        );
      }

      // Encode as JPEG with 85% quality
      final compressedBytes = img.encodeJpg(processedImage, quality: 85);

      // Write compressed image back to a temp file
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(
        p.join(tempDir.path,
            'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg'),
      );
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      // If compression fails, return original file
      return imageFile;
    }
  }

  /// Save an image file to storage.
  /// Automatically compresses the image before saving.
  /// Returns the full path where the image was saved.
  static Future<String> saveImage({
    required File imageFile,
    required int sheetMusicId,
    required int imageIndex,
  }) async {
    try {
      final imagesDir = await _getImagesDirectory();
      final fileName =
          '${sheetMusicId}_${imageIndex}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savePath = p.join(imagesDir.path, fileName);

      // Compress the image before saving
      final compressedFile = await _compressImage(imageFile);
      await compressedFile.copy(savePath);

      // Clean up the compressed temp file if it's different from original
      if (compressedFile.path != imageFile.path) {
        try {
          await compressedFile.delete();
        } catch (_) {
          // Ignore cleanup errors
        }
      }

      return savePath;
    } catch (e) {
      throw FileSystemException(
        message: 'Failed to save image: $e',
      );
    }
  }

  /// Load an image file from storage.
  static Future<File> loadImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        throw FileSystemException(message: 'Image not found: $imagePath');
      }
      return file;
    } catch (e) {
      throw FileSystemException(
        message: 'Failed to load image: $e',
      );
    }
  }

  /// Delete a specific image file.
  static Future<void> deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileSystemException(
        message: 'Failed to delete image: $e',
      );
    }
  }

  /// Delete all images for a specific sheet music entry.
  static Future<void> deleteSheetMusicImages(int sheetMusicId) async {
    try {
      final imagesDir = await _getImagesDirectory();
      final files = imagesDir.listSync();

      for (final file in files) {
        if (file is File && file.path.contains('${sheetMusicId}_')) {
          await file.delete();
        }
      }
    } catch (e) {
      throw FileSystemException(
        message: 'Failed to delete sheet images: $e',
      );
    }
  }

  /// Clear all images from storage.
  static Future<void> clearAll() async {
    try {
      final imagesDir = await _getImagesDirectory();
      if (await imagesDir.exists()) {
        await imagesDir.delete(recursive: true);
        await imagesDir.create(recursive: true);
      }
    } catch (e) {
      throw FileSystemException(
        message: 'Failed to clear image storage: $e',
      );
    }
  }

  /// Get total size of all images in bytes.
  static Future<int> getTotalSize() async {
    try {
      final imagesDir = await _getImagesDirectory();
      final files = imagesDir.listSync(recursive: true);
      int totalSize = 0;

      for (final file in files) {
        if (file is File) {
          totalSize += await file.length();
        }
      }

      return totalSize;
    } catch (e) {
      throw FileSystemException(
        message: 'Failed to calculate storage size: $e',
      );
    }
  }

  /// Get the directory path for images.
  static Future<String> getStoragePath() async {
    final dir = await _getImagesDirectory();
    return dir.path;
  }
}
