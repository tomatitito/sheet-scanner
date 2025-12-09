import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sheet_scanner/core/database/database.dart';
import 'package:sheet_scanner/core/storage/image_storage.dart';

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
/// Handles all file system operations for backup/export/import functionality.
class BackupLocalDataSourceImpl implements BackupLocalDataSource {
  static const String _backupDirName = 'sheet_scanner_backups';
  static const String _dbFileName = 'sheet_scanner.db';

  final AppDatabase database;

  BackupLocalDataSourceImpl({required this.database});

  /// Gets the path to the database file.
  Future<String> _getDatabasePath() async {
    final docDir = await getApplicationDocumentsDirectory();
    return p.join(docDir.path, _dbFileName);
  }

  /// Gets or creates the backup directory.
  Future<Directory> _getBackupDir() async {
    final docDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(docDir.path, _backupDirName));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  @override
  Future<String> exportDatabase({String? customPath}) async {
    final dbPath = await _getDatabasePath();
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      throw Exception('Database file not found at $dbPath');
    }

    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'sheet_scanner_backup_$timestamp.db';

    late String exportPath;
    if (customPath != null) {
      exportPath = customPath;
    } else {
      final backupDir = await _getBackupDir();
      exportPath = p.join(backupDir.path, fileName);
    }

    // Copy database file to export location
    final exportFile = await dbFile.copy(exportPath);
    return exportFile.path;
  }

  @override
  Future<String> exportToJSON({bool includeImages = false}) async {
    // Query all sheet music from the database
    final sheetMusicList =
        await database.select(database.sheetMusicTable).get();

    // Build JSON structure
    final jsonData = {
      'exportDate': DateTime.now().toIso8601String(),
      'exportFormat': 'json',
      'version': '1.0',
      'sheetMusic': sheetMusicList.map((model) {
        final jsonItem = {
          'id': model.id,
          'title': model.title,
          'composer': model.composer,
          'notes': model.notes,
          'createdAt': model.createdAt.toIso8601String(),
          'updatedAt': model.updatedAt.toIso8601String(),
        };

        // Optionally include image information
        if (includeImages) {
          // TODO: Add image paths once schema includes them
          jsonItem['images'] = [];
        }

        return jsonItem;
      }).toList(),
      'metadata': {
        'totalSheets': sheetMusicList.length,
        'includeImages': includeImages,
      },
    };

    // Write JSON file
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'sheet_scanner_export_$timestamp.json';

    final backupDir = await _getBackupDir();
    final filePath = p.join(backupDir.path, fileName);
    final file = File(filePath);

    final jsonString = jsonEncode(jsonData);
    await file.writeAsString(jsonString);

    return filePath;
  }

  @override
  Future<String> exportToZIP({String? customPath}) async {
    final dbPath = await _getDatabasePath();
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      throw Exception('Database file not found at $dbPath');
    }

    // Create ZIP archive
    final archive = Archive();

    // Add database file
    final dbFileBytes = await dbFile.readAsBytes();
    archive.addFile(
      ArchiveFile(
        'sheet_scanner.db',
        dbFileBytes.length,
        dbFileBytes,
      ),
    );

    // Add images if they exist
    try {
      final imagesPath = await ImageStorage.getStoragePath();
      final imagesDir = Directory(imagesPath);

      if (await imagesDir.exists()) {
        final files = imagesDir.listSync(recursive: true);
        for (final entity in files) {
          if (entity is File) {
            final bytes = await entity.readAsBytes();
            final relativePath = p.relative(entity.path, from: imagesPath);
            archive.addFile(
              ArchiveFile(
                'images/$relativePath',
                bytes.length,
                bytes,
              ),
            );
          }
        }
      }
    } catch (e) {
      // Log but continue - images are optional
    }

    // Write ZIP file
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final fileName = 'sheet_scanner_backup_$timestamp.zip';

    late String exportPath;
    if (customPath != null) {
      exportPath = customPath;
    } else {
      final backupDir = await _getBackupDir();
      exportPath = p.join(backupDir.path, fileName);
    }

    final zipFile = File(exportPath);
    final zipBytes = ZipEncoder().encode(archive);
    if (zipBytes != null) {
      await zipFile.writeAsBytes(zipBytes);
    }

    return zipFile.path;
  }

  @override
  Future<int> importFromBackup(String backupFilePath) async {
    // TODO: Implement backup import with merge/replace logic
    throw UnimplementedError('importFromBackup not yet implemented');
  }

  @override
  Future<void> replaceDatabase(String dbFilePath) async {
    // TODO: Implement database replacement logic
    throw UnimplementedError('replaceDatabase not yet implemented');
  }

  @override
  Future<dynamic> openDatabase(String path) async {
    // TODO: Implement read-only database opening
    throw UnimplementedError('openDatabase not yet implemented');
  }

  @override
  Future<int> getDatabaseSize() async {
    final dbPath = await _getDatabasePath();
    final dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      return 0;
    }

    final stat = await dbFile.stat();
    return stat.size;
  }

  @override
  Future<int> getAvailableDiskSpace() async {
    // For now, return a placeholder
    // TODO: Implement actual disk space calculation using platform channels
    return 0;
  }
}
