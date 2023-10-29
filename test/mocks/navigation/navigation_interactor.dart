import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

import 'components/app_tab.dart';
import 'components/bottom_sheets/bottom_sheet_names.dart';
import 'components/dialogs/dialog_names.dart';
import 'components/screens/route_names.dart';
import 'navigation_state.dart';

final postsNavigatorKey = GlobalKey<NavigatorState>();
final likedPostsNavigatorKey = GlobalKey<NavigatorState>();

@singleton
class NavigationInteractor extends BaseNavigationInteractor<NavigationState,
    Map<String, dynamic>, AppTab, RouteNames, DialogNames, BottomSheetNames> {
  @override
  RouteNames get initialRoute => RouteNames.home;

  @override
  AppTab? get currentTab => state.currentTab;

  @override
  List<AppTab>? get tabs => AppTabs.tabs;

  @override
  RouteNames? get tabViewHomeRoute => RouteNames.home;

  @override
  Map<AppTab, GlobalKey<NavigatorState>> get currentTabKeys => {
        AppTabs.posts: postsNavigatorKey,
        AppTabs.likedPosts: likedPostsNavigatorKey,
      };

  @override
  Map<AppTab, RouteNames> get initialTabRoutes => {
        AppTabs.posts: RouteNames.posts,
        AppTabs.likedPosts: RouteNames.likedPosts,
      };

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
    // ignore
  }

  @override
  void setCurrentTab(AppTab tab) {
    updateState(state.copyWith(currentTab: tab));
  }

  @override
  NavigationState initialState(Map<String, dynamic>? input) => NavigationState(
        currentTab: AppTabs.posts,
      );
}
