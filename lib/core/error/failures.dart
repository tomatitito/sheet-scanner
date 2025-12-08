/// Abstract base failure class for all error handling in the application.
///
/// Uses the [Either] type pattern to represent failures instead of exceptions.
/// All repositories and use cases should return [Either<Failure, Success>] to
/// handle errors explicitly and safely.
abstract class Failure implements Exception {
  /// A human-readable error message.
  final String message;

  /// Optional error code for error classification and handling.
  final String? code;

  Failure({
    required this.message,
    this.code,
  });

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (code: $code)' : ''}';
}

/// Generic failure for unexpected errors.
class GenericFailure extends Failure {
  GenericFailure({
    required super.message,
    super.code,
  });
}

/// Failure for database-related errors.
class DatabaseFailure extends Failure {
  DatabaseFailure({
    required super.message,
    super.code,
  });
}

/// Failure for file system operations.
class FileSystemFailure extends Failure {
  FileSystemFailure({
    required super.message,
    super.code,
  });
}

/// Failure for OCR-specific errors.
class OCRFailure extends Failure {
  OCRFailure({
    required super.message,
    super.code,
  });
}

/// Failure for search/query errors.
class SearchFailure extends Failure {
  SearchFailure({
    required super.message,
    super.code,
  });
}

/// Failure for backup/export/import operations.
class BackupFailure extends Failure {
  BackupFailure({
    required super.message,
    super.code,
  });
}

/// Failure for validation errors.
class ValidationFailure extends Failure {
  ValidationFailure({
    required super.message,
    super.code,
  });
}

/// Failure for permission-related errors.
class PermissionFailure extends Failure {
  PermissionFailure({
    required super.message,
    super.code,
  });
}

/// Failure for platform-specific errors (OS detection, platform unavailable).
class PlatformFailure extends Failure {
  PlatformFailure({
    required super.message,
    super.code,
  });
}
