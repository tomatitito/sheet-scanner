import 'package:freezed_annotation/freezed_annotation.dart';

part 'dictation_result.freezed.dart';

/// Represents the result of a voice dictation session.
///
/// Contains the transcribed text, confidence level, finality status,
/// and duration of the recording.
@freezed
class DictationResult with _$DictationResult {
  const factory DictationResult({
    /// The transcribed text from speech recognition.
    required String text,

    /// Confidence level of the recognition (0.0 - 1.0).
    /// Higher values indicate greater confidence.
    @Default(0.0) double confidence,

    /// Whether this is the final result or a partial result.
    /// Partial results are shown during listening, final when stopped.
    @Default(false) bool isFinal,

    /// Duration of the voice input/recording.
    @Default(Duration.zero) Duration duration,
  }) = _DictationResult;
}
