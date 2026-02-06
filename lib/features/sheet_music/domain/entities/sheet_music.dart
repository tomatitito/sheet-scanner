import 'package:freezed_annotation/freezed_annotation.dart';

part 'sheet_music.freezed.dart';

@freezed
class SheetMusic with _$SheetMusic {
  const factory SheetMusic({
    required int id,
    required String title,
    required String composer,
    String? opus,
    String? musicalKey,
    String? source,
    String? notes,
    /// Difficulty level on a scale of 1-5 (from zerluth.de)
    int? difficulty,
    /// Instrumentation, e.g., "Fl,Pno", "Zwei Flöten" (from zerluth.de)
    String? instrumentation,
    /// Musical epoch/era, e.g., "Baroque", "Classical", "Romantic"
    String? epoch,
    @Default([]) List<String> imageUrls,
    @Default([]) List<String> tags,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _SheetMusic;
}
