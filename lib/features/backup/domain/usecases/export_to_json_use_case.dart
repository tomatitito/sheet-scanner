import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/backup/domain/repositories/backup_repository.dart';

/// Use case for exporting sheet music to JSON format.
/// Allows metadata-only export or with image references.
class ExportToJsonUseCase {
  final BackupRepository repository;

  ExportToJsonUseCase({required this.repository});

  /// Exports sheet music to JSON format.
  /// [includeImages] determines whether image URLs are included.
  /// Returns information about the exported file.
  Future<Either<Failure, ExportResult>> call({
    bool includeImages = false,
  }) {
    return repository.exportToJSON(includeImages: includeImages);
  }
}
