import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/backup/data/datasources/backup_local_datasource.dart';
import 'package:sheet_scanner/features/backup/domain/repositories/backup_repository.dart';

/// Implementation of BackupRepository using local file system operations.
class BackupRepositoryImpl implements BackupRepository {
  final BackupLocalDataSource localDataSource;

  BackupRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, ExportResult>> exportDatabase({
    String? customPath,
  }) async {
    try {
      final filePath = await localDataSource.exportDatabase(
        customPath: customPath,
      );
      return Right(
        ExportResult(
          filePath: filePath,
          format: 'db',
          itemCount: 0,
        ),
      );
    } catch (e) {
      return Left(BackupFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExportResult>> exportToJSON({
    bool includeImages = false,
  }) async {
    try {
      final filePath = await localDataSource.exportToJSON(
        includeImages: includeImages,
      );
      return Right(
        ExportResult(
          filePath: filePath,
          format: 'json',
          itemCount: 0,
        ),
      );
    } catch (e) {
      return Left(BackupFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExportResult>> exportToZIP({
    String? customPath,
  }) async {
    try {
      final filePath = await localDataSource.exportToZIP(
        customPath: customPath,
      );
      return Right(
        ExportResult(
          filePath: filePath,
          format: 'zip',
          itemCount: 0,
        ),
      );
    } catch (e) {
      return Left(BackupFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getAvailableDiskSpace() async {
    try {
      final bytes = await localDataSource.getAvailableDiskSpace();
      return Right(bytes);
    } catch (e) {
      return Left(BackupFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getDatabaseSize() async {
    try {
      final bytes = await localDataSource.getDatabaseSize();
      return Right(bytes);
    } catch (e) {
      return Left(BackupFailure(message: e.toString()));
    }
  }

  @override
  Future<dynamic> openDatabase(String path) async {
    try {
      return await localDataSource.openDatabase(path);
    } catch (e) {
      throw BackupFailure(message: e.toString());
    }
  }

  @override
  Future<Either<Failure, ImportResult>> importFromBackup({
    required String backupFilePath,
    ImportMode mode = ImportMode.merge,
  }) async {
    try {
      final importedCount = await localDataSource.importFromBackup(
        backupFilePath,
      );
      // If importedCount is -1, it's a database replacement (count unknown)
      final result = ImportResult(
        totalProcessed: importedCount < 0 ? 0 : importedCount,
        imported: importedCount < 0 ? -1 : importedCount,
        skipped: 0,
        failed: 0,
      );
      return Right(result);
    } catch (e) {
      return Left(BackupFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> replaceDatabase(String dbFilePath) async {
    try {
      await localDataSource.replaceDatabase(dbFilePath);
      return Right<Failure, void>(null);
    } catch (e) {
      return Left(BackupFailure(message: e.toString()));
    }
  }
}
