import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/search/domain/usecases/tag_usecases.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/tag_suggestion_state.dart';

/// Cubit for managing tag suggestions during search/filtering.
class TagSuggestionCubit extends Cubit<TagSuggestionState> {
  final GetAllTagsUseCase _getAllTagsUseCase;

  TagSuggestionCubit({
    required GetAllTagsUseCase getAllTagsUseCase,
  })  : _getAllTagsUseCase = getAllTagsUseCase,
        super(const TagSuggestionState.idle());

  /// Load all tags for suggestions.
  Future<void> loadSuggestions() async {
    emit(const TagSuggestionState.loading());

    final result = await _getAllTagsUseCase();

    result.fold(
      (failure) => emit(TagSuggestionState.error(message: failure.message)),
      (tags) => emit(TagSuggestionState.loaded(suggestions: tags)),
    );
  }
}
