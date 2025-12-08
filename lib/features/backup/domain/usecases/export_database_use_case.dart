import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/backup/domain/repositories/backup_repository.dart';

/// Use case for exporting the database.
/// Handles database export operations with optional custom path.
class ExportDatabaseUseCase {
  final BackupRepository repository;

  ExportDatabaseUseCase({required this.repository});

  /// Exports the database to a file.
  /// Optionally saves to [customPath] instead of default export directory.
  /// Returns information about the exported file.
  Future<Either<Failure, ExportResult>> call({String? customPath}) {
    return repository.exportDatabase(customPath: customPath);
  }
}
