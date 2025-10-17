import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kore/arch/navigation/base/navigation_stack.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// Base class for navigation interactor
/// Contains state and input parameters as every other interactor
/// Also you need to specify type parameters for tabs, routes, dialogs and bottom sheets
///
/// You need to specify custom route builder or provide
/// [UINavigationSettings] values at app startup
///
/// Example:
///
/// ```dart
/// @singleton
/// @AppNavigation(tabs: AppTab)
/// class NavigationInteractor
///     extends NavigationInteractorDeclaration<NavigationState> {
///
///   @override
///   AppTab? get currentTab => state.currentTab;
///
///   @override
///   Map<AppTab, GlobalKey<NavigatorState>> get currentTabKeys => {
///         AppTabs.posts: GlobalKey<NavigatorState>(),
///         AppTabs.likedPosts: GlobalKey<NavigatorState>(),
///       };
///
///   @override
///   NavigationInteractorSettings get settings => NavigationInteractorSettings(
///         initialRoute: RouteNames.home,
///         tabs: AppTabs.tabs,
///         tabViewHomeRoute: RouteNames.home,
///         initialTabRoutes: {
///           AppTabs.posts: RouteNames.posts,
///           AppTabs.likedPosts: RouteNames.likedPosts,
///         },
///         appContainsTabNavigation: true,
///       );
///
///   @override
///   Future<void> onBottomSheetOpened(Widget child, UIRouteSettings route) async {
///     // ignore
///   }
///
///   @override
///   Future<void> onDialogOpened(Widget child, UIRouteSettings route) async {
///     // ignore
///   }
///
///   @override
///   Future<void> onRouteOpened(Widget child, UIRouteSettings route) async {
///     if (route.global) {
///       app.eventBus.send(GlobalRoutePushedEvent(replace: route.replace));
///     }
///   }
///
///   @override
///   void setCurrentTab(AppTab tab) {
///     updateState(state.copyWith(currentTab: tab));
///   }
///
///   @override
///   NavigationState get initialState => NavigationState(
///         currentTab: AppTabs.posts,
///       );
/// }
/// ```
abstract class BaseNavigationInteractor<
        IState,
        Input,
        AppTabType,
        RoutesClassType extends RoutesBase,
        DialogClassType extends RoutesBase,
        BottomSheetClassType extends RoutesBase,
        RouteType,
        DialogType,
        BottomSheetType,
        DeepLinksInteractorType extends BaseDeepLinksInteractor>
    extends BaseInteractor<IState, Input> {
  /// Deeplinks interactor for global app
  /// throws exception if deeplinks interactor not used
  late final deepLinks = InstanceCollection.instance
          .find<DeepLinksInteractorType>(BaseScopes.global)
      as DeepLinksInteractorType;

  /// Global key for main app global navigator
  ///
  /// You need to pass it to instance of MaterialApp
  final globalNavigatorKey = GlobalKey<NavigatorState>();

  /// Global key for main app bottom sheets and dialogs navigator
  ///
  /// if [NavigationInteractorSettings.bottomSheetsAndDialogsUsingGlobalNavigator] is true then it is [globalNavigatorKey]
  late final bottomSheetDialogNavigatorKey =
      settings.bottomSheetsAndDialogsUsingGlobalNavigator
          ? globalNavigatorKey
          : GlobalKey<NavigatorState>();

  /// main route observer for app
  final routeObserver = RouteObserver<ModalRoute<void>>();

  UIRouteModel _defailtRouteModelFor(RouteType route) => UIRouteModel(
        name: route,
        settings: const UIRouteSettings(
          dismissable: false,
        ),
      );

  /// Default stack for global navigator
  List<UIRouteModel> defaultRouteStack() => [
        _defailtRouteModelFor(settings.initialRoute),
      ];

  /// Default stacks for every tab navigator
  Map<AppTabType, List<UIRouteModel>> defaultTabRouteStack() =>
      settings.initialTabRoutes?.map(
        (key, value) => MapEntry(key, [_defailtRouteModelFor(value)]),
      )
      // coverage:ignore-start
      ??
      {};
  // coverage:ignore-end

  /// Contains global keys for every tab in app
  Map<AppTabType, GlobalKey<NavigatorState>> currentTabKeys = {};

  /// Settings for app navigation
  NavigationInteractorSettings get settings;

  /// Settings for app navigation
  RoutesClassType get routes;

  /// Settings for app navigation
  DialogClassType get dialogs;

  /// Settings for app navigation
  BottomSheetClassType get bottomSheets;

  // coverage:ignore-start

  /// Currently selected tab
  AppTabType? get currentTab => null;

  // coverage:ignore-end

  /// Callback for new route in any navigation stack
  Future<void> onRouteOpened(Widget child, UIRouteSettings route);

  /// Callback for new dialog
  Future<void> onDialogOpened(Widget child, UIRouteSettings route);

  /// Callback for new bottom sheet
  Future<void> onBottomSheetOpened(
    Widget child,
    UIRouteSettings route,
  );

  /// Main navigation stack that holds navigation history for every navigator
  late final navigationStack = NavigationStack<AppTabType>(
    routeStack: defaultRouteStack,
    tabRouteStack: defaultTabRouteStack,
  );

  /// Latest route in global stack
  UIRouteModel latestGlobalRoute() =>
      navigationStack.globalNavigationStack.stack.last;

  /// Latest route in current tab
  UIRouteModel latestTabRoute() =>
      navigationStack.tabNavigationStack.stack[currentTab]!.last;

  @mustCallSuper
  @override
  void initialize(Input? input) {
    super.initialize(input);

    routes.initializeLinkHandlers();
    dialogs.initializeLinkHandlers();
    bottomSheets.initializeLinkHandlers();

    initStack();
  }

  /// Initializes stack with [NavigationInteractorSettings.initialRoute]
  void initStack() {
    navigationStack.replaceStack(
      routeName: settings.initialRoute,
      tab: currentTab,
      settings: const UIRouteSettings(global: true, uniqueInStack: true),
    );

    navigationStack.tabNavigationStack.reset();
  }

  /// Checks if navigator now in global stack or in tab stack
  bool isInGlobalStack({bool includeBottomSheetsAndDialogs = true}) {
    if (!settings.appContainsTabNavigation) {
      return true;
    }

    final isHomePresentInStack =
        navigationStack.globalNavigationStack.stack.indexWhere(
              (element) => element.name == settings.tabViewHomeRoute,
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
    return forceGlobal || isInGlobalStack();
  }

  /// Returns navigator key based on current navigation state
  GlobalKey<NavigatorState> getNavigator({bool forceGlobal = false}) {
    if (isInGlobalStack() || forceGlobal) {
      return globalNavigatorKey;
    }

    // otherwise return navigator key for current tab
    return currentTabKeys[currentTab]!;
  }

  /// Returns global key of navigator for given tab
  GlobalKey<NavigatorState> getNavigatorForTab(AppTabType tab) {
    return currentTabKeys[tab]!;
  }

  /// Pops latest route from current navigation stack
  ///
  /// if [onlyInternalStack] is true than only removes route data from navigation stack
  /// Navigator state stays the same in this case
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

  /// Pops latest route in given tab
  ///
  /// if [onlyInternalStack] is true than only removes route data from navigation stack
  /// Navigator state stays the same in this case
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
      navigationStack.pop(tab, false);

      return;
    }

    final navigator = currentTabKeys[tab];

    navigationStack.pop(tab, false);

    navigator?.currentState?.pop(payload);
  }

  /// Opens new route
  Future<dynamic> routeTo(
    UIRoute<RouteType> routeData, {
    bool? fullScreenDialog,
    bool? replace,
    bool? replacePrevious,
    bool? uniqueInStack,
    bool? forceGlobal,
    bool? needToEnsureClose,
    bool? dismissable,
    Object? id,
    NavigationRouteBuilder? customRouteBuilder,
    bool awaitRouteResult = false,
  }) async {
    final bool global = _checkGlobalNavigatorNeeded(
      forceGlobal ?? routeData.defaultSettings.global,
    );

    final routeSettings = UIRouteSettings(
      fullScreenDialog:
          fullScreenDialog ?? routeData.defaultSettings.fullScreenDialog,
      global: global,
      uniqueInStack: uniqueInStack ?? routeData.defaultSettings.uniqueInStack,
      needToEnsureClose:
          needToEnsureClose ?? routeData.defaultSettings.needToEnsureClose,
      dismissable: dismissable ?? routeData.defaultSettings.dismissable,
      id: id ?? routeData.defaultSettings.id,
      replace: replace ?? routeData.defaultSettings.replace,
      replacePrevious:
          replacePrevious ?? routeData.defaultSettings.replacePrevious,
      name: routeData.name.toString(),
      customRouteBuilder:
          customRouteBuilder ?? routeData.defaultSettings.customRouteBuilder,
    );

    final routeName = routeData.name;

    // Firstly check if element is already in stack
    // if it is and uniqueInStack flag is set to true we just return immediately
    if (routeSettings.uniqueInStack &&
        !navigationStack.checkUnique(
          routeName: routeName,
          tab: currentTab,
          global: global,
        ) &&
        !routeSettings.replace) {
      return;
    }

    final navigator = getNavigator(forceGlobal: global);

    final screenToOpen = routeData.child;

    final routeBuilder =
        routeSettings.customRouteBuilder ?? settings.routeBuilder;

    // coverage:ignore-start
    final route = routeBuilder.buildPageRoute(
      child: screenToOpen,
      fullScreenDialog: routeSettings.fullScreenDialog,
      onSystemPop: routeSettings.replace
          ? null
          : () {
              pop(onlyInternalStack: true);
            },
    );
    // coverage:ignore-end

    if (routeSettings.replace) {
      // if replace flag is provided we clear stack and navigator state
      navigationStack
        ..clearTabNavigationStack()
        ..replaceStack(
          routeName: routeName,
          settings: routeSettings,
        );

      unawaited(onRouteOpened(screenToOpen, routeSettings));

      // coverage:ignore-start
      unawaited(navigator.currentState?.pushAndRemoveUntil(
        route,
        (route) => false,
      ));
      // coverage:ignore-end
    } else if (routeSettings.replacePrevious) {
      // if replace flag is provided we clear stack and navigator state
      navigationStack.replaceLastRoute(
        routeName: routeName,
        tab: currentTab,
        settings: routeSettings,
      );

      unawaited(onRouteOpened(screenToOpen, routeSettings));

      return await navigator.currentState?.pushReplacement(route);
    } else {
      // otherwise we just add route and push it to navigator

      navigationStack.addRoute(
        routeName: routeName,
        tab: currentTab,
        settings: routeSettings,
      );

      unawaited(onRouteOpened(screenToOpen, routeSettings));

      if (awaitRouteResult) {
        return await navigator.currentState?.push(
          route,
        );
      }

      unawaited(navigator.currentState?.push(
        route,
      ));
    }
  }

  // Opens new dialog
  Future<dynamic> showDialog(
    UIRoute<DialogType> dialog, {
    bool? forceGlobal,
    bool? dismissable,
    bool? uniqueInStack,
    Object? id,
    NavigationRouteBuilder? customRouteBuilder,
  }) async {
    final bool global = _checkGlobalNavigatorNeeded(
      forceGlobal ?? dialog.defaultSettings.global,
    );

    final dialogSettings = UIRouteSettings(
      global: global,
      uniqueInStack: uniqueInStack ?? dialog.defaultSettings.uniqueInStack,
      dismissable: dismissable ?? dialog.defaultSettings.dismissable,
      id: id ?? dialog.defaultSettings.id,
      name: dialog.name.toString(),
      customRouteBuilder:
          customRouteBuilder ?? dialog.defaultSettings.customRouteBuilder,
    );

    if (dialogSettings.uniqueInStack &&
        !navigationStack.checkUnique(
          routeName: dialog,
          tab: currentTab,
          global: true,
        )) {
      return;
    }

    final dialogName = dialog.name;

    final navigator =
        global ? bottomSheetDialogNavigatorKey : currentTabKeys[currentTab]!;

    navigationStack.addRoute(
      routeName: dialogName,
      tab: currentTab,
      settings: dialogSettings,
    );

    final dialogToOpen = dialog.child;

    unawaited(onDialogOpened(dialogToOpen, dialogSettings));

    final routeBuilder =
        dialogSettings.customRouteBuilder ?? settings.routeBuilder;

    // coverage:ignore-start
    final stackLength = global
        ? navigationStack.globalNavigationStack.stack.length
        : navigationStack.tabNavigationStack.stack[currentTab]!.length;
    // coverage:ignore-end

    final route = routeBuilder.buildDialogRoute(
      navigator: navigator,
      dismissable: dialogSettings.dismissable,
      child: dialogToOpen,
      // coverage:ignore-start
      onPop: () {
        final currentStackLength = global
            ? navigationStack.globalNavigationStack.stack.length
            : navigationStack.tabNavigationStack.stack[currentTab]!.length;

        if (currentStackLength == stackLength) {
          pop(onlyInternalStack: true);
        }
      },
      // coverage:ignore-end
    );

    final result = await navigator.currentState?.push(route);

    return result;
  }

  /// Opens new bottom sheet
  Future<dynamic> showBottomSheet(
    UIRoute<BottomSheetType> bottomSheet, {
    bool? forceGlobal,
    bool? dismissable,
    bool? uniqueInStack,
    Object? id,
    NavigationRouteBuilder? customRouteBuilder,
  }) async {
    final bool global = _checkGlobalNavigatorNeeded(
      forceGlobal ?? bottomSheet.defaultSettings.global,
    );

    final bottomSheetSettings = UIRouteSettings(
      global: global,
      uniqueInStack: uniqueInStack ?? bottomSheet.defaultSettings.uniqueInStack,
      dismissable: dismissable ?? bottomSheet.defaultSettings.dismissable,
      id: id,
      name: bottomSheet.name.toString(),
      customRouteBuilder:
          customRouteBuilder ?? bottomSheet.defaultSettings.customRouteBuilder,
    );

    if (bottomSheetSettings.uniqueInStack &&
        !navigationStack.checkUnique(
          routeName: bottomSheet,
          tab: currentTab,
          global: true,
        )) {
      return;
    }

    final bottomSheetName = bottomSheet.name;

    final navigator =
        global ? bottomSheetDialogNavigatorKey : currentTabKeys[currentTab]!;

    navigationStack.addRoute(
      routeName: bottomSheetName,
      tab: currentTab,
      settings: bottomSheetSettings,
    );

    final bottomSheetToOpen = bottomSheet.child;

    unawaited(onBottomSheetOpened(bottomSheetToOpen, bottomSheetSettings));

    final routeBuilder =
        bottomSheetSettings.customRouteBuilder ?? settings.routeBuilder;

    // coverage:ignore-start
    final stackLength = global
        ? navigationStack.globalNavigationStack.stack.length
        : navigationStack.tabNavigationStack.stack[currentTab]!.length;
    // coverage:ignore-end

    final route = routeBuilder.buildBottomSheetRoute(
      navigator: navigator,
      dismissable: bottomSheetSettings.dismissable,
      child: bottomSheetToOpen,
      // coverage:ignore-start
      onPop: () {
        final currentStackLength = global
            ? navigationStack.globalNavigationStack.stack.length
            : navigationStack.tabNavigationStack.stack[currentTab]!.length;

        if (currentStackLength == stackLength) {
          pop(onlyInternalStack: true);
        }
      },
      // coverage:ignore-end
    );

    final result = await navigator.currentState?.push(route);

    return result;
  }

  /// Sets current tab for this navigator
  void setCurrentTab(AppTabType tab);

  /// Checks if route can be popped
  ///
  /// The route cant be popped if it is root route in navigator
  /// or if latest route is not dismissable
  bool canPop({bool global = true}) {
    if (global) {
      return navigationStack.globalNavigationStack.stack.length > 1 &&
          latestGlobalRoute().settings.dismissable;
    } else {
      return navigationStack.tabNavigationStack.stack[currentTab]!.length > 1 &&
          latestTabRoute().settings.dismissable;
    }
  }

  /// Pops all dialogs bottom sheets and global routes
  void popGlobalToFirst() {
    popAllDialogsAndBottomSheets();

    final navigator = getNavigator(forceGlobal: true);

    // coverage:ignore-start
    navigator.currentState?.popUntil((route) => route.isFirst);
    // coverage:ignore-end

    navigationStack.replaceStack(
      routeName:
          navigationStack.globalNavigationStack.stack.first.name as RouteType,
      settings: const UIRouteSettings(global: true, uniqueInStack: true),
    );
  }

  /// Pops all dialogs bottom sheets and global routes in given tab
  void popInTabToFirst(AppTabType appTab, {bool clearStack = true}) {
    final navigator = currentTabKeys[appTab];

    if (navigator == null) {
      return;
    }

    // coverage:ignore-start
    navigator.currentState?.popUntil((route) => route.isFirst);
    // coverage:ignore-end

    if (!clearStack) {
      return;
    }

    final firstRoute = navigationStack.tabNavigationStack.stack[currentTab]![0];

    navigationStack.tabNavigationStack.replaceStack(
      routeName: firstRoute.name as RouteType,
      tab: appTab,
      settings: const UIRouteSettings(uniqueInStack: true),
    );
  }

  /// Pops all dialogs bottom sheets and global routes and opens given tab
  void popToTab(AppTabType tab) {
    popGlobalToFirst();
    setCurrentTab(tab);
  }

  /// Pops every route in every navigator to root view
  void popAllNavigatiorsToFirst() {
    popGlobalToFirst();
    popAllTabsToFirst();
  }

  /// Pops all dialogs bottom sheets
  void popAllDialogsAndBottomSheets() {
    while (isInBottomSheetDialogScope) {
      navigationStack.pop(currentTab, true);
    }

    // coverage:ignore-start
    bottomSheetDialogNavigatorKey.currentState?.popUntil(
      (route) => route.isFirst,
    );
    // coverage:ignore-end
  }

  /// Pops every route dialog and bottom sheet until current route name is [routeName]
  void popUntil(Object routeName, {bool forceGlobal = false}) {
    if (forceGlobal || isInGlobalStack()) {
      popGlobalUntil(routeName);
    } else {
      popInTabUntil(routeName);
    }
  }

  /// Pops every global route dialog and bottom sheet until current route name is [routeName]
  void popGlobalUntil(Object routeName) {
    while (canPop() && latestGlobalRoute().name != routeName) {
      pop();
    }
  }

  /// Pops every tab route dialog and bottom sheet until current route name is [routeName] in given tab
  void popInTabUntil(Object routeName) {
    while (canPop(global: false) && latestTabRoute().name != routeName) {
      pop();
    }
  }

  /// Pops all tabs to root view
  void popAllTabsToFirst() {
    // ignore: prefer_foreach
    for (final element in settings.tabs ?? []) {
      popInTabToFirst(element, clearStack: false);
    }

    navigationStack.clearTabNavigationStack();
  }

  /// Handles system back button events
  void homeBackButtonGlobalCallback() {
    final isGlobal = isInGlobalStack();

    if (isInBottomSheetDialogScope) {
      pop();
    } else if ((isGlobal ? latestGlobalRoute() : latestTabRoute())
        .settings
        .needToEnsureClose) {
      EventBus.instance.send(EnsureCloseRequestedEvent());
    } else if (canPop(global: isGlobal)) {
      pop();
    }
  }

  /// Checks if latest route is bottom sheet or dialog
  bool get isInBottomSheetDialogScope {
    return latestGlobalRoute().name is BottomSheetType ||
        latestGlobalRoute().name is DialogType;
  }

  /// Checks if global navigator contains given route
  bool containsGlobalRoute(Object routeName) {
    return navigationStack.globalNavigationStack.stack
            .indexWhere((element) => element.name == routeName) !=
        -1;
  }

  /// Tries to open link based on routes declaration and open mapped route
  ///
  /// Returns false if no possible link handler found
  Future<bool> openLink(
    String link, {
    bool preferDialogs = false,
    bool preferBottomSheets = false,
    bool? fullScreenDialog,
    bool? replace,
    bool? replacePrevious,
    bool? uniqueInStack,
    bool? forceGlobal,
    bool? needToEnsureClose,
    bool? dismissable,
    Object? id,
    NavigationRouteBuilder? customRouteBuilder,
  }) async {
    var routeHandler = _findHandlerForLink(
      link,
      preferBottomSheets: preferBottomSheets,
      preferDialogs: preferDialogs,
    );

    if (routeHandler == null) {
      routeHandler = _findRegexHandlerForLink(
        link,
        preferBottomSheets: preferBottomSheets,
        preferDialogs: preferDialogs,
      );

      if (routeHandler == null) {
        return false;
      }
    }

    final route = await routeHandler.parseLinkToRoute(link);
    final routeData = route;

    if (routeData != null) {
      final bool global = _checkGlobalNavigatorNeeded(
        forceGlobal ?? routeData.defaultSettings.global,
      );

      final routeSettings = UIRouteSettings(
        fullScreenDialog:
            fullScreenDialog ?? routeData.defaultSettings.fullScreenDialog,
        global: global,
        uniqueInStack: uniqueInStack ?? routeData.defaultSettings.uniqueInStack,
        needToEnsureClose:
            needToEnsureClose ?? routeData.defaultSettings.needToEnsureClose,
        dismissable: dismissable ?? routeData.defaultSettings.dismissable,
        id: id ?? routeData.defaultSettings.id,
        replace: replace ?? routeData.defaultSettings.replace,
        replacePrevious:
            replacePrevious ?? routeData.defaultSettings.replacePrevious,
        name: routeData.name.toString(),
        customRouteBuilder:
            customRouteBuilder ?? routeData.defaultSettings.customRouteBuilder,
      );

      await routeHandler.processRoute(
        routeData.copyWithDefaultSettings(routeSettings),
      );

      return true;
    }

    return false;
  }

  /// Tries to open link based on routes declaration
  LinkHandler? _findHandlerForLink(
    String link, {
    bool preferDialogs = false,
    bool preferBottomSheets = false,
  }) {
    final matchers = <RoutesBase>[
      if (preferDialogs) dialogs,
      if (preferBottomSheets) bottomSheets,
      routes,
      if (!preferDialogs) dialogs,
      if (!preferBottomSheets) bottomSheets,
    ];

    for (final matcher in matchers) {
      final routeHandler = matcher.handlerForLink(link);

      if (routeHandler != null) {
        return routeHandler;
      }
    }

    return null;
  }

  /// Tries to open link based on route's regex declaration
  LinkHandler? _findRegexHandlerForLink(
    String link, {
    bool preferDialogs = false,
    bool preferBottomSheets = false,
  }) {
    final matchers = <RoutesBase>[
      if (preferDialogs) dialogs,
      if (preferBottomSheets) bottomSheets,
      routes,
      if (!preferDialogs) dialogs,
      if (!preferBottomSheets) bottomSheets,
    ];

    for (final matcher in matchers) {
      final routeHandler = matcher.handlerForRegex(link);

      if (routeHandler != null) {
        return routeHandler;
      }
    }

    return null;
  }
}
