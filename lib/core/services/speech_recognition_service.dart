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

/// Detailed error reason for speech recognition unavailability.
enum SpeechUnavailableReason {
  /// Service/Google Play Services not available on device
  serviceNotAvailable,

  /// Microphone permission not granted by user
  microphonePermissionDenied,

  /// Microphone permission permanently denied - requires app settings
  microphonePermissionPermanentlyDenied,

  /// Manifest permissions missing (AndroidManifest.xml not updated)
  manifestPermissionsMissing,

  /// Unknown error
  unknown,
}

/// Implementation of speech recognition service.
class SpeechRecognitionServiceImpl implements SpeechRecognitionService {
  final _speechToText = SpeechToText();
  String _lastResult = '';
  SpeechUnavailableReason? _lastUnavailableReason;

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

  /// Get a user-friendly error message for why speech recognition is unavailable.
  String getUnavailabilityMessage() {
    return switch (_lastUnavailableReason) {
      SpeechUnavailableReason.serviceNotAvailable =>
        'Google Speech Recognition service is not available on this device. '
        'Please ensure Google Play Services is installed and up to date.',
      SpeechUnavailableReason.microphonePermissionDenied =>
        'Microphone permission is required for voice input. '
        'Please grant the permission when prompted.',
      SpeechUnavailableReason.microphonePermissionPermanentlyDenied =>
        'Microphone permission has been permanently denied. '
        'Please enable it in Settings → Apps → Sheet Scanner → Permissions.',
      SpeechUnavailableReason.manifestPermissionsMissing =>
        'The app requires microphone permissions to be configured. '
        'Please reinstall the app.',
      SpeechUnavailableReason.unknown || null =>
        'Speech recognition is not available. Please check your device settings.',
    };
  }

  @override
  Future<bool> isAvailable() async {
    try {
      // Check if service is available on this device
      if (!_speechToText.isAvailable) {
        debugPrint(
          'Speech recognition service not available on this device',
        );
        _lastUnavailableReason = SpeechUnavailableReason.serviceNotAvailable;
        return false;
      }

      // Check microphone permission
      final micStatus = await Permission.microphone.request();
      if (micStatus.isDenied) {
        debugPrint('Microphone permission denied by user');
        _lastUnavailableReason =
            SpeechUnavailableReason.microphonePermissionDenied;
        return false;
      } else if (micStatus.isPermanentlyDenied) {
        debugPrint(
          'Microphone permission permanently denied. User must enable in settings.',
        );
        _lastUnavailableReason =
            SpeechUnavailableReason.microphonePermissionPermanentlyDenied;
        return false;
      }
      _lastUnavailableReason = null;
      return micStatus.isGranted;
    } catch (e) {
      debugPrint('Error checking speech availability: $e');
      _lastUnavailableReason = SpeechUnavailableReason.unknown;
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
      // Verify availability before attempting to listen
      if (!await isAvailable()) {
        final errorMsg = getUnavailabilityMessage();
        debugPrint('Cannot start listening: $errorMsg');
        onError(errorMsg);
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
      final errorMsg = 'Voice input failed: ${e.toString()}';
      onError(errorMsg);
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
