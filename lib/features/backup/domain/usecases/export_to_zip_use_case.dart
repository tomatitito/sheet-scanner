import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/backup/domain/repositories/backup_repository.dart';

/// Use case for exporting sheet music to ZIP format.
/// Includes database and images in a compressed archive.
class ExportToZipUseCase {
  final BackupRepository repository;

  ExportToZipUseCase({required this.repository});

  /// Exports sheet music and images to a ZIP file.
  /// Optionally saves to [customPath] instead of default export directory.
  /// Returns information about the exported file.
  Future<Either<Failure, ExportResult>> call({String? customPath}) {
    return repository.exportToZIP(customPath: customPath);
  }
}
