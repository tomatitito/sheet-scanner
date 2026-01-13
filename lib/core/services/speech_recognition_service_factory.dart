import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'api_key_service.dart';
import 'hybrid_speech_service.dart';
import 'openai_whisper_service.dart';
import 'speech_recognition_service.dart';
import 'whisper_service.dart';

/// Enum to specify which speech recognition engine to use.
enum SpeechRecognitionEngine {
  /// Traditional speech_to_text with device APIs (Google Speech, Apple Speech)
  deviceNative,

  /// OpenAI's Whisper (offline, tiny model - faster but less accurate)
  whisperLocal,

  /// OpenAI's Whisper API (cloud, Large V3 model - high accuracy)
  openaiWhisper,

  /// Hybrid: uses cloud when online, falls back to local when offline
  hybrid,
}

/// Factory for creating speech recognition service instances.
///
/// Provides abstraction to support:
/// - Traditional speech_to_text (device native APIs)
/// - Local Whisper (offline, tiny model)
/// - OpenAI Whisper API (cloud, high accuracy)
class SpeechRecognitionServiceFactory {
  static const String _enginePrefsKey = 'speech_recognition_engine';
  static SpeechRecognitionEngine _engine =
      SpeechRecognitionEngine.hybrid;
  static ApiKeyService? _apiKeyService;
  static String _cachedApiKey = '';

  /// Initialize the factory with stored preferences.
  static Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final engineIndex = prefs.getInt(_enginePrefsKey);
      if (engineIndex != null &&
          engineIndex < SpeechRecognitionEngine.values.length) {
        _engine = SpeechRecognitionEngine.values[engineIndex];
      }
      debugPrint('Speech recognition engine loaded: $_engine');
    } catch (e) {
      debugPrint('Error loading speech engine preference: $e');
    }
  }

  /// Set the API key service for OpenAI Whisper.
  static void setApiKeyService(ApiKeyService service) {
    _apiKeyService = service;
  }

  /// Refresh the cached API key from secure storage.
  static Future<void> refreshApiKey() async {
    if (_apiKeyService != null) {
      _cachedApiKey = await _apiKeyService!.getOpenAiApiKey();
    }
  }

  /// Set which engine to use for speech recognition.
  static Future<void> setEngine(SpeechRecognitionEngine engine) async {
    _engine = engine;
    debugPrint('Speech recognition engine switched to: $_engine');

    // Persist the preference
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_enginePrefsKey, engine.index);
    } catch (e) {
      debugPrint('Error saving speech engine preference: $e');
    }
  }

  /// Callback for hybrid mode changes (e.g., cloud → local fallback).
  static OnModeChanged? _onHybridModeChanged;

  /// Set callback to be notified when hybrid mode changes.
  static void setHybridModeCallback(OnModeChanged? callback) {
    _onHybridModeChanged = callback;
  }

  /// Create a speech recognition service based on the configured engine.
  static SpeechRecognitionService create() {
    switch (_engine) {
      case SpeechRecognitionEngine.deviceNative:
        return SpeechRecognitionServiceImpl();
      case SpeechRecognitionEngine.whisperLocal:
        return WhisperRecognitionServiceImpl();
      case SpeechRecognitionEngine.openaiWhisper:
        return OpenAIWhisperService(
          getApiKey: () => _cachedApiKey,
        );
      case SpeechRecognitionEngine.hybrid:
        return HybridSpeechRecognitionService(
          cloudService: OpenAIWhisperService(
            getApiKey: () => _cachedApiKey,
          ),
          localService: WhisperRecognitionServiceImpl(),
          onModeChanged: _onHybridModeChanged,
        );
    }
  }

  /// Get the currently configured engine.
  static SpeechRecognitionEngine get currentEngine => _engine;

  /// Check if the current engine requires an API key.
  static bool get requiresApiKey =>
      _engine == SpeechRecognitionEngine.openaiWhisper ||
      _engine == SpeechRecognitionEngine.hybrid;

  /// Check if an API key is configured (for OpenAI engine).
  static Future<bool> isApiKeyConfigured() async {
    if (_apiKeyService == null) return false;
    return await _apiKeyService!.hasOpenAiApiKey();
  }

  /// Get a human-readable name for an engine.
  static String getEngineName(SpeechRecognitionEngine engine) {
    switch (engine) {
      case SpeechRecognitionEngine.deviceNative:
        return 'Device Native (Google/Apple)';
      case SpeechRecognitionEngine.whisperLocal:
        return 'Whisper Local (Offline)';
      case SpeechRecognitionEngine.openaiWhisper:
        return 'OpenAI Whisper (Cloud)';
      case SpeechRecognitionEngine.hybrid:
        return 'Hybrid (Cloud + Offline Fallback)';
    }
  }

  /// Get a description for an engine.
  static String getEngineDescription(SpeechRecognitionEngine engine) {
    switch (engine) {
      case SpeechRecognitionEngine.deviceNative:
        return 'Uses device speech services. Fast, no API key required.';
      case SpeechRecognitionEngine.whisperLocal:
        return 'Offline processing with tiny model. No internet required, lower accuracy.';
      case SpeechRecognitionEngine.openaiWhisper:
        return 'High accuracy cloud transcription. Requires OpenAI API key.';
      case SpeechRecognitionEngine.hybrid:
        return 'Best of both: cloud quality when online, offline fallback when needed.';
    }
  }
}
