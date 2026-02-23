import 'package:flutter_test/flutter_test.dart';
import 'package:sheet_scanner/data/catalog_number_extractor.dart';

void main() {
  group('extractCatalogNumber', () {
    test('returns null for empty string', () {
      expect(extractCatalogNumber(''), isNull);
    });

    test('returns null when no catalog number present', () {
      expect(extractCatalogNumber('Syrinx'), isNull);
      expect(extractCatalogNumber('Prélude à l\'après-midi d\'un faune'),
          isNull);
    });

    group('Opus numbers (Op.)', () {
      test('extracts op. with dot and space', () {
        expect(
          extractCatalogNumber('3 Pieces for Orchestra, op. 6'),
          'Op. 6',
        );
      });

      test('extracts Op. capitalized', () {
        expect(
          extractCatalogNumber('Symphony No. 5, Op. 67'),
          'Op. 67',
        );
      });

      test('extracts op without dot', () {
        expect(
          extractCatalogNumber('Sonata op27'),
          'Op. 27',
        );
      });

      test('extracts Op. with No.', () {
        expect(
          extractCatalogNumber('String Quartet Op. 76 No. 3'),
          'Op. 76 No. 3',
        );
      });
    });

    group('Mozart K. numbers', () {
      test('extracts K. with dot and no space', () {
        expect(
          extractCatalogNumber('Piano Concerto No. 21, K.467'),
          'K. 467',
        );
      });

      test('extracts K. with dot and space', () {
        expect(
          extractCatalogNumber('Symphony No. 40 in G minor, K. 550'),
          'K. 550',
        );
      });

      test('extracts KV format', () {
        expect(
          extractCatalogNumber('Flute Concerto KV 313'),
          'K. 313',
        );
      });
    });

    group('Bach BWV numbers', () {
      test('extracts BWV with space', () {
        expect(
          extractCatalogNumber('Cello Suite No. 1, BWV 1007'),
          'BWV 1007',
        );
      });

      test('extracts BWV without space', () {
        expect(
          extractCatalogNumber('Partita BWV1013'),
          'BWV 1013',
        );
      });
    });

    group('Schubert D. numbers', () {
      test('extracts D. with space', () {
        expect(
          extractCatalogNumber('Piano Sonata D. 960'),
          'D. 960',
        );
      });

      test('extracts D. without space', () {
        expect(
          extractCatalogNumber('Sonata D.960'),
          'D. 960',
        );
      });
    });

    group('Liszt S. numbers', () {
      test('extracts S. number', () {
        expect(
          extractCatalogNumber('Hungarian Rhapsody S.244'),
          'S. 244',
        );
      });
    });

    group('Haydn Hob. numbers', () {
      test('extracts Hob. with Roman numerals and colon', () {
        expect(
          extractCatalogNumber('String Quartet Hob.III:77'),
          'Hob. III:77',
        );
      });

      test('extracts Hob. with slash', () {
        expect(
          extractCatalogNumber('Symphony Hob.I/104'),
          'Hob. I/104',
        );
      });
    });

    group('Other catalog systems', () {
      test('extracts Wq. (CPE Bach)', () {
        expect(
          extractCatalogNumber('Sonata Wq.132'),
          'Wq. 132',
        );
      });

      test('extracts HWV (Handel)', () {
        expect(
          extractCatalogNumber('Messiah HWV 56'),
          'HWV 56',
        );
      });

      test('extracts RV (Vivaldi)', () {
        expect(
          extractCatalogNumber('The Four Seasons: Spring RV 269'),
          'RV 269',
        );
      });

      test('extracts WWV (Wagner)', () {
        expect(
          extractCatalogNumber('Die Walküre WWV 86'),
          'WWV 86',
        );
      });

      test('extracts L. (Debussy)', () {
        expect(
          extractCatalogNumber('Suite bergamasque L.75'),
          'L. 75',
        );
      });

      test('extracts WAB (Bruckner)', () {
        expect(
          extractCatalogNumber('Symphony No. 7 WAB 107'),
          'WAB 107',
        );
      });

      test('extracts Sz. (Bartók)', () {
        expect(
          extractCatalogNumber('Music for Strings Sz.106'),
          'Sz. 106',
        );
      });

      test('extracts B. (Dvořák)', () {
        expect(
          extractCatalogNumber('Symphony No. 9 B.178'),
          'B. 178',
        );
      });
    });
  });

  group('extractAllCatalogNumbers', () {
    test('returns empty list for no matches', () {
      expect(extractAllCatalogNumbers('Syrinx'), isEmpty);
    });

    test('returns single match', () {
      expect(
        extractAllCatalogNumbers('Sonata K.331'),
        ['K. 331'],
      );
    });

    test('returns multiple matches', () {
      final results = extractAllCatalogNumbers(
          'Concerto K.467, Op. 21');
      expect(results, contains('K. 467'));
      expect(results, contains('Op. 21'));
    });
  });
}
