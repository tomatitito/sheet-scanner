import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/add_sheet_music_use_case.dart';

/// Mock for SheetMusicRepository
class MockSheetMusicRepository extends Mock implements SheetMusicRepository {}

void main() {
  group('AddSheetMusicUseCase', () {
    late MockSheetMusicRepository mockRepository;
    late AddSheetMusicUseCase useCase;

    setUpAll(() {
      registerFallbackValue(
        SheetMusic(
          id: 0,
          title: '',
          composer: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    });

    setUp(() {
      mockRepository = MockSheetMusicRepository();
      useCase = AddSheetMusicUseCase(repository: mockRepository);
    });

    final tSheetMusic = SheetMusic(
      id: 1,
      title: 'Test Piece',
      composer: 'Test Composer',
      notes: 'Test notes',
      imageUrls: const ['path/to/image.png'],
      tags: const ['classical'],
      createdAt: DateTime(2025, 12, 24),
      updatedAt: DateTime(2025, 12, 24),
    );

    test('should call repository.add with correct SheetMusic', () async {
      // Arrange
      when(() => mockRepository.add(any()))
          .thenAnswer((_) async => Right(tSheetMusic));

      final params = AddSheetMusicParams(sheetMusic: tSheetMusic);

      // Act
      await useCase.call(params);

      // Assert
      verify(() => mockRepository.add(tSheetMusic)).called(1);
    });

    test('should return Right with SheetMusic on successful add', () async {
      // Arrange
      when(() => mockRepository.add(any()))
          .thenAnswer((_) async => Right(tSheetMusic));

      final params = AddSheetMusicParams(sheetMusic: tSheetMusic);

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result, isA<Right<Failure, SheetMusic>>());
      result.fold(
        (failure) => fail('Should return Right'),
        (sheet) => expect(sheet.title, 'Test Piece'),
      );
    });

    test('should return Left with Failure on repository error', () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Database error');
      when(() => mockRepository.add(any()))
          .thenAnswer((_) async => Left(tFailure));

      final params = AddSheetMusicParams(sheetMusic: tSheetMusic);

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result, isA<Left<Failure, SheetMusic>>());
      result.fold(
        (failure) => expect(failure.message, 'Database error'),
        (sheet) => fail('Should return Left'),
      );
    });

    test('should preserve all SheetMusic properties during add', () async {
      // Arrange
      when(() => mockRepository.add(any()))
          .thenAnswer((_) async => Right(tSheetMusic));

      final params = AddSheetMusicParams(sheetMusic: tSheetMusic);

      // Act
      final result = await useCase.call(params);

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (sheet) {
          expect(sheet.id, 1);
          expect(sheet.title, 'Test Piece');
          expect(sheet.composer, 'Test Composer');
          expect(sheet.notes, 'Test notes');
          expect(sheet.imageUrls, ['path/to/image.png']);
          expect(sheet.tags, ['classical']);
        },
      );
    });

    test('should handle SheetMusic with empty tags', () async {
      // Arrange
      final sheetMusicNoTags = tSheetMusic.copyWith(tags: const []);
      when(() => mockRepository.add(any()))
          .thenAnswer((_) async => Right(sheetMusicNoTags));

      final params = AddSheetMusicParams(sheetMusic: sheetMusicNoTags);

      // Act
      final result = await useCase.call(params);

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (sheet) => expect(sheet.tags, isEmpty),
      );
    });

    test('should handle SheetMusic with multiple images', () async {
      // Arrange
      final sheetMusicMultiImage = tSheetMusic.copyWith(
        imageUrls: const [
          'image1.png',
          'image2.png',
          'image3.png',
        ],
      );
      when(() => mockRepository.add(any()))
          .thenAnswer((_) async => Right(sheetMusicMultiImage));

      final params = AddSheetMusicParams(sheetMusic: sheetMusicMultiImage);

      // Act
      final result = await useCase.call(params);

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (sheet) => expect(sheet.imageUrls.length, 3),
      );
    });
  });
}
