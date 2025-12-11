import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/search/domain/usecases/tag_usecases.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/tag_state.dart';

/// Cubit for managing tags.
class TagCubit extends Cubit<TagState> {
  final GetAllTagsUseCase _getAllTagsUseCase;
  final CreateTagUseCase _createTagUseCase;

  TagCubit({
    required GetAllTagsUseCase getAllTagsUseCase,
    required CreateTagUseCase createTagUseCase,
  })  : _getAllTagsUseCase = getAllTagsUseCase,
        _createTagUseCase = createTagUseCase,
        super(const TagState.idle());

  /// Load all tags from the database.
  Future<void> loadAllTags() async {
    emit(const TagState.loading());

    final result = await _getAllTagsUseCase();

    result.fold(
      (failure) => emit(TagState.error(message: failure.message)),
      (tags) => emit(TagState.loaded(tags: tags)),
    );
  }

  /// Create a new tag.
  Future<bool> createTag(String name) async {
    final result = await _createTagUseCase(name);

    return result.fold(
      (failure) {
        emit(TagState.error(message: 'Failed to create tag: ${failure.message}'));
        return false;
      },
      (_) {
        // Reload tags after creation
        loadAllTags();
        return true;
      },
    );
  }
}
