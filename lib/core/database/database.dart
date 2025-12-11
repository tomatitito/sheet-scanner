import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'database.g.dart';

// Tables
@DataClassName('SheetMusicModel')
class SheetMusicTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get composer => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

@DataClassName('TagModel')
class TagsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

@DataClassName('SheetMusicTagModel')
class SheetMusicTagsTable extends Table {
  IntColumn get sheetMusicId => integer()();
  IntColumn get tagId => integer()();

  @override
  Set<Column<Object>>? get primaryKey => {sheetMusicId, tagId};

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
        {sheetMusicId, tagId},
      ];
}

/// Virtual FTS5 table for full-text search on sheet music
@DataClassName('SheetMusicFTSModel')
class SheetMusicFtsTable extends Table {
  IntColumn get id => integer()();
  TextColumn get title => text()();
  TextColumn get composer => text()();
  TextColumn get notes => text().nullable()();

  @override
  String? get tableName => 'sheet_music_fts';
}

@DriftDatabase(tables: [
  SheetMusicTable,
  TagsTable,
  SheetMusicTagsTable,
  SheetMusicFtsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          // Handle migrations here
        },
      );

  /// Full-text search query using FTS5
  Future<List<SheetMusicModel>> fullTextSearch(String query) async {
    final escapedQuery = query.replaceAll('"', '""');
    return customSelect(
      'SELECT sm.* FROM sheet_music sm '
      'WHERE sm.id IN ('
      '  SELECT id FROM sheet_music_fts WHERE sheet_music_fts MATCH ?'
      ')',
      variables: [escapedQuery],
      readsFrom: {sheetMusicTable},
    ).map((row) => SheetMusicModel.fromData(row.data, this)).get();
  }

  /// Search by title
  Future<List<SheetMusicModel>> searchByTitle(String title) {
    return (select(sheetMusicTable)
          ..where((s) => s.title.like('%$title%')))
        .get();
  }

  /// Search by composer
  Future<List<SheetMusicModel>> searchByComposer(String composer) {
    return (select(sheetMusicTable)
          ..where((s) => s.composer.like('%$composer%')))
        .get();
  }

  /// Get all tags with their usage count
  Future<List<(TagModel, int)>> getAllTagsWithCount() async {
    final tags = await select(tagsTable).get();
    final result = <(TagModel, int)>[];

    for (final tag in tags) {
      final count = await (select(sheetMusicTagsTable)
            ..where((t) => t.tagId.equals(tag.id)))
          .get()
          .then((rows) => rows.length);
      result.add((tag, count));
    }

    return result;
  }

  /// Get tags for a specific sheet music
  Future<List<TagModel>> getTagsForSheet(int sheetMusicId) {
    return (select(tagsTable).join([
      innerJoin(
        sheetMusicTagsTable,
        sheetMusicTagsTable.tagId.equalsExp(tagsTable.id),
      ),
    ])
          ..where(sheetMusicTagsTable.sheetMusicId.equals(sheetMusicId)))
        .map((row) => row.readTable(tagsTable))
        .get();
  }

  /// Advanced search with multiple filters
  Future<List<SheetMusicModel>> advancedSearch({
    String? query,
    List<int>? tagIds,
    String? composer,
    String? sortBy = 'createdAt',
    bool descending = true,
  }) async {
    var q = select(sheetMusicTable);

    // FTS5 search if query provided
    if (query != null && query.isNotEmpty) {
      final escapedQuery = query.replaceAll('"', '""');
      final ftsResults = await customSelect(
        'SELECT id FROM sheet_music_fts WHERE sheet_music_fts MATCH ?',
        variables: [escapedQuery],
        readsFrom: {sheetMusicTable},
      ).get();
      final ftsIds = ftsResults.map((row) => row.read<int>('id')).toList();

      if (ftsIds.isEmpty) {
        return [];
      }

      q = q..where((s) => s.id.isIn(ftsIds));
    }

    // Composer filter
    if (composer != null && composer.isNotEmpty) {
      q = q..where((s) => s.composer.like('%$composer%'));
    }

    // Tag filter
    if (tagIds != null && tagIds.isNotEmpty) {
      final sheetIdsWithTags = await (select(sheetMusicTagsTable)
            ..where((t) => t.tagId.isIn(tagIds)))
          .map((row) => row.sheetMusicId)
          .get();

      if (sheetIdsWithTags.isEmpty) {
        return [];
      }

      q = q..where((s) => s.id.isIn(sheetIdsWithTags));
    }

    // Sorting
    switch (sortBy) {
      case 'title':
        q = q..orderBy([(s) => OrderingTerm(expression: s.title, mode: descending ? OrderingMode.desc : OrderingMode.asc)]);
      case 'composer':
        q = q..orderBy([(s) => OrderingTerm(expression: s.composer, mode: descending ? OrderingMode.desc : OrderingMode.asc)]);
      case 'createdAt':
      default:
        q = q..orderBy([(s) => OrderingTerm(expression: s.createdAt, mode: descending ? OrderingMode.desc : OrderingMode.asc)]);
    }

    return q.get();
  }

  /// Update FTS5 index for a sheet
  Future<void> updateFTSIndex(SheetMusicModel sheet) async {
    await delete(sheetMusicFtsTable)
        .delete(sheetMusicFtsTable.id.equals(sheet.id));

    await into(sheetMusicFtsTable).insert(
      SheetMusicFtsTableCompanion(
        id: Value(sheet.id),
        title: Value(sheet.title),
        composer: Value(sheet.composer),
        notes: Value(sheet.notes),
      ),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sheet_scanner.db'));
    return NativeDatabase(file);
  });
}
