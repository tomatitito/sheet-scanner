import 'package:sheet_scanner/core/error/failures.dart';
import 'package:sheet_scanner/core/utils/either.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

/// Repository interface for SheetMusic domain operations.
/// Implementations handle data source abstraction and error conversion.
abstract class SheetMusicRepository {
  /// Adds a new sheet music entry.
  Future<Either<Failure, SheetMusic>> add(SheetMusic sheetMusic);

  /// Retrieves a sheet music entry by ID.
  Future<Either<Failure, SheetMusic?>> getById(int id);

  /// Retrieves all sheet music entries.
  Future<Either<Failure, List<SheetMusic>>> getAll();

  /// Updates an existing sheet music entry.
  Future<Either<Failure, SheetMusic>> update(SheetMusic sheetMusic);

  /// Deletes a sheet music entry by ID.
  Future<Either<Failure, void>> delete(int id);

  /// Retrieves all sheet music entries for a specific composer.
  Future<Either<Failure, List<SheetMusic>>> getByComposer(String composer);

  /// Retrieves all sheet music entries with a specific tag.
  Future<Either<Failure, List<SheetMusic>>> getByTag(String tag);

  /// Finds sheet music by title and composer (for deduplication).
  Future<Either<Failure, SheetMusic?>> findByTitleAndComposer(
    String title,
    String composer,
  );

  /// Deletes all sheet music entries.
  Future<Either<Failure, void>> deleteAll();
}
