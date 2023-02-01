// Interface for managing navigation stack
import 'package:sample_database/domain/data/app_tab.dart';
import 'package:sample_database/domain/interactors/navigation/components/screens/routes.dart';

abstract class BaseNavigationStack {
  /// Adds specific route to stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object]
  /// CurrentTab is always null for global navigation
  void addRoute(Object routeName, AppTab? currentTab, bool global,
      bool uniqueInStack, bool dismissable);

  /// Replaces whole stack with given route
  /// Route can be only screen route therefore routeName defined as [Routes]
  void replaceStack(
      Routes routeName, AppTab? currentTab, bool global, bool uniqueInStack);

  /// Checks if specific route is already in stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [Object]
  /// returns true if object is not present in stack
  bool checkUnique(Object routeName, AppTab? currentTab, bool global);

  /// Pops latest route from stack
  void pop(AppTab? currentTab);
}
