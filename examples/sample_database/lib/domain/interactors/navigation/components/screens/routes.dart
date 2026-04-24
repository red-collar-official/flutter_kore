import 'package:flutter/material.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/ui/post/post_view.dart';
import 'package:flutter_kore/flutter_kore.dart';

part 'routes.navigation.dart';

@routes
class Routes extends RoutesBase with RoutesGen {
  UIRoute<RouteNames> post({Post? post, int? id, int? filter}) {
    return UIRoute(
      name: .post,
      defaultSettings: const UIRouteSettings(),
      child: PostView(post: post, id: id),
    );
  }

  UIRoute<RouteNames> posts() {
    return UIRoute(
      name: .posts,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  UIRoute<RouteNames> stub() {
    return UIRoute(
      name: .stub,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  UIRoute<RouteNames> home() {
    return UIRoute(
      name: .home,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  UIRoute<RouteNames> likedPosts() {
    return UIRoute(
      name: .likedPosts,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  UIRoute<RouteNames> postsRegex() {
    return UIRoute(
      name: .postsRegex,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }
}
