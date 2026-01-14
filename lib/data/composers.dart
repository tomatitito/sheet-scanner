import 'dart:convert';

import 'package:flutter/services.dart';

class ComposerData {
  final String name;
  final String epoch;
  final int? birthYear;
  final int? deathYear;

  const ComposerData({
    required this.name,
    required this.epoch,
    this.birthYear,
    this.deathYear,
  });

  String get lifeYears {
    if (birthYear == null) return '';
    if (deathYear == null) return '($birthYear–)';
    return '($birthYear–$deathYear)';
  }

  String get displayName => deathYear != null || birthYear != null
      ? '$name $lifeYears'
      : name;

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
    );
  }
}

class ComposerLoader {
  static const List<String> _sourceFiles = [
    'lib/data/sources/openopus.json',
    'lib/data/sources/flute_repertoire.json',
  ];

  static List<ComposerData>? _cachedComposers;
  static List<String>? _cachedNames;
  static Set<String>? _cachedEpochs;

  static Future<void> initialize() async {
    if (_cachedComposers != null) return;

    final composerMap = <String, ComposerData>{};

    for (final assetPath in _sourceFiles) {
      try {
        final jsonString = await rootBundle.loadString(assetPath);
        final Map<String, dynamic> data = json.decode(jsonString);
        final List<dynamic> composersJson = data['composers'] ?? [];

        for (final c in composersJson) {
          final composer = ComposerData.fromJson(c as Map<String, dynamic>);
          if (composer.name.isEmpty) continue;

          composerMap[composer.name.toLowerCase()] = composer;
        }
      } catch (e) {
        // Skip missing or malformed source files
      }
    }

    _cachedComposers = composerMap.values.toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    _cachedNames = _cachedComposers!.map((c) => c.name).toList();
    _cachedEpochs = _cachedComposers!.map((c) => c.epoch).toSet();
  }

  static List<ComposerData> get composers => _cachedComposers ?? [];
  static List<String> get composerNames => _cachedNames ?? [];
  static Set<String> get epochs => _cachedEpochs ?? {};

  static bool get isInitialized => _cachedComposers != null;
}

List<ComposerData> get kComposers => ComposerLoader.composers;
List<String> get kComposerNames => ComposerLoader.composerNames;
Set<String> get kComposerEpochs => ComposerLoader.epochs;
