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

@DriftDatabase(tables: [
  SheetMusicTable,
  TagsTable,
  SheetMusicTagsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          // Create all regular tables
          await m.createAll();

          // Create FTS5 virtual table
          await customStatement(
            'CREATE VIRTUAL TABLE sheet_music_fts USING fts5('
            'id UNINDEXED, ' // Don't index id since we only use it for joins
            'title, '
            'composer, '
            'notes, '
            'content=sheet_music_table, ' // Link to content table
            'content_rowid=id' // Use id as rowid
            ')',
          );

          // Trigger: Insert into FTS when inserting into main table
          await customStatement(
            'CREATE TRIGGER sheet_music_fts_insert AFTER INSERT ON sheet_music_table BEGIN '
            'INSERT INTO sheet_music_fts(rowid, id, title, composer, notes) '
            'VALUES (new.id, new.id, new.title, new.composer, new.notes); '
            'END',
          );

          // Trigger: Update FTS when updating main table
          await customStatement(
            'CREATE TRIGGER sheet_music_fts_update AFTER UPDATE ON sheet_music_table BEGIN '
            'UPDATE sheet_music_fts SET title = new.title, composer = new.composer, notes = new.notes '
            'WHERE rowid = old.id; '
            'END',
          );

          // Trigger: Delete from FTS when deleting from main table
          await customStatement(
            'CREATE TRIGGER sheet_music_fts_delete AFTER DELETE ON sheet_music_table BEGIN '
            'DELETE FROM sheet_music_fts WHERE rowid = old.id; '
            'END',
          );
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            // Migration from v1 to v2: Add FTS5 table and triggers

            // Drop old FTS table if it exists (it was created incorrectly as a regular table)
            await customStatement('DROP TABLE IF EXISTS sheet_music_fts');

            // Create FTS5 virtual table
            await customStatement(
              'CREATE VIRTUAL TABLE sheet_music_fts USING fts5('
              'id UNINDEXED, '
              'title, '
              'composer, '
              'notes, '
              'content=sheet_music_table, '
              'content_rowid=id'
              ')',
            );

            // Populate FTS table from existing data
            await customStatement(
              'INSERT INTO sheet_music_fts(rowid, id, title, composer, notes) '
              'SELECT id, id, title, composer, notes FROM sheet_music_table',
            );

            // Create triggers
            await customStatement(
              'CREATE TRIGGER sheet_music_fts_insert AFTER INSERT ON sheet_music_table BEGIN '
              'INSERT INTO sheet_music_fts(rowid, id, title, composer, notes) '
              'VALUES (new.id, new.id, new.title, new.composer, new.notes); '
              'END',
            );

            await customStatement(
              'CREATE TRIGGER sheet_music_fts_update AFTER UPDATE ON sheet_music_table BEGIN '
              'UPDATE sheet_music_fts SET title = new.title, composer = new.composer, notes = new.notes '
              'WHERE rowid = old.id; '
              'END',
            );

            await customStatement(
              'CREATE TRIGGER sheet_music_fts_delete AFTER DELETE ON sheet_music_table BEGIN '
              'DELETE FROM sheet_music_fts WHERE rowid = old.id; '
              'END',
            );
          }
        },
      );

  /// Full-text search query using FTS5
  Future<List<SheetMusicModel>> fullTextSearch(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    final escapedQuery = query.replaceAll('"', '""');
    final results = await customSelect(
      'SELECT sm.id, sm.title, sm.composer, sm.notes, sm.created_at, sm.updated_at '
      'FROM sheet_music sm '
      'WHERE sm.id IN ('
      '  SELECT id FROM sheet_music_fts WHERE sheet_music_fts MATCH ?'
      ')',
      variables: [Variable<String>(escapedQuery)],
      readsFrom: {sheetMusicTable},
    ).get();

    return results.map((row) {
      return SheetMusicModel(
        id: row.read<int>('id'),
        title: row.read<String>('title'),
        composer: row.read<String>('composer'),
        notes: row.read<String?>('notes'),
        createdAt: row.read<DateTime>('created_at'),
        updatedAt: row.read<DateTime>('updated_at'),
      );
    }).toList();
  }

  /// Search by title
  Future<List<SheetMusicModel>> searchByTitle(String title) {
    return (select(sheetMusicTable)..where((s) => s.title.like('%$title%')))
        .get();
  }

  /// Search by composer
  Future<List<SheetMusicModel>> searchByComposer(String composer) {
    return (select(sheetMusicTable)
          ..where((s) => s.composer.like('%$composer%')))
        .get();
  }

  /// Filter sheet music by date range
  Future<List<SheetMusicModel>> filterSheetMusicByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) {
    return (select(sheetMusicTable)
          ..where((s) =>
              s.createdAt.isBiggerOrEqualValue(startDate) &
              s.createdAt.isSmallerOrEqualValue(endDate)))
        .get();
  }

  /// Get all tags with their usage count
  Future<List<(TagModel, int)>> getAllTagsWithCount() async {
    // Use raw SQL query instead of N+1 queries for better performance
    // Query: SELECT t.*, COUNT(st.sheet_music_id) as count
    //        FROM tags t LEFT JOIN sheet_music_tags st ON t.id = st.tag_id
    //        GROUP BY t.id ORDER BY t.title
    const query = '''
      SELECT t.id, t.name, COUNT(st.sheet_music_id) as count
      FROM tags t
      LEFT JOIN sheet_music_tags st ON t.id = st.tag_id
      GROUP BY t.id
      ORDER BY t.name
    ''';

    final rows = await customSelect(query).get();
    final result = <(TagModel, int)>[];

    for (final row in rows) {
      final tag = TagModel(
        id: row.read<int>('id'),
        name: row.read<String>('name'),
      );
      final count = row.read<int>('count');
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
        variables: [Variable<String>(escapedQuery)],
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
        q = q
          ..orderBy([
            (s) => OrderingTerm(
                expression: s.title,
                mode: descending ? OrderingMode.desc : OrderingMode.asc)
          ]);
      case 'composer':
        q = q
          ..orderBy([
            (s) => OrderingTerm(
                expression: s.composer,
                mode: descending ? OrderingMode.desc : OrderingMode.asc)
          ]);
      case 'createdAt':
      default:
        q = q
          ..orderBy([
            (s) => OrderingTerm(
                expression: s.createdAt,
                mode: descending ? OrderingMode.desc : OrderingMode.asc)
          ]);
    }

    return q.get();
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sheet_scanner.db'));
    return NativeDatabase(file);
  });
}
