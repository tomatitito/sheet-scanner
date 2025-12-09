import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/add_sheet_music_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/ocr_review_state.dart';

/// Cubit for managing OCR review and edit state
///
/// Handles validation and submission of OCR-scanned sheet music metadata.
/// Pre-fills fields with OCR-detected values but allows user correction before saving.
class OCRReviewCubit extends Cubit<OCRReviewState> {
  final AddSheetMusicUseCase _addSheetMusicUseCase;

  OCRReviewCubit(this._addSheetMusicUseCase)
      : super(const OCRReviewState.initial());

  /// Initialize the cubit with OCR-detected data
  void initializeWithOCRResult({
    required String detectedTitle,
    required String detectedComposer,
    required double confidence,
    required File capturedImage,
  }) {
    emit(OCRReviewState.initialized(
      detectedTitle: detectedTitle,
      detectedComposer: detectedComposer,
      confidence: confidence,
      capturedImage: capturedImage,
      editedTitle: detectedTitle,
      editedComposer: detectedComposer,
      tags: [],
    ));
  }

  /// Validate form fields and update state
  void validate({
    required String title,
    required String composer,
    required String notes,
    required List<String> tags,
  }) {
    final Map<String, String> errors = {};

    if (title.trim().isEmpty) {
      errors['title'] = 'Title is required';
    }

    if (composer.trim().isEmpty) {
      errors['composer'] = 'Composer is required';
    }

    if (notes.length > 500) {
      errors['notes'] = 'Notes cannot exceed 500 characters';
    }

    final isValid = errors.isEmpty;

    state.whenOrNull(
      initialized: (dTitle, dComposer, conf, image, eTitle, eComposer, eNotes,
          tgs, _, __, isSubmitting, error) {
        emit(OCRReviewState.initialized(
          detectedTitle: dTitle,
          detectedComposer: dComposer,
          confidence: conf,
          capturedImage: image,
          editedTitle: title,
          editedComposer: composer,
          editedNotes: notes,
          tags: tags,
          isValid: isValid,
          errors: errors,
          isSubmitting: isSubmitting,
          error: error,
        ));
      },
    );
  }

  /// Submit the reviewed and edited sheet music for saving
  Future<void> submitForm({
    required String title,
    required String composer,
    required String notes,
    required List<String> tags,
  }) async {
    // Validate first
    validate(title: title, composer: composer, notes: notes, tags: tags);

    await state.whenOrNull(
      initialized: (detTitle, detComposer, conf, image, eTitle, eComposer,
          eNotes, tgs, isValid, errors, isSubmitting, error) async {
        if (!isValid) {
          return;
        }

        emit(OCRReviewState.initialized(
          detectedTitle: detTitle,
          detectedComposer: detComposer,
          confidence: conf,
          capturedImage: image,
          editedTitle: title,
          editedComposer: composer,
          editedNotes: notes,
          tags: tags,
          isValid: isValid,
          errors: errors,
          isSubmitting: true,
          error: error,
        ));

        // Create sheet music entity from form data
        final sheetMusicEntity = SheetMusic(
          id: 0, // Will be set by the repository
          title: title.trim(),
          composer: composer.trim(),
          notes: notes.isEmpty ? null : notes.trim(),
          imageUrls: image != null ? [image.path] : [],
          tags: tags,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await _addSheetMusicUseCase.call(
          AddSheetMusicParams(sheetMusic: sheetMusicEntity),
        );

        result.fold(
          (failure) {
            emit(OCRReviewState.initialized(
              detectedTitle: detTitle,
              detectedComposer: detComposer,
              confidence: conf,
              capturedImage: image,
              editedTitle: title,
              editedComposer: composer,
              editedNotes: notes,
              tags: tags,
              isValid: isValid,
              errors: errors,
              isSubmitting: false,
              error: failure.message,
            ));
          },
          (sheetMusic) {
            emit(OCRReviewState.success(
              sheetMusic: sheetMusic,
              message: 'Sheet music "${sheetMusic.title}" saved successfully',
            ));
          },
        );
      },
    );
  }

  /// Reset the cubit to initial state
  void reset() {
    emit(const OCRReviewState.initial());
  }
}
