/// Utility for parsing OCR extracted text to intelligently detect title and composer
class OCRTextParser {
  /// Common keywords for identifying composer fields
  static const composerKeywords = [
    'composer:',
    'by:',
    'written by:',
    'music by:',
    'composed by:',
    'author:',
  ];

  /// Common keywords for identifying title fields
  static const titleKeywords = [
    'title:',
    'name:',
    'song:',
  ];

  /// Parse OCR text to extract title and composer
  ///
  /// Attempts intelligent detection using:
  /// 1. Keyword matching (e.g., "Composer:", "By:")
  /// 2. Text position and line analysis
  /// 3. Fallback to first two non-empty lines
  static ({String title, String composer}) parseSheetMusicMetadata(
    String extractedText,
  ) {
    final lines = extractedText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      return (title: '', composer: '');
    }

    String detectedTitle = '';
    String detectedComposer = '';

    // First pass: Look for explicit keyword matches
    for (int i = 0; i < lines.length; i++) {
      final lowerLine = lines[i].toLowerCase();

      // Check for composer keywords
      for (final keyword in composerKeywords) {
        if (lowerLine.startsWith(keyword)) {
          final value = lines[i].substring(keyword.length).trim();
          if (value.isNotEmpty) {
            detectedComposer = value;
          }
        }
      }

      // Check for title keywords
      for (final keyword in titleKeywords) {
        if (lowerLine.startsWith(keyword)) {
          final value = lines[i].substring(keyword.length).trim();
          if (value.isNotEmpty) {
            detectedTitle = value;
          }
        }
      }
    }

    // If we found both, return early
    if (detectedTitle.isNotEmpty && detectedComposer.isNotEmpty) {
      return (title: detectedTitle, composer: detectedComposer);
    }

    // Second pass: Use heuristics if keywords not found
    // Title is usually the longest line at the beginning (unless it's metadata)
    final nonKeywordLines = lines.where((line) {
      final lower = line.toLowerCase();
      return !composerKeywords.any((kw) => lower.startsWith(kw)) &&
          !titleKeywords.any((kw) => lower.startsWith(kw));
    }).toList();

    if (nonKeywordLines.isEmpty) {
      // Fallback to original heuristic
      detectedTitle = lines.isNotEmpty ? lines.first : '';
      detectedComposer = lines.length > 1 ? lines[1] : '';
    } else {
      // Use the first two non-keyword lines as title and composer
      detectedTitle = nonKeywordLines.isNotEmpty ? nonKeywordLines.first : '';
      detectedComposer = nonKeywordLines.length > 1 ? nonKeywordLines[1] : '';

      // If composer is still empty but title was found from keywords,
      // use second non-keyword line as composer
      if (detectedTitle.isEmpty && nonKeywordLines.isNotEmpty) {
        detectedTitle = nonKeywordLines.first;
        if (nonKeywordLines.length > 1) {
          detectedComposer = nonKeywordLines[1];
        }
      }
    }

    return (title: detectedTitle, composer: detectedComposer);
  }

  /// Clean up OCR text by removing common noise
  static String cleanOCRText(String rawText) {
    // Remove leading/trailing whitespace
    var cleaned = rawText.trim();

    // Replace multiple spaces with single space
    cleaned = cleaned.replaceAll(RegExp(r' +'), ' ');

    // Remove common OCR artifacts
    cleaned = cleaned.replaceAll(RegExp(r'[|¡]'), '');

    return cleaned;
  }
}
