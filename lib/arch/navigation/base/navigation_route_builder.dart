// coverage:ignore-file

import 'package:flutter/material.dart';

/// Class describing how to open app routes
abstract class NavigationRouteBuilder {
  const NavigationRouteBuilder();

  /// Pushes dialog route to [Navigator]
  Future<Object?>? pushDialogRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissable,
    required Widget child,
    required VoidCallback pop,
  });

  /// Pushes bottom sheet route to [Navigator]
  Future? pushBottomSheetRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissable,
    required Widget child,
    required VoidCallback pop,
  });

  /// Pushes route to [Navigator]
  PageRoute buildPageRoute({
    required Widget child,
    required bool fullScreenDialog,
    required VoidCallback? onClosed,
    required Future<void> Function()? onWillPop,
  });
}
