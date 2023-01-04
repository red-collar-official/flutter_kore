import 'package:sample_navigation/domain/data/app_tab.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/base/navigation_defaults.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/route_model.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/routes.dart';

import 'base_navigation_stack.dart';

class TabNavigationStack extends BaseNavigationStack {
  /// Map of all routes that are currently active in tabs
  final tabRouteStack = defaultTabRouteStack;

  @override
  void addRoute(Object routeName, AppTab? currentTab, bool global,
      bool uniqueInStack, bool dismissable) {
    tabRouteStack[currentTab]!.add(RouteModel(
      name: routeName,
      dismissable: dismissable,
      uniqueInStack: uniqueInStack,
    ));
  }

  @override
  bool checkUnique(Object routeName, AppTab? currentTab, bool global) {
    if (currentTab == null) {
      return false;
    }

    return tabRouteStack[currentTab.name]!
            .indexWhere((element) => element.name == routeName) ==
        -1;
  }

  @override
  void replaceStack(
      Routes routeName, AppTab? currentTab, bool global, bool uniqueInStack) {
    if (currentTab == null) {
      return;
    }

    tabRouteStack[currentTab] = [
      RouteModel(
        name: routeName,
        dismissable: false,
        uniqueInStack: uniqueInStack,
      ),
    ];
  }

  @override
  void pop(AppTab? currentTab) {
    tabRouteStack[currentTab]!.removeLast();
  }
}
