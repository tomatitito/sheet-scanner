import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/browse_page.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/pages/home_page.dart';
import 'package:sheet_scanner/features/ocr/presentation/pages/scan_camera_page.dart';
import 'package:sheet_scanner/features/ocr/presentation/pages/ocr_review_wrapper.dart';

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
    GoRoute(
      path: '/scan',
      name: 'scan',
      builder: (context, state) => const ScanCameraPage(),
    ),
    GoRoute(
      path: '/ocr-review',
      name: 'ocr-review',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        if (extra == null) {
          return const Scaffold(
            body: Center(child: Text('Invalid OCR review parameters')),
          );
        }
        return OCRReviewWrapper(
          imagePath: extra['imagePath'] as String,
          detectedTitle: extra['detectedTitle'] as String,
          detectedComposer: extra['detectedComposer'] as String,
          confidence: extra['confidence'] as double,
        );
      },
    ),
  ],
);
