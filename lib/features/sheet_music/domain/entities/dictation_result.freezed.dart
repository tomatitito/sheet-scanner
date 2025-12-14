// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dictation_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DictationResult {
  /// The transcribed text from speech recognition.
  String get text => throw _privateConstructorUsedError;

  /// Confidence level of the recognition (0.0 - 1.0).
  /// Higher values indicate greater confidence.
  double get confidence => throw _privateConstructorUsedError;

  /// Whether this is the final result or a partial result.
  /// Partial results are shown during listening, final when stopped.
  bool get isFinal => throw _privateConstructorUsedError;

  /// Duration of the voice input/recording.
  Duration get duration => throw _privateConstructorUsedError;

  /// Create a copy of DictationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DictationResultCopyWith<DictationResult> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DictationResultCopyWith<$Res> {
  factory $DictationResultCopyWith(
          DictationResult value, $Res Function(DictationResult) then) =
      _$DictationResultCopyWithImpl<$Res, DictationResult>;
  @useResult
  $Res call({String text, double confidence, bool isFinal, Duration duration});
}

/// @nodoc
class _$DictationResultCopyWithImpl<$Res, $Val extends DictationResult>
    implements $DictationResultCopyWith<$Res> {
  _$DictationResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DictationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? confidence = null,
    Object? isFinal = null,
    Object? duration = null,
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
      isFinal: null == isFinal
          ? _value.isFinal
          : isFinal // ignore: cast_nullable_to_non_nullable
              as bool,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DictationResultImplCopyWith<$Res>
    implements $DictationResultCopyWith<$Res> {
  factory _$$DictationResultImplCopyWith(_$DictationResultImpl value,
          $Res Function(_$DictationResultImpl) then) =
      __$$DictationResultImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String text, double confidence, bool isFinal, Duration duration});
}

/// @nodoc
class __$$DictationResultImplCopyWithImpl<$Res>
    extends _$DictationResultCopyWithImpl<$Res, _$DictationResultImpl>
    implements _$$DictationResultImplCopyWith<$Res> {
  __$$DictationResultImplCopyWithImpl(
      _$DictationResultImpl _value, $Res Function(_$DictationResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of DictationResult
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? confidence = null,
    Object? isFinal = null,
    Object? duration = null,
  }) {
    return _then(_$DictationResultImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
      isFinal: null == isFinal
          ? _value.isFinal
          : isFinal // ignore: cast_nullable_to_non_nullable
              as bool,
      duration: null == duration
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _$DictationResultImpl implements _DictationResult {
  const _$DictationResultImpl(
      {required this.text,
      this.confidence = 0.0,
      this.isFinal = false,
      this.duration = Duration.zero});

  /// The transcribed text from speech recognition.
  @override
  final String text;

  /// Confidence level of the recognition (0.0 - 1.0).
  /// Higher values indicate greater confidence.
  @override
  @JsonKey()
  final double confidence;

  /// Whether this is the final result or a partial result.
  /// Partial results are shown during listening, final when stopped.
  @override
  @JsonKey()
  final bool isFinal;

  /// Duration of the voice input/recording.
  @override
  @JsonKey()
  final Duration duration;

  @override
  String toString() {
    return 'DictationResult(text: $text, confidence: $confidence, isFinal: $isFinal, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DictationResultImpl &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence) &&
            (identical(other.isFinal, isFinal) || other.isFinal == isFinal) &&
            (identical(other.duration, duration) ||
                other.duration == duration));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, text, confidence, isFinal, duration);

  /// Create a copy of DictationResult
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DictationResultImplCopyWith<_$DictationResultImpl> get copyWith =>
      __$$DictationResultImplCopyWithImpl<_$DictationResultImpl>(
          this, _$identity);
}

abstract class _DictationResult implements DictationResult {
  const factory _DictationResult(
      {required final String text,
      final double confidence,
      final bool isFinal,
      final Duration duration}) = _$DictationResultImpl;

  /// The transcribed text from speech recognition.
  @override
  String get text;

  /// Confidence level of the recognition (0.0 - 1.0).
  /// Higher values indicate greater confidence.
  @override
  double get confidence;

  /// Whether this is the final result or a partial result.
  /// Partial results are shown during listening, final when stopped.
  @override
  bool get isFinal;

  /// Duration of the voice input/recording.
  @override
  Duration get duration;

  /// Create a copy of DictationResult
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DictationResultImplCopyWith<_$DictationResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
