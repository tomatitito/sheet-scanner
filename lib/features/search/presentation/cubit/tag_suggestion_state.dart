import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/tag.dart';

part 'tag_suggestion_state.freezed.dart';

/// Represents the state of tag suggestions for search/filtering.
@freezed
class TagSuggestionState with _$TagSuggestionState {
  /// Initial idle state.
  const factory TagSuggestionState.idle() = _Idle;

  /// Loading state.
  const factory TagSuggestionState.loading() = _Loading;

  /// Successfully loaded tag suggestions.
  const factory TagSuggestionState.loaded({
    required List<Tag> suggestions,
  }) = _Loaded;

  /// Error occurred.
  const factory TagSuggestionState.error({
    required String message,
  }) = _Error;
}
