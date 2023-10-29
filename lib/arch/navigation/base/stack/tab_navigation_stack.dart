import 'package:umvvm/arch/navigation/base/model/route_model.dart';

import 'base_navigation_stack.dart';

class TabNavigationStack<AppTabType> extends BaseNavigationStack<AppTabType> {
  /// Map of all routes that are currently active in tabs
  final Map<AppTabType, List<UIRouteModel>> Function() tabRouteStackBuilder;

  late final Map<AppTabType, List<UIRouteModel>> _tabRouteStack =
      tabRouteStackBuilder();

  TabNavigationStack({
    required this.tabRouteStackBuilder,
  });

  Map<AppTabType, List<UIRouteModel>> get stack => _tabRouteStack;

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
    try {
      _tabRouteStack[currentTab]!.add(UIRouteModel(
        name: routeName,
        settings: UIRouteSettings(
          dismissable: dismissable,
          uniqueInStack: uniqueInStack,
          needToEnsureClose: needToEnsureClose,
          fullScreenDialog: fullScreenDialog,
        ),
        id: id,
      ));
    } catch (e) {
      // ignore
    }
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
    try {
      final stack = _tabRouteStack[currentTab]!;

      stack[stack.length - 1] = UIRouteModel(
        name: routeName,
        settings: UIRouteSettings(
          dismissable: dismissable,
          uniqueInStack: uniqueInStack,
          needToEnsureClose: needToEnsureClose,
          fullScreenDialog: fullScreenDialog,
        ),
        id: id,
      );
    } catch (e) {
      // ignore
    }
  }

  @override
  bool checkUnique({
    required dynamic routeName,
    AppTabType? currentTab,
    required bool global,
  }) {
    if (currentTab == null) {
      return false;
    }

    return _tabRouteStack[currentTab]!
            .indexWhere((element) => element.name == routeName) ==
        -1;
  }

  @override
  void replaceStack({
    required dynamic routeName,
    AppTabType? tab,
    required bool global,
    required bool uniqueInStack,
    required bool fullScreenDialog,
    Object? id,
  }) {
    if (tab == null) {
      return;
    }

    _tabRouteStack[tab] = [
      UIRouteModel(
        name: routeName,
        settings: UIRouteSettings(
          dismissable: false,
          uniqueInStack: uniqueInStack,
          fullScreenDialog: fullScreenDialog,
        ),
        id: id,
      ),
    ];
  }

  @override
  void pop(AppTabType? currentTab) {
    _tabRouteStack[currentTab]!.removeLast();
  }

  void reset() {
    _tabRouteStack
      ..clear()
      ..addAll(tabRouteStackBuilder());
  }
}
