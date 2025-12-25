import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/delete_sheet_music_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/bulk_operations_cubit.dart';

/// Mock for DeleteSheetMusicUseCase
class MockDeleteSheetMusicUseCase extends Mock
    implements DeleteSheetMusicUseCase {}

/// Fallback for DeleteSheetMusicParams
class FakeDeleteSheetMusicParams extends Fake
    implements DeleteSheetMusicParams {}

void main() {
  group('BulkOperationsCubit', () {
    late MockDeleteSheetMusicUseCase mockDeleteSheetMusicUseCase;
    late BulkOperationsCubit bulkOperationsCubit;

    setUpAll(() {
      registerFallbackValue(FakeDeleteSheetMusicParams());
    });

    setUp(() {
      mockDeleteSheetMusicUseCase = MockDeleteSheetMusicUseCase();
      bulkOperationsCubit = BulkOperationsCubit(
        deleteSheetMusicUseCase: mockDeleteSheetMusicUseCase,
      );
    });

    tearDown(() async {
      await bulkOperationsCubit.close();
    });

    test('initial state is BulkOperationsInitial', () {
      expect(bulkOperationsCubit.state, isA<BulkOperationsInitial>());
    });

    group('toggleSelection', () {
      test('toggleSelection starts selection mode with single item', () {
        // Act
        bulkOperationsCubit.toggleSelection(1, 5);

        // Assert
        expect(bulkOperationsCubit.state, isA<SelectionModeActive>());
        final state = bulkOperationsCubit.state as SelectionModeActive;
        expect(state.selectedIds.contains(1), isTrue);
        expect(state.selectionCount, 1);
        expect(state.totalAvailable, 5);
      });

      test('toggleSelection adds multiple items', () {
        // Act
        bulkOperationsCubit.toggleSelection(1, 5);
        bulkOperationsCubit.toggleSelection(2, 5);
        bulkOperationsCubit.toggleSelection(3, 5);

        // Assert
        final state = bulkOperationsCubit.state as SelectionModeActive;
        expect(state.selectionCount, 3);
        expect(state.selectedIds, {1, 2, 3});
      });

      test('toggleSelection removes item when already selected', () {
        // Act
        bulkOperationsCubit.toggleSelection(1, 5);
        bulkOperationsCubit.toggleSelection(2, 5);
        bulkOperationsCubit.toggleSelection(1, 5); // Deselect

        // Assert
        final state = bulkOperationsCubit.state as SelectionModeActive;
        expect(state.selectionCount, 1);
        expect(state.selectedIds, {2});
      });

      test('toggleSelection returns to initial when last item deselected', () {
        // Act
        bulkOperationsCubit.toggleSelection(1, 5);
        bulkOperationsCubit.toggleSelection(1, 5); // Deselect only item

        // Assert
        expect(bulkOperationsCubit.state, isA<BulkOperationsInitial>());
      });

      test('toggleSelection works correctly with large numbers', () {
        // Act
        bulkOperationsCubit.toggleSelection(999, 1000);

        // Assert
        final state = bulkOperationsCubit.state as SelectionModeActive;
        expect(state.selectedIds.contains(999), isTrue);
      });
    });

    group('selectAll', () {
      test('selectAll selects all available items', () {
        // Act
        bulkOperationsCubit.selectAll(5);

        // Assert
        final state = bulkOperationsCubit.state as SelectionModeActive;
        expect(state.selectionCount, 5);
        expect(state.selectedIds, {1, 2, 3, 4, 5});
      });

      test('selectAll updates totalAvailable correctly', () {
        // Act
        bulkOperationsCubit.selectAll(10);

        // Assert
        final state = bulkOperationsCubit.state as SelectionModeActive;
        expect(state.totalAvailable, 10);
        expect(state.selectionCount, 10);
      });

      test('selectAll with 1 item', () {
        // Act
        bulkOperationsCubit.selectAll(1);

        // Assert
        final state = bulkOperationsCubit.state as SelectionModeActive;
        expect(state.selectionCount, 1);
        expect(state.selectedIds, {1});
      });

      test('selectAll with 0 items', () {
        // Act
        bulkOperationsCubit.selectAll(0);

        // Assert
        final state = bulkOperationsCubit.state as SelectionModeActive;
        expect(state.selectionCount, 0);
      });

      test('selectAll clears previous selections', () {
        // Arrange
        bulkOperationsCubit.toggleSelection(1, 5);

        // Act
        bulkOperationsCubit.selectAll(5);

        // Assert
        final state = bulkOperationsCubit.state as SelectionModeActive;
        expect(state.selectionCount, 5);
        expect(state.selectedIds, {1, 2, 3, 4, 5});
      });
    });

    group('deselectAll', () {
      test('deselectAll clears all selections', () {
        // Arrange
        bulkOperationsCubit.toggleSelection(1, 5);
        bulkOperationsCubit.toggleSelection(2, 5);

        // Act
        bulkOperationsCubit.deselectAll();

        // Assert
        expect(bulkOperationsCubit.state, isA<BulkOperationsInitial>());
      });

      test('deselectAll works from initial state', () {
        // Act
        bulkOperationsCubit.deselectAll();

        // Assert
        expect(bulkOperationsCubit.state, isA<BulkOperationsInitial>());
      });
    });

    group('isSelected', () {
      test('isSelected returns true for selected item', () {
        // Arrange
        bulkOperationsCubit.toggleSelection(1, 5);

        // Act & Assert
        expect(bulkOperationsCubit.isSelected(1), isTrue);
      });

      test('isSelected returns false for unselected item', () {
        // Arrange
        bulkOperationsCubit.toggleSelection(1, 5);

        // Act & Assert
        expect(bulkOperationsCubit.isSelected(2), isFalse);
      });

      test('isSelected returns false in initial state', () {
        // Act & Assert
        expect(bulkOperationsCubit.isSelected(1), isFalse);
      });

      test('isSelected works for multiple items', () {
        // Arrange
        bulkOperationsCubit.toggleSelection(1, 5);
        bulkOperationsCubit.toggleSelection(3, 5);
        bulkOperationsCubit.toggleSelection(5, 5);

        // Act & Assert
        expect(bulkOperationsCubit.isSelected(1), isTrue);
        expect(bulkOperationsCubit.isSelected(2), isFalse);
        expect(bulkOperationsCubit.isSelected(3), isTrue);
        expect(bulkOperationsCubit.isSelected(4), isFalse);
        expect(bulkOperationsCubit.isSelected(5), isTrue);
      });
    });

    group('selectionCount', () {
      test('selectionCount returns 0 in initial state', () {
        // Act & Assert
        expect(bulkOperationsCubit.selectionCount, 0);
      });

      test('selectionCount reflects selected items', () {
        // Arrange
        bulkOperationsCubit.toggleSelection(1, 5);
        expect(bulkOperationsCubit.selectionCount, 1);

        bulkOperationsCubit.toggleSelection(2, 5);
        expect(bulkOperationsCubit.selectionCount, 2);

        bulkOperationsCubit.toggleSelection(3, 5);
        // Act & Assert
        expect(bulkOperationsCubit.selectionCount, 3);
      });

      test('selectionCount updates on deselection', () {
        // Arrange
        bulkOperationsCubit.toggleSelection(1, 5);
        bulkOperationsCubit.toggleSelection(2, 5);

        // Act
        bulkOperationsCubit.toggleSelection(1, 5); // Deselect

        // Assert
        expect(bulkOperationsCubit.selectionCount, 1);
      });
    });

    group('bulkDelete', () {
      test('bulkDelete emits error when no items selected', () async {
        // Act & Assert
        expect(
          bulkOperationsCubit.stream,
          emitsInOrder([
            isA<BulkOperationError>(),
          ]),
        );

        await bulkOperationsCubit.bulkDelete();
      });

      test('bulkDelete deletes all selected items', () async {
        // Arrange
        bulkOperationsCubit.toggleSelection(1, 5);
        bulkOperationsCubit.toggleSelection(2, 5);
        when(() => mockDeleteSheetMusicUseCase(any()))
            .thenAnswer((_) async => Right(null));

        // Act
        await bulkOperationsCubit.bulkDelete();

        // Assert
        expect(bulkOperationsCubit.state, isA<BulkOperationsInitial>());
        verify(() => mockDeleteSheetMusicUseCase(any())).called(2);
      });

      test('bulkDelete emits success with count', () async {
        // Arrange
        bulkOperationsCubit.toggleSelection(1, 5);
        bulkOperationsCubit.toggleSelection(2, 5);
        bulkOperationsCubit.toggleSelection(3, 5);
        when(() => mockDeleteSheetMusicUseCase(any()))
            .thenAnswer((_) async => Right(null));

        // Act
        await bulkOperationsCubit.bulkDelete();

        // Assert
        // The state should go through: BulkDeleteInProgress, BulkDeleteSuccess, then BulkOperationsInitial
        expect(bulkOperationsCubit.state, isA<BulkOperationsInitial>());
        verify(() => mockDeleteSheetMusicUseCase(any())).called(3);
      });

      test('bulkDelete handles deletion failure gracefully', () async {
        // Arrange
        bulkOperationsCubit.toggleSelection(1, 5);
        final tFailure = DatabaseFailure(message: 'Delete failed');
        when(() => mockDeleteSheetMusicUseCase(any()))
            .thenAnswer((_) async => Left(tFailure));

        // Act
        await bulkOperationsCubit.bulkDelete();

        // Assert
        expect(bulkOperationsCubit.state, isA<BulkOperationError>());
        final state = bulkOperationsCubit.state as BulkOperationError;
        expect(state.message, contains('Failed to delete items'));
      });

      test('bulkDelete emits InProgress state first', () async {
        // Arrange
        bulkOperationsCubit.toggleSelection(1, 5);
        when(() => mockDeleteSheetMusicUseCase(any()))
            .thenAnswer((_) async => Right(null));

        // Act & Assert
        expect(
          bulkOperationsCubit.stream,
          emits(isA<BulkDeleteInProgress>()),
        );

        await bulkOperationsCubit.bulkDelete();
      });

      test('bulkDelete with single item', () async {
        // Arrange
        bulkOperationsCubit.toggleSelection(42, 100);
        when(() => mockDeleteSheetMusicUseCase(any()))
            .thenAnswer((_) async => Right(null));

        // Act
        await bulkOperationsCubit.bulkDelete();

        // Assert
        verify(() => mockDeleteSheetMusicUseCase(any())).called(1);
      });
    });

    group('cancelSelection', () {
      test('cancelSelection returns to initial state', () {
        // Arrange
        bulkOperationsCubit.toggleSelection(1, 5);
        bulkOperationsCubit.toggleSelection(2, 5);

        // Act
        bulkOperationsCubit.cancelSelection();

        // Assert
        expect(bulkOperationsCubit.state, isA<BulkOperationsInitial>());
      });

      test('cancelSelection works from any state', () {
        // Arrange
        bulkOperationsCubit.selectAll(10);

        // Act
        bulkOperationsCubit.cancelSelection();

        // Assert
        expect(bulkOperationsCubit.state, isA<BulkOperationsInitial>());
      });
    });

    test('close completes without errors', () async {
      // Act & Assert
      expect(bulkOperationsCubit.close(), completes);
    });

    test('workflow: select items, cancel, select all, delete', () async {
      // Arrange
      when(() => mockDeleteSheetMusicUseCase(any()))
          .thenAnswer((_) async => Right(null));

      // Act 1: Select some items
      bulkOperationsCubit.toggleSelection(1, 5);
      expect(bulkOperationsCubit.selectionCount, 1);

      // Act 2: Cancel selection
      bulkOperationsCubit.cancelSelection();
      expect(bulkOperationsCubit.selectionCount, 0);

      // Act 3: Select all
      bulkOperationsCubit.selectAll(5);
      expect(bulkOperationsCubit.selectionCount, 5);

      // Act 4: Delete
      await bulkOperationsCubit.bulkDelete();

      // Assert
      expect(bulkOperationsCubit.state, isA<BulkOperationsInitial>());
      verify(() => mockDeleteSheetMusicUseCase(any())).called(5);
    });
  });
}
