import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/search/domain/usecases/full_text_search_use_case.dart';
import 'package:sheet_scanner/features/search/domain/usecases/tag_usecases.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/search_state.dart';

/// Cubit for managing search state and operations.
/// Handles full-text search and tag management.
class SearchCubit extends Cubit<SearchState> {
  final FullTextSearchUseCase _fullTextSearchUseCase;
  final GetAllTagsUseCase _getAllTagsUseCase;

  SearchCubit({
    required FullTextSearchUseCase fullTextSearchUseCase,
    required GetAllTagsUseCase getAllTagsUseCase,
  })  : _fullTextSearchUseCase = fullTextSearchUseCase,
        _getAllTagsUseCase = getAllTagsUseCase,
        super(const SearchState.idle());

  /// Performs a full-text search with the given query.
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(const SearchState.idle());
      return;
    }

    emit(SearchState.loading(currentQuery: query));
    final result = await _fullTextSearchUseCase(query);

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

  /// Load all available tags for filtering.
  Future<void> loadAvailableTags() async {
    final result = await _getAllTagsUseCase();

    result.fold(
      (failure) => emit(SearchState.error(
        message: 'Failed to load tags: ${failure.message}',
        query: '',
      )),
      (_) {
        // Tags loaded successfully, keep current state
      },
    );
  }

  /// Clears the search and returns to idle state.
  void clearSearch() {
    emit(const SearchState.idle());
  }

  @override
  Future<void> close() async {
    // Clean up resources if needed
    return super.close();
  }
}
