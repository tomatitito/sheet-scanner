import 'package:flutter/foundation.dart';

import 'speech_recognition_service.dart';
import 'whisper_service.dart';

/// Enum to specify which speech recognition engine to use.
enum SpeechRecognitionEngine {
  /// Traditional speech_to_text with device APIs (Google Speech, Apple Speech)
  deviceNative,

  /// OpenAI's Whisper (offline, more accurate)
  whisper,
}

/// Factory for creating speech recognition service instances.
///
/// Provides abstraction to support both traditional speech_to_text
/// and Whisper-based implementations with a simple configuration toggle.
class SpeechRecognitionServiceFactory {
  static SpeechRecognitionEngine _engine = SpeechRecognitionEngine.whisper;

  /// Set which engine to use for speech recognition.
  static void setEngine(SpeechRecognitionEngine engine) {
    _engine = engine;
    debugPrint('Speech recognition engine switched to: $_engine');
  }

  /// Create a speech recognition service based on the configured engine.
  static SpeechRecognitionService create() {
    switch (_engine) {
      case SpeechRecognitionEngine.deviceNative:
        return SpeechRecognitionServiceImpl();
      case SpeechRecognitionEngine.whisper:
        return WhisperRecognitionServiceImpl();
    }
  }

  /// Get the currently configured engine.
  static SpeechRecognitionEngine get currentEngine => _engine;
}
