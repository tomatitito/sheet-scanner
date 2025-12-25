import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_sheet_music_by_id_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/update_sheet_music_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/edit_sheet_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/edit_sheet_state.dart';

/// Mock for GetSheetMusicByIdUseCase
class MockGetSheetMusicByIdUseCase extends Mock
    implements GetSheetMusicByIdUseCase {}

/// Mock for UpdateSheetMusicUseCase
class MockUpdateSheetMusicUseCase extends Mock
    implements UpdateSheetMusicUseCase {}

/// Fallback for GetSheetMusicByIdParams
class FakeGetSheetMusicByIdParams extends Fake
    implements GetSheetMusicByIdParams {}

/// Fallback for UpdateSheetMusicParams
class FakeUpdateSheetMusicParams extends Fake
    implements UpdateSheetMusicParams {}

void main() {
  group('EditSheetCubit', () {
    late MockGetSheetMusicByIdUseCase mockGetSheetMusicByIdUseCase;
    late MockUpdateSheetMusicUseCase mockUpdateSheetMusicUseCase;
    late EditSheetCubit editSheetCubit;

    setUpAll(() {
      registerFallbackValue(FakeGetSheetMusicByIdParams());
      registerFallbackValue(FakeUpdateSheetMusicParams());
    });

    setUp(() {
      mockGetSheetMusicByIdUseCase = MockGetSheetMusicByIdUseCase();
      mockUpdateSheetMusicUseCase = MockUpdateSheetMusicUseCase();
      editSheetCubit = EditSheetCubit(
        getSheetMusicByIdUseCase: mockGetSheetMusicByIdUseCase,
        updateSheetMusicUseCase: mockUpdateSheetMusicUseCase,
      );
    });

    tearDown(() async {
      await editSheetCubit.close();
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

    test('initial state is EditSheetInitial', () {
      expect(editSheetCubit.state, isA<EditSheetInitial>());
    });

    group('loadSheetMusic', () {
      test('loadSheetMusic emits [EditSheetLoading, EditSheetLoaded] on success',
          () async {
        // Arrange
        when(() => mockGetSheetMusicByIdUseCase(any()))
            .thenAnswer((_) async => Right(tSheetMusic));

        // Act & Assert
        expect(
          editSheetCubit.stream,
          emitsInOrder([
            isA<EditSheetLoading>(),
            isA<EditSheetLoaded>(),
          ]),
        );

        await editSheetCubit.loadSheetMusic(1);
      });

      test('loadSheetMusic emits correct data on success', () async {
        // Arrange
        when(() => mockGetSheetMusicByIdUseCase(any()))
            .thenAnswer((_) async => Right(tSheetMusic));

        // Act
        await editSheetCubit.loadSheetMusic(1);

        // Assert
        expect(editSheetCubit.state, isA<EditSheetLoaded>());
        final state = editSheetCubit.state as EditSheetLoaded;
        expect(state.sheetMusic.id, 1);
        expect(state.sheetMusic.title, 'Moonlight Sonata');
        expect(state.sheetMusic.composer, 'Ludwig van Beethoven');
      });

      test('loadSheetMusic emits [EditSheetLoading, EditSheetError] on failure',
          () async {
        // Arrange
        final tFailure = DatabaseFailure(message: 'Database error');
        when(() => mockGetSheetMusicByIdUseCase(any()))
            .thenAnswer((_) async => Left(tFailure));

        // Act & Assert
        expect(
          editSheetCubit.stream,
          emitsInOrder([
            isA<EditSheetLoading>(),
            isA<EditSheetError>(),
          ]),
        );

        await editSheetCubit.loadSheetMusic(1);
      });

      test('loadSheetMusic returns error on not found', () async {
        // Arrange
        when(() => mockGetSheetMusicByIdUseCase(any()))
            .thenAnswer((_) async => Right<Failure, SheetMusic?>(null));

        // Act
        await editSheetCubit.loadSheetMusic(999);

        // Assert
        expect(editSheetCubit.state, isA<EditSheetError>());
        final state = editSheetCubit.state as EditSheetError;
        expect(state.failure.message, 'Sheet music not found');
      });
    });

    group('validateForm', () {
      test('returns empty errors for valid input', () {
        // Act
        final errors = editSheetCubit.validateForm(
          title: 'Valid Title',
          composer: 'Valid Composer',
        );

        // Assert
        expect(errors, isEmpty);
      });

      test('requires title', () {
        // Act
        final errors = editSheetCubit.validateForm(
          title: '',
          composer: 'Valid Composer',
        );

        // Assert
        expect(errors.containsKey('title'), isTrue);
      });

      test('title must be at least 3 characters', () {
        // Act
        final errors = editSheetCubit.validateForm(
          title: 'AB',
          composer: 'Valid Composer',
        );

        // Assert
        expect(errors.containsKey('title'), isTrue);
      });

      test('title must not exceed 200 characters', () {
        // Act
        final errors = editSheetCubit.validateForm(
          title: 'A' * 201,
          composer: 'Valid Composer',
        );

        // Assert
        expect(errors.containsKey('title'), isTrue);
      });

      test('requires composer', () {
        // Act
        final errors = editSheetCubit.validateForm(
          title: 'Valid Title',
          composer: '',
        );

        // Assert
        expect(errors.containsKey('composer'), isTrue);
      });

      test('composer must be at least 2 characters', () {
        // Act
        final errors = editSheetCubit.validateForm(
          title: 'Valid Title',
          composer: 'A',
        );

        // Assert
        expect(errors.containsKey('composer'), isTrue);
      });

      test('composer must not exceed 100 characters', () {
        // Act
        final errors = editSheetCubit.validateForm(
          title: 'Valid Title',
          composer: 'A' * 101,
        );

        // Assert
        expect(errors.containsKey('composer'), isTrue);
      });

      test('notes must not exceed 1000 characters', () {
        // Act
        final errors = editSheetCubit.validateForm(
          title: 'Valid Title',
          composer: 'Valid Composer',
          notes: 'A' * 1001,
        );

        // Assert
        expect(errors.containsKey('notes'), isTrue);
      });

      test('accepts empty notes', () {
        // Act
        final errors = editSheetCubit.validateForm(
          title: 'Valid Title',
          composer: 'Valid Composer',
          notes: null,
        );

        // Assert
        expect(errors.containsKey('notes'), isFalse);
      });

      test('validates multiple fields simultaneously', () {
        // Act
        final errors = editSheetCubit.validateForm(
          title: 'A',
          composer: 'B',
          notes: 'A' * 1001,
        );

        // Assert
        expect(errors.length, 3);
      });
    });

    group('validate', () {
      test('emits [EditSheetValidating, EditSheetValid] for valid input',
          () async {
        // Act & Assert
        expect(
          editSheetCubit.stream,
          emitsInOrder([
            isA<EditSheetValidating>(),
            isA<EditSheetValid>(),
          ]),
        );

        editSheetCubit.validate(
          title: 'Valid Title',
          composer: 'Valid Composer',
        );
      });

      test('emits [EditSheetValidating, EditSheetInvalid] for invalid input',
          () async {
        // Act & Assert
        expect(
          editSheetCubit.stream,
          emitsInOrder([
            isA<EditSheetValidating>(),
            isA<EditSheetInvalid>(),
          ]),
        );

        editSheetCubit.validate(
          title: '',
          composer: 'Valid Composer',
        );
      });
    });

    group('submitForm', () {
      test('submitForm emits [EditSheetSubmitting, EditSheetSuccess] on success',
          () async {
        // Arrange
        when(() => mockUpdateSheetMusicUseCase(any()))
            .thenAnswer((_) async => Right(tSheetMusic));

        // Act & Assert
        expect(
          editSheetCubit.stream,
          emitsInOrder([
            isA<EditSheetSubmitting>(),
            isA<EditSheetSuccess>(),
          ]),
        );

        await editSheetCubit.submitForm(
          id: 1,
          title: 'Moonlight Sonata',
          composer: 'Ludwig van Beethoven',
          createdAt: DateTime(2025, 12, 24),
          notes: 'Beautiful piece',
          tags: ['classic', 'piano'],
        );
      });

      test('submitForm returns success with updated sheet music', () async {
        // Arrange
        when(() => mockUpdateSheetMusicUseCase(any()))
            .thenAnswer((_) async => Right(tSheetMusic));

        // Act
        await editSheetCubit.submitForm(
          id: 1,
          title: 'Moonlight Sonata',
          composer: 'Ludwig van Beethoven',
          createdAt: DateTime(2025, 12, 24),
        );

        // Assert
        expect(editSheetCubit.state, isA<EditSheetSuccess>());
        final state = editSheetCubit.state as EditSheetSuccess;
        expect(state.sheetMusic.title, 'Moonlight Sonata');
      });

      test('submitForm emits error on failure', () async {
        // Arrange
        final tFailure = DatabaseFailure(message: 'Update failed');
        when(() => mockUpdateSheetMusicUseCase(any()))
            .thenAnswer((_) async => Left(tFailure));

        // Act
        await editSheetCubit.submitForm(
          id: 1,
          title: 'Moonlight Sonata',
          composer: 'Ludwig van Beethoven',
          createdAt: DateTime(2025, 12, 24),
        );

        // Assert
        expect(editSheetCubit.state, isA<EditSheetError>());
      });

      test('submitForm validates before submission', () async {
        // Act
        await editSheetCubit.submitForm(
          id: 1,
          title: '',
          composer: 'Valid Composer',
          createdAt: DateTime(2025, 12, 24),
        );

        // Assert
        expect(editSheetCubit.state, isA<EditSheetInvalid>());
        verifyNever(() => mockUpdateSheetMusicUseCase(any()));
      });

      test('submitForm updates all fields', () async {
        // Arrange
        when(() => mockUpdateSheetMusicUseCase(any()))
            .thenAnswer((_) async => Right(tSheetMusic));

        // Act
        await editSheetCubit.submitForm(
          id: 1,
          title: 'New Title',
          composer: 'New Composer',
          notes: 'New notes',
          tags: ['new-tag'],
          imageUrls: ['url1', 'url2'],
          createdAt: DateTime(2025, 12, 24),
        );

        // Assert
        expect(editSheetCubit.state, isA<EditSheetSuccess>());
      });
    });

    test('refresh calls loadSheetMusic', () async {
      // Arrange
      when(() => mockGetSheetMusicByIdUseCase(any()))
          .thenAnswer((_) async => Right(tSheetMusic));

      // Act
      await editSheetCubit.refresh(1);

      // Assert
      verify(() => mockGetSheetMusicByIdUseCase(any())).called(1);
      expect(editSheetCubit.state, isA<EditSheetLoaded>());
    });

    test('close completes without errors', () async {
      // Act & Assert
      expect(editSheetCubit.close(), completes);
    });
  });
}
