import 'dart:async';
import 'dart:io';

import 'package:sample_navigation/domain/interactors/navigation/components/base/navigation_stack.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/base/navigation_utilities.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/bottom_sheets/bottom_sheets.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/bottom_sheets/bottom_sheets_mixin.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/dialogs/dialogs.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/dialogs/dialogs_mixin.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/routes.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/routes_mixin.dart';
import 'package:flutter/cupertino.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_navigation/domain/data/app_tab.dart';

import 'components/route_model.dart';
import 'components/base/navigation_defaults.dart';
import 'navigation_state.dart';

typedef RouteBuilder = Widget Function(Map<String, dynamic>? payload);

@singletonInteractor
class NavigationInteractor extends BaseInteractor<NavigationState> with RoutesMixin, DialogsMixin, BottomSheetsMixin {
  final navigationStack = NavigationStack();

  RouteModel latestGlobalRoute() => navigationStack.globalNavigationStack.routeStack.last;
  RouteModel latestTabRoute() => navigationStack.tabNavigationStack.tabRouteStack[state.currentTab]!.last;

  // On android we always use global navigator
  bool _checkIfGlobalNavigatorNeeded(bool global) {
    return global || Platform.isAndroid;
  }

  GlobalKey<NavigatorState> getNavigator({bool global = false}) {
    // if we need global navigator return global key
    if (_checkIfGlobalNavigatorNeeded(global)) {
      return globalNavigatorKey;
    }

    // otherwise return navigator key for current tab
    final currentTab = state.currentTab;

    return tabNavigatorKeys[currentTab]!;
  }

  GlobalKey<NavigatorState> getNavigatorForTab(AppTab tab) {
    return tabNavigatorKeys[tab]!;
  }

  void pop({dynamic payload, bool global = false}) {
    final navigator = getNavigator(global: _checkIfGlobalNavigatorNeeded(global));

    navigationStack.pop(state.currentTab, _checkIfGlobalNavigatorNeeded(global));

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
    // Firstly check if element is already in stack
    // if it is and uniqueInStack flag is set to true we just return immediately
    if (uniqueInStack && !navigationStack.checkUnique(routeName, state.currentTab, _checkIfGlobalNavigatorNeeded(global)) && !replace) {
      return;
    }

    final navigator = getNavigator(global: _checkIfGlobalNavigatorNeeded(global));

    final route = NavigationUtilities.buildPageRoute(routes[routeName]!(payload), fullScreenDialog, routeName);

    if (replace) {
      // if replace flag is provided we clear stack and navigator state
      navigationStack.replaceStack(routeName, state.currentTab, _checkIfGlobalNavigatorNeeded(global), uniqueInStack);

      unawaited(navigator.currentState?.pushAndRemoveUntil(
        route,
        (route) => false,
      ));
    } else {
      // otherwise we just add route and push it to navigator
      navigationStack.addRoute(routeName, state.currentTab, _checkIfGlobalNavigatorNeeded(global), uniqueInStack, true);

      final result = await navigator.currentState?.push(
        route,
      );

      return result;
    }
  }

  Future<dynamic> showDialog(
    Dialogs dialogName, {
    Map<String, dynamic>? payload,
    bool dismissable = true,
    bool global = false,
  }) async {
    final navigator = getNavigator(global: _checkIfGlobalNavigatorNeeded(global));

    navigationStack.addRoute(dialogName, state.currentTab, _checkIfGlobalNavigatorNeeded(global), true, dismissable);

    final result = await NavigationUtilities.pushDialogRoute(
      navigator: navigator,
      dismissable: dismissable,
      child: dialogs[dialogName]!(payload),
    );

    if (!navigationStack.checkUnique(dialogName, state.currentTab, _checkIfGlobalNavigatorNeeded(global))) {
      // this means that bottom sheet was closed by tap to outside space
      // because dialogs are unique in stack
      navigationStack.pop(state.currentTab, _checkIfGlobalNavigatorNeeded(global));
    }

    return result;
  }

  Future<dynamic> showBottomSheet(
    BottomSheets bottomSheetName, {
    Map<String, dynamic>? payload,
    bool global = false,
    bool dismissable = true,
  }) async {
    final navigator = getNavigator(global: _checkIfGlobalNavigatorNeeded(global));

    navigationStack.addRoute(bottomSheetName, state.currentTab, _checkIfGlobalNavigatorNeeded(global), true, dismissable);

    final result = await NavigationUtilities.pushBottomSheetRoute(
      navigator: navigator,
      dismissable: dismissable,
      child: bottomSheets[bottomSheetName]!(payload),
      onClosed: () {
        navigationStack.pop(state.currentTab, _checkIfGlobalNavigatorNeeded(global));
      },
    );

    if (!navigationStack.checkUnique(bottomSheetName, state.currentTab, _checkIfGlobalNavigatorNeeded(global))) {
      // this means that bottom sheet was closed by tap to outside space
      // because bottom sheets are unique in stack
      navigationStack.pop(state.currentTab, _checkIfGlobalNavigatorNeeded(global));
    }

    return result;
  }

  void setCurrentTab(AppTab tab) {
    updateState(state.copyWith(currentTab: tab));
  }

  @override
  NavigationState get initialState => NavigationState(currentTab: AppTabs.posts);
}
