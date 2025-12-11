import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';

/// Use case to delete a tag by ID.
class DeleteTagUseCase {
  final SheetMusicRepository repository;

  DeleteTagUseCase({required this.repository});

  Future<Either<Failure, void>> call(int tagId) {
    return repository.deleteTag(tagId);
  }
}
