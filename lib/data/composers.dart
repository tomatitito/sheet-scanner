import 'dart:convert';

import 'package:flutter/services.dart';

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

  String get displayName => deathYear != null || birthYear != null
      ? '$name $lifeYears'
      : name;

  /// Average difficulty of all works (1-5 scale, null if no works with difficulty).
  double? get averageDifficulty {
    final worksWithDifficulty = works.where((w) => w.difficulty != null);
    if (worksWithDifficulty.isEmpty) return null;
    return worksWithDifficulty.map((w) => w.difficulty!).reduce((a, b) => a + b) /
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
  ComposerData merge(ComposerData other) {
    return ComposerData(
      name: name.isNotEmpty ? name : other.name,
      epoch: epoch != 'Unknown' ? epoch : other.epoch,
      birthYear: birthYear ?? other.birthYear,
      deathYear: deathYear ?? other.deathYear,
      works: [...works, ...other.works],
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

  static const String _zerluthSource = 'lib/data/sources/zerluth_composers.json';

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

          final key = composer.name.toLowerCase();
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

        final key = composer.name.toLowerCase();
        if (composerMap.containsKey(key)) {
          composerMap[key] = composerMap[key]!.merge(composer);
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

  /// Get composer by name (case-insensitive).
  static ComposerData? getComposer(String name) {
    return _composerMap?[name.toLowerCase()];
  }

  /// Get works for a composer by name (case-insensitive).
  static List<WorkData> getWorksForComposer(String name) {
    return _composerMap?[name.toLowerCase()]?.works ?? const [];
  }

  /// Search composers with fuzzy matching.
  static List<ComposerData> searchComposers(String query) {
    if (query.isEmpty) return composers.take(50).toList();

    final lowerQuery = query.toLowerCase();
    return composers
        .where((c) => c.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}

List<ComposerData> get kComposers => ComposerLoader.composers;
List<String> get kComposerNames => ComposerLoader.composerNames;
Set<String> get kComposerEpochs => ComposerLoader.epochs;
