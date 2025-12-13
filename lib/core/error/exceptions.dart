/// Core exception types for error handling at the data layer.
///
/// Data sources throw exceptions which are caught and converted to
/// Failures by repositories. This keeps domain layer pure.
abstract class CustomException implements Exception {
  final String message;

  CustomException({required this.message});

  @override
  String toString() => message;
}

/// Exception for database errors.
class DatabaseException extends CustomException {
  DatabaseException({required super.message});
}

/// Exception for file system errors.
class FileSystemException extends CustomException {
  FileSystemException({required super.message});
}

/// Exception for invalid input.
class ValidationException extends CustomException {
  ValidationException({required super.message});
}

/// Exception for OCR processing errors.
class OCRException extends CustomException {
  OCRException({required super.message});
}

/// Exception for cache operations.
class CacheException extends CustomException {
  CacheException({required super.message});
}
