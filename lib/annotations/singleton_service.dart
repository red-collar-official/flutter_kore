/// Annotate class as service that holds some singleton instance
/// You also can specify type of input data fot this service
/// ```dart
/// @SingletonService(inputType: String)
/// class NavigationService extends BaseService<NavigationStack, String> {
///   @override
///   NavigationStack provideInstance(String? input) {
///     return NavigationStack();
///   }
/// }
/// ```
class SingletonService {
  /// Input type for this service, Map<String, dynamic> by default
  final Type inputType;

  const SingletonService({
    this.inputType = Map<String, dynamic>,
  });
}

/// Annotate class as service that holds some singleton instance
/// ```dart
/// @singletonService
/// class NavigationService extends BaseService<NavigationStack, Map<String, dynamic>> {
///   @override
///   NavigationStack provideInstance(Map<String, dynamic>? input) {
///     return NavigationStack();
///   }
/// }
/// ```
const singletonService = SingletonService();
