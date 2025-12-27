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
      debugPrint('[REPO-TRACE] startVoiceInput called with listenFor=${listenFor.inSeconds}s');
      
      // Check if service is available
      debugPrint('[REPO-TRACE] Checking if service is available...');
      final available = await _speechService.isAvailable();
      if (!available) {
        debugPrint('[REPO-ERROR] Speech recognition not available');
        return Left(
          PlatformFailure(
            message: 'Speech recognition is not available on this device',
            code: 'speech_unavailable',
          ),
        );
      }
      debugPrint('[REPO-TRACE] Service is available');

      // Initialize the service
      debugPrint('[REPO-TRACE] Initializing service...');
      final initialized = await _speechService.initialize();
      if (!initialized) {
        debugPrint('[REPO-ERROR] Failed to initialize service');
        return Left(
          PlatformFailure(
            message: 'Failed to initialize speech recognition',
            code: 'init_failed',
          ),
        );
      }
      debugPrint('[REPO-TRACE] Service initialized');

      // Validate that the requested language is available on the device
      final availableLanguages = await _speechService.availableLanguages;
      final effectiveLanguage = availableLanguages.contains(language)
          ? language
          : 'en_US'; // Fallback to English if language not available

      if (effectiveLanguage != language) {
        debugPrint(
          'Requested language "$language" not available on device. '
          'Available languages: $availableLanguages. Using "$effectiveLanguage" instead.',
        );
      }

      // Create a completer for this listening session
      debugPrint('[REPO-TRACE] Creating new completer for listening session');
      _listenCompleter = Completer<DictationResult>();

      // Clear previous result
      _finalText = '';
      final startTime = DateTime.now();

      // Start listening
      debugPrint('[REPO-TRACE] Calling _speechService.startListening()...');
      final listenStartTime = DateTime.now();
      await _speechService.startListening(
        onResult: (String text, bool isFinal) {
          debugPrint('[REPO-TRACE] onResult callback: text="$text", isFinal=$isFinal');
          if (isFinal) {
            _finalText = text;
            debugPrint('[REPO-TRACE] isFinal=true, completing completer with text="$text"');
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
          debugPrint('[REPO-ERROR] onError callback: error="$error"');
          if (_listenCompleter != null && !_listenCompleter!.isCompleted) {
            _listenCompleter!.completeError(
              Exception('Speech recognition error: $error'),
            );
          }
        },
        language: effectiveLanguage,
        listenFor: listenFor,
      );
      final listenStartDuration = DateTime.now().difference(listenStartTime);
      debugPrint('[REPO-TRACE] _speechService.startListening() returned after ${listenStartDuration.inMilliseconds}ms');

      // Wait for the listening session to complete or timeout
      // CRITICAL: The timeout must account for BOTH listening AND Whisper transcription time.
      // Whisper transcription can take 1-5 minutes depending on audio length and device.
      // The service layer has its own timeouts (8s for recording, 2min for transcription).
      // We use a very long timeout here (5 minutes) to allow transcription to complete normally.
      debugPrint('[REPO-TRACE] Awaiting completer future with timeout 5 minutes (for listening + transcription)...');
      final timeoutDuration = const Duration(minutes: 5);
      final awaitStartTime = DateTime.now();
      final result = await _listenCompleter!.future.timeout(
        timeoutDuration,
        onTimeout: () {
          debugPrint('[REPO-TRACE] Timeout fired after 5 minutes - operation still pending');
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
      final awaitDuration = DateTime.now().difference(awaitStartTime);
      debugPrint('[REPO-TRACE] Completer future resolved after ${awaitDuration.inSeconds}s, text="${result.text}"');

      return Right(result);
    } on Exception catch (e) {
      debugPrint('[REPO-ERROR] Exception during voice input: $e');
      debugPrint('[REPO-STACK] Stack trace: ${StackTrace.current}');
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
