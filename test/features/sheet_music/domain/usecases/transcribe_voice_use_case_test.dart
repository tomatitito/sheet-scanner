import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/dictation_result.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/speech_recognition_repository.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/transcribe_voice_use_case.dart';

class MockSpeechRecognitionRepository extends Mock
    implements SpeechRecognitionRepository {}

void main() {
  group('TranscribeVoiceUseCase', () {
    late TranscribeVoiceUseCase useCase;
    late MockSpeechRecognitionRepository mockRepository;

    setUp(() {
      mockRepository = MockSpeechRecognitionRepository();
      useCase = TranscribeVoiceUseCase(repository: mockRepository);
    });

    group('call()', () {
      test(
        'returns DictationResult on success',
        () async {
          // GIVEN: Repository returns successful DictationResult
          // WHEN: useCase is called with params
          // THEN: Should return Right with DictationResult

          const expectedResult = DictationResult(
            text: 'hello world',
            confidence: 0.95,
            isFinal: true,
            duration: Duration(seconds: 2),
          );

          when(() => mockRepository.startVoiceInput(
            language: any(named: 'language'),
            listenFor: any(named: 'listenFor'),
          )).thenAnswer((_) async => Right(expectedResult));

          final params = TranscribeVoiceParams(
            language: 'en_US',
            listenFor: const Duration(minutes: 1),
          );

          final result = await useCase.call(params);

          expect(result.isRight(), isTrue);
          result.fold(
            (_) => fail('Should be success'),
            (dictationResult) {
              expect(dictationResult.text, equals('hello world'));
              expect(dictationResult.confidence, equals(0.95));
            },
          );
        },
      );

      test(
        'returns Failure on error',
        () async {
          // GIVEN: Repository returns failure
          // WHEN: useCase is called
          // THEN: Should return Left with Failure

          final failure = SpeechRecognitionFailure(
            message: 'Microphone not available',
          );

          when(() => mockRepository.startVoiceInput(
            language: any(named: 'language'),
            listenFor: any(named: 'listenFor'),
          )).thenAnswer((_) async => Left(failure));

          final params = TranscribeVoiceParams();

          final result = await useCase.call(params);

          expect(result.isLeft(), isTrue);
          result.fold(
            (f) {
              expect(f, isA<SpeechRecognitionFailure>());
              expect(f.message, equals('Microphone not available'));
            },
            (_) => fail('Should be failure'),
          );
        },
      );

      test(
        'passes language parameter to repository',
        () async {
          // GIVEN: TranscribeVoiceParams with language 'es_ES'
          // WHEN: useCase is called
          // THEN: Should pass 'es_ES' to repository

          when(() => mockRepository.startVoiceInput(
            language: 'es_ES',
            listenFor: any(named: 'listenFor'),
          )).thenAnswer(
            (_) async => const Right(
              DictationResult(
                text: 'hola',
                confidence: 0.9,
                isFinal: true,
                duration: Duration(seconds: 1),
              ),
            ),
          );

          final params = TranscribeVoiceParams(language: 'es_ES');

          await useCase.call(params);

          verify(() => mockRepository.startVoiceInput(
            language: 'es_ES',
            listenFor: any(named: 'listenFor'),
          )).called(1);
        },
      );

      test(
        'passes listenFor duration to repository',
        () async {
          // GIVEN: TranscribeVoiceParams with custom listenFor duration
          // WHEN: useCase is called
          // THEN: Should pass duration to repository

          const duration = Duration(seconds: 45);

          when(() => mockRepository.startVoiceInput(
            language: any(named: 'language'),
            listenFor: duration,
          )).thenAnswer(
            (_) async => const Right(
              DictationResult(
                text: 'test',
                confidence: 0.85,
                isFinal: true,
                duration: Duration(seconds: 2),
              ),
            ),
          );

          final params = TranscribeVoiceParams(listenFor: duration);

          await useCase.call(params);

          verify(() => mockRepository.startVoiceInput(
            language: any(named: 'language'),
            listenFor: duration,
          )).called(1);
        },
      );
    });

    group('TranscribeVoiceParams', () {
      test(
        'has correct default values',
        () {
          // GIVEN: TranscribeVoiceParams created with no arguments
          // WHEN: Params are created
          // THEN: Should have default language 'en_US' and 1 minute listen duration

          final params = TranscribeVoiceParams();

          expect(params.language, equals('en_US'));
          expect(params.listenFor, equals(const Duration(minutes: 1)));
        },
      );

      test(
        'can be created with custom language',
        () {
          // GIVEN: Custom language 'fr_FR'
          // WHEN: Params are created with language
          // THEN: Should store the custom language

          final params = TranscribeVoiceParams(language: 'fr_FR');

          expect(params.language, equals('fr_FR'));
        },
      );

      test(
        'can be created with custom listenFor duration',
        () {
          // GIVEN: Custom duration of 30 seconds
          // WHEN: Params are created with listenFor
          // THEN: Should store the custom duration

          const duration = Duration(seconds: 30);
          final params = TranscribeVoiceParams(listenFor: duration);

          expect(params.listenFor, equals(duration));
        },
      );

      test(
        'can be created with both custom language and duration',
        () {
          // GIVEN: Custom language and duration
          // WHEN: Params are created with both
          // THEN: Should store both values

          const duration = Duration(seconds: 60);
          final params = TranscribeVoiceParams(
            language: 'de_DE',
            listenFor: duration,
          );

          expect(params.language, equals('de_DE'));
          expect(params.listenFor, equals(duration));
        },
      );
    });

    group('error scenarios', () {
      test(
        'handles repository throwing exception',
        () async {
          // GIVEN: Repository throws exception
          // WHEN: useCase is called
          // THEN: Should handle gracefully (repository should handle exceptions)

          when(() => mockRepository.startVoiceInput(
            language: any(named: 'language'),
            listenFor: any(named: 'listenFor'),
          )).thenThrow(Exception('Repository error'));

          final params = TranscribeVoiceParams();

          expect(
            () => useCase.call(params),
            throwsException,
          );
        },
      );

      test(
        'works with various failure types',
        () async {
          // GIVEN: Repository returns different failure types
          // WHEN: useCase is called
          // THEN: Should return Left with appropriate failure

          final failure = SpeechRecognitionFailure(message: 'Error');

          when(() => mockRepository.startVoiceInput(
            language: any(named: 'language'),
            listenFor: any(named: 'listenFor'),
          )).thenAnswer((_) async => Left(failure));

          final params = TranscribeVoiceParams();

          final result = await useCase.call(params);

          expect(result.isLeft(), isTrue);
        },
      );
    });

    group('integration scenarios', () {
      test(
        'handles rapid consecutive calls',
        () async {
          // GIVEN: Multiple TranscribeVoiceUseCase calls
          // WHEN: Called in quick succession
          // THEN: Should handle each independently

          when(() => mockRepository.startVoiceInput(
            language: any(named: 'language'),
            listenFor: any(named: 'listenFor'),
          )).thenAnswer(
            (_) async => const Right(
              DictationResult(
                text: 'test',
                confidence: 0.9,
                isFinal: true,
                duration: Duration(seconds: 1),
              ),
            ),
          );

          final params = const TranscribeVoiceParams();

          final result1 = await useCase.call(params);
          final result2 = await useCase.call(params);

          expect(result1.isRight(), isTrue);
          expect(result2.isRight(), isTrue);
          verify(() => mockRepository.startVoiceInput(
            language: any(named: 'language'),
            listenFor: any(named: 'listenFor'),
          )).called(2);
        },
      );

      test(
        'maintains independence between calls',
        () async {
          // GIVEN: Multiple useCase calls with different params
          // WHEN: Executed sequentially
          // THEN: Each should maintain its own params

          when(() => mockRepository.startVoiceInput(
            language: 'en_US',
            listenFor: any(named: 'listenFor'),
          )).thenAnswer(
            (_) async => const Right(
              DictationResult(
                text: 'english',
                confidence: 0.95,
                isFinal: true,
                duration: Duration(seconds: 1),
              ),
            ),
          );

          when(() => mockRepository.startVoiceInput(
            language: 'es_ES',
            listenFor: any(named: 'listenFor'),
          )).thenAnswer(
            (_) async => const Right(
              DictationResult(
                text: 'español',
                confidence: 0.92,
                isFinal: true,
                duration: Duration(seconds: 1),
              ),
            ),
          );

          final paramsEn = TranscribeVoiceParams(language: 'en_US');
          final paramsEs = TranscribeVoiceParams(language: 'es_ES');

          final result1 = await useCase.call(paramsEn);
          final result2 = await useCase.call(paramsEs);

          expect(result1.isRight(), isTrue);
          expect(result2.isRight(), isTrue);
        },
      );
    });
  });
}
