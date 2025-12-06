import 'dart:io';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';

/// Result of an export operation
class ExportResult {
  final File file;
  final String format;
  final int itemCount;

  ExportResult({
    required this.file,
    required this.format,
    required this.itemCount,
  });
}

/// Result of an import operation
class ImportResult {
  final int totalProcessed;
  final int imported;
  final int skipped;
  final int failed;

  ImportResult({
    required this.totalProcessed,
    required this.imported,
    required this.skipped,
    required this.failed,
  });
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
  Future<Either<Failure, ImportResult>> importFromBackup({
    required File backupFile,
    ImportMode mode = ImportMode.merge,
  });

  /// Replaces the entire database with another.
  Future<Either<Failure, void>> replaceDatabase(File dbFile);

  /// Opens a backup database for reading.
  Future<dynamic> openDatabase(String path);

  /// Gets the size of the current database.
  Future<Either<Failure, int>> getDatabaseSize();

  /// Gets available disk space.
  Future<Either<Failure, int>> getAvailableDiskSpace();
}
