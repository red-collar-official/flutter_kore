import 'dart:async';

import 'package:sample_database/domain/data/app_tab.dart';
import 'package:sample_database/domain/global/events.dart';
import 'package:sample_database/domain/global/global_store.dart';
import 'package:sample_database/domain/interactors/navigation/components/base/navigation_defaults.dart';
import 'package:sample_database/domain/interactors/navigation/components/base/navigation_utilities.dart';
import 'package:sample_database/domain/interactors/navigation/components/bottom_sheets/bottom_sheet_names.dart';
import 'package:sample_database/domain/interactors/navigation/components/dialogs/dialog_names.dart';
import 'package:sample_database/domain/interactors/navigation/components/screens/route_names.dart';
import 'package:sample_database/domain/services/navigation_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:mvvm_redux/mvvm_redux.dart';

import 'components/route.dart';
import 'components/route_model.dart';
import 'navigation_state.dart';

@singletonInteractor
class NavigationInteractor
    extends BaseInteractor<NavigationState, Map<String, dynamic>> {
  late final navigationStack = app.services.get<NavigationService>().instance;

  Map<AppTab, GlobalKey<NavigatorState>> currentTabKeys = {};

  UIRouteModel latestGlobalRoute() =>
      navigationStack.globalNavigationStack.routeStack.last;
  UIRouteModel latestTabRoute() =>
      navigationStack.tabNavigationStack.tabRouteStack[state.currentTab]!.last;

  void initStack() {
    navigationStack.replaceStack(
      routeName: RouteNames.home,
      currentTab: state.currentTab,
      global: true,
      uniqueInStack: true,
      fullScreenDialog: false,
    );
  }

  bool isInGlobalStack() {
    final isHomePresentInStack =
        navigationStack.globalNavigationStack.routeStack.indexWhere(
              (element) => element.name == RouteNames.home,
            ) !=
            -1;

    return !isHomePresentInStack ||
        navigationStack.globalNavigationStack.routeStack.length > 1;
  }

  bool _checkGlobalNavigatorNeeded(bool forceGlobal) {
    return forceGlobal ? forceGlobal : isInGlobalStack();
  }

  GlobalKey<NavigatorState> getNavigator({bool forceGlobal = false}) {
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

    final isInBottomSheetApp = isInBottomSheetDialogScope;

    if (!isInBottomSheetApp) {
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
    }

    if (onlyInternalStack) {
      navigationStack.pop(state.currentTab, isInGlobal);

      return;
    }

    final navigator =
        isInBottomSheetApp ? bottomSheetDialogNavigatorKey : getNavigator();

    navigationStack.pop(state.currentTab, isInGlobal || isInBottomSheetApp);

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
    UIRoute<RouteNames> routeData, {
    bool? fullScreenDialog,
    bool replace = false,
    bool replacePrevious = false,
    bool? uniqueInStack,
    bool? forceGlobal,
    bool? needToEnsureClose,
    bool? dismissable,
    Object? id,
  }) async {
    final fullScreenDialogInput =
        fullScreenDialog ?? routeData.defaultSettings.fullScreenDialog;
    final uniqueInStackInput =
        uniqueInStack ?? routeData.defaultSettings.uniqueInStack;
    final forceGlobalInput =
        forceGlobal ?? routeData.defaultSettings.forceGlobal;
    final needToEnsureCloseInput =
        needToEnsureClose ?? routeData.defaultSettings.needToEnsureClose;
    final dismissableInput =
        dismissable ?? routeData.defaultSettings.dismissable;

    final routeName = routeData.name;

    final bool global = _checkGlobalNavigatorNeeded(forceGlobalInput);

    // Firstly check if element is already in stack
    // if it is and uniqueInStack flag is set to true we just return immediately
    if (uniqueInStackInput &&
        !navigationStack.checkUnique(
          routeName: routeName,
          currentTab: state.currentTab,
          global: global,
        ) &&
        !replace) {
      return;
    }

    final navigator = getNavigator(forceGlobal: global);

    final screenToOpen = routeData.child;

    final route = NavigationUtilities.buildPageRoute(
      screenToOpen,
      fullScreenDialogInput,
      routeName,
      replace
          ? null
          : () {
              pop(onlyInternalStack: true);
            },
      needToEnsureCloseInput
          ? () {
              app.eventBus.send(EnsureCloseRequestedEvent());

              return Future.value();
            }
          : (!dismissableInput
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
          uniqueInStack: uniqueInStackInput,
          id: id,
          fullScreenDialog: fullScreenDialogInput,
        );

      if (global) {
        app.eventBus.send(GlobalRoutePushedEvent(replace: replace));
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
        uniqueInStack: uniqueInStackInput,
        dismissable: dismissableInput,
        needToEnsureClose: needToEnsureCloseInput,
        fullScreenDialog: fullScreenDialogInput,
        id: id,
      );

      if (global) {
        app.eventBus.send(GlobalRoutePushedEvent(replace: replace));
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
        uniqueInStack: uniqueInStackInput,
        dismissable: dismissableInput,
        needToEnsureClose: needToEnsureCloseInput,
        fullScreenDialog: fullScreenDialogInput,
        id: id,
      );

      if (global) {
        app.eventBus.send(GlobalRoutePushedEvent(replace: replace));
      }

      await navigator.currentState?.push(
        route,
      );
    }
  }

  Future<dynamic> showDialog(
    UIRoute<DialogNames> dialog, {
    bool? forceGlobal,
    bool? dismissable,
    bool? uniqueInStack,
    Object? id,
  }) async {
    final forceGlobalInput = forceGlobal ?? dialog.defaultSettings.forceGlobal;
    final dismissableInput = dismissable ?? dialog.defaultSettings.dismissable;

    final uniqueInStackInput =
        uniqueInStack ?? dialog.defaultSettings.uniqueInStack;

    if (uniqueInStackInput &&
        !navigationStack.checkUnique(
          routeName: dialog,
          currentTab: state.currentTab,
          global: true,
        )) {
      return;
    }

    final dialogName = dialog.name;

    final bool global = _checkGlobalNavigatorNeeded(forceGlobalInput);

    final navigator = global
        ? bottomSheetDialogNavigatorKey
        : currentTabKeys[state.currentTab]!;

    navigationStack.addRoute(
      routeName: dialogName,
      currentTab: state.currentTab,
      global: global,
      uniqueInStack: true,
      dismissable: dismissableInput,
      needToEnsureClose: false,
      fullScreenDialog: latestGlobalRoute().settings.fullScreenDialog,
      id: id,
    );

    final dialogToOpen = dialog.child;

    final result = await NavigationUtilities.pushDialogRoute(
      navigator: navigator,
      dismissable: dismissableInput,
      child: dialogToOpen,
    );

    return result;
  }

  Future<dynamic> showBottomSheet(
    UIRoute<BottomSheetNames> bottomSheet, {
    bool? forceGlobal,
    bool? dismissable,
    bool? uniqueInStack,
    Object? id,
  }) async {
    final forceGlobalInput =
        forceGlobal ?? bottomSheet.defaultSettings.forceGlobal;
    final dismissableInput =
        dismissable ?? bottomSheet.defaultSettings.dismissable;

    final uniqueInStackInput =
        uniqueInStack ?? bottomSheet.defaultSettings.uniqueInStack;

    if (uniqueInStackInput &&
        !navigationStack.checkUnique(
          routeName: bottomSheet,
          currentTab: state.currentTab,
          global: true,
        )) {
      return;
    }

    final bottomSheetName = bottomSheet.name;

    final bool global = _checkGlobalNavigatorNeeded(forceGlobalInput);

    final navigator = global
        ? bottomSheetDialogNavigatorKey
        : currentTabKeys[state.currentTab]!;

    navigationStack.addRoute(
      routeName: bottomSheetName,
      currentTab: state.currentTab,
      global: global,
      uniqueInStack: true,
      dismissable: dismissableInput,
      needToEnsureClose: false,
      fullScreenDialog: latestGlobalRoute().settings.fullScreenDialog,
      id: id,
    );

    final bottomSheetToOpen = bottomSheet.child;

    final result = await NavigationUtilities.pushBottomSheetRoute(
      navigator: navigator,
      dismissable: dismissableInput,
      child: bottomSheetToOpen,
    );

    return result;
  }

  void setCurrentTab(AppTab tab) {
    updateState(state.copyWith(currentTab: tab));
  }

  bool canPop({bool global = true}) {
    if (global) {
      return navigationStack.globalNavigationStack.routeStack.length > 1 &&
          latestGlobalRoute().settings.dismissable;
    } else {
      return navigationStack
                  .tabNavigationStack.tabRouteStack[state.currentTab]!.length >
              1 &&
          latestTabRoute().settings.dismissable;
    }
  }

  void popGlobalToFirst() {
    popAllDialogsAndBottomSheets();

    final navigator = getNavigator(forceGlobal: true);

    navigator.currentState?.popUntil((route) => route.isFirst);

    navigationStack.replaceStack(
      routeName: RouteNames.home,
      global: true,
      uniqueInStack: true,
      fullScreenDialog: false,
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
      routeName: firstRoute.name as RouteNames,
      currentTab: currentTab,
      global: false,
      uniqueInStack: true,
      fullScreenDialog: false,
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

    while (latestName is DialogNames || latestName is BottomSheetNames) {
      navigationStack.pop(state.currentTab, true);
      latestName = latestGlobalRoute().name;
    }

    bottomSheetDialogNavigatorKey.currentState?.popUntil(
      (route) => route.isFirst,
    );
  }

  void popUntil(Object routeName, {bool forceGlobal = false}) {
    if (forceGlobal || isInGlobalStack()) {
      popGlobalUntil(routeName);
    } else {
      popInTabUntil(routeName);
    }
  }

  void popGlobalUntil(Object routeName) {
    while (canPop() && latestGlobalRoute().name != routeName) {
      pop();
    }
  }

  void popInTabUntil(Object routeName) {
    while (canPop(global: false) && latestTabRoute().name != routeName) {
      pop();
    }
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

  bool get isInBottomSheetDialogScope {
    return latestGlobalRoute().name is BottomSheetNames ||
        latestGlobalRoute().name is DialogNames;
  }

  Future<void> homeBackButtonGlobalCallback({bool global = false}) async {
    if (latestGlobalRoute().name is BottomSheetNames ||
        latestGlobalRoute().name is DialogNames) {
      pop();
    } else if (latestGlobalRoute().settings.needToEnsureClose) {
      app.eventBus.send(EnsureCloseRequestedEvent());
    } else if (canPop(global: global)) {
      pop();
    }
  }

  @override
  NavigationState initialState(Map<String, dynamic>? input) =>
      NavigationState(currentTab: AppTabs.posts);
}
