import 'package:flutter/foundation.dart';

import 'mvvm_instance.dart';

/// Base class that creates and holds some third party instance
/// and provides methods to work with it
///
/// @singleton
/// class StripeWrapper extends BaseWrapper<Stripe, String> {
///   @override
///   Stripe provideInstance(String? params) {
///     return Stripe.instance;
///   }
/// }
abstract class BaseWrapper<Instance, Input> extends MvvmInstance<Input?> {
  /// actual object instance
  late Instance Function() _instanceCreator;
  Instance? _instance;

  /// Inititalizes wrapper
  @mustCallSuper
  @override
  void initialize(Input? input) {
    super.initialize(input);

    _instanceCreator = () => provideInstance(input);

    initialized = true;
  }

  /// Creates actual object instance
  Instance provideInstance(Input? input);

  /// actual object instance
  Instance get instance => _instance ??= _instanceCreator();
}

/// Base class that creates and holds some third party instance
/// and provides methods to work with it
///
/// @singleton
/// class StripeWrapper extends AsyncBaseWrapper<Stripe, String> {
///   @override
///   Stripe provideInstance(String? params) {
///     return Stripe.instance;
///   }
/// }
abstract class AsyncBaseWrapper<Instance, Input> extends MvvmInstance<Input?> {
  /// actual object instance
  late Future<Instance> Function() _instanceCreator;
  Instance? _instance;

  @override
  bool isAsync(Input? input) => true;

  /// Inititalizes wrapper
  @mustCallSuper
  @override
  Future<void> initializeAsync(Input? input) async {
    await super.initializeAsync(input);

    _instanceCreator = () => provideInstance(input);

    initialized = true;
  }

  /// Creates actual object instance
  Future<Instance> provideInstance(Input? input);

  /// actual object instance
  Future<Instance> get instance =>
      _instance == null ? _instanceCreator() : Future.value(_instance);

  /// actual object instance
  Instance unwrapInstance() => _instance!;
}
