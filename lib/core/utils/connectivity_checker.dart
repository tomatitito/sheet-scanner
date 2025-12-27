import 'dart:io';

/// Utility class for checking network connectivity.
///
/// Provides methods to check if the device has an active internet connection.
/// Note: This is a simple implementation that checks basic connectivity.
/// For production apps with advanced networking needs, consider using
/// the 'connectivity_plus' package for more comprehensive checking.
class ConnectivityChecker {
  /// Checks if the device has an active internet connection.
  ///
  /// Returns true if at least one connection type is available and
  /// can reach a stable host (8.8.8.8 - Google DNS).
  static Future<bool> hasInternetConnection() async {
    try {
      // Try to reach a stable, globally accessible host
      final result = await InternetAddress.lookup('8.8.8.8');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException {
      // No connection
    }
    return false;
  }

  /// Checks connectivity with a fallback to a secondary host.
  ///
  /// First tries Google DNS (8.8.8.8), then falls back to Cloudflare DNS (1.1.1.1).
  /// This is more robust for different network configurations.
  static Future<bool> hasInternetConnectionWithFallback() async {
    try {
      // Primary check - Google DNS
      final result = await InternetAddress.lookup('8.8.8.8')
          .timeout(const Duration(seconds: 5));
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } catch (_) {
      // Fallback check - Cloudflare DNS
      try {
        final fallbackResult = await InternetAddress.lookup('1.1.1.1')
            .timeout(const Duration(seconds: 5));
        if (fallbackResult.isNotEmpty &&
            fallbackResult[0].rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {
        // No connection on fallback either
      }
    }
    return false;
  }
}
