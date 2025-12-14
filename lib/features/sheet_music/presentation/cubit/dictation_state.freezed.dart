// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dictation_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$DictationState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String currentTranscription, Duration elapsedTime)
        listening,
    required TResult Function(String text) partialResult,
    required TResult Function(String transcription) processing,
    required TResult Function(String finalText, double confidence) complete,
    required TResult Function(Failure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult? Function(String text)? partialResult,
    TResult? Function(String transcription)? processing,
    TResult? Function(String finalText, double confidence)? complete,
    TResult? Function(Failure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult Function(String text)? partialResult,
    TResult Function(String transcription)? processing,
    TResult Function(String finalText, double confidence)? complete,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Listening value) listening,
    required TResult Function(_PartialResult value) partialResult,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Complete value) complete,
    required TResult Function(_Error value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Listening value)? listening,
    TResult? Function(_PartialResult value)? partialResult,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Complete value)? complete,
    TResult? Function(_Error value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Listening value)? listening,
    TResult Function(_PartialResult value)? partialResult,
    TResult Function(_Processing value)? processing,
    TResult Function(_Complete value)? complete,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DictationStateCopyWith<$Res> {
  factory $DictationStateCopyWith(
          DictationState value, $Res Function(DictationState) then) =
      _$DictationStateCopyWithImpl<$Res, DictationState>;
}

/// @nodoc
class _$DictationStateCopyWithImpl<$Res, $Val extends DictationState>
    implements $DictationStateCopyWith<$Res> {
  _$DictationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$IdleImplCopyWith<$Res> {
  factory _$$IdleImplCopyWith(
          _$IdleImpl value, $Res Function(_$IdleImpl) then) =
      __$$IdleImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$IdleImplCopyWithImpl<$Res>
    extends _$DictationStateCopyWithImpl<$Res, _$IdleImpl>
    implements _$$IdleImplCopyWith<$Res> {
  __$$IdleImplCopyWithImpl(_$IdleImpl _value, $Res Function(_$IdleImpl) _then)
      : super(_value, _then);

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$IdleImpl implements _Idle {
  const _$IdleImpl();

  @override
  String toString() {
    return 'DictationState.idle()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$IdleImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String currentTranscription, Duration elapsedTime)
        listening,
    required TResult Function(String text) partialResult,
    required TResult Function(String transcription) processing,
    required TResult Function(String finalText, double confidence) complete,
    required TResult Function(Failure failure) error,
  }) {
    return idle();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult? Function(String text)? partialResult,
    TResult? Function(String transcription)? processing,
    TResult? Function(String finalText, double confidence)? complete,
    TResult? Function(Failure failure)? error,
  }) {
    return idle?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult Function(String text)? partialResult,
    TResult Function(String transcription)? processing,
    TResult Function(String finalText, double confidence)? complete,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Listening value) listening,
    required TResult Function(_PartialResult value) partialResult,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Complete value) complete,
    required TResult Function(_Error value) error,
  }) {
    return idle(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Listening value)? listening,
    TResult? Function(_PartialResult value)? partialResult,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Complete value)? complete,
    TResult? Function(_Error value)? error,
  }) {
    return idle?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Listening value)? listening,
    TResult Function(_PartialResult value)? partialResult,
    TResult Function(_Processing value)? processing,
    TResult Function(_Complete value)? complete,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (idle != null) {
      return idle(this);
    }
    return orElse();
  }
}

abstract class _Idle implements DictationState {
  const factory _Idle() = _$IdleImpl;
}

/// @nodoc
abstract class _$$ListeningImplCopyWith<$Res> {
  factory _$$ListeningImplCopyWith(
          _$ListeningImpl value, $Res Function(_$ListeningImpl) then) =
      __$$ListeningImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String currentTranscription, Duration elapsedTime});
}

/// @nodoc
class __$$ListeningImplCopyWithImpl<$Res>
    extends _$DictationStateCopyWithImpl<$Res, _$ListeningImpl>
    implements _$$ListeningImplCopyWith<$Res> {
  __$$ListeningImplCopyWithImpl(
      _$ListeningImpl _value, $Res Function(_$ListeningImpl) _then)
      : super(_value, _then);

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? currentTranscription = null,
    Object? elapsedTime = null,
  }) {
    return _then(_$ListeningImpl(
      currentTranscription: null == currentTranscription
          ? _value.currentTranscription
          : currentTranscription // ignore: cast_nullable_to_non_nullable
              as String,
      elapsedTime: null == elapsedTime
          ? _value.elapsedTime
          : elapsedTime // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc

class _$ListeningImpl implements _Listening {
  const _$ListeningImpl(
      {required this.currentTranscription, required this.elapsedTime});

  @override
  final String currentTranscription;
  @override
  final Duration elapsedTime;

  @override
  String toString() {
    return 'DictationState.listening(currentTranscription: $currentTranscription, elapsedTime: $elapsedTime)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ListeningImpl &&
            (identical(other.currentTranscription, currentTranscription) ||
                other.currentTranscription == currentTranscription) &&
            (identical(other.elapsedTime, elapsedTime) ||
                other.elapsedTime == elapsedTime));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, currentTranscription, elapsedTime);

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ListeningImplCopyWith<_$ListeningImpl> get copyWith =>
      __$$ListeningImplCopyWithImpl<_$ListeningImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String currentTranscription, Duration elapsedTime)
        listening,
    required TResult Function(String text) partialResult,
    required TResult Function(String transcription) processing,
    required TResult Function(String finalText, double confidence) complete,
    required TResult Function(Failure failure) error,
  }) {
    return listening(currentTranscription, elapsedTime);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult? Function(String text)? partialResult,
    TResult? Function(String transcription)? processing,
    TResult? Function(String finalText, double confidence)? complete,
    TResult? Function(Failure failure)? error,
  }) {
    return listening?.call(currentTranscription, elapsedTime);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult Function(String text)? partialResult,
    TResult Function(String transcription)? processing,
    TResult Function(String finalText, double confidence)? complete,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (listening != null) {
      return listening(currentTranscription, elapsedTime);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Listening value) listening,
    required TResult Function(_PartialResult value) partialResult,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Complete value) complete,
    required TResult Function(_Error value) error,
  }) {
    return listening(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Listening value)? listening,
    TResult? Function(_PartialResult value)? partialResult,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Complete value)? complete,
    TResult? Function(_Error value)? error,
  }) {
    return listening?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Listening value)? listening,
    TResult Function(_PartialResult value)? partialResult,
    TResult Function(_Processing value)? processing,
    TResult Function(_Complete value)? complete,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (listening != null) {
      return listening(this);
    }
    return orElse();
  }
}

abstract class _Listening implements DictationState {
  const factory _Listening(
      {required final String currentTranscription,
      required final Duration elapsedTime}) = _$ListeningImpl;

  String get currentTranscription;
  Duration get elapsedTime;

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ListeningImplCopyWith<_$ListeningImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PartialResultImplCopyWith<$Res> {
  factory _$$PartialResultImplCopyWith(
          _$PartialResultImpl value, $Res Function(_$PartialResultImpl) then) =
      __$$PartialResultImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String text});
}

/// @nodoc
class __$$PartialResultImplCopyWithImpl<$Res>
    extends _$DictationStateCopyWithImpl<$Res, _$PartialResultImpl>
    implements _$$PartialResultImplCopyWith<$Res> {
  __$$PartialResultImplCopyWithImpl(
      _$PartialResultImpl _value, $Res Function(_$PartialResultImpl) _then)
      : super(_value, _then);

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
  }) {
    return _then(_$PartialResultImpl(
      text: null == text
          ? _value.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$PartialResultImpl implements _PartialResult {
  const _$PartialResultImpl({required this.text});

  @override
  final String text;

  @override
  String toString() {
    return 'DictationState.partialResult(text: $text)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartialResultImpl &&
            (identical(other.text, text) || other.text == text));
  }

  @override
  int get hashCode => Object.hash(runtimeType, text);

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PartialResultImplCopyWith<_$PartialResultImpl> get copyWith =>
      __$$PartialResultImplCopyWithImpl<_$PartialResultImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String currentTranscription, Duration elapsedTime)
        listening,
    required TResult Function(String text) partialResult,
    required TResult Function(String transcription) processing,
    required TResult Function(String finalText, double confidence) complete,
    required TResult Function(Failure failure) error,
  }) {
    return partialResult(text);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult? Function(String text)? partialResult,
    TResult? Function(String transcription)? processing,
    TResult? Function(String finalText, double confidence)? complete,
    TResult? Function(Failure failure)? error,
  }) {
    return partialResult?.call(text);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult Function(String text)? partialResult,
    TResult Function(String transcription)? processing,
    TResult Function(String finalText, double confidence)? complete,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (partialResult != null) {
      return partialResult(text);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Listening value) listening,
    required TResult Function(_PartialResult value) partialResult,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Complete value) complete,
    required TResult Function(_Error value) error,
  }) {
    return partialResult(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Listening value)? listening,
    TResult? Function(_PartialResult value)? partialResult,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Complete value)? complete,
    TResult? Function(_Error value)? error,
  }) {
    return partialResult?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Listening value)? listening,
    TResult Function(_PartialResult value)? partialResult,
    TResult Function(_Processing value)? processing,
    TResult Function(_Complete value)? complete,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (partialResult != null) {
      return partialResult(this);
    }
    return orElse();
  }
}

abstract class _PartialResult implements DictationState {
  const factory _PartialResult({required final String text}) =
      _$PartialResultImpl;

  String get text;

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PartialResultImplCopyWith<_$PartialResultImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ProcessingImplCopyWith<$Res> {
  factory _$$ProcessingImplCopyWith(
          _$ProcessingImpl value, $Res Function(_$ProcessingImpl) then) =
      __$$ProcessingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String transcription});
}

/// @nodoc
class __$$ProcessingImplCopyWithImpl<$Res>
    extends _$DictationStateCopyWithImpl<$Res, _$ProcessingImpl>
    implements _$$ProcessingImplCopyWith<$Res> {
  __$$ProcessingImplCopyWithImpl(
      _$ProcessingImpl _value, $Res Function(_$ProcessingImpl) _then)
      : super(_value, _then);

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transcription = null,
  }) {
    return _then(_$ProcessingImpl(
      transcription: null == transcription
          ? _value.transcription
          : transcription // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$ProcessingImpl implements _Processing {
  const _$ProcessingImpl({required this.transcription});

  @override
  final String transcription;

  @override
  String toString() {
    return 'DictationState.processing(transcription: $transcription)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessingImpl &&
            (identical(other.transcription, transcription) ||
                other.transcription == transcription));
  }

  @override
  int get hashCode => Object.hash(runtimeType, transcription);

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessingImplCopyWith<_$ProcessingImpl> get copyWith =>
      __$$ProcessingImplCopyWithImpl<_$ProcessingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String currentTranscription, Duration elapsedTime)
        listening,
    required TResult Function(String text) partialResult,
    required TResult Function(String transcription) processing,
    required TResult Function(String finalText, double confidence) complete,
    required TResult Function(Failure failure) error,
  }) {
    return processing(transcription);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult? Function(String text)? partialResult,
    TResult? Function(String transcription)? processing,
    TResult? Function(String finalText, double confidence)? complete,
    TResult? Function(Failure failure)? error,
  }) {
    return processing?.call(transcription);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult Function(String text)? partialResult,
    TResult Function(String transcription)? processing,
    TResult Function(String finalText, double confidence)? complete,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(transcription);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Listening value) listening,
    required TResult Function(_PartialResult value) partialResult,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Complete value) complete,
    required TResult Function(_Error value) error,
  }) {
    return processing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Listening value)? listening,
    TResult? Function(_PartialResult value)? partialResult,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Complete value)? complete,
    TResult? Function(_Error value)? error,
  }) {
    return processing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Listening value)? listening,
    TResult Function(_PartialResult value)? partialResult,
    TResult Function(_Processing value)? processing,
    TResult Function(_Complete value)? complete,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(this);
    }
    return orElse();
  }
}

abstract class _Processing implements DictationState {
  const factory _Processing({required final String transcription}) =
      _$ProcessingImpl;

  String get transcription;

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcessingImplCopyWith<_$ProcessingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$CompleteImplCopyWith<$Res> {
  factory _$$CompleteImplCopyWith(
          _$CompleteImpl value, $Res Function(_$CompleteImpl) then) =
      __$$CompleteImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String finalText, double confidence});
}

/// @nodoc
class __$$CompleteImplCopyWithImpl<$Res>
    extends _$DictationStateCopyWithImpl<$Res, _$CompleteImpl>
    implements _$$CompleteImplCopyWith<$Res> {
  __$$CompleteImplCopyWithImpl(
      _$CompleteImpl _value, $Res Function(_$CompleteImpl) _then)
      : super(_value, _then);

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? finalText = null,
    Object? confidence = null,
  }) {
    return _then(_$CompleteImpl(
      finalText: null == finalText
          ? _value.finalText
          : finalText // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$CompleteImpl implements _Complete {
  const _$CompleteImpl({required this.finalText, required this.confidence});

  @override
  final String finalText;
  @override
  final double confidence;

  @override
  String toString() {
    return 'DictationState.complete(finalText: $finalText, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CompleteImpl &&
            (identical(other.finalText, finalText) ||
                other.finalText == finalText) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @override
  int get hashCode => Object.hash(runtimeType, finalText, confidence);

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CompleteImplCopyWith<_$CompleteImpl> get copyWith =>
      __$$CompleteImplCopyWithImpl<_$CompleteImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String currentTranscription, Duration elapsedTime)
        listening,
    required TResult Function(String text) partialResult,
    required TResult Function(String transcription) processing,
    required TResult Function(String finalText, double confidence) complete,
    required TResult Function(Failure failure) error,
  }) {
    return complete(finalText, confidence);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult? Function(String text)? partialResult,
    TResult? Function(String transcription)? processing,
    TResult? Function(String finalText, double confidence)? complete,
    TResult? Function(Failure failure)? error,
  }) {
    return complete?.call(finalText, confidence);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult Function(String text)? partialResult,
    TResult Function(String transcription)? processing,
    TResult Function(String finalText, double confidence)? complete,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (complete != null) {
      return complete(finalText, confidence);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Listening value) listening,
    required TResult Function(_PartialResult value) partialResult,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Complete value) complete,
    required TResult Function(_Error value) error,
  }) {
    return complete(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Listening value)? listening,
    TResult? Function(_PartialResult value)? partialResult,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Complete value)? complete,
    TResult? Function(_Error value)? error,
  }) {
    return complete?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Listening value)? listening,
    TResult Function(_PartialResult value)? partialResult,
    TResult Function(_Processing value)? processing,
    TResult Function(_Complete value)? complete,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (complete != null) {
      return complete(this);
    }
    return orElse();
  }
}

abstract class _Complete implements DictationState {
  const factory _Complete(
      {required final String finalText,
      required final double confidence}) = _$CompleteImpl;

  String get finalText;
  double get confidence;

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CompleteImplCopyWith<_$CompleteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$DictationStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$ErrorImpl(
      failure: null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl({required this.failure});

  @override
  final Failure failure;

  @override
  String toString() {
    return 'DictationState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() idle,
    required TResult Function(String currentTranscription, Duration elapsedTime)
        listening,
    required TResult Function(String text) partialResult,
    required TResult Function(String transcription) processing,
    required TResult Function(String finalText, double confidence) complete,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? idle,
    TResult? Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult? Function(String text)? partialResult,
    TResult? Function(String transcription)? processing,
    TResult? Function(String finalText, double confidence)? complete,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? idle,
    TResult Function(String currentTranscription, Duration elapsedTime)?
        listening,
    TResult Function(String text)? partialResult,
    TResult Function(String transcription)? processing,
    TResult Function(String finalText, double confidence)? complete,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(failure);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Idle value) idle,
    required TResult Function(_Listening value) listening,
    required TResult Function(_PartialResult value) partialResult,
    required TResult Function(_Processing value) processing,
    required TResult Function(_Complete value) complete,
    required TResult Function(_Error value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Idle value)? idle,
    TResult? Function(_Listening value)? listening,
    TResult? Function(_PartialResult value)? partialResult,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_Complete value)? complete,
    TResult? Function(_Error value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Idle value)? idle,
    TResult Function(_Listening value)? listening,
    TResult Function(_PartialResult value)? partialResult,
    TResult Function(_Processing value)? processing,
    TResult Function(_Complete value)? complete,
    TResult Function(_Error value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements DictationState {
  const factory _Error({required final Failure failure}) = _$ErrorImpl;

  Failure get failure;

  /// Create a copy of DictationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
