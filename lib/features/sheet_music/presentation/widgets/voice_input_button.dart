import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/core/di/injection.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/dictation_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/dictation_state.dart';

/// Voice input button widget that triggers dictation for a text field.
///
/// Features:
/// - Animated microphone icon during recording
/// - Real-time transcription display
/// - Recording duration timer
/// - Visual feedback with color changes
/// - Confidence indicator
class VoiceInputButton extends StatefulWidget {
  /// Callback when dictation completes with final text
  final ValueChanged<String> onDictationComplete;

  /// Callback when dictation is cancelled
  final VoidCallback? onDictationCancelled;

  /// Callback when an error occurs
  final ValueChanged<String>? onError;

  /// Language code for voice recognition (default: en_US)
  final String language;

  /// Button tooltip
  final String tooltip;

  /// Button size
  final double size;

  /// Button color when idle
  final Color idleColor;

  /// Button color when listening
  final Color listeningColor;

  /// Whether to show confidence score
  final bool showConfidence;

  const VoiceInputButton({
    super.key,
    required this.onDictationComplete,
    this.onDictationCancelled,
    this.onError,
    this.language = 'en_US',
    this.tooltip = 'Tap to start voice input, tap again to stop',
    this.size = 48.0,
    this.idleColor = Colors.blue,
    this.listeningColor = Colors.red,
    this.showConfidence = true,
  });

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late DictationCubit _cubit;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _cubit = getIt<DictationCubit>();

    // Setup animation controller for microphone pulse effect
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleVoiceInput() {
    if (_isListening) {
      _cubit.stopDictation();
    } else {
      // Always use the current language from the cubit, which is the properly mapped
      // device locale from LanguageSelector
      final languageToUse = _cubit.currentLanguage;
      _cubit.startDictation(language: languageToUse);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      onKeyEvent: (node, event) {
        // Support Space key for voice activation (standard accessibility pattern)
        if (event.logicalKey == LogicalKeyboardKey.space &&
            event is KeyDownEvent) {
          _handleVoiceInput();
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: BlocListener<DictationCubit, DictationState>(
        bloc: _cubit,
        listener: (context, state) {
          state.when(
            idle: () {
              setState(() => _isListening = false);
              widget.onDictationCancelled?.call();
            },
            listening: (_, __) {
              setState(() => _isListening = true);
            },
            partialResult: (text) {
              // Optional: Show partial results in real-time
            },
            processing: (transcription) {
              // Processing state
            },
            complete: (finalText, confidence) {
              setState(() => _isListening = false);
              widget.onDictationComplete(finalText);
            },
            error: (failure) {
              setState(() => _isListening = false);
              widget.onError?.call(failure.message);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dictation error: ${failure.message}'),
                  backgroundColor: Colors.red,
                ),
              );
            },
          );
        },
        child: BlocBuilder<DictationCubit, DictationState>(
          bloc: _cubit,
          builder: (context, state) {
            return Tooltip(
              message: widget.tooltip,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildButton(context, state),
                  // Show real-time transcription, timer, and cancel button during listening
                  if (_isListening)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildListeningIndicator(state),
                          const SizedBox(height: 12),
                          _buildCancelButton(),
                        ],
                      ),
                    ),
                  // Show confidence after completion
                  if (state.maybeWhen(
                        complete: (_, __) => true,
                        orElse: () => false,
                      ) &&
                      widget.showConfidence)
                    state.maybeWhen(
                      complete: (finalText, confidence) => Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
                          style:
                              Theme.of(context).textTheme.labelSmall?.copyWith(
                                    color: confidence > 0.7
                                        ? Colors.green
                                        : Colors.orange,
                                  ),
                        ),
                      ),
                      orElse: () => const SizedBox.shrink(),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, DictationState state) {
    final isListening = state.maybeWhen(
      listening: (_, __) => true,
      orElse: () => false,
    );
    final isProcessing = state.maybeWhen(
      processing: (_) => true,
      orElse: () => false,
    );

    final semanticLabel = isListening
        ? 'Stop recording by tapping the microphone button again'
        : 'Start voice recording by tapping the microphone button';

    return Semantics(
      button: true,
      enabled: true,
      label: semanticLabel,
      onTap: _handleVoiceInput,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            if (isListening)
              BoxShadow(
                color: widget.listeningColor.withValues(alpha: 0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleVoiceInput,
            customBorder: const CircleBorder(),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ScaleTransition(
                scale: isListening
                    ? Tween<double>(begin: 1.0, end: 1.2)
                        .animate(_animationController)
                    : const AlwaysStoppedAnimation(1.0),
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isListening || isProcessing
                        ? widget.listeningColor
                        : widget.idleColor,
                  ),
                  child: Center(
                    child: isProcessing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            isListening ? Icons.mic : Icons.mic_none,
                            color: Colors.white,
                            size: widget.size * 0.5,
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton() {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: _cubit.cancelDictation,
        icon: const Icon(Icons.close, size: 18),
        label: const Text('Cancel'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          textStyle: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }

  Widget _buildListeningIndicator(DictationState state) {
    return state.maybeWhen(
      listening: (transcription, elapsedTime) {
        final seconds = elapsedTime.inSeconds;
        final minutes = seconds ~/ 60;
        final displaySeconds = seconds % 60;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Timer
            Text(
              '${minutes.toString().padLeft(2, '0')}:${displaySeconds.toString().padLeft(2, '0')}',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: widget.listeningColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            // Waveform animation
            SizedBox(
              height: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  4,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.3, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(
                            index * 0.1,
                            (index + 1) * 0.1 + 0.6,
                          ),
                        ),
                      ),
                      child: Container(
                        width: 2,
                        height: 16,
                        decoration: BoxDecoration(
                          color: widget.listeningColor,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }
}
