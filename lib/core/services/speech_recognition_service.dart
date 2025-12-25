import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Events emitted during speech recognition.
@immutable
abstract class SpeechRecognitionEvent {
  const SpeechRecognitionEvent();
}

/// Emitted when listening starts.
class ListeningStartedEvent extends SpeechRecognitionEvent {
  const ListeningStartedEvent();
}

/// Emitted when a partial result is received during listening.
class PartialResultEvent extends SpeechRecognitionEvent {
  final String text;
  const PartialResultEvent(this.text);
}

/// Emitted when the final result is received.
class FinalResultEvent extends SpeechRecognitionEvent {
  final String text;
  final double confidence;
  const FinalResultEvent(this.text, {this.confidence = 0.0});
}

/// Emitted when an error occurs during speech recognition.
class ErrorEvent extends SpeechRecognitionEvent {
  final String message;
  final String? errorCode;
  const ErrorEvent(this.message, {this.errorCode});
}

/// Emitted when listening stops.
class ListeningStoppedEvent extends SpeechRecognitionEvent {
  const ListeningStoppedEvent();
}

/// Abstract interface for speech recognition service.
///
/// Provides a clean wrapper around the speech_to_text package,
/// handling initialization, permission management, and lifecycle.
abstract class SpeechRecognitionService {
  /// Initialize the speech recognition service.
  ///
  /// Must be called before calling any other methods.
  /// Returns true if initialization succeeded, false otherwise.
  Future<bool> initialize();

  /// Check if speech recognition is available on this device.
  Future<bool> isAvailable();

  /// Start listening for voice input.
  ///
  /// [onResult] is called with partial and final results.
  /// [onError] is called if an error occurs.
  /// [language] specifies the language locale (default: 'en_US').
  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    required Function(String error) onError,
    String language = 'en_US',
    Duration listenFor = const Duration(minutes: 1),
  });

  /// Stop listening without canceling the current session.
  ///
  /// Returns the final recognized text.
  Future<String?> stopListening();

  /// Cancel the current listening session.
  Future<void> cancelListening();

  /// Check if currently listening.
  bool get isListening;

  /// Get available languages on the device.
  Future<List<String>> get availableLanguages;
}

/// Implementation of speech recognition service.
class SpeechRecognitionServiceImpl implements SpeechRecognitionService {
  final _speechToText = SpeechToText();
  String _lastResult = '';

  @override
  Future<bool> initialize() async {
    try {
      // Check if already initialized
      if (_speechToText.isAvailable) {
        return true;
      }

      // Initialize speech to text with error and status callbacks
      final available = await _speechToText.initialize(
        onError: (error) {
          debugPrint('SpeechToText Error: ${error.errorMsg}');
        },
        onStatus: (status) {
          debugPrint('SpeechToText Status: $status');
        },
        debugLogging: kDebugMode,
      );

      return available;
    } catch (e) {
      debugPrint('Error initializing speech recognition: $e');
      return false;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // Check if service is available on this device
      if (!_speechToText.isAvailable) {
        debugPrint(
          'Speech recognition service not available on this device',
        );
        return false;
      }

      // Check microphone permission
      final micStatus = await Permission.microphone.request();
      if (micStatus.isDenied) {
        debugPrint('Microphone permission denied by user');
        return false;
      } else if (micStatus.isPermanentlyDenied) {
        debugPrint(
          'Microphone permission permanently denied. User must enable in settings.',
        );
        return false;
      }
      return micStatus.isGranted;
    } catch (e) {
      debugPrint('Error checking speech availability: $e');
      return false;
    }
  }

  @override
  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    required Function(String error) onError,
    String language = 'en_US',
    Duration listenFor = const Duration(minutes: 1),
  }) async {
    try {
      // Ensure service is initialized
      if (!_speechToText.isAvailable) {
        onError('Speech recognition is not available on this device');
        return;
      }

      // Check microphone permission before listening
      final micStatus = await Permission.microphone.status;
      if (micStatus.isDenied) {
        onError(
          'Microphone permission is required for voice input. Please grant permission in settings.',
        );
        return;
      } else if (micStatus.isPermanentlyDenied) {
        onError(
          'Microphone permission is permanently denied. Please enable it in app settings.',
        );
        return;
      }

      // Clear previous result
      _lastResult = '';

      // Start listening
      await _speechToText.listen(
        onResult: (SpeechRecognitionResult result) {
          _lastResult = result.recognizedWords;
          onResult(_lastResult, result.finalResult);
        },
        localeId: language,
        listenFor: listenFor,
        listenOptions: SpeechListenOptions(
          partialResults: true,
          cancelOnError: false,
        ),
      );
    } catch (e) {
      debugPrint('Error starting speech recognition: $e');
      onError('Failed to start listening: $e');
    }
  }

  @override
  Future<String?> stopListening() async {
    try {
      await _speechToText.stop();
      return _lastResult.isNotEmpty ? _lastResult : null;
    } catch (e) {
      debugPrint('Error stopping speech recognition: $e');
      return null;
    }
  }

  @override
  Future<void> cancelListening() async {
    try {
      await _speechToText.cancel();
      _lastResult = '';
    } catch (e) {
      debugPrint('Error canceling speech recognition: $e');
    }
  }

  @override
  bool get isListening => _speechToText.isListening;

  @override
  Future<List<String>> get availableLanguages async {
    try {
      final locales = await _speechToText.locales();
      return locales.map((locale) => locale.localeId).toList();
    } catch (e) {
      debugPrint('Error getting available languages: $e');
      return ['en_US']; // Default fallback
    }
  }
}
