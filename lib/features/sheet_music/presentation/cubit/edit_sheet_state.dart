import 'package:equatable/equatable.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

/// Base state for EditSheetCubit
abstract class EditSheetState extends Equatable {
  const EditSheetState();

  @override
  List<Object?> get props => [];
}

/// Initial state, loading sheet data
class EditSheetInitial extends EditSheetState {
  const EditSheetInitial();
}

/// Loading existing sheet data
class EditSheetLoading extends EditSheetState {
  const EditSheetLoading();
}

/// Loaded existing sheet data, ready to edit
class EditSheetLoaded extends EditSheetState {
  final SheetMusic sheetMusic;

  const EditSheetLoaded(this.sheetMusic);

  @override
  List<Object?> get props => [sheetMusic];
}

/// Form is being validated
class EditSheetValidating extends EditSheetState {
  const EditSheetValidating();
}

/// Form is valid and ready to submit
class EditSheetValid extends EditSheetState {
  const EditSheetValid();
}

/// Form has validation errors
class EditSheetInvalid extends EditSheetState {
  final Map<String, String> errors;

  const EditSheetInvalid(this.errors);

  @override
  List<Object?> get props => [errors];
}

/// Submitting form data
class EditSheetSubmitting extends EditSheetState {
  const EditSheetSubmitting();
}

/// Successfully updated sheet music
class EditSheetSuccess extends EditSheetState {
  final SheetMusic sheetMusic;

  const EditSheetSuccess(this.sheetMusic);

  @override
  List<Object?> get props => [sheetMusic];
}

/// Error during load or submission
class EditSheetError extends EditSheetState {
  final Failure failure;

  const EditSheetError(this.failure);

  @override
  List<Object?> get props => [failure];
}
