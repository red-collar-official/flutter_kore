import 'package:flutter/material.dart';
import 'package:umvvm/arch/navigation/base/view/navigation_view_model.dart';
import 'package:umvvm/arch/view/base_widget.dart';

/// View model for root tab navigation view
/// Must be extended by view containing [bottomNavigationBar] 
abstract class TabNavigationRootViewModel<Widget extends StatefulWidget, State>
    extends NavigationViewModel<Widget, State> {
  Future<bool> onWillPop() async {
    await navigationInteractor.homeBackButtonGlobalCallback();

    return false;
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
  }) {
    return Offstage(
      offstage: offstage,
      child: WillPopScope(
        onWillPop: viewModel.onWillPop,
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
      ),
    );
  }
}
