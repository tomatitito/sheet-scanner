import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';

/// Input parameters for AddSheetMusicUseCase
class AddSheetMusicParams {
  final SheetMusic sheetMusic;

  AddSheetMusicParams({required this.sheetMusic});
}

/// Use case for adding a new sheet music entry.
/// Validates input and delegates to repository.
class AddSheetMusicUseCase {
  final SheetMusicRepository repository;

  AddSheetMusicUseCase({required this.repository});

  /// Adds a new sheet music entry.
  /// Returns the created entry with generated ID.
  Future<Either<Failure, SheetMusic>> call(AddSheetMusicParams params) {
    return repository.add(params.sheetMusic);
  }
}
