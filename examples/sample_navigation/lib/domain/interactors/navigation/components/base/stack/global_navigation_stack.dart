import 'package:sample_navigation/domain/data/app_tab.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/base/navigation_defaults.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/route_model.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/routes.dart';

import 'base_navigation_stack.dart';

class GlobalNavigationStack extends BaseNavigationStack {
  /// List of all routes that are currently active globaly
  final routeStack = defaultRouteStack();

  @override
  void addRoute(
    Object routeName,
    AppTab? currentTab,
    bool global,
    bool uniqueInStack,
    bool dismissable,
    bool needToEnsureClose,
  ) {
    routeStack.add(
      RouteModel(
        name: routeName,
        dismissable: dismissable,
        uniqueInStack: uniqueInStack,
        needToEnsureClose: needToEnsureClose,
      ),
    );
  }

  @override
  void replaceLastRoute(
    Object routeName,
    AppTab? currentTab,
    bool global,
    bool uniqueInStack,
    bool dismissable,
    bool needToEnsureClose,
  ) {
    routeStack[routeStack.length - 1] = RouteModel(
      name: routeName,
      dismissable: dismissable,
      uniqueInStack: uniqueInStack,
      needToEnsureClose: needToEnsureClose,
    );
  }

  @override
  bool checkUnique(Object routeName, AppTab? currentTab, bool global) {
    return routeStack.indexWhere((element) => element.name == routeName) == -1;
  }

  @override
  void replaceStack(
    Routes routeName,
    AppTab? currentTab,
    bool global,
    bool uniqueInStack,
  ) {
    routeStack
      ..clear()
      ..add(
        RouteModel(
          name: routeName,
          dismissable: false,
          uniqueInStack: uniqueInStack,
        ),
      );
  }

  @override
  void pop(AppTab? currentTab) {
    routeStack.removeLast();
  }
}
