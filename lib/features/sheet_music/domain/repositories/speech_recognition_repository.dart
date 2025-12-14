import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/dictation_result.dart';

/// Repository for speech recognition operations.
///
/// Handles voice input and transcription.
abstract class SpeechRecognitionRepository {
  /// Start voice input and return the transcribed result.
  ///
  /// Returns Either a Failure (if something went wrong) or a DictationResult
  /// containing the recognized text.
  Future<Either<Failure, DictationResult>> startVoiceInput({
    String language = 'en_US',
    Duration listenFor = const Duration(minutes: 1),
  });

  /// Stop the current voice input session.
  Future<Either<Failure, void>> stopVoiceInput();

  /// Cancel the current voice input session.
  Future<Either<Failure, void>> cancelVoiceInput();

  /// Check if voice input is available on this device.
  Future<bool> isVoiceInputAvailable();
}
