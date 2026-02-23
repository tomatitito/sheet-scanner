import 'package:flutter_test/flutter_test.dart';
import 'package:sheet_scanner/data/catalog_number_extractor.dart';
import 'package:sheet_scanner/data/key_signature_extractor.dart';
import 'package:sheet_scanner/data/composers.dart';
import 'package:sheet_scanner/data/composer_works.dart';

void main() {
  group('CatalogNumberExtractor performance', () {
    late List<String> titles;

    setUp(() {
      titles = List.generate(10000, (i) {
        switch (i % 8) {
          case 0:
            return 'Symphony No. ${i + 1}, Op. ${i + 10}';
          case 1:
            return 'Piano Concerto No. ${i % 27 + 1}, K.${i + 100}';
          case 2:
            return 'Cello Suite No. ${i % 6 + 1}, BWV ${i + 500}';
          case 3:
            return 'Piano Sonata No. ${i % 32 + 1}, D.${i + 200}';
          case 4:
            return 'Hungarian Rhapsody No. ${i % 19 + 1}, S.${i + 244}';
          case 5:
            return 'String Quartet Hob.III:${i % 83 + 1}';
          case 6:
            return 'Flute Sonata in G major, Wq.${i + 130}';
          default:
            return 'Piece No. ${i + 1} for Flute and Piano';
        }
      });
    });

    test('extractCatalogNumber handles 10000 titles within time limit', () {
      final stopwatch = Stopwatch()..start();
      var matchCount = 0;

      for (final title in titles) {
        final result = extractCatalogNumber(title);
        if (result != null) matchCount++;
      }

      stopwatch.stop();

      // Verify correctness: 7 out of 8 patterns contain catalog numbers
      expect(matchCount, greaterThan(8000));
      // Performance: should complete in well under 1 second
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'extractCatalogNumber for 10000 titles took '
            '${stopwatch.elapsedMilliseconds}ms (limit: 1000ms)',
      );
    });

    test('extractAllCatalogNumbers handles 10000 titles within time limit', () {
      final stopwatch = Stopwatch()..start();
      var totalMatches = 0;

      for (final title in titles) {
        final results = extractAllCatalogNumbers(title);
        totalMatches += results.length;
      }

      stopwatch.stop();

      expect(totalMatches, greaterThan(8000));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'extractAllCatalogNumbers for 10000 titles took '
            '${stopwatch.elapsedMilliseconds}ms (limit: 1000ms)',
      );
    });

    test('handles diverse catalog number formats efficiently', () {
      // Include every recognized catalog system to stress-test the full
      // pattern list.
      final diverseTitles = List.generate(10000, (i) {
        switch (i % 20) {
          case 0:
            return 'Work Op. ${i + 1}';
          case 1:
            return 'Work K.${i + 1}';
          case 2:
            return 'Work BWV ${i + 1}';
          case 3:
            return 'Work D.${i + 1}';
          case 4:
            return 'Work S.${i + 1}';
          case 5:
            return 'Work Hob.III:${i + 1}';
          case 6:
            return 'Work HWV ${i + 1}';
          case 7:
            return 'Work RV ${i + 1}';
          case 8:
            return 'Work WWV ${i + 1}';
          case 9:
            return 'Work Wq.${i + 1}';
          case 10:
            return 'Work WAB ${i + 1}';
          case 11:
            return 'Work Sz.${i + 1}';
          case 12:
            return 'Work B.${i + 1}';
          case 13:
            return 'Work Z.${i + 1}';
          case 14:
            return 'Work L.${i + 1}';
          case 15:
            return 'Work TrV ${i + 1}';
          case 16:
            return 'Work TWV ${i + 1}:G${i % 9 + 1}';
          case 17:
            return 'Work LWV ${i + 1}';
          case 18:
            return 'Work RCT ${i + 1}';
          default:
            return 'Untitled Piece No. ${i + 1}';
        }
      });

      final stopwatch = Stopwatch()..start();
      var matchCount = 0;

      for (final title in diverseTitles) {
        final result = extractCatalogNumber(title);
        if (result != null) matchCount++;
      }

      stopwatch.stop();

      // 19 out of 20 patterns have catalog numbers
      expect(matchCount, greaterThan(9000));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Diverse catalog extraction for 10000 titles took '
            '${stopwatch.elapsedMilliseconds}ms (limit: 1000ms)',
      );
    });
  });

  group('KeySignatureExtractor performance', () {
    late List<String> titles;

    setUp(() {
      titles = List.generate(10000, (i) {
        final notes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
        final note = notes[i % notes.length];
        switch (i % 10) {
          case 0:
            return 'Symphony No. ${i + 1} in $note major';
          case 1:
            return 'Concerto in $note minor, Op. ${i + 10}';
          case 2:
            return 'Sonata in ${note}b major, K.${i + 100}';
          case 3:
            return 'Suite in $note-flat minor, BWV ${i + 500}';
          case 4:
            return 'Prelude in $note-sharp major, D.${i + 200}';
          case 5:
            return 'Konzert in $note-Dur';
          case 6:
            return 'Sonate in ${note.toLowerCase()}-moll';
          case 7:
            return 'Triosonate in Es-Dur';
          case 8:
            return 'Sonate in fis-moll';
          default:
            return 'Etude No. ${i + 1} for Solo Flute';
        }
      });
    });

    test('extractKeySignature handles 10000 titles within time limit', () {
      final stopwatch = Stopwatch()..start();
      var matchCount = 0;

      for (final title in titles) {
        final result = extractKeySignature(title);
        if (result != null) matchCount++;
      }

      stopwatch.stop();

      // 9 out of 10 patterns contain key signatures
      expect(matchCount, greaterThan(8000));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'extractKeySignature for 10000 titles took '
            '${stopwatch.elapsedMilliseconds}ms (limit: 1000ms)',
      );
    });

    test('handles mixed English and German notations efficiently', () {
      final mixedTitles = List.generate(10000, (i) {
        switch (i % 14) {
          case 0:
            return 'Concerto in C major';
          case 1:
            return 'Sonata in D minor';
          case 2:
            return 'Prelude in E-flat major';
          case 3:
            return 'Nocturne in F-sharp minor';
          case 4:
            return 'Concerto in B-flat major';
          case 5:
            return 'Waltz in A flat major';
          case 6:
            return 'Konzert in C-Dur';
          case 7:
            return 'Sonate in d-moll';
          case 8:
            return 'Quartett in Es-Dur';
          case 9:
            return 'Sonate in fis-moll';
          case 10:
            return 'Suite in h-moll';
          case 11:
            return 'Konzert in B-Dur';
          case 12:
            return 'Sonate in cis-moll';
          default:
            return 'Fantasia for Orchestra';
        }
      });

      final stopwatch = Stopwatch()..start();
      var matchCount = 0;

      for (final title in mixedTitles) {
        final result = extractKeySignature(title);
        if (result != null) matchCount++;
      }

      stopwatch.stop();

      // 13 out of 14 patterns have key signatures
      expect(matchCount, greaterThan(9000));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Mixed notation extraction for 10000 titles took '
            '${stopwatch.elapsedMilliseconds}ms (limit: 1000ms)',
      );
    });
  });

  group('WorkData.fromJson performance', () {
    test('parses 10000 work entries with metadata extraction within time limit',
        () {
      final jsonEntries = List.generate(10000, (i) {
        final notes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
        final note = notes[i % notes.length];
        final modes = ['major', 'minor'];
        final mode = modes[i % modes.length];

        return <String, dynamic>{
          'title': 'Symphony No. ${i + 1} in $note $mode, Op. ${i + 10}',
          'subtitle': i % 3 == 0 ? 'Allegro con brio' : null,
          'difficulty': (i % 5) + 1,
          'instrumentation': i % 2 == 0 ? 'Fl,Pno' : 'Fl solo',
          'genre': i % 4 == 0 ? 'Symphony' : 'Concerto',
        };
      });

      final stopwatch = Stopwatch()..start();
      final works = <WorkData>[];

      for (final json in jsonEntries) {
        works.add(WorkData.fromJson(json));
      }

      stopwatch.stop();

      // Verify metadata was extracted correctly
      expect(works.length, 10000);
      final withCatalog = works.where((w) => w.catalogNumber != null).length;
      final withKey = works.where((w) => w.musicalKey != null).length;
      expect(withCatalog, 10000, reason: 'All titles contain Op. numbers');
      expect(withKey, 10000, reason: 'All titles contain key signatures');

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'WorkData.fromJson for 10000 entries took '
            '${stopwatch.elapsedMilliseconds}ms (limit: 1000ms)',
      );
    });

    test('parses titles without metadata gracefully at scale', () {
      final jsonEntries = List.generate(10000, (i) {
        return <String, dynamic>{
          'title': 'Untitled Piece No. ${i + 1}',
        };
      });

      final stopwatch = Stopwatch()..start();
      final works = <WorkData>[];

      for (final json in jsonEntries) {
        works.add(WorkData.fromJson(json));
      }

      stopwatch.stop();

      expect(works.length, 10000);
      final withCatalog = works.where((w) => w.catalogNumber != null).length;
      final withKey = works.where((w) => w.musicalKey != null).length;
      expect(withCatalog, 0, reason: 'No titles contain catalog numbers');
      expect(withKey, 0, reason: 'No titles contain key signatures');

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'WorkData.fromJson (no metadata) for 10000 entries took '
            '${stopwatch.elapsedMilliseconds}ms (limit: 1000ms)',
      );
    });
  });

  group('WorkInfo filtering/searching performance', () {
    late List<WorkInfo> workInfoList;

    setUp(() {
      final notes = ['C', 'D', 'E', 'F', 'G', 'A', 'B'];
      final modes = ['major', 'minor'];
      final genres = [
        'Symphony',
        'Concerto',
        'Sonata',
        'Suite',
        'Nocturne',
        'Prelude',
      ];
      final instrumentations = [
        'Fl,Pno',
        'Fl solo',
        'Fl,Vn,Vc',
        'Fl,Orch',
      ];

      workInfoList = List.generate(10000, (i) {
        final note = notes[i % notes.length];
        final mode = modes[i % modes.length];
        final genre = genres[i % genres.length];

        return WorkInfo(
          title: '$genre No. ${i + 1} in $note $mode, Op. ${i + 10}',
          difficulty: (i % 5) + 1,
          instrumentation: instrumentations[i % instrumentations.length],
          genre: genre,
          catalogNumber: 'Op. ${i + 10}',
          musicalKey: '$note $mode',
        );
      });
    });

    test('title substring search across 10000 WorkInfo objects is fast', () {
      final stopwatch = Stopwatch()..start();

      // Simulate multiple search queries
      final queries = [
        'symphony',
        'concerto',
        'sonata',
        'C major',
        'Op. 50',
        'G minor',
        'suite',
        'prelude',
        'nocturne',
        'D major',
      ];

      var totalResults = 0;
      for (final query in queries) {
        final lowerQuery = query.toLowerCase();
        final results = workInfoList
            .where((w) => w.title.toLowerCase().contains(lowerQuery))
            .toList();
        totalResults += results.length;
      }

      stopwatch.stop();

      expect(totalResults, greaterThan(0));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Title search (10 queries x 10000 items) took '
            '${stopwatch.elapsedMilliseconds}ms (limit: 1000ms)',
      );
    });

    test('multi-field search across title, catalogNumber, and musicalKey', () {
      final stopwatch = Stopwatch()..start();

      final queries = [
        'Op. 100',
        'C major',
        'symphony',
        'F minor',
        'BWV',
        'D major',
        'concerto',
        'Op. 5000',
        'prelude',
        'A minor',
      ];

      var totalResults = 0;
      for (final query in queries) {
        final lowerQuery = query.toLowerCase();
        final results = workInfoList.where((w) {
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
        totalResults += results.length;
      }

      stopwatch.stop();

      expect(totalResults, greaterThan(0));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Multi-field search (10 queries x 10000 items) took '
            '${stopwatch.elapsedMilliseconds}ms (limit: 1000ms)',
      );
    });

    test('filtering by difficulty across 10000 WorkInfo objects is fast', () {
      final stopwatch = Stopwatch()..start();

      // Filter for each difficulty level
      for (var difficulty = 1; difficulty <= 5; difficulty++) {
        final results =
            workInfoList.where((w) => w.difficulty == difficulty).toList();
        expect(results.length, 2000);
      }

      stopwatch.stop();

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Difficulty filtering (5 levels x 10000 items) took '
            '${stopwatch.elapsedMilliseconds}ms (limit: 1000ms)',
      );
    });

    test('combined filter + search across 10000 WorkInfo objects is fast', () {
      final stopwatch = Stopwatch()..start();

      // Simulate realistic autocomplete: filter by query, then sort by
      // relevance (difficulty, then alphabetical).
      final queries = [
        'symphony',
        'concerto in C',
        'Op. 1',
        'sonata in G minor',
        'prelude',
      ];

      var totalResults = 0;
      for (final query in queries) {
        final lowerQuery = query.toLowerCase();
        final filtered = workInfoList
            .where((w) => w.title.toLowerCase().contains(lowerQuery))
            .toList()
          ..sort((a, b) {
            // Sort by difficulty descending, then alphabetically
            final diffCmp = (b.difficulty ?? 0).compareTo(a.difficulty ?? 0);
            if (diffCmp != 0) return diffCmp;
            return a.title.compareTo(b.title);
          });
        totalResults += filtered.length;
      }

      stopwatch.stop();

      expect(totalResults, greaterThan(0));
      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'Combined filter+sort (5 queries x 10000 items) took '
            '${stopwatch.elapsedMilliseconds}ms (limit: 1000ms)',
      );
    });
  });

  group('normalizeComposerKey performance', () {
    test('normalizes 10000 composer names within time limit', () {
      final composerNames = List.generate(10000, (i) {
        switch (i % 6) {
          case 0:
            return 'Johann Sebastian Bach';
          case 1:
            return 'Mozart, Wolfgang Amadeus';
          case 2:
            return 'Ludwig van Beethoven';
          case 3:
            return 'Popp, Wilhelm (Kossack)';
          case 4:
            return 'Philippe Gaubert';
          default:
            return 'Composer${i}Name Lastname$i';
        }
      });

      final stopwatch = Stopwatch()..start();
      final results = <String>[];

      for (final name in composerNames) {
        results.add(normalizeComposerKey(name));
      }

      stopwatch.stop();

      expect(results.length, 10000);
      // Spot-check normalization correctness
      expect(results[0], 'bach, johann sebastian');
      expect(results[1], 'mozart, wolfgang amadeus');
      expect(results[3], 'popp, wilhelm');

      expect(
        stopwatch.elapsedMilliseconds,
        lessThan(1000),
        reason: 'normalizeComposerKey for 10000 names took '
            '${stopwatch.elapsedMilliseconds}ms (limit: 1000ms)',
      );
    });
  });
}
