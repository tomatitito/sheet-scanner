import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Helper class for platform-specific operations.
class PlatformHelper {
  /// Check if running on a desktop platform.
  static bool isDesktop() {
    return defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  /// Check if running on mobile platform.
  static bool isMobile() {
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  /// Check if device is in landscape mode.
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  /// Check if device is in portrait mode.
  static bool isPortrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  /// Get screen width.
  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// Get screen height.
  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  /// Check if screen is considered "large" (typically > 800 width).
  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 800;
  }

  /// Get appropriate padding based on screen size and platform.
  static EdgeInsets getResponsivePadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (isDesktop()) {
      return EdgeInsets.symmetric(
        horizontal: screenWidth > 1200 ? 48.0 : 24.0,
        vertical: 24.0,
      );
    }

    return const EdgeInsets.all(16.0);
  }
}
