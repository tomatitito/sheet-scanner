import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sheet_scanner/core/error/exceptions.dart';

/// Manages local file storage for sheet music images.
/// Provides methods for saving, loading, and cleaning up images.
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

  /// Save an image file to storage.
  /// Returns the relative path where the image was saved.
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

      await imageFile.copy(savePath);
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
