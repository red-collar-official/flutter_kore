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
abstract class TabNavigationRootView<
        AppTabType,
        View extends BaseWidget,
        ScreenState,
        ViewModel extends TabNavigationRootViewModel<View, ScreenState>>
    extends NavigationView<View, ScreenState, ViewModel> {
  Widget tabNavigationContainer({
    required bool offstage,
    required GlobalKey<NavigatorState> navigationKey,
    required Widget view,
    required String name,
    required AppTabType tab,
  }) {
    return Offstage(
      offstage: offstage,
      child: PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) {
          if (didPop) {
            return;
          }

          viewModel.onPop();
        },
        child: HeroControllerScope(
          controller: MaterialApp.createMaterialHeroController(),
          child: NavigationPopScope(
            initialRoute: name,
            initialView: view,
            navigator: navigationKey,
            onPop: () {
              viewModel.onPop();
            },
            stackStream: UMvvmApp.navigationInteractor!.navigationStack
                .tabNavigationStack.stackStream
                .map((event) => event[tab] ?? []),
            initialStack: UMvvmApp.navigationInteractor!.navigationStack
                    .tabNavigationStack.stack[tab] ??
                [],
          ),
        ),
      ),
    );
  }
}
