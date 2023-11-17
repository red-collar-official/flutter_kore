// coverage:ignore-file

import 'dart:io';

import 'package:flutter/material.dart' hide DialogRoute, ModalBottomSheetRoute;
import 'package:umvvm/arch/navigation/settings.dart';
import 'package:umvvm/arch/navigation/utilities/bottom_sheet_route.dart';
import 'package:umvvm/arch/navigation/utilities/dialog_route.dart';
import 'package:umvvm/arch/navigation/utilities/willpop_cupertino_page_route.dart';

import 'navigation_route_builder.dart';

/// Default route builder used by navigation interactor
class DefaultNavigationRouteBuilder extends NavigationRouteBuilder {
  const DefaultNavigationRouteBuilder();

  /// Pushes dialog route to [Navigator]
  @override
  PopupRoute buildDialogRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissable,
    required Widget child,
  }) =>
      DialogRoute(
        barrierDismissible: dismissable,
        barrierColor: UINavigationSettings.barrierColor,
        transitionDuration: UINavigationSettings.transitionDuration,
        pageBuilder: (
          BuildContext buildContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return _overlayRouteContainer(
            dismissable: dismissable,
            child: child,
          );
        },
      );

  /// Pushes bottom sheet route to [Navigator]
  @override
  PopupRoute buildBottomSheetRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissable,
    required Widget child,
  }) =>
      ModalBottomSheetRoute(
        builder: (BuildContext buildContext) {
          return _overlayRouteContainer(
            dismissable: dismissable,
            child: child,
          );
        },
        dismissible: dismissable,
        enableDrag: dismissable,
      );

  /// Pushes route to [Navigator]
  @override
  PageRoute buildPageRoute({
    required Widget child,
    required bool fullScreenDialog,
    required VoidCallback? onSystemPop,
  }) {
    if (Platform.isAndroid) {
      return MaterialPageRoute(
        builder: (BuildContext context) => child,
        fullscreenDialog: fullScreenDialog,
      );
    } else {
      return UICupertinoPageRoute(
        builder: (BuildContext context) => child,
        fullscreenDialog: fullScreenDialog,
        onClosedCallback:
            onSystemPop, // triggers only when used ios back gesture
      );
    }
  }

  static Widget _overlayRouteContainer({
    required bool dismissable,
    required Widget child,
  }) {
    return Builder(
      builder: (BuildContext context) {
        return PopScope(
          canPop: dismissable,
          child: child,
        );
      },
    );
  }
}
