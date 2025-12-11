import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/search/domain/repositories/tag_repository.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/tag.dart';

/// Use case to create a new tag.
class CreateTagUseCase {
  final TagRepository repository;

  CreateTagUseCase({required this.repository});

  Future<Either<Failure, Tag>> call(String name) async {
    return repository.createTag(name);
  }
}

/// Use case to get all tags.
class GetAllTagsUseCase {
  final TagRepository repository;

  GetAllTagsUseCase({required this.repository});

  Future<Either<Failure, List<Tag>>> call() async {
    return repository.getAllTags();
  }
}

/// Use case to get tags for a specific sheet.
class GetSheetTagsUseCase {
  final TagRepository repository;

  GetSheetTagsUseCase({required this.repository});

  Future<Either<Failure, List<Tag>>> call(int sheetMusicId) async {
    return repository.getTagsForSheet(sheetMusicId);
  }
}

/// Use case to delete a tag.
class DeleteTagUseCase {
  final TagRepository repository;

  DeleteTagUseCase({required this.repository});

  Future<Either<Failure, bool>> call(int tagId) async {
    return repository.deleteTag(tagId);
  }
}

/// Use case to merge two tags.
class MergeTagsUseCase {
  final TagRepository repository;

  MergeTagsUseCase({required this.repository});

  Future<Either<Failure, bool>> call(int sourceId, int targetId) async {
    return repository.mergeTags(sourceId, targetId);
  }
}

/// Use case to suggest tags based on partial name.
class SuggestTagsUseCase {
  final TagRepository repository;

  SuggestTagsUseCase({required this.repository});

  Future<Either<Failure, List<Tag>>> call(String partialName) async {
    return repository.suggestTags(partialName);
  }
}

/// Use case to add a tag to a sheet.
class AddTagToSheetUseCase {
  final TagRepository repository;

  AddTagToSheetUseCase({required this.repository});

  Future<Either<Failure, bool>> call(int sheetMusicId, int tagId) async {
    return repository.addTagToSheet(sheetMusicId, tagId);
  }
}

/// Use case to remove a tag from a sheet.
class RemoveTagFromSheetUseCase {
  final TagRepository repository;

  RemoveTagFromSheetUseCase({required this.repository});

  Future<Either<Failure, bool>> call(int sheetMusicId, int tagId) async {
    return repository.removeTagFromSheet(sheetMusicId, tagId);
  }
}
