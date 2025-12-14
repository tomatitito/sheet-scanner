import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/start_voice_input_use_case.dart';
import 'dictation_state.dart';

/// Cubit for managing voice dictation state and operations
class DictationCubit extends Cubit<DictationState> {
  final StartVoiceInputUseCase _startVoiceInputUseCase;
  final StopVoiceInputUseCase _stopVoiceInputUseCase;
  final CancelVoiceInputUseCase _cancelVoiceInputUseCase;
  final CheckVoiceAvailabilityUseCase _checkVoiceAvailabilityUseCase;

  final _logger = Logger('DictationCubit');
  StreamSubscription? _voiceInputSubscription;
  DateTime? _recordingStartTime;

  DictationCubit({
    required StartVoiceInputUseCase startVoiceInputUseCase,
    required StopVoiceInputUseCase stopVoiceInputUseCase,
    required CancelVoiceInputUseCase cancelVoiceInputUseCase,
    required CheckVoiceAvailabilityUseCase checkVoiceAvailabilityUseCase,
  })  : _startVoiceInputUseCase = startVoiceInputUseCase,
        _stopVoiceInputUseCase = stopVoiceInputUseCase,
        _cancelVoiceInputUseCase = cancelVoiceInputUseCase,
        _checkVoiceAvailabilityUseCase = checkVoiceAvailabilityUseCase,
        super(const DictationState.idle());

  /// Start voice recording for the given field
  Future<void> startDictation({String language = 'en_US'}) async {
    _logger.info('Starting voice dictation');
    
    // Check availability first
    final availabilityResult = await _checkVoiceAvailabilityUseCase();
    
    final isAvailable = availabilityResult.fold(
      (failure) {
        emit(DictationState.error(message: failure.message));
        return false;
      },
      (available) => available,
    );

    if (!isAvailable) {
      _logger.warning('Voice recognition not available');
      emit(const DictationState.error(
        message: 'Voice recognition is not available on this device',
      ));
      return;
    }

    try {
      _recordingStartTime = DateTime.now();
      
      // Start voice input and listen to results
      final voiceStream = _startVoiceInputUseCase(
        StartVoiceInputParams(language: language),
      );

      _voiceInputSubscription?.cancel();
      _voiceInputSubscription = voiceStream.listen(
        (result) {
          result.fold(
            (failure) {
              _logger.warning('Voice input failure: ${failure.message}');
              emit(DictationState.error(message: failure.message));
            },
            (dictationResult) {
              final elapsedTime = DateTime.now().difference(_recordingStartTime!);
              emit(DictationState.listening(
                currentTranscription: dictationResult.text,
                elapsedTime: elapsedTime,
              ));
            },
          );
        },
        onError: (error) {
          _logger.severe('Voice input stream error: $error');
          emit(DictationState.error(message: 'Error during voice input: $error'));
        },
      );
    } catch (e) {
      _logger.severe('Error starting dictation: $e');
      emit(DictationState.error(message: 'Failed to start voice input: $e'));
    }
  }

  /// Stop voice recording and return transcribed text
  Future<void> stopDictation() async {
    _logger.info('Stopping voice dictation');
    
    try {
      await _voiceInputSubscription?.cancel();
      _voiceInputSubscription = null;

      final result = await _stopVoiceInputUseCase();

      result.fold(
        (failure) {
          _logger.warning('Error stopping dictation: ${failure.message}');
          emit(DictationState.error(message: failure.message));
        },
        (dictationResult) {
          _logger.info('Voice dictation completed. Text: "${dictationResult.text}"');
          emit(DictationState.complete(
            finalText: dictationResult.text,
            confidence: dictationResult.confidence,
          ));
        },
      );
    } catch (e) {
      _logger.severe('Error in stopDictation: $e');
      emit(DictationState.error(message: 'Failed to process voice input: $e'));
    }
  }

  /// Cancel voice recording without saving
  Future<void> cancelDictation() async {
    _logger.info('Cancelling voice dictation');
    
    try {
      await _voiceInputSubscription?.cancel();
      _voiceInputSubscription = null;

      await _cancelVoiceInputUseCase();
      
      emit(const DictationState.idle());
    } catch (e) {
      _logger.severe('Error cancelling dictation: $e');
      emit(DictationState.error(message: 'Failed to cancel voice input: $e'));
    }
  }

  /// Clear transcription and return to idle state
  void clearTranscription() {
    _logger.info('Clearing transcription');
    emit(const DictationState.idle());
  }

  @override
  Future<void> close() async {
    _logger.info('Closing DictationCubit');
    await _voiceInputSubscription?.cancel();
    return super.close();
  }
}
