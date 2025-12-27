import 'dart:convert';
import 'package:sheet_scanner/core/database/database.dart';
import 'package:sheet_scanner/features/sheet_music/domain/entities/sheet_music.dart';

/// Extension to convert database SheetMusicModel to domain SheetMusic entity.
extension SheetMusicModelExt on SheetMusicModel {
  /// Converts database model to domain entity.
  SheetMusic toDomain({List<String> tags = const []}) {
    List<String> imageUrls = [];
    try {
      if (this.imageUrls.isNotEmpty && this.imageUrls != '[]') {
        imageUrls = List<String>.from(jsonDecode(this.imageUrls) as List);
      }
    } catch (e) {
      // If JSON decoding fails, fall back to empty list
      imageUrls = [];
    }

    return SheetMusic(
      id: id,
      title: title,
      composer: composer,
      notes: notes,
      imageUrls: imageUrls,
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
      imageUrls: imageUrls.isEmpty ? '[]' : jsonEncode(imageUrls),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
