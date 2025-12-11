import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/tag.dart';

part 'tag_state.freezed.dart';

/// Represents the state of tag management operations.
@freezed
class TagState with _$TagState {
  /// Initial idle state.
  const factory TagState.idle() = _Idle;

  /// Loading state.
  const factory TagState.loading() = _Loading;

  /// Successfully loaded all tags.
  const factory TagState.loaded({
    required List<Tag> tags,
  }) = _Loaded;

  /// Error occurred.
  const factory TagState.error({
    required String message,
  }) = _Error;
}
