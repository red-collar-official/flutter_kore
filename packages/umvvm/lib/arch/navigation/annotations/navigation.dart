/// Annotation to mark app navigation interactor
///
/// ```dart
/// @singleton
/// @AppNavigation(tabs: AppTab, deepLinks: DeepLinksInteractor)
/// class NavigationInteractor extends NavigationInteractorDeclaration<NavigationState> {
///   // navigation code...
/// }
/// ```
class AppNavigation {
  const AppNavigation({
    this.deepLinks,
    this.tabs,
  });

  /// Deeplinks interactor type that
  /// will be used by this navigation interactor
  final Type? deepLinks;

  /// Flag indicating that app contains tab navigation
  final Type? tabs;
}

/// Annotation to mark app navigation interactor
///
/// ```dart
/// @singleton
/// @AppNavigation(tabs: AppTab, deepLinks: DeepLinksInteractor)
/// class NavigationInteractor extends NavigationInteractorDeclaration<NavigationState> {
///   // navigation code...
/// }
/// ```
const appNavigation = AppNavigation();
