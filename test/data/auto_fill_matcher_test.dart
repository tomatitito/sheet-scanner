import 'package:flutter_test/flutter_test.dart';
import 'package:sheet_scanner/data/auto_fill_matcher.dart';

void main() {
  // Ensure Flutter test bindings are available (needed because the underlying
  // data loaders use rootBundle, even though our unit tests exercise the
  // matcher in an un-initialized state).
  TestWidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------------------------------------
  // FieldProvenance
  // ---------------------------------------------------------------------------
  group('FieldProvenance', () {
    test('has exactly three values', () {
      expect(FieldProvenance.values.length, 3);
    });

    test('contains empty, manual, and autoFilled', () {
      expect(FieldProvenance.values, contains(FieldProvenance.empty));
      expect(FieldProvenance.values, contains(FieldProvenance.manual));
      expect(FieldProvenance.values, contains(FieldProvenance.autoFilled));
    });

    test('enum indices are stable', () {
      expect(FieldProvenance.empty.index, 0);
      expect(FieldProvenance.manual.index, 1);
      expect(FieldProvenance.autoFilled.index, 2);
    });

    test('enum names match expected strings', () {
      expect(FieldProvenance.empty.name, 'empty');
      expect(FieldProvenance.manual.name, 'manual');
      expect(FieldProvenance.autoFilled.name, 'autoFilled');
    });
  });

  // ---------------------------------------------------------------------------
  // MatchCriteria
  // ---------------------------------------------------------------------------
  group('MatchCriteria', () {
    group('hasAnyCriteria', () {
      test('returns false when all fields are null', () {
        const criteria = MatchCriteria();
        expect(criteria.hasAnyCriteria, isFalse);
      });

      test('returns false when all string fields are empty strings', () {
        const criteria = MatchCriteria(
          composer: '',
          title: '',
          instrumentation: '',
          epoch: '',
        );
        expect(criteria.hasAnyCriteria, isFalse);
      });

      test('returns false when string fields are empty and difficulty is null',
          () {
        const criteria = MatchCriteria(
          composer: '',
          title: '',
          difficulty: null,
          instrumentation: '',
          epoch: '',
        );
        expect(criteria.hasAnyCriteria, isFalse);
      });

      test('returns true when only composer is set', () {
        const criteria = MatchCriteria(composer: 'Bach');
        expect(criteria.hasAnyCriteria, isTrue);
      });

      test('returns true when only title is set', () {
        const criteria = MatchCriteria(title: 'Sonata');
        expect(criteria.hasAnyCriteria, isTrue);
      });

      test('returns true when only difficulty is set', () {
        const criteria = MatchCriteria(difficulty: 3);
        expect(criteria.hasAnyCriteria, isTrue);
      });

      test('returns true when only instrumentation is set', () {
        const criteria = MatchCriteria(instrumentation: 'Fl,Pno');
        expect(criteria.hasAnyCriteria, isTrue);
      });

      test('returns true when only epoch is set', () {
        const criteria = MatchCriteria(epoch: 'Baroque');
        expect(criteria.hasAnyCriteria, isTrue);
      });

      test('returns true when multiple fields are set', () {
        const criteria = MatchCriteria(
          composer: 'Bach',
          title: 'Sonata',
          difficulty: 4,
          instrumentation: 'Fl',
          epoch: 'Baroque',
        );
        expect(criteria.hasAnyCriteria, isTrue);
      });

      test('returns true when difficulty is 0 (valid value)', () {
        const criteria = MatchCriteria(difficulty: 0);
        expect(criteria.hasAnyCriteria, isTrue);
      });

      test('returns true when difficulty is negative (edge case)', () {
        const criteria = MatchCriteria(difficulty: -1);
        expect(criteria.hasAnyCriteria, isTrue);
      });

      test('returns false when composer is null but title is empty', () {
        const criteria = MatchCriteria(composer: null, title: '');
        expect(criteria.hasAnyCriteria, isFalse);
      });

      test('returns true with single-character composer', () {
        const criteria = MatchCriteria(composer: 'B');
        expect(criteria.hasAnyCriteria, isTrue);
      });

      test('returns true with whitespace-only composer', () {
        // Note: whitespace-only strings are non-empty, so hasAnyCriteria is
        // true. Whether the matcher treats them as meaningful is a separate
        // concern.
        const criteria = MatchCriteria(composer: ' ');
        expect(criteria.hasAnyCriteria, isTrue);
      });
    });

    group('field access', () {
      test('stores and returns all fields correctly', () {
        const criteria = MatchCriteria(
          composer: 'Mozart',
          title: 'Eine kleine Nachtmusik',
          difficulty: 3,
          instrumentation: 'Strings',
          epoch: 'Classical',
        );

        expect(criteria.composer, 'Mozart');
        expect(criteria.title, 'Eine kleine Nachtmusik');
        expect(criteria.difficulty, 3);
        expect(criteria.instrumentation, 'Strings');
        expect(criteria.epoch, 'Classical');
      });

      test('all fields default to null', () {
        const criteria = MatchCriteria();

        expect(criteria.composer, isNull);
        expect(criteria.title, isNull);
        expect(criteria.difficulty, isNull);
        expect(criteria.instrumentation, isNull);
        expect(criteria.epoch, isNull);
      });

      test('can be constructed with const', () {
        // Verifies const constructor works (important for widget rebuilds).
        const a = MatchCriteria(composer: 'Bach');
        const b = MatchCriteria(composer: 'Bach');
        expect(identical(a, b), isTrue);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // WorkCandidate
  // ---------------------------------------------------------------------------
  group('WorkCandidate', () {
    test('constructs with required fields only', () {
      const candidate = WorkCandidate(
        composerName: 'Bach',
        title: 'Sonata in B minor',
      );

      expect(candidate.composerName, 'Bach');
      expect(candidate.title, 'Sonata in B minor');
      expect(candidate.difficulty, isNull);
      expect(candidate.instrumentation, isNull);
      expect(candidate.epoch, isNull);
    });

    test('constructs with all fields', () {
      const candidate = WorkCandidate(
        composerName: 'Debussy',
        title: 'Syrinx',
        difficulty: 4,
        instrumentation: 'Fl',
        epoch: 'romantic',
      );

      expect(candidate.composerName, 'Debussy');
      expect(candidate.title, 'Syrinx');
      expect(candidate.difficulty, 4);
      expect(candidate.instrumentation, 'Fl');
      expect(candidate.epoch, 'romantic');
    });

    test('can be constructed with const', () {
      const a = WorkCandidate(composerName: 'Bach', title: 'Syrinx');
      const b = WorkCandidate(composerName: 'Bach', title: 'Syrinx');
      expect(identical(a, b), isTrue);
    });

    test('different instances with different values are not identical', () {
      const a = WorkCandidate(composerName: 'Bach', title: 'Sonata');
      const b = WorkCandidate(composerName: 'Mozart', title: 'Sonata');
      expect(identical(a, b), isFalse);
    });
  });

  // ---------------------------------------------------------------------------
  // AutoFillResult
  // ---------------------------------------------------------------------------
  group('AutoFillResult', () {
    group('hasUniqueMatch', () {
      test('returns true when uniqueMatch is present', () {
        const result = AutoFillResult(
          uniqueMatch: WorkCandidate(
            composerName: 'Bach',
            title: 'Sonata in B minor',
          ),
          candidateCount: 1,
        );
        expect(result.hasUniqueMatch, isTrue);
      });

      test('returns false when uniqueMatch is null', () {
        const result = AutoFillResult(candidateCount: 0);
        expect(result.hasUniqueMatch, isFalse);
      });

      test('returns false when candidateCount > 1 and no unique match', () {
        const result = AutoFillResult(candidateCount: 5);
        expect(result.hasUniqueMatch, isFalse);
        expect(result.uniqueMatch, isNull);
      });
    });

    group('candidateCount', () {
      test('stores zero correctly', () {
        const result = AutoFillResult(candidateCount: 0);
        expect(result.candidateCount, 0);
      });

      test('stores positive count correctly', () {
        const result = AutoFillResult(candidateCount: 42);
        expect(result.candidateCount, 42);
      });

      test('stores 1 with a unique match', () {
        const result = AutoFillResult(
          uniqueMatch: WorkCandidate(
            composerName: 'Debussy',
            title: 'Syrinx',
            difficulty: 4,
          ),
          candidateCount: 1,
        );
        expect(result.candidateCount, 1);
        expect(result.uniqueMatch, isNotNull);
        expect(result.uniqueMatch!.composerName, 'Debussy');
        expect(result.uniqueMatch!.title, 'Syrinx');
        expect(result.uniqueMatch!.difficulty, 4);
      });
    });

    test('can be constructed with const (no match)', () {
      const a = AutoFillResult(candidateCount: 0);
      const b = AutoFillResult(candidateCount: 0);
      expect(identical(a, b), isTrue);
    });

    test('uniqueMatch carries all metadata fields', () {
      const result = AutoFillResult(
        uniqueMatch: WorkCandidate(
          composerName: 'Telemann',
          title: 'Fantasia No. 1 in A major',
          difficulty: 3,
          instrumentation: 'Fl',
          epoch: 'baroque',
        ),
        candidateCount: 1,
      );

      final match = result.uniqueMatch!;
      expect(match.composerName, 'Telemann');
      expect(match.title, 'Fantasia No. 1 in A major');
      expect(match.difficulty, 3);
      expect(match.instrumentation, 'Fl');
      expect(match.epoch, 'baroque');
    });
  });

  // ---------------------------------------------------------------------------
  // AutoFillMatcher.findMatch()
  // ---------------------------------------------------------------------------
  group('AutoFillMatcher', () {
    late AutoFillMatcher matcher;

    setUp(() {
      matcher = AutoFillMatcher();
    });

    group('findMatch with no criteria', () {
      test('returns empty result when criteria is default (all null)', () {
        const criteria = MatchCriteria();
        final result = matcher.findMatch(criteria);

        expect(result.candidateCount, 0);
        expect(result.hasUniqueMatch, isFalse);
        expect(result.uniqueMatch, isNull);
      });

      test('returns empty result when all string criteria are empty', () {
        const criteria = MatchCriteria(
          composer: '',
          title: '',
          instrumentation: '',
          epoch: '',
        );
        final result = matcher.findMatch(criteria);

        expect(result.candidateCount, 0);
        expect(result.hasUniqueMatch, isFalse);
      });
    });

    group('findMatch with unloaded data', () {
      // ComposerLoader and ComposerWorksData rely on rootBundle assets which
      // are not available during pure unit tests.  Without initialization the
      // static caches are empty, so the matcher should return 0 candidates for
      // any criteria, regardless of the query.

      test('returns 0 candidates when searching by composer name', () {
        const criteria = MatchCriteria(composer: 'Bach');
        final result = matcher.findMatch(criteria);

        expect(result.candidateCount, 0);
        expect(result.hasUniqueMatch, isFalse);
      });

      test('returns 0 candidates when searching by title', () {
        const criteria = MatchCriteria(title: 'Syrinx');
        final result = matcher.findMatch(criteria);

        expect(result.candidateCount, 0);
        expect(result.hasUniqueMatch, isFalse);
      });

      test('returns 0 candidates when searching by difficulty', () {
        const criteria = MatchCriteria(difficulty: 3);
        final result = matcher.findMatch(criteria);

        expect(result.candidateCount, 0);
        expect(result.hasUniqueMatch, isFalse);
      });

      test('returns 0 candidates when searching by instrumentation', () {
        const criteria = MatchCriteria(instrumentation: 'Fl');
        final result = matcher.findMatch(criteria);

        expect(result.candidateCount, 0);
        expect(result.hasUniqueMatch, isFalse);
      });

      test('returns 0 candidates when searching by epoch', () {
        const criteria = MatchCriteria(epoch: 'Baroque');
        final result = matcher.findMatch(criteria);

        expect(result.candidateCount, 0);
        expect(result.hasUniqueMatch, isFalse);
      });

      test('returns 0 candidates when searching by all criteria combined', () {
        const criteria = MatchCriteria(
          composer: 'Claude Debussy',
          title: 'Syrinx',
          difficulty: 4,
          instrumentation: 'Fl',
          epoch: 'Romantic',
        );
        final result = matcher.findMatch(criteria);

        expect(result.candidateCount, 0);
        expect(result.hasUniqueMatch, isFalse);
      });

      test(
          'returns 0 candidates with a nonexistent composer '
          '(no data loaded anyway)', () {
        const criteria = MatchCriteria(
          composer: 'Definitely Not A Real Composer 12345',
        );
        final result = matcher.findMatch(criteria);

        expect(result.candidateCount, 0);
        expect(result.hasUniqueMatch, isFalse);
      });
    });

    group('findMatch return type consistency', () {
      test('always returns a non-null AutoFillResult', () {
        final cases = <MatchCriteria>[
          const MatchCriteria(),
          const MatchCriteria(composer: 'Bach'),
          const MatchCriteria(title: '', composer: null),
          const MatchCriteria(difficulty: 1, epoch: 'Modern'),
        ];

        for (final criteria in cases) {
          final result = matcher.findMatch(criteria);
          expect(result, isNotNull);
          expect(result.candidateCount, isA<int>());
          expect(result.candidateCount, greaterThanOrEqualTo(0));
        }
      });
    });

    group('multiple matcher instances', () {
      test('independent instances return consistent results', () {
        final matcher1 = AutoFillMatcher();
        final matcher2 = AutoFillMatcher();

        const criteria = MatchCriteria(composer: 'Mozart');
        final result1 = matcher1.findMatch(criteria);
        final result2 = matcher2.findMatch(criteria);

        expect(result1.candidateCount, result2.candidateCount);
        expect(result1.hasUniqueMatch, result2.hasUniqueMatch);
      });
    });
  });

  // ---------------------------------------------------------------------------
  // Edge cases & integration-style checks
  // ---------------------------------------------------------------------------
  group('Edge cases', () {
    test('MatchCriteria with only whitespace composer still counts as criteria',
        () {
      const criteria = MatchCriteria(composer: '   ');
      expect(criteria.hasAnyCriteria, isTrue);
    });

    test('MatchCriteria with difficulty = 0 counts as criteria', () {
      const criteria = MatchCriteria(difficulty: 0);
      expect(criteria.hasAnyCriteria, isTrue);
    });

    test('WorkCandidate with empty strings is valid but degenerate', () {
      const candidate = WorkCandidate(composerName: '', title: '');
      expect(candidate.composerName, isEmpty);
      expect(candidate.title, isEmpty);
    });

    test('AutoFillResult with candidateCount = 1 but no uniqueMatch', () {
      // This is a structurally valid but semantically odd state: 1 candidate
      // found but uniqueMatch is null.  The class does not enforce invariants
      // beyond what the constructor accepts.
      const result = AutoFillResult(candidateCount: 1);
      expect(result.candidateCount, 1);
      expect(result.hasUniqueMatch, isFalse);
    });

    test(
        'AutoFillResult with candidateCount = 0 and a uniqueMatch '
        '(degenerate but allowed)', () {
      const result = AutoFillResult(
        uniqueMatch: WorkCandidate(composerName: 'X', title: 'Y'),
        candidateCount: 0,
      );
      // hasUniqueMatch is purely driven by uniqueMatch != null
      expect(result.hasUniqueMatch, isTrue);
      expect(result.candidateCount, 0);
    });

    test('MatchCriteria with unicode characters in composer', () {
      const criteria = MatchCriteria(composer: 'Dvořák');
      expect(criteria.hasAnyCriteria, isTrue);
      expect(criteria.composer, 'Dvořák');
    });

    test('MatchCriteria with unicode characters in title', () {
      const criteria =
          MatchCriteria(title: "Prélude à l'après-midi d'un faune");
      expect(criteria.hasAnyCriteria, isTrue);
    });

    test('MatchCriteria with very large difficulty value', () {
      const criteria = MatchCriteria(difficulty: 999999);
      expect(criteria.hasAnyCriteria, isTrue);
    });
  });
}
