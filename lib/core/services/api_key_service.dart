import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for securely storing and retrieving API keys.
///
/// Uses flutter_secure_storage for encrypted storage:
/// - iOS: Keychain
/// - Android: EncryptedSharedPreferences (AES-256)
/// - macOS: Keychain
/// - Windows: Windows Credentials
/// - Linux: libsecret
class ApiKeyService {
  static const String _openAiKeyKey = 'openai_api_key';

  final FlutterSecureStorage _storage;

  /// Cached API key for synchronous access.
  /// Updated whenever the key is read or written.
  String _cachedApiKey = '';

  ApiKeyService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  /// Get the stored OpenAI API key.
  /// Returns empty string if not configured.
  Future<String> getOpenAiApiKey() async {
    try {
      final key = await _storage.read(key: _openAiKeyKey);
      _cachedApiKey = key ?? '';
      return _cachedApiKey;
    } catch (e) {
      debugPrint('Error reading OpenAI API key: $e');
      return '';
    }
  }
  
  /// Get the cached OpenAI API key synchronously.
  /// Returns the last known value or empty string if never loaded.
  /// Call [getOpenAiApiKey] first to ensure the cache is populated.
  String getOpenAiApiKeySync() {
    return _cachedApiKey;
  }

  /// Store the OpenAI API key securely.
  Future<bool> setOpenAiApiKey(String apiKey) async {
    try {
      if (apiKey.isEmpty) {
        await _storage.delete(key: _openAiKeyKey);
        _cachedApiKey = '';
      } else {
        await _storage.write(key: _openAiKeyKey, value: apiKey);
        _cachedApiKey = apiKey;
      }
      debugPrint(
          'OpenAI API key ${apiKey.isEmpty ? "removed" : "stored"} successfully');
      return true;
    } catch (e) {
      debugPrint('Error storing OpenAI API key: $e');
      return false;
    }
  }

  /// Check if an OpenAI API key is configured.
  Future<bool> hasOpenAiApiKey() async {
    final key = await getOpenAiApiKey();
    return key.isNotEmpty;
  }

  /// Validate the format of an OpenAI API key.
  /// Returns null if valid, or an error message if invalid.
  static String? validateApiKey(String apiKey) {
    if (apiKey.isEmpty) {
      return 'API key is required';
    }
    if (!apiKey.startsWith('sk-')) {
      return 'Invalid API key format. OpenAI keys start with "sk-"';
    }
    if (apiKey.length < 20) {
      return 'API key is too short';
    }
    return null;
  }

  /// Clear all stored API keys.
  Future<void> clearAll() async {
    try {
      await _storage.delete(key: _openAiKeyKey);
      debugPrint('All API keys cleared');
    } catch (e) {
      debugPrint('Error clearing API keys: $e');
    }
  }
}
