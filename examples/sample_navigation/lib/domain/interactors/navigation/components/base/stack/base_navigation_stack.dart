import 'package:sample_navigation/domain/data/app_tab.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/routes.dart';

// Interface for managing navigation stack
abstract class BaseNavigationStack {
  /// Adds specific route to stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object]
  /// CurrentTab is always null for global navigation
  void addRoute(
    Object routeName,
    AppTab? currentTab,
    bool global,
    bool uniqueInStack,
    bool dismissable,
    bool needToEnsureClose,
  );

  /// Replaces latest route in stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object]
  /// CurrentTab is always null for global navigation
  void replaceLastRoute(
    Object routeName,
    AppTab? currentTab,
    bool global,
    bool uniqueInStack,
    bool dismissable,
    bool needToEnsureClose,
  );

  /// Replaces whole stack with given route
  /// Route can be only screen route therefore routeName defined as [Routes]
  void replaceStack(
    Routes routeName,
    AppTab? currentTab,
    bool global,
    bool uniqueInStack,
  );

  /// Checks if specific route is already in stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object]
  /// returns true if object is not present in stack
  bool checkUnique(
    Object routeName,
    AppTab? currentTab,
    bool global,
  );

  /// Pops latest route from stack
  void pop(AppTab? currentTab);
}
