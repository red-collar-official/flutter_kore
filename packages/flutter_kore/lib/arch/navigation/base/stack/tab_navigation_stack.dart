import 'package:flutter_kore/flutter_kore.dart';

import 'base_navigation_stack.dart';

/// Navigation stack implementation for tab navigation hisrory
class TabNavigationStack<AppTabType> extends BaseNavigationStack<AppTabType> {
  /// Map of all routes that are currently active in tabs
  final Map<AppTabType, List<UIRouteModel>> Function() tabRouteStackBuilder;

  late final Observable<Map<AppTabType, List<UIRouteModel>>> _tabRouteStack =
      Observable.initial(
    tabRouteStackBuilder(),
  );

  TabNavigationStack({
    required this.tabRouteStackBuilder,
  });

  Map<AppTabType, List<UIRouteModel>> get stack => _tabRouteStack.current ?? {};

  Stream<Map<AppTabType, List<UIRouteModel>>> get stackStream =>
      _tabRouteStack.stream.map(
        (event) => event.next ?? {},
      );

  @override
  void addRoute({
    required dynamic routeName,
    AppTabType? tab,
    required UIRouteSettings settings,
  }) {
    if (tab == null) {
      return;
    }

    final current = Map<AppTabType, List<UIRouteModel>>.from(stack);

    if (current.containsKey(tab)) {
      final currentList = List<UIRouteModel>.from(current[tab] ?? []);

      // ignore: cascade_invocations
      currentList.add(UIRouteModel(
        name: routeName,
        settings: settings,
      ));

      current[tab] = currentList;
    }

    _tabRouteStack.update(current);
  }

  @override
  void replaceLastRoute({
    required dynamic routeName,
    AppTabType? tab,
    required UIRouteSettings settings,
  }) {
    if (tab == null) {
      return;
    }

    final current = Map<AppTabType, List<UIRouteModel>>.from(stack);

    if (current.containsKey(tab)) {
      final currentList = List<UIRouteModel>.from(current[tab] ?? []);

      currentList[currentList.length - 1] = UIRouteModel(
        name: routeName,
        settings: settings,
      );

      current[tab] = currentList;
    }

    _tabRouteStack.update(current);
  }

  @override
  bool checkUnique({
    required dynamic routeName,
    AppTabType? tab,
    required bool global,
  }) {
    if (tab == null) {
      return false;
    }

    return stack[tab]!.indexWhere((element) => element.name == routeName) == -1;
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

    final current = Map<AppTabType, List<UIRouteModel>>.from(stack);

    current[tab] = [
      UIRouteModel(
        name: routeName,
        settings: settings,
      ),
    ];

    _tabRouteStack.update(current);
  }

  @override
  void pop(AppTabType? tab) {
    if (tab == null) {
      return;
    }

    final current = Map<AppTabType, List<UIRouteModel>>.from(stack);

    if (current.containsKey(tab)) {
      final currentList = List<UIRouteModel>.from(current[tab] ?? []);

      // ignore: cascade_invocations
      currentList.removeLast();

      current[tab] = currentList;
    }

    _tabRouteStack.update(current);
  }

  void reset() {
    _tabRouteStack.update(tabRouteStackBuilder());
  }
}
