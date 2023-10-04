// ignore_for_file: cascade_invocations

import 'package:umvvm/arch/navigation/base/model/route_model.dart';
import 'package:umvvm/arch/navigation/base/stack/base_navigation_stack.dart';

import 'stack/global_navigation_stack.dart';
import 'stack/tab_navigation_stack.dart';

class NavigationStack<AppTabType> {
  /// Map of all routes that are currently active in tabs
  final Map<AppTabType, List<UIRouteModel>> Function() tabRouteStack;

  /// Map of all routes that are currently active in tabs
  final List<UIRouteModel> Function() routeStack;

  NavigationStack({
    required this.tabRouteStack,
    required this.routeStack,
  });

  late final globalNavigationStack = GlobalNavigationStack<AppTabType>(
    routeStack: routeStack,
  );

  late final tabNavigationStack = TabNavigationStack<AppTabType>(
    tabRouteStack: tabRouteStack,
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
    AppTabType? currentTab,
    required bool global,
    required bool uniqueInStack,
    required bool dismissable,
    required bool needToEnsureClose,
    required bool fullScreenDialog,
    Object? id,
  }) {
    final stack = _getStack(global);

    stack.addRoute(
      routeName: routeName,
      currentTab: currentTab,
      global: global,
      uniqueInStack: uniqueInStack,
      dismissable: dismissable,
      needToEnsureClose: needToEnsureClose,
      id: id,
      fullScreenDialog: fullScreenDialog,
    );
  }

  /// Replaces latest route in stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object]
  /// CurrentTab is always null for global navigation
  void replaceLastRoute({
    required dynamic routeName,
    AppTabType? currentTab,
    required bool global,
    required bool uniqueInStack,
    required bool dismissable,
    required bool needToEnsureClose,
    required bool fullScreenDialog,
    Object? id,
  }) {
    final stack = _getStack(global);

    stack.replaceLastRoute(
      routeName: routeName,
      currentTab: currentTab,
      global: global,
      uniqueInStack: uniqueInStack,
      dismissable: dismissable,
      needToEnsureClose: needToEnsureClose,
      fullScreenDialog: fullScreenDialog,
      id: id,
    );
  }

  /// Replaces whole stack with given route
  /// Route can be only screen route therefore routeName defined as [RouteNames]
  void replaceStack({
    required dynamic routeName,
    AppTabType? currentTab,
    required bool global,
    required bool uniqueInStack,
    required bool fullScreenDialog,
    Object? id,
  }) {
    final stack = _getStack(global);
    stack.replaceStack(
      routeName: routeName,
      currentTab: currentTab,
      global: global,
      uniqueInStack: uniqueInStack,
      id: id,
      fullScreenDialog: fullScreenDialog,
    );
  }

  /// Checks if specific route is already in stack Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object] returns true if object is not present in stack
  bool checkUnique({
    required dynamic routeName,
    AppTabType? currentTab,
    required bool global,
  }) {
    final stack = _getStack(global);

    return stack.checkUnique(
      routeName: routeName,
      currentTab: currentTab,
      global: global,
    );
  }

  /// Pops latest route from stack
  void pop(AppTabType? currentTab, bool global) {
    final stack = _getStack(global);

    return stack.pop(currentTab);
  }

  void clearTabNavigationStack() {
    tabNavigationStack.reset();
  }
}
