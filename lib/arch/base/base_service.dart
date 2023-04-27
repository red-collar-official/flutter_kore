import 'package:flutter/foundation.dart';

/// Base class that creates and holds some third party instance
/// 
/// @singletonService
/// class StripeService extends BaseService<Stripe> {
///   @override
///   Stripe createService(Map<String, dynamic>? params) {
///     return Stripe.instance;
///   }
/// }
abstract class BaseService<T> {
  /// actual object instance
  late T _instance;

  /// flag indicating that instance is created
  bool initialized = false;

  /// Inititalizes service
  @mustCallSuper
  void initialize(Map<String, dynamic>? params) {
    _instance = createService(params);
    initialized = true;
  }

  /// disposes resources of service
  void dispose() {}

  /// Creates actual object instance
  T createService(Map<String, dynamic>? params);

  /// actual object instance
  T get instance => _instance;
}
