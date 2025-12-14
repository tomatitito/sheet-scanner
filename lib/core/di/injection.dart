import 'package:get_it/get_it.dart';
import 'package:sheet_scanner/core/database/database.dart';
import 'package:sheet_scanner/features/backup/data/datasources/backup_local_datasource.dart';
import 'package:sheet_scanner/features/backup/data/repositories/backup_repository_impl.dart';
import 'package:sheet_scanner/features/backup/domain/repositories/backup_repository.dart';
import 'package:sheet_scanner/features/backup/domain/usecases/export_database_use_case.dart';
import 'package:sheet_scanner/features/backup/domain/usecases/export_to_json_use_case.dart';
import 'package:sheet_scanner/features/backup/domain/usecases/export_to_zip_use_case.dart';
import 'package:sheet_scanner/features/backup/domain/usecases/import_backup_use_case.dart';
import 'package:sheet_scanner/features/backup/domain/usecases/replace_database_use_case.dart';
import 'package:sheet_scanner/features/backup/presentation/cubit/backup_cubit.dart';
import 'package:sheet_scanner/features/ocr/data/datasources/ocr_local_datasource.dart';
import 'package:sheet_scanner/features/ocr/data/repositories/ocr_repository_impl.dart';
import 'package:sheet_scanner/features/ocr/domain/repositories/ocr_repository.dart';
import 'package:sheet_scanner/features/search/data/datasources/search_local_datasource.dart';
import 'package:sheet_scanner/features/search/data/datasources/tag_local_datasource.dart';
import 'package:sheet_scanner/features/search/data/repositories/search_repository_impl.dart';
import 'package:sheet_scanner/features/search/data/repositories/tag_repository_impl.dart';
import 'package:sheet_scanner/features/search/domain/repositories/search_repository.dart';
import 'package:sheet_scanner/features/search/domain/repositories/tag_repository.dart';
import 'package:sheet_scanner/features/search/domain/usecases/full_text_search_use_case.dart';
import 'package:sheet_scanner/features/search/domain/usecases/tag_usecases.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/search_cubit.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/tag_cubit.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/tag_suggestion_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/data/datasources/sheet_music_local_datasource.dart';
import 'package:sheet_scanner/features/sheet_music/data/repositories/sheet_music_repository_impl.dart';
import 'package:sheet_scanner/features/sheet_music/data/services/file_picker_service.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/add_sheet_music_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/delete_sheet_music_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_all_sheet_music_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_sheet_music_by_id_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/update_sheet_music_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/add_sheet_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/browse_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/bulk_operations_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/edit_sheet_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/home_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/ocr_review_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/sheet_detail_cubit.dart';
import 'package:sheet_scanner/features/ocr/domain/usecases/recognize_text_use_case.dart';
import 'package:sheet_scanner/features/ocr/presentation/cubit/ocr_scan_cubit.dart';

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
  // Services
  getIt.registerSingleton<FilePickerService>(
    FilePickerServiceImpl(),
  );

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
    BackupLocalDataSourceImpl(database: getIt<AppDatabase>()),
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

  getIt.registerSingleton<TagLocalDataSource>(
    TagLocalDataSourceImpl(database: getIt<AppDatabase>()),
  );

  // Repositories
  getIt.registerSingleton<SearchRepository>(
    SearchRepositoryImpl(
      localDataSource: getIt<SearchLocalDataSource>(),
    ),
  );

  getIt.registerSingleton<TagRepository>(
    TagRepositoryImpl(
      localDataSource: getIt<TagLocalDataSource>(),
    ),
  );

  // ==================== USE CASES ====================
  // Backup Use Cases
  getIt.registerSingleton<ExportDatabaseUseCase>(
    ExportDatabaseUseCase(
      repository: getIt<BackupRepository>(),
    ),
  );

  getIt.registerSingleton<ExportToJsonUseCase>(
    ExportToJsonUseCase(
      repository: getIt<BackupRepository>(),
    ),
  );

  getIt.registerSingleton<ExportToZipUseCase>(
    ExportToZipUseCase(
      repository: getIt<BackupRepository>(),
    ),
  );

  getIt.registerSingleton<ImportBackupUseCase>(
    ImportBackupUseCase(
      repository: getIt<BackupRepository>(),
    ),
  );

  getIt.registerSingleton<ReplaceDatabaseUseCase>(
    ReplaceDatabaseUseCase(
      repository: getIt<BackupRepository>(),
    ),
  );

  // OCR Use Cases
  getIt.registerSingleton<RecognizeTextUseCase>(
    RecognizeTextUseCase(
      repository: getIt<OCRRepository>(),
    ),
  );

  // Sheet Music Use Cases
  getIt.registerSingleton<AddSheetMusicUseCase>(
    AddSheetMusicUseCase(
      repository: getIt<SheetMusicRepository>(),
    ),
  );

  getIt.registerSingleton<GetAllSheetMusicUseCase>(
    GetAllSheetMusicUseCase(
      repository: getIt<SheetMusicRepository>(),
    ),
  );

  getIt.registerSingleton<GetSheetMusicByIdUseCase>(
    GetSheetMusicByIdUseCase(
      repository: getIt<SheetMusicRepository>(),
    ),
  );

  getIt.registerSingleton<UpdateSheetMusicUseCase>(
    UpdateSheetMusicUseCase(
      repository: getIt<SheetMusicRepository>(),
    ),
  );

  getIt.registerSingleton<DeleteSheetMusicUseCase>(
    DeleteSheetMusicUseCase(
      repository: getIt<SheetMusicRepository>(),
    ),
  );

  // Search Use Cases
  getIt.registerSingleton<FullTextSearchUseCase>(
    FullTextSearchUseCase(
      repository: getIt<SearchRepository>(),
    ),
  );

  // Tag Use Cases
  getIt.registerSingleton<CreateTagUseCase>(
    CreateTagUseCase(repository: getIt<TagRepository>()),
  );

  getIt.registerSingleton<GetAllTagsUseCase>(
    GetAllTagsUseCase(repository: getIt<TagRepository>()),
  );

  getIt.registerSingleton<GetSheetTagsUseCase>(
    GetSheetTagsUseCase(repository: getIt<TagRepository>()),
  );

  getIt.registerSingleton<DeleteTagUseCase>(
    DeleteTagUseCase(repository: getIt<TagRepository>()),
  );

  getIt.registerSingleton<MergeTagsUseCase>(
    MergeTagsUseCase(repository: getIt<TagRepository>()),
  );

  getIt.registerSingleton<SuggestTagsUseCase>(
    SuggestTagsUseCase(repository: getIt<TagRepository>()),
  );

  getIt.registerSingleton<AddTagToSheetUseCase>(
    AddTagToSheetUseCase(repository: getIt<TagRepository>()),
  );

  getIt.registerSingleton<RemoveTagFromSheetUseCase>(
    RemoveTagFromSheetUseCase(repository: getIt<TagRepository>()),
  );

  // ==================== PRESENTATION ====================
  // Backup Cubits
  getIt.registerFactory<BackupCubit>(
    () => BackupCubit(
      exportDatabaseUseCase: getIt<ExportDatabaseUseCase>(),
      exportToJsonUseCase: getIt<ExportToJsonUseCase>(),
      exportToZipUseCase: getIt<ExportToZipUseCase>(),
      importBackupUseCase: getIt<ImportBackupUseCase>(),
      replaceDatabaseUseCase: getIt<ReplaceDatabaseUseCase>(),
    ),
  );

  // Sheet Music Cubits
  getIt.registerFactory<HomeCubit>(
    () => HomeCubit(
      getAllSheetMusicUseCase: getIt<GetAllSheetMusicUseCase>(),
    ),
  );

  getIt.registerFactory<SheetDetailCubit>(
    () => SheetDetailCubit(
      getSheetMusicByIdUseCase: getIt<GetSheetMusicByIdUseCase>(),
      deleteSheetMusicUseCase: getIt<DeleteSheetMusicUseCase>(),
    ),
  );

  getIt.registerFactory<AddSheetCubit>(
    () => AddSheetCubit(
      addSheetMusicUseCase: getIt<AddSheetMusicUseCase>(),
    ),
  );

  getIt.registerFactory<EditSheetCubit>(
    () => EditSheetCubit(
      getSheetMusicByIdUseCase: getIt<GetSheetMusicByIdUseCase>(),
      updateSheetMusicUseCase: getIt<UpdateSheetMusicUseCase>(),
    ),
  );

  getIt.registerFactory<BrowseCubit>(
    () => BrowseCubit(
      getAllSheetMusicUseCase: getIt<GetAllSheetMusicUseCase>(),
    ),
  );

  getIt.registerFactory<BulkOperationsCubit>(
    () => BulkOperationsCubit(
      deleteSheetMusicUseCase: getIt<DeleteSheetMusicUseCase>(),
    ),
  );

  getIt.registerFactory<OCRReviewCubit>(
    () => OCRReviewCubit(
      getIt<AddSheetMusicUseCase>(),
    ),
  );

  // OCR Cubits
  getIt.registerFactory<OCRScanCubit>(
    () => OCRScanCubit(
      recognizeTextUseCase: getIt<RecognizeTextUseCase>(),
    ),
  );

  // Search Cubits
  getIt.registerFactory<SearchCubit>(
    () => SearchCubit(
      fullTextSearchUseCase: getIt<FullTextSearchUseCase>(),
      getAllTagsUseCase: getIt<GetAllTagsUseCase>(),
    ),
  );

  getIt.registerFactory<TagCubit>(
    () => TagCubit(
      getAllTagsUseCase: getIt<GetAllTagsUseCase>(),
      createTagUseCase: getIt<CreateTagUseCase>(),
      deleteTagUseCase: getIt<DeleteTagUseCase>(),
      mergeTagsUseCase: getIt<MergeTagsUseCase>(),
    ),
  );

  getIt.registerFactory<TagSuggestionCubit>(
    () => TagSuggestionCubit(
      getAllTagsUseCase: getIt<GetAllTagsUseCase>(),
    ),
  );
}
