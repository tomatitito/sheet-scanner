import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_sheet_music_by_id_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/update_sheet_music_use_case.dart';
import 'edit_sheet_state.dart';

/// Cubit for managing edit sheet music form state
/// Handles loading, validation, and submission
class EditSheetCubit extends Cubit<EditSheetState> {
  final GetSheetMusicByIdUseCase getSheetMusicByIdUseCase;
  final UpdateSheetMusicUseCase updateSheetMusicUseCase;

  EditSheetCubit({
    required this.getSheetMusicByIdUseCase,
    required this.updateSheetMusicUseCase,
  }) : super(const EditSheetInitial());

  /// Load existing sheet music for editing
  Future<void> loadSheetMusic(int sheetMusicId) async {
    emit(const EditSheetLoading());

    final result = await getSheetMusicByIdUseCase(
      GetSheetMusicByIdParams(id: sheetMusicId),
    );

    result.fold(
      (failure) => emit(EditSheetError(failure)),
      (sheetMusic) {
        if (sheetMusic == null) {
          emit(
            EditSheetError(
              GenericFailure(message: 'Sheet music not found'),
            ),
          );
        } else {
          emit(EditSheetLoaded(sheetMusic));
        }
      },
    );
  }

  /// Validate form fields
  /// Returns a map of field errors if validation fails
  Map<String, String> validateForm({
    required String title,
    required String composer,
    String? notes,
    List<String> tags = const [],
  }) {
    final errors = <String, String>{};

    if (title.isEmpty) {
      errors['title'] = 'Title is required';
    } else if (title.length < 3) {
      errors['title'] = 'Title must be at least 3 characters';
    } else if (title.length > 200) {
      errors['title'] = 'Title must not exceed 200 characters';
    }

    if (composer.isEmpty) {
      errors['composer'] = 'Composer is required';
    } else if (composer.length < 2) {
      errors['composer'] = 'Composer must be at least 2 characters';
    } else if (composer.length > 100) {
      errors['composer'] = 'Composer must not exceed 100 characters';
    }

    if (notes != null && notes.length > 1000) {
      errors['notes'] = 'Notes must not exceed 1000 characters';
    }

    return errors;
  }

  /// Validate the form and update state accordingly
  void validate({
    required String title,
    required String composer,
    String? notes,
    List<String> tags = const [],
  }) {
    emit(const EditSheetValidating());

    final errors = validateForm(
      title: title,
      composer: composer,
      notes: notes,
      tags: tags,
    );

    if (errors.isEmpty) {
      emit(const EditSheetValid());
    } else {
      emit(EditSheetInvalid(errors));
    }
  }

  /// Submit the form to update the sheet music entry
  Future<void> submitForm({
    required int id,
    required String title,
    required String composer,
    String? notes,
    List<String> tags = const [],
    List<String> imageUrls = const [],
    required DateTime createdAt,
  }) async {
    // Validate first
    final errors = validateForm(
      title: title,
      composer: composer,
      notes: notes,
      tags: tags,
    );

    if (errors.isNotEmpty) {
      emit(EditSheetInvalid(errors));
      return;
    }

    emit(const EditSheetSubmitting());

    final sheetMusic = SheetMusic(
      id: id,
      title: title,
      composer: composer,
      notes: notes,
      tags: tags,
      imageUrls: imageUrls,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );

    final result = await updateSheetMusicUseCase(
      UpdateSheetMusicParams(sheetMusic: sheetMusic),
    );

    result.fold(
      (failure) => emit(EditSheetError(failure)),
      (updatedSheetMusic) => emit(EditSheetSuccess(updatedSheetMusic)),
    );
  }

  /// Reload the sheet music data
  Future<void> refresh(int sheetMusicId) => loadSheetMusic(sheetMusicId);

  @override
  Future<void> close() async {
    // Clean up resources if needed
    return super.close();
  }
}
