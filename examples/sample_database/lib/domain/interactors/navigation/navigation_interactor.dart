import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample/domain/data/app_tab.dart';
import 'package:sample/domain/interactors/navigation/components/bottom_sheets_mixin.dart';
import 'package:sample/domain/interactors/navigation/components/dialogs_mixin.dart';
import 'package:sample/domain/interactors/navigation/components/routes.dart';
import 'package:sample/domain/interactors/navigation/components/routes_mixin.dart';
import 'package:mvvm_redux/utility/navigation/dialog_route.dart' as navigations;
import 'package:mvvm_redux/utility/navigation/bottom_sheet_route.dart' as bottom_sheet;

import 'components/bottom_sheets.dart';
import 'components/dialogs.dart';
import 'components/route_model.dart';
import 'navigation_state.dart';

typedef RouteBuilder = Widget Function(Map<String, dynamic>? payload);

late final globalNavigatorKey = GlobalKey<NavigatorState>();

@singletonInteractor
class NavigationInteractor extends BaseInteractor<NavigationState> with RoutesMixin, DialogsMixin, BottomSheetsMixin {
  static final List<RouteModel> _defaultRouteStack = [
    const RouteModel(
      name: Routes.home,
      dismissable: false,
    ),
  ];

  static final Map<AppTab, List<RouteModel>> _defaultTabRouteStack = {
    AppTabs.posts: [
      const RouteModel(
        name: Routes.posts,
        dismissable: false,
      ),
    ],
    AppTabs.likedPosts: [
      const RouteModel(
        name: Routes.likedPosts,
        dismissable: false,
      ),
    ],
  };

  late final Map<AppTab, GlobalKey<NavigatorState>> tabNavigatorKeys = {
    AppTabs.posts: GlobalKey<NavigatorState>(),
    AppTabs.likedPosts: GlobalKey<NavigatorState>(),
  };

  final _routeStack = _defaultRouteStack;
  final _tabRouteStack = _defaultTabRouteStack;

  RouteModel get latestGlobalRoute => _routeStack.last;
  RouteModel get latestTabRoute => _tabRouteStack[state.currentTab]!.last;

  GlobalKey<NavigatorState> _getNavigator({bool global = false}) {
    if (global) {
      return globalNavigatorKey;
    }

    final currentTab = state.currentTab;

    return tabNavigatorKeys[currentTab]!;
  }

  void pop({dynamic payload, bool global = false}) {
    final navigator = _getNavigator(global: global);

    if (!(navigator.currentState?.mounted ?? false)) {
      return;
    }

    if (global) {
      _routeStack.removeLast();
    } else {
      final currentTab = state.currentTab;
      _tabRouteStack[currentTab]!.removeLast();
    }

    navigator.currentState?.pop(payload);
  }

  Future<dynamic> routeTo(
    Routes routeName, {
    Map<String, dynamic>? payload,
    bool fullScreenDialog = false,
    bool replace = false,
    bool uniqueInStack = false,
    bool global = false,
  }) async {
    if (uniqueInStack && _checkUnique(routeName, global) && !replace) {
      return;
    }

    final navigator = _getNavigator(global: global);

    final route = CupertinoPageRoute(
      builder: (BuildContext context) => routes[routeName]!(payload),
      fullscreenDialog: fullScreenDialog,
      title: routeName.toString(),
    );

    if (!(navigator.currentState?.mounted ?? false)) {
      return;
    }

    if (replace) {
      _replaceStack(routeName, global, uniqueInStack);

      unawaited(navigator.currentState?.pushAndRemoveUntil(
        route,
        (route) => false,
      ));
    } else {
      _addRoute(routeName, global, uniqueInStack, true);

      final result = await navigator.currentState?.push(
        route,
      );

      return result;
    }
  }

  void _addRoute(Object routeName, bool global, bool uniqueInStack, bool dismissable) {
    if (global) {
      _routeStack.add(
        RouteModel(
          name: routeName,
          dismissable: dismissable,
          uniqueInStack: uniqueInStack,
        ),
      );
    } else {
      _tabRouteStack[state.currentTab]!.add(RouteModel(
        name: routeName,
        dismissable: dismissable,
        uniqueInStack: uniqueInStack,
      ));
    }
  }

  void _replaceStack(Routes routeName, bool global, bool uniqueInStack) {
    if (global) {
      _routeStack
        ..clear()
        ..add(
          RouteModel(
            name: routeName,
            dismissable: false,
            uniqueInStack: uniqueInStack,
          ),
        );
    } else {
      _tabRouteStack[state.currentTab!] = [
        RouteModel(
          name: routeName,
          dismissable: false,
          uniqueInStack: uniqueInStack,
        ),
      ];
    }
  }

  bool _checkUnique(Routes routeName, bool global) {
    if (global) {
      return _routeStack.indexWhere((element) => element.name == routeName) == -1;
    } else {
      return _tabRouteStack[state.currentTab!.name]!.indexWhere((element) => element.name == routeName) == -1;
    }
  }

  Future<dynamic> showDialog(
    Dialogs dialogName, {
    Map<String, dynamic>? payload,
    bool dismissable = true,
    bool global = false,
  }) async {
    final navigator = _getNavigator(global: global);

    if (!(navigator.currentState?.mounted ?? false)) {
      return;
    }

    _addRoute(dialogName, global, true, dismissable);

    final result = await navigator.currentState?.push(
      navigations.DialogRoute(
        barrierDismissible: dismissable,
        pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
          return Builder(
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async {
                  return Future.value(dismissable);
                },
                child: dialogs[dialogName]!(payload),
              );
            },
          );
        },
      ),
    );

    return result;
  }

  Future<dynamic> showBottomSheet(
    BottomSheets bottomSheetName, {
    Map<String, dynamic>? payload,
    bool global = false,
    bool dismissable = true,
  }) async {
    final navigator = _getNavigator(global: global);

    if (!(navigator.currentState?.mounted ?? false)) {
      return;
    }

    _addRoute(bottomSheetName, global, true, dismissable);

    final result = await navigator.currentState?.push(
      bottom_sheet.ModalBottomSheetRoute(
        builder: (BuildContext buildContext) {
          return Builder(
            builder: (BuildContext context) {
              return WillPopScope(
                onWillPop: () async {
                  return Future.value(dismissable);
                },
                child: bottomSheets[bottomSheetName]!(payload),
              );
            },
          );
        },
        onClosed: (_) {
          pop(global: global);
        },
        dismissible: dismissable,
        enableDrag: dismissable
      ),
    );

    return result;
  }

  void setCurrentTab(AppTab tab) {
    updateState(state.copyWith(currentTab: tab));
  }

  @override
  NavigationState get initialState => NavigationState(currentTab: AppTabs.posts);
}
