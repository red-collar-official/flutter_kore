import 'package:flutter/foundation.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// Base class that wraps logic for working with third party dependency
///
/// Wrappers can contain dependencies and receive events
/// They also can contain parts
/// You also can execute requests and cancel them automatically when wrapper will be disposed
/// with [ApiCaller.executeAndCancelOnDispose] method
///
/// Also wrappers can execute operations in sync with [SynchronizedKoreInstance.enqueue]
///
/// Example:
///
/// ```dart
/// @singleton
/// class StripeWrapper extends BaseWrapper<String> {
/// }
/// ```
abstract class BaseWrapper<Input> extends BaseKoreInstance<Input?>
    with
        DependentKoreInstance<Input?>,
        SynchronizedKoreInstance<Input?>,
        ApiCaller<Input?> {
  @mustCallSuper
  @override
  void initialize(Input? input) {
    super.initialize(input);

    initializeDependencies();
  }

  @override
  void dispose() {
    super.dispose();

    disposeDependencies();
    cancelAllRequests();
    cancelPendingOperations();
  }

  @mustCallSuper
  @override
  Future<void> initializeAsync() async {
    await initializeDependenciesAsync();

    await super.initializeAsync();
  }
}
