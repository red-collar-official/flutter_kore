// coverage:ignore-file

/// Annotate class as custom kore instance
///
/// ```dart
/// @Instance(inputType: String, isSingleton: true)
/// class NavigationWrapper extends BaseWrapper<Map<String, dynamic>> {}
/// ```
///
class Instance {
  /// Input type for this instance. Map by default
  final Type inputType;

  /// Flag indicating is this instance singleton - defaults to false
  final bool isSingleton;

  /// Flag indicating is this instance lazy singleton - defaults to false.
  ///
  /// Only matters if [isSingleton] is set to true
  final bool isLazy;

  /// Initialization order for this instance.
  ///
  /// Only matters if [isSingleton], [isAsync]
  /// and [awaitInitialization] are set to true
  final int? initializationOrder;

  /// Flag indicating that initialization of
  ///
  /// this instance needs to be awaited at app startup - defaults to false
  /// Only matters if [isSingleton], [isAsync] are set to true
  final bool awaitInitialization;

  /// Flag indicating that this instance is async - has async initialization
  final bool isAsync;

  /// Flag indicating that this instance is part instance
  final bool isPart;

  const Instance({
    this.inputType = Map<String, dynamic>,
    this.isSingleton = false,
    this.isLazy = false,
    this.initializationOrder,
    this.isAsync = false,
    this.awaitInitialization = false,
    this.isPart = false,
  });
}

/// Annotate class as default kore instance
///
/// ```dart
/// @basicInstance
/// class NavigationWrapper extends BaseWrapper<Map<String, dynamic>> {}
/// ```
const basicInstance = Instance();

/// Annotate class as kore instance part
///
/// ```dart
/// @instancePart
/// class NavigationPart extends BaseInstancePart<int, NavigationInteractor> {
/// ```
const instancePart = Instance(isPart: true);

/// Annotate class as async kore instance part
///
/// ```dart
/// @asyncInstancePart
/// class NavigationPart extends BaseInstancePart<int, NavigationInteractor> {
/// ```
const asyncInstancePart = Instance(isPart: true, isAsync: true);

/// Annotate class as singleton kore instance
///
/// ```dart
/// @singleton
/// class NavigationWrapper extends BaseWrapper<Map<String, dynamic>> {}
/// ```
const singleton = Instance(isSingleton: true);

/// Annotate class as lazy singleton kore instance
///
/// ```dart
/// @lazySingleton
/// class NavigationWrapper extends BaseWrapper<Map<String, dynamic>> {}
/// ```
const lazySingleton = Instance(isSingleton: true, isLazy: true);

/// Annotate class as async default kore instance
///
/// ```dart
/// @asyncBasicInstance
/// class NavigationWrapper extends BaseWrapper<Map<String, dynamic>> {
///  @override
///  DependentKoreInstanceConfiguration get configuration =>
///    DependentKoreInstanceConfiguration(
///      isAsync: true,
///    );
/// }
/// ```
const asyncBasicInstance = Instance(isAsync: true);

/// Annotate class as async singleton kore instance
///
/// ```dart
/// @asyncSingleton
/// class NavigationWrapper extends BaseWrapper<Map<String, dynamic>> {
///  @override
///  DependentKoreInstanceConfiguration get configuration =>
///    DependentKoreInstanceConfiguration(
///      isAsync: true,
///    );
/// }
/// ```
const asyncSingleton = Instance(isSingleton: true, isAsync: true);

/// Annotate class as async lazy singleton kore instance
///
/// ```dart
/// @asyncLazySingleton
/// class NavigationWrapper extends BaseWrapper<Map<String, dynamic>> {
///  @override
///  DependentKoreInstanceConfiguration get configuration =>
///    DependentKoreInstanceConfiguration(
///      isAsync: true,
///    );
/// }
/// ```
const asyncLazySingleton = Instance(
  isSingleton: true,
  isLazy: true,
  isAsync: true,
);
