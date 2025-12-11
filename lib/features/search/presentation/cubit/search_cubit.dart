import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/search/domain/repositories/search_repository.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/search_state.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';

/// Cubit for managing search state and operations.
/// Handles full-text search, filtering, and sorting of sheet music.
class SearchCubit extends Cubit<SearchState> {
  final SearchRepository _searchRepository;
  final SheetMusicRepository _sheetMusicRepository;

  SearchCubit({
    required SearchRepository searchRepository,
    required SheetMusicRepository sheetMusicRepository,
  })  : _searchRepository = searchRepository,
        _sheetMusicRepository = sheetMusicRepository,
        super(const SearchState.idle());

  /// Performs a full-text search with the given query.
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(const SearchState.idle());
      return;
    }

    emit(SearchState.loading(currentQuery: query));

    final result = await _searchRepository.fullTextSearch(query);

    result.fold(
      (failure) => emit(SearchState.error(
        message: failure.message,
        query: query,
      )),
      (results) {
        if (results.isEmpty) {
          emit(SearchState.empty(query: query));
        } else {
          emit(SearchState.loaded(
            results: results,
            query: query,
            totalCount: results.length,
          ));
        }
      },
    );
  }

  /// Searches by exact title match.
  Future<void> searchByTitle(String title) async {
    if (title.trim().isEmpty) {
      emit(const SearchState.idle());
      return;
    }

    emit(SearchState.loading(currentQuery: title));

    final result = await _searchRepository.searchByTitle(title);

    result.fold(
      (failure) => emit(SearchState.error(
        message: failure.message,
        query: title,
      )),
      (results) {
        if (results.isEmpty) {
          emit(SearchState.empty(query: title));
        } else {
          emit(SearchState.loaded(
            results: results,
            query: title,
            totalCount: results.length,
          ));
        }
      },
    );
  }

  /// Searches by exact composer match.
  Future<void> searchByComposer(String composer) async {
    if (composer.trim().isEmpty) {
      emit(const SearchState.idle());
      return;
    }

    emit(SearchState.loading(currentQuery: composer));

    final result = await _searchRepository.searchByComposer(composer);

    result.fold(
      (failure) => emit(SearchState.error(
        message: failure.message,
        query: composer,
      )),
      (results) {
        if (results.isEmpty) {
          emit(SearchState.empty(query: composer));
        } else {
          emit(SearchState.loaded(
            results: results,
            query: composer,
            totalCount: results.length,
          ));
        }
      },
    );
  }

  /// Filters sheet music by multiple tags.
  Future<void> filterByTags(List<String> tags) async {
    if (tags.isEmpty) {
      emit(const SearchState.idle());
      return;
    }

    emit(const SearchState.loading(currentQuery: 'Filtering by tags...'));

    final result = await _searchRepository.filterByTags(tags);

    result.fold(
      (failure) => emit(SearchState.error(
        message: failure.message,
        query: 'Filtering by tags...',
      )),
      (results) {
        if (results.isEmpty) {
          emit(const SearchState.empty(query: 'Filtering by tags...'));
        } else {
          emit(SearchState.loaded(
            results: results,
            query: 'Filtering by tags...',
            totalCount: results.length,
          ));
        }
      },
    );
  }

  /// Filters sheet music by date range.
  Future<void> filterByDateRange(DateTime startDate, DateTime endDate) async {
    emit(const SearchState.loading(currentQuery: 'Filtering by date...'));

    final result =
        await _searchRepository.filterByDateRange(startDate, endDate);

    result.fold(
      (failure) => emit(SearchState.error(
        message: failure.message,
        query: 'Filtering by date...',
      )),
      (results) {
        if (results.isEmpty) {
          emit(const SearchState.empty(query: 'Filtering by date...'));
        } else {
          emit(SearchState.loaded(
            results: results,
            query: 'Filtering by date...',
            totalCount: results.length,
          ));
        }
      },
    );
  }

  /// Performs an advanced search with multiple filters.
  Future<void> advancedSearch({
    String? query,
    List<String>? tags,
    String? composer,
    String? sortBy,
    bool descending = true,
  }) async {
    final searchQuery = query?.trim() ?? '';

    if (searchQuery.isEmpty &&
        (tags == null || tags.isEmpty) &&
        (composer == null || composer.isEmpty)) {
      emit(const SearchState.idle());
      return;
    }

    emit(SearchState.loading(currentQuery: searchQuery));

    final result = await _searchRepository.advancedSearch(
      query: query,
      tags: tags,
      composer: composer,
      sortBy: sortBy,
      descending: descending,
    );

    result.fold(
      (failure) => emit(SearchState.error(
        message: failure.message,
        query: searchQuery,
      )),
      (results) {
        if (results.isEmpty) {
          emit(SearchState.empty(query: searchQuery));
        } else {
          emit(SearchState.loaded(
            results: results,
            query: searchQuery,
            totalCount: results.length,
          ));
        }
      },
    );
  }

  /// Get all sheet music (for browse without search).
  Future<void> loadAll() async {
    emit(const SearchState.loading());

    final result = await _sheetMusicRepository.getAll();

    result.fold(
      (failure) => emit(SearchState.error(
        message: failure.message,
        query: '',
      )),
      (results) {
        if (results.isEmpty) {
          emit(const SearchState.empty(query: ''));
        } else {
          emit(SearchState.loaded(
            results: results,
            query: '',
            totalCount: results.length,
          ));
        }
      },
    );
  }

  /// Clears the search and returns to idle state.
  void clearSearch() {
    emit(const SearchState.idle());
  }
}
