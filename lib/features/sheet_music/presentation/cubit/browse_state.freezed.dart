// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'browse_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BrowseState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)
        loaded,
    required TResult Function(Failure failure) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)?
        loaded,
    TResult? Function(Failure failure)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)?
        loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BrowseInitial value) initial,
    required TResult Function(BrowseLoading value) loading,
    required TResult Function(BrowseLoaded value) loaded,
    required TResult Function(BrowseError value) error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BrowseInitial value)? initial,
    TResult? Function(BrowseLoading value)? loading,
    TResult? Function(BrowseLoaded value)? loaded,
    TResult? Function(BrowseError value)? error,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BrowseInitial value)? initial,
    TResult Function(BrowseLoading value)? loading,
    TResult Function(BrowseLoaded value)? loaded,
    TResult Function(BrowseError value)? error,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BrowseStateCopyWith<$Res> {
  factory $BrowseStateCopyWith(
          BrowseState value, $Res Function(BrowseState) then) =
      _$BrowseStateCopyWithImpl<$Res, BrowseState>;
}

/// @nodoc
class _$BrowseStateCopyWithImpl<$Res, $Val extends BrowseState>
    implements $BrowseStateCopyWith<$Res> {
  _$BrowseStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BrowseState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc
abstract class _$$BrowseInitialImplCopyWith<$Res> {
  factory _$$BrowseInitialImplCopyWith(
          _$BrowseInitialImpl value, $Res Function(_$BrowseInitialImpl) then) =
      __$$BrowseInitialImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BrowseInitialImplCopyWithImpl<$Res>
    extends _$BrowseStateCopyWithImpl<$Res, _$BrowseInitialImpl>
    implements _$$BrowseInitialImplCopyWith<$Res> {
  __$$BrowseInitialImplCopyWithImpl(
      _$BrowseInitialImpl _value, $Res Function(_$BrowseInitialImpl) _then)
      : super(_value, _then);

  /// Create a copy of BrowseState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$BrowseInitialImpl implements BrowseInitial {
  const _$BrowseInitialImpl();

  @override
  String toString() {
    return 'BrowseState.initial()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$BrowseInitialImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)
        loaded,
    required TResult Function(Failure failure) error,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)?
        loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)?
        loaded,
    TResult Function(Failure failure)? error,
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
    required TResult Function(BrowseInitial value) initial,
    required TResult Function(BrowseLoading value) loading,
    required TResult Function(BrowseLoaded value) loaded,
    required TResult Function(BrowseError value) error,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BrowseInitial value)? initial,
    TResult? Function(BrowseLoading value)? loading,
    TResult? Function(BrowseLoaded value)? loaded,
    TResult? Function(BrowseError value)? error,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BrowseInitial value)? initial,
    TResult Function(BrowseLoading value)? loading,
    TResult Function(BrowseLoaded value)? loaded,
    TResult Function(BrowseError value)? error,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class BrowseInitial implements BrowseState {
  const factory BrowseInitial() = _$BrowseInitialImpl;
}

/// @nodoc
abstract class _$$BrowseLoadingImplCopyWith<$Res> {
  factory _$$BrowseLoadingImplCopyWith(
          _$BrowseLoadingImpl value, $Res Function(_$BrowseLoadingImpl) then) =
      __$$BrowseLoadingImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BrowseLoadingImplCopyWithImpl<$Res>
    extends _$BrowseStateCopyWithImpl<$Res, _$BrowseLoadingImpl>
    implements _$$BrowseLoadingImplCopyWith<$Res> {
  __$$BrowseLoadingImplCopyWithImpl(
      _$BrowseLoadingImpl _value, $Res Function(_$BrowseLoadingImpl) _then)
      : super(_value, _then);

  /// Create a copy of BrowseState
  /// with the given fields replaced by the non-null parameter values.
}

/// @nodoc

class _$BrowseLoadingImpl implements BrowseLoading {
  const _$BrowseLoadingImpl();

  @override
  String toString() {
    return 'BrowseState.loading()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$BrowseLoadingImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)
        loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loading();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)?
        loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loading?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)?
        loaded,
    TResult Function(Failure failure)? error,
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
    required TResult Function(BrowseInitial value) initial,
    required TResult Function(BrowseLoading value) loading,
    required TResult Function(BrowseLoaded value) loaded,
    required TResult Function(BrowseError value) error,
  }) {
    return loading(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BrowseInitial value)? initial,
    TResult? Function(BrowseLoading value)? loading,
    TResult? Function(BrowseLoaded value)? loaded,
    TResult? Function(BrowseError value)? error,
  }) {
    return loading?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BrowseInitial value)? initial,
    TResult Function(BrowseLoading value)? loading,
    TResult Function(BrowseLoaded value)? loaded,
    TResult Function(BrowseError value)? error,
    required TResult orElse(),
  }) {
    if (loading != null) {
      return loading(this);
    }
    return orElse();
  }
}

abstract class BrowseLoading implements BrowseState {
  const factory BrowseLoading() = _$BrowseLoadingImpl;
}

/// @nodoc
abstract class _$$BrowseLoadedImplCopyWith<$Res> {
  factory _$$BrowseLoadedImplCopyWith(
          _$BrowseLoadedImpl value, $Res Function(_$BrowseLoadedImpl) then) =
      __$$BrowseLoadedImplCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {List<SheetMusic> sheets,
      List<SheetMusic> filteredSheets,
      String searchQuery,
      List<String> selectedTags,
      String sortBy,
      bool isRefreshing});
}

/// @nodoc
class __$$BrowseLoadedImplCopyWithImpl<$Res>
    extends _$BrowseStateCopyWithImpl<$Res, _$BrowseLoadedImpl>
    implements _$$BrowseLoadedImplCopyWith<$Res> {
  __$$BrowseLoadedImplCopyWithImpl(
      _$BrowseLoadedImpl _value, $Res Function(_$BrowseLoadedImpl) _then)
      : super(_value, _then);

  /// Create a copy of BrowseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sheets = null,
    Object? filteredSheets = null,
    Object? searchQuery = null,
    Object? selectedTags = null,
    Object? sortBy = null,
    Object? isRefreshing = null,
  }) {
    return _then(_$BrowseLoadedImpl(
      sheets: null == sheets
          ? _value._sheets
          : sheets // ignore: cast_nullable_to_non_nullable
              as List<SheetMusic>,
      filteredSheets: null == filteredSheets
          ? _value._filteredSheets
          : filteredSheets // ignore: cast_nullable_to_non_nullable
              as List<SheetMusic>,
      searchQuery: null == searchQuery
          ? _value.searchQuery
          : searchQuery // ignore: cast_nullable_to_non_nullable
              as String,
      selectedTags: null == selectedTags
          ? _value._selectedTags
          : selectedTags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String,
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$BrowseLoadedImpl implements BrowseLoaded {
  const _$BrowseLoadedImpl(
      {required final List<SheetMusic> sheets,
      required final List<SheetMusic> filteredSheets,
      required this.searchQuery,
      required final List<String> selectedTags,
      required this.sortBy,
      this.isRefreshing = false})
      : _sheets = sheets,
        _filteredSheets = filteredSheets,
        _selectedTags = selectedTags;

  final List<SheetMusic> _sheets;
  @override
  List<SheetMusic> get sheets {
    if (_sheets is EqualUnmodifiableListView) return _sheets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_sheets);
  }

  final List<SheetMusic> _filteredSheets;
  @override
  List<SheetMusic> get filteredSheets {
    if (_filteredSheets is EqualUnmodifiableListView) return _filteredSheets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_filteredSheets);
  }

  @override
  final String searchQuery;
  final List<String> _selectedTags;
  @override
  List<String> get selectedTags {
    if (_selectedTags is EqualUnmodifiableListView) return _selectedTags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedTags);
  }

  @override
  final String sortBy;
  @override
  @JsonKey()
  final bool isRefreshing;

  @override
  String toString() {
    return 'BrowseState.loaded(sheets: $sheets, filteredSheets: $filteredSheets, searchQuery: $searchQuery, selectedTags: $selectedTags, sortBy: $sortBy, isRefreshing: $isRefreshing)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BrowseLoadedImpl &&
            const DeepCollectionEquality().equals(other._sheets, _sheets) &&
            const DeepCollectionEquality()
                .equals(other._filteredSheets, _filteredSheets) &&
            (identical(other.searchQuery, searchQuery) ||
                other.searchQuery == searchQuery) &&
            const DeepCollectionEquality()
                .equals(other._selectedTags, _selectedTags) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_sheets),
      const DeepCollectionEquality().hash(_filteredSheets),
      searchQuery,
      const DeepCollectionEquality().hash(_selectedTags),
      sortBy,
      isRefreshing);

  /// Create a copy of BrowseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BrowseLoadedImplCopyWith<_$BrowseLoadedImpl> get copyWith =>
      __$$BrowseLoadedImplCopyWithImpl<_$BrowseLoadedImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)
        loaded,
    required TResult Function(Failure failure) error,
  }) {
    return loaded(sheets, filteredSheets, searchQuery, selectedTags, sortBy,
        isRefreshing);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)?
        loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return loaded?.call(sheets, filteredSheets, searchQuery, selectedTags,
        sortBy, isRefreshing);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)?
        loaded,
    TResult Function(Failure failure)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(sheets, filteredSheets, searchQuery, selectedTags, sortBy,
          isRefreshing);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(BrowseInitial value) initial,
    required TResult Function(BrowseLoading value) loading,
    required TResult Function(BrowseLoaded value) loaded,
    required TResult Function(BrowseError value) error,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BrowseInitial value)? initial,
    TResult? Function(BrowseLoading value)? loading,
    TResult? Function(BrowseLoaded value)? loaded,
    TResult? Function(BrowseError value)? error,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BrowseInitial value)? initial,
    TResult Function(BrowseLoading value)? loading,
    TResult Function(BrowseLoaded value)? loaded,
    TResult Function(BrowseError value)? error,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class BrowseLoaded implements BrowseState {
  const factory BrowseLoaded(
      {required final List<SheetMusic> sheets,
      required final List<SheetMusic> filteredSheets,
      required final String searchQuery,
      required final List<String> selectedTags,
      required final String sortBy,
      final bool isRefreshing}) = _$BrowseLoadedImpl;

  List<SheetMusic> get sheets;
  List<SheetMusic> get filteredSheets;
  String get searchQuery;
  List<String> get selectedTags;
  String get sortBy;
  bool get isRefreshing;

  /// Create a copy of BrowseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BrowseLoadedImplCopyWith<_$BrowseLoadedImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BrowseErrorImplCopyWith<$Res> {
  factory _$$BrowseErrorImplCopyWith(
          _$BrowseErrorImpl value, $Res Function(_$BrowseErrorImpl) then) =
      __$$BrowseErrorImplCopyWithImpl<$Res>;
  @useResult
  $Res call({Failure failure});
}

/// @nodoc
class __$$BrowseErrorImplCopyWithImpl<$Res>
    extends _$BrowseStateCopyWithImpl<$Res, _$BrowseErrorImpl>
    implements _$$BrowseErrorImplCopyWith<$Res> {
  __$$BrowseErrorImplCopyWithImpl(
      _$BrowseErrorImpl _value, $Res Function(_$BrowseErrorImpl) _then)
      : super(_value, _then);

  /// Create a copy of BrowseState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? failure = null,
  }) {
    return _then(_$BrowseErrorImpl(
      null == failure
          ? _value.failure
          : failure // ignore: cast_nullable_to_non_nullable
              as Failure,
    ));
  }
}

/// @nodoc

class _$BrowseErrorImpl implements BrowseError {
  const _$BrowseErrorImpl(this.failure);

  @override
  final Failure failure;

  @override
  String toString() {
    return 'BrowseState.error(failure: $failure)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BrowseErrorImpl &&
            (identical(other.failure, failure) || other.failure == failure));
  }

  @override
  int get hashCode => Object.hash(runtimeType, failure);

  /// Create a copy of BrowseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BrowseErrorImplCopyWith<_$BrowseErrorImpl> get copyWith =>
      __$$BrowseErrorImplCopyWithImpl<_$BrowseErrorImpl>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function() loading,
    required TResult Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)
        loaded,
    required TResult Function(Failure failure) error,
  }) {
    return error(failure);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function()? loading,
    TResult? Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)?
        loaded,
    TResult? Function(Failure failure)? error,
  }) {
    return error?.call(failure);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function()? loading,
    TResult Function(
            List<SheetMusic> sheets,
            List<SheetMusic> filteredSheets,
            String searchQuery,
            List<String> selectedTags,
            String sortBy,
            bool isRefreshing)?
        loaded,
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
    required TResult Function(BrowseInitial value) initial,
    required TResult Function(BrowseLoading value) loading,
    required TResult Function(BrowseLoaded value) loaded,
    required TResult Function(BrowseError value) error,
  }) {
    return error(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(BrowseInitial value)? initial,
    TResult? Function(BrowseLoading value)? loading,
    TResult? Function(BrowseLoaded value)? loaded,
    TResult? Function(BrowseError value)? error,
  }) {
    return error?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(BrowseInitial value)? initial,
    TResult Function(BrowseLoading value)? loading,
    TResult Function(BrowseLoaded value)? loaded,
    TResult Function(BrowseError value)? error,
    required TResult orElse(),
  }) {
    if (error != null) {
      return error(this);
    }
    return orElse();
  }
}

abstract class BrowseError implements BrowseState {
  const factory BrowseError(final Failure failure) = _$BrowseErrorImpl;

  Failure get failure;

  /// Create a copy of BrowseState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BrowseErrorImplCopyWith<_$BrowseErrorImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
