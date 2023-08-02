import 'package:sample_database/domain/data/app_tab.dart';
import 'package:sample_database/domain/interactors/navigation/components/base/navigation_defaults.dart';
import 'package:sample_database/domain/interactors/navigation/components/route_model.dart';
import 'package:sample_database/domain/interactors/navigation/components/screens/routes.dart';

import 'base_navigation_stack.dart';

class TabNavigationStack extends BaseNavigationStack {
  /// Map of all routes that are currently active in tabs
  final tabRouteStack = defaultTabRouteStack();

  @override
  void addRoute({
    required Object routeName,
    AppTab? currentTab,
    required bool global,
    required bool uniqueInStack,
    required bool dismissable,
    required bool needToEnsureClose,
    Object? id,
  }) {
    try {
      tabRouteStack[currentTab]!.add(RouteModel(
        name: routeName,
        dismissable: dismissable,
        uniqueInStack: uniqueInStack,
        needToEnsureClose: needToEnsureClose,
        id: id,
      ));
    } catch (e) {
      // ignore
    }
  }

  @override
  void replaceLastRoute({
    required Object routeName,
    AppTab? currentTab,
    required bool global,
    required bool uniqueInStack,
    required bool dismissable,
    required bool needToEnsureClose,
    Object? id,
  }) {
    try {
      final stack = tabRouteStack[currentTab]!;

      stack[stack.length - 1] = RouteModel(
        name: routeName,
        dismissable: dismissable,
        uniqueInStack: uniqueInStack,
        needToEnsureClose: needToEnsureClose,
        id: id,
      );
    } catch (e) {
      // ignore
    }
  }

  @override
  bool checkUnique({
    required Object routeName,
    AppTab? currentTab,
    required bool global,
  }) {
    if (currentTab == null) {
      return false;
    }

    return tabRouteStack[currentTab.name]!
            .indexWhere((element) => element.name == routeName) ==
        -1;
  }

  @override
  void replaceStack({
    required Routes routeName,
    AppTab? currentTab,
    required bool global,
    required bool uniqueInStack,
    Object? id,
  }) {
    if (currentTab == null) {
      return;
    }

    tabRouteStack[currentTab] = [
      RouteModel(
        name: routeName,
        dismissable: false,
        uniqueInStack: uniqueInStack,
        id: id,
      ),
    ];
  }

  @override
  void pop(AppTab? currentTab) {
    tabRouteStack[currentTab]!.removeLast();
  }

  void reset() {
    tabRouteStack
      ..clear()
      ..addAll(defaultTabRouteStack());
  }
}
