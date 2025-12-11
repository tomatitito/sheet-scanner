import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/tag.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';

/// Use case to retrieve all tags with their usage counts.
class GetAllTagsUseCase {
  final SheetMusicRepository repository;

  GetAllTagsUseCase({required this.repository});

  Future<Either<Failure, List<Tag>>> call() {
    return repository.getAllTags();
  }
}
