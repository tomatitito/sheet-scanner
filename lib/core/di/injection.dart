import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

final getIt = GetIt.instance;
final _logger = Logger('DependencyInjection');

/// Sets up all dependencies for the application.
///
/// This function must be called in main() before running the app.
/// It configures:
/// - Database connections
/// - Repository implementations
/// - Use cases
/// - Cubits and state management
/// - Data sources
///
/// Dependencies are registered as:
/// - Singletons: Application-wide instances (Database, Repositories)
/// - Lazy Singletons: Deferred initialization (Cubits)
/// - Factories: New instances on each call (temporary objects)
Future<void> setupInjection() async {
  // ====== TIER 1: DATABASE & DATA SOURCES ======
  // To be implemented in Phase 1: Drift database setup
  // Example (after database implementation):
  // final database = AppDatabase();
  // getIt.registerSingleton<AppDatabase>(database);
  // getIt.registerSingleton<SheetMusicLocalDataSource>(
  //   SheetMusicLocalDataSource(database),
  // );

  // ====== TIER 2: REPOSITORIES ======
  // To be implemented in Phase 1: Repository implementations
  // Example (after repository implementation):
  // getIt.registerSingleton<SheetMusicRepository>(
  //   SheetMusicRepositoryImpl(
  //     localDataSource: getIt<SheetMusicLocalDataSource>(),
  //   ),
  // );

  // ====== TIER 3: USE CASES ======
  // To be implemented in each feature phase
  // Example:
  // getIt.registerSingleton<GetAllSheetMusicUseCase>(
  //   GetAllSheetMusicUseCase(getIt<SheetMusicRepository>()),
  // );

  // ====== TIER 4: CUBITS/STATE MANAGEMENT ======
  // To be implemented in each feature phase
  // Example:
  // getIt.registerLazySingleton<SheetMusicCubit>(
  //   () => SheetMusicCubit(
  //     getIt<GetAllSheetMusicUseCase>(),
  //     getIt<AddSheetMusicUseCase>(),
  //   ),
  // );

  _logger.info('Dependency injection setup complete');
}
