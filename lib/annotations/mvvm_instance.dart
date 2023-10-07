/// Annotate class as custom mvvm instance
/// ```dart
/// @Instance(inputType: String, singleton: true)
/// class NavigationWrapper extends BaseWrapper<NavigationStack, Map<String, dynamic>> {
///   @override
///   NavigationStack provideInstance(Map<String, dynamic>? input) {
///     return NavigationStack();
///   }
/// }
/// ```
///
class Instance {
  final Type inputType;
  final bool singleton;
  final bool lazy;

  const Instance({
    this.inputType = Map<String, dynamic>,
    this.singleton = false,
    this.lazy = false,
  });
}

/// Annotate class as default mvvm instance
/// ```dart
/// @instance
/// class NavigationWrapper extends BaseWrapper<NavigationStack, Map<String, dynamic>> {
///   @override
///   NavigationStack provideInstance(Map<String, dynamic>? input) {
///     return NavigationStack();
///   }
/// }
/// ```
const basicInstance = Instance();

/// Annotate class as singleton mvvm instance
/// ```dart
/// @singleton
/// class NavigationWrapper extends BaseWrapper<NavigationStack, Map<String, dynamic>> {
///   @override
///   NavigationStack provideInstance(Map<String, dynamic>? input) {
///     return NavigationStack();
///   }
/// }
/// ```
const singleton = Instance(singleton: true);

/// Annotate class as lazy singleton mvvm instance
/// ```dart
/// @lazySingleton
/// class NavigationWrapper extends BaseWrapper<NavigationStack, Map<String, dynamic>> {
///   @override
///   NavigationStack provideInstance(Map<String, dynamic>? input) {
///     return NavigationStack();
///   }
/// }
/// ```
const lazySingleton = Instance(singleton: true, lazy: true);