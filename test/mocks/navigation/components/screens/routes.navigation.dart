// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'routes.dart';

// **************************************************************************
// MainNavigationGenerator
// **************************************************************************

// ignore_for_file: unnecessary_parenthesis, unused_local_variable, prefer_final_locals, unnecessary_string_interpolations, join_return_with_assignment
class PostLinkHandler extends RouteLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('posts/:{id}');
    final patternQuery = [
      'filter',
    ];
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];

      if (pathSegmentPattern == ':{id}') {
        pathParams['id'] = segments[index];
      }
    }

    for (var index = 0; index < patternQuery.length; index++) {
      final queryParam = patternQuery[index];

      queryParamsForView['filter'] = queryParams[queryParam] ?? [];
    }

    final route = app.navigation.routes
        .post(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this);

    return route;
  }
}

class PostArrayLinkHandler extends RouteLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('posts/:{id}');
    final patternQuery = [
      'filter',
    ];
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];

      if (pathSegmentPattern == ':{id}') {
        pathParams['id'] = segments[index];
      }
    }

    for (var index = 0; index < patternQuery.length; index++) {
      final queryParam = patternQuery[index];

      queryParamsForView['filter'] = queryParams[queryParam] ?? [];
    }

    final route = app.navigation.routes
        .postArray(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this);

    return route;
  }
}

class Post2LinkHandler extends RouteLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('posts/:{id}');
    final patternQuery = [
      'filter',
    ];
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];

      if (pathSegmentPattern == ':{id}') {
        pathParams['id'] = segments[index];
      }
    }

    for (var index = 0; index < patternQuery.length; index++) {
      final queryParam = patternQuery[index];

      queryParamsForView['filter'] = queryParams[queryParam] ?? [];
    }

    final route = app.navigation.routes
        .post2(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this);

    return route;
  }
}

class Post3LinkHandler extends RouteLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('posts/:{id}');
    final patternQuery = [
      'filter',
      'query',
    ];
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];

      if (pathSegmentPattern == ':{id}') {
        pathParams['id'] = segments[index];
      }
    }

    for (var index = 0; index < patternQuery.length; index++) {
      final queryParam = patternQuery[index];

      queryParamsForView['filter'] = queryParams[queryParam] ?? [];
      queryParamsForView['query'] = queryParams[queryParam] ?? [];
    }

    final route = app.navigation.routes
        .post3(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this);

    return route;
  }
}

class Post4LinkHandler extends RouteLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('posts/:{id}/test');
    final patternQuery = [
      'filter',
      'query',
    ];
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];

      if (pathSegmentPattern == ':{id}') {
        pathParams['id'] = segments[index];
      }
    }

    for (var index = 0; index < patternQuery.length; index++) {
      final queryParam = patternQuery[index];

      queryParamsForView['filter'] = queryParams[queryParam] ?? [];
      queryParamsForView['query'] = queryParams[queryParam] ?? [];
    }

    final route = app.navigation.routes
        .post4(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this);

    return route;
  }
}

class PostsLinkHandler extends RouteLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('posts');
    final patternQuery = [];
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];
    }

    for (var index = 0; index < patternQuery.length; index++) {
      final queryParam = patternQuery[index];
    }

    final route = app.navigation.routes
        .posts(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this);

    return route;
  }
}

class Posts2LinkHandler extends RouteLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('posts');
    final patternQuery = [
      'filter',
    ];
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];
    }

    for (var index = 0; index < patternQuery.length; index++) {
      final queryParam = patternQuery[index];

      queryParamsForView['filter'] = queryParams[queryParam] ?? [];
    }

    final route = app.navigation.routes
        .posts2(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this);

    return route;
  }
}

class StubLinkHandler extends RouteLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('stub');
    final patternQuery = [
      'filter',
    ];
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];
    }

    for (var index = 0; index < patternQuery.length; index++) {
      final queryParam = patternQuery[index];

      queryParamsForView['filter'] = queryParams[queryParam] ?? [];
    }

    final route = app.navigation.routes
        .stub(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this);

    return route;
  }
}

class HomeLinkHandler extends RouteLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('home');
    final patternQuery = [];
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];
    }

    for (var index = 0; index < patternQuery.length; index++) {
      final queryParam = patternQuery[index];
    }

    final route = app.navigation.routes
        .home(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this);

    return route;
  }
}

class LikedPostsLinkHandler extends RouteLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('likedPosts');
    final patternQuery = [];
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];
    }

    for (var index = 0; index < patternQuery.length; index++) {
      final queryParam = patternQuery[index];
    }

    final route = app.navigation.routes
        .likedPosts(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this);

    return route;
  }
}

enum RouteNames {
  post,
  postCustom,
  postArray,
  post2,
  post3,
  post4,
  posts,
  posts2,
  stub,
  home,
  likedPosts,
}

mixin RoutesGen on RoutesBase {
  @override
  void initializeLinkHandlers() {
    routeLinkHandlers.addAll({
      'posts': {
        '*': {
          '': {
            'filter': PostLinkHandler(),
            'filter=[qwerty1,qwerty2]': PostArrayLinkHandler(),
            'filter=qwerty': Post2LinkHandler(),
            'filter|query?': Post3LinkHandler(),
          },
          '*': {
            '': {
              'filter=qwerty1|filter=qwerty2': TestHandler(),
            },
          },
          'test': {
            '': {
              'filter|query?': Post4LinkHandler(),
            },
          },
        },
        '': {
          '': PostsLinkHandler(),
          'filter': Posts2LinkHandler(),
        },
      },
      'stub': {
        '': {
          'filter': StubLinkHandler(),
        },
      },
      'home': {
        '': HomeLinkHandler(),
      },
      'likedPosts': {
        '': LikedPostsLinkHandler(),
      },
    });
  }
}
