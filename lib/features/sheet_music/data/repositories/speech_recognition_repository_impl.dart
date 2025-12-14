import 'package:logging/logging.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/services/speech_recognition_service.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/dictation_result.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/speech_recognition_repository.dart';

/// Implementation of SpeechRecognitionRepository
class SpeechRecognitionRepositoryImpl implements SpeechRecognitionRepository {
  final SpeechRecognitionService _speechService;
  final _logger = Logger('SpeechRecognitionRepository');

  String _currentTranscription = '';
  DateTime? _startTime;
  final _resultsController = <Either<Failure, DictationResult>>[];

  SpeechRecognitionRepositoryImpl({required SpeechRecognitionService speechService})
      : _speechService = speechService;

  @override
  Future<Either<Failure, bool>> isAvailable() async {
    try {
      final available = await _speechService.isAvailable();
      return Right(available);
    } catch (e) {
      _logger.severe('Error checking voice availability: $e');
      return Left(PlatformFailure(message: 'Could not check voice availability: $e'));
    }
  }

  @override
  Stream<Either<Failure, DictationResult>> startVoiceInput({
    required String language,
  }) {
    _currentTranscription = '';
    _startTime = DateTime.now();

    return Stream.create((sink) {
      _speechService.startListening(
        onResult: (result) {
          _currentTranscription = result;
          final duration = DateTime.now().difference(_startTime!);

          final dictationResult = DictationResult(
            text: result,
            confidence: 0.8, // speech_to_text doesn't provide confidence, using default
            isFinal: false,
            duration: duration,
          );

          sink.add(Right(dictationResult));
          _logger.fine('Streaming transcription result: $result');
        },
        onError: (error) {
          _logger.warning('Voice input error: $error');
          sink.addError(Left(PlatformFailure(message: error)));
        },
        language: language,
      ).catchError((e) {
        _logger.severe('Error starting voice input: $e');
        sink.addError(Left(PlatformFailure(message: 'Failed to start voice input: $e')));
      });
    });
  }

  @override
  Future<Either<Failure, DictationResult>> stopVoiceInput() async {
    try {
      await _speechService.stopListening();

      final duration = _startTime != null
          ? DateTime.now().difference(_startTime!)
          : Duration.zero;

      final finalResult = DictationResult(
        text: _currentTranscription,
        confidence: 0.8,
        isFinal: true,
        duration: duration,
      );

      _logger.info('Voice input stopped. Final text: "$_currentTranscription"');
      return Right(finalResult);
    } catch (e) {
      _logger.severe('Error stopping voice input: $e');
      return Left(PlatformFailure(message: 'Failed to stop voice input: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelVoiceInput() async {
    try {
      await _speechService.cancelListening();
      _currentTranscription = '';
      _startTime = null;
      _logger.info('Voice input cancelled');
      return const Right(null);
    } catch (e) {
      _logger.severe('Error cancelling voice input: $e');
      return Left(PlatformFailure(message: 'Failed to cancel voice input: $e'));
    }
  }
}
