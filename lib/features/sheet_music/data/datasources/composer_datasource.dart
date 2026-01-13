import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/known_composer.dart';

abstract class ComposerDataSource {
  Future<List<KnownComposer>> getAllComposers();
  Future<List<KnownComposer>> searchComposers(String query);
  Future<List<KnownComposer>> getPopularComposers();
}

class ComposerDataSourceImpl implements ComposerDataSource {
  static const String _assetPath = 'lib/data/openopus_dump.json';
  List<KnownComposer>? _cachedComposers;

  @override
  Future<List<KnownComposer>> getAllComposers() async {
    if (_cachedComposers != null) {
      return _cachedComposers!;
    }

    final jsonString = await rootBundle.loadString(_assetPath);
    final Map<String, dynamic> data = json.decode(jsonString);
    final List<dynamic> composersJson = data['composers'] ?? [];

    _cachedComposers = composersJson
        .map((c) => KnownComposer(
              name: c['name'] ?? '',
              completeName: c['complete_name'] ?? c['name'] ?? '',
              epoch: c['epoch'] ?? 'Unknown',
              birth: c['birth'],
              death: c['death'],
              isPopular: c['popular'] == '1',
              isRecommended: c['recommended'] == '1',
            ))
        .toList();

    _cachedComposers!.sort((a, b) =>
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
