import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/dictation_result.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/speech_recognition_repository.dart';

/// Parameters for the TranscribeVoiceUseCase.
class TranscribeVoiceParams {
  /// Language/locale for speech recognition (e.g., 'en_US', 'es_ES').
  final String language;

  /// Duration to listen for speech before auto-stopping.
  final Duration listenFor;

  TranscribeVoiceParams({
    this.language = 'en_US',
    this.listenFor = const Duration(minutes: 1),
  });
}

/// Use case for transcribing voice input to text.
///
/// Handles the business logic of initiating voice input and returning
/// the transcribed result.
class TranscribeVoiceUseCase {
  final SpeechRecognitionRepository _repository;

  TranscribeVoiceUseCase({required SpeechRecognitionRepository repository})
      : _repository = repository;

  /// Start voice transcription and return the result.
  ///
  /// Returns Either a Failure or a DictationResult with the transcribed text.
  Future<Either<Failure, DictationResult>> call(TranscribeVoiceParams params) {
    return _repository.startVoiceInput(
      language: params.language,
      listenFor: params.listenFor,
    );
  }
}
