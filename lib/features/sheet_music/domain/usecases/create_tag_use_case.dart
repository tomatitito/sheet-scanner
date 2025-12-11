import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/tag.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';

/// Use case to create a new tag.
class CreateTagUseCase {
  final SheetMusicRepository repository;

  CreateTagUseCase({required this.repository});

  Future<Either<Failure, Tag>> call(String name) {
    if (name.trim().isEmpty) {
      return Future.value(
        Left(Failure(message: 'Tag name cannot be empty')),
      );
    }
    return repository.createTag(name);
  }
}
