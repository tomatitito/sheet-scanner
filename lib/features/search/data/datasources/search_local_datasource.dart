import 'package:sheet_scanner/core/database/database.dart';

/// Abstract interface for search data source operations.
abstract class SearchLocalDataSource {
  /// Performs full-text search across sheet music.
  /// [query] is the search string
  Future<List<SheetMusicModel>> fullTextSearch(String query);

  /// Searches by exact title match.
  Future<List<SheetMusicModel>> searchByTitle(String title);

  /// Searches by exact composer match.
  Future<List<SheetMusicModel>> searchByComposer(String composer);

  /// Filters sheet music by multiple tags.
  Future<List<SheetMusicModel>> filterByTags(List<String> tags);

  /// Filters sheet music by date range.
  Future<List<SheetMusicModel>> filterByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Advanced search with multiple criteria.
  Future<List<SheetMusicModel>> advancedSearch({
    String? query,
    List<String>? tags,
    String? composer,
    String? sortBy,
    bool descending,
  });
}

/// Implementation of SearchLocalDataSource using Drift.
/// Uses FTS5 for full-text search and Drift queries for filtering.
class SearchLocalDataSourceImpl implements SearchLocalDataSource {
  final AppDatabase database;

  SearchLocalDataSourceImpl({required this.database});

  @override
  Future<List<SheetMusicModel>> advancedSearch({
    String? query,
    List<String>? tags,
    String? composer,
    String? sortBy,
    bool descending = false,
  }) async {
    // Get tag IDs from tag names
    List<int>? tagIds;
    if (tags != null && tags.isNotEmpty) {
      final tagModels = await (database.select(database.tagsTable)
            ..where((t) => t.name.isIn(tags)))
          .get();
      tagIds = tagModels.map((t) => t.id).toList();
    }

    return database.advancedSearch(
      query: query,
      tagIds: tagIds,
      composer: composer,
      sortBy: sortBy,
      descending: descending,
    );
  }

  @override
  Future<List<SheetMusicModel>> filterByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Use efficient database-level filtering instead of loading all data into memory
    return database.filterSheetMusicByDateRange(startDate, endDate);
  }

  @override
  Future<List<SheetMusicModel>> filterByTags(List<String> tags) async {
    if (tags.isEmpty) return [];

    // Get tag IDs from tag names
    final tagModels = await (database.select(database.tagsTable)
          ..where((t) => t.name.isIn(tags)))
        .get();

    if (tagModels.isEmpty) return [];

    final tagIds = tagModels.map((t) => t.id).toList();

    // Get sheet IDs that have ANY of the specified tags
    final sheetIds = await (database.select(database.sheetMusicTagsTable)
          ..where((st) => st.tagId.isIn(tagIds)))
        .map((row) => row.sheetMusicId)
        .get();

    if (sheetIds.isEmpty) return [];

    return (database.select(database.sheetMusicTable)
          ..where((s) => s.id.isIn(sheetIds)))
        .get();
  }

  @override
  Future<List<SheetMusicModel>> fullTextSearch(String query) {
    return database.fullTextSearch(query);
  }

  @override
  Future<List<SheetMusicModel>> searchByComposer(String composer) {
    return database.searchByComposer(composer);
  }

  @override
  Future<List<SheetMusicModel>> searchByTitle(String title) {
    return database.searchByTitle(title);
  }
}
