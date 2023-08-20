import 'package:sample_database/domain/data/app_tab.dart';
import 'package:sample_database/domain/interactors/navigation/components/base/navigation_defaults.dart';
import 'package:sample_database/domain/interactors/navigation/components/route_model.dart';
import 'package:sample_database/domain/interactors/navigation/components/screens/route_names.dart';

import 'base_navigation_stack.dart';

class GlobalNavigationStack extends BaseNavigationStack {
  /// List of all routes that are currently active globaly
  final routeStack = defaultRouteStack();

  @override
  void addRoute({
    required Object routeName,
    AppTab? currentTab,
    required bool global,
    required bool uniqueInStack,
    required bool dismissable,
    required bool needToEnsureClose,
    required bool fullScreenDialog,
    Object? id,
  }) {
    routeStack.add(
      UIRouteModel(
        name: routeName,
        settings: UIRouteSettings(
          dismissable: dismissable,
          uniqueInStack: uniqueInStack,
          needToEnsureClose: needToEnsureClose,
          fullScreenDialog: fullScreenDialog,
        ),
        id: id,
      ),
    );
  }

  @override
  void replaceLastRoute({
    required Object routeName,
    AppTab? currentTab,
    required bool global,
    required bool uniqueInStack,
    required bool dismissable,
    required bool needToEnsureClose,
    required bool fullScreenDialog,
    Object? id,
  }) {
    routeStack[routeStack.length - 1] = UIRouteModel(
      name: routeName,
      settings: UIRouteSettings(
        dismissable: dismissable,
        uniqueInStack: uniqueInStack,
        needToEnsureClose: needToEnsureClose,
        fullScreenDialog: fullScreenDialog,
      ),
      id: id,
    );
  }

  @override
  bool checkUnique({
    required Object routeName,
    AppTab? currentTab,
    required bool global,
  }) {
    return routeStack.indexWhere((element) => element.name == routeName) == -1;
  }

  @override
  void replaceStack({
    required RouteNames routeName,
    AppTab? currentTab,
    required bool global,
    required bool uniqueInStack,
    required bool fullScreenDialog,
    Object? id,
  }) {
    routeStack
      ..clear()
      ..add(
        UIRouteModel(
          name: routeName,
          settings: UIRouteSettings(
            dismissable: false,
            uniqueInStack: uniqueInStack,
            fullScreenDialog: fullScreenDialog,
          ),
          id: id,
        ),
      );
  }

  @override
  void pop(AppTab? currentTab) {
    routeStack.removeLast();
  }
}
