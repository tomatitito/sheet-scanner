// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_repository.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OCRResult {
  String get text => throw _privateConstructorUsedError;
  double get confidence => throw _privateConstructorUsedError;

  /// Create a copy of OCRResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $OCRResultCopyWith<OCRResult> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OCRResultCopyWith<$Res> {
  factory $OCRResultCopyWith(OCRResult value, $Res Function(OCRResult) then) =
      _$OCRResultCopyWithImpl<$Res, OCRResult>;
  @useResult
  $Res call({String text, double confidence});
}

/// @nodoc
class _$OCRResultCopyWithImpl<$Res, $Val extends OCRResult> implements $OCRResultCopyWith<$Res> {
  _$OCRResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OCRResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? confidence = null,
  }) {
    return _then(_value.copyWith(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OCRResultImplCopyWith<$Res> implements $OCRResultCopyWith<$Res> {
  factory _$$OCRResultImplCopyWith(_$OCRResultImpl value, $Res Function(_$OCRResultImpl) then) =
      __$$OCRResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, double confidence});
}

/// @nodoc
class __$$OCRResultImplCopyWithImpl<$Res> extends _$OCRResultCopyWithImpl<$Res, _$OCRResultImpl>
    implements _$$OCRResultImplCopyWith<$Res> {
  __$$OCRResultImplCopyWithImpl(_$OCRResultImpl _value, $Res Function(_$OCRResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of OCRResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? confidence = null,
  }) {
    return _then(_$OCRResultImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$OCRResultImpl implements _OCRResult {
  const _$OCRResultImpl({required this.text, required this.confidence});

  @override
  final String text;
  @override
  final double confidence;

  @override
  String toString() {
    return 'OCRResult(text: $text, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OCRResultImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.confidence, confidence) || other.confidence == confidence));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text, confidence);

  /// Create a copy of OCRResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OCRResultImplCopyWith<_$OCRResultImpl> get copyWith =>
      __$$OCRResultImplCopyWithImpl<_$OCRResultImpl>(this, _$identity);
}

abstract class _OCRResult implements OCRResult {
  const factory _OCRResult({required final String text, required final double confidence}) =
      _$OCRResultImpl;

  @override
  String get text;
  @override
  double get confidence;

  /// Create a copy of OCRResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OCRResultImplCopyWith<_$OCRResultImpl> get copyWith => throw _privateConstructorUsedError;
}
