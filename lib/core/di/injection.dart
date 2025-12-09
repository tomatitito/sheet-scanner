import 'package:get_it/get_it.dart';
import 'package:sheet_scanner/core/database/database.dart';
import 'package:sheet_scanner/features/backup/data/datasources/backup_local_datasource.dart';
import 'package:sheet_scanner/features/backup/data/repositories/backup_repository_impl.dart';
import 'package:sheet_scanner/features/backup/domain/repositories/backup_repository.dart';
import 'package:sheet_scanner/features/ocr/data/datasources/ocr_local_datasource.dart';
import 'package:sheet_scanner/features/ocr/data/repositories/ocr_repository_impl.dart';
import 'package:sheet_scanner/features/ocr/domain/repositories/ocr_repository.dart';
import 'package:sheet_scanner/features/search/data/datasources/search_local_datasource.dart';
import 'package:sheet_scanner/features/search/data/repositories/search_repository_impl.dart';
import 'package:sheet_scanner/features/search/domain/repositories/search_repository.dart';
import 'package:sheet_scanner/features/sheet_music/data/datasources/sheet_music_local_datasource.dart';
import 'package:sheet_scanner/features/sheet_music/data/repositories/sheet_music_repository_impl.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_all_sheet_music_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/home_cubit.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies for the application.
/// Must be called before runApp() in main.dart.
///
/// Registers:
/// - Core dependencies (database, platform detection)
/// - Feature repositories (data layer contracts)
/// - Feature implementations (business logic)
/// - Feature data sources (local data access)
void setupInjection() {
  // ==================== CORE ====================
  // Database - LazyDatabase will initialize on first use
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  // ==================== SHEET MUSIC FEATURE ====================
  // Data sources
  getIt.registerSingleton<SheetMusicLocalDataSource>(
    SheetMusicLocalDataSourceImpl(database: getIt<AppDatabase>()),
  );

  // Repositories
  getIt.registerSingleton<SheetMusicRepository>(
    SheetMusicRepositoryImpl(
      localDataSource: getIt<SheetMusicLocalDataSource>(),
    ),
  );

  // ==================== OCR FEATURE ====================
  // Data sources
  getIt.registerSingleton<OCRLocalDataSource>(
    OCRLocalDataSourceImpl(),
  );

  // Repositories
  getIt.registerSingleton<OCRRepository>(
    OCRRepositoryImpl(
      localDataSource: getIt<OCRLocalDataSource>(),
    ),
  );

  // ==================== BACKUP FEATURE ====================
  // Data sources
  getIt.registerSingleton<BackupLocalDataSource>(
    BackupLocalDataSourceImpl(),
  );

  // Repositories
  getIt.registerSingleton<BackupRepository>(
    BackupRepositoryImpl(
      localDataSource: getIt<BackupLocalDataSource>(),
    ),
  );

  // ==================== SEARCH FEATURE ====================
  // Data sources
  getIt.registerSingleton<SearchLocalDataSource>(
    SearchLocalDataSourceImpl(database: getIt<AppDatabase>()),
  );

  // Repositories
  getIt.registerSingleton<SearchRepository>(
    SearchRepositoryImpl(
      localDataSource: getIt<SearchLocalDataSource>(),
    ),
  );

  // ==================== USE CASES ====================
  // Sheet Music Use Cases
  getIt.registerSingleton<GetAllSheetMusicUseCase>(
    GetAllSheetMusicUseCase(
      repository: getIt<SheetMusicRepository>(),
    ),
  );

  // ==================== PRESENTATION ====================
  // Sheet Music Cubits
  getIt.registerSingleton<HomeCubit>(
    HomeCubit(
      getAllSheetMusicUseCase: getIt<GetAllSheetMusicUseCase>(),
    ),
  );
}
