import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/data/datasources/sheet_music_local_datasource.dart';
import 'package:sheet_scanner/features/sheet_music/data/models/sheet_music_model.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';
import 'package:sheet_scanner/features/sheet_music/domain/repositories/sheet_music_repository.dart';

/// Implementation of SheetMusicRepository using local database.
/// TODO: Complete implementation with actual database queries.
class SheetMusicRepositoryImpl implements SheetMusicRepository {
  final SheetMusicLocalDataSource localDataSource;

  SheetMusicRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, SheetMusic>> add(SheetMusic sheetMusic) async {
    try {
      final id = await localDataSource.insertSheetMusic(sheetMusic.toModel());

      // Handle tags
      for (final tag in sheetMusic.tags) {
        await localDataSource.addTagToSheetMusic(id, tag);
      }

      return Right(sheetMusic.copyWith(id: id));
    } catch (e) {
      return Left(
        DatabaseFailure(message: e.toString()),
      );
    }
  }

  @override
  Future<Either<Failure, void>> delete(int id) async {
    try {
      await localDataSource.deleteSheetMusic(id);
      return Right<Failure, void>(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAll() async {
    try {
      await localDataSource.deleteAllSheetMusic();
      return Right<Failure, void>(null);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SheetMusic?>> findByTitleAndComposer(
    String title,
    String composer,
  ) async {
    try {
      final model = await localDataSource.findSheetMusicByTitleAndComposer(
        title,
        composer,
      );
      if (model == null) return Right<Failure, SheetMusic?>(null);

      final tags = await localDataSource.getTagsForSheetMusic(model.id);
      return Right(model.toDomain(tags: tags));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SheetMusic>>> getAll() async {
    try {
      final models = await localDataSource.getAllSheetMusic();

      // Load tags for each model
      final musicWithTags = <SheetMusic>[];
      for (final model in models) {
        final tags = await localDataSource.getTagsForSheetMusic(model.id);
        musicWithTags.add(model.toDomain(tags: tags));
      }

      return Right(musicWithTags);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SheetMusic?>> getById(int id) async {
    try {
      final model = await localDataSource.getSheetMusicById(id);
      if (model == null) return Right<Failure, SheetMusic?>(null);

      final tags = await localDataSource.getTagsForSheetMusic(id);
      return Right(model.toDomain(tags: tags));
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SheetMusic>>> getByComposer(
      String composer) async {
    try {
      final models = await localDataSource.getSheetMusicByComposer(composer);

      // Load tags for each model
      final musicWithTags = <SheetMusic>[];
      for (final model in models) {
        final tags = await localDataSource.getTagsForSheetMusic(model.id);
        musicWithTags.add(model.toDomain(tags: tags));
      }

      return Right(musicWithTags);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SheetMusic>>> getByTag(String tag) async {
    try {
      final models = await localDataSource.getSheetMusicByTag(tag);

      // Load tags for each model
      final musicWithTags = <SheetMusic>[];
      for (final model in models) {
        final tags = await localDataSource.getTagsForSheetMusic(model.id);
        musicWithTags.add(model.toDomain(tags: tags));
      }

      return Right(musicWithTags);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SheetMusic>> update(SheetMusic sheetMusic) async {
    try {
      await localDataSource.updateSheetMusic(sheetMusic.toModel());

      // Update tags: clear old ones and add new ones
      final oldTags = await localDataSource.getTagsForSheetMusic(sheetMusic.id);
      for (final tag in oldTags) {
        await localDataSource.removeTagFromSheetMusic(sheetMusic.id, tag);
      }
      for (final tag in sheetMusic.tags) {
        await localDataSource.addTagToSheetMusic(sheetMusic.id, tag);
      }

      return Right(sheetMusic);
    } catch (e) {
      return Left(DatabaseFailure(message: e.toString()));
    }
  }
}
