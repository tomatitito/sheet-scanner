import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/delete_sheet_music_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_sheet_music_by_id_use_case.dart';
import 'sheet_detail_state.dart';

/// Cubit for managing sheet music detail view state
/// Handles loading and displaying individual sheet music entries
class SheetDetailCubit extends Cubit<SheetDetailState> {
  final GetSheetMusicByIdUseCase getSheetMusicByIdUseCase;
  final DeleteSheetMusicUseCase deleteSheetMusicUseCase;

  SheetDetailCubit({
    required this.getSheetMusicByIdUseCase,
    required this.deleteSheetMusicUseCase,
  }) : super(const SheetDetailInitial());

  /// Load sheet music details by ID
  Future<void> loadSheetMusic(int sheetMusicId) async {
    emit(const SheetDetailLoading());

    final result = await getSheetMusicByIdUseCase(
      GetSheetMusicByIdParams(id: sheetMusicId),
    );

    result.fold(
      (failure) => emit(SheetDetailError(failure)),
      (sheetMusic) {
        if (sheetMusic == null) {
          emit(
            SheetDetailError(
              GenericFailure(message: 'Sheet music not found'),
            ),
          );
        } else {
          emit(SheetDetailLoaded(sheetMusic));
        }
      },
    );
  }

  /// Refresh the sheet music details
  Future<void> refresh(int sheetMusicId) => loadSheetMusic(sheetMusicId);

  /// Delete the currently loaded sheet music
  Future<void> deleteSheetMusic(int sheetMusicId) async {
    final currentState = state;
    if (currentState is SheetDetailLoaded) {
      emit(SheetDetailDeleting(currentState.sheetMusic));

      final result = await deleteSheetMusicUseCase(
        DeleteSheetMusicParams(id: sheetMusicId),
      );

      result.fold(
        (failure) => emit(SheetDetailError(failure)),
        (_) => emit(SheetDetailDeleted(sheetMusicId)),
      );
    }
  }
}
