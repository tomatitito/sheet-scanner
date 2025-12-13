import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

part 'search_state.freezed.dart';

/// State for search and filtering operations.
@freezed
class SearchState with _$SearchState {
  /// Initial state - no search or loading in progress.
  const factory SearchState.idle() = _Idle;

  /// Search or load is in progress.
  const factory SearchState.loading({
    @Default('') String currentQuery,
  }) = _Loading;

  /// Search completed successfully with results.
  const factory SearchState.loaded({
    required List<SheetMusic> results,
    required String query,
    required int totalCount,
  }) = _Loaded;

  /// Search returned no results.
  const factory SearchState.empty({
    required String query,
  }) = _Empty;

  /// Error occurred during search.
  const factory SearchState.error({
    required String message,
    required String query,
  }) = _Error;
}
