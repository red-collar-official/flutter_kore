// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:umvvm/arch/navigation/base/default_navigation_route_builder.dart';

/// Class describing how to open app routes
abstract class NavigationRouteBuilder {
  const NavigationRouteBuilder();

  /// Default route builder for app
  NavigationRouteBuilder get defaultRouteBuilder =>
      const DefaultNavigationRouteBuilder();

  /// Pushes dialog route to [Navigator]
  Future<Object?>? pushDialogRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissable,
    required Widget child,
    required VoidCallback pop,
  }) async {
    return defaultRouteBuilder.pushDialogRoute(
      navigator: navigator,
      dismissable: dismissable,
      child: child,
      pop: pop,
    );
  }

  /// Pushes bottom sheet route to [Navigator]
  Future? pushBottomSheetRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissable,
    required Widget child,
    required VoidCallback pop,
  }) async {
    return defaultRouteBuilder.pushBottomSheetRoute(
      navigator: navigator,
      dismissable: dismissable,
      child: child,
      pop: pop,
    );
  }

  /// Pushes route to [Navigator]
  PageRoute buildPageRoute({
    required Widget child,
    required bool fullScreenDialog,
    required VoidCallback? onClosed,
    required Future<void> Function()? onWillPop,
  }) {
    return defaultRouteBuilder.buildPageRoute(
      fullScreenDialog: fullScreenDialog,
      onClosed: onClosed,
      child: child,
      onWillPop: onWillPop,
    );
  }
}
