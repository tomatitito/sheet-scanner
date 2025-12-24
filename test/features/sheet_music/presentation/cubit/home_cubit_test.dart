import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_all_sheet_music_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/home_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/home_state.dart';

// Mock the UseCase parameter type
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_all_sheet_music_use_case.dart'
    as use_case;

/// Mock for GetAllSheetMusicUseCase
class MockGetAllSheetMusicUseCase extends Mock
    implements GetAllSheetMusicUseCase {}

void main() {
  group('HomeCubit', () {
    late MockGetAllSheetMusicUseCase mockGetAllSheetMusicUseCase;
    late HomeCubit homeCubit;

    setUp(() {
      mockGetAllSheetMusicUseCase = MockGetAllSheetMusicUseCase();
      homeCubit = HomeCubit(
        getAllSheetMusicUseCase: mockGetAllSheetMusicUseCase,
      );
    });

    tearDown(() async {
      await homeCubit.close();
    });

    final tSheetMusicList = [
      SheetMusic(
        id: 1,
        title: 'Piece 1',
        composer: 'Composer 1',
        createdAt: DateTime(2025, 12, 24),
        updatedAt: DateTime(2025, 12, 24),
      ),
      SheetMusic(
        id: 2,
        title: 'Piece 2',
        composer: 'Composer 2',
        createdAt: DateTime(2025, 12, 24),
        updatedAt: DateTime(2025, 12, 24),
      ),
    ];

    test('initial state is HomeInitial', () {
      expect(homeCubit.state, isA<HomeInitial>());
    });

    test('loadSheetMusic emits [HomeLoading, HomeLoaded] on success', () async {
      // Arrange
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(tSheetMusicList));

      // Act & Assert
      expect(
        homeCubit.stream,
        emitsInOrder([
          isA<HomeLoading>(),
          isA<HomeLoaded>(),
        ]),
      );

      await homeCubit.loadSheetMusic();
    });

    test('loadSheetMusic emits correct data on success', () async {
      // Arrange
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(tSheetMusicList));

      // Act
      await homeCubit.loadSheetMusic();

      // Assert
      expect(homeCubit.state, isA<HomeLoaded>());
      final state = homeCubit.state as HomeLoaded;
      expect(state.sheetMusicList.length, 2);
      expect(state.totalCount, 2);
      expect(state.sheetMusicList[0].title, 'Piece 1');
    });

    test('loadSheetMusic emits [HomeLoading, HomeError] on failure', () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Database error');
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Left(tFailure));

      // Act & Assert
      expect(
        homeCubit.stream,
        emitsInOrder([
          isA<HomeLoading>(),
          isA<HomeError>(),
        ]),
      );

      await homeCubit.loadSheetMusic();
    });

    test('loadSheetMusic emits correct error on failure', () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Database error');
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Left(tFailure));

      // Act
      await homeCubit.loadSheetMusic();

      // Assert
      expect(homeCubit.state, isA<HomeError>());
      final state = homeCubit.state as HomeError;
      expect(state.failure.message, 'Database error');
    });

    test('loadSheetMusic handles empty list', () async {
      // Arrange
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(<SheetMusic>[]));

      // Act
      await homeCubit.loadSheetMusic();

      // Assert
      expect(homeCubit.state, isA<HomeLoaded>());
      final state = homeCubit.state as HomeLoaded;
      expect(state.sheetMusicList, isEmpty);
      expect(state.totalCount, 0);
    });

    test('refresh calls loadSheetMusic', () async {
      // Arrange
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(tSheetMusicList));

      // Act
      await homeCubit.refresh();

      // Assert
      verify(() => mockGetAllSheetMusicUseCase.call()).called(1);
      expect(homeCubit.state, isA<HomeLoaded>());
    });

    test('loadSheetMusic called multiple times emits correct states',
        () async {
      // Arrange
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(tSheetMusicList));

      // Act
      await homeCubit.loadSheetMusic();
      final firstState = homeCubit.state;

      await homeCubit.loadSheetMusic();
      final secondState = homeCubit.state;

      // Assert
      expect(firstState, isA<HomeLoaded>());
      expect(secondState, isA<HomeLoaded>());
      final firstLoaded = firstState as HomeLoaded;
      final secondLoaded = secondState as HomeLoaded;
      expect(firstLoaded.sheetMusicList.length,
          secondLoaded.sheetMusicList.length);
    });

    test('handles large data sets', () async {
      // Arrange
      final largeList = List.generate(
        1000,
        (i) => SheetMusic(
          id: i,
          title: 'Piece $i',
          composer: 'Composer $i',
          createdAt: DateTime(2025, 12, 24),
          updatedAt: DateTime(2025, 12, 24),
        ),
      );
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(largeList));

      // Act
      await homeCubit.loadSheetMusic();

      // Assert
      expect(homeCubit.state, isA<HomeLoaded>());
      final state = homeCubit.state as HomeLoaded;
      expect(state.sheetMusicList.length, 1000);
      expect(state.totalCount, 1000);
    });

    test('close completes without errors', () async {
      // Act & Assert
      expect(homeCubit.close(), completes);
    });
  });
}
