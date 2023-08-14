import 'package:flutter/foundation.dart';

import 'mvvm_instance.dart';

/// Base class that creates and holds some third party instance
///
/// @singletonService
/// class StripeService extends BaseService<Stripe> {
///   @override
///   Stripe provideInstance(Map<String, dynamic>? params) {
///     return Stripe.instance;
///   }
/// }
abstract class BaseService<Instance, Input> extends MvvmInstance<Input?> {
  /// actual object instance
  late Instance Function() _instanceCreator;
  Instance? _instance;

  /// Inititalizes service
  @mustCallSuper
  @override
  void initialize(Input? input) {
    super.initialize(input);

    _instanceCreator = () => provideInstance(input);

    initialized = true;
  }

  /// Creates actual object instance
  Instance provideInstance(Input? params);

  /// actual object instance
  Instance get instance => _instance ??= _instanceCreator();
}
