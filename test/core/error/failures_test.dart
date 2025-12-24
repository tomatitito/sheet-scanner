import 'package:flutter_test/flutter_test.dart';
import 'package:sheet_scanner/core/error/failures.dart';

void main() {
  group('Failure classes', () {
    group('GenericFailure', () {
      test('creates GenericFailure with message only', () {
        final failure = GenericFailure(message: 'Test error');
        expect(failure.message, 'Test error');
        expect(failure.code, isNull);
      });

      test('creates GenericFailure with message and code', () {
        final failure = GenericFailure(
          message: 'Test error',
          code: 'ERR_001',
        );
        expect(failure.message, 'Test error');
        expect(failure.code, 'ERR_001');
      });

      test('GenericFailure.toString() formats without code', () {
        final failure = GenericFailure(message: 'Test error');
        expect(failure.toString(), 'Failure: Test error');
      });

      test('GenericFailure.toString() formats with code', () {
        final failure = GenericFailure(
          message: 'Test error',
          code: 'ERR_001',
        );
        expect(failure.toString(), 'Failure: Test error (code: ERR_001)');
      });

      test('GenericFailure is an Exception', () {
        final failure = GenericFailure(message: 'Test');
        expect(failure, isA<Exception>());
      });
    });

    group('DatabaseFailure', () {
      test('creates DatabaseFailure with message', () {
        final failure = DatabaseFailure(message: 'Connection failed');
        expect(failure.message, 'Connection failed');
      });

      test('DatabaseFailure.toString() formats correctly', () {
        final failure = DatabaseFailure(
          message: 'Connection failed',
          code: 'DB_001',
        );
        expect(
          failure.toString(),
          'Failure: Connection failed (code: DB_001)',
        );
      });
    });

    group('FileSystemFailure', () {
      test('creates FileSystemFailure with message', () {
        final failure = FileSystemFailure(message: 'File not found');
        expect(failure.message, 'File not found');
      });

      test('FileSystemFailure.toString() formats correctly', () {
        final failure = FileSystemFailure(
          message: 'File not found',
          code: 'FS_001',
        );
        expect(
          failure.toString(),
          'Failure: File not found (code: FS_001)',
        );
      });
    });

    group('OCRFailure', () {
      test('creates OCRFailure with message', () {
        final failure = OCRFailure(message: 'Text recognition failed');
        expect(failure.message, 'Text recognition failed');
      });

      test('OCRFailure.toString() formats correctly', () {
        final failure = OCRFailure(
          message: 'Text recognition failed',
          code: 'OCR_001',
        );
        expect(
          failure.toString(),
          'Failure: Text recognition failed (code: OCR_001)',
        );
      });
    });

    group('SearchFailure', () {
      test('creates SearchFailure with message', () {
        final failure = SearchFailure(message: 'Query error');
        expect(failure.message, 'Query error');
      });

      test('SearchFailure.toString() formats correctly', () {
        final failure = SearchFailure(
          message: 'Query error',
          code: 'SEARCH_001',
        );
        expect(
          failure.toString(),
          'Failure: Query error (code: SEARCH_001)',
        );
      });
    });

    group('BackupFailure', () {
      test('creates BackupFailure with message', () {
        final failure = BackupFailure(message: 'Export failed');
        expect(failure.message, 'Export failed');
      });

      test('BackupFailure.toString() formats correctly', () {
        final failure = BackupFailure(
          message: 'Export failed',
          code: 'BACKUP_001',
        );
        expect(
          failure.toString(),
          'Failure: Export failed (code: BACKUP_001)',
        );
      });
    });

    group('ValidationFailure', () {
      test('creates ValidationFailure with message', () {
        final failure = ValidationFailure(message: 'Invalid input');
        expect(failure.message, 'Invalid input');
      });

      test('ValidationFailure.toString() formats correctly', () {
        final failure = ValidationFailure(
          message: 'Invalid input',
          code: 'VAL_001',
        );
        expect(
          failure.toString(),
          'Failure: Invalid input (code: VAL_001)',
        );
      });
    });

    group('PermissionFailure', () {
      test('creates PermissionFailure with message', () {
        final failure = PermissionFailure(message: 'Permission denied');
        expect(failure.message, 'Permission denied');
      });

      test('PermissionFailure.toString() formats correctly', () {
        final failure = PermissionFailure(
          message: 'Permission denied',
          code: 'PERM_001',
        );
        expect(
          failure.toString(),
          'Failure: Permission denied (code: PERM_001)',
        );
      });
    });

    group('PlatformFailure', () {
      test('creates PlatformFailure with message', () {
        final failure = PlatformFailure(message: 'Unsupported platform');
        expect(failure.message, 'Unsupported platform');
      });

      test('PlatformFailure.toString() formats correctly', () {
        final failure = PlatformFailure(
          message: 'Unsupported platform',
          code: 'PLAT_001',
        );
        expect(
          failure.toString(),
          'Failure: Unsupported platform (code: PLAT_001)',
        );
      });
    });

    group('Failure polymorphism', () {
      test('different failure types are distinguishable', () {
        final dbFailure = DatabaseFailure(message: 'Error');
        final fsFailure = FileSystemFailure(message: 'Error');
        final ocrFailure = OCRFailure(message: 'Error');

        expect(dbFailure, isA<DatabaseFailure>());
        expect(fsFailure, isA<FileSystemFailure>());
        expect(ocrFailure, isA<OCRFailure>());

        expect(dbFailure, isNot(fsFailure));
        expect(fsFailure, isNot(ocrFailure));
      });

      test('all failures are Exceptions', () {
        final failures = [
          GenericFailure(message: 'Error'),
          DatabaseFailure(message: 'Error'),
          FileSystemFailure(message: 'Error'),
          OCRFailure(message: 'Error'),
          SearchFailure(message: 'Error'),
          BackupFailure(message: 'Error'),
          ValidationFailure(message: 'Error'),
          PermissionFailure(message: 'Error'),
          PlatformFailure(message: 'Error'),
        ];

        for (final failure in failures) {
          expect(failure, isA<Exception>());
        }
      });

      test('all failures have consistent toString format', () {
        final failures = [
          GenericFailure(message: 'Error', code: 'G001'),
          DatabaseFailure(message: 'Error', code: 'DB001'),
          FileSystemFailure(message: 'Error', code: 'FS001'),
        ];

        for (final failure in failures) {
          expect(failure.toString(), contains('Failure:'));
          expect(failure.toString(), contains('Error'));
          expect(failure.toString(), contains('code:'));
        }
      });
    });

    group('Failure edge cases', () {
      test('handles very long error messages', () {
        final longMessage = 'E' * 1000;
        final failure = GenericFailure(message: longMessage);
        expect(failure.message.length, 1000);
      });

      test('handles special characters in messages', () {
        final failure = GenericFailure(
          message: 'Error: @#\$%^&*()_+-={}[]|:;<>?,./~`',
        );
        expect(failure.message.isNotEmpty, true);
      });

      test('handles Unicode in messages', () {
        final failure = GenericFailure(message: 'エラー 错误 خطأ');
        expect(failure.message, 'エラー 错误 خطأ');
      });

      test('handles empty code string', () {
        final failure = GenericFailure(message: 'Error', code: '');
        expect(failure.code, '');
        expect(failure.toString(), 'Failure: Error (code: )');
      });
    });
  });
}
