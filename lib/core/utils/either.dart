/// Result type for clean error handling without exceptions.
///
/// Either represents a value of one of two possible types (disjoint union).
/// An instance of Either is either an instance of Left or Right.
/// Left is used to hold error/failure values, Right is used for success values.
///
/// Example:
/// ```dart
/// Either<Failure, String> result = fetchData();
/// result.fold(
///   (failure) => print('Error: ${failure.message}'),
///   (data) => print('Success: $data'),
/// );
/// ```
sealed class Either<L, R> {
  /// Apply a function to the left value if present, otherwise return right.
  T fold<T>(T Function(L) onLeft, T Function(R) onRight);

  /// Convert to Right if Either is Right, otherwise convert Left to Right.
  Either<L, R2> flatMap<R2>(Either<L, R2> Function(R) f);

  /// Convert Right value to new type.
  Either<L, R2> map<R2>(R2 Function(R) f);

  /// Convert Left value to new type.
  Either<L2, R> mapLeft<L2>(L2 Function(L) f);

  /// Get Right value or null.
  R? toNullable();

  /// Check if this is a Right.
  bool isRight();

  /// Check if this is a Left.
  bool isLeft();
}

/// Left side of Either - represents a failure/error value.
class Left<L, R> extends Either<L, R> {
  final L value;

  Left(this.value);

  @override
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    return onLeft(value);
  }

  @override
  Either<L, R2> flatMap<R2>(Either<L, R2> Function(R) f) {
    return Left(value);
  }

  @override
  Either<L, R2> map<R2>(R2 Function(R) f) {
    return Left(value);
  }

  @override
  Either<L2, R> mapLeft<L2>(L2 Function(L) f) {
    return Left(f(value));
  }

  @override
  R? toNullable() => null;

  @override
  bool isRight() => false;

  @override
  bool isLeft() => true;

  @override
  String toString() => 'Left($value)';
}

/// Right side of Either - represents a success value.
class Right<L, R> extends Either<L, R> {
  final R value;

  Right(this.value);

  @override
  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    return onRight(value);
  }

  @override
  Either<L, R2> flatMap<R2>(Either<L, R2> Function(R) f) {
    return f(value);
  }

  @override
  Either<L, R2> map<R2>(R2 Function(R) f) {
    return Right(f(value));
  }

  @override
  Either<L2, R> mapLeft<L2>(L2 Function(L) f) {
    return Right(value);
  }

  @override
  R? toNullable() => value;

  @override
  bool isRight() => true;

  @override
  bool isLeft() => false;

  @override
  String toString() => 'Right($value)';
}
