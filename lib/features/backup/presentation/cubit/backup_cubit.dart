import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/backup/domain/repositories/backup_repository.dart';
import 'package:sheet_scanner/features/backup/domain/usecases/export_database_use_case.dart';
import 'package:sheet_scanner/features/backup/domain/usecases/export_to_json_use_case.dart';
import 'package:sheet_scanner/features/backup/domain/usecases/export_to_zip_use_case.dart';
import 'package:sheet_scanner/features/backup/domain/usecases/import_backup_use_case.dart';
import 'package:sheet_scanner/features/backup/domain/usecases/replace_database_use_case.dart';
import 'package:sheet_scanner/features/backup/presentation/cubit/backup_state.dart';

/// Cubit for managing backup/export/import operations
class BackupCubit extends Cubit<BackupState> {
  final ExportDatabaseUseCase exportDatabaseUseCase;
  final ExportToJsonUseCase exportToJsonUseCase;
  final ExportToZipUseCase exportToZipUseCase;
  final ImportBackupUseCase importBackupUseCase;
  final ReplaceDatabaseUseCase replaceDatabaseUseCase;

  BackupCubit({
    required this.exportDatabaseUseCase,
    required this.exportToJsonUseCase,
    required this.exportToZipUseCase,
    required this.importBackupUseCase,
    required this.replaceDatabaseUseCase,
  }) : super(const BackupState.initial());

  /// Exports the database to a backup file
  Future<void> exportDatabase({String? customPath}) async {
    emit(const BackupState.loading());

    final result = await exportDatabaseUseCase(customPath: customPath);

    result.fold(
      (failure) => emit(BackupState.error(failure: failure)),
      (exportResult) => emit(BackupState.exportSuccess(result: exportResult)),
    );
  }

  /// Exports sheet music to JSON format
  Future<void> exportToJson({bool includeImages = false}) async {
    emit(const BackupState.loading());

    final result = await exportToJsonUseCase(includeImages: includeImages);

    result.fold(
      (failure) => emit(BackupState.error(failure: failure)),
      (exportResult) => emit(BackupState.exportSuccess(result: exportResult)),
    );
  }

  /// Exports sheet music to ZIP format with images
  Future<void> exportToZip({String? customPath}) async {
    emit(const BackupState.loading());

    final result = await exportToZipUseCase(customPath: customPath);

    result.fold(
      (failure) => emit(BackupState.error(failure: failure)),
      (exportResult) => emit(BackupState.exportSuccess(result: exportResult)),
    );
  }

  /// Imports sheet music from a backup file
  Future<void> importFromBackup({
    required String backupFilePath,
    ImportMode mode = ImportMode.merge,
  }) async {
    emit(const BackupState.loading());

    final result = await importBackupUseCase(
      backupFilePath: backupFilePath,
      mode: mode,
    );

    result.fold(
      (failure) => emit(BackupState.error(failure: failure)),
      (importResult) => emit(BackupState.importSuccess(result: importResult)),
    );
  }

  /// Replaces the entire database with a backup
  Future<void> replaceDatabase({required String dbFilePath}) async {
    emit(const BackupState.loading());

    final result = await replaceDatabaseUseCase(dbFilePath: dbFilePath);

    result.fold(
      (failure) => emit(BackupState.error(failure: failure)),
      (_) => emit(
        const BackupState.importSuccess(
          result: ImportResult(
            totalProcessed: 0,
            imported: -1,
            skipped: 0,
            failed: 0,
          ),
        ),
      ),
    );
  }
}
