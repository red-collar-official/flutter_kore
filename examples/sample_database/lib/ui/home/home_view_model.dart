import 'package:flutter/material.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_database/domain/data/app_tab.dart';
import 'package:sample_database/domain/global/global_store.dart';
import 'package:sample_database/domain/interactors/navigation/navigation_interactor.dart';

import 'home_view.dart';
import 'home_view_state.dart';

class HomeViewModel extends BaseViewModel<HomeView, HomeViewState> {
  @override
  List<Connector> dependsOn(HomeView widget) => [];

  @override
  void onLaunch(HomeView widget) {
    // ignore
  }

  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    updateState(HomeViewState.fromJson(savedStateObject));
  }

  GlobalKey<NavigatorState> getNavigatorKey(AppTab tab) {
    return app.interactors.get<NavigationInteractor>().getNavigatorForTab(tab);
  }

  void changeTab(AppTab tab) {
    app.interactors.get<NavigationInteractor>().setCurrentTab(tab);
  }

  AppTab get initialTab =>
      app.interactors.get<NavigationInteractor>().state.currentTab!;

  Stream<AppTab?> get currentTabStream => app.interactors
      .get<NavigationInteractor>()
      .updates((state) => state.currentTab);

  @override
  Map<String, dynamic> get savedStateObject => state.toJson();

  @override
  HomeViewState initialState(HomeView widget) => HomeViewState();
}
