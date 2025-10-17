import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:flutter_kore_template/domain/data/data.dart';
import 'package:flutter_kore_template/domain/global/global.dart';

import 'components/bottom_sheets/bottom_sheets.dart';
import 'components/dialogs/dialogs.dart';
import 'components/screens/routes.dart';
import 'navigation_state.dart';

part 'navigation_interactor.app_navigation.dart';

@singleton
@AppNavigation(tabs: AppTab)
class NavigationInteractor
    extends NavigationInteractorDeclaration<NavigationState> {
  @override
  AppTab? get currentTab => state.currentTab;

  @override
  Map<AppTab, GlobalKey<NavigatorState>> get currentTabKeys => {
    AppTabs.posts: GlobalKey<NavigatorState>(),
    AppTabs.likedPosts: GlobalKey<NavigatorState>(),
  };

  @override
  NavigationInteractorSettings get settings => NavigationInteractorSettings(
    initialRoute: RouteNames.splash,
    tabs: AppTabs.tabs,
    tabViewHomeRoute: RouteNames.home,
    initialTabRoutes: {
      AppTabs.posts: RouteNames.posts,
      AppTabs.likedPosts: RouteNames.likedPosts,
    },
    appContainsTabNavigation: true,
    bottomSheetsAndDialogsUsingGlobalNavigator: false,
  );

  @override
  Future<void> onBottomSheetOpened(Widget child, UIRouteSettings route) async {
    // ignore
  }

  @override
  Future<void> onDialogOpened(Widget child, UIRouteSettings route) async {
    // ignore
  }

  @override
  Future<void> onRouteOpened(Widget child, UIRouteSettings route) async {
    if (route.global) {
      app.eventBus.send(GlobalRoutePushedEvent(replace: route.replace));
    }
  }

  @override
  void setCurrentTab(AppTab tab) {
    updateState(state.copyWith(currentTab: tab));
  }

  @override
  NavigationState get initialState =>
      const NavigationState(currentTab: AppTabs.posts);
}
