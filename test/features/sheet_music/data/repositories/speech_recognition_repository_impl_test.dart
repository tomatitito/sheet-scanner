import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/services/speech_recognition_service.dart';
import 'package:sheet_scanner/features/sheet_music/data/repositories/speech_recognition_repository_impl.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/dictation_result.dart';

class _DurationFake extends Fake implements Duration {}

class MockSpeechRecognitionService extends Mock
    implements SpeechRecognitionService {}

void main() {
  setUpAll(() {
    registerFallbackValue(_DurationFake());
  });

  group('SpeechRecognitionRepositoryImpl', () {
    late SpeechRecognitionRepositoryImpl repository;
    late MockSpeechRecognitionService mockService;

    setUp(() {
      mockService = MockSpeechRecognitionService();
      
      // Set up default fallback for availableLanguages to return a Future
      // This prevents "type 'Null' is not a subtype of type 'Future<List<String>>'" errors
      when(() => mockService.availableLanguages)
          .thenAnswer((_) async => ['en_US', 'es_ES', 'fr_FR', 'de_DE']);
      
      repository = SpeechRecognitionRepositoryImpl(
        speechService: mockService,
      );
    });

    group('startVoiceInput()', () {
      test(
        'returns failure when service is not available',
        () async {
          // GIVEN: Speech recognition service is not available
          when(() => mockService.isAvailable()).thenAnswer((_) async => false);

          // WHEN: startVoiceInput() is called
          final result = await repository.startVoiceInput();

          // THEN: Should return PlatformFailure with speech_unavailable code
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) {
              expect(failure, isA<PlatformFailure>());
              expect(failure.code, equals('speech_unavailable'));
            },
            (_) => fail('Should return failure'),
          );
        },
      );

      test(
        'returns failure when initialization fails',
        () async {
          // GIVEN: Speech service is available but initialization fails
          when(() => mockService.isAvailable()).thenAnswer((_) async => true);
          when(() => mockService.initialize()).thenAnswer((_) async => false);

          // WHEN: startVoiceInput() is called
          final result = await repository.startVoiceInput();

          // THEN: Should return PlatformFailure with init_failed code
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) {
              expect(failure, isA<PlatformFailure>());
              expect(failure.code, equals('init_failed'));
            },
            (_) => fail('Should return failure'),
          );
        },
      );

      test(
        'returns DictationResult when voice input completes with final result',
        () async {
          // GIVEN: Service is available and initialized
          when(() => mockService.isAvailable()).thenAnswer((_) async => true);
          when(() => mockService.initialize()).thenAnswer((_) async => true);

          // Mock startListening to immediately call onResult with isFinal=true
          when(
            () => mockService.startListening(
              onResult: any(named: 'onResult'),
              onError: any(named: 'onError'),
              language: any(named: 'language'),
              listenFor: any(named: 'listenFor'),
            ),
          ).thenAnswer((invocation) async {
            final onResult = invocation.namedArguments[const Symbol('onResult')]
                as Function(String, bool);
            // Simulate successful recognition with final result
            Future.microtask(() => onResult('hello world', true));
          });

          // WHEN: startVoiceInput() is called
          final result = await repository.startVoiceInput(
            listenFor: const Duration(seconds: 5),
          );

          // THEN: Should return DictationResult with recognized text
          expect(result.isRight(), isTrue);
          result.fold(
            (_) => fail('Should return success'),
            (dictationResult) {
              expect(dictationResult, isA<DictationResult>());
              expect(dictationResult.text, equals('hello world'));
              expect(dictationResult.isFinal, isTrue);
              expect(dictationResult.confidence, greaterThan(0.0));
            },
          );
        },
      );

      test(
        'returns failure when error occurs during voice input',
        () async {
          // GIVEN: Service is available and initialized
          when(() => mockService.isAvailable()).thenAnswer((_) async => true);
          when(() => mockService.initialize()).thenAnswer((_) async => true);

          // Mock startListening to call onError
          when(
            () => mockService.startListening(
              onResult: any(named: 'onResult'),
              onError: any(named: 'onError'),
              language: any(named: 'language'),
              listenFor: any(named: 'listenFor'),
            ),
          ).thenAnswer((invocation) async {
            final onError = invocation.namedArguments[const Symbol('onError')]
                as Function(String);
            // Simulate error
            Future.microtask(() => onError('Microphone access denied'));
          });

          // WHEN: startVoiceInput() is called
          final result = await repository.startVoiceInput(
            listenFor: const Duration(seconds: 5),
          );

          // THEN: Should return failure
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<GenericFailure>()),
            (_) => fail('Should return failure'),
          );
        },
      );

      test(
        'passes correct language to service',
        () async {
          // GIVEN: Language parameter 'es_ES'
          when(() => mockService.isAvailable()).thenAnswer((_) async => true);
          when(() => mockService.initialize()).thenAnswer((_) async => true);

          when(
            () => mockService.startListening(
              onResult: any(named: 'onResult'),
              onError: any(named: 'onError'),
              language: 'es_ES',
              listenFor: any(named: 'listenFor'),
            ),
          ).thenAnswer((invocation) async {
            final onResult = invocation.namedArguments[const Symbol('onResult')]
                as Function(String, bool);
            Future.microtask(() => onResult('hola', true));
          });

          // WHEN: startVoiceInput(language: 'es_ES') is called
          await repository.startVoiceInput(language: 'es_ES');

          // THEN: Should pass 'es_ES' to the service
          verify(
            () => mockService.startListening(
              onResult: any(named: 'onResult'),
              onError: any(named: 'onError'),
              language: 'es_ES',
              listenFor: any(named: 'listenFor'),
            ),
          ).called(1);
        },
      );

      test(
        'respects listenFor duration parameter',
        () async {
          // GIVEN: listenFor duration of 30 seconds
          const listenDuration = Duration(seconds: 30);

          when(() => mockService.isAvailable()).thenAnswer((_) async => true);
          when(() => mockService.initialize()).thenAnswer((_) async => true);

          when(
            () => mockService.startListening(
              onResult: any(named: 'onResult'),
              onError: any(named: 'onError'),
              language: any(named: 'language'),
              listenFor: listenDuration,
            ),
          ).thenAnswer((invocation) async {
            final onResult = invocation.namedArguments[const Symbol('onResult')]
                as Function(String, bool);
            Future.microtask(() => onResult('test result', true));
          });

          // WHEN: startVoiceInput(listenFor: Duration(seconds: 30)) is called
          await repository.startVoiceInput(listenFor: listenDuration);

          // THEN: Should pass duration to the service
          verify(
            () => mockService.startListening(
              onResult: any(named: 'onResult'),
              onError: any(named: 'onError'),
              language: any(named: 'language'),
              listenFor: listenDuration,
            ),
          ).called(1);
        },
      );
    });

    group('DictationResult properties', () {
      test(
        'DictationResult contains text from speech recognition',
        () async {
          // GIVEN: Speech service returns recognized text
          const expectedText = 'hello world';

          when(() => mockService.isAvailable()).thenAnswer((_) async => true);
          when(() => mockService.initialize()).thenAnswer((_) async => true);

          when(
            () => mockService.startListening(
              onResult: any(named: 'onResult'),
              onError: any(named: 'onError'),
              language: any(named: 'language'),
              listenFor: any(named: 'listenFor'),
            ),
          ).thenAnswer((invocation) async {
            final onResult = invocation.namedArguments[const Symbol('onResult')]
                as Function(String, bool);
            Future.microtask(() => onResult(expectedText, true));
          });

          // WHEN: startVoiceInput() completes
          final result = await repository.startVoiceInput();

          // THEN: Result should contain the recognized text
          result.fold(
            (_) => fail('Should return success'),
            (dictationResult) {
              expect(dictationResult.text, equals(expectedText));
            },
          );
        },
      );

      test(
        'DictationResult has reasonable confidence value',
        () async {
          // GIVEN: Speech recognition completes
          when(() => mockService.isAvailable()).thenAnswer((_) async => true);
          when(() => mockService.initialize()).thenAnswer((_) async => true);

          when(
            () => mockService.startListening(
              onResult: any(named: 'onResult'),
              onError: any(named: 'onError'),
              language: any(named: 'language'),
              listenFor: any(named: 'listenFor'),
            ),
          ).thenAnswer((invocation) async {
            final onResult = invocation.namedArguments[const Symbol('onResult')]
                as Function(String, bool);
            Future.microtask(() => onResult('test', true));
          });

          // WHEN: startVoiceInput() returns
          final result = await repository.startVoiceInput();

          // THEN: Confidence should be between 0.0 and 1.0
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
        'DictationResult marks final result correctly',
        () async {
          // GIVEN: Speech recognition completes
          when(() => mockService.isAvailable()).thenAnswer((_) async => true);
          when(() => mockService.initialize()).thenAnswer((_) async => true);

          when(
            () => mockService.startListening(
              onResult: any(named: 'onResult'),
              onError: any(named: 'onError'),
              language: any(named: 'language'),
              listenFor: any(named: 'listenFor'),
            ),
          ).thenAnswer((invocation) async {
            final onResult = invocation.namedArguments[const Symbol('onResult')]
                as Function(String, bool);
            Future.microtask(() => onResult('final text', true));
          });

          // WHEN: startVoiceInput() returns
          final result = await repository.startVoiceInput();

          // THEN: isFinal should be true for completed recognition
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
          when(() => mockService.isAvailable())
              .thenThrow(Exception('Service error'));

          // WHEN: startVoiceInput() is called
          final result = await repository.startVoiceInput();

          // THEN: Should catch and return failure
          expect(result.isLeft(), isTrue);
          result.fold(
            (failure) => expect(failure, isA<GenericFailure>()),
            (_) => fail('Should return failure'),
          );
        },
      );

      test(
        'provides meaningful error messages',
        () async {
          // GIVEN: Service is not available
          when(() => mockService.isAvailable()).thenAnswer((_) async => false);

          // WHEN: startVoiceInput() is called
          final result = await repository.startVoiceInput();

          // THEN: Failure should contain descriptive message
          result.fold(
            (failure) {
              expect(failure.message, isNotEmpty);
            },
            (_) => fail('Should return failure'),
          );
        },
      );
    });

    group('stopVoiceInput()', () {
      test(
        'completes the listening session',
        () async {
          // GIVEN: A listening session is in progress
          when(() => mockService.isAvailable()).thenAnswer((_) async => true);
          when(() => mockService.initialize()).thenAnswer((_) async => true);

          when(
            () => mockService.startListening(
              onResult: any(named: 'onResult'),
              onError: any(named: 'onError'),
              language: any(named: 'language'),
              listenFor: any(named: 'listenFor'),
            ),
          ).thenAnswer((_) async {
            // Don't call onResult immediately, so we can call stopVoiceInput
          });

          when(() => mockService.stopListening())
              .thenAnswer((_) async => 'stopped text');

          // Start listening (won't complete immediately)
          final future = repository.startVoiceInput(
            listenFor: const Duration(minutes: 1),
          );

          // Give the startListening time to complete
          await Future.delayed(const Duration(milliseconds: 100));

          // WHEN: stopVoiceInput() is called
          final stopResult = await repository.stopVoiceInput();

          // THEN: Should complete successfully
          expect(stopResult.isRight(), isTrue);

          // And the startVoiceInput should now complete
          final result = await future;
          expect(result.isRight(), isTrue);
        },
      );
    });

    group('cancelVoiceInput()', () {
      test(
        'cancels the listening session',
        () async {
          // GIVEN: A listening session is in progress
          when(() => mockService.isAvailable()).thenAnswer((_) async => true);
          when(() => mockService.initialize()).thenAnswer((_) async => true);

          when(
            () => mockService.startListening(
              onResult: any(named: 'onResult'),
              onError: any(named: 'onError'),
              language: any(named: 'language'),
              listenFor: any(named: 'listenFor'),
            ),
          ).thenAnswer((_) async {
            // Don't call callbacks immediately
          });

          when(() => mockService.cancelListening()).thenAnswer((_) async {});

          // Start listening (won't complete immediately)
          final future = repository.startVoiceInput(
            listenFor: const Duration(minutes: 1),
          );

          // Give the startListening time to complete
          await Future.delayed(const Duration(milliseconds: 100));

          // WHEN: cancelVoiceInput() is called
          final cancelResult = await repository.cancelVoiceInput();

          // THEN: Should complete successfully
          expect(cancelResult.isRight(), isTrue);

          // And the startVoiceInput should fail
          final result = await future;
          expect(result.isLeft(), isTrue);
        },
      );
    });
  });
}
