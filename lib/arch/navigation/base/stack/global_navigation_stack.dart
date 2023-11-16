import 'package:umvvm/umvvm.dart';

import 'base_navigation_stack.dart';

/// Navigation stack implementation for global navigation hisrory
class GlobalNavigationStack<AppTabType>
    extends BaseNavigationStack<AppTabType> {
  /// Map of all routes that are currently active in tabs
  final List<UIRouteModel> Function() routeStackBuilder;

  late final Observable<List<UIRouteModel>> _routeStack = Observable.initial(
    routeStackBuilder(),
  );

  GlobalNavigationStack({
    required this.routeStackBuilder,
  });

  List<UIRouteModel> get stack => _routeStack.current ?? [];

  Stream<List<UIRouteModel>> get stackStream => _routeStack.stream.map(
        (event) => event.next ?? [],
      );

  @override
  void addRoute({
    required dynamic routeName,
    AppTabType? tab,
    required UIRouteSettings settings,
  }) {
    final current = List<UIRouteModel>.from(stack);

    // ignore: cascade_invocations
    current.add(
      UIRouteModel(
        name: routeName,
        settings: settings,
      ),
    );

    _routeStack.update(current);
  }

  @override
  void replaceLastRoute({
    required dynamic routeName,
    AppTabType? tab,
    required UIRouteSettings settings,
  }) {
    final current = List<UIRouteModel>.from(stack);

    // ignore: cascade_invocations
    current[current.length - 1] = UIRouteModel(
      name: routeName,
      settings: settings,
    );

    _routeStack.update(current);
  }

  @override
  bool checkUnique({
    required dynamic routeName,
    AppTabType? tab,
    required bool global,
  }) {
    return stack.indexWhere((element) => element.name == routeName) == -1;
  }

  @override
  void replaceStack({
    required dynamic routeName,
    AppTabType? tab,
    required UIRouteSettings settings,
  }) {
    _routeStack.update([
      UIRouteModel(
        name: routeName,
        settings: settings,
      ),
    ]);
  }

  @override
  void pop(AppTabType? tab) {
    final current = List<UIRouteModel>.from(stack);

    // ignore: cascade_invocations
    current.removeLast();

    _routeStack.update(current);
  }
}
