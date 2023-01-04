import 'package:sample_database/domain/data/app_tab.dart';
import 'package:sample_database/domain/interactors/navigation/components/route_model.dart';
import 'package:sample_database/domain/interactors/navigation/components/screens/routes.dart';
import 'package:flutter/material.dart';

final globalNavigatorKey = GlobalKey<NavigatorState>();
final routeObserver = RouteObserver<ModalRoute<void>>();

/// Default stack for global navigator
final List<RouteModel> defaultRouteStack = [
  const RouteModel(
    name: Routes.home,
    dismissable: false,
  ),
];

/// Default stacks for every tab navigator
final Map<AppTab, List<RouteModel>> defaultTabRouteStack = {
  AppTabs.posts: [
    const RouteModel(
      name: Routes.posts,
      dismissable: false,
    ),
  ],
  AppTabs.likedPosts: [
    const RouteModel(
      name: Routes.likedPosts,
      dismissable: false,
    ),
  ],
};

/// Global keys for every tab navigator
final Map<AppTab, GlobalKey<NavigatorState>> tabNavigatorKeys = {
  AppTabs.posts: GlobalKey<NavigatorState>(),
  AppTabs.likedPosts: GlobalKey<NavigatorState>(),
};
