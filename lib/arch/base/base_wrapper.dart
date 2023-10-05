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
