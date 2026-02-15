import 'dart:convert';

import 'package:flutter/services.dart';

/// Normalizes a composer name into a canonical "last, first" lowercase key.
///
/// Handles three transformations:
/// 1. Strips parenthetical annotations: "Popp, Wilhelm (Kossack)" -> "Popp, Wilhelm"
/// 2. Converts "First Last" to "Last, First": "Philippe Gaubert" -> "Gaubert, Philippe"
/// 3. Lowercases and trims
String normalizeComposerKey(String name) {
  // 1. Strip parenthetical annotations
  var normalized = name.replaceAll(RegExp(r'\s*\([^)]*\)\s*'), '').trim();

  // 2. If no comma, assume "First Last" format -> convert to "Last, First"
  if (!normalized.contains(',')) {
    final parts = normalized.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final lastName = parts.last;
      final firstNames = parts.sublist(0, parts.length - 1).join(' ');
      normalized = '$lastName, $firstNames';
    }
  }

  // 3. Lowercase
  return normalized.toLowerCase().trim();
}

/// Represents work metadata including difficulty and instrumentation.
class WorkData {
  final String title;
  final String? subtitle;
  final int? difficulty;
  final String? instrumentation;
  final String? genre;

  const WorkData({
    required this.title,
    this.subtitle,
    this.difficulty,
    this.instrumentation,
    this.genre,
  });

  factory WorkData.fromJson(Map<String, dynamic> json) {
    return WorkData(
      title: json['title'] ?? '',
      subtitle: json['subtitle'] as String?,
      difficulty: json['difficulty'] as int?,
      instrumentation: json['instrumentation'] as String?,
      genre: json['genre'] as String?,
    );
  }

  /// Display string showing difficulty indicator.
  String get difficultyDisplay {
    if (difficulty == null) return '';
    return '★' * difficulty! + '☆' * (5 - difficulty!);
  }
}

/// Extended composer data with works and Zerluth metadata.
class ComposerData {
  final String name;
  final String epoch;
  final int? birthYear;
  final int? deathYear;
  final List<WorkData> works;
  final bool isPopular;
  final bool isRecommended;

  const ComposerData({
    required this.name,
    required this.epoch,
    this.birthYear,
    this.deathYear,
    this.works = const [],
    this.isPopular = false,
    this.isRecommended = false,
  });

  String get lifeYears {
    if (birthYear == null) return '';
    if (deathYear == null) return '($birthYear–)';
    return '($birthYear–$deathYear)';
  }

  String get displayName =>
      deathYear != null || birthYear != null ? '$name $lifeYears' : name;

  /// Average difficulty of all works (1-5 scale, null if no works with difficulty).
  double? get averageDifficulty {
    final worksWithDifficulty = works.where((w) => w.difficulty != null);
    if (worksWithDifficulty.isEmpty) return null;
    return worksWithDifficulty
            .map((w) => w.difficulty!)
            .reduce((a, b) => a + b) /
        worksWithDifficulty.length;
  }

  /// Number of works available for this composer.
  int get worksCount => works.length;

  /// Creates from OpenOpus/flute_repertoire JSON format.
  factory ComposerData.fromJson(Map<String, dynamic> json) {
    int? parseYear(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return null;
      final parts = dateStr.split('-');
      if (parts.isEmpty) return null;
      return int.tryParse(parts[0]);
    }

    return ComposerData(
      name: json['complete_name'] ?? json['name'] ?? '',
      epoch: json['epoch'] ?? 'Unknown',
      birthYear: parseYear(json['birth']),
      deathYear: parseYear(json['death']),
      isPopular: json['popular'] == '1' || json['popular'] == true,
      isRecommended: json['recommended'] == '1' || json['recommended'] == true,
    );
  }

  /// Creates from Zerluth JSON format with works.
  factory ComposerData.fromZerluthJson(Map<String, dynamic> json) {
    final worksList = (json['works'] as List<dynamic>?)
            ?.map((w) => WorkData.fromJson(w as Map<String, dynamic>))
            .toList() ??
        [];

    return ComposerData(
      name: json['complete_name'] ?? json['name'] ?? '',
      epoch: json['epoch'] ?? 'Unknown',
      works: worksList,
      isPopular: json['popular'] == '1' || json['popular'] == true,
      isRecommended: json['recommended'] == '1' || json['recommended'] == true,
    );
  }

  /// Merges this composer with another, preferring non-null values.
  ///
  /// For works, deduplicates by normalized title. When a work exists in both,
  /// prefers the version with more metadata (difficulty/instrumentation).
  ComposerData merge(ComposerData other) {
    // Deduplicate works by normalized title, preferring versions with metadata
    final mergedWorks = <String, WorkData>{};
    for (final work in works) {
      mergedWorks[work.title.toLowerCase().trim()] = work;
    }
    for (final work in other.works) {
      final key = work.title.toLowerCase().trim();
      final existing = mergedWorks[key];
      if (existing == null) {
        mergedWorks[key] = work;
      } else {
        // Prefer the version with more metadata (new data wins on conflict)
        final existingHasMetadata =
            existing.difficulty != null || existing.instrumentation != null;
        final otherHasMetadata =
            work.difficulty != null || work.instrumentation != null;
        if (otherHasMetadata && !existingHasMetadata) {
          mergedWorks[key] = work;
        } else if (otherHasMetadata && existingHasMetadata) {
          // Both have metadata — new data takes priority
          mergedWorks[key] = work;
        }
        // If only existing has metadata, keep existing
      }
    }

    return ComposerData(
      name: name.isNotEmpty ? name : other.name,
      epoch: epoch != 'Unknown' ? epoch : other.epoch,
      birthYear: birthYear ?? other.birthYear,
      deathYear: deathYear ?? other.deathYear,
      works: mergedWorks.values.toList(),
      isPopular: isPopular || other.isPopular,
      isRecommended: isRecommended || other.isRecommended,
    );
  }
}

class ComposerLoader {
  static const List<String> _sourceFiles = [
    'lib/data/sources/openopus.json',
    'lib/data/sources/flute_repertoire.json',
  ];

  static const String _zerluthSource =
      'lib/data/sources/zerluth_composers.json';

  static List<ComposerData>? _cachedComposers;
  static List<String>? _cachedNames;
  static Set<String>? _cachedEpochs;
  static Map<String, ComposerData>? _composerMap;

  static Future<void> initialize() async {
    if (_cachedComposers != null) return;

    final composerMap = <String, ComposerData>{};

    // Load base composer data (OpenOpus, flute_repertoire)
    for (final assetPath in _sourceFiles) {
      try {
        final jsonString = await rootBundle.loadString(assetPath);
        final Map<String, dynamic> data = json.decode(jsonString);
        final List<dynamic> composersJson = data['composers'] ?? [];

        for (final c in composersJson) {
          final composer = ComposerData.fromJson(c as Map<String, dynamic>);
          if (composer.name.isEmpty) continue;

          final key = normalizeComposerKey(composer.name);
          if (composerMap.containsKey(key)) {
            composerMap[key] = composerMap[key]!.merge(composer);
          } else {
            composerMap[key] = composer;
          }
        }
      } catch (e) {
        // Skip missing or malformed source files
      }
    }

    // Load Zerluth data with works (prioritized for flute)
    try {
      final jsonString = await rootBundle.loadString(_zerluthSource);
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> composersJson = data['composers'] ?? [];

      for (final c in composersJson) {
        final composer =
            ComposerData.fromZerluthJson(c as Map<String, dynamic>);
        if (composer.name.isEmpty) continue;

        final key = normalizeComposerKey(composer.name);
        if (composerMap.containsKey(key)) {
          // Zerluth is the receiver so its fields take priority;
          // OpenOpus fills gaps (birth/death years, popularity flags)
          composerMap[key] = composer.merge(composerMap[key]!);
        } else {
          composerMap[key] = composer;
        }
      }
    } catch (e) {
      // Zerluth data is optional
    }

    // Sort: popular/recommended first, then alphabetically
    final sortedComposers = composerMap.values.toList()
      ..sort((a, b) {
        // Popular and recommended composers come first
        final aScore = (a.isPopular ? 2 : 0) + (a.isRecommended ? 1 : 0);
        final bScore = (b.isPopular ? 2 : 0) + (b.isRecommended ? 1 : 0);
        if (aScore != bScore) return bScore.compareTo(aScore);
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });

    _cachedComposers = sortedComposers;
    _composerMap = composerMap;
    _cachedNames = sortedComposers.map((c) => c.name).toList();
    _cachedEpochs = sortedComposers.map((c) => c.epoch).toSet();
  }

  static List<ComposerData> get composers => _cachedComposers ?? [];
  static List<String> get composerNames => _cachedNames ?? [];
  static Set<String> get epochs => _cachedEpochs ?? {};

  static bool get isInitialized => _cachedComposers != null;

  /// Get composer by name (uses normalized key for matching).
  static ComposerData? getComposer(String name) {
    return _composerMap?[normalizeComposerKey(name)];
  }

  /// Get works for a composer by name (uses normalized key for matching).
  static List<WorkData> getWorksForComposer(String name) {
    return _composerMap?[normalizeComposerKey(name)]?.works ?? const [];
  }

  /// Search composers with fuzzy matching.
  /// Matches against both the display name and the normalized key.
  static List<ComposerData> searchComposers(String query) {
    if (query.isEmpty) return composers.take(50).toList();

    final lowerQuery = query.toLowerCase();
    final normalizedQuery = normalizeComposerKey(query);
    return composers
        .where((c) =>
            c.name.toLowerCase().contains(lowerQuery) ||
            normalizeComposerKey(c.name).contains(normalizedQuery))
        .toList();
  }
}

List<ComposerData> get kComposers => ComposerLoader.composers;
List<String> get kComposerNames => ComposerLoader.composerNames;
Set<String> get kComposerEpochs => ComposerLoader.epochs;
