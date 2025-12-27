import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_sheet_music_by_id_use_case.dart';

/// Mock for SheetMusicRepository
class MockSheetMusicRepository extends Mock implements SheetMusicRepository {}

void main() {
  group('GetSheetMusicByIdUseCase', () {
    late MockSheetMusicRepository mockRepository;
    late GetSheetMusicByIdUseCase useCase;

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
      useCase = GetSheetMusicByIdUseCase(repository: mockRepository);
    });

    final tSheetMusic = SheetMusic(
      id: 1,
      title: 'Test Piece',
      composer: 'Test Composer',
      notes: 'Test notes',
      imageUrls: const ['image.png'],
      tags: const ['classical', 'piano'],
      createdAt: DateTime(2025, 12, 24),
      updatedAt: DateTime(2025, 12, 24),
    );

    test('should call repository.getById with correct id', () async {
      // Arrange
      when(() => mockRepository.getById(any()))
          .thenAnswer((_) async => Right(tSheetMusic));

      final params = GetSheetMusicByIdParams(id: 1);

      // Act
      await useCase.call(params);

      // Assert
      verify(() => mockRepository.getById(1)).called(1);
    });

    test('should return Right with SheetMusic on success', () async {
      // Arrange
      when(() => mockRepository.getById(any()))
          .thenAnswer((_) async => Right(tSheetMusic));

      final params = GetSheetMusicByIdParams(id: 1);

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should return Right'),
        (sheet) => expect(sheet?.id, 1),
      );
    });

    test('should return Left with Failure when not found', () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Sheet music not found');
      when(() => mockRepository.getById(any()))
          .thenAnswer((_) async => Left(tFailure));

      final params = GetSheetMusicByIdParams(id: 999);

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, 'Sheet music not found'),
        (sheet) => fail('Should return Left'),
      );
    });

    test('should preserve all SheetMusic properties', () async {
      // Arrange
      when(() => mockRepository.getById(any()))
          .thenAnswer((_) async => Right(tSheetMusic));

      final params = GetSheetMusicByIdParams(id: 1);

      // Act
      final result = await useCase.call(params);

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (sheet) {
          expect(sheet?.id, tSheetMusic.id);
          expect(sheet?.title, tSheetMusic.title);
          expect(sheet?.composer, tSheetMusic.composer);
          expect(sheet?.notes, tSheetMusic.notes);
          expect(sheet?.imageUrls, tSheetMusic.imageUrls);
          expect(sheet?.tags, tSheetMusic.tags);
          expect(sheet?.createdAt, tSheetMusic.createdAt);
          expect(sheet?.updatedAt, tSheetMusic.updatedAt);
        },
      );
    });

    test('should handle retrieval of different IDs', () async {
      // Arrange
      when(() => mockRepository.getById(any())).thenAnswer((invocation) async {
        final id = invocation.positionalArguments[0] as int;
        return Right(tSheetMusic.copyWith(id: id));
      });

      // Act & Assert
      for (int id in [1, 5, 10, 100]) {
        final params = GetSheetMusicByIdParams(id: id);
        final result = await useCase.call(params);
        result.fold(
          (failure) => fail('Should return Right'),
          (sheet) => expect(sheet?.id, id),
        );
      }
    });

    test('should handle database errors', () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Database connection error');
      when(() => mockRepository.getById(any()))
          .thenAnswer((_) async => Left(tFailure));

      final params = GetSheetMusicByIdParams(id: 1);

      // Act
      final result = await useCase.call(params);

      // Assert
      result.fold(
        (failure) => expect(failure.message, 'Database connection error'),
        (sheet) => fail('Should return Left'),
      );
    });
  });
}
