import 'package:sheet_scanner/core/database/database.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

/// Extension to convert database SheetMusicModel to domain SheetMusic entity.
extension SheetMusicModelExt on SheetMusicModel {
  /// Converts database model to domain entity.
  SheetMusic toDomain({List<String> tags = const []}) {
    return SheetMusic(
      id: id,
      title: title,
      composer: composer,
      notes: notes,
      imageUrls: const [], // Image URLs stored separately if needed
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Extension on SheetMusic domain entity to convert to database model.
extension SheetMusicToDatabaseExt on SheetMusic {
  /// Converts domain entity to database model for insertion.
  SheetMusicModel toModel() {
    return SheetMusicModel(
      id: id,
      title: title,
      composer: composer,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
