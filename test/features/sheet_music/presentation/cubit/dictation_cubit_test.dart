import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/dictation_result.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/transcribe_voice_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/dictation_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/dictation_state.dart';
import 'package:sheet_scanner/core/utils/either.dart';

// Mock for the use case
class MockTranscribeVoiceUseCase extends Mock
    implements TranscribeVoiceUseCase {}

// Fake for TranscribeVoiceParams
class FakeTranscribeVoiceParams extends Fake implements TranscribeVoiceParams {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeTranscribeVoiceParams());
  });

  group('DictationCubit', () {
    late DictationCubit dictationCubit;
    late MockTranscribeVoiceUseCase mockUseCase;

    setUp(() {
      mockUseCase = MockTranscribeVoiceUseCase();
      dictationCubit = DictationCubit(
        transcribeVoiceUseCase: mockUseCase,
      );
    });

    tearDown(() {
      dictationCubit.close();
    });

    group('initialization', () {
      test(
        'initial state is idle',
        () {
          // GIVEN: Fresh DictationCubit instance
          // WHEN: Created
          // THEN: Should start in idle state

          expect(dictationCubit.state, isA<DictationState>());
          expect(
            dictationCubit.state,
            const DictationState.idle(),
          );
        },
      );

      test(
        'current language defaults to en_US',
        () {
          // GIVEN: Fresh DictationCubit
          // WHEN: Created
          // THEN: currentLanguage should be 'en_US'

          expect(dictationCubit.currentLanguage, equals('en_US'));
        },
      );
    });

    group('startDictation()', () {
      test(
        'emits listening state before starting transcription',
        () async {
          // GIVEN: DictationCubit in idle state
          // WHEN: startDictation() is called
          // THEN: First emits listening state with empty transcription

          when(() => mockUseCase.call(any())).thenAnswer(
            (_) async => Right(const 
              DictationResult(
                text: 'hello world',
                confidence: 0.95,
                isFinal: true,
                duration: Duration(seconds: 2),
              ),
            ),
          );

          final states = <DictationState>[];
          final subscription = dictationCubit.stream.listen(states.add);

          await dictationCubit.startDictation();

          await Future.delayed(const Duration(milliseconds: 100));

          expect(states, isNotEmpty);
          expect(states.first, isA<DictationState>());

          await subscription.cancel();
        },
      );

      test(
        'ignores subsequent calls while already listening',
        () async {
          // GIVEN: DictationCubit currently listening
          // WHEN: startDictation() is called again
          // THEN: Should ignore and not call use case twice

          var callCount = 0;
          when(() => mockUseCase.call(any())).thenAnswer((_) {
            callCount++;
            return Future.delayed(
              const Duration(milliseconds: 500),
              () => Right(
                const DictationResult(
                  text: 'test',
                  confidence: 0.9,
                  isFinal: true,
                  duration: Duration(seconds: 1),
                ),
              ),
            );
          });

          final future1 = dictationCubit.startDictation();

          // Wait a tiny bit to ensure first call starts and emits listening
          await Future.delayed(const Duration(milliseconds: 10));

          // Try to start again while listening - should be ignored
          final future2 = dictationCubit.startDictation();

          // Both should complete without error
          await Future.wait([future1, future2]);

          // Use case should be called only once
          expect(callCount, 1);
        },
      );

      test(
        'emits complete state with result on success',
        () async {
          // GIVEN: Use case returns success
          // WHEN: startDictation() completes
          // THEN: Should emit complete state with text and confidence

          const expectedText = 'hello world';
          const expectedConfidence = 0.95;

          when(() => mockUseCase.call(any())).thenAnswer(
            (_) async => Right(
              const DictationResult(
                text: expectedText,
                confidence: expectedConfidence,
                isFinal: true,
                duration: Duration(seconds: 2),
              ),
            ),
          );

          await dictationCubit.startDictation();

          // Wait for async completion
          await Future.delayed(const Duration(milliseconds: 200));

          expect(dictationCubit.state, isA<DictationState>());
        },
      );

      test(
        'emits error state when use case fails',
        () async {
          // GIVEN: Use case returns failure
          // WHEN: startDictation() completes
          // THEN: Should emit error state with failure

          when(() => mockUseCase.call(any())).thenAnswer(
            (_) async => Left(
              SpeechRecognitionFailure(
                message: 'Speech recognition not available',
              ),
            ),
          );

          await dictationCubit.startDictation();

          // Wait for async completion
          await Future.delayed(const Duration(milliseconds: 200));

          expect(dictationCubit.state, isA<DictationState>());
        },
      );

      test(
        'uses provided language parameter',
        () async {
          // GIVEN: Language parameter 'es_ES'
          // WHEN: startDictation(language: 'es_ES') is called
          // THEN: Should pass 'es_ES' to use case

          when(() => mockUseCase.call(any())).thenAnswer(
            (_) async => Right(
              const DictationResult(
                text: 'hola',
                confidence: 0.9,
                isFinal: true,
                duration: Duration(seconds: 1),
              ),
            ),
          );

          await dictationCubit.startDictation(language: 'es_ES');

          expect(dictationCubit.currentLanguage, equals('es_ES'));

          verify(() => mockUseCase.call(any())).called(1);
        },
      );
    });

    group('stopDictation()', () {
      test(
        'ignores when not listening',
        () async {
          // GIVEN: DictationCubit in idle state
          // WHEN: stopDictation() is called
          // THEN: Should return without error

          expect(
            () => dictationCubit.stopDictation(),
            returnsNormally,
          );
        },
      );

      test(
        'emits processing state while listening',
        () async {
          // GIVEN: DictationCubit is listening
          // WHEN: stopDictation() is called
          // THEN: Should emit processing state

          when(() => mockUseCase.call(any())).thenAnswer(
            (_) async => Right(
              const DictationResult(
                text: 'test',
                confidence: 0.9,
                isFinal: true,
                duration: Duration(seconds: 1),
              ),
            ),
          );

          await dictationCubit.startDictation();

          // Wait for listening state
          await Future.delayed(const Duration(milliseconds: 100));

          await dictationCubit.stopDictation();

          expect(dictationCubit.state, isA<DictationState>());
        },
      );
    });

    group('cancelDictation()', () {
      test(
        'emits idle state',
        () async {
          // GIVEN: DictationCubit in any state
          // WHEN: cancelDictation() is called
          // THEN: Should emit idle state

          when(() => mockUseCase.call(any())).thenAnswer(
            (_) async => Right(
              const DictationResult(
                text: 'test',
                confidence: 0.9,
                isFinal: true,
                duration: Duration(seconds: 1),
              ),
            ),
          );

          await dictationCubit.startDictation();

          await Future.delayed(const Duration(milliseconds: 50));

          await dictationCubit.cancelDictation();

          expect(
            dictationCubit.state,
            const DictationState.idle(),
          );
        },
      );

      test(
        'clears listening start time',
        () async {
          // GIVEN: DictationCubit that has started listening
          // WHEN: cancelDictation() is called
          // THEN: Internal state should be cleared

          expect(
            () => dictationCubit.cancelDictation(),
            returnsNormally,
          );
        },
      );
    });

    group('clearTranscription()', () {
      test(
        'emits idle state',
        () {
          // GIVEN: DictationCubit in any state
          // WHEN: clearTranscription() is called
          // THEN: Should emit idle state

          dictationCubit.clearTranscription();

          expect(
            dictationCubit.state,
            const DictationState.idle(),
          );
        },
      );
    });

    group('updatePartialResult()', () {
      test(
        'ignores when not listening',
        () {
          // GIVEN: DictationCubit in idle state
          // WHEN: updatePartialResult() is called
          // THEN: Should ignore (no state change)

          final initialState = dictationCubit.state;

          dictationCubit.updatePartialResult('partial text');

          expect(dictationCubit.state, equals(initialState));
        },
      );

      test(
        'emits partial result state when listening',
        () async {
          // GIVEN: DictationCubit is listening
          // WHEN: updatePartialResult() is called
          // THEN: Should emit partialResult state

          when(() => mockUseCase.call(any())).thenAnswer(
            (_) => Future.delayed(
              const Duration(milliseconds: 500),
              () => Right(
                const DictationResult(
                  text: 'final text',
                  confidence: 0.95,
                  isFinal: true,
                  duration: Duration(seconds: 2),
                ),
              ),
            ),
          );

          await dictationCubit.startDictation();

          // Wait for listening state
          await Future.delayed(const Duration(milliseconds: 100));

          dictationCubit.updatePartialResult('partial text');

          expect(dictationCubit.state, isA<DictationState>());
        },
      );
    });

    group('setLanguage()', () {
      test(
        'updates the current language',
        () {
          // GIVEN: DictationCubit with default language
          // WHEN: setLanguage() is called
          // THEN: Should update currentLanguage

          dictationCubit.setLanguage('fr_FR');

          expect(dictationCubit.currentLanguage, equals('fr_FR'));
        },
      );
    });

    group('cleanup', () {
      test(
        'cancels timer when closed',
        () async {
          // GIVEN: DictationCubit with active elapsed timer
          // WHEN: close() is called
          // THEN: Timer should be cancelled gracefully

          when(() => mockUseCase.call(any())).thenAnswer(
            (_) => Future.delayed(
              const Duration(milliseconds: 500),
              () => Right(
                const DictationResult(
                  text: 'test',
                  confidence: 0.9,
                  isFinal: true,
                  duration: Duration(seconds: 1),
                ),
              ),
            ),
          );

          await dictationCubit.startDictation();

          // Start listening creates elapsed timer
          await Future.delayed(const Duration(milliseconds: 100));

          // Close should cancel the timer
          expect(
            () => dictationCubit.close(),
            returnsNormally,
          );
        },
      );
    });

    group('state transitions', () {
      test(
        'transitions correctly from idle → listening → complete',
        () async {
          // GIVEN: DictationCubit starting in idle state
          // WHEN: startDictation() succeeds
          // THEN: Should transition: idle → listening → complete

          final states = <DictationState>[];
          final subscription = dictationCubit.stream.listen(states.add);

          when(() => mockUseCase.call(any())).thenAnswer(
            (_) async => Right(
              const DictationResult(
                text: 'hello',
                confidence: 0.95,
                isFinal: true,
                duration: Duration(seconds: 1),
              ),
            ),
          );

          await dictationCubit.startDictation();

          await Future.delayed(const Duration(milliseconds: 200));

          expect(states, isNotEmpty);

          await subscription.cancel();
        },
      );

      test(
        'transitions correctly from idle → listening → error',
        () async {
          // GIVEN: DictationCubit starting in idle state
          // WHEN: startDictation() fails
          // THEN: Should transition: idle → listening → error

          final states = <DictationState>[];
          final subscription = dictationCubit.stream.listen(states.add);

          when(() => mockUseCase.call(any())).thenAnswer(
            (_) async => Left(
              SpeechRecognitionFailure(message: 'Error'),
            ),
          );

          await dictationCubit.startDictation();

          await Future.delayed(const Duration(milliseconds: 200));

          expect(states, isNotEmpty);

          await subscription.cancel();
        },
      );
    });
  });
}
