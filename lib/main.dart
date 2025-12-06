import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'core/di/injection.dart';

final _logger = Logger('SheetScanner');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.loggerName} - ${record.message}');
  });

  setupInjection();
  _logger.info('App initialized');
  runApp(const SheetScannerApp());
}

class SheetScannerApp extends StatelessWidget {
  const SheetScannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sheet Scanner',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B5B45), // Warm brown for sheet music
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6B5B45),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      routerConfig: _getRouter(),
      debugShowCheckedModeBanner: false,
    );
  }

  GoRouter _getRouter() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
          routes: [
            GoRoute(
              path: 'scan',
              builder: (context, state) => const ScanScreen(),
            ),
            GoRoute(
              path: 'browse',
              builder: (context, state) => const BrowseScreen(),
            ),
            GoRoute(
              path: 'search',
              builder: (context, state) => const SearchScreen(),
            ),
            GoRoute(
              path: 'detail/:id',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return DetailScreen(id: id);
              },
            ),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    );
  }
}

// Placeholder screens - to be implemented by frontend agent
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class DetailScreen extends StatelessWidget {
  final String id;
  const DetailScreen({required this.id, super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => const Placeholder();
}
