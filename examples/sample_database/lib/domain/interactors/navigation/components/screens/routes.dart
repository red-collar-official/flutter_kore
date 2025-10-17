import 'package:flutter/material.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/interactors/navigation/components/mappers/test_mapper.dart';
import 'package:sample_database/ui/post/post_view.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_database/domain/global/global_app.dart';

part 'routes.navigation.dart';

@routes
class Routes extends RoutesBase with RoutesGen {
  UIRoute<RouteNames> post({
    Post? post,
    int? id,
    int? filter,
  }) {
    return UIRoute(
      name: RouteNames.post,
      defaultSettings: const UIRouteSettings(),
      child: PostView(
        post: post,
        id: id,
      ),
    );
  }

  UIRoute<RouteNames> posts() {
    return UIRoute(
      name: RouteNames.posts,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  UIRoute<RouteNames> stub() {
    return UIRoute(
      name: RouteNames.stub,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  UIRoute<RouteNames> home() {
    return UIRoute(
      name: RouteNames.home,
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

  UIRoute<RouteNames> postsRegex() {
    return UIRoute(
      name: RouteNames.postsRegex,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }
}
