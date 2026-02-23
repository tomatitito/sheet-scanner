import 'package:flutter_test/flutter_test.dart';
import 'package:sheet_scanner/data/composers.dart';
import 'package:sheet_scanner/data/composer_works.dart';
import 'package:sheet_scanner/data/catalog_number_extractor.dart';
import 'package:sheet_scanner/data/key_signature_extractor.dart';

void main() {
  group('Field Interdependency Integration Tests', () {
    // -----------------------------------------------------------------------
    // 1. WorkData.fromJson extracts both catalogNumber and musicalKey
    // -----------------------------------------------------------------------
    group('WorkData.fromJson extracts catalogNumber and musicalKey', () {
      test('extracts K. catalog number from Mozart title', () {
        final work = WorkData.fromJson({
          'title': 'Piano Concerto No. 21, K.467',
        });

        expect(work.title, 'Piano Concerto No. 21, K.467');
        expect(work.catalogNumber, 'K. 467');
        expect(work.musicalKey, isNull);
      });

      test('extracts both catalog number and key from title', () {
        final work = WorkData.fromJson({
          'title': 'Symphony No. 40 in G minor, K.550',
        });

        expect(work.catalogNumber, 'K. 550');
        expect(work.musicalKey, 'G minor');
      });

      test('extracts BWV catalog number from Bach title', () {
        final work = WorkData.fromJson({
          'title': 'Cello Suite No. 1, BWV 1007',
        });

        expect(work.catalogNumber, 'BWV 1007');
        expect(work.musicalKey, isNull);
      });

      test('extracts Op. catalog number', () {
        final work = WorkData.fromJson({
          'title': '3 Pieces for Orchestra, op. 6',
        });

        expect(work.catalogNumber, 'Op. 6');
        expect(work.musicalKey, isNull);
      });

      test('extracts German key signature from title', () {
        final work = WorkData.fromJson({
          'title': 'Sonate in G-Dur',
        });

        expect(work.catalogNumber, isNull);
        expect(work.musicalKey, 'G major');
      });

      test('extracts German minor key from title', () {
        final work = WorkData.fromJson({
          'title': 'Triosonate in c-moll',
        });

        expect(work.catalogNumber, isNull);
        expect(work.musicalKey, 'C minor');
      });

      test('extracts German Es-Dur as Eb major', () {
        final work = WorkData.fromJson({
          'title': 'Konzert in Es-Dur',
        });

        expect(work.catalogNumber, isNull);
        expect(work.musicalKey, 'Eb major');
      });
    });

    // -----------------------------------------------------------------------
    // 2. WorkInfo.fromWorkData preserves catalogNumber and musicalKey
    // -----------------------------------------------------------------------
    group('WorkInfo.fromWorkData preserves metadata', () {
      test('preserves catalogNumber and musicalKey from WorkData', () {
        final workData = WorkData.fromJson({
          'title': 'Symphony No. 40 in G minor, K.550',
          'difficulty': 4,
          'instrumentation': 'Orch',
          'genre': 'Orchestral',
        });

        final workInfo = WorkInfo.fromWorkData(workData);

        expect(workInfo.title, 'Symphony No. 40 in G minor, K.550');
        expect(workInfo.catalogNumber, 'K. 550');
        expect(workInfo.musicalKey, 'G minor');
        expect(workInfo.difficulty, 4);
        expect(workInfo.instrumentation, 'Orch');
        expect(workInfo.genre, 'Orchestral');
      });

      test('preserves null metadata when not extractable', () {
        final workData = WorkData.fromJson({
          'title': 'Syrinx',
          'difficulty': 4,
        });

        final workInfo = WorkInfo.fromWorkData(workData);

        expect(workInfo.title, 'Syrinx');
        expect(workInfo.catalogNumber, isNull);
        expect(workInfo.musicalKey, isNull);
        expect(workInfo.difficulty, 4);
      });

      test('preserves catalog number only (no key)', () {
        final workData = WorkData.fromJson({
          'title': 'Cello Suite No. 1, BWV 1007',
        });

        final workInfo = WorkInfo.fromWorkData(workData);

        expect(workInfo.catalogNumber, 'BWV 1007');
        expect(workInfo.musicalKey, isNull);
      });

      test('preserves key only (no catalog number)', () {
        final workData = WorkData.fromJson({
          'title': 'Sonate in G-Dur',
        });

        final workInfo = WorkInfo.fromWorkData(workData);

        expect(workInfo.catalogNumber, isNull);
        expect(workInfo.musicalKey, 'G major');
      });
    });

    // -----------------------------------------------------------------------
    // 3. WorkInfo.titleOnly has null catalogNumber and musicalKey
    // -----------------------------------------------------------------------
    group('WorkInfo.titleOnly has null metadata', () {
      test('titleOnly does not extract catalogNumber or musicalKey', () {
        final workInfo =
            WorkInfo.titleOnly('Symphony No. 40 in G minor, K.550');

        expect(workInfo.title, 'Symphony No. 40 in G minor, K.550');
        expect(workInfo.catalogNumber, isNull);
        expect(workInfo.musicalKey, isNull);
        expect(workInfo.difficulty, isNull);
        expect(workInfo.instrumentation, isNull);
        expect(workInfo.genre, isNull);
      });

      test('titleOnly with catalog number in title still has null fields', () {
        final workInfo = WorkInfo.titleOnly('Cello Suite No. 1, BWV 1007');

        expect(workInfo.catalogNumber, isNull);
        expect(workInfo.musicalKey, isNull);
      });

      test('titleOnly with German key in title still has null fields', () {
        final workInfo = WorkInfo.titleOnly('Konzert in Es-Dur');

        expect(workInfo.catalogNumber, isNull);
        expect(workInfo.musicalKey, isNull);
      });
    });

    // -----------------------------------------------------------------------
    // 4. CatalogNumber extraction with German Zerluth-style titles
    // -----------------------------------------------------------------------
    group('CatalogNumber extraction with Zerluth-style titles', () {
      test('extracts K. from German/Zerluth title with key', () {
        // Zerluth titles often combine German key notation with catalog numbers
        expect(
          extractCatalogNumber('Konzert in G-Dur, KV 313'),
          'K. 313',
        );
      });

      test('extracts BWV from prefixed Zerluth title', () {
        expect(
          extractCatalogNumber('Bach: Sonate in h-moll, BWV 1030'),
          'BWV 1030',
        );
      });

      test('extracts Op. from Zerluth-style title with instrumentation', () {
        expect(
          extractCatalogNumber(
            'Sonate in e-moll für Flöte und Klavier, op. 167',
          ),
          'Op. 167',
        );
      });

      test('extracts catalog from title with many embedded details', () {
        expect(
          extractCatalogNumber(
            'Triosonate in c-moll für Flöte, Violine, B.c., BWV 1079',
          ),
          'BWV 1079',
        );
      });

      test('no catalog number in plain German title', () {
        expect(
          extractCatalogNumber('Sonate in G-Dur'),
          isNull,
        );
      });
    });

    // -----------------------------------------------------------------------
    // 5. KeySignature extraction with English and German titles
    // -----------------------------------------------------------------------
    group('KeySignature extraction with English and German titles', () {
      test('English: extracts G minor', () {
        expect(
          extractKeySignature('Symphony No. 40 in G minor, K.550'),
          'G minor',
        );
      });

      test('English: extracts C major from complex title', () {
        expect(
          extractKeySignature('Piano Concerto No. 21 in C major, K.467'),
          'C major',
        );
      });

      test('German: extracts G major from G-Dur', () {
        expect(
          extractKeySignature('Sonate in G-Dur'),
          'G major',
        );
      });

      test('German: extracts C minor from c-moll', () {
        expect(
          extractKeySignature('Triosonate in c-moll'),
          'C minor',
        );
      });

      test('German: extracts Eb major from Es-Dur', () {
        expect(
          extractKeySignature('Konzert in Es-Dur'),
          'Eb major',
        );
      });

      test('German: extracts F# minor from fis-moll', () {
        expect(
          extractKeySignature('Sonate in fis-moll'),
          'F# minor',
        );
      });

      test('German: extracts B minor from h-moll', () {
        expect(
          extractKeySignature('Suite in h-moll'),
          'B minor',
        );
      });

      test('German: extracts Bb major from B-Dur', () {
        expect(
          extractKeySignature('Konzert in B-Dur'),
          'Bb major',
        );
      });

      test('German with Zerluth composer prefix', () {
        expect(
          extractKeySignature('Abel: Sonate in G-Dur'),
          'G major',
        );
      });

      test('German with instrumentation suffix', () {
        expect(
          extractKeySignature(
            'Abel: Triosonate in c-moll für Flöte, Violine, B.c',
          ),
          'C minor',
        );
      });
    });

    // -----------------------------------------------------------------------
    // 6. ComposerWorksData.filterWorksInfo searches across fields
    // -----------------------------------------------------------------------
    group('ComposerWorksData.filterWorksInfo cross-field search', () {
      // We construct a ComposerWorksData-like filtering scenario by
      // directly testing the filtering logic that filterWorksInfo uses.
      // Since ComposerWorksData.load() requires Flutter asset loading,
      // we test the filter logic on a list of WorkInfo objects.

      late List<WorkInfo> testWorks;

      setUp(() {
        // Create WorkInfo objects via WorkData.fromJson -> WorkInfo.fromWorkData
        // to exercise the full extraction pipeline.
        final workDataList = [
          WorkData.fromJson({
            'title': 'Piano Concerto No. 21, K.467',
            'difficulty': 5,
            'genre': 'Concerto',
          }),
          WorkData.fromJson({
            'title': 'Symphony No. 40 in G minor, K.550',
            'difficulty': 4,
            'genre': 'Orchestral',
          }),
          WorkData.fromJson({
            'title': 'Sonate in G-Dur',
            'difficulty': 3,
            'instrumentation': 'Fl,Pno',
          }),
          WorkData.fromJson({
            'title': 'Cello Suite No. 1, BWV 1007',
            'difficulty': 4,
          }),
          WorkData.fromJson({
            'title': '3 Pieces for Orchestra, op. 6',
            'difficulty': 3,
          }),
          WorkData.fromJson({
            'title': 'Konzert in Es-Dur',
            'difficulty': 2,
          }),
          WorkData.fromJson({
            'title': 'Triosonate in c-moll',
            'difficulty': 3,
          }),
        ];

        testWorks = workDataList.map(WorkInfo.fromWorkData).toList();
      });

      /// Mimics ComposerWorksData.filterWorksInfo filtering logic.
      List<WorkInfo> filterWorks(List<WorkInfo> works, String query) {
        if (query.isEmpty) return works;
        final lowerQuery = query.toLowerCase();
        return works.where((w) {
          if (w.title.toLowerCase().contains(lowerQuery)) return true;
          if (w.catalogNumber != null &&
              w.catalogNumber!.toLowerCase().contains(lowerQuery)) {
            return true;
          }
          if (w.musicalKey != null &&
              w.musicalKey!.toLowerCase().contains(lowerQuery)) {
            return true;
          }
          return false;
        }).toList();
      }

      test('filters by title substring', () {
        final results = filterWorks(testWorks, 'Piano Concerto');
        expect(results.length, 1);
        expect(results.first.title, 'Piano Concerto No. 21, K.467');
      });

      test('filters by catalog number K. 550', () {
        final results = filterWorks(testWorks, 'K. 550');
        expect(results.length, 1);
        expect(results.first.title, 'Symphony No. 40 in G minor, K.550');
        expect(results.first.catalogNumber, 'K. 550');
      });

      test('filters by catalog number BWV', () {
        final results = filterWorks(testWorks, 'BWV');
        expect(results.length, 1);
        expect(results.first.catalogNumber, 'BWV 1007');
      });

      test('filters by catalog number Op.', () {
        final results = filterWorks(testWorks, 'Op. 6');
        expect(results.length, 1);
        expect(results.first.catalogNumber, 'Op. 6');
      });

      test('filters by musical key G minor', () {
        final results = filterWorks(testWorks, 'G minor');
        expect(results.length, 1);
        expect(results.first.musicalKey, 'G minor');
      });

      test('filters by musical key G major (matches German G-Dur)', () {
        final results = filterWorks(testWorks, 'G major');
        expect(results.length, 1);
        expect(results.first.musicalKey, 'G major');
        expect(results.first.title, 'Sonate in G-Dur');
      });

      test('filters by musical key Eb major (matches German Es-Dur)', () {
        final results = filterWorks(testWorks, 'Eb major');
        expect(results.length, 1);
        expect(results.first.musicalKey, 'Eb major');
        expect(results.first.title, 'Konzert in Es-Dur');
      });

      test('filters by musical key C minor (matches German c-moll)', () {
        final results = filterWorks(testWorks, 'C minor');
        expect(results.length, 1);
        expect(results.first.musicalKey, 'C minor');
        expect(results.first.title, 'Triosonate in c-moll');
      });

      test('filters by partial catalog number K. finds multiple Mozart works',
          () {
        final results = filterWorks(testWorks, 'K.');
        // Both K.467 and K.550 should match via catalogNumber field,
        // and possibly via title too (since K. appears in both titles).
        expect(results.length, greaterThanOrEqualTo(2));
      });

      test('empty query returns all works', () {
        final results = filterWorks(testWorks, '');
        expect(results.length, testWorks.length);
      });

      test('non-matching query returns empty', () {
        final results = filterWorks(testWorks, 'Xylophone Concerto');
        expect(results, isEmpty);
      });

      test('case insensitive search by catalog number', () {
        final results = filterWorks(testWorks, 'bwv 1007');
        expect(results.length, 1);
        expect(results.first.catalogNumber, 'BWV 1007');
      });

      test('case insensitive search by musical key', () {
        final results = filterWorks(testWorks, 'eb major');
        expect(results.length, 1);
        expect(results.first.musicalKey, 'Eb major');
      });
    });

    // -----------------------------------------------------------------------
    // 7. WorkData fields all populated correctly from JSON with metadata
    // -----------------------------------------------------------------------
    group('WorkData fields fully populated from JSON', () {
      test('all fields populated from comprehensive JSON', () {
        final work = WorkData.fromJson({
          'title': 'Symphony No. 40 in G minor, K.550',
          'subtitle': 'Great G Minor Symphony',
          'difficulty': 5,
          'instrumentation': 'Orch',
          'genre': 'Orchestral',
        });

        expect(work.title, 'Symphony No. 40 in G minor, K.550');
        expect(work.subtitle, 'Great G Minor Symphony');
        expect(work.difficulty, 5);
        expect(work.instrumentation, 'Orch');
        expect(work.genre, 'Orchestral');
        expect(work.catalogNumber, 'K. 550');
        expect(work.musicalKey, 'G minor');
      });

      test('BWV title with key extracts both fields', () {
        final work = WorkData.fromJson({
          'title': 'Sonate in h-moll, BWV 1030',
          'difficulty': 4,
          'instrumentation': 'Fl,Cemb',
          'genre': 'Chamber',
        });

        expect(work.title, 'Sonate in h-moll, BWV 1030');
        expect(work.catalogNumber, 'BWV 1030');
        expect(work.musicalKey, 'B minor');
        expect(work.difficulty, 4);
        expect(work.instrumentation, 'Fl,Cemb');
        expect(work.genre, 'Chamber');
      });

      test('Op. title with German key extracts both fields', () {
        final work = WorkData.fromJson({
          'title': 'Sonate in e-moll für Flöte und Klavier, op. 167',
          'difficulty': 3,
          'instrumentation': 'Fl,Pno',
        });

        expect(work.catalogNumber, 'Op. 167');
        expect(work.musicalKey, 'E minor');
        expect(work.difficulty, 3);
        expect(work.instrumentation, 'Fl,Pno');
      });

      test('title with only catalog number, no key', () {
        final work = WorkData.fromJson({
          'title': 'Cello Suite No. 1, BWV 1007',
        });

        expect(work.catalogNumber, 'BWV 1007');
        expect(work.musicalKey, isNull);
        expect(work.difficulty, isNull);
        expect(work.instrumentation, isNull);
        expect(work.genre, isNull);
      });

      test('title with only German key, no catalog number', () {
        final work = WorkData.fromJson({
          'title': 'Konzert in Es-Dur',
        });

        expect(work.catalogNumber, isNull);
        expect(work.musicalKey, 'Eb major');
      });

      test('title with neither key nor catalog number', () {
        final work = WorkData.fromJson({
          'title': 'Syrinx',
          'difficulty': 4,
          'instrumentation': 'Fl',
          'genre': 'Solo',
        });

        expect(work.catalogNumber, isNull);
        expect(work.musicalKey, isNull);
        expect(work.difficulty, 4);
        expect(work.instrumentation, 'Fl');
        expect(work.genre, 'Solo');
      });

      test('missing title defaults to empty string', () {
        final work = WorkData.fromJson({
          'difficulty': 3,
        });

        expect(work.title, '');
        expect(work.catalogNumber, isNull);
        expect(work.musicalKey, isNull);
        expect(work.difficulty, 3);
      });

      test('English key with K. catalog extracts both correctly', () {
        final work = WorkData.fromJson({
          'title': 'Piano Concerto No. 21 in C major, K.467',
          'difficulty': 5,
        });

        expect(work.catalogNumber, 'K. 467');
        expect(work.musicalKey, 'C major');
        expect(work.difficulty, 5);
      });
    });

    // -----------------------------------------------------------------------
    // End-to-end: full pipeline from JSON through WorkData to WorkInfo search
    // -----------------------------------------------------------------------
    group('End-to-end pipeline: JSON -> WorkData -> WorkInfo -> filter', () {
      test('Zerluth-style works survive the full pipeline', () {
        // Simulate Zerluth JSON data going through the full pipeline
        final zerluthWorks = [
          {
            'title': 'Sonate in G-Dur',
            'difficulty': 3,
            'instrumentation': 'Fl,Pno',
          },
          {
            'title': 'Triosonate in c-moll für Flöte, Violine, B.c',
            'difficulty': 4,
            'instrumentation': 'Fl,Vn,Bc',
          },
          {
            'title': 'Konzert in Es-Dur, KV 313',
            'difficulty': 5,
            'instrumentation': 'Fl,Orch',
          },
        ];

        // Step 1: Parse JSON to WorkData
        final workDataList =
            zerluthWorks.map((json) => WorkData.fromJson(json)).toList();

        // Verify extraction happened at WorkData level
        expect(workDataList[0].musicalKey, 'G major');
        expect(workDataList[0].catalogNumber, isNull);

        expect(workDataList[1].musicalKey, 'C minor');
        expect(workDataList[1].catalogNumber, isNull);

        expect(workDataList[2].musicalKey, 'Eb major');
        expect(workDataList[2].catalogNumber, 'K. 313');

        // Step 2: Convert to WorkInfo
        final workInfoList = workDataList.map(WorkInfo.fromWorkData).toList();

        // Verify metadata preserved
        expect(workInfoList[0].musicalKey, 'G major');
        expect(workInfoList[0].catalogNumber, isNull);
        expect(workInfoList[0].difficulty, 3);

        expect(workInfoList[2].musicalKey, 'Eb major');
        expect(workInfoList[2].catalogNumber, 'K. 313');
        expect(workInfoList[2].difficulty, 5);

        // Step 3: Filter by extracted metadata
        final byKey = workInfoList.where(
          (w) =>
              w.musicalKey != null &&
              w.musicalKey!.toLowerCase().contains('minor'),
        );
        expect(byKey.length, 1);
        expect(
            byKey.first.title, 'Triosonate in c-moll für Flöte, Violine, B.c');

        final byCatalog = workInfoList.where(
          (w) =>
              w.catalogNumber != null &&
              w.catalogNumber!.toLowerCase().contains('k.'),
        );
        expect(byCatalog.length, 1);
        expect(byCatalog.first.title, 'Konzert in Es-Dur, KV 313');
      });

      test('mixed English and German titles all extract correctly', () {
        final mixedTitles = [
          'Piano Concerto No. 21, K.467',
          'Symphony No. 40 in G minor, K.550',
          'Sonate in G-Dur',
          'Triosonate in c-moll',
          'Cello Suite No. 1, BWV 1007',
          'Konzert in Es-Dur',
          '3 Pieces for Orchestra, op. 6',
        ];

        final works =
            mixedTitles.map((t) => WorkData.fromJson({'title': t})).toList();
        final infos = works.map(WorkInfo.fromWorkData).toList();

        // Verify catalog numbers
        expect(infos[0].catalogNumber, 'K. 467');
        expect(infos[1].catalogNumber, 'K. 550');
        expect(infos[2].catalogNumber, isNull);
        expect(infos[3].catalogNumber, isNull);
        expect(infos[4].catalogNumber, 'BWV 1007');
        expect(infos[5].catalogNumber, isNull);
        expect(infos[6].catalogNumber, 'Op. 6');

        // Verify keys
        expect(infos[0].musicalKey, isNull);
        expect(infos[1].musicalKey, 'G minor');
        expect(infos[2].musicalKey, 'G major');
        expect(infos[3].musicalKey, 'C minor');
        expect(infos[4].musicalKey, isNull);
        expect(infos[5].musicalKey, 'Eb major');
        expect(infos[6].musicalKey, isNull);
      });
    });
  });
}
