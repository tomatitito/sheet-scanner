import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/tag.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';

/// Use case to update a tag's name.
class UpdateTagUseCase {
  final SheetMusicRepository repository;

  UpdateTagUseCase({required this.repository});

  Future<Either<Failure, Tag>> call(int tagId, String newName) {
    if (newName.trim().isEmpty) {
      return Future.value(
        Left(Failure(message: 'Tag name cannot be empty')),
      );
    }
    return repository.updateTag(tagId, newName);
  }
}
