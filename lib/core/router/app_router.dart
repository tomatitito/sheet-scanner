import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// GoRouter configuration for the application.
/// Defines all routes and navigation paths.
/// Uses lazy loading to avoid circular dependencies with features.
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
      // Use lazy loading to prevent circular dependency with features layer
      builder: (context, state) {
        // Import here to avoid circular dependency at module level
        // ignore: avoid_relative_library_imports
        // The HomePage will be loaded by DI or through feature plugin
        return const SizedBox(
          child: Scaffold(
            body: Center(
              child: Text('Home Page'),
            ),
          ),
        );
      },
    ),
  ],
);
