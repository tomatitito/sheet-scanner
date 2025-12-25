import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_all_sheet_music_use_case.dart';
import 'browse_state.dart';

/// Cubit for managing browse/inventory list screen state
/// Handles loading, searching, filtering, and sorting sheet music
class BrowseCubit extends Cubit<BrowseState> {
  final GetAllSheetMusicUseCase getAllSheetMusicUseCase;

  BrowseCubit({required this.getAllSheetMusicUseCase})
      : super(const BrowseState.initial());

  /// Load all sheet music from the library
  Future<void> loadSheetMusic() async {
    emit(const BrowseState.loading());

    final result = await getAllSheetMusicUseCase();

    result.fold(
      (failure) => emit(BrowseState.error(failure)),
      (sheetMusicList) => emit(
        BrowseState.loaded(
          sheets: sheetMusicList,
          filteredSheets: sheetMusicList,
          searchQuery: '',
          selectedTags: [],
          sortBy: 'recent',
        ),
      ),
    );
  }

  /// Search sheets by query (matches title, composer, notes)
  void search(String query) {
    final currentState = state;
    if (currentState is! BrowseLoaded) return;

    final filtered = currentState.sheets.where((sheet) {
      final matchesQuery = query.isEmpty ||
          sheet.title.toLowerCase().contains(query.toLowerCase()) ||
          sheet.composer.toLowerCase().contains(query.toLowerCase()) ||
          (sheet.notes?.toLowerCase().contains(query.toLowerCase()) ?? false);

      final matchesTags = currentState.selectedTags.isEmpty ||
          sheet.tags.any((tag) => currentState.selectedTags.contains(tag));

      return matchesQuery && matchesTags;
    }).toList();

    emit(currentState.copyWith(
      searchQuery: query,
      filteredSheets: _sortSheets(filtered, currentState.sortBy),
    ));
  }

  /// Filter sheets by tags
  void filterByTags(List<String> tags) {
    final currentState = state;
    if (currentState is! BrowseLoaded) return;

    final filtered = currentState.sheets.where((sheet) {
      final matchesQuery = currentState.searchQuery.isEmpty ||
          sheet.title
              .toLowerCase()
              .contains(currentState.searchQuery.toLowerCase()) ||
          sheet.composer
              .toLowerCase()
              .contains(currentState.searchQuery.toLowerCase()) ||
          (sheet.notes
                  ?.toLowerCase()
                  .contains(currentState.searchQuery.toLowerCase()) ??
              false);

      final matchesTags =
          tags.isEmpty || sheet.tags.any((tag) => tags.contains(tag));

      return matchesQuery && matchesTags;
    }).toList();

    emit(currentState.copyWith(
      selectedTags: tags,
      filteredSheets: _sortSheets(filtered, currentState.sortBy),
    ));
  }

  /// Sort sheets by the specified criteria
  void sortBy(String sortBy) {
    final currentState = state;
    if (currentState is! BrowseLoaded) return;

    final sorted = _sortSheets(currentState.filteredSheets, sortBy);

    emit(currentState.copyWith(
      sortBy: sortBy,
      filteredSheets: sorted,
    ));
  }

  /// Internal method to sort sheets based on criteria
  List<SheetMusic> _sortSheets(List<SheetMusic> sheets, String sortBy) {
    final sorted = [...sheets];

    switch (sortBy) {
      case 'title':
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'composer':
        sorted.sort((a, b) => a.composer.compareTo(b.composer));
        break;
      case 'oldest':
        sorted.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case 'recent':
      default:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return sorted;
  }

  /// Refresh the sheet music list while preserving current state
  Future<void> refresh() async {
    // If we already have data, mark as refreshing instead of loading
    final currentState = state;
    if (currentState is BrowseLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      // If no data yet, show normal loading
      emit(const BrowseState.loading());
    }

    final result = await getAllSheetMusicUseCase();

    result.fold(
      (failure) => emit(BrowseState.error(failure)),
      (sheetMusicList) => emit(
        BrowseState.loaded(
          sheets: sheetMusicList,
          filteredSheets: _sortSheets(sheetMusicList, 'recent'),
          searchQuery: '',
          selectedTags: [],
          sortBy: 'recent',
          isRefreshing: false,
        ),
      ),
    );
  }

  /// Clear all filters and search
  void clearFilters() {
    final currentState = state;
    if (currentState is! BrowseLoaded) return;

    emit(currentState.copyWith(
      searchQuery: '',
      selectedTags: [],
      filteredSheets: _sortSheets(currentState.sheets, currentState.sortBy),
    ));
  }

  /// Get all unique tags from the library
  List<String> getAllTags() {
    final currentState = state;
    if (currentState is! BrowseLoaded) return [];

    final tagsSet = <String>{};
    for (final sheet in currentState.sheets) {
      tagsSet.addAll(sheet.tags);
    }
    return tagsSet.toList()..sort();
  }

  @override
  Future<void> close() async {
    // Clean up resources if needed
    return super.close();
  }
}
