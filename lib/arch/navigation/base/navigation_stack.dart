// ignore_for_file: cascade_invocations

import 'package:umvvm/arch/navigation/model/route_model.dart';
import 'package:umvvm/arch/navigation/base/stack/base_navigation_stack.dart';

import 'stack/global_navigation_stack.dart';
import 'stack/tab_navigation_stack.dart';

/// Class that holds navigation history for Navigation interactors
class NavigationStack<AppTabType> {
  /// Map of all routes that are currently active in tabs
  final Map<AppTabType, List<UIRouteModel>> Function() tabRouteStack;

  /// Map of all routes that are currently active in tabs
  final List<UIRouteModel> Function() routeStack;

  NavigationStack({
    required this.tabRouteStack,
    required this.routeStack,
  });

  /// Global navigation history
  late final globalNavigationStack = GlobalNavigationStack<AppTabType>(
    routeStackBuilder: routeStack,
  );

  /// Tab navigation history
  late final tabNavigationStack = TabNavigationStack<AppTabType>(
    tabRouteStackBuilder: tabRouteStack,
  );

  BaseNavigationStack _getStack(bool global) {
    return global ? globalNavigationStack : tabNavigationStack;
  }

  /// Adds specific route to stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object]
  /// CurrentTab is always null for global navigation
  void addRoute({
    required dynamic routeName,
    AppTabType? tab,
    required UIRouteSettings settings,
  }) {
    final stack = _getStack(settings.global);

    stack.addRoute(
      routeName: routeName,
      tab: tab,
      settings: settings,
    );
  }

  /// Replaces latest route in stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object]
  /// CurrentTab is always null for global navigation
  void replaceLastRoute({
    required dynamic routeName,
    AppTabType? tab,
    required UIRouteSettings settings,
  }) {
    final stack = _getStack(settings.global);

    stack.replaceLastRoute(
      routeName: routeName,
      tab: tab,
      settings: settings,
    );
  }

  /// Replaces whole stack with given route
  /// Route can be only screen route therefore routeName defined as [RouteNames]
  void replaceStack({
    required dynamic routeName,
    AppTabType? tab,
    required UIRouteSettings settings,
  }) {
    final stack = _getStack(settings.global);
    
    stack.replaceStack(
      routeName: routeName,
      tab: tab,
      settings: settings,
    );
  }

  /// Checks if specific route is already in stack Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object] returns true if object is not present in stack
  bool checkUnique({
    required dynamic routeName,
    AppTabType? tab,
    required bool global,
  }) {
    final stack = _getStack(global);

    return stack.checkUnique(
      routeName: routeName,
      tab: tab,
      global: global,
    );
  }

  /// Pops latest route from stack
  void pop(AppTabType? currentTab, bool global) {
    final stack = _getStack(global);

    return stack.pop(currentTab);
  }

  /// Clears tab navigation stack
  void clearTabNavigationStack() {
    tabNavigationStack.reset();
  }
}
