import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';

/// Input parameters for DeleteSheetMusicUseCase
class DeleteSheetMusicParams {
  final int id;

  DeleteSheetMusicParams({required this.id});
}

/// Use case for deleting a sheet music entry.
class DeleteSheetMusicUseCase {
  final SheetMusicRepository repository;

  DeleteSheetMusicUseCase({required this.repository});

  /// Deletes a sheet music entry by ID.
  /// Returns void on success, Failure on error.
  Future<Either<Failure, void>> call(DeleteSheetMusicParams params) {
    return repository.delete(params.id);
  }
}
