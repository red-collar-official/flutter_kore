import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:mvvm_redux/utility/navigation/dialog_route.dart' as dialog;
import 'package:mvvm_redux/utility/navigation/bottom_sheet_route.dart'
    as bottom_sheet;
import 'package:sample_database/domain/global/global_store.dart';
import 'package:sample_database/domain/interactors/interactors.dart';
import 'package:sample_database/domain/interactors/navigation/components/screens/routes.dart';
import 'package:sample_database/domain/interactors/navigation/components/utilities/willpop_cupertino_page_route.dart';

class NavigationUtilities {
  static Future<Object?>? pushDialogRoute({
    required GlobalKey<NavigatorState> navigator,
    required bool dismissable,
    required Widget child,
  }) =>
      navigator.currentState?.push(
        dialog.DialogRoute(
          barrierDismissible: dismissable,
          pageBuilder: (BuildContext buildContext, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return Builder(
              builder: (BuildContext context) {
                return GestureDetector(
                  onTap: () {
                    // TODO find better solution
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
          },
        ),
      );

  static Future<void> pushBottomSheetRoute(
      {required GlobalKey<NavigatorState> navigator,
      required bool dismissable,
      required Widget child,
      required Function onClosed}) async {
    final completer = Completer<void>();

    unawaited(
      navigator.currentState
          ?.push(
        bottom_sheet.ModalBottomSheetRoute(
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
            onClosed();

            // this case means user swiped away bottom sheet so we close completer
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
          dismissible: dismissable,
          enableDrag: dismissable,
        ),
      )
          .then(
        (value) {
          // this means that bottom sheet was popped or system back button was pressed
          if (!completer.isCompleted) {
            completer.complete();
          }
        },
      ),
    );

    return completer.future;
  }

  static PageRoute buildPageRoute(Widget child, bool fullScreenDialog,
      Routes routeName, VoidCallback? onClosed) {
    if (Platform.isAndroid) {
      return MaterialPageRoute(
        builder: (BuildContext context) => onClosed == null
            ? child
            : WillPopScope(
                onWillPop: () async {
                  onClosed(); // triggers only when used android system back button
                  return Future.value(true);
                },
                child: child,
              ),
        fullscreenDialog: fullScreenDialog,
      );
    } else {
      return UICupertinoPageRoute(
        builder: (BuildContext context) => child,
        fullscreenDialog: fullScreenDialog,
        title: routeName.toString(),
        onClosedCallback: onClosed, // triggers only when used ios back gesture
      );
    }
  }
}
