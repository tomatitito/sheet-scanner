// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ocr_scan_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$OCRScanState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() cameraReady,
    required TResult Function() capturing,
    required TResult Function(
            String imagePath, double progress, String? currentOperation)
        processing,
    required TResult Function(
            String imagePath, String extractedText, double confidence)
        ocrComplete,
    required TResult Function(Failure failure, String? imagePath) error,
    required TResult Function() permissionDenied,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? cameraReady,
    TResult? Function()? capturing,
    TResult? Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult? Function(
            String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult? Function(Failure failure, String? imagePath)? error,
    TResult? Function()? permissionDenied,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? cameraReady,
    TResult Function()? capturing,
    TResult Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult Function(String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult Function(Failure failure, String? imagePath)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_CameraReady value) cameraReady,
    required TResult Function(_Capturing value) capturing,
    required TResult Function(_Processing value) processing,
    required TResult Function(_OCRComplete value) ocrComplete,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_CameraReady value)? cameraReady,
    TResult? Function(_Capturing value)? capturing,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_OCRComplete value)? ocrComplete,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_CameraReady value)? cameraReady,
    TResult Function(_Capturing value)? capturing,
    TResult Function(_Processing value)? processing,
    TResult Function(_OCRComplete value)? ocrComplete,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OCRScanStateCopyWith<$Res> {
  factory $OCRScanStateCopyWith(
          OCRScanState value, $Res Function(OCRScanState) then) =
      _$OCRScanStateCopyWithImpl<$Res, OCRScanState>;
}

/// @nodoc
class _$OCRScanStateCopyWithImpl<$Res, $Val extends OCRScanState>
    implements $OCRScanStateCopyWith<$Res> {
  _$OCRScanStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$InitialImplCopyWith<$Res> {
  factory _$$InitialImplCopyWith(
          _$InitialImpl value, $Res Function(_$InitialImpl) then) =
      __$$InitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialImplCopyWithImpl<$Res>
    extends _$OCRScanStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'OCRScanState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$InitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() cameraReady,
    required TResult Function() capturing,
    required TResult Function(
            String imagePath, double progress, String? currentOperation)
        processing,
    required TResult Function(
            String imagePath, String extractedText, double confidence)
        ocrComplete,
    required TResult Function(Failure failure, String? imagePath) error,
    required TResult Function() permissionDenied,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? cameraReady,
    TResult? Function()? capturing,
    TResult? Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult? Function(
            String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult? Function(Failure failure, String? imagePath)? error,
    TResult? Function()? permissionDenied,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? cameraReady,
    TResult Function()? capturing,
    TResult Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult Function(String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult Function(Failure failure, String? imagePath)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_CameraReady value) cameraReady,
    required TResult Function(_Capturing value) capturing,
    required TResult Function(_Processing value) processing,
    required TResult Function(_OCRComplete value) ocrComplete,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_CameraReady value)? cameraReady,
    TResult? Function(_Capturing value)? capturing,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_OCRComplete value)? ocrComplete,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_CameraReady value)? cameraReady,
    TResult Function(_Capturing value)? capturing,
    TResult Function(_Processing value)? processing,
    TResult Function(_OCRComplete value)? ocrComplete,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements OCRScanState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$CameraReadyImplCopyWith<$Res> {
  factory _$$CameraReadyImplCopyWith(
          _$CameraReadyImpl value, $Res Function(_$CameraReadyImpl) then) =
      __$$CameraReadyImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CameraReadyImplCopyWithImpl<$Res>
    extends _$OCRScanStateCopyWithImpl<$Res, _$CameraReadyImpl>
    implements _$$CameraReadyImplCopyWith<$Res> {
  __$$CameraReadyImplCopyWithImpl(
      _$CameraReadyImpl _value, $Res Function(_$CameraReadyImpl) _then)
      : super(_value, _then);

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CameraReadyImpl implements _CameraReady {
  const _$CameraReadyImpl();

  @override
  String toString() {
    return 'OCRScanState.cameraReady()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CameraReadyImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() cameraReady,
    required TResult Function() capturing,
    required TResult Function(
            String imagePath, double progress, String? currentOperation)
        processing,
    required TResult Function(
            String imagePath, String extractedText, double confidence)
        ocrComplete,
    required TResult Function(Failure failure, String? imagePath) error,
    required TResult Function() permissionDenied,
  }) {
    return cameraReady();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? cameraReady,
    TResult? Function()? capturing,
    TResult? Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult? Function(
            String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult? Function(Failure failure, String? imagePath)? error,
    TResult? Function()? permissionDenied,
  }) {
    return cameraReady?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? cameraReady,
    TResult Function()? capturing,
    TResult Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult Function(String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult Function(Failure failure, String? imagePath)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) {
    if (cameraReady != null) {
      return cameraReady();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_CameraReady value) cameraReady,
    required TResult Function(_Capturing value) capturing,
    required TResult Function(_Processing value) processing,
    required TResult Function(_OCRComplete value) ocrComplete,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) {
    return cameraReady(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_CameraReady value)? cameraReady,
    TResult? Function(_Capturing value)? capturing,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_OCRComplete value)? ocrComplete,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) {
    return cameraReady?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_CameraReady value)? cameraReady,
    TResult Function(_Capturing value)? capturing,
    TResult Function(_Processing value)? processing,
    TResult Function(_OCRComplete value)? ocrComplete,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) {
    if (cameraReady != null) {
      return cameraReady(this);
    }
    return orElse();
  }
}

abstract class _CameraReady implements OCRScanState {
  const factory _CameraReady() = _$CameraReadyImpl;
}

/// @nodoc
abstract class _$$CapturingImplCopyWith<$Res> {
  factory _$$CapturingImplCopyWith(
          _$CapturingImpl value, $Res Function(_$CapturingImpl) then) =
      __$$CapturingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$CapturingImplCopyWithImpl<$Res>
    extends _$OCRScanStateCopyWithImpl<$Res, _$CapturingImpl>
    implements _$$CapturingImplCopyWith<$Res> {
  __$$CapturingImplCopyWithImpl(
      _$CapturingImpl _value, $Res Function(_$CapturingImpl) _then)
      : super(_value, _then);

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$CapturingImpl implements _Capturing {
  const _$CapturingImpl();

  @override
  String toString() {
    return 'OCRScanState.capturing()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$CapturingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() cameraReady,
    required TResult Function() capturing,
    required TResult Function(
            String imagePath, double progress, String? currentOperation)
        processing,
    required TResult Function(
            String imagePath, String extractedText, double confidence)
        ocrComplete,
    required TResult Function(Failure failure, String? imagePath) error,
    required TResult Function() permissionDenied,
  }) {
    return capturing();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? cameraReady,
    TResult? Function()? capturing,
    TResult? Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult? Function(
            String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult? Function(Failure failure, String? imagePath)? error,
    TResult? Function()? permissionDenied,
  }) {
    return capturing?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? cameraReady,
    TResult Function()? capturing,
    TResult Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult Function(String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult Function(Failure failure, String? imagePath)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) {
    if (capturing != null) {
      return capturing();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_CameraReady value) cameraReady,
    required TResult Function(_Capturing value) capturing,
    required TResult Function(_Processing value) processing,
    required TResult Function(_OCRComplete value) ocrComplete,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) {
    return capturing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_CameraReady value)? cameraReady,
    TResult? Function(_Capturing value)? capturing,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_OCRComplete value)? ocrComplete,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) {
    return capturing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_CameraReady value)? cameraReady,
    TResult Function(_Capturing value)? capturing,
    TResult Function(_Processing value)? processing,
    TResult Function(_OCRComplete value)? ocrComplete,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) {
    if (capturing != null) {
      return capturing(this);
    }
    return orElse();
  }
}

abstract class _Capturing implements OCRScanState {
  const factory _Capturing() = _$CapturingImpl;
}

/// @nodoc
abstract class _$$ProcessingImplCopyWith<$Res> {
  factory _$$ProcessingImplCopyWith(
          _$ProcessingImpl value, $Res Function(_$ProcessingImpl) then) =
      __$$ProcessingImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String imagePath, double progress, String? currentOperation});
}

/// @nodoc
class __$$ProcessingImplCopyWithImpl<$Res>
    extends _$OCRScanStateCopyWithImpl<$Res, _$ProcessingImpl>
    implements _$$ProcessingImplCopyWith<$Res> {
  __$$ProcessingImplCopyWithImpl(
      _$ProcessingImpl _value, $Res Function(_$ProcessingImpl) _then)
      : super(_value, _then);

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imagePath = null,
    Object? progress = null,
    Object? currentOperation = freezed,
  }) {
    return _then(_$ProcessingImpl(
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      progress: null == progress
          ? _value.progress
          : progress // ignore: cast_nullable_to_non_nullable
              as double,
      currentOperation: freezed == currentOperation
          ? _value.currentOperation
          : currentOperation // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ProcessingImpl implements _Processing {
  const _$ProcessingImpl(
      {required this.imagePath, required this.progress, this.currentOperation});

  @override
  final String imagePath;
  @override
  final double progress;
  @override
  final String? currentOperation;

  @override
  String toString() {
    return 'OCRScanState.processing(imagePath: $imagePath, progress: $progress, currentOperation: $currentOperation)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProcessingImpl &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.currentOperation, currentOperation) ||
                other.currentOperation == currentOperation));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, imagePath, progress, currentOperation);

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProcessingImplCopyWith<_$ProcessingImpl> get copyWith =>
      __$$ProcessingImplCopyWithImpl<_$ProcessingImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() cameraReady,
    required TResult Function() capturing,
    required TResult Function(
            String imagePath, double progress, String? currentOperation)
        processing,
    required TResult Function(
            String imagePath, String extractedText, double confidence)
        ocrComplete,
    required TResult Function(Failure failure, String? imagePath) error,
    required TResult Function() permissionDenied,
  }) {
    return processing(imagePath, progress, currentOperation);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? cameraReady,
    TResult? Function()? capturing,
    TResult? Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult? Function(
            String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult? Function(Failure failure, String? imagePath)? error,
    TResult? Function()? permissionDenied,
  }) {
    return processing?.call(imagePath, progress, currentOperation);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? cameraReady,
    TResult Function()? capturing,
    TResult Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult Function(String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult Function(Failure failure, String? imagePath)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(imagePath, progress, currentOperation);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_CameraReady value) cameraReady,
    required TResult Function(_Capturing value) capturing,
    required TResult Function(_Processing value) processing,
    required TResult Function(_OCRComplete value) ocrComplete,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) {
    return processing(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_CameraReady value)? cameraReady,
    TResult? Function(_Capturing value)? capturing,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_OCRComplete value)? ocrComplete,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) {
    return processing?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_CameraReady value)? cameraReady,
    TResult Function(_Capturing value)? capturing,
    TResult Function(_Processing value)? processing,
    TResult Function(_OCRComplete value)? ocrComplete,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) {
    if (processing != null) {
      return processing(this);
    }
    return orElse();
  }
}

abstract class _Processing implements OCRScanState {
  const factory _Processing(
      {required final String imagePath,
      required final double progress,
      final String? currentOperation}) = _$ProcessingImpl;

  String get imagePath;
  double get progress;
  String? get currentOperation;

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProcessingImplCopyWith<_$ProcessingImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$OCRCompleteImplCopyWith<$Res> {
  factory _$$OCRCompleteImplCopyWith(
          _$OCRCompleteImpl value, $Res Function(_$OCRCompleteImpl) then) =
      __$$OCRCompleteImplCopyWithImpl<$Res>;
  @useResult
  $Res call({String imagePath, String extractedText, double confidence});
}

/// @nodoc
class __$$OCRCompleteImplCopyWithImpl<$Res>
    extends _$OCRScanStateCopyWithImpl<$Res, _$OCRCompleteImpl>
    implements _$$OCRCompleteImplCopyWith<$Res> {
  __$$OCRCompleteImplCopyWithImpl(
      _$OCRCompleteImpl _value, $Res Function(_$OCRCompleteImpl) _then)
      : super(_value, _then);

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? imagePath = null,
    Object? extractedText = null,
    Object? confidence = null,
  }) {
    return _then(_$OCRCompleteImpl(
      imagePath: null == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String,
      extractedText: null == extractedText
          ? _value.extractedText
          : extractedText // ignore: cast_nullable_to_non_nullable
              as String,
      confidence: null == confidence
          ? _value.confidence
          : confidence // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$OCRCompleteImpl implements _OCRComplete {
  const _$OCRCompleteImpl(
      {required this.imagePath,
      required this.extractedText,
      required this.confidence});

  @override
  final String imagePath;
  @override
  final String extractedText;
  @override
  final double confidence;

  @override
  String toString() {
    return 'OCRScanState.ocrComplete(imagePath: $imagePath, extractedText: $extractedText, confidence: $confidence)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OCRCompleteImpl &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath) &&
            (identical(other.extractedText, extractedText) ||
                other.extractedText == extractedText) &&
            (identical(other.confidence, confidence) ||
                other.confidence == confidence));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, imagePath, extractedText, confidence);

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$OCRCompleteImplCopyWith<_$OCRCompleteImpl> get copyWith =>
      __$$OCRCompleteImplCopyWithImpl<_$OCRCompleteImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() cameraReady,
    required TResult Function() capturing,
    required TResult Function(
            String imagePath, double progress, String? currentOperation)
        processing,
    required TResult Function(
            String imagePath, String extractedText, double confidence)
        ocrComplete,
    required TResult Function(Failure failure, String? imagePath) error,
    required TResult Function() permissionDenied,
  }) {
    return ocrComplete(imagePath, extractedText, confidence);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? cameraReady,
    TResult? Function()? capturing,
    TResult? Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult? Function(
            String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult? Function(Failure failure, String? imagePath)? error,
    TResult? Function()? permissionDenied,
  }) {
    return ocrComplete?.call(imagePath, extractedText, confidence);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? cameraReady,
    TResult Function()? capturing,
    TResult Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult Function(String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult Function(Failure failure, String? imagePath)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) {
    if (ocrComplete != null) {
      return ocrComplete(imagePath, extractedText, confidence);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_CameraReady value) cameraReady,
    required TResult Function(_Capturing value) capturing,
    required TResult Function(_Processing value) processing,
    required TResult Function(_OCRComplete value) ocrComplete,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) {
    return ocrComplete(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_CameraReady value)? cameraReady,
    TResult? Function(_Capturing value)? capturing,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_OCRComplete value)? ocrComplete,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) {
    return ocrComplete?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_CameraReady value)? cameraReady,
    TResult Function(_Capturing value)? capturing,
    TResult Function(_Processing value)? processing,
    TResult Function(_OCRComplete value)? ocrComplete,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) {
    if (ocrComplete != null) {
      return ocrComplete(this);
    }
    return orElse();
  }
}

abstract class _OCRComplete implements OCRScanState {
  const factory _OCRComplete(
      {required final String imagePath,
      required final String extractedText,
      required final double confidence}) = _$OCRCompleteImpl;

  String get imagePath;
  String get extractedText;
  double get confidence;

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$OCRCompleteImplCopyWith<_$OCRCompleteImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ErrorImplCopyWith<$Res> {
  factory _$$ErrorImplCopyWith(
          _$ErrorImpl value, $Res Function(_$ErrorImpl) then) =
      __$$ErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure, String? imagePath});
}

/// @nodoc
class __$$ErrorImplCopyWithImpl<$Res>
    extends _$OCRScanStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
    Object? imagePath = freezed,
  }) {
    return _then(_$ErrorImpl(
      failure: null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
      imagePath: freezed == imagePath
          ? _value.imagePath
          : imagePath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$ErrorImpl implements _Error {
  const _$ErrorImpl({required this.failure, this.imagePath});

  @override
  final Failure failure;
  @override
  final String? imagePath;

  @override
  String toString() {
    return 'OCRScanState.error(failure: $failure, imagePath: $imagePath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure) &&
            (identical(other.imagePath, imagePath) ||
                other.imagePath == imagePath));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure, imagePath);

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      __$$ErrorImplCopyWithImpl<_$ErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() cameraReady,
    required TResult Function() capturing,
    required TResult Function(
            String imagePath, double progress, String? currentOperation)
        processing,
    required TResult Function(
            String imagePath, String extractedText, double confidence)
        ocrComplete,
    required TResult Function(Failure failure, String? imagePath) error,
    required TResult Function() permissionDenied,
  }) {
    return error(failure, imagePath);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? cameraReady,
    TResult? Function()? capturing,
    TResult? Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult? Function(
            String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult? Function(Failure failure, String? imagePath)? error,
    TResult? Function()? permissionDenied,
  }) {
    return error?.call(failure, imagePath);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? cameraReady,
    TResult Function()? capturing,
    TResult Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult Function(String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult Function(Failure failure, String? imagePath)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(failure, imagePath);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_CameraReady value) cameraReady,
    required TResult Function(_Capturing value) capturing,
    required TResult Function(_Processing value) processing,
    required TResult Function(_OCRComplete value) ocrComplete,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_CameraReady value)? cameraReady,
    TResult? Function(_Capturing value)? capturing,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_OCRComplete value)? ocrComplete,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_CameraReady value)? cameraReady,
    TResult Function(_Capturing value)? capturing,
    TResult Function(_Processing value)? processing,
    TResult Function(_OCRComplete value)? ocrComplete,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements OCRScanState {
  const factory _Error(
      {required final Failure failure, final String? imagePath}) = _$ErrorImpl;

  Failure get failure;
  String? get imagePath;

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$PermissionDeniedImplCopyWith<$Res> {
  factory _$$PermissionDeniedImplCopyWith(_$PermissionDeniedImpl value,
          $Res Function(_$PermissionDeniedImpl) then) =
      __$$PermissionDeniedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$PermissionDeniedImplCopyWithImpl<$Res>
    extends _$OCRScanStateCopyWithImpl<$Res, _$PermissionDeniedImpl>
    implements _$$PermissionDeniedImplCopyWith<$Res> {
  __$$PermissionDeniedImplCopyWithImpl(_$PermissionDeniedImpl _value,
      $Res Function(_$PermissionDeniedImpl) _then)
      : super(_value, _then);

  /// Create a copy of OCRScanState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$PermissionDeniedImpl implements _PermissionDenied {
  const _$PermissionDeniedImpl();

  @override
  String toString() {
    return 'OCRScanState.permissionDenied()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$PermissionDeniedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() cameraReady,
    required TResult Function() capturing,
    required TResult Function(
            String imagePath, double progress, String? currentOperation)
        processing,
    required TResult Function(
            String imagePath, String extractedText, double confidence)
        ocrComplete,
    required TResult Function(Failure failure, String? imagePath) error,
    required TResult Function() permissionDenied,
  }) {
    return permissionDenied();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? cameraReady,
    TResult? Function()? capturing,
    TResult? Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult? Function(
            String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult? Function(Failure failure, String? imagePath)? error,
    TResult? Function()? permissionDenied,
  }) {
    return permissionDenied?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? cameraReady,
    TResult Function()? capturing,
    TResult Function(
            String imagePath, double progress, String? currentOperation)?
        processing,
    TResult Function(String imagePath, String extractedText, double confidence)?
        ocrComplete,
    TResult Function(Failure failure, String? imagePath)? error,
    TResult Function()? permissionDenied,
    required TResult orElse(),
  }) {
    if (permissionDenied != null) {
      return permissionDenied();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_CameraReady value) cameraReady,
    required TResult Function(_Capturing value) capturing,
    required TResult Function(_Processing value) processing,
    required TResult Function(_OCRComplete value) ocrComplete,
    required TResult Function(_Error value) error,
    required TResult Function(_PermissionDenied value) permissionDenied,
  }) {
    return permissionDenied(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_CameraReady value)? cameraReady,
    TResult? Function(_Capturing value)? capturing,
    TResult? Function(_Processing value)? processing,
    TResult? Function(_OCRComplete value)? ocrComplete,
    TResult? Function(_Error value)? error,
    TResult? Function(_PermissionDenied value)? permissionDenied,
  }) {
    return permissionDenied?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_CameraReady value)? cameraReady,
    TResult Function(_Capturing value)? capturing,
    TResult Function(_Processing value)? processing,
    TResult Function(_OCRComplete value)? ocrComplete,
    TResult Function(_Error value)? error,
    TResult Function(_PermissionDenied value)? permissionDenied,
    required TResult orElse(),
  }) {
    if (permissionDenied != null) {
      return permissionDenied(this);
    }
    return orElse();
  }
}

abstract class _PermissionDenied implements OCRScanState {
  const factory _PermissionDenied() = _$PermissionDeniedImpl;
}
