import 'package:file_picker/file_picker.dart';

/// Service for handling file selection with cross-platform support.
/// Supports both mobile (image picker) and desktop (file picker) workflows.
abstract class FilePickerService {
  /// Pick an image file from device storage or camera.
  /// Returns the file path if successful, null if cancelled.
  Future<String?> pickImage();

  /// Pick multiple image files.
  Future<List<String>> pickMultipleImages();

  /// Pick any file with optional type filtering.
  Future<String?> pickFile({
    List<String>? allowedExtensions,
  });

  /// Pick multiple files.
  Future<List<String>> pickMultipleFiles({
    List<String>? allowedExtensions,
  });

  /// Check if device supports camera.
  Future<bool> hasCameraSupport();
}

/// Implementation using file_picker and image_picker packages.
class FilePickerServiceImpl implements FilePickerService {
  @override
  Future<String?> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    return result?.files.first.path;
  }

  @override
  Future<List<String>> pickMultipleImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    return result?.files.map((e) => e.path ?? '').toList() ?? [];
  }

  @override
  Future<String?> pickFile({
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: false,
    );

    return result?.files.first.path;
  }

  @override
  Future<List<String>> pickMultipleFiles({
    List<String>? allowedExtensions,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: allowedExtensions != null ? FileType.custom : FileType.any,
      allowedExtensions: allowedExtensions,
      allowMultiple: true,
    );

    return result?.files
            .map((e) => e.path ?? '')
            .where((p) => p.isNotEmpty)
            .toList() ??
        [];
  }

  @override
  Future<bool> hasCameraSupport() async {
    // For now, assume camera is available on mobile platforms
    // TODO: Implement actual camera capability check
    return true;
  }
}
