import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:sheet_scanner/core/database/database.dart';

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

  /// Deletes multiple sheet music records in a single transaction.
  /// More efficient than calling deleteSheetMusic() multiple times.
  Future<int> deleteBatch(List<int> ids);

  /// Updates multiple sheet music records in a single transaction.
  /// More efficient than calling updateSheetMusic() multiple times.
  Future<int> updateBatch(List<SheetMusicModel> models);

  /// Adds a tag to a sheet music entry.
  Future<void> addTagToSheetMusic(int sheetMusicId, String tagName);

  /// Removes a tag from a sheet music entry.
  Future<void> removeTagFromSheetMusic(int sheetMusicId, String tagName);

  /// Gets all tags for a sheet music entry.
  Future<List<String>> getTagsForSheetMusic(int sheetMusicId);
}

/// Implementation of SheetMusicLocalDataSource using Drift.
class SheetMusicLocalDataSourceImpl implements SheetMusicLocalDataSource {
  final AppDatabase database;

  SheetMusicLocalDataSourceImpl({required this.database});

  @override
  Future<int> insertSheetMusic(SheetMusicModel model) async {
    return database.into(database.sheetMusicTable).insert(
          SheetMusicTableCompanion(
            title: Value(model.title),
            composer: Value(model.composer),
            notes: Value(model.notes),
            imageUrls: Value(model.imageUrls),
            createdAt: Value(model.createdAt),
            updatedAt: Value(model.updatedAt),
          ),
        );
  }

  @override
  Future<SheetMusicModel?> getSheetMusicById(int id) {
    return (database.select(database.sheetMusicTable)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
  }

  @override
  Future<List<SheetMusicModel>> getAllSheetMusic() {
    return (database.select(database.sheetMusicTable)
          ..orderBy([
            (s) =>
                OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  @override
  Future<bool> updateSheetMusic(SheetMusicModel model) async {
    return database.update(database.sheetMusicTable).replace(
          SheetMusicTableCompanion(
            id: Value(model.id),
            title: Value(model.title),
            composer: Value(model.composer),
            notes: Value(model.notes),
            imageUrls: Value(model.imageUrls),
            createdAt: Value(model.createdAt),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  @override
  Future<bool> deleteSheetMusic(int id) async {
    // FTS index is automatically maintained by database triggers
    final deleted = await (database.delete(database.sheetMusicTable)
          ..where((s) => s.id.equals(id)))
        .go();

    return deleted > 0;
  }

  @override
  Future<List<SheetMusicModel>> getSheetMusicByComposer(String composer) {
    return database.searchByComposer(composer);
  }

  @override
  Future<List<SheetMusicModel>> getSheetMusicByTag(String tag) async {
    // Find the tag first
    final tagModel = await (database.select(database.tagsTable)
          ..where((t) => t.name.equals(tag)))
        .getSingleOrNull();

    if (tagModel == null) return [];

    // Get sheet music with this tag
    final sheetIds = await (database.select(database.sheetMusicTagsTable)
          ..where((t) => t.tagId.equals(tagModel.id)))
        .map((row) => row.sheetMusicId)
        .get();

    if (sheetIds.isEmpty) return [];

    return (database.select(database.sheetMusicTable)
          ..where((s) => s.id.isIn(sheetIds))
          ..orderBy([
            (s) =>
                OrderingTerm(expression: s.createdAt, mode: OrderingMode.desc)
          ]))
        .get();
  }

  @override
  Future<SheetMusicModel?> findSheetMusicByTitleAndComposer(
    String title,
    String composer,
  ) {
    return (database.select(database.sheetMusicTable)
          ..where((s) => s.title.equals(title) & s.composer.equals(composer)))
        .getSingleOrNull();
  }

  @override
  Future<void> deleteAllSheetMusic() async {
    // FTS index is automatically maintained by database triggers
    await database.delete(database.sheetMusicTable).go();
  }

  @override
  Future<int> deleteBatch(List<int> ids) async {
    if (ids.isEmpty) return 0;
    // Use a transaction to ensure atomic deletion
    return database.transaction(() async {
      return await (database.delete(database.sheetMusicTable)
            ..where((s) => s.id.isIn(ids)))
          .go();
    });
  }

  @override
  Future<int> updateBatch(List<SheetMusicModel> models) async {
    if (models.isEmpty) return 0;
    // Use a transaction to ensure atomic updates
    return database.transaction(() async {
      int updateCount = 0;
      for (final model in models) {
        final updated = await database.update(database.sheetMusicTable).replace(
              SheetMusicTableCompanion(
                id: Value(model.id),
                title: Value(model.title),
                composer: Value(model.composer),
                notes: Value(model.notes),
                imageUrls: Value(model.imageUrls),
                createdAt: Value(model.createdAt),
                updatedAt: Value(model.updatedAt),
              ),
            );
        if (updated) updateCount++;
      }
      return updateCount;
    });
  }

  @override
  Future<void> addTagToSheetMusic(int sheetMusicId, String tagName) async {
    // Get or create tag
    var tagModel = await (database.select(database.tagsTable)
          ..where((t) => t.name.equals(tagName)))
        .getSingleOrNull();

    if (tagModel == null) {
      final tagId = await database.into(database.tagsTable).insert(
            TagsTableCompanion(name: Value(tagName)),
          );
      tagModel = TagModel(id: tagId, name: tagName);
    }

    // Add the association (ignore if already exists)
    try {
      await database.into(database.sheetMusicTagsTable).insert(
            SheetMusicTagsTableCompanion(
              sheetMusicId: Value(sheetMusicId),
              tagId: Value(tagModel.id),
            ),
          );
    } catch (e) {
      // Check if this is a unique constraint violation (tag already associated)
      final errorMessage = e.toString();
      if (errorMessage.contains('UNIQUE constraint failed') ||
          errorMessage.contains('Unique constraint')) {
        // Tag is already associated with this sheet music, which is fine
        developer.log(
          'Tag already associated with sheet music (expected)',
          name: 'SheetMusicLocalDataSource',
        );
      } else {
        // Log and re-throw other database errors (connection lost, disk full, etc)
        developer.log(
          'Database error adding tag to sheet music: $errorMessage',
          name: 'SheetMusicLocalDataSource',
          error: e,
        );
        rethrow;
      }
    }
  }

  @override
  Future<void> removeTagFromSheetMusic(int sheetMusicId, String tagName) async {
    // Find the tag
    final tagModel = await (database.select(database.tagsTable)
          ..where((t) => t.name.equals(tagName)))
        .getSingleOrNull();

    if (tagModel == null) return;

    // Delete the association
    await (database.delete(database.sheetMusicTagsTable)
          ..where((t) =>
              t.sheetMusicId.equals(sheetMusicId) &
              t.tagId.equals(tagModel.id)))
        .go();
  }

  @override
  Future<List<String>> getTagsForSheetMusic(int sheetMusicId) async {
    final tags = await database.getTagsForSheet(sheetMusicId);
    return tags.map((tag) => tag.name).toList();
  }
}
