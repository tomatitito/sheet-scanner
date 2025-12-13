import 'package:freezed_annotation/freezed_annotation.dart';

part 'composer.freezed.dart';

@freezed
class Composer with _$Composer {
  const factory Composer({
    required int id,
    required String name,
    @Default(0) int count,
  }) = _Composer;
}
