import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_navigation/domain/data/app_tab.dart';
import 'package:sample_navigation/domain/global/events.dart';
import 'package:sample_navigation/domain/global/global_store.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/base/navigation_defaults.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/base/navigation_utilities.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/bottom_sheets/bottom_sheets.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/bottom_sheets/bottom_sheets_mixin.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/dialogs/dialogs.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/dialogs/dialogs_mixin.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/routes.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/routes_mixin.dart';
import 'package:sample_navigation/domain/services/navigation_service.dart';

import 'components/route_model.dart';
import 'navigation_state.dart';

typedef RouteBuilder = Widget Function(Map<String, dynamic>? payload);

@singletonInteractor
class NavigationInteractor extends BaseInteractor<NavigationState>
    with RoutesMixin, DialogsMixin, BottomSheetsMixin {
  final navigationStack = app.services.get<NavigationService>().instance;

  Map<AppTab, GlobalKey<NavigatorState>> currentTabKeys = {};

  RouteModel latestGlobalRoute() =>
      navigationStack.globalNavigationStack.routeStack.last;
  RouteModel latestTabRoute() =>
      navigationStack.tabNavigationStack.tabRouteStack[state.currentTab]!.last;

  void initStack() {
    navigationStack.replaceStack(
      routeName: Routes.home,
      currentTab: state.currentTab,
      global: true,
      uniqueInStack: true,
    );
  }

  bool isInGlobalStack() {
    final isHomePresentInStack =
        navigationStack.globalNavigationStack.routeStack.indexWhere(
              (element) => element.name == Routes.home,
            ) !=
            -1;

    return !isHomePresentInStack ||
        navigationStack.globalNavigationStack.routeStack.length > 1;
  }

  bool _checkGlobalNavigatorNeeded(bool forceGlobal) {
    return forceGlobal ? forceGlobal : isInGlobalStack();
  }

  GlobalKey<NavigatorState> getNavigator({bool forceGlobal = false}) {
    final routeStack = navigationStack.globalNavigationStack.routeStack;

    if (routeStack.isNotEmpty &&
        (routeStack.last.name is Dialogs ||
            routeStack.last.name is BottomSheets)) {
      return bottomSheetDialogNavigatorKey;
    }

    if (isInGlobalStack() || forceGlobal) {
      return globalNavigatorKey;
    }

    // otherwise return navigator key for current tab
    final currentTab = state.currentTab;

    return currentTabKeys[currentTab]!;
  }

  GlobalKey<NavigatorState> getNavigatorForTab(AppTab tab) {
    return currentTabKeys[tab]!;
  }

  void pop({
    dynamic payload,
    bool onlyInternalStack = false,
  }) {
    final bool isInGlobal = isInGlobalStack();

    if (!isInGlobal) {
      final tabStack =
          navigationStack.tabNavigationStack.tabRouteStack[state.currentTab]!;

      if (tabStack.length == 1) {
        // preventing close of first page in tab stack
        return;
      }
    } else {
      final globalStack = navigationStack.globalNavigationStack.routeStack;

      if (globalStack.length == 1) {
        // preventing close of first page in tab stack
        return;
      }
    }

    if (onlyInternalStack) {
      navigationStack.pop(state.currentTab, isInGlobal);

      return;
    }

    final navigator = getNavigator();

    navigationStack.pop(state.currentTab, isInGlobal);

    navigator.currentState?.pop(payload);
  }

  void popInTab(
    AppTab tab, {
    dynamic payload,
    bool onlyInternalStack = false,
  }) {
    final tabStack = navigationStack.tabNavigationStack.tabRouteStack[tab]!;

    if (tabStack.length == 1) {
      // preventing close of first page in tab stack
      return;
    }

    if (onlyInternalStack) {
      navigationStack.pop(state.currentTab, false);

      return;
    }

    final navigator = currentTabKeys[tab];

    navigationStack.pop(state.currentTab, false);

    navigator?.currentState?.pop(payload);
  }

  Future<void> routeTo(
    Routes routeName, {
    Map<String, dynamic>? payload,
    bool fullScreenDialog = false,
    bool replace = false,
    bool replacePrevious = false,
    bool uniqueInStack = false,
    bool forceGlobal = false,
    bool needToEnsureClose = false,
    bool dismissable = true,
    Object? id,
  }) async {
    final bool global = _checkGlobalNavigatorNeeded(forceGlobal);

    // Firstly check if element is already in stack
    // if it is and uniqueInStack flag is set to true we just return immediately
    if (uniqueInStack &&
        !navigationStack.checkUnique(
          routeName: routeName,
          currentTab: state.currentTab,
          global: global,
        ) &&
        !replace) {
      return;
    }

    final navigator = getNavigator(forceGlobal: global);

    final screenToOpen = routes[routeName]!(payload);

    final route = NavigationUtilities.buildPageRoute(
      screenToOpen,
      fullScreenDialog,
      routeName,
      replace
          ? null
          : () {
              pop(onlyInternalStack: true);
            },
      needToEnsureClose
          ? () {
              app.eventBus.send(Events.ensureCloseRequested);

              return Future.value();
            }
          : (!dismissable
              ? () {
                  return Future.value();
                }
              : null),
    );

    if (replace) {
      // if replace flag is provided we clear stack and navigator state
      navigationStack
        ..clearTabNavigationStack()
        ..replaceStack(
          routeName: routeName,
          global: global,
          uniqueInStack: uniqueInStack,
          id: id,
        );

      if (global) {
        app.eventBus.send(Events.globalRoutePushed, payload: replace);
      }

      unawaited(navigator.currentState?.pushAndRemoveUntil(
        route,
        (route) => false,
      ));
    } else if (replacePrevious) {
      // if replace flag is provided we clear stack and navigator state
      navigationStack.replaceLastRoute(
        routeName: routeName,
        currentTab: state.currentTab,
        global: global,
        uniqueInStack: uniqueInStack,
        dismissable: dismissable,
        needToEnsureClose: needToEnsureClose,
        id: id,
      );

      if (global) {
        app.eventBus.send(Events.globalRoutePushed, payload: replace);
      }

      unawaited(navigator.currentState?.pushReplacement(
        route,
      ));
    } else {
      // otherwise we just add route and push it to navigator
      navigationStack.addRoute(
        routeName: routeName,
        currentTab: state.currentTab,
        global: global,
        uniqueInStack: uniqueInStack,
        dismissable: dismissable,
        needToEnsureClose: needToEnsureClose,
        id: id,
      );

      if (global) {
        app.eventBus.send(Events.globalRoutePushed, payload: replace);
      }

      await navigator.currentState?.push(
        route,
      );
    }
  }

  Future<dynamic> showDialog(
    Dialogs dialogName, {
    Map<String, dynamic>? payload,
    bool dismissable = true,
    bool forceGlobal = true,
    Object? id,
  }) async {
    final bool global = _checkGlobalNavigatorNeeded(forceGlobal);

    final navigator = global
        ? bottomSheetDialogNavigatorKey
        : getNavigator(forceGlobal: global);

    navigationStack.addRoute(
      routeName: dialogName,
      currentTab: state.currentTab,
      global: global,
      uniqueInStack: true,
      dismissable: dismissable,
      needToEnsureClose: false,
      id: id,
    );

    final result = await NavigationUtilities.pushDialogRoute(
      navigator: navigator,
      dismissable: dismissable,
      child: dialogs[dialogName]!(payload),
    );

    return result;
  }

  Future<dynamic> showBottomSheet(
    BottomSheets bottomSheetName, {
    Map<String, dynamic>? payload,
    bool forceGlobal = true,
    bool dismissable = true,
    Object? id,
  }) async {
    final bool global = _checkGlobalNavigatorNeeded(forceGlobal);

    final navigator = global
        ? bottomSheetDialogNavigatorKey
        : getNavigator(forceGlobal: global);

    navigationStack.addRoute(
      routeName: bottomSheetName,
      currentTab: state.currentTab,
      global: global,
      uniqueInStack: true,
      dismissable: dismissable,
      needToEnsureClose: false,
      id: id,
    );
    final result = await NavigationUtilities.pushBottomSheetRoute(
      navigator: navigator,
      dismissable: dismissable,
      child: bottomSheets[bottomSheetName]!(payload),
      onClosed: () {
        pop();
      },
    );

    if (!navigationStack.checkUnique(
      routeName: bottomSheetName,
      currentTab: state.currentTab,
      global: global,
    )) {
      // this means that bottom sheet was closed by tap to outside space
      // because bottom sheets are unique in stack
      navigationStack.pop(state.currentTab, global);
    }

    return result;
  }

  void setCurrentTab(AppTab tab) {
    updateState(state.copyWith(currentTab: tab));
  }

  bool canPop({bool global = true}) {
    if (global) {
      return latestGlobalRoute().name != defaultRouteStack()[0].name;
    } else {
      return latestTabRoute().name !=
          defaultTabRouteStack()[state.currentTab]![0].name;
    }
  }

  void popGlobalToFirst() {
    final navigator = getNavigator(forceGlobal: true);

    navigator.currentState?.popUntil((route) => route.isFirst);

    navigationStack.replaceStack(
      routeName: Routes.home,
      global: true,
      uniqueInStack: true,
    );
  }

  void popInTabToFirst(AppTab appTab, {bool clearStack = true}) {
    final navigator = currentTabKeys[appTab];

    if (navigator == null) {
      return;
    }

    navigator.currentState?.popUntil((route) => route.isFirst);

    if (!clearStack) {
      return;
    }

    final currentTab = state.currentTab;
    final firstRoute =
        navigationStack.tabNavigationStack.tabRouteStack[currentTab]![0];

    navigationStack.tabNavigationStack.replaceStack(
      routeName: firstRoute.name as Routes,
      currentTab: currentTab,
      global: false,
      uniqueInStack: true,
    );
  }

  void popToTab(AppTab tab) {
    popGlobalToFirst();
    setCurrentTab(tab);
  }

  void popAllNavigatiorsToFirst() {
    popAllDialogsAndBottomSheets();
    popGlobalToFirst();
    popAllTabsToFirst();
  }

  void popAllDialogsAndBottomSheets() {
    var latestName = latestGlobalRoute().name;

    while (latestName is Dialogs || latestName is BottomSheets) {
      navigationStack.pop(state.currentTab, true);
      latestName = latestGlobalRoute().name;
    }

    bottomSheetDialogNavigatorKey.currentState?.popUntil(
      (route) => route.isFirst,
    );
  }

  void popAllTabsToFirst() {
    // ignore: prefer_foreach
    for (final element in AppTabs.tabs) {
      popInTabToFirst(element, clearStack: false);
    }

    navigationStack.clearTabNavigationStack();
  }

  void popGlobalToPage(Object routeName, {bool navigateBefore = false}) {
    while (latestGlobalRoute().name != routeName) {
      pop();
    }

    if (navigateBefore) {
      pop();
    }
  }

  Future<bool> homeBackButtonTabCallback() async {
    if (latestTabRoute().needToEnsureClose) {
      app.eventBus.send(Events.ensureCloseRequested);
    } else if (canPop(global: false)) {
      pop();
    }

    return false;
  }

  bool homeBackButtonGlobalCallback() {
    if (latestGlobalRoute().needToEnsureClose) {
      app.eventBus.send(Events.ensureCloseRequested);
    } else if (canPop()) {
      pop();
    }

    return true;
  }

  @override
  NavigationState initialState(Map<String, dynamic>? input) =>
      NavigationState(currentTab: AppTabs.posts);
}
