import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart' as drift;
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
    final backupFile = File(backupFilePath);

    if (!await backupFile.exists()) {
      throw Exception('Backup file not found at $backupFilePath');
    }

    // Determine file type and handle accordingly
    if (backupFilePath.endsWith('.zip')) {
      return _importFromZip(backupFilePath);
    } else if (backupFilePath.endsWith('.json')) {
      return _importFromJSON(backupFilePath);
    } else if (backupFilePath.endsWith('.db')) {
      return _importFromDatabase(backupFilePath);
    } else {
      throw Exception('Unsupported backup file format');
    }
  }

  /// Imports sheet music from a JSON backup file.
  Future<int> _importFromJSON(String jsonFilePath) async {
    try {
      final jsonFile = File(jsonFilePath);
      final jsonString = await jsonFile.readAsString();
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

      final sheetMusicList = jsonMap['sheetMusic'] as List<dynamic>? ?? [];
      int importedCount = 0;

      for (final item in sheetMusicList) {
        try {
          final sheetData = item as Map<String, dynamic>;
          final title = sheetData['title'] as String? ?? 'Untitled';
          final composer = sheetData['composer'] as String? ?? 'Unknown';
          final notes = sheetData['notes'] as String?;
          final createdAt = sheetData['createdAt'] != null
              ? DateTime.parse(sheetData['createdAt'] as String)
              : DateTime.now();
          final updatedAt = sheetData['updatedAt'] != null
              ? DateTime.parse(sheetData['updatedAt'] as String)
              : DateTime.now();

          // Insert into database
          await database.into(database.sheetMusicTable).insert(
                SheetMusicTableCompanion(
                  title: drift.Value(title),
                  composer: drift.Value(composer),
                  notes: notes != null && notes.isNotEmpty
                      ? drift.Value(notes)
                      : const drift.Value.absent(),
                  createdAt: drift.Value(createdAt),
                  updatedAt: drift.Value(updatedAt),
                ),
              );

          importedCount++;
        } catch (_) {
          // Silently skip items that fail to import
        }
      }

      return importedCount;
    } catch (e) {
      throw Exception('Failed to import JSON backup: $e');
    }
  }

  /// Imports sheet music from a ZIP backup file.
  Future<int> _importFromZip(String zipFilePath) async {
    try {
      final zipFile = File(zipFilePath);
      final zipBytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(zipBytes);

      int importedCount = 0;
      int jsonImportCount = 0;

      // First, try to import database if present
      for (final file in archive.files) {
        if (file.name == 'sheet_scanner.db') {
          // Extract and import database
          final tempDir = await getTemporaryDirectory();
          final tempDbPath = p.join(tempDir.path,
              'temp_backup_${DateTime.now().millisecondsSinceEpoch}.db');
          final tempFile = File(tempDbPath);
          await tempFile.writeAsBytes(file.content as List<int>);
          jsonImportCount = await _importFromDatabase(tempDbPath);
          // Clean up temp file
          await tempFile.delete();
          break;
        }
      }

      // If no database found or database import was 0, try JSON import
      if (jsonImportCount == 0) {
        // Look for JSON files in the archive
        for (final file in archive.files) {
          if (file.name.endsWith('.json')) {
            try {
              final jsonContent = file.content as List<int>;
              final jsonString = String.fromCharCodes(jsonContent);
              final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
              final sheetMusicList =
                  jsonMap['sheetMusic'] as List<dynamic>? ?? [];

              for (final item in sheetMusicList) {
                try {
                  final sheetData = item as Map<String, dynamic>;
                  final title = sheetData['title'] as String? ?? 'Untitled';
                  final composer =
                      sheetData['composer'] as String? ?? 'Unknown';
                  final notes = sheetData['notes'] as String?;
                  final createdAt = sheetData['createdAt'] != null
                      ? DateTime.parse(sheetData['createdAt'] as String)
                      : DateTime.now();
                  final updatedAt = sheetData['updatedAt'] != null
                      ? DateTime.parse(sheetData['updatedAt'] as String)
                      : DateTime.now();

                  // Insert into database
                  await database.into(database.sheetMusicTable).insert(
                        SheetMusicTableCompanion(
                          title: drift.Value(title),
                          composer: drift.Value(composer),
                          notes: notes != null && notes.isNotEmpty
                              ? drift.Value(notes)
                              : const drift.Value.absent(),
                          createdAt: drift.Value(createdAt),
                          updatedAt: drift.Value(updatedAt),
                        ),
                      );

                  importedCount++;
                } catch (_) {
                  // Silently skip items that fail to import
                }
              }
            } catch (_) {
              // Silently skip files that fail to process
            }
          }
        }
      }

      // Also import any images
      _extractImagesFromZip(archive);

      return jsonImportCount > 0 ? jsonImportCount : importedCount;
    } catch (e) {
      throw Exception('Failed to import ZIP backup: $e');
    }
  }

  /// Imports sheet music from a database backup file.
  /// Note: For database imports, we treat it as a complete replacement.
  /// This is safer than trying to merge data between database files.
  Future<int> _importFromDatabase(String dbFilePath) async {
    try {
      final backupDbFile = File(dbFilePath);
      if (!await backupDbFile.exists()) {
        throw Exception('Database file not found at $dbFilePath');
      }

      // For .db files, we use replaceDatabase instead of merging
      // since reading from external databases requires complex setup
      await replaceDatabase(dbFilePath);

      // Return -1 to indicate a complete database replacement
      // (count unknown without reading the file)
      return -1;
    } catch (e) {
      throw Exception('Failed to import database backup: $e');
    }
  }

  /// Extracts images from ZIP archive to the images storage directory.
  Future<void> _extractImagesFromZip(Archive archive) async {
    try {
      final imagesPath = await ImageStorage.getStoragePath();

      for (final file in archive.files) {
        if (file.name.startsWith('images/') && file.isFile) {
          final relativePath = file.name.replaceFirst('images/', '');
          final fileDir =
              Directory(p.join(imagesPath, p.dirname(relativePath)));

          if (!await fileDir.exists()) {
            await fileDir.create(recursive: true);
          }

          final filePath = p.join(imagesPath, relativePath);
          final outputFile = File(filePath);
          final content = file.content as List<int>;
          await outputFile.writeAsBytes(content);
        }
      }
    } catch (_) {
      // Silently continue - images are optional
    }
  }

  @override
  Future<void> replaceDatabase(String dbFilePath) async {
    final sourceFile = File(dbFilePath);

    if (!await sourceFile.exists()) {
      throw Exception('Database file not found at $dbFilePath');
    }

    final currentDbPath = await _getDatabasePath();
    final currentDbFile = File(currentDbPath);

    // Backup current database before replacing
    if (await currentDbFile.exists()) {
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final backupDir = await _getBackupDir();
      final backupPath =
          p.join(backupDir.path, 'backup_before_restore_$timestamp.db');
      await currentDbFile.copy(backupPath);
    }

    // Replace with new database
    await sourceFile.copy(currentDbPath);
  }

  @override
  Future<dynamic> openDatabase(String path) async {
    final dbFile = File(path);

    if (!await dbFile.exists()) {
      throw Exception('Database file not found at $path');
    }

    // TODO: Implement read-only database connection
    // This would require creating a separate Drift instance for reading
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
