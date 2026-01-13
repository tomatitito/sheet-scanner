import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/core/keyboard/keyboard_shortcuts.dart';
import 'package:sheet_scanner/core/router/app_router.dart';
import 'package:sheet_scanner/core/services/speech_recognition_service_factory.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize speech recognition factory (loads saved engine preference)
  await SpeechRecognitionServiceFactory.initialize();

  // Set up dependency injection
  setupInjection();

  // Refresh API key cache after DI is set up
  await SpeechRecognitionServiceFactory.refreshApiKey();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return KeyboardShortcutsHandler(
      onShortcut: _handleGlobalShortcut,
      child: MaterialApp.router(
        title: 'Sheet Music Library',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
      ),
    );
  }

  void _handleGlobalShortcut(String actionKey) {
    // Handle global shortcuts that apply across all screens
    switch (actionKey) {
      case KeyboardShortcuts.saveAction:
        // Save action will be handled by specific Cubits
        // Cubits can listen to a global save action stream
        break;
      case KeyboardShortcuts.newItemAction:
        // New item action - navigate or trigger add dialog
        break;
      case KeyboardShortcuts.searchAction:
        // Open search/filter
        break;
      case KeyboardShortcuts.escapeAction:
        // Close dialogs or go back
        if (context.canPop()) {
          context.pop();
        }
        break;
      default:
        break;
    }
  }
}
