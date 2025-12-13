import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';

/// Use case for retrieving all sheet music entries.
class GetAllSheetMusicUseCase {
  final SheetMusicRepository repository;

  GetAllSheetMusicUseCase({required this.repository});

  /// Retrieves all sheet music entries.
  Future<Either<Failure, List<SheetMusic>>> call() {
    return repository.getAll();
  }
}
