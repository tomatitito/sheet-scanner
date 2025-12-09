import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

part 'browse_state.freezed.dart';

@freezed
class BrowseState with _$BrowseState {
  const factory BrowseState.initial() = BrowseInitial;

  const factory BrowseState.loading() = BrowseLoading;

  const factory BrowseState.loaded({
    required List<SheetMusic> sheets,
    required List<SheetMusic> filteredSheets,
    required String searchQuery,
    required List<String> selectedTags,
    required String sortBy,
  }) = BrowseLoaded;

  const factory BrowseState.error(Failure failure) = BrowseError;
}
