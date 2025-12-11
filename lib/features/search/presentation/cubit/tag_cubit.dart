import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/search/domain/usecases/tag_usecases.dart';
import 'package:sheet_scanner/features/search/presentation/cubit/tag_state.dart';

/// Cubit for managing tags.
/// Handles tag creation, deletion, merging, and listing.
class TagCubit extends Cubit<TagState> {
  final GetAllTagsUseCase _getAllTagsUseCase;
  final CreateTagUseCase _createTagUseCase;
  final DeleteTagUseCase _deleteTagUseCase;
  final MergeTagsUseCase _mergeTagsUseCase;

  TagCubit({
    required GetAllTagsUseCase getAllTagsUseCase,
    required CreateTagUseCase createTagUseCase,
    required DeleteTagUseCase deleteTagUseCase,
    required MergeTagsUseCase mergeTagsUseCase,
  })  : _getAllTagsUseCase = getAllTagsUseCase,
        _createTagUseCase = createTagUseCase,
        _deleteTagUseCase = deleteTagUseCase,
        _mergeTagsUseCase = mergeTagsUseCase,
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

  /// Delete a tag by ID.
  Future<bool> deleteTag(int tagId) async {
    final result = await _deleteTagUseCase(tagId);

    return result.fold(
      (failure) {
        emit(TagState.error(message: 'Failed to delete tag: ${failure.message}'));
        return false;
      },
      (_) {
        // Reload tags after deletion
        loadAllTags();
        return true;
      },
    );
  }

  /// Merge two tags.
  Future<bool> mergeTags(int sourceId, int targetId) async {
    final result = await _mergeTagsUseCase(sourceId, targetId);

    return result.fold(
      (failure) {
        emit(TagState.error(message: 'Failed to merge tags: ${failure.message}'));
        return false;
      },
      (_) {
        // Reload tags after merge
        loadAllTags();
        return true;
      },
    );
  }
}
