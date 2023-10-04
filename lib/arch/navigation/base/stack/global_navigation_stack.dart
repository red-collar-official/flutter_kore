import 'package:umvvm/arch/navigation/base/model/route_model.dart';

import 'base_navigation_stack.dart';

class GlobalNavigationStack<AppTabType>
    extends BaseNavigationStack<AppTabType> {
  /// Map of all routes that are currently active in tabs
  final List<UIRouteModel> Function() routeStack;

  late final List<UIRouteModel> _routeStack = routeStack();

  GlobalNavigationStack({
    required this.routeStack,
  });

  List<UIRouteModel> get stack => _routeStack;

  @override
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
    _routeStack.add(
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
    required dynamic routeName,
    AppTabType? currentTab,
    required bool global,
    required bool uniqueInStack,
    required bool dismissable,
    required bool needToEnsureClose,
    required bool fullScreenDialog,
    Object? id,
  }) {
    _routeStack[_routeStack.length - 1] = UIRouteModel(
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
    required dynamic routeName,
    AppTabType? currentTab,
    required bool global,
  }) {
    return _routeStack.indexWhere((element) => element.name == routeName) == -1;
  }

  @override
  void replaceStack({
    required dynamic routeName,
    AppTabType? currentTab,
    required bool global,
    required bool uniqueInStack,
    required bool fullScreenDialog,
    Object? id,
  }) {
    _routeStack
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
  void pop(AppTabType? currentTab) {
    _routeStack.removeLast();
  }
}
