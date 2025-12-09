import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';

/// Input parameters for UpdateSheetMusicUseCase
class UpdateSheetMusicParams {
  final SheetMusic sheetMusic;

  UpdateSheetMusicParams({required this.sheetMusic});
}

/// Use case for updating an existing sheet music entry.
class UpdateSheetMusicUseCase {
  final SheetMusicRepository repository;

  UpdateSheetMusicUseCase({required this.repository});

  /// Updates an existing sheet music entry.
  /// Returns the updated entry.
  Future<Either<Failure, SheetMusic>> call(UpdateSheetMusicParams params) {
    return repository.update(params.sheetMusic);
  }
}
