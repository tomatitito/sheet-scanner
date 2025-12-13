import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/delete_sheet_music_use_case.dart';

part 'bulk_operations_state.dart';

/// Cubit for managing bulk operations on sheet music items.
/// Handles multi-select, select all, and batch delete operations.
class BulkOperationsCubit extends Cubit<BulkOperationsState> {
  final DeleteSheetMusicUseCase deleteSheetMusicUseCase;

  BulkOperationsCubit({
    required this.deleteSheetMusicUseCase,
  }) : super(const BulkOperationsInitial());

  /// Toggle selection of a specific item
  void toggleSelection(int sheetMusicId, int totalAvailable) {
    if (state is SelectionModeActive) {
      final currentState = state as SelectionModeActive;
      final updatedIds = Set<int>.from(currentState.selectedIds);

      if (updatedIds.contains(sheetMusicId)) {
        updatedIds.remove(sheetMusicId);
      } else {
        updatedIds.add(sheetMusicId);
      }

      if (updatedIds.isEmpty) {
        emit(const BulkOperationsInitial());
      } else {
        emit(SelectionModeActive(
          selectedIds: updatedIds,
          totalAvailable: totalAvailable,
        ));
      }
    } else {
      // Start selection mode with first selection
      emit(SelectionModeActive(
        selectedIds: {sheetMusicId},
        totalAvailable: totalAvailable,
      ));
    }
  }

  /// Select all available items
  void selectAll(int totalAvailable) {
    final selectedIds =
        Set<int>.from(List.generate(totalAvailable, (i) => i + 1));
    emit(SelectionModeActive(
      selectedIds: selectedIds,
      totalAvailable: totalAvailable,
    ));
  }

  /// Deselect all items
  void deselectAll() {
    emit(const BulkOperationsInitial());
  }

  /// Check if a specific item is selected
  bool isSelected(int sheetMusicId) {
    if (state is SelectionModeActive) {
      final currentState = state as SelectionModeActive;
      return currentState.selectedIds.contains(sheetMusicId);
    }
    return false;
  }

  /// Get count of selected items
  int get selectionCount {
    if (state is SelectionModeActive) {
      final currentState = state as SelectionModeActive;
      return currentState.selectionCount;
    }
    return 0;
  }

  /// Perform bulk delete on selected items
  Future<void> bulkDelete() async {
    if (state is! SelectionModeActive) {
      emit(const BulkOperationError('No items selected'));
      return;
    }

    final currentState = state as SelectionModeActive;
    final selectedIds = currentState.selectedIds;

    try {
      emit(BulkDeleteInProgress(selectedIds));

      int deletedCount = 0;
      for (final id in selectedIds) {
        final result = await deleteSheetMusicUseCase.call(
          DeleteSheetMusicParams(id: id),
        );

        result.fold(
          (failure) => throw Exception(failure.toString()),
          (_) => deletedCount++,
        );
      }

      emit(BulkDeleteSuccess(deletedCount));
      emit(const BulkOperationsInitial());
    } catch (e) {
      emit(BulkOperationError(
        'Failed to delete items: $e',
        stackTrace: StackTrace.current,
      ));
    }
  }

  /// Cancel bulk selection
  void cancelSelection() {
    emit(const BulkOperationsInitial());
  }

  @override
  Future<void> close() async {
    // Clean up resources if needed
    return super.close();
  }
}
