import 'package:sheet_scanner/core/database/database.dart';
import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/search/data/datasources/search_local_datasource.dart';
import 'package:sheet_scanner/features/search/domain/repositories/search_repository.dart';
import 'package:sheet_scanner/features/sheet_music/data/models/sheet_music_model.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

/// Implementation of SearchRepository using local database.
/// TODO: Complete implementation with actual search logic.
class SearchRepositoryImpl implements SearchRepository {
  final SearchLocalDataSource localDataSource;

  SearchRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<SheetMusic>>> advancedSearch({
    String? query,
    List<String>? tags,
    String? composer,
    String? sortBy,
    bool descending = false,
  }) async {
    try {
      final models = await localDataSource.advancedSearch(
        query: query,
        tags: tags,
        composer: composer,
        sortBy: sortBy,
        descending: descending,
      );
      final results = await _modelsToEntities(models);
      return Right(results);
    } catch (e) {
      return Left(SearchFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SheetMusic>>> filterByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final models =
          await localDataSource.filterByDateRange(startDate, endDate);
      final results = await _modelsToEntities(models);
      return Right(results);
    } catch (e) {
      return Left(SearchFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SheetMusic>>> filterByTags(
    List<String> tags,
  ) async {
    try {
      final models = await localDataSource.filterByTags(tags);
      final results = await _modelsToEntities(models);
      return Right(results);
    } catch (e) {
      return Left(SearchFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SheetMusic>>> fullTextSearch(String query) async {
    try {
      final models = await localDataSource.fullTextSearch(query);
      final results = await _modelsToEntities(models);
      return Right(results);
    } catch (e) {
      return Left(SearchFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SheetMusic>>> searchByComposer(
    String composer,
  ) async {
    try {
      final models = await localDataSource.searchByComposer(composer);
      final results = await _modelsToEntities(models);
      return Right(results);
    } catch (e) {
      return Left(SearchFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SheetMusic>>> searchByTitle(String title) async {
    try {
      final models = await localDataSource.searchByTitle(title);
      final results = await _modelsToEntities(models);
      return Right(results);
    } catch (e) {
      return Left(SearchFailure(message: e.toString()));
    }
  }

  /// Helper to convert database models to domain entities.
  Future<List<SheetMusic>> _modelsToEntities(
    List<SheetMusicModel> models,
  ) async {
    return models.map((model) => model.toDomain()).toList();
  }
}
