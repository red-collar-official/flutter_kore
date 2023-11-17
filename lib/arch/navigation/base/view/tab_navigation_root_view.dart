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
        View extends BaseWidget,
        ScreenState,
        ViewModel extends TabNavigationRootViewModel<View, ScreenState>>
    extends NavigationView<View, ScreenState, ViewModel> {
  Widget tabNavigationContainer({
    required bool offstage,
    required GlobalKey<NavigatorState> navigationKey,
    required Widget view,
    required String name,
  }) {
    return Offstage(
      offstage: offstage,
      child: HeroControllerScope(
        controller: MaterialApp.createMaterialHeroController(),
        child: Navigator(
          initialRoute: name,
          key: navigationKey,
          onGenerateRoute: (_) => MaterialPageRoute(
            builder: (_) => Builder(
              builder: (_) => view,
            ),
          ),
        ),
      ),
    );
  }
}
