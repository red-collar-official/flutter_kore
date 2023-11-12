import 'package:umvvm/arch/navigation/model/route_model.dart';

import 'base_navigation_stack.dart';

/// Navigation stack implementation for tab navigation hisrory
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
    required UIRouteSettings settings,
  }) {
    try {
      _tabRouteStack[currentTab]!.add(UIRouteModel(
        name: routeName,
        settings: settings,
      ));
    } catch (e) {
      // ignore
    }
  }

  @override
  void replaceLastRoute({
    required dynamic routeName,
    AppTabType? currentTab,
    required UIRouteSettings settings,
  }) {
    try {
      final stack = _tabRouteStack[currentTab]!;

      stack[stack.length - 1] = UIRouteModel(
        name: routeName,
        settings: settings,
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
    required UIRouteSettings settings,
  }) {
    if (tab == null) {
      return;
    }

    _tabRouteStack[tab] = [
      UIRouteModel(
        name: routeName,
        settings: settings,
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
