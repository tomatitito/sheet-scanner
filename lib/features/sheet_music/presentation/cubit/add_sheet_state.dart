import 'package:equatable/equatable.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

/// Base state for AddSheetCubit
abstract class AddSheetState extends Equatable {
  const AddSheetState();

  @override
  List<Object?> get props => [];
}

/// Initial state before form is interacted with
class AddSheetInitial extends AddSheetState {
  const AddSheetInitial();
}

/// Form is being validated
class AddSheetValidating extends AddSheetState {
  const AddSheetValidating();
}

/// Form is valid and ready to submit
class AddSheetValid extends AddSheetState {
  const AddSheetValid();
}

/// Form has validation errors
class AddSheetInvalid extends AddSheetState {
  final Map<String, String> errors;

  const AddSheetInvalid(this.errors);

  @override
  List<Object?> get props => [errors];
}

/// Submitting form data
class AddSheetSubmitting extends AddSheetState {
  const AddSheetSubmitting();
}

/// Successfully added sheet music
class AddSheetSuccess extends AddSheetState {
  final SheetMusic sheetMusic;

  const AddSheetSuccess(this.sheetMusic);

  @override
  List<Object?> get props => [sheetMusic];
}

/// Error during submission
class AddSheetError extends AddSheetState {
  final Failure failure;

  const AddSheetError(this.failure);

  @override
  List<Object?> get props => [failure];
}
