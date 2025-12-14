import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sheet_scanner/core/error/failures.dart';

part 'dictation_state.freezed.dart';

/// State class for the DictationCubit.
///
/// Represents different states during voice input and transcription.
@freezed
class DictationState with _$DictationState {
  /// Initial idle state, no voice input in progress.
  const factory DictationState.idle() = _Idle;

  /// Currently listening for voice input.
  const factory DictationState.listening({
    required String currentTranscription,
    required Duration elapsedTime,
  }) = _Listening;

  /// Received a partial result while listening.
  const factory DictationState.partialResult({
    required String text,
  }) = _PartialResult;

  /// Received the final result and processing it.
  const factory DictationState.processing({
    required String transcription,
  }) = _Processing;

  /// Voice input completed successfully.
  const factory DictationState.complete({
    required String finalText,
    required double confidence,
  }) = _Complete;

  /// An error occurred during voice input.
  const factory DictationState.error({
    required Failure failure,
  }) = _Error;
}
