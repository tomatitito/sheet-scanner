import 'package:freezed_annotation/freezed_annotation.dart';

part 'dictation_state.freezed.dart';

/// State for voice dictation operations
@freezed
class DictationState with _$DictationState {
  /// Initial idle state
  const factory DictationState.idle() = _Idle;

  /// Currently listening/recording voice input
  const factory DictationState.listening({
    required String currentTranscription,
    required Duration elapsedTime,
  }) = _Listening;

  /// Processing voice input (after user stops talking)
  const factory DictationState.processing({
    required String transcription,
  }) = _Processing;

  /// Voice dictation completed successfully
  const factory DictationState.complete({
    required String finalText,
    required double confidence,
  }) = _Complete;

  /// Error occurred during voice input
  const factory DictationState.error({
    required String message,
  }) = _Error;
}
