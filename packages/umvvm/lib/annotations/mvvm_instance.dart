// coverage:ignore-file

/// Annotate class as custom mvvm instance
///
/// ```dart
/// @Instance(inputType: String, singleton: true)
/// class NavigationWrapper extends BaseHolderWrapper<NavigationStack, Map<String, dynamic>> {
///   @override
///   NavigationStack provideInstance() {
///     return NavigationStack();
///   }
/// }
/// ```
///
class Instance {
  /// Input type for this instance. Map by default
  final Type inputType;

  /// Flag indicating is this instance singleton - defaults to false
  final bool singleton;

  /// Flag indicating is this instance lazy singleton - defaults to false.
  ///
  /// Only matters if [singleton] is set to true
  final bool isLazy;

  /// Initialization order for this instance.
  ///
  /// Only matters if [singleton], [isAsync]
  /// and [awaitInitialization] are set to true
  final int? initializationOrder;

  /// Flag indicating that initialization of
  ///
  /// this instance needs to be awaited at app startup - defaults to false
  /// Only matters if [singleton], [isAsync] are set to true
  final bool awaitInitialization;

  /// Flag indicating that this instance is async - has async initialization
  final bool isAsync;

  /// Flag indicating that this instance is part instance
  final bool part;

  const Instance({
    this.inputType = Map<String, dynamic>,
    this.singleton = false,
    this.isLazy = false,
    this.initializationOrder,
    this.isAsync = false,
    this.awaitInitialization = false,
    this.part = false,
  });
}

/// Annotate class as default mvvm instance
///
/// ```dart
/// @instance
/// class NavigationWrapper extends BaseHolderWrapper<NavigationStack, Map<String, dynamic>> {
///   @override
///   NavigationStack provideInstance() {
///     return NavigationStack();
///   }
/// }
/// ```
const basicInstance = Instance();

/// Annotate class as mvvm instance part
///
/// ```dart
/// @instancePart
/// class NavigationPart extends BaseInstancePart<int, NavigationInteractor> {
/// ```
const instancePart = Instance(part: true);

/// Annotate class as async mvvm instance part
///
/// ```dart
/// @asyncInstancePart
/// class NavigationPart extends BaseInstancePart<int, NavigationInteractor> {
/// ```
const asyncInstancePart = Instance(part: true, isAsync: true);

/// Annotate class as singleton mvvm instance
///
/// ```dart
/// @singleton
/// class NavigationWrapper extends BaseHolderWrapper<NavigationStack, Map<String, dynamic>> {
///   @override
///   NavigationStack provideInstance() {
///     return NavigationStack();
///   }
/// }
/// ```
const singleton = Instance(singleton: true);

/// Annotate class as lazy singleton mvvm instance
///
/// ```dart
/// @lazySingleton
/// class NavigationWrapper extends BaseHolderWrapper<NavigationStack, Map<String, dynamic>> {
///   @override
///   NavigationStack provideInstance() {
///     return NavigationStack();
///   }
/// }
/// ```
const lazySingleton = Instance(singleton: true, isLazy: true);

/// Annotate class as async default mvvm instance
///
/// ```dart
/// @asyncBasicInstance
/// class NavigationWrapper extends BaseHolderWrapper<NavigationStack, Map<String, dynamic>> {
///  @override
///  DependentMvvmInstanceConfiguration get configuration =>
///    DependentMvvmInstanceConfiguration(
///      isAsync: true,
///    );
///
///   @override
///   NavigationStack provideInstance() {
///     return NavigationStack();
///   }
/// }
/// ```
const asyncBasicInstance = Instance(isAsync: true);

/// Annotate class as async singleton mvvm instance
///
/// ```dart
/// @asyncSingleton
/// class NavigationWrapper extends BaseHolderWrapper<NavigationStack, Map<String, dynamic>> {
///  @override
///  DependentMvvmInstanceConfiguration get configuration =>
///    DependentMvvmInstanceConfiguration(
///      isAsync: true,
///    );
///
///   @override
///   NavigationStack provideInstance() {
///     return NavigationStack();
///   }
/// }
/// ```
const asyncSingleton = Instance(singleton: true, isAsync: true);

/// Annotate class as async lazy singleton mvvm instance
///
/// ```dart
/// @asyncLazySingleton
/// class NavigationWrapper extends BaseHolderWrapper<NavigationStack, Map<String, dynamic>> {
///  @override
///  DependentMvvmInstanceConfiguration get configuration =>
///    DependentMvvmInstanceConfiguration(
///      isAsync: true,
///    );
///
///   @override
///   NavigationStack provideInstance() {
///     return NavigationStack();
///   }
/// }
/// ```
const asyncLazySingleton = Instance(
  singleton: true,
  isLazy: true,
  isAsync: true,
);
