import 'dart:async';
import 'dart:io';

import 'package:sample_navigation/domain/interactors/navigation/components/screens/routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:mvvm_redux/utility/navigation/dialog_route.dart' as dialog;
import 'package:mvvm_redux/utility/navigation/bottom_sheet_route.dart'
    as bottom_sheet;

class NavigationUtilities {
  static Future<Object?>? pushDialogRoute(
          {required GlobalKey<NavigatorState> navigator,
          required bool dismissable,
          required Widget child}) =>
      navigator.currentState?.push(
        dialog.DialogRoute(
          barrierDismissible: dismissable,
          pageBuilder: (BuildContext buildContext, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return Builder(
              builder: (BuildContext context) {
                return WillPopScope(
                  onWillPop: () async {
                    return Future.value(dismissable);
                  },
                  child: child,
                );
              },
            );
          },
        ),
      );

  static Future<void> pushBottomSheetRoute(
      {required GlobalKey<NavigatorState> navigator,
      required bool dismissable,
      required Widget child,
      required Function onClosed}) async {
    final completer = Completer<void>();

    unawaited(navigator.currentState
        ?.push(bottom_sheet.ModalBottomSheetRoute(
            builder: (BuildContext buildContext) {
              return Builder(
                builder: (BuildContext context) {
                  return WillPopScope(
                    onWillPop: () async {
                      return Future.value(dismissable);
                    },
                    child: child,
                  );
                },
              );
            },
            onClosed: (_) {
              // this case means user swiped away bottom sheet so we close completer
              completer.complete();
              onClosed();
            },
            dismissible: dismissable,
            enableDrag: dismissable))
        .then((value) {
      // this means that bottom sheet was popped or system back button was pressed
      completer.complete();
    }));

    return completer.future;
  }

  static PageRoute buildPageRoute(
      Widget child, bool fullScreenDialog, Routes routeName) {
    if (Platform.isAndroid) {
      return MaterialPageRoute(
        builder: (BuildContext context) => child,
        fullscreenDialog: fullScreenDialog,
      );
    } else {
      return CupertinoPageRoute(
        builder: (BuildContext context) => child,
        fullscreenDialog: fullScreenDialog,
        title: routeName.toString(),
      );
    }
  }
}
