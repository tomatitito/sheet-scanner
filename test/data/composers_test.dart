import 'package:flutter_test/flutter_test.dart';
import 'package:sheet_scanner/data/composers.dart';

void main() {
  group('WorkData', () {
    test('creates from JSON correctly', () {
      final json = {
        'title': 'Sonata in G Major',
        'subtitle': 'BWV 1030',
        'difficulty': 4,
        'instrumentation': 'Fl,Pno',
        'genre': 'Chamber',
      };

      final work = WorkData.fromJson(json);

      expect(work.title, 'Sonata in G Major');
      expect(work.subtitle, 'BWV 1030');
      expect(work.difficulty, 4);
      expect(work.instrumentation, 'Fl,Pno');
      expect(work.genre, 'Chamber');
      expect(work.musicalKey, 'G major');
      expect(work.catalogNumber, isNull);
    });

    test('extracts catalog number from title', () {
      final json = {
        'title': 'Piano Concerto No. 21, K.467',
        'difficulty': 5,
      };

      final work = WorkData.fromJson(json);

      expect(work.title, 'Piano Concerto No. 21, K.467');
      expect(work.catalogNumber, 'K. 467');
    });

    test('extracts both catalog number and key from title', () {
      final json = {
        'title': 'Symphony No. 40 in G minor, K.550',
      };

      final work = WorkData.fromJson(json);

      expect(work.catalogNumber, 'K. 550');
      expect(work.musicalKey, 'G minor');
    });

    test('handles missing fields gracefully', () {
      final json = {'title': 'Test Piece'};

      final work = WorkData.fromJson(json);

      expect(work.title, 'Test Piece');
      expect(work.subtitle, isNull);
      expect(work.difficulty, isNull);
      expect(work.instrumentation, isNull);
      expect(work.genre, isNull);
      expect(work.catalogNumber, isNull);
      expect(work.musicalKey, isNull);
    });

    test('difficultyDisplay shows correct stars', () {
      expect(
        const WorkData(title: 't', difficulty: 1).difficultyDisplay,
        '★☆☆☆☆',
      );
      expect(
        const WorkData(title: 't', difficulty: 3).difficultyDisplay,
        '★★★☆☆',
      );
      expect(
        const WorkData(title: 't', difficulty: 5).difficultyDisplay,
        '★★★★★',
      );
      expect(
        const WorkData(title: 't').difficultyDisplay,
        '',
      );
    });
  });

  group('ComposerData', () {
    test('creates from JSON correctly', () {
      final json = {
        'complete_name': 'Johann Sebastian Bach',
        'name': 'Bach',
        'epoch': 'Baroque',
        'birth': '1685-03-21',
        'death': '1750-07-28',
        'popular': '1',
        'recommended': '0',
      };

      final composer = ComposerData.fromJson(json);

      expect(composer.name, 'Johann Sebastian Bach');
      expect(composer.epoch, 'Baroque');
      expect(composer.birthYear, 1685);
      expect(composer.deathYear, 1750);
      expect(composer.isPopular, true);
      expect(composer.isRecommended, false);
    });

    test('creates from Zerluth JSON with works', () {
      final json = {
        'complete_name': 'Claude Debussy',
        'name': 'Debussy',
        'epoch': 'Romantic',
        'popular': '1',
        'recommended': '1',
        'works': [
          {
            'title': 'Syrinx',
            'difficulty': 4,
            'instrumentation': 'Fl',
            'genre': 'Solo',
          },
          {
            'title': 'Prélude à l\'après-midi d\'un faune',
            'difficulty': 5,
            'instrumentation': 'Fl,Orch',
            'genre': 'Orchestral',
          },
        ],
      };

      final composer = ComposerData.fromZerluthJson(json);

      expect(composer.name, 'Claude Debussy');
      expect(composer.epoch, 'Romantic');
      expect(composer.isPopular, true);
      expect(composer.isRecommended, true);
      expect(composer.works.length, 2);
      expect(composer.works[0].title, 'Syrinx');
      expect(composer.works[0].difficulty, 4);
      expect(composer.works[1].instrumentation, 'Fl,Orch');
    });

    test('lifeYears formats correctly', () {
      expect(
        const ComposerData(
          name: 'Bach',
          epoch: 'Baroque',
          birthYear: 1685,
          deathYear: 1750,
        ).lifeYears,
        '(1685–1750)',
      );

      expect(
        const ComposerData(
          name: 'Living',
          epoch: 'Contemporary',
          birthYear: 1950,
        ).lifeYears,
        '(1950–)',
      );

      expect(
        const ComposerData(name: 'Unknown', epoch: 'Unknown').lifeYears,
        '',
      );
    });

    test('displayName includes life years when available', () {
      expect(
        const ComposerData(
          name: 'Mozart',
          epoch: 'Classical',
          birthYear: 1756,
          deathYear: 1791,
        ).displayName,
        'Mozart (1756–1791)',
      );

      expect(
        const ComposerData(name: 'Unknown', epoch: 'Unknown').displayName,
        'Unknown',
      );
    });

    test('averageDifficulty calculates correctly', () {
      const composer = ComposerData(
        name: 'Test',
        epoch: 'Test',
        works: [
          WorkData(title: 'A', difficulty: 2),
          WorkData(title: 'B', difficulty: 4),
          WorkData(title: 'C', difficulty: 3),
        ],
      );

      expect(composer.averageDifficulty, 3.0);
    });

    test('averageDifficulty ignores works without difficulty', () {
      const composer = ComposerData(
        name: 'Test',
        epoch: 'Test',
        works: [
          WorkData(title: 'A', difficulty: 2),
          WorkData(title: 'B'), // No difficulty
          WorkData(title: 'C', difficulty: 4),
        ],
      );

      expect(composer.averageDifficulty, 3.0);
    });

    test('averageDifficulty returns null when no works have difficulty', () {
      const composer = ComposerData(
        name: 'Test',
        epoch: 'Test',
        works: [
          WorkData(title: 'A'),
          WorkData(title: 'B'),
        ],
      );

      expect(composer.averageDifficulty, isNull);
    });

    test('worksCount returns correct count', () {
      const composer = ComposerData(
        name: 'Test',
        epoch: 'Test',
        works: [
          WorkData(title: 'A'),
          WorkData(title: 'B'),
          WorkData(title: 'C'),
        ],
      );

      expect(composer.worksCount, 3);
    });

    test('merge combines composers correctly', () {
      const composer1 = ComposerData(
        name: 'Bach',
        epoch: 'Baroque',
        birthYear: 1685,
        deathYear: 1750,
        isPopular: true,
        works: [WorkData(title: 'Work 1')],
      );

      const composer2 = ComposerData(
        name: 'Johann Sebastian Bach',
        epoch: 'Unknown', // Should be ignored
        isRecommended: true,
        works: [WorkData(title: 'Work 2')],
      );

      final merged = composer1.merge(composer2);

      // Prefer non-empty/non-Unknown values
      expect(merged.name, 'Bach');
      expect(merged.epoch, 'Baroque');
      expect(merged.birthYear, 1685);
      expect(merged.deathYear, 1750);
      // OR flags from both
      expect(merged.isPopular, true);
      expect(merged.isRecommended, true);
      // Combine works
      expect(merged.works.length, 2);
    });
  });
}
