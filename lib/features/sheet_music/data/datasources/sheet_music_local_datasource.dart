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

  /// Adds a tag to a sheet music entry.
  Future<void> addTagToSheetMusic(int sheetMusicId, String tagName);

  /// Removes a tag from a sheet music entry.
  Future<void> removeTagFromSheetMusic(int sheetMusicId, String tagName);

  /// Gets all tags for a sheet music entry.
  Future<List<String>> getTagsForSheetMusic(int sheetMusicId);
}

/// Implementation of SheetMusicLocalDataSource using Drift.
/// TODO: Complete implementation with proper Drift queries.
/// Current stub ensures architecture compiles and DTOs function correctly.
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
    } catch (_) {
      // Tag association already exists, which is fine
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
