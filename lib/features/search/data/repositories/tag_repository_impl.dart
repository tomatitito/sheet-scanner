import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/search/data/datasources/tag_local_datasource.dart';
import 'package:sheet_scanner/features/search/domain/repositories/tag_repository.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/tag.dart';

/// Implementation of TagRepository using local database.
class TagRepositoryImpl implements TagRepository {
  final TagLocalDataSource localDataSource;

  TagRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, Tag>> createTag(String name) async {
    try {
      final tag = await localDataSource.createTag(name);
      return Right(tag);
    } catch (e) {
      return Left(SearchFailure(message: 'Failed to create tag: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTag(int id) async {
    try {
      await localDataSource.deleteTag(id);
      return Right(true);
    } catch (e) {
      return Left(SearchFailure(message: 'Failed to delete tag: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Tag>>> getAllTags() async {
    try {
      final tags = await localDataSource.getAllTags();
      return Right(tags);
    } catch (e) {
      return Left(SearchFailure(message: 'Failed to fetch tags: $e'));
    }
  }

  @override
  Future<Either<Failure, Tag?>> getTag(int id) async {
    try {
      final tag = await localDataSource.getTag(id);
      return Right(tag);
    } catch (e) {
      return Left(SearchFailure(message: 'Failed to fetch tag: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Tag>>> getTagsForSheet(int sheetMusicId) async {
    try {
      final tags = await localDataSource.getTagsForSheet(sheetMusicId);
      return Right(tags);
    } catch (e) {
      return Left(SearchFailure(message: 'Failed to fetch sheet tags: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> mergeTags(
    int sourceTagId,
    int targetTagId,
  ) async {
    try {
      await localDataSource.mergeTags(sourceTagId, targetTagId);
      return Right(true);
    } catch (e) {
      return Left(SearchFailure(message: 'Failed to merge tags: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Tag>>> suggestTags(String partialName) async {
    try {
      final tags = await localDataSource.suggestTags(partialName);
      return Right(tags);
    } catch (e) {
      return Left(SearchFailure(message: 'Failed to suggest tags: $e'));
    }
  }

  @override
  Future<Either<Failure, Tag>> updateTag(int id, String newName) async {
    try {
      final tag = await localDataSource.updateTag(id, newName);
      return Right(tag);
    } catch (e) {
      return Left(SearchFailure(message: 'Failed to update tag: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> addTagToSheet(
    int sheetMusicId,
    int tagId,
  ) async {
    try {
      await localDataSource.addTagToSheet(sheetMusicId, tagId);
      return Right(true);
    } catch (e) {
      return Left(SearchFailure(message: 'Failed to add tag to sheet: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> removeTagFromSheet(
    int sheetMusicId,
    int tagId,
  ) async {
    try {
      await localDataSource.removeTagFromSheet(sheetMusicId, tagId);
      return Right(true);
    } catch (e) {
      return Left(SearchFailure(message: 'Failed to remove tag from sheet: $e'));
    }
  }
}
