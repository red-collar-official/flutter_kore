import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/domain/global/global_store.dart';

part 'routes.navigation.dart';

class TestHandler extends LinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    return UIRoute(
      name: 'test',
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @override
  Future<void> processRoute(UIRoute route) async {}
}

@routes
class Routes extends RoutesBase with RoutesGen {
  @Link(
    path: 'posts/:{id}',
    query: [
      'filter',
    ],
  )
  UIRoute<RouteNames> post({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.post,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'posts/:{id}/:{type}',
    query: [
      'filter=qwerty1|qwerty2',
    ],
    customHandler: TestHandler,
  )
  UIRoute<RouteNames> postCustom({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.post,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'posts/:{id}',
    query: [
      'filter=[qwerty1,qwerty2]',
    ],
  )
  UIRoute<RouteNames> postArray({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postArray,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'posts/:{id}',
    query: [
      'filter=qwerty',
    ],
  )
  UIRoute<RouteNames> post2({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.post,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'posts/:{id}',
    query: ['filter', 'query?'],
  )
  UIRoute<RouteNames> post3({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.post,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'posts/:{id}/test',
    query: ['filter', 'query?'],
  )
  UIRoute<RouteNames> post4({
    Post? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.post,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'posts',
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

  @Link(path: 'posts', query: [
    'filter',
  ])
  UIRoute<RouteNames> posts2({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.posts,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(path: 'stub', query: [
    'filter',
  ])
  UIRoute<RouteNames> stub({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.stub,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'home',
  )
  UIRoute<RouteNames> home({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.home,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @Link(
    path: 'likedPosts',
  )
  UIRoute<RouteNames> likedPosts({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.likedPosts,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }
}
