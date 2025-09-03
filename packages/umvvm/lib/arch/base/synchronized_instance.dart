import 'dart:async';

import 'package:umvvm/umvvm.dart';

/// Helper class to call any [Future] with addition of timeout handling
class SyncFuture {
  /// Flag indicating that this operation can be canceled
  ///
  /// Used by [SynchronizedMvvmInstance] to decide if this operation must be canceled
  /// when calling instance is disposed
  final bool cancelOnDispose;

  /// Optional timeout for this operation
  final Duration? timeout;

  /// Actual [Future] function that must be executed by this class
  final Future<void> Function() operation;

  /// Callback to process timeout exception
  final FutureOr<void> Function()? onTimeout;

  SyncFuture({
    required this.cancelOnDispose,
    required this.timeout,
    required this.operation,
    required this.onTimeout,
  });

  /// Flag indicating that this operation is still running
  var isRunning = false;

  /// Executes [operation] and handles timeout exception
  Future<void> execute() async {
    isRunning = true;

    if (timeout == null) {
      await operation();
    } else {
      try {
        await operation().timeout(timeout!, onTimeout: onTimeout);
      } catch (e) {
        onTimeout?.call();
      }
    }

    isRunning = false;

    await Future.microtask(() {});
  }
}

/// Base class for executing operations in queue, enabling to sync operations if needed
///
/// It contains internal operations queue and option to cancel remaining oprations when [MvvmInstance.dispose] called
///
/// ```dart
/// abstract class BaseBox extends MvvmInstance<dynamic> with SynchronizedMvvmInstance<dynamic> {
///   String get boxName;
///
///   late final hiveWrapper = app.instances.get<HiveWrapper>();
///
///   @mustCallSuper
///   @override
///   void dispose() {
///     super.dispose();
///
///     cancelPendingOperations();
///   }
/// }
/// ```
mixin SynchronizedMvvmInstance<Input> on MvvmInstance<Input> {
  /// Internal operations list
  final _runningFutures = <SyncFuture>[];

  /// Flag indicating that any operation is currently running
  var _isCurrentlyRunning = false;

  /// Executes operation in sync meaning that if you wrap any code in this function
  /// the code will be executed in place if currently there are no other operations running
  /// otherwise function will add operation to queue and it will be executed after all previously executed operations are completed
  ///
  /// [discardOnDispose] - flag indicating that this operation will be canceled when instance is disposed - defaults to true
  /// [timeout] - optional timeout for this operation
  /// [operation] - actual future callback that will be executed
  /// [onTimeout] - optional callback if timeout is reached
  Future<void> enqueue({
    bool discardOnDispose = true,
    Duration? timeout,
    required Future<void> Function() operation,
    FutureOr<void> Function()? onTimeout,
  }) async {
    final syncOperation = SyncFuture(
      cancelOnDispose: discardOnDispose,
      timeout: timeout,
      operation: operation,
      onTimeout: onTimeout,
    );

    _runningFutures.add(syncOperation);

    _enqueueNext();
  }

  /// Executes next operation in queue - otherwise if queue is empty does nothing
  void _enqueueNext() {
    if (_runningFutures.isEmpty || _isCurrentlyRunning) {
      return;
    }

    final nextOperation = _runningFutures.first;

    _isCurrentlyRunning = true;

    nextOperation.execute().then((_) {
      _isCurrentlyRunning = false;

      if (_runningFutures.isEmpty) {
        return;
      }

      _runningFutures.removeAt(0);
      _enqueueNext();
    });
  }

  /// Cancels all operations in current queue
  ///
  /// Due to [Future] implementation in dart this function will not stop future that is currently running
  /// but all operations after running future will be discarded
  void cancelPendingOperations() {
    final operationsToCancel = <SyncFuture>[];

    for (final operation in _runningFutures) {
      if (operation.cancelOnDispose && !operation.isRunning) {
        operationsToCancel.add(operation);
      }
    }

    operationsToCancel.forEach(_runningFutures.remove);
  }
}
