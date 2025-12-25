import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/add_sheet_music_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/add_sheet_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/add_sheet_state.dart';

/// Mock for AddSheetMusicUseCase
class MockAddSheetMusicUseCase extends Mock implements AddSheetMusicUseCase {}

/// Fallback for AddSheetMusicParams
class FakeAddSheetMusicParams extends Fake implements AddSheetMusicParams {}

void main() {
  group('AddSheetCubit', () {
    late MockAddSheetMusicUseCase mockAddSheetMusicUseCase;
    late AddSheetCubit addSheetCubit;

    setUpAll(() {
      registerFallbackValue(FakeAddSheetMusicParams());
    });

    setUp(() {
      mockAddSheetMusicUseCase = MockAddSheetMusicUseCase();
      addSheetCubit = AddSheetCubit(
        addSheetMusicUseCase: mockAddSheetMusicUseCase,
      );
    });

    tearDown(() async {
      await addSheetCubit.close();
    });

    final tSheetMusic = SheetMusic(
      id: 1,
      title: 'Moonlight Sonata',
      composer: 'Ludwig van Beethoven',
      createdAt: DateTime(2025, 12, 24),
      updatedAt: DateTime(2025, 12, 24),
      notes: 'Beautiful piece',
      tags: ['classic', 'piano'],
    );

    test('initial state is AddSheetInitial', () {
      expect(addSheetCubit.state, isA<AddSheetInitial>());
    });

    group('validateForm', () {
      test('returns empty errors for valid input', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'Valid Title',
          composer: 'Valid Composer',
        );

        // Assert
        expect(errors, isEmpty);
      });

      test('requires title', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: '',
          composer: 'Valid Composer',
        );

        // Assert
        expect(errors.containsKey('title'), isTrue);
        expect(errors['title'], 'Title is required');
      });

      test('title must be at least 3 characters', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'AB',
          composer: 'Valid Composer',
        );

        // Assert
        expect(errors.containsKey('title'), isTrue);
        expect(errors['title'], 'Title must be at least 3 characters');
      });

      test('title must not exceed 200 characters', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'A' * 201,
          composer: 'Valid Composer',
        );

        // Assert
        expect(errors.containsKey('title'), isTrue);
        expect(errors['title'], 'Title must not exceed 200 characters');
      });

      test('accepts title exactly 3 characters', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'ABC',
          composer: 'Valid Composer',
        );

        // Assert
        expect(errors.containsKey('title'), isFalse);
      });

      test('accepts title exactly 200 characters', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'A' * 200,
          composer: 'Valid Composer',
        );

        // Assert
        expect(errors.containsKey('title'), isFalse);
      });

      test('requires composer', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'Valid Title',
          composer: '',
        );

        // Assert
        expect(errors.containsKey('composer'), isTrue);
        expect(errors['composer'], 'Composer is required');
      });

      test('composer must be at least 2 characters', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'Valid Title',
          composer: 'A',
        );

        // Assert
        expect(errors.containsKey('composer'), isTrue);
        expect(errors['composer'], 'Composer must be at least 2 characters');
      });

      test('composer must not exceed 100 characters', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'Valid Title',
          composer: 'A' * 101,
        );

        // Assert
        expect(errors.containsKey('composer'), isTrue);
        expect(errors['composer'], 'Composer must not exceed 100 characters');
      });

      test('accepts composer exactly 2 characters', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'Valid Title',
          composer: 'AB',
        );

        // Assert
        expect(errors.containsKey('composer'), isFalse);
      });

      test('accepts composer exactly 100 characters', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'Valid Title',
          composer: 'A' * 100,
        );

        // Assert
        expect(errors.containsKey('composer'), isFalse);
      });

      test('notes must not exceed 1000 characters', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'Valid Title',
          composer: 'Valid Composer',
          notes: 'A' * 1001,
        );

        // Assert
        expect(errors.containsKey('notes'), isTrue);
        expect(errors['notes'], 'Notes must not exceed 1000 characters');
      });

      test('accepts notes exactly 1000 characters', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'Valid Title',
          composer: 'Valid Composer',
          notes: 'A' * 1000,
        );

        // Assert
        expect(errors.containsKey('notes'), isFalse);
      });

      test('accepts empty notes', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'Valid Title',
          composer: 'Valid Composer',
          notes: null,
        );

        // Assert
        expect(errors.containsKey('notes'), isFalse);
      });

      test('validates multiple fields simultaneously', () {
        // Act
        final errors = addSheetCubit.validateForm(
          title: 'A',
          composer: 'B',
          notes: 'A' * 1001,
        );

        // Assert
        expect(errors.length, 3);
        expect(errors.containsKey('title'), isTrue);
        expect(errors.containsKey('composer'), isTrue);
        expect(errors.containsKey('notes'), isTrue);
      });
    });

    group('validate', () {
      test('emits [AddSheetValidating, AddSheetValid] for valid input',
          () async {
        // Act & Assert
        expect(
          addSheetCubit.stream,
          emitsInOrder([
            isA<AddSheetValidating>(),
            isA<AddSheetValid>(),
          ]),
        );

        addSheetCubit.validate(
          title: 'Valid Title',
          composer: 'Valid Composer',
        );
      });

      test('emits [AddSheetValidating, AddSheetInvalid] for invalid input',
          () async {
        // Act & Assert
        expect(
          addSheetCubit.stream,
          emitsInOrder([
            isA<AddSheetValidating>(),
            isA<AddSheetInvalid>(),
          ]),
        );

        addSheetCubit.validate(
          title: '',
          composer: 'Valid Composer',
        );
      });

      test('validation sets errors correctly', () async {
        // Act
        addSheetCubit.validate(
          title: 'A',
          composer: 'B',
        );

        // Assert
        expect(addSheetCubit.state, isA<AddSheetInvalid>());
        final state = addSheetCubit.state as AddSheetInvalid;
        expect(state.errors.length, 2);
      });
    });

    group('submitForm', () {
      test('submitForm emits [AddSheetSubmitting, AddSheetSuccess] on success',
          () async {
        // Arrange
        when(() => mockAddSheetMusicUseCase(any()))
            .thenAnswer((_) async => Right(tSheetMusic));

        // Act & Assert
        expect(
          addSheetCubit.stream,
          emitsInOrder([
            isA<AddSheetSubmitting>(),
            isA<AddSheetSuccess>(),
          ]),
        );

        await addSheetCubit.submitForm(
          title: 'Moonlight Sonata',
          composer: 'Ludwig van Beethoven',
          notes: 'Beautiful piece',
          tags: ['classic', 'piano'],
        );
      });

      test('submitForm calls useCase with correct parameters', () async {
        // Arrange
        when(() => mockAddSheetMusicUseCase(any()))
            .thenAnswer((_) async => Right(tSheetMusic));

        // Act
        await addSheetCubit.submitForm(
          title: 'Moonlight Sonata',
          composer: 'Ludwig van Beethoven',
          notes: 'Beautiful piece',
          tags: ['classic', 'piano'],
          imageUrls: ['url1', 'url2'],
        );

        // Assert
        verify(() => mockAddSheetMusicUseCase(any())).called(1);
      });

      test('submitForm returns success with added sheet music', () async {
        // Arrange
        when(() => mockAddSheetMusicUseCase(any()))
            .thenAnswer((_) async => Right(tSheetMusic));

        // Act
        await addSheetCubit.submitForm(
          title: 'Moonlight Sonata',
          composer: 'Ludwig van Beethoven',
        );

        // Assert
        expect(addSheetCubit.state, isA<AddSheetSuccess>());
        final state = addSheetCubit.state as AddSheetSuccess;
        expect(state.sheetMusic.title, 'Moonlight Sonata');
        expect(state.sheetMusic.composer, 'Ludwig van Beethoven');
      });

      test('submitForm emits [AddSheetSubmitting, AddSheetError] on failure',
          () async {
        // Arrange
        final tFailure = DatabaseFailure(message: 'Database error');
        when(() => mockAddSheetMusicUseCase(any()))
            .thenAnswer((_) async => Left(tFailure));

        // Act & Assert
        expect(
          addSheetCubit.stream,
          emitsInOrder([
            isA<AddSheetSubmitting>(),
            isA<AddSheetError>(),
          ]),
        );

        await addSheetCubit.submitForm(
          title: 'Moonlight Sonata',
          composer: 'Ludwig van Beethoven',
        );
      });

      test('submitForm returns error on failure', () async {
        // Arrange
        final tFailure = DatabaseFailure(message: 'Database error');
        when(() => mockAddSheetMusicUseCase(any()))
            .thenAnswer((_) async => Left(tFailure));

        // Act
        await addSheetCubit.submitForm(
          title: 'Moonlight Sonata',
          composer: 'Ludwig van Beethoven',
        );

        // Assert
        expect(addSheetCubit.state, isA<AddSheetError>());
        final state = addSheetCubit.state as AddSheetError;
        expect(state.failure.message, 'Database error');
      });

      test('submitForm validates before submission', () async {
        // Act
        await addSheetCubit.submitForm(
          title: '',
          composer: 'Valid Composer',
        );

        // Assert
        expect(addSheetCubit.state, isA<AddSheetInvalid>());
        verifyNever(() => mockAddSheetMusicUseCase(any()));
      });

      test('submitForm with empty tags', () async {
        // Arrange
        when(() => mockAddSheetMusicUseCase(any()))
            .thenAnswer((_) async => Right(tSheetMusic));

        // Act
        await addSheetCubit.submitForm(
          title: 'Moonlight Sonata',
          composer: 'Ludwig van Beethoven',
          tags: [],
        );

        // Assert
        expect(addSheetCubit.state, isA<AddSheetSuccess>());
      });

      test('submitForm with empty imageUrls', () async {
        // Arrange
        when(() => mockAddSheetMusicUseCase(any()))
            .thenAnswer((_) async => Right(tSheetMusic));

        // Act
        await addSheetCubit.submitForm(
          title: 'Moonlight Sonata',
          composer: 'Ludwig van Beethoven',
          imageUrls: [],
        );

        // Assert
        expect(addSheetCubit.state, isA<AddSheetSuccess>());
      });

      test('submitForm with multiple tags and images', () async {
        // Arrange
        when(() => mockAddSheetMusicUseCase(any()))
            .thenAnswer((_) async => Right(tSheetMusic));

        // Act
        await addSheetCubit.submitForm(
          title: 'Moonlight Sonata',
          composer: 'Ludwig van Beethoven',
          tags: ['classic', 'piano', 'beethoven'],
          imageUrls: ['url1', 'url2', 'url3'],
        );

        // Assert
        expect(addSheetCubit.state, isA<AddSheetSuccess>());
      });
    });

    test('reset returns to initial state', () async {
      // Arrange
      when(() => mockAddSheetMusicUseCase(any()))
          .thenAnswer((_) async => Right(tSheetMusic));
      await addSheetCubit.submitForm(
        title: 'Moonlight Sonata',
        composer: 'Ludwig van Beethoven',
      );

      // Act
      addSheetCubit.reset();

      // Assert
      expect(addSheetCubit.state, isA<AddSheetInitial>());
    });

    test('close completes without errors', () async {
      // Act & Assert
      expect(addSheetCubit.close(), completes);
    });
  });
}
