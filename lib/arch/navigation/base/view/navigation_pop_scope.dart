// coverage:ignore-file

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

class NavigationPopScope extends StatelessWidget {
  const NavigationPopScope({
    super.key,
    required this.initialRoute,
    required this.initialView,
    required this.navigator,
    required this.onPop,
    required this.stackStream,
    required this.initialStack,
  });

  final String initialRoute;
  final Widget initialView;
  final GlobalKey<NavigatorState> navigator;
  final VoidCallback onPop;
  final Stream<List<UIRouteModel>> stackStream;
  final List<UIRouteModel> initialStack;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UIRouteModel>>(
      stream: stackStream,
      initialData: initialStack,
      builder: (context, snapshot) {
        final stack = snapshot.data ?? [];

        final isPopDisabled = stack.isEmpty ||
            !stack.last.settings.dismissable ||
            stack.last.settings.needToEnsureClose;

        return PopScope(
          canPop: !isPopDisabled,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }

            onPop.call();
          },
          // Listen to changes in the navigation stack in the widget subtree.
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
      },
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
    return NavigationPopScope(
      initialRoute: initialRoute,
      initialView: initialView,
      navigator: UMvvmApp.navigationInteractor!.globalNavigatorKey,
      onPop: () {
        UMvvmApp.navigationInteractor!.homeBackButtonGlobalCallback(
          global: true,
        );
      },
      stackStream: UMvvmApp.navigationInteractor!.navigationStack
          .globalNavigationStack.stackStream,
      initialStack: UMvvmApp
          .navigationInteractor!.navigationStack.globalNavigationStack.stack,
    );
  }
}
