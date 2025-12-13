import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/backup/domain/repositories/backup_repository.dart';
import 'package:sheet_scanner/features/backup/domain/usecases/export_database_use_case.dart';

class MockBackupRepository extends Mock implements BackupRepository {}

void main() {
  group('ExportDatabaseUseCase', () {
    late ExportDatabaseUseCase useCase;
    late MockBackupRepository mockRepository;

    setUp(() {
      mockRepository = MockBackupRepository();
      useCase = ExportDatabaseUseCase(repository: mockRepository);
    });

    test('calls repository.exportDatabase with correct parameters', () async {
      const mockResult = ExportResult(
        filePath: '/path/to/backup.db',
        format: 'db',
        itemCount: 0,
      );

      when(() => mockRepository.exportDatabase(customPath: null))
          .thenAnswer((_) async => Right(mockResult));

      await useCase.call();

      verify(
        () => mockRepository.exportDatabase(customPath: null),
      ).called(1);
    });

    test('passes custom path to repository', () async {
      const customPath = '/custom/path/backup.db';
      const mockResult = ExportResult(
        filePath: customPath,
        format: 'db',
        itemCount: 0,
      );

      when(() => mockRepository.exportDatabase(customPath: customPath))
          .thenAnswer((_) async => Right(mockResult));

      await useCase.call(customPath: customPath);

      verify(
        () => mockRepository.exportDatabase(customPath: customPath),
      ).called(1);
    });
  });
}
