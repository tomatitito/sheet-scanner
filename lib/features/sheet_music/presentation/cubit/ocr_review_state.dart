import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

part 'ocr_review_state.freezed.dart';

/// State for the OCR review and edit workflow
///
/// Manages the lifecycle of reviewing OCR-detected metadata before saving,
/// including validation, user edits, and submission.
@freezed
class OCRReviewState with _$OCRReviewState {
  /// Initial state before any OCR result is loaded
  const factory OCRReviewState.initial() = _Initial;

  /// Initialized with OCR-detected data ready for review
  const factory OCRReviewState.initialized({
    required String detectedTitle,
    required String detectedComposer,
    required double confidence,
    required File? capturedImage,
    required String editedTitle,
    required String editedComposer,
    @Default('') String editedNotes,
    required List<String> tags,
    @Default(false) bool isValid,
    @Default({}) Map<String, String> errors,
    @Default(false) bool isSubmitting,
    String? error,
  }) = _Initialized;

  /// Success state after sheet music is saved
  const factory OCRReviewState.success({
    required SheetMusic sheetMusic,
    required String message,
  }) = _Success;

  /// Error state if submission fails
  const factory OCRReviewState.error({
    required String message,
  }) = _Error;
}

/// Extension to help with state updates
extension OCRReviewStateExt on OCRReviewState {
  OCRReviewState copyWith({
    String? editedTitle,
    String? editedComposer,
    String? editedNotes,
    List<String>? tags,
    bool? isValid,
    Map<String, String>? errors,
    bool? isSubmitting,
    String? error,
  }) {
    return (this as _Initialized).copyWith(
      editedTitle: editedTitle ?? (this as _Initialized).editedTitle,
      editedComposer: editedComposer ?? (this as _Initialized).editedComposer,
      editedNotes: editedNotes ?? (this as _Initialized).editedNotes,
      tags: tags ?? (this as _Initialized).tags,
      isValid: isValid ?? (this as _Initialized).isValid,
      errors: errors ?? (this as _Initialized).errors,
      isSubmitting: isSubmitting ?? (this as _Initialized).isSubmitting,
    );
  }
}
