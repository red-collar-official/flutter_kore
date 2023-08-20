import 'dart:async';
import 'dart:io';

import 'package:sample_database/domain/global/global_store.dart';
import 'package:sample_database/domain/interactors/interactors.dart';
import 'package:sample_database/domain/interactors/navigation/components/screens/route_names.dart';
import 'package:sample_database/domain/interactors/navigation/components/utilities/bottom_sheet_route.dart';
import 'package:sample_database/domain/interactors/navigation/components/utilities/dialog_route.dart';
import 'package:sample_database/domain/interactors/navigation/components/utilities/willpop_cupertino_page_route.dart';
import 'package:flutter/material.dart' hide DialogRoute, ModalBottomSheetRoute;

class NavigationUtilities {
  static Future<Object?>? pushDialogRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissable,
    required Widget child,
  }) =>
      navigator.currentState?.push(
        DialogRoute(
          barrierDismissible: dismissable,
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
        ),
      );

  static Future? pushBottomSheetRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissable,
    required Widget child,
  }) =>
      navigator.currentState?.push(
        ModalBottomSheetRoute(
          builder: (BuildContext buildContext) {
            return _overlayRouteContainer(
              dismissable: dismissable,
              child: child,
            );
          },
          dismissible: dismissable,
          enableDrag: dismissable,
        ),
      );

  static PageRoute buildPageRoute(
    Widget child,
    bool fullScreenDialog,
    RouteNames routeName,
    VoidCallback? onClosed,
    Future<void> Function()? onWillPop,
  ) {
    if (Platform.isAndroid) {
      return MaterialPageRoute(
        builder: (BuildContext context) => onClosed == null
            ? child
            : WillPopScope(
                onWillPop: () async {
                  if (onWillPop != null) {
                    await onWillPop();

                    return false;
                  }

                  onClosed(); // triggers only when used android system back button

                  return Future.value(true);
                },
                child: child,
              ),
        fullscreenDialog: fullScreenDialog,
      );
    } else {
      return UICupertinoPageRoute(
        builder: (BuildContext context) => onWillPop != null
            ? WillPopScope(
                onWillPop: () async {
                  await onWillPop();

                  return false;
                },
                child: child,
              )
            : child,
        fullscreenDialog: fullScreenDialog,
        title: routeName.toString(),
        onClosedCallback: onClosed, // triggers only when used ios back gesture
      );
    }
  }

  static Widget _overlayRouteContainer({
    required bool dismissable,
    required Widget child,
  }) {
    return Builder(
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            if (dismissable) {
              app.interactors.get<NavigationInteractor>().pop();
            }
          },
          child: WillPopScope(
            onWillPop: () async {
              if (dismissable) {
                app.interactors.get<NavigationInteractor>().pop();
              }

              return false;
            },
            child: child,
          ),
        );
      },
    );
  }
}
