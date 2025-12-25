import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/services/speech_recognition_service.dart';
import 'package:sheet_scanner/features/sheet_music/data/repositories/speech_recognition_repository_impl.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/dictation_result.dart';

class MockSpeechRecognitionService extends Mock
    implements SpeechRecognitionService {}

void main() {
  group('SpeechRecognitionRepositoryImpl', () {
    late SpeechRecognitionRepositoryImpl repository;
    late MockSpeechRecognitionService mockService;

    setUp(() {
      mockService = MockSpeechRecognitionService();
      repository = SpeechRecognitionRepositoryImpl(
        speechService: mockService,
      );
      
      // Set default behavior for all tests
      when(() => mockService.isAvailable()).thenAnswer((_) async => true);
      when(() => mockService.initialize()).thenAnswer((_) async => true);
      when(
        () => mockService.startListening(
          onResult: any(named: 'onResult'),
          onError: any(named: 'onError'),
          language: any(named: 'language'),
          listenFor: any(named: 'listenFor'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockService.stopListening()).thenAnswer((_) async => null);
    });

    group('startVoiceInput()', () {
      test(
        'returns failure when service is not available',
        () async {
          // GIVEN: Speech recognition service is not available
          // WHEN: startVoiceInput() is called
          // THEN: Should return PlatformFailure

          when(() => mockService.isAvailable()).thenAnswer((_) async => false);

          final result = await repository.startVoiceInput();

          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) {
              expect(failure, isA<PlatformFailure>());
            },
            (_) => fail('Should return failure'),
          );
        },
      );

      test(
        'returns failure when initialization fails',
        () async {
          // GIVEN: Speech service initialization fails
          // WHEN: startVoiceInput() is called
          // THEN: Should return PlatformFailure

          when(() => mockService.initialize()).thenAnswer((_) async => false);

          final result = await repository.startVoiceInput();

          expect(result.isLeft(), isTrue);
        },
      );

      test(
        'returns DictationResult on successful voice input',
        () async {
          // GIVEN: Service is available and initialized
          // WHEN: startVoiceInput() completes successfully
          // THEN: Should return DictationResult with recognized text

          when(() => mockService.stopListening())
              .thenAnswer((_) async => 'hello world');

          final result = await repository.startVoiceInput();

          expect(result.isRight(), isTrue);
          result.fold(
            (_) => fail('Should return result'),
            (dictationResult) {
              expect(dictationResult, isA<DictationResult>());
              expect(dictationResult.text, isNotEmpty);
            },
          );
        },
      );

      test(
        'handles error during voice input',
        () async {
          // GIVEN: Service is available but error occurs during listening
          // WHEN: startVoiceInput() encounters an error
          // THEN: Should return failure with error message

          when(
            () => mockService.startListening(
              onResult: any(named: 'onResult'),
              onError: any(named: 'onError'),
              language: any(named: 'language'),
              listenFor: any(named: 'listenFor'),
            ),
          ).thenAnswer(
            (invocation) async {
              final onError =
                  invocation.namedArguments[const Symbol('onError')]
                      as Function(String);
              // Simulate error in a future
              Future<void>(() {
                onError('Microphone access denied');
              });
            },
          );

          final result = await repository.startVoiceInput();

          expect(result.isLeft(), isTrue);
        },
      );

      test(
        'with language parameter',
        () async {
          // GIVEN: Language parameter 'es_ES'
          // WHEN: startVoiceInput(language: 'es_ES') is called
          // THEN: Should work successfully with custom language

          when(() => mockService.stopListening())
              .thenAnswer((_) async => 'hola');

          final result = await repository.startVoiceInput(language: 'es_ES');

          expect(result.isRight(), isTrue);
        },
      );

      test(
        'with custom listenFor duration',
        () async {
          // GIVEN: listenFor duration of 30 seconds
          // WHEN: startVoiceInput(listenFor: Duration(seconds: 30)) is called
          // THEN: Should work successfully with custom duration

          const listenDuration = Duration(seconds: 30);

          when(() => mockService.stopListening())
              .thenAnswer((_) async => 'test');

          final result = await repository.startVoiceInput(
            listenFor: listenDuration,
          );

          expect(result.isRight(), isTrue);
        },
      );
    });

    group('DictationResult properties', () {
      test(
        'contains text from speech recognition',
        () async {
          // GIVEN: Speech service returns recognized text
          // WHEN: startVoiceInput() completes
          // THEN: Result should contain the recognized text

          const expectedText = 'hello world';

          when(() => mockService.stopListening())
              .thenAnswer((_) async => expectedText);

          final result = await repository.startVoiceInput();

          result.fold(
            (_) => fail('Should return success'),
            (dictationResult) {
              expect(dictationResult.text, equals(expectedText));
            },
          );
        },
      );

      test(
        'has reasonable confidence value',
        () async {
          // GIVEN: Speech recognition completes
          // WHEN: startVoiceInput() returns
          // THEN: Confidence should be between 0.0 and 1.0

          when(() => mockService.stopListening())
              .thenAnswer((_) async => 'test');

          final result = await repository.startVoiceInput();

          result.fold(
            (_) => fail('Should return success'),
            (dictationResult) {
              expect(dictationResult.confidence, greaterThanOrEqualTo(0.0));
              expect(dictationResult.confidence, lessThanOrEqualTo(1.0));
            },
          );
        },
      );

      test(
        'marks final result correctly',
        () async {
          // GIVEN: Speech recognition completes
          // WHEN: startVoiceInput() returns
          // THEN: isFinal should be true for completed recognition

          when(() => mockService.stopListening())
              .thenAnswer((_) async => 'final text');

          final result = await repository.startVoiceInput();

          result.fold(
            (_) => fail('Should return success'),
            (dictationResult) {
              expect(dictationResult.isFinal, isTrue);
            },
          );
        },
      );
    });

    group('error handling', () {
      test(
        'handles service unavailable gracefully',
        () async {
          // GIVEN: Speech service throws exception
          // WHEN: startVoiceInput() is called
          // THEN: Should catch and return failure

          when(() => mockService.isAvailable())
              .thenThrow(Exception('Service error'));

          final result = await repository.startVoiceInput();

          // Repository catches exceptions and returns Left
          expect(result.isLeft(), isTrue);
        },
      );

      test(
        'provides meaningful error messages',
        () async {
          // GIVEN: Error occurs during voice input
          // WHEN: startVoiceInput() completes with error
          // THEN: Failure should contain descriptive message

          when(() => mockService.isAvailable()).thenAnswer((_) async => false);

          final result = await repository.startVoiceInput();

          result.fold(
            (failure) {
              expect(failure.message, isNotEmpty);
            },
            (_) => fail('Should return failure'),
          );
        },
      );
    });
  });
}
