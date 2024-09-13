import 'package:umvvm/arch/navigation/base/navigation_stack.dart';
import 'package:umvvm/umvvm.dart';

/// Class describing app navigation settings
///
/// Example:
///
/// ```dart
/// NavigationInteractorSettings(
///   initialRoute: RouteNames.home,
///   tabs: AppTabs.tabs,
///   tabViewHomeRoute: RouteNames.home,
///   initialTabRoutes: {
///      AppTabs.posts: RouteNames.posts,
///      AppTabs.likedPosts: RouteNames.likedPosts,
///   },
///   appContainsTabNavigation: true,
/// );
/// ```
class NavigationInteractorSettings<AppTabType, RouteType, DialogType,
    BottomSheetType> {
  /// Initial route of whole app
  /// Used to initialize [NavigationStack]
  final RouteType initialRoute;

  // coverage:ignore-start

  /// Initial route of every tab in app
  final Map<AppTabType, RouteType>? initialTabRoutes;

  /// Name of route that contains tab view for tab navigators
  final RouteType? tabViewHomeRoute;

  /// List of all tabs in app
  final List<AppTabType>? tabs;

  // coverage:ignore-end

  /// Flag indicating that app contains tab views with inner navigators
  final bool appContainsTabNavigation;

  /// Flag indicating that app dialogs and botttom sheets
  /// using [BaseNavigationInteractor.globalNavigatorKey] instead of separate [BaseNavigationInteractor.bottomSheetDialogNavigatorKey]
  ///
  /// Set it to false if you want separate navigator for bottom sheets and dialogs
  final bool bottomSheetsAndDialogsUsingGlobalNavigator;

  /// Route builder for navigation interactor
  final NavigationRouteBuilder routeBuilder;

  const NavigationInteractorSettings({
    required this.initialRoute,
    this.initialTabRoutes,
    this.tabViewHomeRoute,
    this.tabs,
    this.appContainsTabNavigation = false,
    this.bottomSheetsAndDialogsUsingGlobalNavigator = true,
    this.routeBuilder = const DefaultNavigationRouteBuilder(),
  });
}
