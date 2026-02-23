/// Extracts catalog/opus numbers from classical music work titles.
///
/// Recognizes standard catalog systems: Op., K., BWV, D., S., Hob., L.,
/// RV, WWV, Wq., HWV, TrV, WAB, Sz., B., Z., TWV, LWV, RCT, and more.
library;

/// Extracts catalog/opus numbers embedded in a work title string.
///
/// Returns `null` if no catalog number is found.
///
/// Examples:
///   'Piano Concerto No. 21, K.467' → 'K. 467'
///   'Symphony No. 5, op. 67' → 'Op. 67'
///   'Cello Suite No. 1, BWV 1007' → 'BWV 1007'
///   'Sonata D.960' → 'D. 960'
String? extractCatalogNumber(String title) {
  if (title.isEmpty) return null;

  // Try each pattern in priority order (more specific first)
  for (final pattern in _catalogPatterns) {
    final match = pattern.regex.firstMatch(title);
    if (match != null) {
      final raw = match.group(0)!;
      return _normalizeCatalogNumber(raw, pattern.prefix);
    }
  }

  return null;
}

/// Extracts all catalog numbers from a title (some titles have multiple).
///
/// Example: 'Concerto K.467, Op. 21' → ['K. 467', 'Op. 21']
List<String> extractAllCatalogNumbers(String title) {
  if (title.isEmpty) return const [];

  final results = <String>[];
  for (final pattern in _catalogPatterns) {
    for (final match in pattern.regex.allMatches(title)) {
      final raw = match.group(0)!;
      final normalized = _normalizeCatalogNumber(raw, pattern.prefix);
      if (!results.contains(normalized)) {
        results.add(normalized);
      }
    }
  }
  return results;
}

/// Normalizes a raw catalog match into a consistent format.
///
/// Ensures consistent spacing: 'K.467' → 'K. 467', 'op. 6' → 'Op. 6'
String _normalizeCatalogNumber(String raw, String canonicalPrefix) {
  // Find the first digit — everything from that point onward is the number part.
  // For Hob./TWV this includes the Roman numeral or letter prefix before the colon,
  // so we look for the first alphanumeric character after stripping the known prefix letters.
  final trimmed = raw.trim();

  // For Hob. patterns, the "number" part includes Roman numerals (e.g., "III:77").
  // For all other patterns, find the first digit.
  if (canonicalPrefix == 'Hob. ') {
    // Strip 'Hob' prefix in various forms, get rest
    final hob = RegExp(r'Hob\.?\s*', caseSensitive: false);
    final numberPart = trimmed.replaceFirst(hob, '').trim();
    return '$canonicalPrefix$numberPart';
  }
  if (canonicalPrefix == 'TWV ') {
    final twv = RegExp(r'TWV\s*', caseSensitive: false);
    final numberPart = trimmed.replaceFirst(twv, '').trim();
    return '$canonicalPrefix$numberPart';
  }

  // For standard patterns: find the first digit and take everything from there
  final digitIndex = trimmed.indexOf(RegExp(r'\d'));
  if (digitIndex < 0) return trimmed; // Shouldn't happen with valid matches

  final numberPart = trimmed.substring(digitIndex).trim();
  return '$canonicalPrefix$numberPart';
}

/// A catalog number pattern definition.
class _CatalogPattern {
  final RegExp regex;

  /// The canonical prefix form (e.g., 'Op. ', 'K. ', 'BWV ').
  final String prefix;

  const _CatalogPattern(this.regex, this.prefix);
}

/// Ordered list of catalog patterns. More specific patterns come first
/// to avoid false positives (e.g., 'K.' before generic 'Op.').
final List<_CatalogPattern> _catalogPatterns = [
  // Hoboken (Haydn) - complex format: Hob.XVI:52 or Hob. IX:11
  _CatalogPattern(
    RegExp(r'\bHob\.?\s*[IVXLC]+[:/]\s*\d+\w*', caseSensitive: false),
    'Hob. ',
  ),
  // TWV (Telemann) - complex format: TWV 51:G9
  _CatalogPattern(
    RegExp(r'\bTWV\s*\d+\s*:\s*\w+\d*', caseSensitive: false),
    'TWV ',
  ),
  // BWV (Bach)
  _CatalogPattern(
    RegExp(r'\bBWV?\s*\.?\s*\d+\w?', caseSensitive: false),
    'BWV ',
  ),
  // KV / K. (Mozart) - match KV or K. but not bare K followed by space+digit
  // to avoid false positives with other words starting with K
  _CatalogPattern(
    RegExp(r'\bK\.?\s*V?\.?\s*\d+\w?', caseSensitive: false),
    'K. ',
  ),
  // Wq. (C.P.E. Bach)
  _CatalogPattern(
    RegExp(r'\bWq\.?\s*\d+\w?', caseSensitive: false),
    'Wq. ',
  ),
  // WWV (Wagner)
  _CatalogPattern(
    RegExp(r'\bWWV\s*\d+\w?', caseSensitive: false),
    'WWV ',
  ),
  // WAB (Bruckner)
  _CatalogPattern(
    RegExp(r'\bWAB\s*\d+\w?', caseSensitive: false),
    'WAB ',
  ),
  // HWV (Handel)
  _CatalogPattern(
    RegExp(r'\bHWV\s*\d+\w?', caseSensitive: false),
    'HWV ',
  ),
  // RV (Vivaldi) - require at least space before digits
  _CatalogPattern(
    RegExp(r'\bRV\s+\d+\w?', caseSensitive: false),
    'RV ',
  ),
  // TrV (R. Strauss)
  _CatalogPattern(
    RegExp(r'\bTrV\s*\d+\w?', caseSensitive: false),
    'TrV ',
  ),
  // Sz. (Bartók)
  _CatalogPattern(
    RegExp(r'\bSz\.?\s*\d+\w?', caseSensitive: false),
    'Sz. ',
  ),
  // D. (Schubert) - require dot or space before digits
  _CatalogPattern(
    RegExp(r'\bD\.?\s*\d+\w?(?!\w)', caseSensitive: true),
    'D. ',
  ),
  // S. (Liszt) - require dot before digits to avoid false positives
  _CatalogPattern(
    RegExp(r'\bS\.\s*\d+\w?', caseSensitive: true),
    'S. ',
  ),
  // L. (Debussy) - require dot before digits
  _CatalogPattern(
    RegExp(r'\bL\.\s*\d+\w?', caseSensitive: true),
    'L. ',
  ),
  // B. (Dvořák) - require dot before digits
  _CatalogPattern(
    RegExp(r'\bB\.\s*\d+\w?', caseSensitive: true),
    'B. ',
  ),
  // Z. (Purcell) - require dot before digits
  _CatalogPattern(
    RegExp(r'\bZ\.\s*\d+\w?', caseSensitive: true),
    'Z. ',
  ),
  // LWV (Lully)
  _CatalogPattern(
    RegExp(r'\bLWV\s*\d+\w?', caseSensitive: false),
    'LWV ',
  ),
  // RCT (Rameau)
  _CatalogPattern(
    RegExp(r'\bRCT\s*\d+\w?', caseSensitive: false),
    'RCT ',
  ),
  // TH (Tchaikovsky)
  _CatalogPattern(
    RegExp(r'\bTH\s+\d+\w?', caseSensitive: true),
    'TH ',
  ),
  // Op./op. (generic opus number) - most common, checked last
  _CatalogPattern(
    RegExp(r'\bOp\.?\s*\d+(?:\s*(?:No\.?\s*\d+|,\s*No\.?\s*\d+))?',
        caseSensitive: false),
    'Op. ',
  ),
];
