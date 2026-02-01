// ignore_for_file: unawaited_futures, document_ignores

import 'dart:async';

import 'package:caxapok/src/extension/future_extension.dart';
import 'package:test/test.dart';

void main() {
  group('cancellable()', () {
    test('returns a CancellableTask', () {
      final future = Future.value(42);

      final task = future.cancellable();

      expect(task, isA<CancellableTask<int>>());
    });

    test('completes normally when not cancelled', () async {
      final future = Future.value(42);

      final task = future.cancellable();

      expect(await task, equals(42));
    });

    test('completes with TaskCancelledException when cancelled before completion', () async {
      final completer = Completer<int>();
      final task = completer.future.cancellable();

      await task.cancel();

      expect(task, throwsA(isA<TaskCancelledException>()));
    });

    test('calls onCancel callback when cancelled', () async {
      var onCancelCalled = false;
      final completer = Completer<int>();

      final task = completer.future.cancellable(
        onCancel: () {
          onCancelCalled = true;
        },
      )..cancel();

      // Wait for cancellation to propagate
      await expectLater(task, throwsA(isA<TaskCancelledException>()));
      expect(onCancelCalled, isTrue);
    });

    test('onCancel callback is not called if task completes before cancellation', () async {
      var onCancelCalled = false;
      final future = Future.value(42);

      final task = future.cancellable(
        onCancel: () {
          onCancelCalled = true;
        },
      );

      await task;
      await task.cancel();

      expect(onCancelCalled, isFalse);
    });

    test('handles async onCancel callback', () async {
      var onCancelCalled = false;
      final completer = Completer<int>();

      final task = completer.future.cancellable(
        onCancel: () async {
          await Future.delayed(const Duration(milliseconds: 10));
          onCancelCalled = true;
        },
      );

      await task.cancel();

      expect(onCancelCalled, isTrue);
      expect(task, throwsA(isA<TaskCancelledException>()));
    });

    test('cancel is idempotent - can be called multiple times', () async {
      final completer = Completer<int>();
      final task = completer.future.cancellable()
        ..cancel()
        ..cancel()
        ..cancel();

      expect(task, throwsA(isA<TaskCancelledException>()));
    });

    test('preserves original future error when not cancelled', () async {
      final future = Future<int>.error(Exception('test error'));

      final task = future.cancellable();

      expect(task, throwsA(isA<Exception>()));
    });

    test('then works correctly', () async {
      final future = Future.value(42);

      final task = future.cancellable();
      final result = await task.then((value) => value * 2);

      expect(result, equals(84));
    });

    test('then propagates cancellation', () async {
      final completer = Completer<int>();
      final task = completer.future.cancellable();

      final chainedFuture = task.then((value) => value * 2);
      await task.cancel();

      expect(chainedFuture, throwsA(isA<TaskCancelledException>()));
    });

    test('catchError handles original future errors', () async {
      final future = Future<int>.error(Exception('test error'));

      final task = future.cancellable();
      final result = await task.catchError((error) => 99);

      expect(result, equals(99));
    });

    test('catchError handles cancellation errors', () async {
      final completer = Completer<int>();
      final task = completer.future.cancellable();

      final chainedFuture = task.catchError((Object error, StackTrace stackTrace) {
        if (error is TaskCancelledException) {
          return -1;
        }
        Error.throwWithStackTrace(error, stackTrace);
      });

      await task.cancel();

      expect(await chainedFuture, equals(-1));
    });

    test('catchError with test predicate', () async {
      final future = Future<int>.error(Exception('test error'));

      final task = future.cancellable();
      final result = await task.catchError(
        (error) => 99,
        test: (error) => error is Exception,
      );

      expect(result, equals(99));
    });

    test('whenComplete is called on success', () async {
      var completeCalled = false;
      final future = Future.value(42);

      final task = future.cancellable();
      await task.whenComplete(() {
        completeCalled = true;
      });

      expect(completeCalled, isTrue);
    });

    test('whenComplete is called on cancellation', () async {
      var completeCalled = false;
      final completer = Completer<int>();
      final task = completer.future.cancellable();

      final chainedFuture = task.whenComplete(() {
        completeCalled = true;
      });

      await task.cancel();

      try {
        await chainedFuture;
      } on Object {
        // Expected
      }

      expect(completeCalled, isTrue);
    });

    test('timeout works correctly', () async {
      final completer = Completer<int>();
      final task = completer.future.cancellable();

      expect(
        task.timeout(const Duration(milliseconds: 10)),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('timeout with onTimeout callback', () async {
      final completer = Completer<int>();
      final task = completer.future.cancellable();

      final result = await task.timeout(
        const Duration(milliseconds: 10),
        onTimeout: () => 99,
      );

      expect(result, equals(99));
    });

    test('asStream returns stream with result', () async {
      final future = Future.value(42);
      final task = future.cancellable();

      final stream = task.asStream();
      final result = await stream.first;

      expect(result, equals(42));
    });

    test('asStream propagates cancellation', () async {
      final completer = Completer<int>();
      final task = completer.future.cancellable();

      final stream = task.asStream();
      await task.cancel();

      expect(stream.first, throwsA(isA<TaskCancelledException>()));
    });

    test('asStream propagates errors', () async {
      final future = Future<int>.error(Exception('test error'));
      final task = future.cancellable();

      final stream = task.asStream();

      expect(stream.first, throwsA(isA<Exception>()));
    });

    test('cancellation during then chain', () async {
      final completer = Completer<int>();
      final task = completer.future.cancellable();

      var thenCalled = false;
      final chainedFuture = task.then((value) {
        thenCalled = true;
        return value * 2;
      });

      await task.cancel();

      expect(chainedFuture, throwsA(isA<TaskCancelledException>()));
      expect(thenCalled, isFalse);
    });

    test('handles errors in onCancel callback gracefully', () async {
      final completer = Completer<int>();
      final task = completer.future.cancellable(
        onCancel: () {
          throw Exception('Error in onCancel');
        },
      );

      task.cancel().catchError((e) {
        // Expected - error from onCancel
      });

      // Task should still complete with TaskCancelledException
      await expectLater(task, throwsA(isA<TaskCancelledException>()));
    });

    test('TaskCancelledException toString returns descriptive message', () {
      const exception = TaskCancelledException();

      expect(exception.toString(), equals('Task was cancelled'));
    });

    test('multiple operations chained together', () async {
      final future = Future.value(10);

      final result = await future
          .cancellable()
          .then((value) => value * 2)
          .then((value) => value + 5)
          .catchError((error) => -1);

      expect(result, equals(25));
    });

    test('cancel after partial completion of chain', () async {
      final completer = Completer<int>();
      final task = completer.future.cancellable();

      var firstThenCalled = false;
      var secondThenCalled = false;

      final chainedFuture = task
          .then((value) {
            firstThenCalled = true;
            return value * 2;
          })
          .then((value) {
            secondThenCalled = true;
            return value + 5;
          });

      await task.cancel();

      expect(chainedFuture, throwsA(isA<TaskCancelledException>()));
      expect(firstThenCalled, isFalse);
      expect(secondThenCalled, isFalse);
    });

    test('works with immediate future', () async {
      final task = Future.value(42).cancellable();

      // Even though future completes immediately, task should work
      expect(await task, equals(42));
    });

    test('works with delayed future', () async {
      final task = Future.delayed(
        const Duration(milliseconds: 50),
        () => 42,
      ).cancellable();

      expect(await task, equals(42));
    });

    test('cancelling delayed future before completion', () async {
      final task = Future.delayed(
        const Duration(milliseconds: 100),
        () => 42,
      ).cancellable();

      await Future.delayed(const Duration(milliseconds: 10));
      await task.cancel();

      expect(task, throwsA(isA<TaskCancelledException>()));
    });

    test('onCancel with FutureOr return type returning void', () async {
      var onCancelCalled = false;
      final completer = Completer<int>();

      final task = completer.future.cancellable(
        onCancel: () {
          onCancelCalled = true;
          // Returns void
        },
      )..cancel();

      // Wait for cancellation to propagate
      await expectLater(task, throwsA(isA<TaskCancelledException>()));
      expect(onCancelCalled, isTrue);
    });

    test('works with generic types', () async {
      final task = Future.value(['a', 'b', 'c']).cancellable();

      final result = await task;

      expect(result, equals(['a', 'b', 'c']));
      expect(result, isA<List<String>>());
    });

    test('works with null values', () async {
      final task = Future<int?>.value().cancellable();

      final result = await task;

      expect(result, isNull);
    });

    test('handles future that throws synchronously', () async {
      final future = Future.sync(() => throw Exception('sync error'));
      final task = future.cancellable();

      expect(task, throwsA(isA<Exception>()));
    });
  });
}
