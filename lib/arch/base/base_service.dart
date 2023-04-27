import 'package:flutter/foundation.dart';

import 'event_bus_receiver.dart';

/// Base class that creates and holds some third party instance
///
/// @singletonService
/// class StripeService extends BaseService<Stripe> {
///   @override
///   Stripe createService(Map<String, dynamic>? params) {
///     return Stripe.instance;
///   }
/// }
abstract class BaseService<T> extends EventBusReceiver {
  /// actual object instance
  late T _instance;

  /// flag indicating that instance is created
  bool initialized = false;

  /// Inititalizes service
  @mustCallSuper
  void initialize(Map<String, dynamic>? params) {
    _instance = createService(params);
    subscribeToEvents();
    
    initialized = true;
  }

  /// Creates actual object instance
  T createService(Map<String, dynamic>? params);

  /// actual object instance
  T get instance => _instance;
}
