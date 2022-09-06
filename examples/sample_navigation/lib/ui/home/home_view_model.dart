import 'package:flutter/material.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_navigation/domain/data/app_tab.dart';
import 'package:sample_navigation/domain/global/global_store.dart';
import 'package:sample_navigation/domain/interactors/navigation/navigation_interactor.dart';

import 'home_view.dart';
import 'home_view_state.dart';

class HomeViewModel extends BaseViewModel<HomeView, HomeViewState> {
  @override
  List<Connector> get dependsOn => [];

  @override
  void onLaunch(HomeView widget) {
    // ignore
  }

  GlobalKey<NavigatorState> getNavigatorKey(AppTab tab) {
    return app.interactors.get<NavigationInteractor>().tabNavigatorKeys[tab]!;
  }

  void changeTab(AppTab tab) {
    app.interactors.get<NavigationInteractor>().setCurrentTab(tab);
  }

  AppTab get initialTab => app.interactors.get<NavigationInteractor>().state.currentTab!;

  Stream<AppTab?> get currentTabStream => app.interactors.get<NavigationInteractor>().updates((state) => state.currentTab);
}
