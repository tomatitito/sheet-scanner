import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/browse_page.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/home_page.dart';

/// GoRouter configuration for the application.
/// Defines all routes and navigation paths.
final appRouter = GoRouter(
  initialLocation: '/',
  errorPageBuilder: (context, state) => MaterialPage(
    child: Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Text(state.error?.toString() ?? 'Unknown error'),
      ),
    ),
  ),
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/browse',
      name: 'browse',
      builder: (context, state) => const BrowsePage(),
    ),
  ],
);
