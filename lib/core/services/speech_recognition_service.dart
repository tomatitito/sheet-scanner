import 'package:logging/logging.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Abstract interface for speech recognition service
abstract class SpeechRecognitionService {
  /// Initialize the speech recognition service
  /// Returns true if initialization successful
  Future<bool> initialize();

  /// Check if device supports speech recognition
  Future<bool> isAvailable();

  /// Start listening for voice input
  /// Calls [onResult] with partial/final results
  /// Calls [onError] if error occurs
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    String language = 'en_US',
  });

  /// Stop listening and return final result
  Future<void> stopListening();

  /// Cancel listening without returning result
  Future<void> cancelListening();

  /// Check if currently listening
  bool get isListening;

  /// Dispose resources
  Future<void> dispose();
}

/// Implementation of SpeechRecognitionService using speech_to_text package
class SpeechRecognitionServiceImpl implements SpeechRecognitionService {
  final _speechToText = stt.SpeechToText();
  final _logger = Logger('SpeechRecognitionService');

  String? _currentLanguage;
  Function(String)? _onResultCallback;
  Function(String)? _onErrorCallback;

  @override
  bool get isListening => _speechToText.isListening;

  @override
  Future<bool> initialize() async {
    try {
      _logger.info('Initializing speech recognition service');
      final available = await _speechToText.initialize(
        onError: _handleError,
        onStatus: _handleStatus,
        debugLogging: false,
      );

      if (available) {
        _logger.info('Speech recognition initialized successfully');
      } else {
        _logger.warning('Speech recognition not available on this device');
      }

      return available;
    } catch (e) {
      _logger.severe('Failed to initialize speech recognition: $e');
      return false;
    }
  }

  @override
  Future<bool> isAvailable() async {
    try {
      if (!_speechToText.isInitialized) {
        return await initialize();
      }
      return true;
    } catch (e) {
      _logger.warning('Error checking speech availability: $e');
      return false;
    }
  }

  @override
  Future<void> startListening({
    required Function(String) onResult,
    required Function(String) onError,
    String language = 'en_US',
  }) async {
    try {
      if (!_speechToText.isInitialized) {
        _logger.warning('Speech service not initialized, initializing...');
        final initialized = await initialize();
        if (!initialized) {
          onError('Speech recognition not available');
          return;
        }
      }

      _currentLanguage = language;
      _onResultCallback = onResult;
      _onErrorCallback = onError;

      _logger.info('Starting speech recognition with language: $language');

      await _speechToText.listen(
        onResult: _handleResult,
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: language,
        cancelOnError: true,
        listenMode: stt.ListenMode.search,
      );
    } catch (e) {
      _logger.severe('Failed to start listening: $e');
      onError('Failed to start voice input: $e');
    }
  }

  @override
  Future<void> stopListening() async {
    try {
      if (_speechToText.isListening) {
        _logger.info('Stopping speech recognition');
        await _speechToText.stop();
      }
    } catch (e) {
      _logger.severe('Error stopping listener: $e');
    }
  }

  @override
  Future<void> cancelListening() async {
    try {
      if (_speechToText.isListening) {
        _logger.info('Cancelling speech recognition');
        await _speechToText.cancel();
      }
    } catch (e) {
      _logger.severe('Error cancelling listener: $e');
    }
  }

  @override
  Future<void> dispose() async {
    try {
      _logger.info('Disposing speech recognition service');
      await cancelListening();
      // speech_to_text doesn't have explicit dispose, but we clean up callbacks
      _onResultCallback = null;
      _onErrorCallback = null;
    } catch (e) {
      _logger.severe('Error disposing service: $e');
    }
  }

  void _handleResult(stt.SpeechRecognitionResult result) {
    if (_onResultCallback != null) {
      _onResultCallback!(result.recognizedWords);
      _logger.fine('Received speech result: "${result.recognizedWords}" (final: ${result.finalResult})');
    }
  }

  void _handleError(stt.SpeechRecognitionError error) {
    _logger.warning('Speech recognition error: ${error.errorMsg}');
    if (_onErrorCallback != null) {
      _onErrorCallback!(error.errorMsg);
    }
  }

  void _handleStatus(String status) {
    _logger.fine('Speech recognition status: $status');
  }
}
