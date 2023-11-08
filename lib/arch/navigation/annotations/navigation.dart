/// Annotation to mark app navigation interactor
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
const appNavigation = AppNavigation();
