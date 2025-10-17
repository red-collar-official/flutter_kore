// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:flutter_kore/arch/navigation/base/default_navigation_route_builder.dart';

/// Class describing how to open app routes
/// You can override builders for bottom sheets, dialogs and routes
abstract class NavigationRouteBuilder {
  const NavigationRouteBuilder();

  /// Default route builder for app
  NavigationRouteBuilder get defaultRouteBuilder =>
      const DefaultNavigationRouteBuilder();

  /// Pushes dialog route to [Navigator]
  PopupRoute buildDialogRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissable,
    required Widget child,
    required VoidCallback? onPop,
  }) {
    return defaultRouteBuilder.buildDialogRoute(
      navigator: navigator,
      dismissable: dismissable,
      child: child,
      onPop: onPop,
    );
  }

  /// Pushes bottom sheet route to [Navigator]
  PopupRoute buildBottomSheetRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissable,
    required Widget child,
    required VoidCallback? onPop,
  }) {
    return defaultRouteBuilder.buildBottomSheetRoute(
      navigator: navigator,
      dismissable: dismissable,
      child: child,
      onPop: onPop,
    );
  }

  /// Pushes route to [Navigator]
  PageRoute buildPageRoute({
    required Widget child,
    required bool fullScreenDialog,
    required VoidCallback? onSystemPop,
  }) {
    return defaultRouteBuilder.buildPageRoute(
      fullScreenDialog: fullScreenDialog,
      onSystemPop: onSystemPop,
      child: child,
    );
  }
}
