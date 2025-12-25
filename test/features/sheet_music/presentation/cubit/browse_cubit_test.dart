import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/usecases/get_all_sheet_music_use_case.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/browse_cubit.dart';
import 'package:sheet_scanner/features/sheet_music/presentation/cubit/browse_state.dart';

/// Mock for GetAllSheetMusicUseCase
class MockGetAllSheetMusicUseCase extends Mock
    implements GetAllSheetMusicUseCase {}

void main() {
  group('BrowseCubit', () {
    late MockGetAllSheetMusicUseCase mockGetAllSheetMusicUseCase;
    late BrowseCubit browseCubit;

    setUp(() {
      mockGetAllSheetMusicUseCase = MockGetAllSheetMusicUseCase();
      browseCubit = BrowseCubit(
        getAllSheetMusicUseCase: mockGetAllSheetMusicUseCase,
      );
    });

    tearDown(() async {
      await browseCubit.close();
    });

    final tSheetMusicList = [
      SheetMusic(
        id: 1,
        title: 'Moonlight Sonata',
        composer: 'Ludwig van Beethoven',
        createdAt: DateTime(2025, 12, 20),
        updatedAt: DateTime(2025, 12, 20),
        tags: ['classic', 'piano'],
        notes: 'Beautiful piece',
      ),
      SheetMusic(
        id: 2,
        title: 'Fur Elise',
        composer: 'Ludwig van Beethoven',
        createdAt: DateTime(2025, 12, 21),
        updatedAt: DateTime(2025, 12, 21),
        tags: ['classic', 'piano'],
        notes: 'German title',
      ),
      SheetMusic(
        id: 3,
        title: 'Clair de Lune',
        composer: 'Claude Debussy',
        createdAt: DateTime(2025, 12, 22),
        updatedAt: DateTime(2025, 12, 22),
        tags: ['impressionist', 'piano'],
        notes: 'Moonlight',
      ),
      SheetMusic(
        id: 4,
        title: 'Winter',
        composer: 'Antonio Vivaldi',
        createdAt: DateTime(2025, 12, 23),
        updatedAt: DateTime(2025, 12, 23),
        tags: ['baroque', 'violin'],
        notes: 'Four seasons',
      ),
    ];

    test('initial state is BrowseInitial', () {
      expect(browseCubit.state, isA<BrowseInitial>());
    });

    test('loadSheetMusic emits [BrowseLoading, BrowseLoaded] on success',
        () async {
      // Arrange
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(tSheetMusicList));

      // Act & Assert
      expect(
        browseCubit.stream,
        emitsInOrder([
          isA<BrowseLoading>(),
          isA<BrowseLoaded>(),
        ]),
      );

      await browseCubit.loadSheetMusic();
    });

    test('loadSheetMusic emits correct data on success', () async {
      // Arrange
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(tSheetMusicList));

      // Act
      await browseCubit.loadSheetMusic();

      // Assert
      expect(browseCubit.state, isA<BrowseLoaded>());
      final state = browseCubit.state as BrowseLoaded;
      expect(state.sheets.length, 4);
      expect(state.filteredSheets.length, 4);
      expect(state.searchQuery, '');
      expect(state.selectedTags, isEmpty);
      expect(state.sortBy, 'recent');
    });

    test('loadSheetMusic sorts by recent by default', () async {
      // Arrange
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(tSheetMusicList));

      // Act
      await browseCubit.loadSheetMusic();

      // Assert
      expect(browseCubit.state, isA<BrowseLoaded>());
      final state = browseCubit.state as BrowseLoaded;
      // Most recent first
      expect(state.filteredSheets[0].id, 4);
      expect(state.filteredSheets[1].id, 3);
      expect(state.filteredSheets[2].id, 2);
      expect(state.filteredSheets[3].id, 1);
    });

    test('loadSheetMusic emits [BrowseLoading, BrowseError] on failure',
        () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Database error');
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Left(tFailure));

      // Act & Assert
      expect(
        browseCubit.stream,
        emitsInOrder([
          isA<BrowseLoading>(),
          isA<BrowseError>(),
        ]),
      );

      await browseCubit.loadSheetMusic();
    });

    test('loadSheetMusic emits correct error on failure', () async {
      // Arrange
      final tFailure = DatabaseFailure(message: 'Database error');
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Left(tFailure));

      // Act
      await browseCubit.loadSheetMusic();

      // Assert
      expect(browseCubit.state, isA<BrowseError>());
      final state = browseCubit.state as BrowseError;
      expect(state.failure.message, 'Database error');
    });

    group('search', () {
      setUp(() async {
        when(() => mockGetAllSheetMusicUseCase.call())
            .thenAnswer((_) async => Right(tSheetMusicList));
        await browseCubit.loadSheetMusic();
      });

      test('search by title filters correctly', () async {
        // Act
        browseCubit.search('Moonlight');

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.searchQuery, 'Moonlight');
        expect(state.filteredSheets.length, 2); // Moonlight Sonata + Clair de Lune (matches notes)
        // Clair de Lune is more recent, so it comes first
        expect(state.filteredSheets[0].title, 'Clair de Lune');
        expect(state.filteredSheets[1].title, 'Moonlight Sonata');
      });

      test('search by composer filters correctly', () async {
        // Act
        browseCubit.search('Beethoven');

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.filteredSheets.length, 2);
        expect(state.filteredSheets.every((s) => s.composer.contains('Beethoven')),
            isTrue);
      });

      test('search is case insensitive', () async {
        // Act
        browseCubit.search('beethoven');

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.filteredSheets.length, 2);
      });

      test('search by notes filters correctly', () async {
        // Act
        browseCubit.search('Moonlight');

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.filteredSheets.any((s) => s.notes?.contains('Moonlight') ?? false),
            isTrue);
      });

      test('empty search returns all sheets', () async {
        // Act
        browseCubit.search('');

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.filteredSheets.length, 4);
      });

      test('search with no results returns empty list', () async {
        // Act
        browseCubit.search('NonExistent');

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.filteredSheets.length, 0);
      });
    });

    group('filterByTags', () {
      setUp(() async {
        when(() => mockGetAllSheetMusicUseCase.call())
            .thenAnswer((_) async => Right(tSheetMusicList));
        await browseCubit.loadSheetMusic();
      });

      test('filter by single tag', () async {
        // Act
        browseCubit.filterByTags(['piano']);

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.selectedTags, ['piano']);
        expect(state.filteredSheets.length, 3);
        expect(state.filteredSheets.every((s) => s.tags.contains('piano')), isTrue);
      });

      test('filter by multiple tags', () async {
        // Act
        browseCubit.filterByTags(['classic', 'piano']);

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.selectedTags.length, 2);
        // Should return items that have EITHER tag
        expect(state.filteredSheets.length, 3);
      });

      test('filter by nonexistent tag returns empty', () async {
        // Act
        browseCubit.filterByTags(['nonexistent']);

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.filteredSheets.length, 0);
      });

      test('clear filter returns all sheets', () async {
        // Act
        browseCubit.filterByTags(['piano']);
        browseCubit.filterByTags([]);

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.filteredSheets.length, 4);
      });

      test('filter combines with existing search', () async {
        // Act
        browseCubit.search('Beethoven');
        browseCubit.filterByTags(['piano']);

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.filteredSheets.length, 2);
        expect(state.filteredSheets.every((s) => 
            s.composer.contains('Beethoven') && s.tags.contains('piano')), 
            isTrue);
      });
    });

    group('sortBy', () {
      setUp(() async {
        when(() => mockGetAllSheetMusicUseCase.call())
            .thenAnswer((_) async => Right(tSheetMusicList));
        await browseCubit.loadSheetMusic();
      });

      test('sort by title', () async {
        // Act
        browseCubit.sortBy('title');

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.sortBy, 'title');
        expect(state.filteredSheets[0].title, 'Clair de Lune');
        expect(state.filteredSheets[3].title, 'Winter');
      });

      test('sort by composer', () async {
        // Act
        browseCubit.sortBy('composer');

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.sortBy, 'composer');
        expect(state.filteredSheets[0].composer, 'Antonio Vivaldi');
        expect(state.filteredSheets[3].composer, 'Ludwig van Beethoven');
      });

      test('sort by oldest', () async {
        // Act
        browseCubit.sortBy('oldest');

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.filteredSheets[0].id, 1);
        expect(state.filteredSheets[3].id, 4);
      });

      test('sort by recent', () async {
        // Act
        browseCubit.sortBy('recent');

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.filteredSheets[0].id, 4);
        expect(state.filteredSheets[3].id, 1);
      });

      test('invalid sort defaults to recent', () async {
        // Act
        browseCubit.sortBy('invalid');

        // Assert
        expect(browseCubit.state, isA<BrowseLoaded>());
        final state = browseCubit.state as BrowseLoaded;
        expect(state.filteredSheets[0].id, 4);
      });
    });

    test('clearFilters resets search and tags', () async {
      // Arrange
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(tSheetMusicList));
      await browseCubit.loadSheetMusic();

      // Act
      browseCubit.search('Beethoven');
      browseCubit.filterByTags(['piano']);
      browseCubit.clearFilters();

      // Assert
      expect(browseCubit.state, isA<BrowseLoaded>());
      final state = browseCubit.state as BrowseLoaded;
      expect(state.searchQuery, '');
      expect(state.selectedTags, isEmpty);
      expect(state.filteredSheets.length, 4);
    });

    test('getAllTags returns all unique tags sorted', () async {
      // Arrange
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(tSheetMusicList));
      await browseCubit.loadSheetMusic();

      // Act
      final tags = browseCubit.getAllTags();

      // Assert
      expect(tags.length, 5);
      expect(tags, [
        'baroque',
        'classic',
        'impressionist',
        'piano',
        'violin',
      ]);
    });

    test('getAllTags returns empty when no data loaded', () {
      // Act
      final tags = browseCubit.getAllTags();

      // Assert
      expect(tags, isEmpty);
    });

    test('refresh calls loadSheetMusic', () async {
      // Arrange
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(tSheetMusicList));

      // Act
      await browseCubit.refresh();

      // Assert
      verify(() => mockGetAllSheetMusicUseCase.call()).called(1);
      expect(browseCubit.state, isA<BrowseLoaded>());
    });

    test('refresh sets isRefreshing flag', () async {
      // Arrange
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(tSheetMusicList));
      await browseCubit.loadSheetMusic();

      // Act
      final refreshFuture = browseCubit.refresh();
      
      // The state should have isRefreshing true before completing
      expect(browseCubit.state, isA<BrowseLoaded>());
      final state = browseCubit.state as BrowseLoaded;
      expect(state.isRefreshing, isTrue);

      // Assert
      await refreshFuture;
    });

    test('handles empty library', () async {
      // Arrange
      when(() => mockGetAllSheetMusicUseCase.call())
          .thenAnswer((_) async => Right(<SheetMusic>[]));

      // Act
      await browseCubit.loadSheetMusic();

      // Assert
      expect(browseCubit.state, isA<BrowseLoaded>());
      final state = browseCubit.state as BrowseLoaded;
      expect(state.sheets, isEmpty);
      expect(state.filteredSheets, isEmpty);
    });

    test('close completes without errors', () async {
      // Act & Assert
      expect(browseCubit.close(), completes);
    });
  });
}
