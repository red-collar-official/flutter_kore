import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mvvm_redux/arch/base_events.dart';
import 'package:mvvm_redux/arch/navigation/base/navigation_stack.dart';
import 'package:mvvm_redux/arch/navigation/base/navigation_utilities.dart';
import 'package:mvvm_redux/mvvm_redux.dart';

abstract class BaseNavigationInteractor<State, Input, AppTabType, RouteType,
    DialogType, BottomSheetType> extends BaseInteractor<State, Input> {
  final globalNavigatorKey = GlobalKey<NavigatorState>();
  final bottomSheetDialogNavigatorKey = GlobalKey<NavigatorState>();
  final routeObserver = RouteObserver<ModalRoute<void>>();

  UIRouteModel _defailtRouteModelFor(RouteType route) => UIRouteModel(
        name: route,
        settings: const UIRouteSettings(
          dismissable: false,
        ),
      );

  /// Default stack for global navigator
  List<UIRouteModel> defaultRouteStack() => [
        _defailtRouteModelFor(initialRoute),
      ];

  /// Default stacks for every tab navigator
  Map<AppTabType, List<UIRouteModel>> defaultTabRouteStack() =>
      initialTabRoutes.map(
        (key, value) => MapEntry(key, [_defailtRouteModelFor(value)]),
      );

  Map<AppTabType, GlobalKey<NavigatorState>> currentTabKeys = {};

  RouteType get initialRoute;
  Map<AppTabType, RouteType> get initialTabRoutes => {};

  RouteType? get tabViewHomeRoute => null;

  AppTabType? get currentTab => null;

  List<AppTabType>? get tabs => null;

  bool get appContainsTabNavigation => true;

  Future<void> onRouteOpened(Widget child, UIRouteSettings route);
  Future<void> onDialogOpened(Widget child, UIRouteSettings route);
  Future<void> onBottomSheetOpened(
    Widget child,
    UIRouteSettings route,
  );

  late final navigationStack = NavigationStack<AppTabType>(
    routeStack: defaultRouteStack,
    tabRouteStack: defaultTabRouteStack,
  );

  UIRouteModel latestGlobalRoute() =>
      navigationStack.globalNavigationStack.stack.last;
  UIRouteModel latestTabRoute() =>
      navigationStack.tabNavigationStack.stack[currentTab]!.last;

  void initStack() {
    navigationStack.replaceStack(
      routeName: initialRoute,
      currentTab: currentTab,
      global: true,
      uniqueInStack: true,
      fullScreenDialog: false,
    );
  }

  bool isInGlobalStack({bool includeBottomSheetsAndDialogs = true}) {
    if (!appContainsTabNavigation) {
      return true;
    }

    final isHomePresentInStack =
        navigationStack.globalNavigationStack.stack.indexWhere(
              (element) => element.name == tabViewHomeRoute,
            ) !=
            -1;

    final bool isGlobalStack = includeBottomSheetsAndDialogs
        ? navigationStack.globalNavigationStack.stack.length > 1
        : navigationStack.globalNavigationStack.stack
                .where((element) =>
                    element.name is! BottomSheetType &&
                    element.name is! DialogType)
                .length >
            1;

    return !isHomePresentInStack || isGlobalStack;
  }

  bool _checkGlobalNavigatorNeeded(bool forceGlobal) {
    return forceGlobal ? forceGlobal : isInGlobalStack();
  }

  GlobalKey<NavigatorState> getNavigator({bool forceGlobal = false}) {
    if (isInGlobalStack() || forceGlobal) {
      return globalNavigatorKey;
    }

    // otherwise return navigator key for current tab
    return currentTabKeys[currentTab]!;
  }

  GlobalKey<NavigatorState> getNavigatorForTab(AppTabType tab) {
    return currentTabKeys[tab]!;
  }

  void pop({
    dynamic payload,
    bool onlyInternalStack = false,
  }) {
    final isInGlobal = isInGlobalStack();

    final isInBottomSheetApp = isInBottomSheetDialogScope;

    if (!isInBottomSheetApp) {
      if (!isInGlobal) {
        final tabStack = navigationStack.tabNavigationStack.stack[currentTab]!;

        if (tabStack.length == 1) {
          // preventing close of first page in tab stack
          return;
        }
      } else {
        final globalStack = navigationStack.globalNavigationStack.stack;

        if (globalStack.length == 1) {
          // preventing close of first page in tab stack
          return;
        }
      }
    }

    if (onlyInternalStack) {
      navigationStack.pop(currentTab, isInGlobal);

      return;
    }

    final navigator =
        isInBottomSheetApp ? bottomSheetDialogNavigatorKey : getNavigator();

    navigationStack.pop(currentTab, isInGlobal || isInBottomSheetApp);

    navigator.currentState?.pop(payload);
  }

  void popInTab(
    AppTabType tab, {
    dynamic payload,
    bool onlyInternalStack = false,
  }) {
    final tabStack = navigationStack.tabNavigationStack.stack[tab]!;

    if (tabStack.length == 1) {
      // preventing close of first page in tab stack
      return;
    }

    if (onlyInternalStack) {
      navigationStack.pop(currentTab, false);

      return;
    }

    final navigator = currentTabKeys[tab];

    navigationStack.pop(currentTab, false);

    navigator?.currentState?.pop(payload);
  }

  Future<void> routeTo(
    UIRoute<RouteType> routeData, {
    bool? fullScreenDialog,
    bool replace = false,
    bool replacePrevious = false,
    bool? uniqueInStack,
    bool? forceGlobal,
    bool? needToEnsureClose,
    bool? dismissable,
    Object? id,
  }) async {
    final routeSettings = UIRouteSettings(
      fullScreenDialog:
          fullScreenDialog ?? routeData.defaultSettings.fullScreenDialog,
      global: forceGlobal ?? routeData.defaultSettings.global,
      uniqueInStack: uniqueInStack ?? routeData.defaultSettings.uniqueInStack,
      needToEnsureClose:
          needToEnsureClose ?? routeData.defaultSettings.needToEnsureClose,
      dismissable: dismissable ?? routeData.defaultSettings.dismissable,
      id: id,
      replace: replace,
      replacePrevious: replacePrevious,
    );

    final routeName = routeData.name;

    final bool global = _checkGlobalNavigatorNeeded(routeSettings.global);

    // Firstly check if element is already in stack
    // if it is and uniqueInStack flag is set to true we just return immediately
    if (routeSettings.uniqueInStack &&
        !navigationStack.checkUnique(
          routeName: routeName,
          currentTab: currentTab,
          global: global,
        ) &&
        !replace) {
      return;
    }

    final navigator = getNavigator(forceGlobal: global);

    final screenToOpen = routeData.child;

    final route = NavigationUtilities.buildPageRoute(
      screenToOpen,
      routeSettings.fullScreenDialog,
      replace
          ? null
          : () {
              pop(onlyInternalStack: true);
            },
      routeSettings.needToEnsureClose
          ? () {
              EventBus.instance.send(EnsureCloseRequestedEvent());

              return Future.value();
            }
          : (!routeSettings.dismissable
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
          uniqueInStack: routeSettings.uniqueInStack,
          id: id,
          fullScreenDialog: routeSettings.fullScreenDialog,
        );

      unawaited(onRouteOpened(screenToOpen, routeSettings));

      unawaited(navigator.currentState?.pushAndRemoveUntil(
        route,
        (route) => false,
      ));
    } else if (replacePrevious) {
      // if replace flag is provided we clear stack and navigator state
      navigationStack.replaceLastRoute(
        routeName: routeName,
        currentTab: currentTab,
        global: global,
        uniqueInStack: routeSettings.uniqueInStack,
        dismissable: routeSettings.dismissable,
        needToEnsureClose: routeSettings.needToEnsureClose,
        fullScreenDialog: routeSettings.fullScreenDialog,
        id: id,
      );

      unawaited(onRouteOpened(screenToOpen, routeSettings));

      unawaited(navigator.currentState?.pushReplacement(
        route,
      ));
    } else {
      // otherwise we just add route and push it to navigator
      navigationStack.addRoute(
        routeName: routeName,
        currentTab: currentTab,
        global: global,
        uniqueInStack: routeSettings.uniqueInStack,
        dismissable: routeSettings.dismissable,
        needToEnsureClose: routeSettings.needToEnsureClose,
        fullScreenDialog: routeSettings.fullScreenDialog,
        id: id,
      );

      unawaited(onRouteOpened(screenToOpen, routeSettings));

      await navigator.currentState?.push(
        route,
      );
    }
  }

  Future<dynamic> showDialog(
    UIRoute<DialogType> dialog, {
    bool? forceGlobal,
    bool? dismissable,
    bool? uniqueInStack,
    Object? id,
  }) async {
    final dialogSettings = UIRouteSettings(
      global: forceGlobal ?? dialog.defaultSettings.global,
      uniqueInStack: uniqueInStack ?? dialog.defaultSettings.uniqueInStack,
      dismissable: dismissable ?? dialog.defaultSettings.dismissable,
      id: id,
      fullScreenDialog: latestGlobalRoute().settings.fullScreenDialog,
    );

    if (dialogSettings.uniqueInStack &&
        !navigationStack.checkUnique(
          routeName: dialog,
          currentTab: currentTab,
          global: true,
        )) {
      return;
    }

    final dialogName = dialog.name;

    final bool global = _checkGlobalNavigatorNeeded(dialogSettings.global);

    final navigator =
        global ? bottomSheetDialogNavigatorKey : currentTabKeys[currentTab]!;

    navigationStack.addRoute(
      routeName: dialogName,
      currentTab: currentTab,
      global: global,
      uniqueInStack: true,
      dismissable: dialogSettings.dismissable,
      needToEnsureClose: false,
      fullScreenDialog: latestGlobalRoute().settings.fullScreenDialog,
      id: id,
    );

    final dialogToOpen = dialog.child;

    unawaited(onDialogOpened(dialogToOpen, dialogSettings));

    final result = await NavigationUtilities.pushDialogRoute(
      navigator: navigator,
      dismissable: dialogSettings.dismissable,
      child: dialogToOpen,
      pop: pop,
    );

    return result;
  }

  Future<dynamic> showBottomSheet(
    UIRoute<BottomSheetType> bottomSheet, {
    bool? forceGlobal,
    bool? dismissable,
    bool? uniqueInStack,
    Object? id,
  }) async {
    final bottomSheetSettings = UIRouteSettings(
      global: forceGlobal ?? bottomSheet.defaultSettings.global,
      uniqueInStack: uniqueInStack ?? bottomSheet.defaultSettings.uniqueInStack,
      dismissable: dismissable ?? bottomSheet.defaultSettings.dismissable,
      id: id,
      fullScreenDialog: latestGlobalRoute().settings.fullScreenDialog,
    );

    if (bottomSheetSettings.uniqueInStack &&
        !navigationStack.checkUnique(
          routeName: bottomSheet,
          currentTab: currentTab,
          global: true,
        )) {
      return;
    }

    final bottomSheetName = bottomSheet.name;

    final bool global = _checkGlobalNavigatorNeeded(bottomSheetSettings.global);

    final navigator =
        global ? bottomSheetDialogNavigatorKey : currentTabKeys[currentTab]!;

    navigationStack.addRoute(
      routeName: bottomSheetName,
      currentTab: currentTab,
      global: global,
      uniqueInStack: true,
      dismissable: bottomSheetSettings.dismissable,
      needToEnsureClose: false,
      fullScreenDialog: latestGlobalRoute().settings.fullScreenDialog,
      id: id,
    );

    final bottomSheetToOpen = bottomSheet.child;

    unawaited(onBottomSheetOpened(bottomSheetToOpen, bottomSheetSettings));

    final result = await NavigationUtilities.pushBottomSheetRoute(
      navigator: navigator,
      dismissable: bottomSheetSettings.dismissable,
      child: bottomSheetToOpen,
      pop: pop,
    );

    return result;
  }

  void setCurrentTab(AppTabType tab);

  bool canPop({bool global = true}) {
    if (global) {
      return navigationStack.globalNavigationStack.stack.length > 1 &&
          latestGlobalRoute().settings.dismissable;
    } else {
      return navigationStack.tabNavigationStack.stack[currentTab]!.length > 1 &&
          latestTabRoute().settings.dismissable;
    }
  }

  void popGlobalToFirst() {
    popAllDialogsAndBottomSheets();

    final navigator = getNavigator(forceGlobal: true);

    navigator.currentState?.popUntil((route) => route.isFirst);

    navigationStack.replaceStack(
      routeName:
          navigationStack.globalNavigationStack.stack.first.name as RouteType,
      global: true,
      uniqueInStack: true,
      fullScreenDialog: false,
    );
  }

  void popInTabToFirst(AppTabType appTab, {bool clearStack = true}) {
    final navigator = currentTabKeys[appTab];

    if (navigator == null) {
      return;
    }

    navigator.currentState?.popUntil((route) => route.isFirst);

    if (!clearStack) {
      return;
    }

    final firstRoute = navigationStack.tabNavigationStack.stack[currentTab]![0];

    navigationStack.tabNavigationStack.replaceStack(
      routeName: firstRoute.name as RouteType,
      currentTab: currentTab,
      global: false,
      uniqueInStack: true,
      fullScreenDialog: false,
    );
  }

  void popToTab(AppTabType tab) {
    popGlobalToFirst();
    setCurrentTab(tab);
  }

  void popAllNavigatiorsToFirst() {
    popGlobalToFirst();
    popAllTabsToFirst();
  }

  void popAllDialogsAndBottomSheets() {
    while (isInBottomSheetDialogScope) {
      navigationStack.pop(currentTab, true);
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
    for (final element in tabs ?? []) {
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

  Future<void> homeBackButtonGlobalCallback({bool global = false}) async {
    if (isInBottomSheetDialogScope) {
      pop();
    } else if (latestGlobalRoute().settings.needToEnsureClose) {
      EventBus.instance.send(EnsureCloseRequestedEvent());
    } else if (canPop(global: global)) {
      pop();
    }
  }

  bool get isInBottomSheetDialogScope {
    return latestGlobalRoute().name is BottomSheetType ||
        latestGlobalRoute().name is DialogType;
  }

  bool containsGlobalRoute(Object routeName) {
    return navigationStack.globalNavigationStack.stack
            .indexWhere((element) => element.name == routeName) !=
        -1;
  }
}
