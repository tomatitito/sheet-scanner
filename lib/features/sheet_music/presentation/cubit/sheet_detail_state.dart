import 'package:equatable/equatable.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

/// Base state for SheetDetailCubit
abstract class SheetDetailState extends Equatable {
  const SheetDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class SheetDetailInitial extends SheetDetailState {
  const SheetDetailInitial();
}

/// Loading state while fetching sheet music details
class SheetDetailLoading extends SheetDetailState {
  const SheetDetailLoading();
}

/// Success state with loaded sheet music details
class SheetDetailLoaded extends SheetDetailState {
  final SheetMusic sheetMusic;

  const SheetDetailLoaded(this.sheetMusic);

  @override
  List<Object?> get props => [sheetMusic];
}

/// Error state with failure details
class SheetDetailError extends SheetDetailState {
  final Failure failure;

  const SheetDetailError(this.failure);

  @override
  List<Object?> get props => [failure];
}
