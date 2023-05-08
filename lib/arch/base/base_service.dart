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
abstract class BaseService<T> extends MvvmInstance<Map<String, dynamic>?> {
  /// actual object instance
  late T _instance;

  /// Inititalizes service
  @mustCallSuper
  @override
  void initialize(Map<String, dynamic>? input) {
    super.initialize(input);

    _instance = provideInstance(input);

    initialized = true;
  }

  /// Creates actual object instance
  T provideInstance(Map<String, dynamic>? params);

  /// actual object instance
  T get instance => _instance;
}
