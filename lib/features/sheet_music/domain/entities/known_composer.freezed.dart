// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'known_composer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

KnownComposer _$KnownComposerFromJson(Map<String, dynamic> json) {
  return _KnownComposer.fromJson(json);
}

/// @nodoc
mixin _$KnownComposer {
  String get name => throw _privateConstructorUsedError;
  String get completeName => throw _privateConstructorUsedError;
  String get epoch => throw _privateConstructorUsedError;
  String? get birth => throw _privateConstructorUsedError;
  String? get death => throw _privateConstructorUsedError;
  bool get isPopular => throw _privateConstructorUsedError;
  bool get isRecommended => throw _privateConstructorUsedError;

  /// Serializes this KnownComposer to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of KnownComposer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $KnownComposerCopyWith<KnownComposer> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $KnownComposerCopyWith<$Res> {
  factory $KnownComposerCopyWith(
          KnownComposer value, $Res Function(KnownComposer) then) =
      _$KnownComposerCopyWithImpl<$Res, KnownComposer>;
  @useResult
  $Res call(
      {String name,
      String completeName,
      String epoch,
      String? birth,
      String? death,
      bool isPopular,
      bool isRecommended});
}

/// @nodoc
class _$KnownComposerCopyWithImpl<$Res, $Val extends KnownComposer>
    implements $KnownComposerCopyWith<$Res> {
  _$KnownComposerCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of KnownComposer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? completeName = null,
    Object? epoch = null,
    Object? birth = freezed,
    Object? death = freezed,
    Object? isPopular = null,
    Object? isRecommended = null,
  }) {
    return _then(_value.copyWith(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      completeName: null == completeName
          ? _value.completeName
          : completeName // ignore: cast_nullable_to_non_nullable
              as String,
      epoch: null == epoch
          ? _value.epoch
          : epoch // ignore: cast_nullable_to_non_nullable
              as String,
      birth: freezed == birth
          ? _value.birth
          : birth // ignore: cast_nullable_to_non_nullable
              as String?,
      death: freezed == death
          ? _value.death
          : death // ignore: cast_nullable_to_non_nullable
              as String?,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
      isRecommended: null == isRecommended
          ? _value.isRecommended
          : isRecommended // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$KnownComposerImplCopyWith<$Res>
    implements $KnownComposerCopyWith<$Res> {
  factory _$$KnownComposerImplCopyWith(
          _$KnownComposerImpl value, $Res Function(_$KnownComposerImpl) then) =
      __$$KnownComposerImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String name,
      String completeName,
      String epoch,
      String? birth,
      String? death,
      bool isPopular,
      bool isRecommended});
}

/// @nodoc
class __$$KnownComposerImplCopyWithImpl<$Res>
    extends _$KnownComposerCopyWithImpl<$Res, _$KnownComposerImpl>
    implements _$$KnownComposerImplCopyWith<$Res> {
  __$$KnownComposerImplCopyWithImpl(
      _$KnownComposerImpl _value, $Res Function(_$KnownComposerImpl) _then)
      : super(_value, _then);

  /// Create a copy of KnownComposer
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = null,
    Object? completeName = null,
    Object? epoch = null,
    Object? birth = freezed,
    Object? death = freezed,
    Object? isPopular = null,
    Object? isRecommended = null,
  }) {
    return _then(_$KnownComposerImpl(
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      completeName: null == completeName
          ? _value.completeName
          : completeName // ignore: cast_nullable_to_non_nullable
              as String,
      epoch: null == epoch
          ? _value.epoch
          : epoch // ignore: cast_nullable_to_non_nullable
              as String,
      birth: freezed == birth
          ? _value.birth
          : birth // ignore: cast_nullable_to_non_nullable
              as String?,
      death: freezed == death
          ? _value.death
          : death // ignore: cast_nullable_to_non_nullable
              as String?,
      isPopular: null == isPopular
          ? _value.isPopular
          : isPopular // ignore: cast_nullable_to_non_nullable
              as bool,
      isRecommended: null == isRecommended
          ? _value.isRecommended
          : isRecommended // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$KnownComposerImpl implements _KnownComposer {
  const _$KnownComposerImpl(
      {required this.name,
      required this.completeName,
      required this.epoch,
      this.birth,
      this.death,
      this.isPopular = false,
      this.isRecommended = false});

  factory _$KnownComposerImpl.fromJson(Map<String, dynamic> json) =>
      _$$KnownComposerImplFromJson(json);

  @override
  final String name;
  @override
  final String completeName;
  @override
  final String epoch;
  @override
  final String? birth;
  @override
  final String? death;
  @override
  @JsonKey()
  final bool isPopular;
  @override
  @JsonKey()
  final bool isRecommended;

  @override
  String toString() {
    return 'KnownComposer(name: $name, completeName: $completeName, epoch: $epoch, birth: $birth, death: $death, isPopular: $isPopular, isRecommended: $isRecommended)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$KnownComposerImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.completeName, completeName) ||
                other.completeName == completeName) &&
            (identical(other.epoch, epoch) || other.epoch == epoch) &&
            (identical(other.birth, birth) || other.birth == birth) &&
            (identical(other.death, death) || other.death == death) &&
            (identical(other.isPopular, isPopular) ||
                other.isPopular == isPopular) &&
            (identical(other.isRecommended, isRecommended) ||
                other.isRecommended == isRecommended));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, completeName, epoch, birth,
      death, isPopular, isRecommended);

  /// Create a copy of KnownComposer
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$KnownComposerImplCopyWith<_$KnownComposerImpl> get copyWith =>
      __$$KnownComposerImplCopyWithImpl<_$KnownComposerImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$KnownComposerImplToJson(
      this,
    );
  }
}

abstract class _KnownComposer implements KnownComposer {
  const factory _KnownComposer(
      {required final String name,
      required final String completeName,
      required final String epoch,
      final String? birth,
      final String? death,
      final bool isPopular,
      final bool isRecommended}) = _$KnownComposerImpl;

  factory _KnownComposer.fromJson(Map<String, dynamic> json) =
      _$KnownComposerImpl.fromJson;

  @override
  String get name;
  @override
  String get completeName;
  @override
  String get epoch;
  @override
  String? get birth;
  @override
  String? get death;
  @override
  bool get isPopular;
  @override
  bool get isRecommended;

  /// Create a copy of KnownComposer
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$KnownComposerImplCopyWith<_$KnownComposerImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
