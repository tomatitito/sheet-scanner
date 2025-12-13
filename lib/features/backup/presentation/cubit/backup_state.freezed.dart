// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'backup_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BackupState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ExportResult result) exportSuccess,
    required TResult Function(ImportResult result) importSuccess,
    required TResult Function(Failure failure) error,
    required TResult Function(int databaseSize, int availableDiskSpace)
        databaseInfo,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ExportResult result)? exportSuccess,
    TResult? Function(ImportResult result)? importSuccess,
    TResult? Function(Failure failure)? error,
    TResult? Function(int databaseSize, int availableDiskSpace)? databaseInfo,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ExportResult result)? exportSuccess,
    TResult Function(ImportResult result)? importSuccess,
    TResult Function(Failure failure)? error,
    TResult Function(int databaseSize, int availableDiskSpace)? databaseInfo,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ExportSuccess value) exportSuccess,
    required TResult Function(_ImportSuccess value) importSuccess,
    required TResult Function(_Error value) error,
    required TResult Function(_DatabaseInfo value) databaseInfo,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ExportSuccess value)? exportSuccess,
    TResult? Function(_ImportSuccess value)? importSuccess,
    TResult? Function(_Error value)? error,
    TResult? Function(_DatabaseInfo value)? databaseInfo,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ExportSuccess value)? exportSuccess,
    TResult Function(_ImportSuccess value)? importSuccess,
    TResult Function(_Error value)? error,
    TResult Function(_DatabaseInfo value)? databaseInfo,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BackupStateCopyWith<$Res> {
  factory $BackupStateCopyWith(
          BackupState value, $Res Function(BackupState) then) =
      _$BackupStateCopyWithImpl<$Res, BackupState>;
}

/// @nodoc
class _$BackupStateCopyWithImpl<$Res, $Val extends BackupState>
    implements $BackupStateCopyWith<$Res> {
  _$BackupStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BackupState
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
    extends _$BackupStateCopyWithImpl<$Res, _$InitialImpl>
    implements _$$InitialImplCopyWith<$Res> {
  __$$InitialImplCopyWithImpl(
      _$InitialImpl _value, $Res Function(_$InitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$InitialImpl implements _Initial {
  const _$InitialImpl();

  @override
  String toString() {
    return 'BackupState.initial()';
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
    required TResult Function() loading,
    required TResult Function(ExportResult result) exportSuccess,
    required TResult Function(ImportResult result) importSuccess,
    required TResult Function(Failure failure) error,
    required TResult Function(int databaseSize, int availableDiskSpace)
        databaseInfo,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ExportResult result)? exportSuccess,
    TResult? Function(ImportResult result)? importSuccess,
    TResult? Function(Failure failure)? error,
    TResult? Function(int databaseSize, int availableDiskSpace)? databaseInfo,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ExportResult result)? exportSuccess,
    TResult Function(ImportResult result)? importSuccess,
    TResult Function(Failure failure)? error,
    TResult Function(int databaseSize, int availableDiskSpace)? databaseInfo,
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
    required TResult Function(_Loading value) loading,
    required TResult Function(_ExportSuccess value) exportSuccess,
    required TResult Function(_ImportSuccess value) importSuccess,
    required TResult Function(_Error value) error,
    required TResult Function(_DatabaseInfo value) databaseInfo,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ExportSuccess value)? exportSuccess,
    TResult? Function(_ImportSuccess value)? importSuccess,
    TResult? Function(_Error value)? error,
    TResult? Function(_DatabaseInfo value)? databaseInfo,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ExportSuccess value)? exportSuccess,
    TResult Function(_ImportSuccess value)? importSuccess,
    TResult Function(_Error value)? error,
    TResult Function(_DatabaseInfo value)? databaseInfo,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class _Initial implements BackupState {
  const factory _Initial() = _$InitialImpl;
}

/// @nodoc
abstract class _$$LoadingImplCopyWith<$Res> {
  factory _$$LoadingImplCopyWith(
          _$LoadingImpl value, $Res Function(_$LoadingImpl) then) =
      __$$LoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$LoadingImplCopyWithImpl<$Res>
    extends _$BackupStateCopyWithImpl<$Res, _$LoadingImpl>
    implements _$$LoadingImplCopyWith<$Res> {
  __$$LoadingImplCopyWithImpl(
      _$LoadingImpl _value, $Res Function(_$LoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$LoadingImpl implements _Loading {
  const _$LoadingImpl();

  @override
  String toString() {
    return 'BackupState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$LoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ExportResult result) exportSuccess,
    required TResult Function(ImportResult result) importSuccess,
    required TResult Function(Failure failure) error,
    required TResult Function(int databaseSize, int availableDiskSpace)
        databaseInfo,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ExportResult result)? exportSuccess,
    TResult? Function(ImportResult result)? importSuccess,
    TResult? Function(Failure failure)? error,
    TResult? Function(int databaseSize, int availableDiskSpace)? databaseInfo,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ExportResult result)? exportSuccess,
    TResult Function(ImportResult result)? importSuccess,
    TResult Function(Failure failure)? error,
    TResult Function(int databaseSize, int availableDiskSpace)? databaseInfo,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ExportSuccess value) exportSuccess,
    required TResult Function(_ImportSuccess value) importSuccess,
    required TResult Function(_Error value) error,
    required TResult Function(_DatabaseInfo value) databaseInfo,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ExportSuccess value)? exportSuccess,
    TResult? Function(_ImportSuccess value)? importSuccess,
    TResult? Function(_Error value)? error,
    TResult? Function(_DatabaseInfo value)? databaseInfo,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ExportSuccess value)? exportSuccess,
    TResult Function(_ImportSuccess value)? importSuccess,
    TResult Function(_Error value)? error,
    TResult Function(_DatabaseInfo value)? databaseInfo,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class _Loading implements BackupState {
  const factory _Loading() = _$LoadingImpl;
}

/// @nodoc
abstract class _$$ExportSuccessImplCopyWith<$Res> {
  factory _$$ExportSuccessImplCopyWith(
          _$ExportSuccessImpl value, $Res Function(_$ExportSuccessImpl) then) =
      __$$ExportSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ExportResult result});

  $ExportResultCopyWith<$Res> get result;
}

/// @nodoc
class __$$ExportSuccessImplCopyWithImpl<$Res>
    extends _$BackupStateCopyWithImpl<$Res, _$ExportSuccessImpl>
    implements _$$ExportSuccessImplCopyWith<$Res> {
  __$$ExportSuccessImplCopyWithImpl(
      _$ExportSuccessImpl _value, $Res Function(_$ExportSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? result = null,
  }) {
    return _then(_$ExportSuccessImpl(
      result: null == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ExportResult,
    ));
  }

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ExportResultCopyWith<$Res> get result {
    return $ExportResultCopyWith<$Res>(_value.result, (value) {
      return _then(_value.copyWith(result: value));
    });
  }
}

/// @nodoc

class _$ExportSuccessImpl implements _ExportSuccess {
  const _$ExportSuccessImpl({required this.result});

  @override
  final ExportResult result;

  @override
  String toString() {
    return 'BackupState.exportSuccess(result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExportSuccessImpl &&
            (identical(other.result, result) || other.result == result));
  }

  @override
  int get hashCode => Object.hash(runtimeType, result);

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExportSuccessImplCopyWith<_$ExportSuccessImpl> get copyWith =>
      __$$ExportSuccessImplCopyWithImpl<_$ExportSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ExportResult result) exportSuccess,
    required TResult Function(ImportResult result) importSuccess,
    required TResult Function(Failure failure) error,
    required TResult Function(int databaseSize, int availableDiskSpace)
        databaseInfo,
  }) {
    return exportSuccess(result);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ExportResult result)? exportSuccess,
    TResult? Function(ImportResult result)? importSuccess,
    TResult? Function(Failure failure)? error,
    TResult? Function(int databaseSize, int availableDiskSpace)? databaseInfo,
  }) {
    return exportSuccess?.call(result);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ExportResult result)? exportSuccess,
    TResult Function(ImportResult result)? importSuccess,
    TResult Function(Failure failure)? error,
    TResult Function(int databaseSize, int availableDiskSpace)? databaseInfo,
    required TResult orElse(),
  }) {
    if (exportSuccess != null) {
      return exportSuccess(result);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ExportSuccess value) exportSuccess,
    required TResult Function(_ImportSuccess value) importSuccess,
    required TResult Function(_Error value) error,
    required TResult Function(_DatabaseInfo value) databaseInfo,
  }) {
    return exportSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ExportSuccess value)? exportSuccess,
    TResult? Function(_ImportSuccess value)? importSuccess,
    TResult? Function(_Error value)? error,
    TResult? Function(_DatabaseInfo value)? databaseInfo,
  }) {
    return exportSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ExportSuccess value)? exportSuccess,
    TResult Function(_ImportSuccess value)? importSuccess,
    TResult Function(_Error value)? error,
    TResult Function(_DatabaseInfo value)? databaseInfo,
    required TResult orElse(),
  }) {
    if (exportSuccess != null) {
      return exportSuccess(this);
    }
    return orElse();
  }
}

abstract class _ExportSuccess implements BackupState {
  const factory _ExportSuccess({required final ExportResult result}) =
      _$ExportSuccessImpl;

  ExportResult get result;

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExportSuccessImplCopyWith<_$ExportSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ImportSuccessImplCopyWith<$Res> {
  factory _$$ImportSuccessImplCopyWith(
          _$ImportSuccessImpl value, $Res Function(_$ImportSuccessImpl) then) =
      __$$ImportSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({ImportResult result});

  $ImportResultCopyWith<$Res> get result;
}

/// @nodoc
class __$$ImportSuccessImplCopyWithImpl<$Res>
    extends _$BackupStateCopyWithImpl<$Res, _$ImportSuccessImpl>
    implements _$$ImportSuccessImplCopyWith<$Res> {
  __$$ImportSuccessImplCopyWithImpl(
      _$ImportSuccessImpl _value, $Res Function(_$ImportSuccessImpl) _then)
      : super(_value, _then);

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? result = null,
  }) {
    return _then(_$ImportSuccessImpl(
      result: null == result
          ? _value.result
          : result // ignore: cast_nullable_to_non_nullable
              as ImportResult,
    ));
  }

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ImportResultCopyWith<$Res> get result {
    return $ImportResultCopyWith<$Res>(_value.result, (value) {
      return _then(_value.copyWith(result: value));
    });
  }
}

/// @nodoc

class _$ImportSuccessImpl implements _ImportSuccess {
  const _$ImportSuccessImpl({required this.result});

  @override
  final ImportResult result;

  @override
  String toString() {
    return 'BackupState.importSuccess(result: $result)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ImportSuccessImpl &&
            (identical(other.result, result) || other.result == result));
  }

  @override
  int get hashCode => Object.hash(runtimeType, result);

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ImportSuccessImplCopyWith<_$ImportSuccessImpl> get copyWith =>
      __$$ImportSuccessImplCopyWithImpl<_$ImportSuccessImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ExportResult result) exportSuccess,
    required TResult Function(ImportResult result) importSuccess,
    required TResult Function(Failure failure) error,
    required TResult Function(int databaseSize, int availableDiskSpace)
        databaseInfo,
  }) {
    return importSuccess(result);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ExportResult result)? exportSuccess,
    TResult? Function(ImportResult result)? importSuccess,
    TResult? Function(Failure failure)? error,
    TResult? Function(int databaseSize, int availableDiskSpace)? databaseInfo,
  }) {
    return importSuccess?.call(result);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ExportResult result)? exportSuccess,
    TResult Function(ImportResult result)? importSuccess,
    TResult Function(Failure failure)? error,
    TResult Function(int databaseSize, int availableDiskSpace)? databaseInfo,
    required TResult orElse(),
  }) {
    if (importSuccess != null) {
      return importSuccess(result);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ExportSuccess value) exportSuccess,
    required TResult Function(_ImportSuccess value) importSuccess,
    required TResult Function(_Error value) error,
    required TResult Function(_DatabaseInfo value) databaseInfo,
  }) {
    return importSuccess(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ExportSuccess value)? exportSuccess,
    TResult? Function(_ImportSuccess value)? importSuccess,
    TResult? Function(_Error value)? error,
    TResult? Function(_DatabaseInfo value)? databaseInfo,
  }) {
    return importSuccess?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ExportSuccess value)? exportSuccess,
    TResult Function(_ImportSuccess value)? importSuccess,
    TResult Function(_Error value)? error,
    TResult Function(_DatabaseInfo value)? databaseInfo,
    required TResult orElse(),
  }) {
    if (importSuccess != null) {
      return importSuccess(this);
    }
    return orElse();
  }
}

abstract class _ImportSuccess implements BackupState {
  const factory _ImportSuccess({required final ImportResult result}) =
      _$ImportSuccessImpl;

  ImportResult get result;

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ImportSuccessImplCopyWith<_$ImportSuccessImpl> get copyWith =>
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
    extends _$BackupStateCopyWithImpl<$Res, _$ErrorImpl>
    implements _$$ErrorImplCopyWith<$Res> {
  __$$ErrorImplCopyWithImpl(
      _$ErrorImpl _value, $Res Function(_$ErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of BackupState
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
    return 'BackupState.error(failure: $failure)';
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

  /// Create a copy of BackupState
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
    required TResult Function() loading,
    required TResult Function(ExportResult result) exportSuccess,
    required TResult Function(ImportResult result) importSuccess,
    required TResult Function(Failure failure) error,
    required TResult Function(int databaseSize, int availableDiskSpace)
        databaseInfo,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ExportResult result)? exportSuccess,
    TResult? Function(ImportResult result)? importSuccess,
    TResult? Function(Failure failure)? error,
    TResult? Function(int databaseSize, int availableDiskSpace)? databaseInfo,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ExportResult result)? exportSuccess,
    TResult Function(ImportResult result)? importSuccess,
    TResult Function(Failure failure)? error,
    TResult Function(int databaseSize, int availableDiskSpace)? databaseInfo,
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
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ExportSuccess value) exportSuccess,
    required TResult Function(_ImportSuccess value) importSuccess,
    required TResult Function(_Error value) error,
    required TResult Function(_DatabaseInfo value) databaseInfo,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ExportSuccess value)? exportSuccess,
    TResult? Function(_ImportSuccess value)? importSuccess,
    TResult? Function(_Error value)? error,
    TResult? Function(_DatabaseInfo value)? databaseInfo,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ExportSuccess value)? exportSuccess,
    TResult Function(_ImportSuccess value)? importSuccess,
    TResult Function(_Error value)? error,
    TResult Function(_DatabaseInfo value)? databaseInfo,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class _Error implements BackupState {
  const factory _Error({required final Failure failure}) = _$ErrorImpl;

  Failure get failure;

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ErrorImplCopyWith<_$ErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$DatabaseInfoImplCopyWith<$Res> {
  factory _$$DatabaseInfoImplCopyWith(
          _$DatabaseInfoImpl value, $Res Function(_$DatabaseInfoImpl) then) =
      __$$DatabaseInfoImplCopyWithImpl<$Res>;
  @useResult
  $Res call({int databaseSize, int availableDiskSpace});
}

/// @nodoc
class __$$DatabaseInfoImplCopyWithImpl<$Res>
    extends _$BackupStateCopyWithImpl<$Res, _$DatabaseInfoImpl>
    implements _$$DatabaseInfoImplCopyWith<$Res> {
  __$$DatabaseInfoImplCopyWithImpl(
      _$DatabaseInfoImpl _value, $Res Function(_$DatabaseInfoImpl) _then)
      : super(_value, _then);

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? databaseSize = null,
    Object? availableDiskSpace = null,
  }) {
    return _then(_$DatabaseInfoImpl(
      databaseSize: null == databaseSize
          ? _value.databaseSize
          : databaseSize // ignore: cast_nullable_to_non_nullable
              as int,
      availableDiskSpace: null == availableDiskSpace
          ? _value.availableDiskSpace
          : availableDiskSpace // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$DatabaseInfoImpl implements _DatabaseInfo {
  const _$DatabaseInfoImpl(
      {required this.databaseSize, required this.availableDiskSpace});

  @override
  final int databaseSize;
  @override
  final int availableDiskSpace;

  @override
  String toString() {
    return 'BackupState.databaseInfo(databaseSize: $databaseSize, availableDiskSpace: $availableDiskSpace)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DatabaseInfoImpl &&
            (identical(other.databaseSize, databaseSize) ||
                other.databaseSize == databaseSize) &&
            (identical(other.availableDiskSpace, availableDiskSpace) ||
                other.availableDiskSpace == availableDiskSpace));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, databaseSize, availableDiskSpace);

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DatabaseInfoImplCopyWith<_$DatabaseInfoImpl> get copyWith =>
      __$$DatabaseInfoImplCopyWithImpl<_$DatabaseInfoImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(ExportResult result) exportSuccess,
    required TResult Function(ImportResult result) importSuccess,
    required TResult Function(Failure failure) error,
    required TResult Function(int databaseSize, int availableDiskSpace)
        databaseInfo,
  }) {
    return databaseInfo(databaseSize, availableDiskSpace);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(ExportResult result)? exportSuccess,
    TResult? Function(ImportResult result)? importSuccess,
    TResult? Function(Failure failure)? error,
    TResult? Function(int databaseSize, int availableDiskSpace)? databaseInfo,
  }) {
    return databaseInfo?.call(databaseSize, availableDiskSpace);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(ExportResult result)? exportSuccess,
    TResult Function(ImportResult result)? importSuccess,
    TResult Function(Failure failure)? error,
    TResult Function(int databaseSize, int availableDiskSpace)? databaseInfo,
    required TResult orElse(),
  }) {
    if (databaseInfo != null) {
      return databaseInfo(databaseSize, availableDiskSpace);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Initial value) initial,
    required TResult Function(_Loading value) loading,
    required TResult Function(_ExportSuccess value) exportSuccess,
    required TResult Function(_ImportSuccess value) importSuccess,
    required TResult Function(_Error value) error,
    required TResult Function(_DatabaseInfo value) databaseInfo,
  }) {
    return databaseInfo(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Initial value)? initial,
    TResult? Function(_Loading value)? loading,
    TResult? Function(_ExportSuccess value)? exportSuccess,
    TResult? Function(_ImportSuccess value)? importSuccess,
    TResult? Function(_Error value)? error,
    TResult? Function(_DatabaseInfo value)? databaseInfo,
  }) {
    return databaseInfo?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Initial value)? initial,
    TResult Function(_Loading value)? loading,
    TResult Function(_ExportSuccess value)? exportSuccess,
    TResult Function(_ImportSuccess value)? importSuccess,
    TResult Function(_Error value)? error,
    TResult Function(_DatabaseInfo value)? databaseInfo,
    required TResult orElse(),
  }) {
    if (databaseInfo != null) {
      return databaseInfo(this);
    }
    return orElse();
  }
}

abstract class _DatabaseInfo implements BackupState {
  const factory _DatabaseInfo(
      {required final int databaseSize,
      required final int availableDiskSpace}) = _$DatabaseInfoImpl;

  int get databaseSize;
  int get availableDiskSpace;

  /// Create a copy of BackupState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DatabaseInfoImplCopyWith<_$DatabaseInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
