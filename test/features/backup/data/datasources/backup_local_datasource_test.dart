import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/database/database.dart';
import 'package:sheet_scanner/features/backup/data/datasources/backup_local_datasource.dart';

class MockAppDatabase extends Mock implements AppDatabase {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BackupLocalDataSourceImpl', () {
    late BackupLocalDataSourceImpl dataSource;
    late MockAppDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockAppDatabase();
      dataSource = BackupLocalDataSourceImpl(database: mockDatabase);
    });

    test('should instantiate with database', () {
      expect(dataSource, isNotNull);
      expect(dataSource.database, equals(mockDatabase));
    });

    test('should have all required methods defined', () {
      expect(dataSource.exportDatabase, isNotNull);
      expect(dataSource.exportToJSON, isNotNull);
      expect(dataSource.exportToZIP, isNotNull);
      expect(dataSource.getDatabaseSize, isNotNull);
      expect(dataSource.getAvailableDiskSpace, isNotNull);
      expect(dataSource.importFromBackup, isNotNull);
      expect(dataSource.replaceDatabase, isNotNull);
      expect(dataSource.openDatabase, isNotNull);
    });
  });
}
