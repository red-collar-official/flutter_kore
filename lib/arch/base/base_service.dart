import 'package:flutter/foundation.dart';

/// Base class that creates and holds some third party instance
/// 
/// @singletonService
/// class StripeService extends BaseService<Stripe> {
///   @override
///   Stripe createService() {
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
  void initialize() {
    _instance = createService();
    initialized = true;
  }

  /// disposes resources of service
  void dispose() {}

  /// Creates actual object instance
  T createService();

  /// actual object instance
  T get instance => _instance;
}
