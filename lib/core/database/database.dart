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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) => m.createAll(),
        onUpgrade: (Migrator m, int from, int to) async {
          // Handle migrations here
        },
      );

  // Queries will be added here
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sheet_scanner.db'));
    return NativeDatabase(file);
  });
}
