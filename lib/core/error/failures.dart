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

  /// A user-friendly error message suitable for UI display.
  /// Returns the message if it's already user-friendly,
  /// or provides a generic friendly message for technical errors.
  String get userMessage {
    // If message is already friendly (doesn't start with technical keywords),
    // return it as-is
    if (!message.startsWith('Failed to') &&
        !message.contains('Exception') &&
        !message.contains('Error') &&
        !message.contains('Cannot') &&
        message.length > 10) {
      return message;
    }

    // Provide friendly messages for common error types
    if (this is DatabaseFailure) {
      return 'Unable to access your library. Please check your data and try again.';
    } else if (this is FileSystemFailure) {
      return 'Unable to access files on your device. Please try again.';
    } else if (this is OCRFailure) {
      return 'Unable to process the image. Please try with a clearer photo.';
    } else if (this is SearchFailure) {
      return 'Unable to search right now. Please try again.';
    } else if (this is BackupFailure) {
      return 'Unable to complete backup. Please try again.';
    } else if (this is ValidationFailure) {
      return 'Please check your input and try again.';
    } else if (this is PermissionFailure) {
      return 'This app needs permission to continue. Please grant it in settings.';
    } else if (this is PlatformFailure) {
      return 'This feature is not available on your device.';
    } else if (this is SpeechRecognitionFailure) {
      return 'Unable to use voice input. Please try again.';
    } else if (this is NetworkFailure) {
      return 'Unable to connect. Please check your internet connection.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

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

/// Failure for speech recognition/dictation errors.
class SpeechRecognitionFailure extends Failure {
  SpeechRecognitionFailure({
    required super.message,
    super.code,
  });
}

/// Failure for network-related errors (connectivity, timeouts, etc.).
class NetworkFailure extends Failure {
  NetworkFailure({
    required super.message,
    super.code,
  });
}
