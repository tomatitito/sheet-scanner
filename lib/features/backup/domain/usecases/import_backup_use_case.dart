import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/backup/domain/repositories/backup_repository.dart';

/// Use case for importing sheet music from a backup file.
/// Supports merging or replacing existing data.
class ImportBackupUseCase {
  final BackupRepository repository;

  ImportBackupUseCase({required this.repository});

  /// Imports sheet music from a backup file.
  /// [backupFilePath] is the file system path to the backup file.
  /// [mode] determines how to handle existing data (merge, replace, or update).
  /// Returns information about the import operation.
  Future<Either<Failure, ImportResult>> call({
    required String backupFilePath,
    ImportMode mode = ImportMode.merge,
  }) {
    return repository.importFromBackup(
      backupFilePath: backupFilePath,
      mode: mode,
    );
  }
}
