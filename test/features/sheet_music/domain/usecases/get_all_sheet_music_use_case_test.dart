import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_all_sheet_music_use_case.dart';

/// Mock for SheetMusicRepository
class MockSheetMusicRepository extends Mock implements SheetMusicRepository {}

void main() {
  group('GetAllSheetMusicUseCase', () {
    late MockSheetMusicRepository mockRepository;
    late GetAllSheetMusicUseCase useCase;

    setUp(() {
      mockRepository = MockSheetMusicRepository();
      useCase = GetAllSheetMusicUseCase(repository: mockRepository);
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
      SheetMusic(
        id: 3,
        title: 'Piece 3',
        composer: 'Composer 3',
        createdAt: DateTime(2025, 12, 24),
        updatedAt: DateTime(2025, 12, 24),
      ),
    ];

    test('should call repository.getAll', () async {
      // Arrange
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => Right(tSheetMusicList));

      // Act
      await useCase.call();

      // Assert
      verify(() => mockRepository.getAll()).called(1);
    });

    test('should return Right with list of SheetMusic on success', () async {
      // Arrange
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => Right(tSheetMusicList));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Right<Failure, List<SheetMusic>>>());
      result.fold(
        (failure) => fail('Should return Right'),
        (list) {
          expect(list.length, 3);
          expect(list[0].title, 'Piece 1');
          expect(list[1].title, 'Piece 2');
          expect(list[2].title, 'Piece 3');
        },
      );
    });

    test('should return Left with Failure on repository error', () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Database error');
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => Left(tFailure));

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isA<Left<Failure, List<SheetMusic>>>());
      result.fold(
        (failure) => expect(failure.message, 'Database error'),
        (list) => fail('Should return Left'),
      );
    });

    test('should return empty list when no sheet music exists', () async {
      // Arrange
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => Right(<SheetMusic>[]));

      // Act
      final result = await useCase.call();

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (list) => expect(list, isEmpty),
      );
    });

    test('should preserve SheetMusic properties in list', () async {
      // Arrange
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => Right(tSheetMusicList));

      // Act
      final result = await useCase.call();

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (list) {
          final first = list[0];
          expect(first.id, 1);
          expect(first.title, 'Piece 1');
          expect(first.composer, 'Composer 1');
        },
      );
    });

    test('should handle large lists efficiently', () async {
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
      when(() => mockRepository.getAll())
          .thenAnswer((_) async => Right(largeList));

      // Act
      final result = await useCase.call();

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (list) => expect(list.length, 1000),
      );
    });
  });
}
