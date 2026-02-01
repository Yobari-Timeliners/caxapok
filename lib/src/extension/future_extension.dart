import 'dart:async';

extension FutureExtension<T> on Future<T> {
  /// Converts this [Future] into a [CancellableTask] that can be cancelled before completion.
  ///
  /// A cancellable task allows you to cancel long-running operations and optionally
  /// perform cleanup through the [onCancel] callback.
  ///
  /// When [CancellableTask.cancel] is called:
  /// - If the [onCancel] callback is provided, it will be executed
  /// - The task will complete with a [TaskCancelledException]
  /// - Any chained operations (like `then`, `catchError`) will receive the exception
  ///
  /// If the original future completes before cancellation, the task completes normally
  /// and calling cancel afterwards has no effect.
  ///
  /// The [onCancel] callback can be either synchronous or asynchronous (returning
  /// `void` or `Future<void>`). It's useful for cleanup operations like:
  /// - Closing network connections
  /// - Canceling timers
  /// - Releasing resources
  /// - Updating UI state
  ///
  /// Example:
  ///
  /// ```dart
  /// // Basic cancellation
  /// final task = Future.delayed(
  ///   Duration(seconds: 5),
  ///   () => 'completed',
  /// ).cancellable();
  ///
  /// // Cancel after 1 second
  /// Future.delayed(Duration(seconds: 1), () => task.cancel());
  ///
  /// try {
  ///   final result = await task;
  ///   print(result);
  /// } on TaskCancelledException {
  ///   print('Task was cancelled');
  /// }
  /// ```
  ///
  /// Example with cleanup:
  ///
  /// ```dart
  /// final client = HttpClient();
  /// final task = client.get('example.com', 80, '/api/data')
  ///   .then((request) => request.close())
  ///   .then((response) => response.transform(utf8.decoder).join())
  ///   .cancellable(onCancel: () {
  ///     client.close();
  ///     print('Connection closed due to cancellation');
  ///   });
  ///
  /// // Later, if needed:
  /// await task.cancel();
  /// ```
  ///
  /// See also:
  /// - [CancellableTask], the returned task type
  /// - [TaskCancelledException], thrown when a task is cancelled
  CancellableTask<T> cancellable({FutureOr<void> Function()? onCancel}) => CancellableTask<T>(
    future: this,
    onCancel: onCancel,
  );
}

/// A [Future] that can be cancelled before it completes.
///
/// This class wraps a [Future] and provides the ability to cancel it through
/// the [cancel] method. When cancelled, the task completes with a
/// [TaskCancelledException] instead of its normal result.
///
/// Create a [CancellableTask] using the [FutureExtension.cancellable] extension
/// method on any [Future].
///
/// The task implements [Future], so it can be used anywhere a regular future
/// is expected, including with `await`, `.then()`, `.catchError()`, etc.
///
/// Example:
///
/// ```dart
/// final task = Future.delayed(Duration(seconds: 5))
///   .cancellable(onCancel: () => print('Cleaning up...'));
///
/// // Cancel the task
/// await task.cancel();
///
/// // The task will throw TaskCancelledException
/// try {
///   await task;
/// } catch (e) {
///   print(e); // Task was cancelled
/// }
/// ```
class CancellableTask<T> implements Future<T> {
  final Future<T> _future;
  final FutureOr<void> Function()? _onCancel;

  CancellableTask({
    /// Cancels this task, preventing it from completing normally.
    ///
    /// When called:
    /// 1. If the task has already completed, this method does nothing
    /// 2. Otherwise, executes the `onCancel` callback (if provided)
    /// 3. Completes the task with a [TaskCancelledException]
    ///
    /// This method is idempotent - calling it multiple times has no additional effect.
    ///
    /// Any operations chained to this task (via `then`, `catchError`, etc.) will
    /// receive the [TaskCancelledException].
    ///
    /// Returns a [Future] that completes when the cancellation is done. If `onCancel`
    /// throws an error, that error will be propagated through the returned future,
    /// but the task itself will still complete with [TaskCancelledException].
    ///
    /// Example:
    ///
    /// ```dart
    /// final task = Future.delayed(Duration(seconds: 10))
    ///   .cancellable(onCancel: () async {
    ///     // Cleanup code here
    ///     await closeConnections();
    ///   });
    ///
    /// // Cancel after 1 second
    /// await Future.delayed(Duration(seconds: 1));
    /// await task.cancel();
    ///
    /// // Task is now cancelled
    /// try {
    ///   await task;
    /// } on TaskCancelledException {
    ///   print('Operation was cancelled');
    /// }
    /// ```
    required Future<T> future,
    FutureOr<void> Function()? onCancel,
  }) : _future = future,
       _onCancel = onCancel {
    _init();
  }

  final _completer = Completer<T>();

  @override
  Stream<T> asStream() => _completer.future.asStream();

  @override
  Future<T> catchError(Function onError, {bool Function(Object error)? test}) =>
      _completer.future.catchError(onError, test: test);

  @override
  Future<R> then<R>(FutureOr<R> Function(T value) onValue, {Function? onError}) =>
      _completer.future.then(onValue, onError: onError);

  @override
  Future<T> timeout(Duration timeLimit, {FutureOr<T> Function()? onTimeout}) =>
      /// Exception thrown when a [CancellableTask] is cancelled.
      ///
      /// This exception is thrown to any code awaiting a cancelled task, as well as
      /// to any chained operations (like `then` or `catchError`).
      ///
      /// You can catch this specific exception to handle cancellation separately
      /// from other errors:
      ///
      /// ```dart
      /// try {
      ///   final result = await cancellableTask;
      ///   print('Completed: $result');
      /// } on TaskCancelledException {
      ///   print('Task was cancelled');
      /// } catch (e) {
      ///   print('Other error: $e');
      /// }
      /// ```
      _completer.future.timeout(timeLimit, onTimeout: onTimeout);

  @override
  Future<T> whenComplete(FutureOr<void> Function() action) =>
      _completer.future.whenComplete(action);

  Future<void> cancel() async {
    if (_completer.isCompleted) return;

    try {
      await _onCancel?.call();
    } finally {
      if (!_completer.isCompleted) {
        _completer.completeError(
          const TaskCancelledException(),
          StackTrace.current,
        );
      }
    }
  }

  Future<void> _init() async {
    try {
      final result = await _future;

      if (_completer.isCompleted) return;

      _completer.complete(result);
    } catch (e, stackTrace) {
      if (_completer.isCompleted) return;

      _completer.completeError(e, stackTrace);
    }
  }
}

final class TaskCancelledException implements Exception {
  const TaskCancelledException();

  @override
  String toString() => 'Task was cancelled';
}
