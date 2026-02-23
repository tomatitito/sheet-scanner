import 'package:flutter_test/flutter_test.dart';
import 'package:sheet_scanner/data/key_signature_extractor.dart';

void main() {
  group('extractKeySignature', () {
    test('returns null for empty string', () {
      expect(extractKeySignature(''), isNull);
    });

    test('returns null when no key signature present', () {
      expect(extractKeySignature('Syrinx'), isNull);
      expect(extractKeySignature('Hungarian Rhapsody No. 2'), isNull);
    });

    group('English notation', () {
      test('extracts simple major key', () {
        expect(
          extractKeySignature('Symphony No. 40 in G major'),
          'G major',
        );
      });

      test('extracts simple minor key', () {
        expect(
          extractKeySignature('Sonata in A minor'),
          'A minor',
        );
      });

      test('extracts flat major key with hyphen', () {
        expect(
          extractKeySignature('Concerto in B-flat major'),
          'Bb major',
        );
      });

      test('extracts flat major key with space', () {
        expect(
          extractKeySignature('Concerto in B flat major'),
          'Bb major',
        );
      });

      test('extracts sharp minor key with hyphen', () {
        expect(
          extractKeySignature('Impromptu in F-sharp minor'),
          'F# minor',
        );
      });

      test('extracts sharp minor key with space', () {
        expect(
          extractKeySignature('Impromptu in F sharp minor'),
          'F# minor',
        );
      });

      test('extracts key case-insensitively', () {
        expect(
          extractKeySignature('Concerto in D Major'),
          'D major',
        );
      });

      test('extracts E flat major', () {
        expect(
          extractKeySignature('Symphony in E flat major'),
          'Eb major',
        );
      });

      test('extracts A flat major', () {
        expect(
          extractKeySignature('Sonata in A flat major'),
          'Ab major',
        );
      });

      test('extracts C sharp major', () {
        expect(
          extractKeySignature('Prelude in C sharp major'),
          'C# major',
        );
      });

      test('extracts key from complex title', () {
        expect(
          extractKeySignature(
              'Piano Concerto No. 21 in C major, K.467'),
          'C major',
        );
      });
    });

    group('German notation', () {
      test('extracts simple Dur key', () {
        expect(
          extractKeySignature('Sonate in G-Dur'),
          'G major',
        );
      });

      test('extracts simple moll key', () {
        expect(
          extractKeySignature('Triosonate in c-moll'),
          'C minor',
        );
      });

      test('extracts Es-Dur (E-flat major)', () {
        expect(
          extractKeySignature('Konzert in Es-Dur'),
          'Eb major',
        );
      });

      test('extracts fis-moll (F-sharp minor)', () {
        expect(
          extractKeySignature('Sonate in fis-moll'),
          'F# minor',
        );
      });

      test('extracts cis-moll (C-sharp minor)', () {
        expect(
          extractKeySignature('Sonate in cis-moll'),
          'C# minor',
        );
      });

      test('extracts B-Dur (B-flat major)', () {
        expect(
          extractKeySignature('Konzert in B-Dur'),
          'Bb major',
        );
      });

      test('extracts h-moll (B minor)', () {
        expect(
          extractKeySignature('Suite in h-moll'),
          'B minor',
        );
      });

      test('extracts A-Dur', () {
        expect(
          extractKeySignature('Quartett in A-Dur'),
          'A major',
        );
      });

      test('extracts D-Dur', () {
        expect(
          extractKeySignature('Sonate in D-Dur'),
          'D major',
        );
      });

      test('extracts a-moll', () {
        expect(
          extractKeySignature('Sonate in a-moll'),
          'A minor',
        );
      });

      test('extracts d-moll', () {
        expect(
          extractKeySignature('Konzert in d-moll'),
          'D minor',
        );
      });

      test('extracts e-moll', () {
        expect(
          extractKeySignature('Sonate in e-moll'),
          'E minor',
        );
      });

      test('extracts f-moll', () {
        expect(
          extractKeySignature('Konzert in f-moll'),
          'F minor',
        );
      });

      test('extracts g-moll', () {
        expect(
          extractKeySignature('Sonate in g-moll'),
          'G minor',
        );
      });

      test('extracts F-Dur', () {
        expect(
          extractKeySignature('Sonate in F-Dur'),
          'F major',
        );
      });

      test('extracts C-Dur', () {
        expect(
          extractKeySignature('Concerto in C-Dur'),
          'C major',
        );
      });

      test('extracts E-Dur', () {
        expect(
          extractKeySignature('Sonate in E-Dur'),
          'E major',
        );
      });

      test('handles German notation within Zerluth-style title', () {
        expect(
          extractKeySignature(
              'Abel: Sonate in G-Dur'),
          'G major',
        );
      });

      test('handles German notation with complex surrounding text', () {
        expect(
          extractKeySignature(
              'Abel: Triosonate in c-moll für Flöte, Violine, B.c'),
          'C minor',
        );
      });
    });
  });
}
