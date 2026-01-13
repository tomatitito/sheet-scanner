import 'package:freezed_annotation/freezed_annotation.dart';

part 'known_composer.freezed.dart';
part 'known_composer.g.dart';

@freezed
class KnownComposer with _$KnownComposer {
  const factory KnownComposer({
    required String name,
    required String completeName,
    required String epoch,
    String? birth,
    String? death,
    @Default(false) bool isPopular,
    @Default(false) bool isRecommended,
  }) = _KnownComposer;

  factory KnownComposer.fromJson(Map<String, dynamic> json) =>
      _$KnownComposerFromJson(json);
}

extension KnownComposerX on KnownComposer {
  String get displayName => completeName;

  String? get birthYear => birth?.substring(0, 4);

  String? get deathYear => death?.substring(0, 4);

  String get lifespan {
    final by = birthYear ?? '?';
    final dy = deathYear ?? 'living';
    return '$by–$dy';
  }

  String get displayWithLifespan => '$completeName ($lifespan)';
}
