import 'package:sheet_scanner/core/database/database.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/tag.dart';

/// Abstract interface for local sheet music data source.
abstract class SheetMusicLocalDataSource {
  /// Inserts a new sheet music record into the database.
  Future<int> insertSheetMusic(SheetMusicModel model);

  /// Retrieves a sheet music record by ID.
  Future<SheetMusicModel?> getSheetMusicById(int id);

  /// Retrieves all sheet music records.
  Future<List<SheetMusicModel>> getAllSheetMusic();

  /// Updates an existing sheet music record.
  Future<bool> updateSheetMusic(SheetMusicModel model);

  /// Deletes a sheet music record by ID.
  Future<bool> deleteSheetMusic(int id);

  /// Retrieves all sheet music for a specific composer.
  Future<List<SheetMusicModel>> getSheetMusicByComposer(String composer);

  /// Retrieves all sheet music with a specific tag.
  Future<List<SheetMusicModel>> getSheetMusicByTag(String tag);

  /// Finds sheet music by title and composer.
  Future<SheetMusicModel?> findSheetMusicByTitleAndComposer(
    String title,
    String composer,
  );

  /// Deletes all sheet music records.
  Future<void> deleteAllSheetMusic();

  /// Adds a tag to a sheet music entry.
  Future<void> addTagToSheetMusic(int sheetMusicId, String tagName);

  /// Removes a tag from a sheet music entry.
  Future<void> removeTagFromSheetMusic(int sheetMusicId, String tagName);

  /// Gets all tags for a sheet music entry.
  Future<List<String>> getTagsForSheetMusic(int sheetMusicId);

  /// Gets all tags with their usage counts.
  Future<List<Tag>> getAllTags();

  /// Creates a new tag.
  Future<Tag> createTag(String name);

  /// Updates a tag's name.
  Future<Tag> updateTag(int tagId, String newName);

  /// Deletes a tag and removes it from all sheets.
  Future<void> deleteTag(int tagId);
}

/// Implementation of SheetMusicLocalDataSource using Drift.
/// TODO: Complete implementation with proper Drift queries.
/// Current stub ensures architecture compiles and DTOs function correctly.
class SheetMusicLocalDataSourceImpl implements SheetMusicLocalDataSource {
  final AppDatabase database;

  SheetMusicLocalDataSourceImpl({required this.database});

  @override
  Future<int> insertSheetMusic(SheetMusicModel model) {
    throw UnimplementedError('insertSheetMusic not yet implemented');
  }

  @override
  Future<SheetMusicModel?> getSheetMusicById(int id) {
    throw UnimplementedError('getSheetMusicById not yet implemented');
  }

  @override
  Future<List<SheetMusicModel>> getAllSheetMusic() {
    throw UnimplementedError('getAllSheetMusic not yet implemented');
  }

  @override
  Future<bool> updateSheetMusic(SheetMusicModel model) {
    throw UnimplementedError('updateSheetMusic not yet implemented');
  }

  @override
  Future<bool> deleteSheetMusic(int id) {
    throw UnimplementedError('deleteSheetMusic not yet implemented');
  }

  @override
  Future<List<SheetMusicModel>> getSheetMusicByComposer(String composer) {
    throw UnimplementedError('getSheetMusicByComposer not yet implemented');
  }

  @override
  Future<List<SheetMusicModel>> getSheetMusicByTag(String tag) {
    throw UnimplementedError('getSheetMusicByTag not yet implemented');
  }

  @override
  Future<SheetMusicModel?> findSheetMusicByTitleAndComposer(
    String title,
    String composer,
  ) {
    throw UnimplementedError(
        'findSheetMusicByTitleAndComposer not yet implemented');
  }

  @override
  Future<void> deleteAllSheetMusic() {
    throw UnimplementedError('deleteAllSheetMusic not yet implemented');
  }

  @override
  Future<void> addTagToSheetMusic(int sheetMusicId, String tagName) {
    throw UnimplementedError('addTagToSheetMusic not yet implemented');
  }

  @override
  Future<void> removeTagFromSheetMusic(int sheetMusicId, String tagName) {
    throw UnimplementedError('removeTagFromSheetMusic not yet implemented');
  }

  @override
  Future<List<String>> getTagsForSheetMusic(int sheetMusicId) {
    throw UnimplementedError('getTagsForSheetMusic not yet implemented');
  }

  @override
  Future<List<Tag>> getAllTags() {
    throw UnimplementedError('getAllTags not yet implemented');
  }

  @override
  Future<Tag> createTag(String name) {
    throw UnimplementedError('createTag not yet implemented');
  }

  @override
  Future<Tag> updateTag(int tagId, String newName) {
    throw UnimplementedError('updateTag not yet implemented');
  }

  @override
  Future<void> deleteTag(int tagId) {
    throw UnimplementedError('deleteTag not yet implemented');
  }
}
