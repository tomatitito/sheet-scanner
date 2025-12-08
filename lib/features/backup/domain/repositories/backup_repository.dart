import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';

part 'backup_repository.freezed.dart';

/// Result of an export operation
@freezed
class ExportResult with _$ExportResult {
  const factory ExportResult({
    /// Path to the exported file
    required String filePath,

    /// Format of the export (json, zip, db)
    required String format,

    /// Number of items exported
    required int itemCount,
  }) = _ExportResult;
}

/// Result of an import operation
@freezed
class ImportResult with _$ImportResult {
  const factory ImportResult({
    /// Total number of items processed
    required int totalProcessed,

    /// Number successfully imported
    required int imported,

    /// Number skipped due to duplicates or validation
    required int skipped,

    /// Number failed to import
    required int failed,
  }) = _ImportResult;
}

/// Import mode for backup operations
enum ImportMode { merge, replace, update }

/// Repository interface for backup/export/import operations.
abstract class BackupRepository {
  /// Exports sheet music to JSON format (metadata only).
  Future<Either<Failure, ExportResult>> exportToJSON({
    bool includeImages,
  });

  /// Exports sheet music to ZIP format (with images).
  Future<Either<Failure, ExportResult>> exportToZIP({
    String? customPath,
  });

  /// Exports raw database file.
  Future<Either<Failure, ExportResult>> exportDatabase({
    String? customPath,
  });

  /// Imports sheet music from backup file.
  /// [backupFilePath] is the file system path to the backup file
  Future<Either<Failure, ImportResult>> importFromBackup({
    required String backupFilePath,
    ImportMode mode = ImportMode.merge,
  });

  /// Replaces the entire database with another.
  /// [dbFilePath] is the file system path to the database file
  Future<Either<Failure, void>> replaceDatabase(String dbFilePath);

  /// Opens a backup database for reading.
  /// [path] is the file system path to the backup database
  Future<dynamic> openDatabase(String path);

  /// Gets the size of the current database in bytes.
  Future<Either<Failure, int>> getDatabaseSize();

  /// Gets available disk space in bytes.
  Future<Either<Failure, int>> getAvailableDiskSpace();
}
