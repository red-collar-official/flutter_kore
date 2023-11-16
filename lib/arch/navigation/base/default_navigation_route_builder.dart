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
    required VoidCallback pop,
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
            pop: pop,
          );
        },
      );

  /// Pushes bottom sheet route to [Navigator]
  @override
  PopupRoute buildBottomSheetRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissable,
    required Widget child,
    required VoidCallback pop,
  }) =>
      ModalBottomSheetRoute(
        builder: (BuildContext buildContext) {
          return _overlayRouteContainer(
            dismissable: dismissable,
            child: child,
            pop: pop,
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
    required VoidCallback? onClosedBySystemBackButton,
    required VoidCallback? onPop,
  }) {
    if (Platform.isAndroid) {
      return MaterialPageRoute(
        builder: (BuildContext context) => onClosedBySystemBackButton == null
            ? child
            : PopScope(
                canPop: onPop != null,
                onPopInvoked: (didPop) {
                  if (didPop) {
                    return;
                  }
                  
                  if (onPop != null) {
                    onPop();

                    return;
                  }

                  onClosedBySystemBackButton(); // triggers only when used android system back button
                },
                child: child,
              ),
        fullscreenDialog: fullScreenDialog,
      );
    } else {
      return UICupertinoPageRoute(
        builder: (BuildContext context) => onPop != null
            ? PopScope(
                canPop: false,
                onPopInvoked: (didPop) {
                  if (didPop) {
                    return;
                  }

                  onPop();
                },
                child: child,
              )
            : child,
        fullscreenDialog: fullScreenDialog,
        onClosedCallback:
            onClosedBySystemBackButton, // triggers only when used ios back gesture
      );
    }
  }

  static Widget _overlayRouteContainer({
    required bool dismissable,
    required Widget child,
    required VoidCallback pop,
  }) {
    return Builder(
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            if (dismissable) {
              pop();
            }
          },
          child: PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (didPop) {
                return;
              }

              if (dismissable) {
                pop();
              }
            },
            child: child,
          ),
        );
      },
    );
  }
}
