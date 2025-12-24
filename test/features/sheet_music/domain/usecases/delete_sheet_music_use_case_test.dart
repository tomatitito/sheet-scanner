import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/delete_sheet_music_use_case.dart';

/// Mock for SheetMusicRepository
class MockSheetMusicRepository extends Mock implements SheetMusicRepository {}

void main() {
  group('DeleteSheetMusicUseCase', () {
    late MockSheetMusicRepository mockRepository;
    late DeleteSheetMusicUseCase useCase;

    setUpAll(() {
      registerFallbackValue(0);
    });

    setUp(() {
      mockRepository = MockSheetMusicRepository();
      useCase = DeleteSheetMusicUseCase(repository: mockRepository);
    });

    test('should call repository.delete with correct id', () async {
      // Arrange
      when(() => mockRepository.delete(any()))
          .thenAnswer((_) async => Right<Failure, void>(null));

      final params = DeleteSheetMusicParams(id: 1);

      // Act
      await useCase.call(params);

      // Assert
      verify(() => mockRepository.delete(1)).called(1);
    });

    test('should return Right on successful delete', () async {
      // Arrange
      when(() => mockRepository.delete(any()))
          .thenAnswer((_) async => Right<Failure, void>(null));

      final params = DeleteSheetMusicParams(id: 1);

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result, isA<Right<Failure, void>>());
    });

    test('should return Left with Failure on repository error', () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Sheet not found');
      when(() => mockRepository.delete(any()))
          .thenAnswer((_) async => Left(tFailure));

      final params = DeleteSheetMusicParams(id: 1);

      // Act
      final result = await useCase.call(params);

      // Assert
      expect(result, isA<Left<Failure, void>>());
      result.fold(
        (failure) => expect(failure.message, 'Sheet not found'),
        (_) => fail('Should return Left'),
      );
    });

    test('should handle deletion of various IDs', () async {
      // Arrange
      when(() => mockRepository.delete(any()))
          .thenAnswer((_) async => Right<Failure, void>(null));

      // Act & Assert
      for (int id in [1, 10, 100, 999]) {
        final params = DeleteSheetMusicParams(id: id);
        final result = await useCase.call(params);
        expect(result, isA<Right<Failure, void>>());
        verify(() => mockRepository.delete(id)).called(1);
      }
    });

    test('should handle database constraint errors', () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Foreign key constraint failed');
      when(() => mockRepository.delete(any()))
          .thenAnswer((_) async => Left(tFailure));

      final params = DeleteSheetMusicParams(id: 1);

      // Act
      final result = await useCase.call(params);

      // Assert
      result.fold(
        (failure) =>
            expect(failure.message, 'Foreign key constraint failed'),
        (_) => fail('Should return Left'),
      );
    });
  });
}
