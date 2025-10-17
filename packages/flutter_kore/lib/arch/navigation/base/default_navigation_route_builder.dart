// coverage:ignore-file

import 'package:flutter/material.dart' hide DialogRoute, ModalBottomSheetRoute;
import 'package:flutter_kore/arch/navigation/settings.dart';
import 'package:flutter_kore/arch/navigation/utilities/bottom_sheet_route.dart';
import 'package:flutter_kore/arch/navigation/utilities/dialog_route.dart';
import 'package:flutter_kore/arch/navigation/utilities/willpop_cupertino_page_route.dart';
import 'package:universal_platform/universal_platform.dart';

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
    required VoidCallback? onPop,
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
            onPop: onPop,
          );
        },
      );

  /// Pushes bottom sheet route to [Navigator]
  @override
  PopupRoute buildBottomSheetRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissable,
    required Widget child,
    required VoidCallback? onPop,
  }) =>
      ModalBottomSheetRoute(
        builder: (BuildContext buildContext) {
          return _overlayRouteContainer(
            dismissable: dismissable,
            child: child,
            onPop: onPop,
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
    if (UniversalPlatform.isAndroid) {
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

  Widget _overlayRouteContainer({
    required bool dismissable,
    required Widget child,
    required VoidCallback? onPop,
  }) {
    return Builder(
      builder: (BuildContext context) {
        return PopScope(
          canPop: dismissable,
          child: child,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop || onPop == null) {
              return;
            }

            onPop();
          },
        );
      },
    );
  }
}
