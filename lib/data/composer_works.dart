/// Provides well-known works (pieces) for each composer for autocomplete suggestions.
/// Data sourced from OpenOpus - only popular and recommended works included.
library;

import 'dart:convert';

import 'package:flutter/services.dart';

/// Singleton cache for composer works data.
class ComposerWorksData {
  static ComposerWorksData? _instance;
  static Map<String, List<String>>? _worksCache;

  ComposerWorksData._();

  /// Gets the singleton instance.
  static ComposerWorksData get instance => _instance ??= ComposerWorksData._();

  /// Whether the data has been loaded.
  bool get isLoaded => _worksCache != null;

  /// Loads the composer works from the bundled JSON asset.
  /// Call this during app initialization or lazily before first use.
  Future<void> load() async {
    if (_worksCache != null) return;

    final jsonString =
        await rootBundle.loadString('lib/data/composer_works.json');
    final List<dynamic> data = json.decode(jsonString) as List<dynamic>;

    _worksCache = {};
    for (final item in data) {
      final composerName = item['composer'] as String;
      final works = (item['works'] as List<dynamic>).cast<String>();
      _worksCache![composerName] = works;
    }
  }

  /// Gets works for a specific composer (exact match).
  /// Returns empty list if composer not found or data not loaded.
  List<String> getWorksForComposer(String composerName) {
    return _worksCache?[composerName] ?? const [];
  }

  /// Gets works for a composer (case-insensitive partial match).
  /// Returns the first matching composer's works.
  List<String> getWorksForComposerFuzzy(String composerName) {
    if (_worksCache == null) return const [];

    final lowerQuery = composerName.toLowerCase();
    for (final entry in _worksCache!.entries) {
      if (entry.key.toLowerCase() == lowerQuery) {
        return entry.value;
      }
    }
    // Fallback to partial match
    for (final entry in _worksCache!.entries) {
      if (entry.key.toLowerCase().contains(lowerQuery)) {
        return entry.value;
      }
    }
    return const [];
  }

  /// Filters works matching a query string.
  List<String> filterWorks(String composerName, String query) {
    final works = getWorksForComposerFuzzy(composerName);
    if (query.isEmpty) return works;

    final lowerQuery = query.toLowerCase();
    return works.where((w) => w.toLowerCase().contains(lowerQuery)).toList();
  }

  /// Gets all composer names that have works data.
  List<String> get composerNames => _worksCache?.keys.toList() ?? const [];

  /// Total number of works across all composers.
  int get totalWorks =>
      _worksCache?.values.fold<int>(0, (sum, works) => sum + works.length) ?? 0;
}
