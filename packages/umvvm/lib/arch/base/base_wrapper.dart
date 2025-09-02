import 'package:flutter/foundation.dart';
import 'package:umvvm/umvvm.dart';

/// Base class that wraps logic for working with third party dependency
///
/// Wrappers can contain dependencies and receive events
/// They also can contain parts
/// You also can execute requests and cancel them automatically when wrapper will be disposed
/// with [ApiCaller.executeAndCancelOnDispose] method
///
/// Example:
///
/// ```dart
/// @singleton
/// class StripeWrapper extends BaseStaticWrapper<String> {
/// }
/// ```
abstract class BaseStaticWrapper<Input> extends MvvmInstance<Input?>
    with DependentMvvmInstance<Input?>, ApiCaller<Input?> {
  /// Inititalizes wrapper
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
  }

  @mustCallSuper
  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();
    await initializeDependenciesAsync();
  }
}

/// Base class that creates and holds some third party instance and provides methods to work with it
///
/// Wrappers can contain dependencies and receive events
/// They also can contain parts
/// You also can execute requests and cancel them automatically when wrapper will be disposed
/// with [ApiCaller.executeAndCancelOnDispose] method
///
/// Example:
///
/// ```dart
/// @asyncSingleton
/// class StripeWrapper extends BaseHolderWrapper<Stripe, String> {
///   @override
///   DependentMvvmInstanceConfiguration get configuration =>
///     const DependentMvvmInstanceConfiguration(
///       isAsync: true,
///     );
///
///   @override
///   Stripe provideInstance() {
///     return Stripe.instance;
///   }
/// }
/// ```
abstract class BaseHolderWrapper<MInstance, Input> extends MvvmInstance<Input?>
    with DependentMvvmInstance<Input?>, ApiCaller<Input?> {
  /// Actual object instance
  late MInstance Function() _instanceCreator;
  MInstance? _instance;

  @mustCallSuper
  @override
  void initialize(Input? input) {
    super.initialize(input);

    _instanceCreator = provideInstance;

    initializeDependencies();
  }

  @override
  void dispose() {
    super.dispose();

    disposeDependencies();
    cancelAllRequests();
  }

  /// Inititalizes wrapper
  @mustCallSuper
  @override
  Future<void> initializeAsync() async {
    await super.initializeAsync();
    await initializeDependenciesAsync();
  }

  /// Creates actual object instance
  MInstance provideInstance();

  /// Actual object instance
  MInstance get instance {
    _instance ??= _instanceCreator();

    return _instance!;
  }
}
