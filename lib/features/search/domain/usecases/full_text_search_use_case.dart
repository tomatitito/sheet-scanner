import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/search/domain/repositories/search_repository.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

/// Use case for full-text search across sheet music.
/// Validates search query and delegates to repository.
class FullTextSearchUseCase {
  final SearchRepository repository;

  FullTextSearchUseCase({required this.repository});

  /// Performs full-text search with the given query.
  /// Returns matching sheet music entries.
  Future<Either<Failure, List<SheetMusic>>> call(String query) {
    if (query.trim().isEmpty) {
      return Future.value(Right<Failure, List<SheetMusic>>([]));
    }
    return repository.fullTextSearch(query);
  }
}
