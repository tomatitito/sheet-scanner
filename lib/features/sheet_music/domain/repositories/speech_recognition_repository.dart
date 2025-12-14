import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/dictation_result.dart';

/// Repository interface for speech recognition operations
abstract class SpeechRecognitionRepository {
  /// Check if speech recognition is available on this device
  Future<Either<Failure, bool>> isAvailable();

  /// Start voice recording and transcription
  /// Streams partial results as user speaks
  Stream<Either<Failure, DictationResult>> startVoiceInput({
    required String language,
  });

  /// Stop the current voice recording
  Future<Either<Failure, DictationResult>> stopVoiceInput();

  /// Cancel the current voice recording
  Future<Either<Failure, void>> cancelVoiceInput();
}
