import 'package:flutter/material.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_database/domain/data/app_tab.dart';
import 'package:sample_database/domain/global/global_store.dart';
import 'package:sample_database/domain/interactors/navigation/navigation_interactor.dart';

import 'home_view.dart';
import 'home_view_state.dart';

class HomeViewModel extends TabNavigationRootViewModel<HomeView, HomeViewState> {
  @override
  List<Connector> dependsOn(HomeView input) => [];

  final Map<AppTab, GlobalKey<NavigatorState>> tabNavigatorKeys = {
    AppTabs.posts: GlobalKey<NavigatorState>(),
    AppTabs.likedPosts: GlobalKey<NavigatorState>(),
  };

  @override
  void onLaunch(HomeView widget) {
    app.navigation.currentTabKeys = tabNavigatorKeys;
  }

  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    updateState(HomeViewState.fromJson(savedStateObject));
  }

  Future<bool> onWillPop() async {
    await app.interactors
        .get<NavigationInteractor>()
        .homeBackButtonGlobalCallback();

    return false;
  }

  GlobalKey<NavigatorState> getNavigatorKey(AppTab tab) {
    return app.navigation.getNavigatorForTab(tab);
  }

  void changeTab(AppTab tab) {
    app.navigation.setCurrentTab(tab);
  }

  AppTab get initialTab => app.navigation.state.currentTab;

  Stream<AppTab?> get currentTabStream => app.interactors
      .get<NavigationInteractor>()
      .updates((state) => state.currentTab);

  @override
  Map<String, dynamic> get savedStateObject => state.toJson();

  @override
  HomeViewState initialState(HomeView input) => HomeViewState();
}
