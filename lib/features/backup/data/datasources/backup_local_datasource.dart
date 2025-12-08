/// Abstract interface for backup data source operations.
abstract class BackupLocalDataSource {
  /// Exports sheet music to JSON format.
  /// Returns the path to the created file.
  Future<String> exportToJSON({bool includeImages = false});

  /// Exports sheet music to ZIP format.
  /// Returns the path to the created file.
  Future<String> exportToZIP({String? customPath});

  /// Exports the database file.
  /// Returns the path to the exported database.
  Future<String> exportDatabase({String? customPath});

  /// Imports data from a backup file.
  /// [backupFilePath] is the path to the backup file.
  /// Returns count of imported items.
  Future<int> importFromBackup(String backupFilePath);

  /// Replaces the entire database with a backup.
  Future<void> replaceDatabase(String dbFilePath);

  /// Opens a database for reading.
  Future<dynamic> openDatabase(String path);

  /// Gets the size of the current database in bytes.
  Future<int> getDatabaseSize();

  /// Gets available disk space in bytes.
  Future<int> getAvailableDiskSpace();
}

/// Implementation of BackupLocalDataSource.
/// TODO: Complete implementation with actual file operations.
class BackupLocalDataSourceImpl implements BackupLocalDataSource {
  @override
  Future<String> exportToJSON({bool includeImages = false}) {
    throw UnimplementedError('exportToJSON not yet implemented');
  }

  @override
  Future<String> exportToZIP({String? customPath}) {
    throw UnimplementedError('exportToZIP not yet implemented');
  }

  @override
  Future<String> exportDatabase({String? customPath}) {
    throw UnimplementedError('exportDatabase not yet implemented');
  }

  @override
  Future<int> importFromBackup(String backupFilePath) {
    throw UnimplementedError('importFromBackup not yet implemented');
  }

  @override
  Future<void> replaceDatabase(String dbFilePath) {
    throw UnimplementedError('replaceDatabase not yet implemented');
  }

  @override
  Future<dynamic> openDatabase(String path) {
    throw UnimplementedError('openDatabase not yet implemented');
  }

  @override
  Future<int> getDatabaseSize() {
    throw UnimplementedError('getDatabaseSize not yet implemented');
  }

  @override
  Future<int> getAvailableDiskSpace() {
    throw UnimplementedError('getAvailableDiskSpace not yet implemented');
  }
}
