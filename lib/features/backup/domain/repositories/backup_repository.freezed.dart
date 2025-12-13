// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ExportResult {
  /// Path to the exported file
  String get filePath => throw _privateConstructorUsedError;

  /// Format of the export (json, zip, db)
  String get format => throw _privateConstructorUsedError;

  /// Number of items exported
  int get itemCount => throw _privateConstructorUsedError;

  /// Create a copy of ExportResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExportResultCopyWith<ExportResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExportResultCopyWith<$Res> {
  factory $ExportResultCopyWith(
          ExportResult value, $Res Function(ExportResult) then) =
      _$ExportResultCopyWithImpl<$Res, ExportResult>;
  @useResult
  $Res call({String filePath, String format, int itemCount});
}

/// @nodoc
class _$ExportResultCopyWithImpl<$Res, $Val extends ExportResult>
    implements $ExportResultCopyWith<$Res> {
  _$ExportResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExportResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = null,
    Object? format = null,
    Object? itemCount = null,
  }) {
    return _then(_value.copyWith(
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      itemCount: null == itemCount
          ? _value.itemCount
          : itemCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExportResultImplCopyWith<$Res>
    implements $ExportResultCopyWith<$Res> {
  factory _$$ExportResultImplCopyWith(
          _$ExportResultImpl value, $Res Function(_$ExportResultImpl) then) =
      __$$ExportResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String filePath, String format, int itemCount});
}

/// @nodoc
class __$$ExportResultImplCopyWithImpl<$Res>
    extends _$ExportResultCopyWithImpl<$Res, _$ExportResultImpl>
    implements _$$ExportResultImplCopyWith<$Res> {
  __$$ExportResultImplCopyWithImpl(
      _$ExportResultImpl _value, $Res Function(_$ExportResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExportResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? filePath = null,
    Object? format = null,
    Object? itemCount = null,
  }) {
    return _then(_$ExportResultImpl(
      filePath: null == filePath
          ? _value.filePath
          : filePath // ignore: cast_nullable_to_non_nullable
              as String,
      format: null == format
          ? _value.format
          : format // ignore: cast_nullable_to_non_nullable
              as String,
      itemCount: null == itemCount
          ? _value.itemCount
          : itemCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ExportResultImpl implements _ExportResult {
  const _$ExportResultImpl(
      {required this.filePath, required this.format, required this.itemCount});

  /// Path to the exported file
  @override
  final String filePath;

  /// Format of the export (json, zip, db)
  @override
  final String format;

  /// Number of items exported
  @override
  final int itemCount;

  @override
  String toString() {
    return 'ExportResult(filePath: $filePath, format: $format, itemCount: $itemCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportResultImpl &&
            (identical(other.filePath, filePath) ||
                other.filePath == filePath) &&
            (identical(other.format, format) || other.format == format) &&
            (identical(other.itemCount, itemCount) ||
                other.itemCount == itemCount));
  }

  @override
  int get hashCode => Object.hash(runtimeType, filePath, format, itemCount);

  /// Create a copy of ExportResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportResultImplCopyWith<_$ExportResultImpl> get copyWith =>
      __$$ExportResultImplCopyWithImpl<_$ExportResultImpl>(this, _$identity);
}

abstract class _ExportResult implements ExportResult {
  const factory _ExportResult(
      {required final String filePath,
      required final String format,
      required final int itemCount}) = _$ExportResultImpl;

  /// Path to the exported file
  @override
  String get filePath;

  /// Format of the export (json, zip, db)
  @override
  String get format;

  /// Number of items exported
  @override
  int get itemCount;

  /// Create a copy of ExportResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExportResultImplCopyWith<_$ExportResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ImportResult {
  /// Total number of items processed
  int get totalProcessed => throw _privateConstructorUsedError;

  /// Number successfully imported
  int get imported => throw _privateConstructorUsedError;

  /// Number skipped due to duplicates or validation
  int get skipped => throw _privateConstructorUsedError;

  /// Number failed to import
  int get failed => throw _privateConstructorUsedError;

  /// Create a copy of ImportResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ImportResultCopyWith<ImportResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ImportResultCopyWith<$Res> {
  factory $ImportResultCopyWith(
          ImportResult value, $Res Function(ImportResult) then) =
      _$ImportResultCopyWithImpl<$Res, ImportResult>;
  @useResult
  $Res call({int totalProcessed, int imported, int skipped, int failed});
}

/// @nodoc
class _$ImportResultCopyWithImpl<$Res, $Val extends ImportResult>
    implements $ImportResultCopyWith<$Res> {
  _$ImportResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ImportResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalProcessed = null,
    Object? imported = null,
    Object? skipped = null,
    Object? failed = null,
  }) {
    return _then(_value.copyWith(
      totalProcessed: null == totalProcessed
          ? _value.totalProcessed
          : totalProcessed // ignore: cast_nullable_to_non_nullable
              as int,
      imported: null == imported
          ? _value.imported
          : imported // ignore: cast_nullable_to_non_nullable
              as int,
      skipped: null == skipped
          ? _value.skipped
          : skipped // ignore: cast_nullable_to_non_nullable
              as int,
      failed: null == failed
          ? _value.failed
          : failed // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ImportResultImplCopyWith<$Res>
    implements $ImportResultCopyWith<$Res> {
  factory _$$ImportResultImplCopyWith(
          _$ImportResultImpl value, $Res Function(_$ImportResultImpl) then) =
      __$$ImportResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int totalProcessed, int imported, int skipped, int failed});
}

/// @nodoc
class __$$ImportResultImplCopyWithImpl<$Res>
    extends _$ImportResultCopyWithImpl<$Res, _$ImportResultImpl>
    implements _$$ImportResultImplCopyWith<$Res> {
  __$$ImportResultImplCopyWithImpl(
      _$ImportResultImpl _value, $Res Function(_$ImportResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of ImportResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalProcessed = null,
    Object? imported = null,
    Object? skipped = null,
    Object? failed = null,
  }) {
    return _then(_$ImportResultImpl(
      totalProcessed: null == totalProcessed
          ? _value.totalProcessed
          : totalProcessed // ignore: cast_nullable_to_non_nullable
              as int,
      imported: null == imported
          ? _value.imported
          : imported // ignore: cast_nullable_to_non_nullable
              as int,
      skipped: null == skipped
          ? _value.skipped
          : skipped // ignore: cast_nullable_to_non_nullable
              as int,
      failed: null == failed
          ? _value.failed
          : failed // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ImportResultImpl implements _ImportResult {
  const _$ImportResultImpl(
      {required this.totalProcessed,
      required this.imported,
      required this.skipped,
      required this.failed});

  /// Total number of items processed
  @override
  final int totalProcessed;

  /// Number successfully imported
  @override
  final int imported;

  /// Number skipped due to duplicates or validation
  @override
  final int skipped;

  /// Number failed to import
  @override
  final int failed;

  @override
  String toString() {
    return 'ImportResult(totalProcessed: $totalProcessed, imported: $imported, skipped: $skipped, failed: $failed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImportResultImpl &&
            (identical(other.totalProcessed, totalProcessed) ||
                other.totalProcessed == totalProcessed) &&
            (identical(other.imported, imported) ||
                other.imported == imported) &&
            (identical(other.skipped, skipped) || other.skipped == skipped) &&
            (identical(other.failed, failed) || other.failed == failed));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, totalProcessed, imported, skipped, failed);

  /// Create a copy of ImportResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImportResultImplCopyWith<_$ImportResultImpl> get copyWith =>
      __$$ImportResultImplCopyWithImpl<_$ImportResultImpl>(this, _$identity);
}

abstract class _ImportResult implements ImportResult {
  const factory _ImportResult(
      {required final int totalProcessed,
      required final int imported,
      required final int skipped,
      required final int failed}) = _$ImportResultImpl;

  /// Total number of items processed
  @override
  int get totalProcessed;

  /// Number successfully imported
  @override
  int get imported;

  /// Number skipped due to duplicates or validation
  @override
  int get skipped;

  /// Number failed to import
  @override
  int get failed;

  /// Create a copy of ImportResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImportResultImplCopyWith<_$ImportResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
