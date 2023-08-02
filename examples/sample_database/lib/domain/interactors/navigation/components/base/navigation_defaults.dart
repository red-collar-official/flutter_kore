import 'package:flutter/material.dart';
import 'package:sample_database/domain/data/app_tab.dart';
import 'package:sample_database/domain/interactors/navigation/components/route_model.dart';
import 'package:sample_database/domain/interactors/navigation/components/screens/routes.dart';

final globalNavigatorKey = GlobalKey<NavigatorState>();
final bottomSheetDialogNavigatorKey = GlobalKey<NavigatorState>();
final routeObserver = RouteObserver<ModalRoute<void>>();

RouteModel _defailtRouteModelFor(Routes route) => RouteModel(
      name: route,
      dismissable: false,
    );

/// Default stack for global navigator
List<RouteModel> defaultRouteStack() => [
      _defailtRouteModelFor(Routes.home),
    ];

/// Default stacks for every tab navigator
Map<AppTab, List<RouteModel>> defaultTabRouteStack() => {
      AppTabs.posts: [_defailtRouteModelFor(Routes.posts)],
      AppTabs.likedPosts: [_defailtRouteModelFor(Routes.likedPosts)],
    };
