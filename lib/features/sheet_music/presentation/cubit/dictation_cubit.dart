import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/transcribe_voice_use_case.dart';
import 'dictation_state.dart';

/// Cubit for managing voice dictation state and operations.
///
/// Handles:
/// - Starting/stopping voice input
/// - Emitting state changes during transcription
/// - Error handling
/// - Timeout management
class DictationCubit extends Cubit<DictationState> {
  final TranscribeVoiceUseCase _transcribeVoiceUseCase;

  /// Timer for tracking elapsed time during listening.
  Timer? _elapsedTimer;

  /// Start time of the current listening session.
  DateTime? _listeningStartTime;

  /// Current language/locale for voice recognition.
  String _currentLanguage = 'en_US';

  /// Map of user-friendly language names to their actual locale IDs
  /// This is populated from the device's available locales
  final Map<String, String> _languageLocaleMap = {};

  /// Flag to indicate if a cancellation was requested while listening
  bool _cancelRequested = false;

  DictationCubit({required TranscribeVoiceUseCase transcribeVoiceUseCase})
      : _transcribeVoiceUseCase = transcribeVoiceUseCase,
        super(const DictationState.idle());

  /// Start voice dictation for the specified field.
  ///
  /// Emits listening state and then either a complete state with the result
  /// or an error state if something goes wrong.
  /// Can be cancelled by calling [cancelDictation].
  Future<void> startDictation({
    String language = 'en_US',
    Duration listenFor = const Duration(seconds: 30),
  }) async {
    debugPrint('[CUBIT-TRACE] startDictation called with listenFor=${listenFor.inSeconds}s, language=$language');
    
    // If already listening, ignore
    final isListening = state.whenOrNull(
          listening: (_, __) => true,
        ) ??
        false;
    if (isListening) {
      debugPrint('[CUBIT-WARN] Already listening, ignoring startDictation call');
      return;
    }

    _cancelRequested = false;
    _currentLanguage = language;
    _listeningStartTime = DateTime.now();

    // Emit listening state
    debugPrint('[CUBIT-TRACE] Emitting listening state');
    emit(const DictationState.listening(
      currentTranscription: '',
      elapsedTime: Duration.zero,
    ));

    // Start elapsed time timer
    _startElapsedTimer();

    // Start voice transcription
    debugPrint('[CUBIT-TRACE] Calling _transcribeVoiceUseCase.call()...');
    final useCaseStartTime = DateTime.now();
    final params = TranscribeVoiceParams(
      language: language,
      listenFor: listenFor,
    );

    final result = await _transcribeVoiceUseCase.call(params);
    final useCaseDuration = DateTime.now().difference(useCaseStartTime);
    debugPrint('[CUBIT-TRACE] _transcribeVoiceUseCase.call() returned after ${useCaseDuration.inSeconds}s');

    // Stop the elapsed timer
    _stopElapsedTimer();

    // If cancellation was requested, don't emit a result
    if (_cancelRequested) {
      debugPrint('[CUBIT-TRACE] Cancellation was requested, returning without emitting result');
      _cancelRequested = false;
      return;
    }

    result.fold(
      (failure) {
        debugPrint('[CUBIT-ERROR] Got failure result: ${failure.userMessage}');
        emit(DictationState.error(failure: failure));
      },
      (dictationResult) {
        debugPrint('[CUBIT-TRACE] Got success result: "${dictationResult.text}"');
        emit(DictationState.complete(
          finalText: dictationResult.text,
          confidence: dictationResult.confidence,
        ));
      },
    );
  }

  /// Stop the current listening session and return the result.
  ///
  /// Called when the user manually stops the recording.
  Future<void> stopDictation() async {
    final isListening = state.whenOrNull(
          listening: (_, __) => true,
        ) ??
        false;
    if (!isListening) {
      return;
    }

    // Stop elapsed timer
    _stopElapsedTimer();

    // Emit processing state
    emit(const DictationState.processing(transcription: ''));

    // In a real implementation, this would stop the actual listening.
    // For now, the use case handles the timing out and returning results.
  }

  /// Cancel the current dictation session.
  ///
  /// Stops listening immediately and returns to idle state.
  /// If called during listening, the transcription will be discarded.
  Future<void> cancelDictation() async {
    _stopElapsedTimer();
    _listeningStartTime = null;
    _cancelRequested = true;

    // Emit idle state
    emit(const DictationState.idle());
  }

  /// Clear the transcription text and return to idle state.
  void clearTranscription() {
    emit(const DictationState.idle());
  }

  /// Update the current transcription text (for partial results).
  ///
  /// Called when a partial result is received during listening.
  void updatePartialResult(String text) {
    final isListening = state.whenOrNull(
          listening: (_, __) => true,
        ) ??
        false;
    if (isListening) {
      emit(DictationState.partialResult(text: text));
    }
  }

  /// Initialize language mapping from service.
  /// This should be called when the app starts to populate available locales.
  Future<void> initializeAvailableLanguages(
    List<String> availableLocaleIds,
  ) async {
    _languageLocaleMap.clear();

    // Create a normalized mapping for common languages
    // Key: user-facing language code (e.g., 'de', 'de_DE')
    // Value: actual device locale ID (e.g., 'de-DE', 'de')
    for (final localeId in availableLocaleIds) {
      // Store the exact locale ID from the device
      _languageLocaleMap[localeId] = localeId;

      // Also store common variants for easier lookup
      final parts = localeId.split(RegExp(r'[-_]'));
      if (parts.isNotEmpty) {
        final languageCode = parts[0].toLowerCase();
        // Store language code variant (e.g., 'de' -> 'de_DE')
        if (!_languageLocaleMap.containsKey(languageCode)) {
          _languageLocaleMap[languageCode] = localeId;
        }
      }
    }

    // If German is available, make sure common variants point to it
    _ensureLanguageVariantsAreMapped('de');
    _ensureLanguageVariantsAreMapped('en');
    _ensureLanguageVariantsAreMapped('es');
    _ensureLanguageVariantsAreMapped('fr');
  }

  /// Helper to ensure language variants (e.g., 'de', 'de_DE', 'de-DE') all map to available locale
  void _ensureLanguageVariantsAreMapped(String languageCode) {
    // Find the actual locale ID for this language if it exists
    String? actualLocaleId;
    for (final entry in _languageLocaleMap.entries) {
      if (entry.key.toLowerCase().startsWith(languageCode.toLowerCase())) {
        actualLocaleId = entry.value;
        break;
      }
    }

    if (actualLocaleId != null) {
      // Map all variants to the actual locale ID
      _languageLocaleMap[languageCode] = actualLocaleId;
      _languageLocaleMap['${languageCode}_${languageCode.toUpperCase()}'] =
          actualLocaleId;
      final hyphenated = '$languageCode-${languageCode.toUpperCase()}';
      _languageLocaleMap[hyphenated] = actualLocaleId;
    }
  }

  /// Set the language/locale for voice recognition.
  /// [language] can be a language code like 'de', 'en_US', 'de-DE', etc.
  /// The method will find the actual device locale that matches this language.
  void setLanguage(String language) {
    // Try direct match first
    if (_languageLocaleMap.containsKey(language)) {
      _currentLanguage = _languageLocaleMap[language]!;
      return;
    }

    // Try to find a matching language variant
    final normalizedLanguage = language.toLowerCase();
    for (final entry in _languageLocaleMap.entries) {
      if (entry.key.toLowerCase() == normalizedLanguage ||
          entry.key.toLowerCase().startsWith(normalizedLanguage)) {
        _currentLanguage = entry.value;
        return;
      }
    }

    // Fallback to the original language code
    // (the service will handle validation)
    _currentLanguage = language;
  }

  /// Get the current language/locale.
  String get currentLanguage => _currentLanguage;

  /// Get all available language codes mapped from the device.
  Map<String, String> get availableLanguages =>
      Map.unmodifiable(_languageLocaleMap);

  /// Start the timer that tracks elapsed listening time.
  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_listeningStartTime != null) {
        final elapsed = DateTime.now().difference(_listeningStartTime!);
        state.whenOrNull(
          listening: (currentTranscription, _) {
            emit(DictationState.listening(
              currentTranscription: currentTranscription,
              elapsedTime: elapsed,
            ));
            return null;
          },
        );
      }
    });
  }

  /// Stop the elapsed time timer.
  void _stopElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = null;
  }

  @override
  Future<void> close() {
    _stopElapsedTimer();
    return super.close();
  }
}
