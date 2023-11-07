// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dialogs.dart';

// **************************************************************************
// MainNavigationGenerator
// **************************************************************************

// ignore_for_file: unnecessary_parenthesis, unused_local_variable, prefer_final_locals, unnecessary_string_interpolations, join_return_with_assignment
class PostLinkHandler extends DialogLinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    final resultUrl =
        (UMvvmApp.navigationInteractor!.settings.baseLinkUrl ?? '') +
            (pathPrefix ?? '');
    var pathUrl = '$resultUrl';
    pathUrl += '/${paramsForLink!['id']}';
    pathUrl += '?filter=${paramsForQuery!['filter']}';

    return pathUrl;
  }

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

    final route = app.navigation.dialogs
        .post(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this
          ..paramsForLink = pathParams
          ..paramsForQuery = queryParamsForView
          ..pathPrefix = '/posts');

    return route;
  }
}

class Post2LinkHandler extends DialogLinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    final resultUrl =
        (UMvvmApp.navigationInteractor!.settings.baseLinkUrl ?? '') +
            (pathPrefix ?? '');
    var pathUrl = '$resultUrl';
    pathUrl += '/${paramsForLink!['id']}';
    pathUrl += '?filter=${paramsForQuery!['filter']}';

    return pathUrl;
  }

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

    final route = app.navigation.dialogs
        .post2(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this
          ..paramsForLink = pathParams
          ..paramsForQuery = queryParamsForView
          ..pathPrefix = '/posts');

    return route;
  }
}

class Post3LinkHandler extends DialogLinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    final resultUrl =
        (UMvvmApp.navigationInteractor!.settings.baseLinkUrl ?? '') +
            (pathPrefix ?? '');
    var pathUrl = '$resultUrl';
    pathUrl += '/${paramsForLink!['id']}';
    pathUrl += '?filter=${paramsForQuery!['filter']}';
    pathUrl += '&query=${paramsForQuery!['query']}';

    return pathUrl;
  }

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

    final route = app.navigation.dialogs
        .post3(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this
          ..paramsForLink = pathParams
          ..paramsForQuery = queryParamsForView
          ..pathPrefix = '/posts');

    return route;
  }
}

class Post4LinkHandler extends DialogLinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    final resultUrl =
        (UMvvmApp.navigationInteractor!.settings.baseLinkUrl ?? '') +
            (pathPrefix ?? '');
    var pathUrl = '$resultUrl';
    pathUrl += '/${paramsForLink!['id']}';
    pathUrl += '?filter=${paramsForQuery!['filter']}';
    pathUrl += '&query=${paramsForQuery!['query']}';

    return pathUrl;
  }

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

    final route = app.navigation.dialogs
        .post4(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this
          ..paramsForLink = pathParams
          ..paramsForQuery = queryParamsForView
          ..pathPrefix = '/posts/test');

    return route;
  }
}

class PostsLinkHandler extends DialogLinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    final resultUrl =
        (UMvvmApp.navigationInteractor!.settings.baseLinkUrl ?? '') +
            (pathPrefix ?? '');
    var pathUrl = '$resultUrl';
    return pathUrl;
  }

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

    final route = app.navigation.dialogs
        .posts(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this
          ..paramsForLink = pathParams
          ..paramsForQuery = queryParamsForView
          ..pathPrefix = '/posts');

    return route;
  }
}

class Posts2LinkHandler extends DialogLinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    final resultUrl =
        (UMvvmApp.navigationInteractor!.settings.baseLinkUrl ?? '') +
            (pathPrefix ?? '');
    var pathUrl = '$resultUrl';
    pathUrl += '?filter=${paramsForQuery!['filter']}';

    return pathUrl;
  }

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

    final route = app.navigation.dialogs
        .posts2(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this
          ..paramsForLink = pathParams
          ..paramsForQuery = queryParamsForView
          ..pathPrefix = '/posts');

    return route;
  }
}

class StubLinkHandler extends DialogLinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    final resultUrl =
        (UMvvmApp.navigationInteractor!.settings.baseLinkUrl ?? '') +
            (pathPrefix ?? '');
    var pathUrl = '$resultUrl';
    pathUrl += '?filter=${paramsForQuery!['filter']}';

    return pathUrl;
  }

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

    final route = app.navigation.dialogs
        .stub(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this
          ..paramsForLink = pathParams
          ..paramsForQuery = queryParamsForView
          ..pathPrefix = '/stub');

    return route;
  }
}

class HomeLinkHandler extends DialogLinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    final resultUrl =
        (UMvvmApp.navigationInteractor!.settings.baseLinkUrl ?? '') +
            (pathPrefix ?? '');
    var pathUrl = '$resultUrl';
    return pathUrl;
  }

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

    final route = app.navigation.dialogs
        .home(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this
          ..paramsForLink = pathParams
          ..paramsForQuery = queryParamsForView
          ..pathPrefix = '/home');

    return route;
  }
}

class LikedPostsLinkHandler extends DialogLinkHandler {
  @override
  Future<String> generateLinkForRoute() async {
    final resultUrl =
        (UMvvmApp.navigationInteractor!.settings.baseLinkUrl ?? '') +
            (pathPrefix ?? '');
    var pathUrl = '$resultUrl';
    return pathUrl;
  }

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

    final route = app.navigation.dialogs
        .likedPosts(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        )
        .copyWithLinkHandler(this
          ..paramsForLink = pathParams
          ..paramsForQuery = queryParamsForView
          ..pathPrefix = '/likedPosts');

    return route;
  }
}

enum DialogNames {
  post,
  postCustom,
  post2,
  post3,
  post4,
  posts,
  posts2,
  stub,
  home,
  likedPosts,
}

mixin DialogsGen on RoutesBase {
  @override
  void initializeLinkHandlers() {
    routeLinkHandlers.addAll({
      'posts': {
        '*': {
          '': {
            'filter': PostLinkHandler(),
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
