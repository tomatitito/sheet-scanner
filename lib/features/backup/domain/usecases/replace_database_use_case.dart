import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/backup/domain/repositories/backup_repository.dart';

/// Use case for replacing the entire database with a backup.
/// Creates an automatic backup of the current database before replacing.
class ReplaceDatabaseUseCase {
  final BackupRepository repository;

  ReplaceDatabaseUseCase({required this.repository});

  /// Replaces the current database with a backup database.
  /// [dbFilePath] is the file system path to the backup database file.
  /// The current database is automatically backed up before replacement.
  /// Returns success or failure.
  Future<Either<Failure, void>> call({required String dbFilePath}) {
    return repository.replaceDatabase(dbFilePath);
  }
}
