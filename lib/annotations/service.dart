class DefaultService {
  final Type inputType;

  const DefaultService({
    this.inputType = Map<String, dynamic>,
  });
}

/// Annotate class as service that holds some instance
/// ```dart
/// @defaultService
/// class StripeService extends BaseService<Stripe> {
///   @override
///   Stripe createService() {
///     return Stripe.instance;
///   }
/// }
/// }
/// ```
const defaultService = DefaultService();
