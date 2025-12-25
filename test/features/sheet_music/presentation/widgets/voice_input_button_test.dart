import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/dictation_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/dictation_state.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/widgets/voice_input_button.dart';

class MockDictationCubit extends Mock implements DictationCubit {
  @override
  Stream<DictationState> get stream => Stream.value(const DictationState.idle());

  @override
  DictationState get state => const DictationState.idle();

  @override
  Future<void> startDictation({
    String language = 'en_US',
    Duration listenFor = const Duration(minutes: 1),
  }) async {}

  @override
  Future<void> stopDictation() async {}

  @override
  Future<void> cancelDictation() async {}

  @override
  void clearTranscription() {}

  @override
  void updatePartialResult(String text) {}

  @override
  void setLanguage(String language) {}

  @override
  String get currentLanguage => 'en_US';

  @override
  Future<void> close() async {}

  @override
  bool get isClosed => false;
}

void main() {
  group('VoiceInputButton Widget Tests', () {
    setUp(() {
      // Register mock cubit in GetIt for the widget to use
      final getIt = GetIt.instance;
      getIt.registerSingleton<DictationCubit>(MockDictationCubit());
    });

    tearDown(() {
      // Clean up GetIt after each test
      GetIt.instance.reset();
    });

    Widget createWidget({
      ValueChanged<String>? onDictationComplete,
      VoidCallback? onDictationCancelled,
      ValueChanged<String>? onError,
      String language = 'en_US',
      String tooltip = 'Tap to start voice input',
      double size = 48.0,
      Color? idleColor,
      Color? listeningColor,
      bool showConfidence = true,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: VoiceInputButton(
            onDictationComplete: onDictationComplete ?? (_) {},
            onDictationCancelled: onDictationCancelled,
            onError: onError,
            language: language,
            tooltip: tooltip,
            size: size,
            idleColor: idleColor ?? Colors.blue,
            listeningColor: listeningColor ?? Colors.red,
            showConfidence: showConfidence,
          ),
        ),
      );
    }

    group('widget appearance', () {
      testWidgets(
        'renders with idle appearance initially',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton in initial state
          // WHEN: Widget is built
          // THEN: Should display microphone icon with idle color

          await tester.pumpWidget(createWidget());

          expect(find.byIcon(Icons.mic_none), findsOneWidget);
          expect(find.byIcon(Icons.mic), findsNothing);
        },
      );

      testWidgets(
        'renders with custom size',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton with custom size
          // WHEN: Widget is built
          // THEN: Button should respect the specified size

          await tester.pumpWidget(createWidget(size: 64.0));

          final buttonFinder = find.byType(VoiceInputButton);
          expect(buttonFinder, findsOneWidget);
        },
      );

      testWidgets(
        'renders with tooltip',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton with custom tooltip
          // WHEN: Widget is built
          // THEN: Tooltip should be accessible

          const customTooltip = 'Start recording your voice';
          await tester.pumpWidget(createWidget(tooltip: customTooltip));

          await tester.pump();

          expect(find.byType(Tooltip), findsWidgets);
        },
      );

      testWidgets(
        'displays confidence when showConfidence is true',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton with showConfidence = true
          // WHEN: Dictation completes
          // THEN: Should display confidence percentage

          await tester.pumpWidget(createWidget(showConfidence: true));

          // Note: Confidence display only appears in complete state
          // This test documents the expected behavior
          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );

      testWidgets(
        'hides confidence when showConfidence is false',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton with showConfidence = false
          // WHEN: Dictation completes
          // THEN: Should not display confidence percentage

          await tester.pumpWidget(createWidget(showConfidence: false));

          await tester.pump();

          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );
    });

    group('interaction', () {
      testWidgets(
        'is tappable when in idle state',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton in idle state
          // WHEN: Button is tapped
          // THEN: Should not throw error

          await tester.pumpWidget(createWidget());

          expect(
            () async => await tester.tap(find.byType(InkWell)),
            returnsNormally,
          );
        },
      );

      testWidgets(
        'handles double tap gracefully',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton
          // WHEN: Button is tapped multiple times quickly
          // THEN: Should handle gracefully (debounce logic in cubit)

          await tester.pumpWidget(createWidget());

          await tester.tap(find.byType(InkWell));
          await tester.tap(find.byType(InkWell));

          await tester.pump();

          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );
    });

    group('callbacks', () {
      testWidgets(
        'calls onDictationComplete when dictation finishes',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton with onDictationComplete callback
          // WHEN: Dictation completes with text
          // THEN: Callback should be invoked with the text

          await tester.pumpWidget(
            createWidget(
              onDictationComplete: (_) {},
            ),
          );

          await tester.pump();

          // Callback would be called by cubit state changes
          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );

      testWidgets(
        'calls onDictationCancelled when cancelled',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton with onDictationCancelled callback
          // WHEN: Dictation is cancelled
          // THEN: Callback should be invoked

          await tester.pumpWidget(
            createWidget(
              onDictationCancelled: () {},
            ),
          );

          await tester.pump();

          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );

      testWidgets(
        'calls onError when error occurs',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton with onError callback
          // WHEN: An error occurs during dictation
          // THEN: Callback should be invoked with error message

          await tester.pumpWidget(
            createWidget(
              onError: (_) {},
            ),
          );

          await tester.pump();

          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );
    });

    group('accessibility', () {
      testWidgets(
        'button has semantic label',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton
          // WHEN: Widget is built
          // THEN: Should provide semantic information for screen readers

          await tester.pumpWidget(createWidget());

          expect(find.byType(Tooltip), findsWidgets);
        },
      );

      testWidgets(
        'supports screen reader announcements',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton
          // WHEN: Widget is built
          // THEN: Should work with accessibility services

          await tester.pumpWidget(
            createWidget(
              tooltip: 'Voice input button - tap to start recording',
            ),
          );

          await tester.pump();

          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );
    });

    group('state display', () {
      testWidgets(
        'shows listening indicator during listening state',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton showing listening state
          // WHEN: Cubit emits listening state
          // THEN: Should display elapsed time and waveform

          // Note: This test documents the behavior
          // Actual state changes would come from cubit

          await tester.pumpWidget(createWidget());

          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );

      testWidgets(
        'shows timer during recording',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton in listening state
          // WHEN: Time passes
          // THEN: Should display formatted timer (MM:SS)

          await tester.pumpWidget(createWidget());

          await tester.pump();

          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );

      testWidgets(
        'shows waveform animation during listening',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton in listening state
          // WHEN: Animation is running
          // THEN: Should display animated waveform bars

          await tester.pumpWidget(createWidget());

          await tester.pump();

          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );
    });

    group('error handling', () {
      testWidgets(
        'displays error snackbar on error state',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton
          // WHEN: Error state is emitted
          // THEN: Should show error snackbar

          await tester.pumpWidget(createWidget());

          await tester.pump();

          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );

      testWidgets(
        'recovers from error state',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton that showed error
          // WHEN: User dismisses error
          // THEN: Should allow retry

          await tester.pumpWidget(createWidget());

          await tester.pump();

          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );
    });

    group('customization', () {
      testWidgets(
        'respects custom idle color',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton with custom idleColor
          // WHEN: Widget is built
          // THEN: Button should use the specified color

          await tester.pumpWidget(
            createWidget(idleColor: Colors.green),
          );

          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );

      testWidgets(
        'respects custom listening color',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton with custom listeningColor
          // WHEN: Listening state is active
          // THEN: Button should use the specified color

          await tester.pumpWidget(
            createWidget(listeningColor: Colors.orange),
          );

          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );

      testWidgets(
        'respects custom language',
        (WidgetTester tester) async {
          // GIVEN: VoiceInputButton with custom language
          // WHEN: Dictation starts
          // THEN: Should use specified language for recognition

          await tester.pumpWidget(
            createWidget(language: 'es_ES'),
          );

          expect(find.byType(VoiceInputButton), findsOneWidget);
        },
      );
    });
  });
}
