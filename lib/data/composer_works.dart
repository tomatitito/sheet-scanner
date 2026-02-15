/// Provides well-known works (pieces) for each composer for autocomplete suggestions.
/// Data sourced from OpenOpus and Zerluth (for flute repertoire).
library;

import 'dart:convert';

import 'package:flutter/services.dart';

import 'composers.dart';

/// Extended work info for autocomplete, combining title with metadata.
class WorkInfo {
  final String title;
  final int? difficulty;
  final String? instrumentation;
  final String? genre;

  const WorkInfo({
    required this.title,
    this.difficulty,
    this.instrumentation,
    this.genre,
  });

  /// Creates from a WorkData instance.
  factory WorkInfo.fromWorkData(WorkData data) {
    return WorkInfo(
      title: data.title,
      difficulty: data.difficulty,
      instrumentation: data.instrumentation,
      genre: data.genre,
    );
  }

  /// Creates with just a title (legacy data).
  factory WorkInfo.titleOnly(String title) {
    return WorkInfo(title: title);
  }

  /// Display string showing difficulty indicator.
  String get difficultyDisplay {
    if (difficulty == null) return '';
    return '★' * difficulty! + '☆' * (5 - difficulty!);
  }
}

/// Singleton cache for composer works data.
class ComposerWorksData {
  static ComposerWorksData? _instance;
  static Map<String, List<WorkInfo>>? _worksCache;
  static bool _legacyLoaded = false;

  ComposerWorksData._();

  /// Gets the singleton instance.
  static ComposerWorksData get instance => _instance ??= ComposerWorksData._();

  /// Whether the data has been loaded.
  bool get isLoaded => _worksCache != null;

  /// Loads the composer works from bundled assets.
  /// Prioritizes Zerluth data (with metadata), falls back to legacy JSON.
  Future<void> load() async {
    if (_worksCache != null) return;

    _worksCache = {};

    // First, ensure ComposerLoader is initialized (has Zerluth data)
    await ComposerLoader.initialize();

    // Load works from ComposerLoader (includes Zerluth data with metadata)
    for (final composer in ComposerLoader.composers) {
      if (composer.works.isEmpty) continue;

      final key = normalizeComposerKey(composer.name);
      final workInfos =
          composer.works.map((w) => WorkInfo.fromWorkData(w)).toList();

      if (_worksCache!.containsKey(key)) {
        _worksCache![key]!.addAll(workInfos);
      } else {
        _worksCache![key] = workInfos;
      }
    }

    // Load legacy composer_works.json for additional titles
    if (!_legacyLoaded) {
      try {
        final jsonString =
            await rootBundle.loadString('lib/data/composer_works.json');
        final List<dynamic> data = json.decode(jsonString) as List<dynamic>;

        for (final item in data) {
          final composerName = normalizeComposerKey(item['composer'] as String);
          final works = (item['works'] as List<dynamic>)
              .cast<String>()
              .map((title) => WorkInfo.titleOnly(title))
              .toList();

          if (_worksCache!.containsKey(composerName)) {
            // Add only titles not already present
            final existingTitles =
                _worksCache![composerName]!.map((w) => w.title.toLowerCase()).toSet();
            for (final work in works) {
              if (!existingTitles.contains(work.title.toLowerCase())) {
                _worksCache![composerName]!.add(work);
              }
            }
          } else {
            _worksCache![composerName] = works;
          }
        }
        _legacyLoaded = true;
      } catch (e) {
        // Legacy data is optional
      }
    }
  }

  /// Gets works for a specific composer (normalized key match).
  List<WorkInfo> getWorksInfoForComposer(String composerName) {
    return _worksCache?[normalizeComposerKey(composerName)] ?? const [];
  }

  /// Gets work titles for a specific composer (exact match).
  /// Returns empty list if composer not found or data not loaded.
  List<String> getWorksForComposer(String composerName) {
    return getWorksInfoForComposer(composerName).map((w) => w.title).toList();
  }

  /// Gets works for a composer (normalized key match with fuzzy fallback).
  /// Returns the first matching composer's works.
  List<String> getWorksForComposerFuzzy(String composerName) {
    if (_worksCache == null) return const [];

    final normalizedQuery = normalizeComposerKey(composerName);
    // Exact normalized match first
    if (_worksCache!.containsKey(normalizedQuery)) {
      return _worksCache![normalizedQuery]!.map((w) => w.title).toList();
    }
    // Fallback to partial match on normalized keys
    for (final entry in _worksCache!.entries) {
      if (entry.key.contains(normalizedQuery) ||
          normalizedQuery.contains(entry.key)) {
        return entry.value.map((w) => w.title).toList();
      }
    }
    return const [];
  }

  /// Gets works with full metadata for a composer (normalized key match with fuzzy fallback).
  List<WorkInfo> getWorksInfoFuzzy(String composerName) {
    if (_worksCache == null) return const [];

    final normalizedQuery = normalizeComposerKey(composerName);
    // Exact normalized match first
    if (_worksCache!.containsKey(normalizedQuery)) {
      return _worksCache![normalizedQuery]!;
    }
    // Fallback to partial match on normalized keys
    for (final entry in _worksCache!.entries) {
      if (entry.key.contains(normalizedQuery) ||
          normalizedQuery.contains(entry.key)) {
        return entry.value;
      }
    }
    return const [];
  }

  /// Gets a specific work by title for a composer.
  WorkInfo? getWork(String composerName, String title) {
    final works = getWorksInfoFuzzy(composerName);
    final lowerTitle = title.toLowerCase();
    for (final work in works) {
      if (work.title.toLowerCase() == lowerTitle) {
        return work;
      }
    }
    // Partial match
    for (final work in works) {
      if (work.title.toLowerCase().contains(lowerTitle)) {
        return work;
      }
    }
    return null;
  }

  /// Filters works matching a query string.
  List<String> filterWorks(String composerName, String query) {
    final works = getWorksForComposerFuzzy(composerName);
    if (query.isEmpty) return works;

    final lowerQuery = query.toLowerCase();
    return works.where((w) => w.toLowerCase().contains(lowerQuery)).toList();
  }

  /// Filters works with metadata matching a query string.
  List<WorkInfo> filterWorksInfo(String composerName, String query) {
    final works = getWorksInfoFuzzy(composerName);
    if (query.isEmpty) return works;

    final lowerQuery = query.toLowerCase();
    return works.where((w) => w.title.toLowerCase().contains(lowerQuery)).toList();
  }

  /// Gets all composer names that have works data.
  List<String> get composerNames => _worksCache?.keys.toList() ?? const [];

  /// Total number of works across all composers.
  int get totalWorks =>
      _worksCache?.values.fold<int>(0, (sum, works) => sum + works.length) ?? 0;
}
