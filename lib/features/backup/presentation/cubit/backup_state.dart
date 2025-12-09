import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/features/backup/domain/repositories/backup_repository.dart';

part 'backup_state.freezed.dart';

/// State for backup operations (export/import)
@freezed
class BackupState with _$BackupState {
  /// Initial state - no operation in progress
  const factory BackupState.initial() = _Initial;

  /// Loading state - operation in progress
  const factory BackupState.loading() = _Loading;

  /// Export successful
  const factory BackupState.exportSuccess({
    required ExportResult result,
  }) = _ExportSuccess;

  /// Import successful
  const factory BackupState.importSuccess({
    required ImportResult result,
  }) = _ImportSuccess;

  /// Operation failed
  const factory BackupState.error({
    required Failure failure,
  }) = _Error;

  /// Database size info
  const factory BackupState.databaseInfo({
    required int databaseSize,
    required int availableDiskSpace,
  }) = _DatabaseInfo;
}
