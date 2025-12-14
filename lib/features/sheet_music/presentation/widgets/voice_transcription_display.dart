import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/dictation_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/dictation_state.dart';

/// Widget that displays real-time transcription during voice input.
///
/// Shows:
/// - Current transcription text
/// - Whether it's partial or final result
/// - Confidence indicator
/// - Elapsed time
class VoiceTranscriptionDisplay extends StatelessWidget {
  /// The cubit managing dictation state
  final DictationCubit cubit;

  /// Callback when final result is available
  final ValueChanged<String>? onFinalResult;

  /// Whether to show the elapsed time
  final bool showTimer;

  /// Whether to show confidence indicator
  final bool showConfidence;

  /// Custom text style for transcription
  final TextStyle? transcriptionStyle;

  /// Custom text style for partial result indicator
  final TextStyle? indicatorStyle;

  const VoiceTranscriptionDisplay({
    super.key,
    required this.cubit,
    this.onFinalResult,
    this.showTimer = true,
    this.showConfidence = true,
    this.transcriptionStyle,
    this.indicatorStyle,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DictationCubit, DictationState>(
      bloc: cubit,
      builder: (context, state) {
        return state.when(
          idle: () => const SizedBox.shrink(),
          listening: (transcription, elapsedTime) {
            return _buildListeningDisplay(
              context,
              transcription,
              elapsedTime,
              isPartial: true,
            );
          },
          partialResult: (text) {
            return _buildListeningDisplay(
              context,
              text,
              Duration.zero,
              isPartial: true,
            );
          },
          processing: (transcription) {
            return _buildProcessingDisplay(context, transcription);
          },
          complete: (finalText, confidence) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              onFinalResult?.call(finalText);
            });
            return _buildCompleteDisplay(context, finalText, confidence);
          },
          error: (failure) {
            return _buildErrorDisplay(context, failure.message);
          },
        );
      },
    );
  }

  Widget _buildListeningDisplay(
    BuildContext context,
    String transcription,
    Duration elapsedTime, {
    required bool isPartial,
  }) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.blue.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  transcription.isEmpty ? 'Listening...' : transcription,
                  style: transcriptionStyle ??
                      Theme.of(context).textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showTimer)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    _formatDuration(elapsedTime),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                ),
            ],
          ),
          if (isPartial && transcription.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '(Partial result)',
                style: indicatorStyle ??
                    Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Colors.blue,
                          fontStyle: FontStyle.italic,
                        ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProcessingDisplay(BuildContext context, String transcription) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Processing: $transcription',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteDisplay(
    BuildContext context,
    String finalText,
    double confidence,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            finalText,
            style: transcriptionStyle ?? Theme.of(context).textTheme.bodyMedium,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          if (showConfidence)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Text(
                    'Confidence: ',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: confidence,
                        minHeight: 4,
                        backgroundColor: Colors.grey.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          confidence > 0.7 ? Colors.green : Colors.orange,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '${(confidence * 100).toStringAsFixed(0)}%',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color:
                                confidence > 0.7 ? Colors.green : Colors.orange,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildErrorDisplay(BuildContext context, String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error: $errorMessage',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                  ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
