// coverage:ignore-file

import 'package:material_ui/material_ui.dart' hide DialogRoute, ModalBottomSheetRoute;
import 'package:flutter_kore/arch/navigation/settings.dart';
import 'package:flutter_kore/arch/navigation/utilities/bottom_sheet_route.dart';
import 'package:flutter_kore/arch/navigation/utilities/dialog_route.dart';
import 'package:flutter_kore/arch/navigation/utilities/page_routes.dart';
import 'package:universal_platform/universal_platform.dart';

import 'navigation_route_builder.dart';

/// Default route builder used by navigation interactor
class DefaultNavigationRouteBuilder extends NavigationRouteBuilder {
  const DefaultNavigationRouteBuilder();

  /// Pushes dialog route to [Navigator]
  @override
  PopupRoute buildDialogRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissible,
    required Widget child,
    required VoidCallback? onPop,
  }) => DialogRoute(
    barrierDismissible: dismissible,
    barrierColor: UINavigationSettings.barrierColor,
    transitionDuration: UINavigationSettings.transitionDuration,
    pageBuilder:
        (
          BuildContext buildContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return _overlayRouteContainer(
            dismissible: dismissible,
            child: child,
            onPop: onPop,
          );
        },
  );

  /// Pushes bottom sheet route to [Navigator]
  @override
  PopupRoute buildBottomSheetRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissible,
    required Widget child,
    required VoidCallback? onPop,
  }) => ModalBottomSheetRoute(
    builder: (BuildContext buildContext) {
      return _overlayRouteContainer(
        dismissible: dismissible,
        child: child,
        onPop: onPop,
      );
    },
    dismissible: dismissible,
    enableDrag: dismissible,
  );

  /// Pushes route to [Navigator]
  @override
  PageRoute buildPageRoute({
    required Widget child,
    required bool fullScreenDialog,
    required VoidCallback? onSystemPop,
  }) {
    // onSystemPop triggers only when system back gesture is used
    if (UniversalPlatform.isAndroid) {
      return UIMaterialPageRoute(
        builder: (BuildContext context) => child,
        fullscreenDialog: fullScreenDialog,
        onSystemPop: onSystemPop,
      );
    } else {
      return UICupertinoPageRoute(
        builder: (BuildContext context) => child,
        fullscreenDialog: fullScreenDialog,
        onSystemPop: onSystemPop,
      );
    }
  }

  Widget _overlayRouteContainer({
    required bool dismissible,
    required Widget child,
    required VoidCallback? onPop,
  }) {
    return Builder(
      builder: (BuildContext context) {
        return PopScope(
          canPop: dismissible,
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
