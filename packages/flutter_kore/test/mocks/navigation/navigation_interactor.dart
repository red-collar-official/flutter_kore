import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';

import '../deep_links/deep_links_interactor.dart';
import 'components/app_tab.dart';
import 'components/bottom_sheets/bottom_sheets.dart';
import 'components/dialogs/dialogs.dart';
import 'components/screens/routes.dart';
import 'navigation_state.dart';

final postsNavigatorKey = GlobalKey<NavigatorState>();
final likedPostsNavigatorKey = GlobalKey<NavigatorState>();

@singleton
class NavigationInteractor extends BaseNavigationInteractor<
    NavigationState,
    Map<String, dynamic>,
    AppTab,
    Routes,
    Dialogs,
    BottomSheets,
    RouteNames,
    DialogNames,
    BottomSheetNames,
    TestDeepLinksInteractor> {
  final _routes = Routes();
  final _dialogs = Dialogs();
  final _bottomSheets = BottomSheets();

  @override
  AppTab? get currentTab => state.currentTab;

  @override
  Map<AppTab, GlobalKey<NavigatorState>> get currentTabKeys => {
        AppTabs.posts: postsNavigatorKey,
        AppTabs.likedPosts: likedPostsNavigatorKey,
      };

  @override
  NavigationInteractorSettings get settings =>
      const NavigationInteractorSettings(
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
  BottomSheets get bottomSheets => _bottomSheets;
  @override
  Dialogs get dialogs => _dialogs;
  @override
  Routes get routes => _routes;

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
  NavigationState get initialState => NavigationState(
        currentTab: AppTabs.posts,
      );
}
