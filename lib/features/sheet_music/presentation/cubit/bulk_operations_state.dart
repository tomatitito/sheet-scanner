part of 'bulk_operations_cubit.dart';

/// Base state for bulk operations
abstract class BulkOperationsState extends Equatable {
  const BulkOperationsState();

  @override
  List<Object?> get props => [];
}

/// Initial state with empty selection
class BulkOperationsInitial extends BulkOperationsState {
  const BulkOperationsInitial();
}

/// Selection mode is active
class SelectionModeActive extends BulkOperationsState {
  final Set<int> selectedIds;
  final int totalAvailable;

  const SelectionModeActive({
    required this.selectedIds,
    required this.totalAvailable,
  });

  @override
  List<Object?> get props => [selectedIds, totalAvailable];

  /// Get the number of selected items
  int get selectionCount => selectedIds.length;

  /// Check if all items are selected
  bool get allSelected => selectedIds.length == totalAvailable;

  /// Get percentage of selected items
  double get selectionPercentage =>
      totalAvailable > 0 ? (selectionCount / totalAvailable) * 100 : 0;
}

/// Bulk delete operation is in progress
class BulkDeleteInProgress extends BulkOperationsState {
  final Set<int> itemsBeingDeleted;

  const BulkDeleteInProgress(this.itemsBeingDeleted);

  @override
  List<Object?> get props => [itemsBeingDeleted];
}

/// Bulk delete completed successfully
class BulkDeleteSuccess extends BulkOperationsState {
  final int deletedCount;

  const BulkDeleteSuccess(this.deletedCount);

  @override
  List<Object?> get props => [deletedCount];
}

/// Bulk operation failed
class BulkOperationError extends BulkOperationsState {
  final String message;
  final StackTrace? stackTrace;

  const BulkOperationError(this.message, {this.stackTrace});

  @override
  List<Object?> get props => [message];
}
