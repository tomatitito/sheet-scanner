import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing sheet music source values.
///
/// Sources are stored in SharedPreferences as a JSON-encoded list.
/// Default source "private" is always included if not present.
class SourceManager {
  static const String _sourcesKey = 'sheet_music_sources';
  static const String _defaultSource = 'private';

  final SharedPreferences _prefs;

  SourceManager({required SharedPreferences prefs}) : _prefs = prefs;

  /// Get all configured sources.
  /// Returns a list containing at least the default "private" source.
  List<String> getSources() {
    try {
      final sourcesJson = _prefs.getString(_sourcesKey);
      if (sourcesJson == null || sourcesJson.isEmpty) {
        return [_defaultSource];
      }

      final sources = List<String>.from(jsonDecode(sourcesJson) as List);

      // Ensure default source is always present
      if (!sources.contains(_defaultSource)) {
        sources.insert(0, _defaultSource);
      }

      return sources;
    } catch (e) {
      debugPrint('Error reading sources: $e');
      return [_defaultSource];
    }
  }

  /// Add a new source to the list.
  /// Returns true if added successfully, false if already exists or error.
  Future<bool> addSource(String source) async {
    try {
      final trimmedSource = source.trim();

      if (trimmedSource.isEmpty) {
        debugPrint('Cannot add empty source');
        return false;
      }

      final currentSources = getSources();

      if (currentSources.contains(trimmedSource)) {
        debugPrint('Source "$trimmedSource" already exists');
        return false;
      }

      currentSources.add(trimmedSource);
      await _saveSources(currentSources);
      debugPrint('Source "$trimmedSource" added successfully');
      return true;
    } catch (e) {
      debugPrint('Error adding source: $e');
      return false;
    }
  }

  /// Remove a source from the list.
  /// Cannot remove the default "private" source.
  /// Returns true if removed successfully, false otherwise.
  Future<bool> removeSource(String source) async {
    try {
      if (source == _defaultSource) {
        debugPrint('Cannot remove default source "$_defaultSource"');
        return false;
      }

      final currentSources = getSources();

      if (!currentSources.contains(source)) {
        debugPrint('Source "$source" does not exist');
        return false;
      }

      currentSources.remove(source);
      await _saveSources(currentSources);
      debugPrint('Source "$source" removed successfully');
      return true;
    } catch (e) {
      debugPrint('Error removing source: $e');
      return false;
    }
  }

  /// Save sources to SharedPreferences.
  Future<void> _saveSources(List<String> sources) async {
    final sourcesJson = jsonEncode(sources);
    await _prefs.setString(_sourcesKey, sourcesJson);
  }

  /// Initialize with default source if no sources are configured.
  Future<void> ensureDefaults() async {
    final sources = getSources();
    if (sources.isEmpty || !sources.contains(_defaultSource)) {
      await _saveSources([_defaultSource]);
    }
  }

  /// Clear all sources and reset to default.
  Future<void> resetToDefaults() async {
    await _saveSources([_defaultSource]);
    debugPrint('Sources reset to defaults');
  }
}
