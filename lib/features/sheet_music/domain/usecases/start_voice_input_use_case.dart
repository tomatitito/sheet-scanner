import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/dictation_result.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/speech_recognition_repository.dart';

/// Parameters for starting voice input
class StartVoiceInputParams {
  final String language;

  StartVoiceInputParams({
    this.language = 'en_US',
  });
}

/// Use case for starting voice input and recording
class StartVoiceInputUseCase {
  final SpeechRecognitionRepository repository;

  StartVoiceInputUseCase({required this.repository});

  /// Start voice recording, returning a stream of transcription results
  Stream<Either<Failure, DictationResult>> call(StartVoiceInputParams params) {
    return repository.startVoiceInput(language: params.language);
  }
}

/// Use case for stopping voice input
class StopVoiceInputUseCase {
  final SpeechRecognitionRepository repository;

  StopVoiceInputUseCase({required this.repository});

  Future<Either<Failure, DictationResult>> call() {
    return repository.stopVoiceInput();
  }
}

/// Use case for cancelling voice input
class CancelVoiceInputUseCase {
  final SpeechRecognitionRepository repository;

  CancelVoiceInputUseCase({required this.repository});

  Future<Either<Failure, void>> call() {
    return repository.cancelVoiceInput();
  }
}

/// Use case for checking voice availability
class CheckVoiceAvailabilityUseCase {
  final SpeechRecognitionRepository repository;

  CheckVoiceAvailabilityUseCase({required this.repository});

  Future<Either<Failure, bool>> call() {
    return repository.isAvailable();
  }
}
