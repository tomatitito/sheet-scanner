import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/update_sheet_music_use_case.dart';

/// Mock for SheetMusicRepository
class MockSheetMusicRepository extends Mock implements SheetMusicRepository {}

void main() {
  group('UpdateSheetMusicUseCase', () {
    late MockSheetMusicRepository mockRepository;
    late UpdateSheetMusicUseCase useCase;

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
      useCase = UpdateSheetMusicUseCase(repository: mockRepository);
    });

    final tSheetMusic = SheetMusic(
      id: 1,
      title: 'Updated Title',
      composer: 'Updated Composer',
      notes: 'Updated notes',
      imageUrls: const ['updated.png'],
      tags: const ['updated_tag'],
      createdAt: DateTime(2025, 12, 24),
      updatedAt: DateTime(2025, 12, 25),
    );

    test('should call repository.update with correct SheetMusic', () async {
      // Arrange
      when(() => mockRepository.update(any()))
          .thenAnswer((_) async => Right(tSheetMusic));

      final params = UpdateSheetMusicParams(sheetMusic: tSheetMusic);

      // Act
      await useCase.call(params);

      // Assert
      verify(() => mockRepository.update(tSheetMusic)).called(1);
    });

    test('should return Right with updated SheetMusic on success', () async {
      // Arrange
      when(() => mockRepository.update(any()))
          .thenAnswer((_) async => Right(tSheetMusic));

      final params = UpdateSheetMusicParams(sheetMusic: tSheetMusic);

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result, isA<Right<Failure, SheetMusic>>());
      result.fold(
        (failure) => fail('Should return Right'),
        (sheet) {
          expect(sheet.title, 'Updated Title');
          expect(sheet.composer, 'Updated Composer');
        },
      );
    });

    test('should return Left with Failure on repository error', () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Update failed');
      when(() => mockRepository.update(any()))
          .thenAnswer((_) async => Left(tFailure));

      final params = UpdateSheetMusicParams(sheetMusic: tSheetMusic);

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result, isA<Left<Failure, SheetMusic>>());
      result.fold(
        (failure) => expect(failure.message, 'Update failed'),
        (sheet) => fail('Should return Left'),
      );
    });

    test('should handle updates to single field', () async {
      // Arrange
      final updatedSheet = tSheetMusic.copyWith(title: 'New Title');
      when(() => mockRepository.update(any()))
          .thenAnswer((_) async => Right(updatedSheet));

      final params = UpdateSheetMusicParams(sheetMusic: updatedSheet);

      // Act
      final result = await useCase.call(params);

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (sheet) => expect(sheet.title, 'New Title'),
      );
    });

    test('should handle updates to multiple fields', () async {
      // Arrange
      final updatedSheet = tSheetMusic.copyWith(
        title: 'New Title',
        composer: 'New Composer',
        notes: 'New notes',
      );
      when(() => mockRepository.update(any()))
          .thenAnswer((_) async => Right(updatedSheet));

      final params = UpdateSheetMusicParams(sheetMusic: updatedSheet);

      // Act
      final result = await useCase.call(params);

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (sheet) {
          expect(sheet.title, 'New Title');
          expect(sheet.composer, 'New Composer');
          expect(sheet.notes, 'New notes');
        },
      );
    });

    test('should handle updates to tags list', () async {
      // Arrange
      final updatedSheet = tSheetMusic.copyWith(
        tags: const ['new_tag1', 'new_tag2', 'new_tag3'],
      );
      when(() => mockRepository.update(any()))
          .thenAnswer((_) async => Right(updatedSheet));

      final params = UpdateSheetMusicParams(sheetMusic: updatedSheet);

      // Act
      final result = await useCase.call(params);

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (sheet) {
          expect(sheet.tags.length, 3);
          expect(sheet.tags.contains('new_tag1'), true);
        },
      );
    });

    test('should handle updates to images list', () async {
      // Arrange
      final updatedSheet = tSheetMusic.copyWith(
        imageUrls: const ['image1.png', 'image2.png'],
      );
      when(() => mockRepository.update(any()))
          .thenAnswer((_) async => Right(updatedSheet));

      final params = UpdateSheetMusicParams(sheetMusic: updatedSheet);

      // Act
      final result = await useCase.call(params);

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (sheet) => expect(sheet.imageUrls.length, 2),
      );
    });

    test('should handle not found error', () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Sheet not found');
      when(() => mockRepository.update(any()))
          .thenAnswer((_) async => Left(tFailure));

      final params = UpdateSheetMusicParams(sheetMusic: tSheetMusic);

      // Act
      final result = await useCase.call(params);

      // Assert
      result.fold(
        (failure) => expect(failure.message, 'Sheet not found'),
        (sheet) => fail('Should return Left'),
      );
    });
  });
}
