import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/services/speech_recognition_service.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/dictation_result.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/speech_recognition_repository.dart';

/// Implementation of the speech recognition repository.
///
/// Handles the coordination between the service layer (speech_to_text)
/// and the domain layer.
class SpeechRecognitionRepositoryImpl implements SpeechRecognitionRepository {
  final SpeechRecognitionService _speechService;

  /// The final text result from the current listening session.
  String _finalText = '';

  /// Completer to handle async operations.
  Completer<DictationResult>? _listenCompleter;

  SpeechRecognitionRepositoryImpl(
      {required SpeechRecognitionService speechService})
      : _speechService = speechService;

  @override
  Future<Either<Failure, DictationResult>> startVoiceInput({
    String language = 'en_US',
    Duration listenFor = const Duration(minutes: 1),
  }) async {
    try {
      // Check if service is available
      final available = await _speechService.isAvailable();
      if (!available) {
        return Left(
          PlatformFailure(
            message: 'Speech recognition is not available on this device',
            code: 'speech_unavailable',
          ),
        );
      }

      // Initialize the service
      final initialized = await _speechService.initialize();
      if (!initialized) {
        return Left(
          PlatformFailure(
            message: 'Failed to initialize speech recognition',
            code: 'init_failed',
          ),
        );
      }

      // Create a completer for this listening session
      _listenCompleter = Completer<DictationResult>();
      String errorMessage = '';

      // Clear previous result
      _finalText = '';
      final startTime = DateTime.now();

      // Start listening
      await _speechService.startListening(
        onResult: (String text, bool isFinal) {
          if (isFinal) {
            _finalText = text;
            // Complete the completer when final result is received
            if (_listenCompleter != null && !_listenCompleter!.isCompleted) {
              _listenCompleter!.complete(
                DictationResult(
                  text: text,
                  confidence: text.isNotEmpty ? 0.95 : 0.0,
                  isFinal: true,
                  duration: DateTime.now().difference(startTime),
                ),
              );
            }
          }
        },
        onError: (String error) {
          errorMessage = error;
          if (_listenCompleter != null && !_listenCompleter!.isCompleted) {
            _listenCompleter!.completeError(
              Exception('Speech recognition error: $error'),
            );
          }
        },
        language: language,
        listenFor: listenFor,
      );

      // Wait for the listening session to complete or timeout
      final timeoutDuration =
          Duration(milliseconds: listenFor.inMilliseconds + 1000);
      final result = await _listenCompleter!.future.timeout(
        timeoutDuration,
        onTimeout: () {
          // Stop listening on timeout
          unawaited(_speechService.stopListening());
          return DictationResult(
            text: _finalText,
            confidence: _finalText.isNotEmpty ? 0.9 : 0.0,
            isFinal: true,
            duration: DateTime.now().difference(startTime),
          );
        },
      );

      return Right(result);
    } on Exception catch (e) {
      return Left(
        GenericFailure(
          message: 'Error during voice input: ${e.toString()}',
          code: 'voice_input_error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> stopVoiceInput() async {
    try {
      final result = await _speechService.stopListening();

      // Complete the listening session
      if (_listenCompleter != null && !_listenCompleter!.isCompleted) {
        _listenCompleter!.complete(
          DictationResult(
            text: result ?? _finalText,
            confidence: _finalText.isNotEmpty ? 0.9 : 0.0,
            isFinal: true,
            duration: const Duration(), // This is handled elsewhere
          ),
        );
      }

      return Right(null);
    } catch (e) {
      return Left(
        GenericFailure(
          message: 'Error stopping voice input: $e',
          code: 'stop_error',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> cancelVoiceInput() async {
    try {
      await _speechService.cancelListening();

      // Cancel the listening session
      if (_listenCompleter != null && !_listenCompleter!.isCompleted) {
        _listenCompleter!.completeError(Exception('Voice input cancelled'));
      }

      _finalText = '';
      return Right(null);
    } catch (e) {
      return Left(
        GenericFailure(
          message: 'Error canceling voice input: $e',
          code: 'cancel_error',
        ),
      );
    }
  }

  @override
  Future<bool> isVoiceInputAvailable() => _speechService.isAvailable();
}
