import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

import '../../../global_app/app.dart';

part 'routes.navigation.dart';

class TestHandler extends LinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    return UIRoute<RouteNames>(
      name: RouteNames.stub,
      defaultSettings: const UIRouteSettings(global: true),
      child: Container(),
    );
  }

  @override
  Future<void> processRoute(UIRoute route) async {
    await app.navigation.routeTo(route as UIRoute<RouteNames>);
  }
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
    int? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.post,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
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
    int? post,
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
    path: 'posts/:{id}/:{type}',
    query: [
      'filter=qwerty1|qwerty2',
    ],
    customHandler: TestHandler,
  )
  UIRoute<RouteNames> postCustom({
    int? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postCustom,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
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
    int? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.post2,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }

  @Link(
    path: 'posts/:{id}',
    query: ['filter', 'query?'],
  )
  UIRoute<RouteNames> post3({
    int? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.post3,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }

  @Link(
    path: 'posts/:{id}/test',
    query: ['filter', 'query?'],
  )
  UIRoute<RouteNames> post4({
    int? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.post4,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
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
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
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
      name: RouteNames.posts2,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
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
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
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
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
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
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }
}
