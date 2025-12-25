import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/delete_sheet_music_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_sheet_music_by_id_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/sheet_detail_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/sheet_detail_state.dart';

/// Mock for GetSheetMusicByIdUseCase
class MockGetSheetMusicByIdUseCase extends Mock
    implements GetSheetMusicByIdUseCase {}

/// Mock for DeleteSheetMusicUseCase
class MockDeleteSheetMusicUseCase extends Mock
    implements DeleteSheetMusicUseCase {}

void main() {
  group('SheetDetailCubit', () {
    late MockGetSheetMusicByIdUseCase mockGetSheetMusicByIdUseCase;
    late MockDeleteSheetMusicUseCase mockDeleteSheetMusicUseCase;
    late SheetDetailCubit sheetDetailCubit;

    setUpAll(() {
      registerFallbackValue(GetSheetMusicByIdParams(id: 0));
    });

    setUp(() {
      mockGetSheetMusicByIdUseCase = MockGetSheetMusicByIdUseCase();
      mockDeleteSheetMusicUseCase = MockDeleteSheetMusicUseCase();
      sheetDetailCubit = SheetDetailCubit(
        getSheetMusicByIdUseCase: mockGetSheetMusicByIdUseCase,
        deleteSheetMusicUseCase: mockDeleteSheetMusicUseCase,
      );
    });

    tearDown(() async {
      await sheetDetailCubit.close();
    });

    final tSheetMusic = SheetMusic(
      id: 1,
      title: 'Test Piece',
      composer: 'Test Composer',
      notes: 'Test notes',
      imageUrls: const ['image.png'],
      tags: const ['classical'],
      createdAt: DateTime(2025, 12, 24),
      updatedAt: DateTime(2025, 12, 24),
    );

    test('initial state is SheetDetailInitial', () {
      expect(sheetDetailCubit.state, isA<SheetDetailInitial>());
    });

    test('loadSheetMusic emits [SheetDetailLoading, SheetDetailLoaded]',
        () async {
      // Arrange
      when(() => mockGetSheetMusicByIdUseCase(any()))
          .thenAnswer((_) async => Right(tSheetMusic));

      // Act & Assert
      expect(
        sheetDetailCubit.stream,
        emitsInOrder([
          isA<SheetDetailLoading>(),
          isA<SheetDetailLoaded>(),
        ]),
      );

      await sheetDetailCubit.loadSheetMusic(1);
    });

    test('loadSheetMusic loads correct sheet music', () async {
      // Arrange
      when(() => mockGetSheetMusicByIdUseCase(any()))
          .thenAnswer((_) async => Right(tSheetMusic));

      // Act
      await sheetDetailCubit.loadSheetMusic(1);

      // Assert
      expect(sheetDetailCubit.state, isA<SheetDetailLoaded>());
      final state = sheetDetailCubit.state as SheetDetailLoaded;
      expect(state.sheetMusic.title, 'Test Piece');
      expect(state.sheetMusic.id, 1);
    });

    test('loadSheetMusic emits error on failure', () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Not found');
      when(() => mockGetSheetMusicByIdUseCase(any()))
          .thenAnswer((_) async => Left(tFailure));

      // Act & Assert
      expect(
        sheetDetailCubit.stream,
        emitsInOrder([
          isA<SheetDetailLoading>(),
          isA<SheetDetailError>(),
        ]),
      );

      await sheetDetailCubit.loadSheetMusic(999);
    });

    test('loadSheetMusic preserves all sheet music properties', () async {
      // Arrange
      when(() => mockGetSheetMusicByIdUseCase(any()))
          .thenAnswer((_) async => Right(tSheetMusic));

      // Act
      await sheetDetailCubit.loadSheetMusic(1);

      // Assert
      final state = sheetDetailCubit.state as SheetDetailLoaded;
      expect(state.sheetMusic.composer, 'Test Composer');
      expect(state.sheetMusic.notes, 'Test notes');
      expect(state.sheetMusic.imageUrls, ['image.png']);
      expect(state.sheetMusic.tags, ['classical']);
    });

    test('loadSheetMusic handles sheet with multiple images', () async {
      // Arrange
      final sheetWithImages = tSheetMusic.copyWith(
        imageUrls: const ['img1.png', 'img2.png', 'img3.png'],
      );
      when(() => mockGetSheetMusicByIdUseCase(any()))
          .thenAnswer((_) async => Right(sheetWithImages));

      // Act
      await sheetDetailCubit.loadSheetMusic(1);

      // Assert
      final state = sheetDetailCubit.state as SheetDetailLoaded;
      expect(state.sheetMusic.imageUrls.length, 3);
    });

    test('loadSheetMusic handles sheet with multiple tags', () async {
      // Arrange
      final sheetWithTags = tSheetMusic.copyWith(
        tags: const ['classical', 'piano', 'sonata', 'beethoven'],
      );
      when(() => mockGetSheetMusicByIdUseCase(any()))
          .thenAnswer((_) async => Right(sheetWithTags));

      // Act
      await sheetDetailCubit.loadSheetMusic(1);

      // Assert
      final state = sheetDetailCubit.state as SheetDetailLoaded;
      expect(state.sheetMusic.tags.length, 4);
    });

    test('loadSheetMusic can load different sheet IDs', () async {
      // Arrange
      when(() => mockGetSheetMusicByIdUseCase(any()))
          .thenAnswer((invocation) async {
        final params = invocation.positionalArguments[0];
        final id = params.id as int;
        return Right(tSheetMusic.copyWith(id: id));
      });

      // Act
      await sheetDetailCubit.loadSheetMusic(5);

      // Assert
      final state = sheetDetailCubit.state as SheetDetailLoaded;
      expect(state.sheetMusic.id, 5);
    });

    test('loadSheetMusic handles database errors', () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Database error');
      when(() => mockGetSheetMusicByIdUseCase(any()))
          .thenAnswer((_) async => Left(tFailure));

      // Act
      await sheetDetailCubit.loadSheetMusic(1);

      // Assert
      expect(sheetDetailCubit.state, isA<SheetDetailError>());
      final state = sheetDetailCubit.state as SheetDetailError;
      expect(state.failure.message, 'Database error');
    });

    test('close completes without errors', () async {
      // Act & Assert
      expect(sheetDetailCubit.close(), completes);
    });
  });
}
