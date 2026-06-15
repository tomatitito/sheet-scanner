/// Converts the flat zerluth crawl data to the composer-grouped format
/// used by the app's data sources.
///
/// Usage: dart run tool/convert_zerluth_data.dart
library;

import 'dart:convert';
import 'dart:io';

/// ANSI color codes for terminal output
class TerminalColors {
  static const String reset = '\x1B[0m';
  static const String bold = '\x1B[1m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
}

/// Represents a crawled item from zerluth.de
class ZerluthItem {
  final String id;
  final String? composer;
  final String? title;
  final int? difficulty;
  final String? instrumentation;
  final String? category;

  ZerluthItem({
    required this.id,
    this.composer,
    this.title,
    this.difficulty,
    this.instrumentation,
    this.category,
  });

  factory ZerluthItem.fromJson(Map<String, dynamic> json) {
    return ZerluthItem(
      id: json['id'] as String,
      composer: json['composer'] as String?,
      title: json['title'] as String?,
      difficulty: json['difficulty'] as int?,
      instrumentation: json['instrumentation'] as String?,
      category: json['category'] as String?,
    );
  }
}

/// Represents a work with extended metadata
class Work {
  final String title;
  final String subtitle;
  final String searchterms;
  final int? difficulty;
  final String? instrumentation;
  final String genre;

  Work({
    required this.title,
    this.subtitle = '',
    this.searchterms = '',
    this.difficulty,
    this.instrumentation,
    this.genre = 'Chamber',
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'searchterms': searchterms,
        if (difficulty != null) 'difficulty': difficulty,
        if (instrumentation != null) 'instrumentation': instrumentation,
        'genre': genre,
        'popular': '0',
        'recommended': '0',
      };
}

/// Represents a composer with their works
class Composer {
  final String name;
  final String completeName;
  final List<Work> works;

  Composer({
    required this.name,
    required this.completeName,
    List<Work>? works,
  }) : works = works ?? [];

  Map<String, dynamic> toJson() => {
        'name': name,
        'complete_name': completeName,
        'epoch': 'Unknown',
        'popular': '0',
        'recommended': '0',
        'works': works.map((w) => w.toJson()).toList(),
      };
}

/// Extract a clean composer name from various formats
String cleanComposerName(String raw) {
  // Remove common suffixes like (Arr), (Hrsg), (Arr/Hrsg)
  var name =
      raw.replaceAll(RegExp(r'\s*\(Arr[^\)]*\)', caseSensitive: false), '');
  name =
      name.replaceAll(RegExp(r'\s*\(Hrsg[^\)]*\)', caseSensitive: false), '');
  name =
      name.replaceAll(RegExp(r'\s*/\s*.*$'), ''); // Remove co-authors after /

  // Trim and normalize whitespace
  name = name.trim().replaceAll(RegExp(r'\s+'), ' ');

  return name;
}

/// Extract short name from complete name
String extractShortName(String completeName) {
  final parts = completeName.split(',');
  if (parts.isNotEmpty) {
    return parts.first.trim();
  }
  return completeName.split(' ').last;
}

/// Guess genre from instrumentation and title
String guessGenre(String? instrumentation, String title) {
  final lowerTitle = title.toLowerCase();

  if (lowerTitle.contains('concerto')) return 'Orchestral';
  if (lowerTitle.contains('symphony')) return 'Orchestral';
  if (lowerTitle.contains('opera')) return 'Stage';
  if (lowerTitle.contains('sonata')) return 'Chamber';
  if (lowerTitle.contains('solo') || lowerTitle.contains('flöte-solo')) {
    return 'Solo';
  }
  if (lowerTitle.contains('duet') || lowerTitle.contains('zwei')) {
    return 'Chamber';
  }
  if (lowerTitle.contains('trio') || lowerTitle.contains('drei')) {
    return 'Chamber';
  }
  if (lowerTitle.contains('quartet')) return 'Chamber';
  if (lowerTitle.contains('quintet')) return 'Chamber';
  if (lowerTitle.contains('etüden') || lowerTitle.contains('studies')) {
    return 'Educational';
  }

  if (instrumentation != null) {
    final lowerInstr = instrumentation.toLowerCase();
    if (lowerInstr.contains('orchester') || lowerInstr.contains('orch')) {
      return 'Orchestral';
    }
    if (lowerInstr.contains('solo')) return 'Solo';
  }

  return 'Chamber';
}

/// Generate search terms from title
String generateSearchTerms(String title) {
  final terms = <String>[];
  final lowerTitle = title.toLowerCase();

  if (lowerTitle.contains('concerto')) terms.add('concerto');
  if (lowerTitle.contains('sonata')) terms.add('sonata');
  if (lowerTitle.contains('suite')) terms.add('suite');
  if (lowerTitle.contains('variations')) terms.add('variations');
  if (lowerTitle.contains('fantasi')) terms.add('fantasy fantasia');
  if (lowerTitle.contains('duet') || lowerTitle.contains('duo')) {
    terms.add('duet');
  }
  if (lowerTitle.contains('trio')) terms.add('trio');
  if (lowerTitle.contains('quartet')) terms.add('quartet');
  if (lowerTitle.contains('quintet')) terms.add('quintet');
  if (lowerTitle.contains('etüden') || lowerTitle.contains('stud')) {
    terms.add('etude study');
  }
  if (lowerTitle.contains('prelud')) terms.add('prelude');
  if (lowerTitle.contains('capricc')) terms.add('capriccio');
  if (lowerTitle.contains('nocturne')) terms.add('nocturne');
  if (lowerTitle.contains('serenade')) terms.add('serenade');

  return terms.join(' ');
}

Future<void> main(List<String> args) async {
  stdout.writeln('''
${TerminalColors.bold}${TerminalColors.cyan}
╔══════════════════════════════════════════════════════════════════════╗
║           Zerluth Data Converter - Flat to Grouped Format            ║
╚══════════════════════════════════════════════════════════════════════╝
${TerminalColors.reset}
''');

  const inputPath = 'lib/data/sources/zerluth_flute.json';
  const outputPath = 'lib/data/sources/zerluth_composers.json';

  // Load crawled data
  stdout.writeln(
      '${TerminalColors.cyan}Loading crawled data from $inputPath...${TerminalColors.reset}');

  final inputFile = File(inputPath);
  if (!await inputFile.exists()) {
    stdout.writeln(
        '${TerminalColors.red}Error: Input file not found. Run the crawler first.${TerminalColors.reset}');
    exit(1);
  }

  final jsonString = await inputFile.readAsString();
  final List<dynamic> rawItems = json.decode(jsonString);

  stdout.writeln(
      '${TerminalColors.green}Loaded ${rawItems.length} items${TerminalColors.reset}');

  // Parse items
  final items = rawItems
      .map((j) => ZerluthItem.fromJson(j as Map<String, dynamic>))
      .where((item) => item.composer != null && item.title != null)
      .toList();

  stdout.writeln(
      '${TerminalColors.cyan}Valid items with composer and title: ${items.length}${TerminalColors.reset}');

  // Group by composer
  final composerMap = <String, Composer>{};

  for (final item in items) {
    final rawComposer = item.composer!;
    final cleanName = cleanComposerName(rawComposer);
    final key = cleanName.toLowerCase();

    if (!composerMap.containsKey(key)) {
      composerMap[key] = Composer(
        name: extractShortName(cleanName),
        completeName: cleanName,
      );
    }

    final work = Work(
      title: item.title!,
      difficulty: item.difficulty,
      instrumentation: item.instrumentation,
      genre: guessGenre(item.instrumentation, item.title!),
      searchterms: generateSearchTerms(item.title!),
    );

    composerMap[key]!.works.add(work);
  }

  stdout.writeln(
      '${TerminalColors.cyan}Grouped into ${composerMap.length} unique composers${TerminalColors.reset}');

  // Sort composers by name and works by title
  final sortedComposers = composerMap.values.toList()
    ..sort((a, b) => a.completeName.compareTo(b.completeName));

  for (final composer in sortedComposers) {
    composer.works.sort((a, b) => a.title.compareTo(b.title));
  }

  // Create output structure
  final outputData = {
    'composers': sortedComposers.map((c) => c.toJson()).toList(),
  };

  // Write output
  final outputFile = File(outputPath);
  await outputFile.writeAsString(
    const JsonEncoder.withIndent('  ').convert(outputData),
  );

  stdout.writeln(
      '\n${TerminalColors.green}${TerminalColors.bold}Conversion complete!${TerminalColors.reset}');
  stdout.writeln(
      '${TerminalColors.cyan}Output written to: $outputPath${TerminalColors.reset}');

  // Statistics
  final totalWorks =
      sortedComposers.fold<int>(0, (sum, c) => sum + c.works.length);
  final worksWithDifficulty = items.where((i) => i.difficulty != null).length;
  final worksWithInstr = items.where((i) => i.instrumentation != null).length;

  stdout
      .writeln('\n${TerminalColors.yellow}Statistics:${TerminalColors.reset}');
  stdout.writeln('  Composers: ${sortedComposers.length}');
  stdout.writeln('  Works: $totalWorks');
  stdout.writeln(
      '  Works with difficulty: $worksWithDifficulty (${(worksWithDifficulty / totalWorks * 100).toStringAsFixed(1)}%)');
  stdout.writeln(
      '  Works with instrumentation: $worksWithInstr (${(worksWithInstr / totalWorks * 100).toStringAsFixed(1)}%)');

  // Top composers by works
  final topComposers = sortedComposers.toList()
    ..sort((a, b) => b.works.length.compareTo(a.works.length));

  stdout.writeln(
      '\n${TerminalColors.magenta}Top 10 composers by number of works:${TerminalColors.reset}');
  for (var i = 0; i < 10 && i < topComposers.length; i++) {
    final c = topComposers[i];
    stdout.writeln('  ${i + 1}. ${c.completeName}: ${c.works.length} works');
  }
}
