import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';
import 'package:umvvm_template/domain/global/global.dart';
import 'package:umvvm_template/ui/screens.dart';

part 'routes.navigation.dart';

@routes
class Routes extends RoutesBase with RoutesGen {
  @Link(
    paths: ['posts'],
  )
  UIRoute<RouteNames> posts({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.posts,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  UIRoute<RouteNames> likedPosts() {
    return UIRoute(
      name: RouteNames.likedPosts,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  UIRoute<RouteNames> splash() {
    return const UIRoute<RouteNames>(
      name: RouteNames.splash,
      child: SplashView(),
      defaultSettings: UIRouteSettings(
        uniqueInStack: true,
        global: true,
      ),
    );
  }

  UIRoute<RouteNames> home() {
    return const UIRoute(
      name: RouteNames.home,
      defaultSettings: UIRouteSettings(),
      child: HomeView(),
    );
  }

  // TODO: place routes here
}
