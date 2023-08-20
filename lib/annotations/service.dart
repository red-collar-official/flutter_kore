/// Annotate class as service that holds some instance
/// You also can specify type of input data fot this service
/// ```dart
/// @DefaultService(inputType: String)
/// class NavigationService extends BaseService<NavigationStack, String> {
///   @override
///   NavigationStack provideInstance(String? input) {
///     return NavigationStack();
///   }
/// }
/// ```
class DefaultService {
  /// Input type for this service, Map<String, dynamic> by default
  final Type inputType;

  const DefaultService({
    this.inputType = Map<String, dynamic>,
  });
}

/// Annotate class as service that holds some instance
/// ```dart
/// @defaultService
/// class NavigationService extends BaseService<NavigationStack, Map<String, dynamic>> {
///   @override
///   NavigationStack provideInstance(Map<String, dynamic>? input) {
///     return NavigationStack();
///   }
/// }
/// ```
const defaultService = DefaultService();
