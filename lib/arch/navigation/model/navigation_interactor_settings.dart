/// Class describing app navigation settings
class NavigationInteractorSettings<AppTabType, RouteType, DialogType,
    BottomSheetType> {
  /// Initial route of whole app
  /// Used to initialize [navigationStack]
  final RouteType initialRoute;

  // coverage:ignore-start

  /// Initial route of every tab in app
  final Map<AppTabType, RouteType>? initialTabRoutes;

  /// Name of route that contains tab view for tab navigators
  final RouteType? tabViewHomeRoute;

  /// Base url for links generated to routes
  final String? baseLinkUrl;

  /// List of all tabs in app
  final List<AppTabType>? tabs;

  // coverage:ignore-end

  /// Flag indicating that app contains tab views with inner navigators
  final bool appContainsTabNavigation;

  /// Flag indicating that app dialogs and botttom sheets
  /// using [globalNavigatorKey] instead of separate [bottomSheetDialogNavigatorKey]
  /// Set it to false if you want separate navigator for bottom sheets and dialogs
  final bool bottomSheetsAndDialogsUsingSameNavigator;

  NavigationInteractorSettings({
    required this.initialRoute,
    this.initialTabRoutes,
    this.tabViewHomeRoute,
    this.baseLinkUrl,
    this.tabs,
    this.appContainsTabNavigation = false,
    this.bottomSheetsAndDialogsUsingSameNavigator = true,
  });
}
