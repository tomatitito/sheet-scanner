import 'package:flutter_test/flutter_test.dart';
import 'package:sheet_scanner/data/composer_works.dart';

void main() {
  group('WorkInfo', () {
    test('creates with all fields', () {
      const work = WorkInfo(
        title: 'Sonata',
        difficulty: 3,
        instrumentation: 'Fl,Pno',
        genre: 'Chamber',
      );

      expect(work.title, 'Sonata');
      expect(work.difficulty, 3);
      expect(work.instrumentation, 'Fl,Pno');
      expect(work.genre, 'Chamber');
    });

    test('creates with title only', () {
      final work = WorkInfo.titleOnly('Test Piece');

      expect(work.title, 'Test Piece');
      expect(work.difficulty, isNull);
      expect(work.instrumentation, isNull);
      expect(work.genre, isNull);
    });

    test('difficultyDisplay shows correct stars', () {
      expect(
        const WorkInfo(title: 't', difficulty: 1).difficultyDisplay,
        '★☆☆☆☆',
      );
      expect(
        const WorkInfo(title: 't', difficulty: 3).difficultyDisplay,
        '★★★☆☆',
      );
      expect(
        const WorkInfo(title: 't', difficulty: 5).difficultyDisplay,
        '★★★★★',
      );
      expect(
        const WorkInfo(title: 't').difficultyDisplay,
        '',
      );
    });
  });
}
