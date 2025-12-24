import 'package:flutter_test/flutter_test.dart';
import 'package:sheet_scanner/core/utils/either.dart';

/// Test helper class for Either tests
class _TestUser {
  final String name;
  final int age;
  _TestUser(this.name, this.age);
}

void main() {
  group('Either - Left', () {
    test('Left stores and provides access to left value', () {
      final left = Left<String, int>('Error');
      expect(left.value, 'Error');
    });

    test('Left.fold calls onLeft function', () {
      final left = Left<String, int>('Error');
      final result = left.fold(
        (error) => 'Got error: $error',
        (value) => 'Got value: $value',
      );
      expect(result, 'Got error: Error');
    });

    test('Left.fold does not call onRight function', () {
      final left = Left<String, int>('Error');
      var rightCalled = false;
      left.fold(
        (error) => error,
        (value) {
          rightCalled = true;
          return value;
        },
      );
      expect(rightCalled, false);
    });

    test('Left.flatMap returns Left unchanged', () {
      final left = Left<String, int>('Error');
      final result = left.flatMap<double>((value) => Right(value.toDouble()));
      expect(result, isA<Left<String, double>>());
      expect(result.toNullable(), isNull);
    });

    test('Left.map returns Left unchanged', () {
      final left = Left<String, int>('Error');
      final result = left.map<double>((value) => value.toDouble());
      expect(result, isA<Left<String, double>>());
    });

    test('Left.mapLeft transforms left value', () {
      final left = Left<String, int>('Error');
      final result = left.mapLeft<int>((error) => error.length);
      expect(result, isA<Left<int, int>>());
      result.fold(
        (error) => expect(error, 5),
        (value) => fail('Should be Left'),
      );
    });

    test('Left.toNullable returns null', () {
      final left = Left<String, int>('Error');
      expect(left.toNullable(), isNull);
    });

    test('Left.isRight returns false', () {
      final left = Left<String, int>('Error');
      expect(left.isRight(), false);
    });

    test('Left.isLeft returns true', () {
      final left = Left<String, int>('Error');
      expect(left.isLeft(), true);
    });

    test('Left.toString represents left', () {
      final left = Left<String, int>('Error');
      expect(left.toString(), contains('Left'));
    });
  });

  group('Either - Right', () {
    test('Right stores and provides access to right value', () {
      final right = Right<String, int>(42);
      expect(right.value, 42);
    });

    test('Right.fold calls onRight function', () {
      final right = Right<String, int>(42);
      final result = right.fold(
        (error) => 'Got error: $error',
        (value) => 'Got value: $value',
      );
      expect(result, 'Got value: 42');
    });

    test('Right.fold does not call onLeft function', () {
      final right = Right<String, int>(42);
      var leftCalled = false;
      right.fold(
        (error) {
          leftCalled = true;
          return error;
        },
        (value) => value,
      );
      expect(leftCalled, false);
    });

    test('Right.flatMap chains Either operations', () {
      final right = Right<String, int>(5);
      final result = right.flatMap<int>((value) => Right(value * 2));
      expect(result, isA<Right<String, int>>());
      expect(result.toNullable(), 10);
    });

    test('Right.flatMap can return Left', () {
      final right = Right<String, int>(5);
      final result = right.flatMap<int>((value) => Left('Error'));
      expect(result, isA<Left<String, int>>());
    });

    test('Right.map transforms right value', () {
      final right = Right<String, int>(5);
      final result = right.map<double>((value) => value.toDouble());
      expect(result, isA<Right<String, double>>());
      expect(result.toNullable(), 5.0);
    });

    test('Right.mapLeft returns Right unchanged', () {
      final right = Right<String, int>(42);
      final result = right.mapLeft<int>((error) => error.length);
      expect(result, isA<Right<int, int>>());
      expect(result.toNullable(), 42);
    });

    test('Right.toNullable returns the value', () {
      final right = Right<String, int>(42);
      expect(right.toNullable(), 42);
    });

    test('Right.isRight returns true', () {
      final right = Right<String, int>(42);
      expect(right.isRight(), true);
    });

    test('Right.isLeft returns false', () {
      final right = Right<String, int>(42);
      expect(right.isLeft(), false);
    });

    test('Right.toString represents right', () {
      final right = Right<String, int>(42);
      expect(right.toString(), contains('Right'));
    });
  });

  group('Either - Chaining operations', () {
    test('chain multiple map operations on Right', () {
      final result = Right<String, int>(5)
          .map<int>((v) => v * 2)
          .map<int>((v) => v + 3)
          .map<String>((v) => 'Result: $v');

      expect(result.toNullable(), 'Result: 13');
    });

    test('chain operations on Left stops at first Left', () {
      final result = Left<String, int>('Error')
          .map<int>((v) => v * 2)
          .map<int>((v) => v + 3);

      expect(result.toNullable(), isNull);
    });

    test('flatMap with Right returns new Right', () {
      final result = Right<String, int>(5).flatMap<int>((v) {
        if (v > 0) {
          return Right(v * 2);
        } else {
          return Left('Negative value');
        }
      });

      expect(result.toNullable(), 10);
    });

    test('flatMap with negative value returns Left', () {
      final result = Right<String, int>(-5).flatMap<int>((v) {
        if (v > 0) {
          return Right(v * 2);
        } else {
          return Left('Negative value');
        }
      });

      expect(result.isLeft(), true);
      expect(result.toNullable(), isNull);
    });
  });

  group('Either - Complex scenarios', () {
    test('fold with different return types', () {
      final either = Right<String, int>(42);
      final result = either.fold<String>(
        (error) => 'Error: $error',
        (value) => 'Success: $value',
      );
      expect(result, 'Success: 42');
    });

    test('work with custom objects', () {
      final either = Right<String, _TestUser>(
        _TestUser('Alice', 30),
      );

      expect(either.toNullable()?.name, 'Alice');
      expect(either.toNullable()?.age, 30);
    });

    test('handle null values in Right', () {
      final either = Right<String, String?>(null);
      expect(either.toNullable(), isNull);
      expect(either.isRight(), true);
    });

    test('chain mapLeft transformations', () {
      final either = Left<String, int>('Error');
      final result = either
          .mapLeft<int>((error) => error.length)
          .mapLeft<String>((code) => 'Code: $code');

      expect(result.isLeft(), true);
    });

    test('mixed Left and Right operations', () {
      final rightResult = Right<String, int>(5)
          .flatMap<int>((v) => Right(v * 2))
          .flatMap<int>((v) => Left('Failed'));

      expect(rightResult.isLeft(), true);

      final leftResult = Left<String, int>('Start error')
          .mapLeft<String>((e) => '$e - handled');

      expect(leftResult.isLeft(), true);
    });
  });

  group('Either - Edge cases', () {
    test('Right with zero value', () {
      final right = Right<String, int>(0);
      expect(right.toNullable(), 0);
      expect(right.isRight(), true);
    });

    test('Right with empty string', () {
      final right = Right<String, String>('');
      expect(right.toNullable(), '');
      expect(right.isRight(), true);
    });

    test('Left with empty string error', () {
      final left = Left<String, int>('');
      expect(left.isLeft(), true);
    });

    test('fold executes onRight for Right', () {
      final either = Right<String, int>(5);
      final result = either.fold(
        (error) => -1,
        (value) => value * 2,
      );
      expect(result, 10);
    });

    test('multiple Either instances are independent', () {
      final left = Left<String, int>('Error');
      final right = Right<String, int>(42);

      expect(left.isLeft(), true);
      expect(right.isRight(), true);
      expect(left.isRight(), false);
      expect(right.isLeft(), false);
    });
  });
}
