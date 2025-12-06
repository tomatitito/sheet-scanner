import 'dart:io';

/// Utility for detecting the current platform.
///
/// Used to provide platform-specific implementations and behavior
/// without exposing platform-specific code throughout the app.
abstract class PlatformDetector {
  /// Returns true if the app is running on iOS.
  static bool get isIOS => !kIsWeb && Platform.isIOS;

  /// Returns true if the app is running on Android.
  static bool get isAndroid => !kIsWeb && Platform.isAndroid;

  /// Returns true if the app is running on a mobile platform (iOS or Android).
  static bool get isMobile => isIOS || isAndroid;

  /// Returns true if the app is running on macOS.
  static bool get isMacOS => !kIsWeb && Platform.isMacOS;

  /// Returns true if the app is running on Windows.
  static bool get isWindows => !kIsWeb && Platform.isWindows;

  /// Returns true if the app is running on Linux.
  static bool get isLinux => !kIsWeb && Platform.isLinux;

  /// Returns true if the app is running on a desktop platform.
  static bool get isDesktop => isMacOS || isWindows || isLinux;

  /// Returns true if the app is running on the web.
  static bool get isWeb => kIsWeb;
}

// Dart 2 web detection
const bool kIsWeb = bool.fromEnvironment('dart.library.js_util');
