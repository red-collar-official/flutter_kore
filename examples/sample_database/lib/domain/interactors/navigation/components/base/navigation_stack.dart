// ignore_for_file: cascade_invocations

import 'package:sample_database/domain/data/app_tab.dart';
import 'package:sample_database/domain/interactors/navigation/components/screens/routes.dart';

import 'stack/base_navigation_stack.dart';
import 'stack/global_navigation_stack.dart';
import 'stack/tab_navigation_stack.dart';

class NavigationStack {
  final globalNavigationStack = GlobalNavigationStack();
  final tabNavigationStack = TabNavigationStack();

  BaseNavigationStack _getStack(bool global) {
    return global ? globalNavigationStack : tabNavigationStack;
  }

  /// Adds specific route to stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object]
  /// CurrentTab is always null for global navigation
  void addRoute(Object routeName, AppTab? currentTab, bool global,
      bool uniqueInStack, bool dismissable) {
    final stack = _getStack(global);
    stack.addRoute(routeName, currentTab, global, uniqueInStack, dismissable);
  }

  /// Replaces whole stack with given route
  /// Route can be only screen route therefore routeName defined as [Routes]
  void replaceStack(
      Routes routeName, AppTab? currentTab, bool global, bool uniqueInStack) {
    final stack = _getStack(global);
    stack.replaceStack(routeName, currentTab, global, uniqueInStack);
  }

  /// Checks if specific route is already in stack Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object] returns true if object is not present in stack
  bool checkUnique(Object routeName, AppTab? currentTab, bool global) {
    final stack = _getStack(global);
    return stack.checkUnique(routeName, currentTab, global);
  }

  /// Pops latest route from stack
  void pop(AppTab? currentTab, bool global) {
    final stack = _getStack(global);
    return stack.pop(currentTab);
  }

  void clearTabNavigationStack() {
    tabNavigationStack.reset();
  }
}
