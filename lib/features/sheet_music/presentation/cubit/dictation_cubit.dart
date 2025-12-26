import 'dart:async';

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

  DictationCubit({required TranscribeVoiceUseCase transcribeVoiceUseCase})
      : _transcribeVoiceUseCase = transcribeVoiceUseCase,
        super(const DictationState.idle());

  /// Start voice dictation for the specified field.
  ///
  /// Emits listening state and then either a complete state with the result
  /// or an error state if something goes wrong.
  Future<void> startDictation({
    String language = 'en_US',
    Duration listenFor = const Duration(seconds: 30),
  }) async {
    // If already listening, ignore
    final isListening = state.whenOrNull(
          listening: (_, __) => true,
        ) ??
        false;
    if (isListening) {
      return;
    }

    _currentLanguage = language;
    _listeningStartTime = DateTime.now();

    // Emit listening state
    emit(const DictationState.listening(
      currentTranscription: '',
      elapsedTime: Duration.zero,
    ));

    // Start elapsed time timer
    _startElapsedTimer();

    // Start voice transcription
    final params = TranscribeVoiceParams(
      language: language,
      listenFor: listenFor,
    );

    final result = await _transcribeVoiceUseCase.call(params);

    // Stop the elapsed timer
    _stopElapsedTimer();

    result.fold(
      (failure) {
        emit(DictationState.error(failure: failure));
      },
      (dictationResult) {
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
  /// Clears the transcription and returns to idle state.
  Future<void> cancelDictation() async {
    _stopElapsedTimer();
    _listeningStartTime = null;

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

  /// Set the language/locale for voice recognition.
  void setLanguage(String language) {
    _currentLanguage = language;
  }

  /// Get the current language/locale.
  String get currentLanguage => _currentLanguage;

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
