import 'package:sample_database/domain/data/app_tab.dart';
import 'package:sample_database/domain/interactors/navigation/components/screens/route_names.dart';

// Interface for managing navigation stack
abstract class BaseNavigationStack {
  /// Adds specific route to stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object]
  /// CurrentTab is always null for global navigation
  void addRoute({
    required Object routeName,
    AppTab? currentTab,
    required bool global,
    required bool uniqueInStack,
    required bool dismissable,
    required bool needToEnsureClose,
    required bool fullScreenDialog,
    Object? id,
  });

  /// Replaces latest route in stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object]
  /// CurrentTab is always null for global navigation
  void replaceLastRoute({
    required Object routeName,
    AppTab? currentTab,
    required bool global,
    required bool uniqueInStack,
    required bool dismissable,
    required bool needToEnsureClose,
    required bool fullScreenDialog,
    Object? id,
  });

  /// Replaces whole stack with given route
  /// Route can be only screen route therefore routeName defined as [RouteNames]
  void replaceStack({
    required RouteNames routeName,
    AppTab? currentTab,
    required bool global,
    required bool uniqueInStack,
    required bool fullScreenDialog,
    Object? id,
  });

  /// Checks if specific route is already in stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object]
  /// returns true if object is not present in stack
  bool checkUnique({
    required Object routeName,
    AppTab? currentTab,
    required bool global,
  });

  /// Pops latest route from stack
  void pop(AppTab? currentTab);
}
