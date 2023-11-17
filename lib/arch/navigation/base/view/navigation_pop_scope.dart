// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

import 'navigation_pop_handler.dart';

class NavigationPopScope extends StatelessWidget {
  const NavigationPopScope({
    super.key,
    required this.initialRoute,
    required this.initialView,
    required this.navigator,
    required this.onPop,
    required this.stackStream,
    required this.initialStack,
    this.currentTabStackStream,
    this.currentTabInitialStack,
  });

  final String initialRoute;
  final Widget initialView;
  final GlobalKey<NavigatorState> navigator;
  final VoidCallback onPop;
  final Stream<List<UIRouteModel>> stackStream;
  final List<UIRouteModel> Function() initialStack;
  final Stream<List<UIRouteModel>>? currentTabStackStream;
  final List<UIRouteModel> Function()? currentTabInitialStack;

  @override
  Widget build(BuildContext context) {
    return UINavigatorPopHandler(
      onPop: onPop,
      stackStream: stackStream,
      initialStack: initialStack,
      currentTabInitialStack: currentTabInitialStack,
      currentTabStackStream: currentTabStackStream,
      child: Navigator(
        initialRoute: initialRoute,
        key: navigator,
        onGenerateRoute: (_) => MaterialPageRoute(
          builder: (_) => Builder(
            builder: (_) => initialView,
          ),
        ),
      ),
    );
  }
}

class GlobalNavigationPopScope extends StatelessWidget {
  const GlobalNavigationPopScope({
    super.key,
    required this.initialRoute,
    required this.initialView,
  });

  final String initialRoute;
  final Widget initialView;

  @override
  Widget build(BuildContext context) {
    final navigationInteractor = UMvvmApp.navigationInteractor!;
    return NavigationPopScope(
      initialRoute: initialRoute,
      initialView: initialView,
      navigator: UMvvmApp.navigationInteractor!.globalNavigatorKey,
      onPop: () {
        UMvvmApp.navigationInteractor!.homeBackButtonGlobalCallback();
      },
      stackStream: UMvvmApp.navigationInteractor!.navigationStack
          .globalNavigationStack.stackStream,
      initialStack: () =>
          navigationInteractor.navigationStack.globalNavigationStack.stack,
      currentTabStackStream: navigationInteractor
              .settings.appContainsTabNavigation
          ? navigationInteractor.navigationStack.tabNavigationStack.stackStream
              .map((event) => event[navigationInteractor.currentTab] ?? [])
          : null,
      currentTabInitialStack:
          navigationInteractor.settings.appContainsTabNavigation
              ? () =>
                  navigationInteractor.navigationStack.tabNavigationStack
                      .stack[navigationInteractor.currentTab] ??
                  []
              : null,
    );
  }
}
