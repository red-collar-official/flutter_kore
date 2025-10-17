import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_navigation/domain/data/app_tab.dart';
import 'package:sample_navigation/domain/global/events.dart';
import 'package:sample_navigation/domain/global/global_app.dart';

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
  NavigationInteractorSettings get settings => NavigationInteractorSettings(
        initialRoute: RouteNames.home,
        tabs: AppTabs.tabs,
        tabViewHomeRoute: RouteNames.home,
        initialTabRoutes: {
          AppTabs.posts: RouteNames.posts,
          AppTabs.likedPosts: RouteNames.likedPosts,
        },
        appContainsTabNavigation: true,
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
  NavigationState get initialState => NavigationState(
        currentTab: AppTabs.posts,
      );
}
