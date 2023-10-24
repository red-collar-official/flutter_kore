import 'package:flutter/foundation.dart';
import 'package:umvvm/umvvm.dart';

/// Base class that wraps logic for working with third party dependency
///
/// @singleton
/// class StripeWrapper extends BaseWrapper<String> {
/// }
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
    await initializeDependenciesAsync(input);
  }
}

/// Base class that creates and holds some third party instance
/// and provides methods to work with it
///
/// @asyncSingleton
/// class StripeWrapper extends BaseHolderWrapper<Stripe, String> {
///   @override
///   Future<Stripe> provideInstance(String? params) async {
///     return Stripe.instance;
///   }
/// }
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
    await initializeDependenciesAsync(input);
  }

  /// Creates actual object instance
  Instance provideInstance(Input? input);

  /// actual object instance
  Instance get instance => _instance == null ? _instanceCreator() : _instance!;
}
