import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

import 'speech_recognition_service.dart';

/// Implementation of speech recognition using OpenAI's Whisper model.
///
/// Works offline using whisper.cpp for improved accuracy on short phrases
/// and technical terms (like music metadata).
///
/// Note: This implementation serves as a foundation for Whisper integration.
/// Recording is currently delegated to platform-specific implementations or
/// future integration with a stable audio recording package.
class WhisperRecognitionServiceImpl implements SpeechRecognitionService {
  late final Whisper _whisper;
  bool _isListening = false;

  WhisperRecognitionServiceImpl() {
    _whisper = const Whisper(
      model: WhisperModel.base, // Balance between accuracy and size
      downloadHost: 'https://huggingface.co/ggerganov/whisper.cpp/resolve/main',
    );
  }

  @override
  Future<bool> initialize() async {
    try {
      // Check if Whisper is available
      final version = await _whisper.getVersion();
      debugPrint('Whisper version: $version');
      return true;
    } catch (e) {
      debugPrint('Error initializing Whisper: $e');
      return false;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // Check microphone permission
      final micStatus = await Permission.microphone.request();
      if (micStatus.isDenied) {
        debugPrint('Microphone permission denied by user');
        return false;
      } else if (micStatus.isPermanentlyDenied) {
        debugPrint('Microphone permission permanently denied');
        return false;
      }
      return true;
    } catch (e) {
      debugPrint('Error checking Whisper availability: $e');
      return false;
    }
  }

  @override
  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    required Function(String error) onError,
    String language = 'en_US',
    Duration listenFor = const Duration(seconds: 30),
  }) async {
    try {
      // Verify availability before attempting to listen
      if (!await isAvailable()) {
        onError('Microphone permission not granted');
        return;
      }

      _isListening = true;

      // Emit listening started event
      onResult('', false);

      // For now, we emit an error indicating that Whisper needs audio input
      // In production, this would integrate with a stable audio recording package
      // or use platform channels for native audio recording
      onError(
        'Whisper engine requires audio file input. '
        'Please use device native speech recognition for now.',
      );

      _isListening = false;
    } catch (e) {
      debugPrint('Error during Whisper listening: $e');
      onError('Whisper error: ${e.toString()}');
      _isListening = false;
    }
  }

  @override
  Future<String?> stopListening() async {
    try {
      if (!_isListening) {
        return null;
      }

      _isListening = false;
      return null;
    } catch (e) {
      debugPrint('Error stopping Whisper listening: $e');
      return null;
    }
  }

  @override
  Future<void> cancelListening() async {
    try {
      _isListening = false;
    } catch (e) {
      debugPrint('Error canceling Whisper listening: $e');
    }
  }

  @override
  bool get isListening => _isListening;

  @override
  Future<List<String>> get availableLanguages async {
    // Whisper supports 99 languages, but we'll return common ones
    return [
      'en_US', // English
      'es_ES', // Spanish
      'fr_FR', // French
      'de_DE', // German
      'it_IT', // Italian
      'pt_BR', // Portuguese
      'ja_JP', // Japanese
      'zh_CN', // Chinese Simplified
      'zh_TW', // Chinese Traditional
    ];
  }

  /// Transcribe an audio file using Whisper.
  ///
  /// This method can be called directly when you have an audio file path
  /// (e.g., from native recording or other sources).
  Future<String> transcribeAudioFile(String audioPath) async {
    try {
      final result = await _whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: audioPath,
          isTranslate: false,
          isNoTimestamps: true,
        ),
      );

      debugPrint('Whisper result: ${result.text}');
      return result.text.trim();
    } catch (e) {
      debugPrint('Error transcribing audio: $e');
      rethrow;
    }
  }
}
