import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/search/domain/usecases/full_text_search_use_case.dart';
import 'package:sheet_scanner/features/search/domain/usecases/tag_usecases.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/search_state.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

/// Cubit for managing search state and operations.
/// Handles full-text search, filtering, and sorting of sheet music.
class SearchCubit extends Cubit<SearchState> {
  final FullTextSearchUseCase _fullTextSearchUseCase;
  final GetAllTagsUseCase _getAllTagsUseCase;
  final SuggestTagsUseCase _suggestTagsUseCase;
  final AddTagToSheetUseCase _addTagToSheetUseCase;
  final RemoveTagFromSheetUseCase _removeTagFromSheetUseCase;

  SearchCubit({
    required FullTextSearchUseCase fullTextSearchUseCase,
    required GetAllTagsUseCase getAllTagsUseCase,
    required SuggestTagsUseCase suggestTagsUseCase,
    required AddTagToSheetUseCase addTagToSheetUseCase,
    required RemoveTagFromSheetUseCase removeTagFromSheetUseCase,
  })  : _fullTextSearchUseCase = fullTextSearchUseCase,
        _getAllTagsUseCase = getAllTagsUseCase,
        _suggestTagsUseCase = suggestTagsUseCase,
        _addTagToSheetUseCase = addTagToSheetUseCase,
        _removeTagFromSheetUseCase = removeTagFromSheetUseCase,
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

  /// Get all available tags for filtering.
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

  /// Suggest tags based on partial name.
  Future<List<String>> suggestTags(String partialName) async {
    final result = await _suggestTagsUseCase(partialName);

    return result.fold(
      (failure) => [],
      (tags) => tags.map((tag) => tag.name).toList(),
    );
  }

  /// Add a tag to a sheet music.
  Future<bool> addTagToSheet(int sheetMusicId, int tagId) async {
    final result = await _addTagToSheetUseCase(sheetMusicId, tagId);

    return result.fold(
      (failure) => false,
      (success) => success,
    );
  }

  /// Remove a tag from a sheet music.
  Future<bool> removeTagFromSheet(int sheetMusicId, int tagId) async {
    final result = await _removeTagFromSheetUseCase(sheetMusicId, tagId);

    return result.fold(
      (failure) => false,
      (success) => success,
    );
  }

  /// Clears the search and returns to idle state.
  void clearSearch() {
    emit(const SearchState.idle());
  }
}
