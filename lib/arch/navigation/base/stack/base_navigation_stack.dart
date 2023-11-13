// Interface for managing navigation stack
import 'package:umvvm/umvvm.dart';

/// Abstract class describing interface for navigation stack
abstract class BaseNavigationStack<AppTabType> {
  /// Adds specific route to stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [dynamic]
  /// CurrentTab is always null for global navigation
  void addRoute({
    required dynamic routeName,
    AppTabType? tab,
    required UIRouteSettings settings,
  });

  /// Replaces latest route in stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [dynamic]
  /// CurrentTab is always null for global navigation
  void replaceLastRoute({
    required dynamic routeName,
    AppTabType? tab,
    required UIRouteSettings settings,
  });

  /// Replaces whole stack with given route
  /// Route can be only screen route therefore routeName defined as [RouteNames]
  void replaceStack({
    required dynamic routeName,
    AppTabType? tab,
    required UIRouteSettings settings,
  });

  /// Checks if specific route is already in stack
  /// Can be screen route, dialog route or bottom sheet route
  /// Therefore route name is [dynamic]
  /// returns true if object is not present in stack
  bool checkUnique({
    required dynamic routeName,
    AppTabType? tab,
    required bool global,
  });

  /// Pops latest route from stack
  void pop(AppTabType? currentTab);
}
