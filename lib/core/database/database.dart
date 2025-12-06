import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite3;

part 'database.g.dart';

// ============ TABLES ============

class SheetMusicTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get composer => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Index> get indexes => [
    Index('idx_composer', {composer}),
    Index('idx_title', {title}),
  ];
}

class TagsTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  IntColumn get count => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class SheetMusicTagsTable extends Table {
  IntColumn get sheetMusicId => integer()();
  IntColumn get tagId => integer()();

  @override
  Set<Column> get primaryKey => {sheetMusicId, tagId};

  @override
  List<ForeignKeyClause> get foreignKeys => [
    ForeignKeyClause(
      columnName: 'sheet_music_id',
      foreignTable: 'sheet_music_table',
      foreignColumnName: 'id',
      onDelete: KeyAction.cascade,
      onUpdate: KeyAction.cascade,
    ),
    ForeignKeyClause(
      columnName: 'tag_id',
      foreignTable: 'tags_table',
      foreignColumnName: 'id',
      onDelete: KeyAction.cascade,
      onUpdate: KeyAction.cascade,
    ),
  ];
}

// ============ DATABASE ============

@DriftDatabase(tables: [
  SheetMusicTable,
  TagsTable,
  SheetMusicTagsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        // Handle migrations here
      },
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sheet_scanner.db'));

    if (Platform.isAndroid) {
      await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    }

    sqlite3.SqliteException.loadExtension = false;

    return NativeDatabase.createInBackground(
      file,
      logStatements: false,
    );
  });
}
