// ignore_for_file: unawaited_futures, document_ignores

import 'dart:async';

import 'package:caxapok/caxapok.dart';
import 'package:fake_async/fake_async.dart';
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

    test('handles async onCancel callback', () {
      fakeAsync((async) {
        var onCancelCalled = false;
        var cancelDone = false;
        Object? error;
        final task =
            Completer<int>().future.cancellable(
              onCancel: () async {
                await Future<void>.delayed(const Duration(milliseconds: 10));
                onCancelCalled = true;
              },
            )..catchError((Object e) {
              error = e;
              return 0;
            });

        task.cancel().then((_) => cancelDone = true);
        async.elapse(const Duration(milliseconds: 9));
        expect(onCancelCalled, isFalse);
        expect(cancelDone, isFalse);
        expect(error, isNull);

        async.elapse(const Duration(milliseconds: 1));
        expect(onCancelCalled, isTrue);
        expect(cancelDone, isTrue);
        expect(error, isA<TaskCancelledException>());
      });
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

    test('timeout works correctly', () {
      fakeAsync((async) {
        Object? error;
        Completer<int>().future.cancellable().timeout(const Duration(milliseconds: 10)).catchError((
          Object e,
        ) {
          error = e;
          return 0;
        });

        async.elapse(const Duration(milliseconds: 9));
        expect(error, isNull);

        async.elapse(const Duration(milliseconds: 1));
        expect(error, isA<TimeoutException>());
      });
    });

    test('timeout with onTimeout callback', () {
      fakeAsync((async) {
        int? result;
        Completer<int>().future
            .cancellable()
            .timeout(const Duration(milliseconds: 10), onTimeout: () => 99)
            .then((value) => result = value);

        async.elapse(const Duration(milliseconds: 10));

        expect(result, equals(99));
      });
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

    test('works with delayed future', () {
      fakeAsync((async) {
        int? result;
        Future.delayed(
          const Duration(milliseconds: 50),
          () => 42,
        ).cancellable().then((value) => result = value);

        async.elapse(const Duration(milliseconds: 49));
        expect(result, isNull);

        async.elapse(const Duration(milliseconds: 1));
        expect(result, equals(42));
      });
    });

    test('cancelling delayed future before completion', () {
      fakeAsync((async) {
        int? result;
        Object? error;
        final task = Future.delayed(const Duration(milliseconds: 100), () => 42).cancellable()
          ..then((value) => result = value).catchError((Object e) {
            error = e;
            return 0;
          });

        async.elapse(const Duration(milliseconds: 10));
        task.cancel();
        async.elapse(const Duration(milliseconds: 100));

        expect(error, isA<TaskCancelledException>());
        expect(result, isNull);
      });
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

    test('cancel without awaiting the task does not raise an unhandled error', () async {
      final task = Completer<int>().future.cancellable();

      await task.cancel();
      await Future<void>.delayed(Duration.zero);

      await expectLater(task, throwsA(isA<TaskCancelledException>()));
    });

    test('handles future that throws synchronously', () async {
      final future = Future.sync(() => throw Exception('sync error'));
      final task = future.cancellable();

      expect(task, throwsA(isA<Exception>()));
    });
  });

  group('minDuration()', () {
    const duration = Duration(milliseconds: 50);
    const tick = Duration(milliseconds: 1);

    test('waits at least duration for a fast future', () {
      fakeAsync((async) {
        int? result;
        Future.value(1).minDuration(duration).then((value) => result = value);

        async.elapse(duration - tick);
        expect(result, isNull);

        async.elapse(tick);
        expect(result, equals(1));
      });
    });

    test('does not add delay to a slow future', () {
      fakeAsync((async) {
        int? result;
        Future.delayed(duration * 2, () => 1).minDuration(duration).then((value) => result = value);

        async.elapse(duration * 2 - tick);
        expect(result, isNull);

        async.elapse(tick);
        expect(result, equals(1));
      });
    });

    test('delivers errors after duration', () {
      fakeAsync((async) {
        Object? error;
        Future<int>.error(Exception('boom')).minDuration(duration).catchError((Object e) {
          error = e;
          return 0;
        });

        async.elapse(duration - tick);
        expect(error, isNull);

        async.elapse(tick);
        expect(error, isA<Exception>());
      });
    });
  });

  group('retry()', () {
    const period = Duration(milliseconds: 10);
    const timeout = Duration(milliseconds: 100);

    test('returns the first successful result', () {
      fakeAsync((async) {
        var attempts = 0;
        Future<int> task() async {
          attempts++;
          if (attempts < 3) throw Exception('fail $attempts');
          return attempts;
        }

        int? result;
        task.retry(period: period, timeout: timeout).then((value) => result = value);
        async.elapse(timeout);

        expect(result, equals(3));
        expect(attempts, equals(3));
      });
    });

    test('waits period between attempts', () {
      fakeAsync((async) {
        final times = <Duration>[];
        Future<int> task() async {
          times.add(async.elapsed);
          throw Exception('fail');
        }

        task.retry(period: period, timeout: timeout).ignore();
        async.elapse(timeout);

        expect(times, equals([for (var i = 0; i < times.length; i++) period * i]));
      });
    });

    test('does not retry an Error', () {
      fakeAsync((async) {
        var attempts = 0;
        Future<int> task() async {
          attempts++;
          throw StateError('bug');
        }

        Object? error;
        task.retry(period: period, timeout: timeout).catchError((Object e) {
          error = e;
          return 0;
        });
        async.elapse(timeout);

        expect(error, isStateError);
        expect(attempts, equals(1));
      });
    });

    test('completes with the last error once next attempt would exceed timeout', () {
      fakeAsync((async) {
        var attempts = 0;
        Future<int> task() async {
          attempts++;
          throw Exception('fail $attempts');
        }

        Object? error;
        task.retry(period: period, timeout: timeout).catchError((Object e) {
          error = e;
          return 0;
        });
        async.elapse(timeout * 2);

        // Attempts at 0, 10, ..., 90 ms: the one at 100 ms would exceed timeout.
        expect(attempts, equals(10));
        expect('$error', equals('Exception: fail 10'));
      });
    });

    test('completes with TimeoutException when an attempt hangs', () {
      fakeAsync((async) {
        Future<int> task() => Completer<int>().future;

        Object? error;
        task.retry(period: period, timeout: timeout).catchError((Object e) {
          error = e;
          return 0;
        });

        async.elapse(timeout - period);
        expect(error, isNull);

        async.elapse(period);
        expect(error, isA<TimeoutException>());
      });
    });

    test('stops retrying after timeout', () {
      fakeAsync((async) {
        var attempts = 0;
        Future<int> task() async {
          attempts++;
          await Future<void>.delayed(const Duration(milliseconds: 40));
          throw Exception('fail');
        }

        task.retry(period: period, timeout: const Duration(milliseconds: 60)).ignore();
        async.elapse(const Duration(milliseconds: 60));
        final attemptsAtTimeout = attempts;
        async.elapse(timeout * 10);

        expect(attempts, equals(attemptsAtTimeout));
        expect(async.pendingTimers, isEmpty);
      });
    });

    test('cancel stops further attempts', () {
      fakeAsync((async) {
        var attempts = 0;
        Future<int> task() async {
          attempts++;
          throw Exception('fail');
        }

        Object? error;
        final retryTask = task.retry(period: period, timeout: timeout)
          ..catchError((Object e) {
            error = e;
            return 0;
          });
        async.elapse(period * 3);
        retryTask.cancel();
        async.flushMicrotasks();
        final attemptsAtCancel = attempts;
        async.elapse(timeout);

        expect(error, isA<TaskCancelledException>());
        expect(attempts, equals(attemptsAtCancel));
        expect(async.pendingTimers, isEmpty);
      });
    });
  });
}
