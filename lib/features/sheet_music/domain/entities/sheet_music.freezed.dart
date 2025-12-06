// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sheet_music.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SheetMusic {
  int get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String get composer => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;
  List<String> get imageUrls => throw _privateConstructorUsedError;
  List<String> get tags => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get updatedAt => throw _privateConstructorUsedError;

  /// Create a copy of SheetMusic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SheetMusicCopyWith<SheetMusic> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SheetMusicCopyWith<$Res> {
  factory $SheetMusicCopyWith(
          SheetMusic value, $Res Function(SheetMusic) then) =
      _$SheetMusicCopyWithImpl<$Res, SheetMusic>;
  @useResult
  $Res call(
      {int id,
      String title,
      String composer,
      String? notes,
      List<String> imageUrls,
      List<String> tags,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class _$SheetMusicCopyWithImpl<$Res, $Val extends SheetMusic>
    implements $SheetMusicCopyWith<$Res> {
  _$SheetMusicCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SheetMusic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? composer = null,
    Object? notes = freezed,
    Object? imageUrls = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      composer: null == composer
          ? _value.composer
          : composer // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: null == imageUrls
          ? _value.imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SheetMusicImplCopyWith<$Res>
    implements $SheetMusicCopyWith<$Res> {
  factory _$$SheetMusicImplCopyWith(
          _$SheetMusicImpl value, $Res Function(_$SheetMusicImpl) then) =
      __$$SheetMusicImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String title,
      String composer,
      String? notes,
      List<String> imageUrls,
      List<String> tags,
      DateTime createdAt,
      DateTime updatedAt});
}

/// @nodoc
class __$$SheetMusicImplCopyWithImpl<$Res>
    extends _$SheetMusicCopyWithImpl<$Res, _$SheetMusicImpl>
    implements _$$SheetMusicImplCopyWith<$Res> {
  __$$SheetMusicImplCopyWithImpl(
      _$SheetMusicImpl _value, $Res Function(_$SheetMusicImpl) _then)
      : super(_value, _then);

  /// Create a copy of SheetMusic
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? composer = null,
    Object? notes = freezed,
    Object? imageUrls = null,
    Object? tags = null,
    Object? createdAt = null,
    Object? updatedAt = null,
  }) {
    return _then(_$SheetMusicImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      composer: null == composer
          ? _value.composer
          : composer // ignore: cast_nullable_to_non_nullable
              as String,
      notes: freezed == notes
          ? _value.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrls: null == imageUrls
          ? _value._imageUrls
          : imageUrls // ignore: cast_nullable_to_non_nullable
              as List<String>,
      tags: null == tags
          ? _value._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      updatedAt: null == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc

class _$SheetMusicImpl implements _SheetMusic {
  const _$SheetMusicImpl(
      {required this.id,
      required this.title,
      required this.composer,
      this.notes,
      final List<String> imageUrls = const [],
      final List<String> tags = const [],
      required this.createdAt,
      required this.updatedAt})
      : _imageUrls = imageUrls,
        _tags = tags;

  @override
  final int id;
  @override
  final String title;
  @override
  final String composer;
  @override
  final String? notes;
  final List<String> _imageUrls;
  @override
  @JsonKey()
  List<String> get imageUrls {
    if (_imageUrls is EqualUnmodifiableListView) return _imageUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_imageUrls);
  }

  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  @override
  String toString() {
    return 'SheetMusic(id: $id, title: $title, composer: $composer, notes: $notes, imageUrls: $imageUrls, tags: $tags, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SheetMusicImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.composer, composer) ||
                other.composer == composer) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality()
                .equals(other._imageUrls, _imageUrls) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      title,
      composer,
      notes,
      const DeepCollectionEquality().hash(_imageUrls),
      const DeepCollectionEquality().hash(_tags),
      createdAt,
      updatedAt);

  /// Create a copy of SheetMusic
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SheetMusicImplCopyWith<_$SheetMusicImpl> get copyWith =>
      __$$SheetMusicImplCopyWithImpl<_$SheetMusicImpl>(this, _$identity);
}

abstract class _SheetMusic implements SheetMusic {
  const factory _SheetMusic(
      {required final int id,
      required final String title,
      required final String composer,
      final String? notes,
      final List<String> imageUrls,
      final List<String> tags,
      required final DateTime createdAt,
      required final DateTime updatedAt}) = _$SheetMusicImpl;

  @override
  int get id;
  @override
  String get title;
  @override
  String get composer;
  @override
  String? get notes;
  @override
  List<String> get imageUrls;
  @override
  List<String> get tags;
  @override
  DateTime get createdAt;
  @override
  DateTime get updatedAt;

  /// Create a copy of SheetMusic
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SheetMusicImplCopyWith<_$SheetMusicImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
