import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/add_sheet_music_use_case.dart';
import 'add_sheet_state.dart';

/// Cubit for managing add/create sheet music form state
/// Handles form validation and submission
class AddSheetCubit extends Cubit<AddSheetState> {
  final AddSheetMusicUseCase addSheetMusicUseCase;

  AddSheetCubit({required this.addSheetMusicUseCase}) : super(const AddSheetInitial());

  /// Validate form fields
  /// Returns a map of field errors if validation fails
  Map<String, String> validateForm({
    required String title,
    required String composer,
    String? opus,
    String? musicalKey,
    String? source,
    String? notes,
    int? difficulty,
    String? instrumentation,
    String? epoch,
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

    if (opus != null && opus.length > 100) {
      errors['opus'] = 'Opus must not exceed 100 characters';
    }

    if (musicalKey != null && musicalKey.length > 50) {
      errors['musicalKey'] = 'Musical key must not exceed 50 characters';
    }

    if (source != null && source.length > 100) {
      errors['source'] = 'Source must not exceed 100 characters';
    }

    if (notes != null && notes.length > 1000) {
      errors['notes'] = 'Notes must not exceed 1000 characters';
    }

    if (difficulty != null && (difficulty < 1 || difficulty > 5)) {
      errors['difficulty'] = 'Difficulty must be between 1 and 5';
    }

    if (instrumentation != null && instrumentation.length > 100) {
      errors['instrumentation'] = 'Instrumentation must not exceed 100 characters';
    }

    if (epoch != null && epoch.length > 50) {
      errors['epoch'] = 'Epoch must not exceed 50 characters';
    }

    return errors;
  }

  /// Validate the form and update state accordingly
  void validate({
    required String title,
    required String composer,
    String? opus,
    String? musicalKey,
    String? source,
    String? notes,
    int? difficulty,
    String? instrumentation,
    String? epoch,
    List<String> tags = const [],
  }) {
    emit(const AddSheetValidating());

    final errors = validateForm(
      title: title,
      composer: composer,
      opus: opus,
      musicalKey: musicalKey,
      source: source,
      notes: notes,
      difficulty: difficulty,
      instrumentation: instrumentation,
      epoch: epoch,
      tags: tags,
    );

    if (errors.isEmpty) {
      emit(const AddSheetValid());
    } else {
      emit(AddSheetInvalid(errors));
    }
  }

  /// Submit the form to add a new sheet music entry
  Future<void> submitForm({
    required String title,
    required String composer,
    String? opus,
    String? musicalKey,
    String? source,
    String? notes,
    int? difficulty,
    String? instrumentation,
    String? epoch,
    List<String> tags = const [],
    List<String> imageUrls = const [],
  }) async {
    // Validate first
    final errors = validateForm(
      title: title,
      composer: composer,
      opus: opus,
      musicalKey: musicalKey,
      source: source,
      notes: notes,
      difficulty: difficulty,
      instrumentation: instrumentation,
      epoch: epoch,
      tags: tags,
    );

    if (errors.isNotEmpty) {
      emit(AddSheetInvalid(errors));
      return;
    }

    emit(const AddSheetSubmitting());

    final sheetMusic = SheetMusic(
      id: 0, // Will be assigned by database
      title: title,
      composer: composer,
      opus: opus,
      musicalKey: musicalKey,
      source: source,
      notes: notes,
      difficulty: difficulty,
      instrumentation: instrumentation,
      epoch: epoch,
      tags: tags,
      imageUrls: imageUrls,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await addSheetMusicUseCase(
      AddSheetMusicParams(sheetMusic: sheetMusic),
    );

    result.fold(
      (failure) => emit(AddSheetError(failure)),
      (addedSheetMusic) => emit(AddSheetSuccess(addedSheetMusic)),
    );
  }

  /// Reset the form to initial state
  void reset() {
    emit(const AddSheetInitial());
  }

  @override
  Future<void> close() async {
    // Clean up resources if needed
    return super.close();
  }
}
