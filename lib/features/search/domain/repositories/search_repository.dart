import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

/// Repository interface for search and filtering operations.
abstract class SearchRepository {
  /// Performs full-text search across sheet music.
  Future<Either<Failure, List<SheetMusic>>> fullTextSearch(String query);

  /// Searches by exact title.
  Future<Either<Failure, List<SheetMusic>>> searchByTitle(String title);

  /// Searches by exact composer.
  Future<Either<Failure, List<SheetMusic>>> searchByComposer(String composer);

  /// Filters sheet music by multiple tags.
  Future<Either<Failure, List<SheetMusic>>> filterByTags(List<String> tags);

  /// Filters sheet music by date range.
  Future<Either<Failure, List<SheetMusic>>> filterByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Combined search with filters and sorting.
  Future<Either<Failure, List<SheetMusic>>> advancedSearch({
    String? query,
    List<String>? tags,
    String? composer,
    String? sortBy,
    bool descending,
  });
}
