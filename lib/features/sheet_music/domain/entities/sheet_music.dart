import 'package:freezed_annotation/freezed_annotation.dart';

part 'sheet_music.freezed.dart';

@freezed
class SheetMusic with _$SheetMusic {
  const factory SheetMusic({
    required int id,
    required String title,
    required String composer,
    String? notes,
    @Default([]) List<String> imageUrls,
    @Default([]) List<String> tags,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SheetMusic;
}
