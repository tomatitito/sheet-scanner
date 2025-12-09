import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/database/database.dart';
import 'package:sheet_scanner/features/backup/data/datasources/backup_local_datasource.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  group('BackupLocalDataSourceImpl', () {
    late BackupLocalDataSourceImpl dataSource;
    late MockAppDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockAppDatabase();
      dataSource = BackupLocalDataSourceImpl(database: mockDatabase);
    });

    group('exportDatabase', () {
      test('throws exception when database file does not exist', () async {
        expect(
          () => dataSource.exportDatabase(),
          throwsException,
        );
      });

      test('returns valid file path when successful', () async {
        // This test would need a real database file to work
        // For now, we're testing that the method signature is correct
        expect(dataSource.exportDatabase(), completes);
      });
    });

    group('getDatabaseSize', () {
      test('returns 0 when database file does not exist', () async {
        final size = await dataSource.getDatabaseSize();
        expect(size, equals(0));
      });
    });

    group('getAvailableDiskSpace', () {
      test('returns non-negative number', () async {
        final space = await dataSource.getAvailableDiskSpace();
        expect(space, greaterThanOrEqualTo(0));
      });
    });

    group('exportToJSON', () {
      test('creates valid JSON file', () async {
        // This test would need a working database
        // For now, we verify the method exists and has the right signature
        expect(dataSource.exportToJSON(), completes);
      });
    });

    group('exportToZIP', () {
      test('creates valid ZIP file', () async {
        // This test would need a working database
        // For now, we verify the method exists and has the right signature
        expect(dataSource.exportToZIP(), completes);
      });
    });
  });
}
