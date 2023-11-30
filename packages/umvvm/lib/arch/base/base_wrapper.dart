import 'package:flutter/foundation.dart';
import 'package:umvvm/umvvm.dart';

/// Base class that wraps logic for working with third party dependency
/// Wrappers can contain dependencies and receive events
/// They also can contain parts
/// You also can execute requests and cancel them automatically when wrapper will be disposed
/// with [executeAndCancelOnDispose] method
/// 
/// Example: 
/// 
/// ```dart
/// @singleton
/// class StripeWrapper extends BaseWrapper<String> {
/// }
/// ```
abstract class BaseWrapper<Input> extends MvvmInstance<Input?>
    with DependentMvvmInstance<Input?>, ApiCaller<Input?> {
  /// Inititalizes wrapper
  @mustCallSuper
  @override
  void initialize(Input? input) {
    super.initialize(input);

    initializeDependencies(input);

    initialized = true;
  }

  @override
  void dispose() {
    super.dispose();

    disposeDependencies();
    cancelAllRequests();

    initialized = false;
  }

  @mustCallSuper
  @override
  Future<void> initializeAsync(Input? input) async {
    await super.initializeAsync(input);
    await initializeDependenciesAsync(input);
  }

  @mustCallSuper
  @override
  void initializeWithoutConnections(Input? input) {
    initializeDependenciesWithoutConnections(input);

    initialized = true;
  }

  @mustCallSuper
  @override
  Future<void> initializeWithoutConnectionsAsync(Input? input) async {
    await initializeDependenciesWithoutConnectionsAsync(input);

    initialized = true;
  }
}

/// Base class that creates and holds some third party instance
/// and provides methods to work with it
/// Wrappers can contain dependencies and receive events
/// They also can contain parts
/// You also can execute requests and cancel them automatically when wrapper will be disposed
/// with [executeAndCancelOnDispose] method
/// 
/// Example: 
/// 
/// ```dart
/// @asyncSingleton
/// class StripeWrapper extends BaseHolderWrapper<Stripe, String> {
///   @override
///   Future<Stripe> provideInstance(String? params) async {
///     return Stripe.instance;
///   }
/// }
/// ```
abstract class BaseHolderWrapper<Instance, Input> extends MvvmInstance<Input?>
    with DependentMvvmInstance<Input?>, ApiCaller<Input?> {
  /// actual object instance
  late Instance Function() _instanceCreator;
  Instance? _instance;

  @mustCallSuper
  @override
  void initialize(Input? input) {
    super.initialize(input);

    _instanceCreator = () {
      return provideInstance(input);
    };

    initializeDependencies(input);

    initialized = true;
  }

  @override
  void dispose() {
    super.dispose();

    disposeDependencies();
    cancelAllRequests();

    initialized = false;
  }

  /// Inititalizes wrapper
  @mustCallSuper
  @override
  Future<void> initializeAsync(Input? input) async {
    await super.initializeAsync(input);
    await initializeDependenciesAsync(input);
  }

  /// Creates actual object instance
  Instance provideInstance(Input? input);

  /// Actual object instance
  Instance get instance => _instance == null ? _instanceCreator() : _instance!;
}
