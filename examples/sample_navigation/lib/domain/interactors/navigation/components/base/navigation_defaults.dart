import 'package:sample_navigation/domain/data/app_tab.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/route_model.dart';
import 'package:flutter/material.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/route_names.dart';

final globalNavigatorKey = GlobalKey<NavigatorState>();
final bottomSheetDialogNavigatorKey = GlobalKey<NavigatorState>();
final routeObserver = RouteObserver<ModalRoute<void>>();

UIRouteModel _defailtRouteModelFor(RouteNames route) => UIRouteModel(
      name: route,
      settings: const UIRouteSettings(
        dismissable: false,
      ),
    );

/// Default stack for global navigator
List<UIRouteModel> defaultRouteStack() => [
      _defailtRouteModelFor(RouteNames.home),
    ];

/// Default stacks for every tab navigator
Map<AppTab, List<UIRouteModel>> defaultTabRouteStack() => {
      AppTabs.posts: [_defailtRouteModelFor(RouteNames.posts)],
      AppTabs.likedPosts: [_defailtRouteModelFor(RouteNames.likedPosts)],
    };
