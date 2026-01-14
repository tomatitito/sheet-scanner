import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/known_composer.dart';

abstract class ComposerDataSource {
  Future<List<KnownComposer>> getAllComposers();
  Future<List<KnownComposer>> searchComposers(String query);
  Future<List<KnownComposer>> getPopularComposers();
}

class ComposerDataSourceImpl implements ComposerDataSource {
  static const List<String> _sourceFiles = [
    'lib/data/sources/openopus.json',
    'lib/data/sources/flute_repertoire.json',
  ];

  List<KnownComposer>? _cachedComposers;

  @override
  Future<List<KnownComposer>> getAllComposers() async {
    if (_cachedComposers != null) {
      return _cachedComposers!;
    }

    final composerMap = <String, KnownComposer>{};

    for (final assetPath in _sourceFiles) {
      try {
        final jsonString = await rootBundle.loadString(assetPath);
        final Map<String, dynamic> data = json.decode(jsonString);
        final List<dynamic> composersJson = data['composers'] ?? [];

        for (final c in composersJson) {
          final completeName = c['complete_name'] ?? c['name'] ?? '';
          if (completeName.isEmpty) continue;

          final composer = KnownComposer(
            name: c['name'] ?? '',
            completeName: completeName,
            epoch: c['epoch'] ?? 'Unknown',
            birth: c['birth'],
            death: c['death'],
            isPopular: c['popular'] == '1',
            isRecommended: c['recommended'] == '1',
          );

          composerMap[completeName.toLowerCase()] = composer;
        }
      } catch (e) {
        // Skip missing or malformed source files
      }
    }

    _cachedComposers = composerMap.values.toList()
      ..sort((a, b) =>
          a.completeName.toLowerCase().compareTo(b.completeName.toLowerCase()));

    return _cachedComposers!;
  }

  @override
  Future<List<KnownComposer>> searchComposers(String query) async {
    final composers = await getAllComposers();
    if (query.isEmpty) return composers;

    final lowerQuery = query.toLowerCase();
    return composers.where((c) {
      return c.completeName.toLowerCase().contains(lowerQuery) ||
          c.name.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  @override
  Future<List<KnownComposer>> getPopularComposers() async {
    final composers = await getAllComposers();
    return composers.where((c) => c.isPopular || c.isRecommended).toList();
  }
}
