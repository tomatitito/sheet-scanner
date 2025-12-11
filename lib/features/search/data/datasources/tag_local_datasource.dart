import 'package:drift/drift.dart' as drift;
import 'package:sheet_scanner/core/database/database.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/tag.dart';

/// Abstract interface for tag data source operations.
abstract class TagLocalDataSource {
  /// Create a new tag with the given name.
  Future<Tag> createTag(String name);

  /// Get a tag by ID.
  Future<Tag?> getTag(int id);

  /// Get all tags with their usage counts.
  Future<List<Tag>> getAllTags();

  /// Get tags for a specific sheet music.
  Future<List<Tag>> getTagsForSheet(int sheetMusicId);

  /// Update a tag's name.
  Future<Tag> updateTag(int id, String newName);

  /// Delete a tag and all associations.
  Future<void> deleteTag(int id);

  /// Merge two tags: reassign all sheets from source to target, then delete source.
  Future<void> mergeTags(int sourceTagId, int targetTagId);

  /// Get tag suggestions based on a partial name.
  Future<List<Tag>> suggestTags(String partialName);

  /// Add a tag to a sheet music.
  Future<void> addTagToSheet(int sheetMusicId, int tagId);

  /// Remove a tag from a sheet music.
  Future<void> removeTagFromSheet(int sheetMusicId, int tagId);
}

/// Implementation of TagLocalDataSource using Drift.
class TagLocalDataSourceImpl implements TagLocalDataSource {
  final AppDatabase database;

  TagLocalDataSourceImpl({required this.database});

  @override
  Future<Tag> createTag(String name) async {
    final insertedId = await database.into(database.tagsTable).insert(
          TagsTableCompanion(
            name: drift.Value(name),
          ),
        );

    return Tag(id: insertedId, name: name, count: 0);
  }

  @override
  Future<void> deleteTag(int id) async {
    // Delete all associations with this tag
    await (database.delete(database.sheetMusicTagsTable)
          ..where((t) => t.tagId.equals(id)))
        .go();

    // Delete the tag itself
    await (database.delete(database.tagsTable)
          ..where((t) => t.id.equals(id)))
        .go();
  }

  @override
  Future<List<Tag>> getAllTags() async {
    final tagsCounts = await database.getAllTagsWithCount();
    return tagsCounts
        .map((tc) => Tag(id: tc.$1.id, name: tc.$1.name, count: tc.$2))
        .toList();
  }

  @override
  Future<Tag?> getTag(int id) async {
    final tagModel = await (database.select(database.tagsTable)
          ..where((t) => t.id.equals(id)))
        .getSingleOrNull();

    if (tagModel == null) return null;

    // Get usage count
    final count = await (database.select(database.sheetMusicTagsTable)
          ..where((t) => t.tagId.equals(id)))
        .get()
        .then((rows) => rows.length);

    return Tag(id: tagModel.id, name: tagModel.name, count: count);
  }

  @override
  Future<List<Tag>> getTagsForSheet(int sheetMusicId) async {
    final tagModels = await database.getTagsForSheet(sheetMusicId);
    return tagModels
        .map((tm) => Tag(id: tm.id, name: tm.name, count: 0))
        .toList();
  }

  @override
  Future<void> mergeTags(int sourceTagId, int targetTagId) async {
    // Get all sheets with the source tag
    final sheetIdsWithSourceTag = await (database
            .select(database.sheetMusicTagsTable)
          ..where((t) => t.tagId.equals(sourceTagId)))
        .map((row) => row.sheetMusicId)
        .get();

    // Reassign to target tag (avoid duplicates)
    for (final sheetId in sheetIdsWithSourceTag) {
      final existing = await (database
              .select(database.sheetMusicTagsTable)
            ..where((t) => t.sheetMusicId.equals(sheetId) &
                t.tagId.equals(targetTagId)))
          .getSingleOrNull();

      if (existing == null) {
        // Only insert if the sheet doesn't already have the target tag
        await database.into(database.sheetMusicTagsTable).insert(
              SheetMusicTagsTableCompanion(
                sheetMusicId: drift.Value(sheetId),
                tagId: drift.Value(targetTagId),
              ),
            );
      }
    }

    // Delete the source tag
    await deleteTag(sourceTagId);
  }

  @override
  Future<List<Tag>> suggestTags(String partialName) async {
    final tagModels = await (database.select(database.tagsTable)
          ..where((t) => t.name.like('%$partialName%')))
        .get();

    final tags = <Tag>[];
    for (final tm in tagModels) {
      final count = await (database.select(database.sheetMusicTagsTable)
            ..where((t) => t.tagId.equals(tm.id)))
          .get()
          .then((rows) => rows.length);
      tags.add(Tag(id: tm.id, name: tm.name, count: count));
    }

    return tags;
  }

  @override
  Future<Tag> updateTag(int id, String newName) async {
    await (database.update(database.tagsTable)..where((t) => t.id.equals(id)))
        .write(
          TagsTableCompanion(
            name: drift.Value(newName),
          ),
        );

    // Get updated tag
    final tagModel = await (database.select(database.tagsTable)
          ..where((t) => t.id.equals(id)))
        .getSingle();

    final count = await (database.select(database.sheetMusicTagsTable)
          ..where((t) => t.tagId.equals(id)))
        .get()
        .then((rows) => rows.length);

    return Tag(id: tagModel.id, name: tagModel.name, count: count);
  }

  @override
  Future<void> addTagToSheet(int sheetMusicId, int tagId) async {
    // Check if already exists
    final existing = await (database
            .select(database.sheetMusicTagsTable)
          ..where((t) => t.sheetMusicId.equals(sheetMusicId) &
              t.tagId.equals(tagId)))
        .getSingleOrNull();

    if (existing == null) {
      await database.into(database.sheetMusicTagsTable).insert(
            SheetMusicTagsTableCompanion(
              sheetMusicId: drift.Value(sheetMusicId),
              tagId: drift.Value(tagId),
            ),
          );
    }
  }

  @override
  Future<void> removeTagFromSheet(int sheetMusicId, int tagId) async {
    await (database.delete(database.sheetMusicTagsTable)
          ..where((t) => t.sheetMusicId.equals(sheetMusicId) &
              t.tagId.equals(tagId)))
        .go();
  }
}
