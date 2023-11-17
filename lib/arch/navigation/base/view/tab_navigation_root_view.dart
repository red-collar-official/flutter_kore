import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

/// View model for root tab navigation view
/// Must be extended by view containing [bottomNavigationBar]
abstract class TabNavigationRootViewModel<Widget extends StatefulWidget, State>
    extends NavigationViewModel<Widget, State> {
  void onPop() {
    navigationInteractor.homeBackButtonGlobalCallback();
  }
}

/// Base view state for root tab navigation view
/// Must be extended by view containing [bottomNavigationBar]
abstract class TabNavigationRootView<View extends BaseWidget, ScreenState,
        ViewModel extends TabNavigationRootViewModel<View, ScreenState>>
    extends NavigationView<View, ScreenState, ViewModel> {
  Widget tabNavigationContainer({
    required bool offstage,
    required GlobalKey<NavigatorState> navigationKey,
    required Widget view,
    required String name,
    required dynamic tab,
  }) {
    final navigationInteractor = UMvvmApp.navigationInteractor!;

    return Offstage(
      offstage: offstage,
      child: HeroControllerScope(
        controller: MaterialApp.createMaterialHeroController(),
        child: NavigationPopScope(
          initialRoute: name,
          initialView: view,
          navigator: navigationKey,
          onPop: () {
            UMvvmApp.navigationInteractor!.homeBackButtonGlobalCallback();
          },
          stackStream: UMvvmApp.navigationInteractor!.navigationStack
              .globalNavigationStack.stackStream,
          initialStack: () =>
              navigationInteractor.navigationStack.globalNavigationStack.stack,
          currentTabStackStream:
              navigationInteractor.settings.appContainsTabNavigation
                  ? navigationInteractor
                      .navigationStack.tabNavigationStack.stackStream
                      .map((event) => event[tab] ?? [])
                  : null,
          currentTabInitialStack:
              navigationInteractor.settings.appContainsTabNavigation
                  ? () =>
                      navigationInteractor
                          .navigationStack.tabNavigationStack.stack[tab] ??
                      []
                  : null,
        ),
      ),
    );
  }
}
