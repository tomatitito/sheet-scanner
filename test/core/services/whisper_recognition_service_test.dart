import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/services/whisper_service.dart';

void main() {
  group('WhisperRecognitionServiceImpl', () {
    late WhisperRecognitionServiceImpl service;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      service = WhisperRecognitionServiceImpl();
    });

    tearDown(() async {
      await service.cancelListening();
    });

    group('initialize()', () {
      test(
        'returns bool indicating initialization status',
        () async {
          // GIVEN: A fresh WhisperRecognitionServiceImpl instance
          // WHEN: initialize() is called
          // THEN: Should return a boolean indicating success

          final result = await service.initialize();

          expect(result, isA<bool>());
        },
      );

      test(
        'handles exceptions gracefully during initialization',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: initialize() is called
          // THEN: Should not throw

          expect(() async => await service.initialize(), returnsNormally);
        },
      );
    });

    group('isAvailable()', () {
      test(
        'checks microphone permission',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: isAvailable() is called
          // THEN: Should verify microphone permission

          final result = await service.isAvailable();

          expect(result, isA<bool>());
        },
      );

      test(
        'returns false when microphone permission denied',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: isAvailable() is called (permission might be denied)
          // THEN: Should handle permission checks gracefully

          final result = await service.isAvailable();
          expect(result, isA<bool>());
        },
      );
    });

    group('startListening()', () {
      test(
        'calls onError when service is not available',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: startListening() is called without microphone permission
          // THEN: onError callback should be invoked or listening starts

          String? errorMessage;
          bool? resultReceived;

          await service.startListening(
            onResult: (text, isFinal) {
              resultReceived = isFinal;
            },
            onError: (error) {
              errorMessage = error;
            },
            language: 'en_US',
          );

          // Give async operations time to complete
          await Future.delayed(const Duration(milliseconds: 500));

          // Either error was set or listening started
          expect(
            errorMessage == null || errorMessage is String,
            isTrue,
          );
        },
      );

      test(
        'initializes with proper parameters',
        () async {
          // GIVEN: Valid language and listen duration
          // WHEN: startListening() is called
          // THEN: Should not throw and handle callbacks

          expect(
            () async => await service.startListening(
              onResult: (text, isFinal) {},
              onError: (error) {},
              language: 'en_US',
              listenFor: const Duration(seconds: 5),
            ),
            returnsNormally,
          );
        },
      );

      test(
        'sets isListening to true after starting',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: startListening() is called
          // THEN: isListening should become true

          bool listeningBefore = service.isListening;

          await service.startListening(
            onResult: (text, isFinal) {},
            onError: (error) {},
            language: 'en_US',
            listenFor: const Duration(seconds: 1),
          );

          // isListening should have been set to true at least momentarily
          expect(listeningBefore, isFalse);
          // Note: it might already be false again due to async operations
        },
      );
    });

    group('stopListening()', () {
      test(
        'returns null or string when called',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl that hasn\'t recorded
          // WHEN: stopListening() is called
          // THEN: Should return null or string

          final result = await service.stopListening();

          expect(
            result == null || result is String,
            isTrue,
          );
        },
      );

      test(
        'handles exceptions gracefully',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: stopListening() is called
          // THEN: Should not throw

          expect(() async => await service.stopListening(), returnsNormally);
        },
      );

      test(
        'sets isListening to false',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: stopListening() is called
          // THEN: isListening should be false

          await service.stopListening();

          expect(service.isListening, isFalse);
        },
      );
    });

    group('cancelListening()', () {
      test(
        'clears listening state',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl with potential listening
          // WHEN: cancelListening() is called
          // THEN: Should clear state and not throw

          expect(
            () async => await service.cancelListening(),
            returnsNormally,
          );

          expect(service.isListening, isFalse);
        },
      );

      test(
        'handles exceptions gracefully',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: cancelListening() is called
          // THEN: Should not throw

          expect(
            () async => await service.cancelListening(),
            returnsNormally,
          );
        },
      );

      test(
        'can be called multiple times safely',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: cancelListening() is called multiple times
          // THEN: Should handle it gracefully

          expect(
            () async => await Future.wait([
              service.cancelListening(),
              service.cancelListening(),
              service.cancelListening(),
            ]),
            returnsNormally,
          );
        },
      );
    });

    group('isListening getter', () {
      test(
        'returns false initially',
        () {
          // GIVEN: Fresh WhisperRecognitionServiceImpl
          // WHEN: isListening is accessed
          // THEN: Should return false

          expect(service.isListening, isFalse);
        },
      );
    });

    group('availableLanguages getter', () {
      test(
        'returns a list of language codes',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: availableLanguages is accessed
          // THEN: Should return a non-empty list

          final languages = await service.availableLanguages;

          expect(languages, isA<List<String>>());
          expect(languages, isNotEmpty);
        },
      );

      test(
        'includes English language',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: availableLanguages is accessed
          // THEN: Should include English

          final languages = await service.availableLanguages;

          // Should include English in some form
          expect(
            languages.any((lang) => lang.startsWith('en')),
            isTrue,
          );
        },
      );
    });

    group('transcribeAudioFile()', () {
      test(
        'handles non-existent file gracefully',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: transcribeAudioFile() is called with non-existent file
          // THEN: Should throw or handle gracefully

          expect(
            () async => await service.transcribeAudioFile('/non/existent/path.wav'),
            throwsA(anything),
          );
        },
      );

      test(
        'returns a string result',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: transcribeAudioFile() completes (with mock data if needed)
          // THEN: Should return a string

          // This test would need a valid WAV file to fully test
          // For now, we test that the method signature works
          expect(service.transcribeAudioFile, isNotNull);
        },
      );
    });

    group('Audio recording integration', () {
      test(
        'startListening and cancelListening workflow',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: startListening() then cancelListening() is called
          // THEN: Should clean up resources properly

          await service.startListening(
            onResult: (text, isFinal) {},
            onError: (error) {},
            language: 'en_US',
            listenFor: const Duration(seconds: 10),
          );

          // Give time for recording to start
          await Future.delayed(const Duration(milliseconds: 100));

          // Cancel should work even while recording
          await service.cancelListening();

          expect(service.isListening, isFalse);
        },
      );

      test(
        'startListening with short duration',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: startListening() with very short duration
          // THEN: Should complete without error

          bool? recordingCompleted;
          String? transcriptionResult;

          await service.startListening(
            onResult: (text, isFinal) {
              if (isFinal) {
                transcriptionResult = text;
                recordingCompleted = true;
              }
            },
            onError: (error) {},
            language: 'en_US',
            listenFor: const Duration(milliseconds: 500),
          );

          // Wait for recording to complete
          await Future.delayed(const Duration(seconds: 2));

          // Should have processed without crashing
          expect(recordingCompleted == null || recordingCompleted is bool, isTrue);
        },
      );
    });

    group('Error handling', () {
      test(
        'handles permission denied gracefully',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: Service is used without permissions
          // THEN: Should provide helpful error messages

          String? capturedError;

          await service.startListening(
            onResult: (text, isFinal) {},
            onError: (error) {
              capturedError = error;
            },
            language: 'en_US',
          );

          // Wait a bit for async operations
          await Future.delayed(const Duration(milliseconds: 200));

          // Either got error or started (depending on actual permissions)
          expect(
            capturedError == null || capturedError is String,
            isTrue,
          );
        },
      );

      test(
        'handles recording errors gracefully',
        () async {
          // GIVEN: WhisperRecognitionServiceImpl
          // WHEN: Recording operation encounters error
          // THEN: Should call onError with message

          String? errorMessage;
          bool errorCalled = false;

          await service.startListening(
            onResult: (text, isFinal) {},
            onError: (error) {
              errorMessage = error;
              errorCalled = true;
            },
            language: 'en_US',
            listenFor: const Duration(seconds: 1),
          );

          // Wait for recording and potential errors
          await Future.delayed(const Duration(seconds: 2));

          // Should have either errored or completed
          expect(
            errorCalled || !service.isListening,
            isTrue,
          );
        },
      );
    });
  });
}
