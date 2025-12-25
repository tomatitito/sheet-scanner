import 'package:logging/logging.dart';
import 'package:sheet_scanner/core/database/database.dart';
import 'package:sheet_scanner/core/di/injection.dart';

/// Manages the lifecycle of the application database.
///
/// Provides methods to:
/// - Check database health
/// - Properly close the database on app shutdown
/// - Handle database initialization errors
class DatabaseManager {
  static final _logger = Logger('DatabaseManager');

  /// Verifies that the database is properly initialized and accessible.
  ///
  /// Returns true if the database is ready for use.
  /// Returns false if there are any issues.
  static Future<bool> healthCheck() async {
    try {
      final database = getIt<AppDatabase>();
      
      // Try a simple query to verify database is working
      // This will also trigger lazy initialization if not done yet
      final count = await (database.select(database.sheetMusicTable)).get();
      
      _logger.info('Database health check passed. Sheet music records: ${count.length}');
      return true;
    } catch (e) {
      _logger.severe('Database health check failed: $e');
      return false;
    }
  }

  /// Properly closes the database connection.
  ///
  /// Should be called during app shutdown (e.g., in main() after app closes).
  /// Ensures all pending writes are flushed and resources are released.
  static Future<void> closeDatabase() async {
    try {
      final database = getIt<AppDatabase>();
      await database.close();
      _logger.info('Database closed successfully');
    } catch (e) {
      _logger.warning('Error closing database: $e');
      // Don't rethrow - we still want the app to shut down cleanly
    }
  }

  /// Returns diagnostic information about the database.
  ///
  /// Useful for debugging and error reporting.
  static Future<Map<String, dynamic>> getDatabaseInfo() async {
    try {
      final database = getIt<AppDatabase>();
      
      final sheetCount = await (database.select(database.sheetMusicTable)).get();
      final tagCount = await (database.select(database.tagsTable)).get();
      
      return {
        'status': 'ok',
        'sheetMusicRecords': sheetCount.length,
        'tags': tagCount.length,
        'schemaVersion': database.schemaVersion,
      };
    } catch (e) {
      return {
        'status': 'error',
        'error': e.toString(),
      };
    }
  }
}
