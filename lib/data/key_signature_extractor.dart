/// Extracts musical key signatures from classical music work titles.
///
/// Handles both English notation ('in G major', 'in B-flat minor')
/// and German notation ('G-Dur', 'c-moll', 'Es-Dur', 'fis-moll').
///
/// Output is normalized to English format: '{Note}{Accidental} {Mode}'
/// Examples: 'G major', 'C minor', 'F# minor', 'Bb major', 'Eb major'
library;

/// Extracts the musical key signature from a work title string.
///
/// Returns a normalized key string, or `null` if no key is found.
///
/// Examples:
///   'Symphony No. 40 in G minor' → 'G minor'
///   'Concerto in B-flat major' → 'Bb major'
///   'Sonate in G-Dur' → 'G major'
///   'Triosonate in c-moll' → 'C minor'
///   'Concerto in Es-Dur' → 'Eb major'
///   'Sonate in fis-moll' → 'F# minor'
String? extractKeySignature(String title) {
  if (title.isEmpty) return null;

  // Try English notation first (more explicit)
  final englishMatch = _englishKeyPattern.firstMatch(title);
  if (englishMatch != null) {
    return _normalizeEnglishKey(englishMatch);
  }

  // Try German notation
  final germanMatch = _germanKeyPattern.firstMatch(title);
  if (germanMatch != null) {
    return _normalizeGermanKey(germanMatch.group(0)!);
  }

  return null;
}

// ---------------------------------------------------------------------------
// English notation
// ---------------------------------------------------------------------------

/// Matches English key signatures: 'in A major', 'in B-flat minor',
/// 'in F sharp major', 'in C# minor', etc.
final RegExp _englishKeyPattern = RegExp(
  r'\bin\s+'
  r'([A-G])'
  r'(?:'
  r'(?:\s*-?\s*flat|b)'
  r'|(?:\s*-?\s*sharp|#)'
  r')?'
  r'\s+'
  r'(major|minor)',
  caseSensitive: false,
);

/// Normalizes an English key match to canonical form.
String _normalizeEnglishKey(RegExpMatch match) {
  final full = match.group(0)!;
  // Re-parse the full match for the note + accidental + mode
  final parsed = RegExp(
    r'in\s+([A-G])\s*(-?\s*flat|b|-?\s*sharp|#)?\s+(major|minor)',
    caseSensitive: false,
  ).firstMatch(full);

  if (parsed == null) return full;

  final note = parsed.group(1)!.toUpperCase();
  final accidentalRaw = parsed.group(2)?.trim().toLowerCase() ?? '';
  final mode = parsed.group(3)!.toLowerCase();

  String accidental = '';
  if (accidentalRaw.contains('flat') || accidentalRaw == 'b') {
    accidental = 'b';
  } else if (accidentalRaw.contains('sharp') || accidentalRaw == '#') {
    accidental = '#';
  }

  return '$note$accidental $mode';
}

// ---------------------------------------------------------------------------
// German notation
// ---------------------------------------------------------------------------

/// Matches German key signatures: 'G-Dur', 'c-moll', 'Es-Dur', 'fis-moll',
/// 'Cis-Dur', 'b-moll', etc.
///
/// In German notation, flat notes use `-es` suffix (shortened to `-s` after
/// vowels): C→Ces, D→Des, E→Es, F→Fes, G→Ges, A→As. Sharp notes use `-is`.
/// H = B natural, B = Bb. The `-Dur`/`-moll` suffix indicates major/minor.
///
/// Longer note names (Fis, Ces, etc.) are listed first so they match before
/// the single-letter alternatives.
final RegExp _germanKeyPattern = RegExp(
  r'\b('
  // Flats (longer first): Ces, Des, Es, Fes, Ges, As
  r'[Cc]es|[Dd]es|[Ee]s|[Ff]es|[Gg]es|[Aa]s|'
  // Sharps: Cis, Dis, Eis, Fis, Gis, Ais, His
  r'[Cc]is|[Dd]is|[Ee]is|[Ff]is|[Gg]is|[Aa]is|[Hh]is|'
  // Natural notes (single letter)
  r'[A-Ha-h]'
  r')\s*-\s*(Dur|dur|Moll|moll)\b',
);

/// Normalizes a German key to English format.
String _normalizeGermanKey(String germanKey) {
  final match = _germanKeyPattern.firstMatch(germanKey);
  if (match == null) return germanKey;

  final noteRaw = match.group(1)!;
  final modeRaw = match.group(2)!.toLowerCase();

  final mode = modeRaw == 'dur' ? 'major' : 'minor';
  final note = _germanNoteToEnglish(noteRaw);

  return '$note $mode';
}

/// Converts a German note name to its English equivalent.
///
/// Handles: C, D, E, F, G, A, H(=B), B(=Bb),
/// plus -is (sharp) and -es (flat) suffixes.
String _germanNoteToEnglish(String germanNote) {
  // Normalize to lowercase for matching
  final lower = germanNote.toLowerCase();

  // Check compound suffixes first
  if (lower.length > 1) {
    // -is suffix = sharp
    if (lower.endsWith('is')) {
      final base = lower.substring(0, lower.length - 2);
      final englishBase = _germanBaseToEnglish(base);
      return '$englishBase#';
    }
    // -es suffix = flat (but 'es' alone = Eb, 'as' = Ab)
    if (lower.endsWith('es')) {
      final base = lower.substring(0, lower.length - 2);
      if (base.isEmpty) {
        // 'es' alone = Eb
        return 'Eb';
      }
      final englishBase = _germanBaseToEnglish(base);
      return '${englishBase}b';
    }
    // 'as' = Ab
    if (lower == 'as') {
      return 'Ab';
    }
  }

  // Single letter
  return _germanBaseToEnglish(lower);
}

/// Converts a single German base note letter to English.
String _germanBaseToEnglish(String base) {
  switch (base.toLowerCase()) {
    case 'h':
      return 'B';
    case 'b':
      return 'Bb';
    default:
      return base.toUpperCase();
  }
}
