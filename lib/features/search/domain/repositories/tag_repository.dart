import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/tag.dart';

/// Repository interface for tag management operations.
abstract class TagRepository {
  /// Create a new tag.
  /// Returns the created tag or a failure.
  Future<Either<Failure, Tag>> createTag(String name);

  /// Get a tag by ID.
  Future<Either<Failure, Tag?>> getTag(int id);

  /// Get all tags with their usage counts.
  Future<Either<Failure, List<Tag>>> getAllTags();

  /// Get tags for a specific sheet music ID.
  Future<Either<Failure, List<Tag>>> getTagsForSheet(int sheetMusicId);

  /// Update a tag.
  Future<Either<Failure, Tag>> updateTag(int id, String newName);

  /// Delete a tag.
  /// Returns whether the deletion was successful.
  Future<Either<Failure, bool>> deleteTag(int id);

  /// Merge two tags (combine tag B into tag A, delete B).
  /// Reassigns all sheets from tag B to tag A.
  Future<Either<Failure, bool>> mergeTags(int sourceTagId, int targetTagId);

  /// Get tag suggestions based on a partial name.
  /// Used for autocomplete in forms.
  Future<Either<Failure, List<Tag>>> suggestTags(String partialName);

  /// Add a tag to a specific sheet music.
  Future<Either<Failure, bool>> addTagToSheet(int sheetMusicId, int tagId);

  /// Remove a tag from a specific sheet music.
  Future<Either<Failure, bool>> removeTagFromSheet(int sheetMusicId, int tagId);
}
