import 'dart:async';

import 'package:umvvm_template/domain/data/data.dart';
import 'package:umvvm_template/domain/global/global.dart';
import 'package:umvvm_template/domain/interactors/interactors.dart';
import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

import 'home_view.dart';
import 'home_view_state.dart';

class HomeViewModel extends NavigationViewModel<HomeView, HomeViewState> {
  final Map<AppTab, GlobalKey<NavigatorState>> tabNavigatorKeys = {
    AppTabs.posts: GlobalKey<NavigatorState>(),
    AppTabs.likedPosts: GlobalKey<NavigatorState>(),
  };

  @override
  void onLaunch() {
    app.navigation.currentTabKeys = tabNavigatorKeys;
  }

  GlobalKey<NavigatorState> getNavigatorKey(AppTab tab) {
    return tabNavigatorKeys[tab]!;
  }

  void changeTab(AppTab tab) {
    app.navigation.setCurrentTab(tab);
  }

  AppTab get initialTab => app.navigation.state.currentTab;

  Stream<AppTab?> get currentTabStream =>
      app.instances.get<NavigationInteractor>().updates((state) => state.currentTab);

  @override
  HomeViewState get initialState => const HomeViewState();
}
