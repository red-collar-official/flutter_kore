// coverage:ignore-file

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
  final int? initializationOrder;
  final bool awaitInitialization;
  final bool async;
  final bool part;

  const Instance({
    this.inputType = Map<String, dynamic>,
    this.singleton = false,
    this.lazy = false,
    this.initializationOrder,
    this.async = false,
    this.awaitInitialization = false,
    this.part = false,
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

/// Annotate class as mvvm instance part
/// ```dart
/// @instancePart
/// class NavigationPart extends BaseInstancePart<int, NavigationInteractor> {
/// ```
const instancePart = Instance(part: true);

/// Annotate class as async mvvm instance part
/// ```dart
/// @asyncInstancePart
/// class NavigationPart extends BaseInstancePart<int, NavigationInteractor> {
/// ```
const asyncInstancePart = Instance(part: true, async: true);

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

/// Annotate class as async default mvvm instance
/// ```dart
/// @instance
/// class NavigationWrapper extends BaseWrapper<NavigationStack, Map<String, dynamic>> {
///   @override
///   NavigationStack provideInstance(Map<String, dynamic>? input) {
///     return NavigationStack();
///   }
/// }
/// ```
const asyncBasicInstance = Instance(async: true);

/// Annotate class as async singleton mvvm instance
/// ```dart
/// @singleton
/// class NavigationWrapper extends BaseWrapper<NavigationStack, Map<String, dynamic>> {
///   @override
///   NavigationStack provideInstance(Map<String, dynamic>? input) {
///     return NavigationStack();
///   }
/// }
/// ```
const asyncSingleton = Instance(singleton: true, async: true);

/// Annotate class as async lazy singleton mvvm instance
/// ```dart
/// @lazySingleton
/// class NavigationWrapper extends BaseWrapper<NavigationStack, Map<String, dynamic>> {
///   @override
///   NavigationStack provideInstance(Map<String, dynamic>? input) {
///     return NavigationStack();
///   }
/// }
/// ```
const asyncLazySingleton = Instance(singleton: true, lazy: true, async: true);
