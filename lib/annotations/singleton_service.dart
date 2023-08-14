class SingletonService {
  final Type inputType;

  const SingletonService({
    this.inputType = Map<String, dynamic>,
  });
}

/// Annotate class as service that holds some singleton instance
/// ```dart
/// @singletonService
/// class StripeService extends BaseService<Stripe> {
///   @override
///   Stripe createService() {
///     return Stripe.instance;
///   }
/// }
/// }
/// ```
const singletonService = SingletonService();
