import 'package:get_it/get_it.dart';
import 'package:sheet_scanner/core/database/database.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies for the application.
/// Must be called before runApp() in main.dart.
void setupInjection() {
  // Database - LazyDatabase will initialize on first use
  getIt.registerSingleton<AppDatabase>(AppDatabase());

  // Note: Repository implementations and cubits will be registered
  // as features are developed. This is the base setup.
}
