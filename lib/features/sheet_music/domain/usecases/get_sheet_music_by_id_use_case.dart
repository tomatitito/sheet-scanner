import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';

/// Input for GetSheetMusicByIdUseCase
class GetSheetMusicByIdParams {
  final int id;

  GetSheetMusicByIdParams({required this.id});
}

/// Use case for retrieving a specific sheet music entry by ID.
class GetSheetMusicByIdUseCase {
  final SheetMusicRepository repository;

  GetSheetMusicByIdUseCase({required this.repository});

  /// Retrieves a single sheet music entry by its ID.
  /// Returns null if not found.
  Future<Either<Failure, SheetMusic?>> call(GetSheetMusicByIdParams params) {
    return repository.getById(params.id);
  }
}
