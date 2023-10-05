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

  const Instance({
    this.inputType = Map<String, dynamic>,
    this.singleton = false,
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
const instance = Instance();

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
