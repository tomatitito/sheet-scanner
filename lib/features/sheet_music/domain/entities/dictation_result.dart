/// Result of a voice dictation operation
class DictationResult {
  final String text;
  final double confidence;
  final bool isFinal;
  final Duration duration;

  DictationResult({
    required this.text,
    this.confidence = 0.0,
    this.isFinal = false,
    this.duration = Duration.zero,
  });

  @override
  String toString() =>
      'DictationResult(text: $text, confidence: $confidence, isFinal: $isFinal, duration: $duration)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DictationResult &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          confidence == other.confidence &&
          isFinal == other.isFinal &&
          duration == other.duration;

  @override
  int get hashCode =>
      text.hashCode ^
      confidence.hashCode ^
      isFinal.hashCode ^
      duration.hashCode;
}
