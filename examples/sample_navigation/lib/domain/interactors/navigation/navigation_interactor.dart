import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_navigation/domain/data/app_tab.dart';

import 'components/base/navigation_defaults.dart';
import 'components/base/navigation_stack.dart';
import 'components/base/navigation_utilities.dart';
import 'components/bottom_sheets/bottom_sheets.dart';
import 'components/bottom_sheets/bottom_sheets_mixin.dart';
import 'components/dialogs/dialogs.dart';
import 'components/dialogs/dialogs_mixin.dart';
import 'components/route_model.dart';
import 'components/screens/routes.dart';
import 'components/screens/routes_mixin.dart';
import 'navigation_state.dart';

typedef RouteBuilder = Widget Function(Map<String, dynamic>? payload);

@singletonInteractor
class NavigationInteractor extends BaseInteractor<NavigationState>
    with
        RoutesMixin,
        DialogsMixin,
        BottomSheetsMixin {
  final navigationStack = NavigationStack();

  RouteModel latestGlobalRoute() =>
      navigationStack.globalNavigationStack.routeStack.last;
  RouteModel latestTabRoute() =>
      navigationStack.tabNavigationStack.tabRouteStack[state.currentTab]!.last;

  void initStack() {
    navigationStack.replaceStack(
      Routes.home,
      state.currentTab,
      true,
      true,
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
    final bool global;

    if (forceGlobal) {
      global = true;
    } else {
      global = isInGlobalStack();
    }

    return global;
  }

  GlobalKey<NavigatorState> getNavigator({bool forceGlobal = false}) {
    final routeStack = navigationStack.globalNavigationStack.routeStack;

    if (routeStack.isNotEmpty &&
          (routeStack.last.name is Dialogs ||
              routeStack.last.name is BottomSheets)) {
        return globalNavigatorKey;
      }

    if (isInGlobalStack() || forceGlobal) {
      return globalNavigatorKey;
    }

    // otherwise return navigator key for current tab
    final currentTab = state.currentTab;

    return tabNavigatorKeys[currentTab]!;
  }

  GlobalKey<NavigatorState> getNavigatorForTab(AppTab tab) {
    return tabNavigatorKeys[tab]!;
  }

  void pop({dynamic payload, bool onlyInternalStack = false}) {
    if (onlyInternalStack) {
      navigationStack.pop(state.currentTab, isInGlobalStack());
      return;
    }

    final navigator = getNavigator();

    navigationStack.pop(state.currentTab, isInGlobalStack());

    navigator.currentState?.pop(payload);
  }

  Future<void> routeTo(
    Routes routeName, {
    Map<String, dynamic>? payload,
    bool fullScreenDialog = false,
    bool replace = false,
    bool uniqueInStack = false,
    bool forceGlobal = false,
  }) async {
    final bool global = _checkGlobalNavigatorNeeded(forceGlobal);

    // Firstly check if element is already in stack
    // if it is and uniqueInStack flag is set to true we just return immediately
    if (uniqueInStack &&
        !navigationStack.checkUnique(routeName, state.currentTab, global) &&
        !replace) {
      return;
    }

    final navigator = getNavigator(forceGlobal: global);

    final route = NavigationUtilities.buildPageRoute(
        routes[routeName]!(payload),
        fullScreenDialog,
        routeName,
        replace
            ? null
            : () {
                pop(onlyInternalStack: true);
              });

    if (replace) {
      // if replace flag is provided we clear stack and navigator state
      navigationStack.replaceStack(
          routeName, state.currentTab, global, uniqueInStack);

      unawaited(navigator.currentState?.pushAndRemoveUntil(
        route,
        (route) => false,
      ));
    } else {
      // otherwise we just add route and push it to navigator
      navigationStack.addRoute(
          routeName, state.currentTab, global, uniqueInStack, true);

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
  }) async {
    final bool global = _checkGlobalNavigatorNeeded(forceGlobal);

    final navigator = global
        ? globalNavigatorKey
        : getNavigator(forceGlobal: global);

    navigationStack.addRoute(
        dialogName, state.currentTab, global, true, dismissable);

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
  }) async {
    final bool global = _checkGlobalNavigatorNeeded(forceGlobal);

    final navigator = global
        ? globalNavigatorKey
        : getNavigator(forceGlobal: global);

    navigationStack.addRoute(
        bottomSheetName, state.currentTab, global, true, dismissable);

    final result = await NavigationUtilities.pushBottomSheetRoute(
      navigator: navigator,
      dismissable: dismissable,
      child: bottomSheets[bottomSheetName]!(payload),
      onClosed: () {
        pop();
      },
    );

    if (!navigationStack.checkUnique(
        bottomSheetName, state.currentTab, global)) {
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
      return latestGlobalRoute() != defaultRouteStack()[0];
    } else {
      return latestTabRoute() != defaultTabRouteStack()[state.currentTab]![0];
    }
  }

  void popGlobalToFirst() {
    final navigator = getNavigator(forceGlobal: true);

    navigator.currentState?.popUntil((route) => route.isFirst);

    initStack();
  }

  void popInTabToFirst(AppTab appTab) {
    final navigator = tabNavigatorKeys[appTab]!;
    navigator.currentState?.popUntil((route) => route.isFirst);
  }

  void popToTab(AppTab tab) {
    popGlobalToFirst();
    setCurrentTab(tab);
  }

  void popAllNavigatiorsToFirst() {
    popGlobalToFirst();

    // ignore: prefer_foreach
    for (final element in AppTabs.tabs) {
      popInTabToFirst(element);
    }
  }

  @override
  NavigationState initialState(Map<String, dynamic>? input) =>
      NavigationState(currentTab: AppTabs.posts);
}
