// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dialogs.dart';

// **************************************************************************
// MainNavigationGenerator
// **************************************************************************

// ignore_for_file: unnecessary_parenthesis, unused_local_variable, prefer_final_locals, unnecessary_string_interpolations, join_return_with_assignment, unnecessary_raw_strings
class PostLinkHandler1 extends DialogLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('posts/:{id}');
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];

      if (pathSegmentPattern == ':{id}') {
        pathParams['id'] = segments[index];
      }
    }

    for (final param in queryParams.entries) {
      final queryParam = param.key;
      dynamic queryValue = param.value;

      if (queryValue.length == 1) {
        queryParamsForView[queryParam] = queryValue[0];
      } else if (queryValue.length > 1) {
        queryParamsForView[queryParam] = queryValue;
      }
    }

    final route = app.navigation.dialogs.post(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class Post2LinkHandler1 extends DialogLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('posts/:{id}');
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];

      if (pathSegmentPattern == ':{id}') {
        pathParams['id'] = segments[index];
      }
    }

    for (final param in queryParams.entries) {
      final queryParam = param.key;
      dynamic queryValue = param.value;

      if (queryValue.length == 1) {
        queryParamsForView[queryParam] = queryValue[0];
      } else if (queryValue.length > 1) {
        queryParamsForView[queryParam] = queryValue;
      }
    }

    final route = app.navigation.dialogs.post2(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class Post3LinkHandler1 extends DialogLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('posts/:{id}');
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];

      if (pathSegmentPattern == ':{id}') {
        pathParams['id'] = segments[index];
      }
    }

    for (final param in queryParams.entries) {
      final queryParam = param.key;
      dynamic queryValue = param.value;

      if (queryValue.length == 1) {
        queryParamsForView[queryParam] = queryValue[0];
      } else if (queryValue.length > 1) {
        queryParamsForView[queryParam] = queryValue;
      }
    }

    final route = app.navigation.dialogs.post3(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class Post4LinkHandler1 extends DialogLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('posts/:{id}/test');
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];

      if (pathSegmentPattern == ':{id}') {
        pathParams['id'] = segments[index];
      }
    }

    for (final param in queryParams.entries) {
      final queryParam = param.key;
      dynamic queryValue = param.value;

      if (queryValue.length == 1) {
        queryParamsForView[queryParam] = queryValue[0];
      } else if (queryValue.length > 1) {
        queryParamsForView[queryParam] = queryValue;
      }
    }

    final route = app.navigation.dialogs.post4(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class PostsLinkHandler1 extends DialogLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('posts');
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];
    }

    for (final param in queryParams.entries) {
      final queryParam = param.key;
      dynamic queryValue = param.value;

      if (queryValue.length == 1) {
        queryParamsForView[queryParam] = queryValue[0];
      } else if (queryValue.length > 1) {
        queryParamsForView[queryParam] = queryValue;
      }
    }

    final route = app.navigation.dialogs.posts(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class Posts2LinkHandler1 extends DialogLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('posts');
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];
    }

    for (final param in queryParams.entries) {
      final queryParam = param.key;
      dynamic queryValue = param.value;

      if (queryValue.length == 1) {
        queryParamsForView[queryParam] = queryValue[0];
      } else if (queryValue.length > 1) {
        queryParamsForView[queryParam] = queryValue;
      }
    }

    final route = app.navigation.dialogs.posts2(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class StubLinkHandler1 extends DialogLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('stub');
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];
    }

    for (final param in queryParams.entries) {
      final queryParam = param.key;
      dynamic queryValue = param.value;

      if (queryValue.length == 1) {
        queryParamsForView[queryParam] = queryValue[0];
      } else if (queryValue.length > 1) {
        queryParamsForView[queryParam] = queryValue;
      }
    }

    final route = app.navigation.dialogs.stub(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class HomeLinkHandler1 extends DialogLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('home');
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];
    }

    for (final param in queryParams.entries) {
      final queryParam = param.key;
      dynamic queryValue = param.value;

      if (queryValue.length == 1) {
        queryParamsForView[queryParam] = queryValue[0];
      } else if (queryValue.length > 1) {
        queryParamsForView[queryParam] = queryValue;
      }
    }

    final route = app.navigation.dialogs.home(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class LikedPostsLinkHandler1 extends DialogLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('likedPosts');
    final patternSegments = patternUriPath.pathSegments;

    Map<String, dynamic> queryParamsForView = {};
    Map<String, dynamic> pathParams = {};

    for (var index = 0; index < patternSegments.length; index++) {
      final pathSegmentPattern = patternSegments[index];
    }

    for (final param in queryParams.entries) {
      final queryParam = param.key;
      dynamic queryValue = param.value;

      if (queryValue.length == 1) {
        queryParamsForView[queryParam] = queryValue[0];
      } else if (queryValue.length > 1) {
        queryParamsForView[queryParam] = queryValue;
      }
    }

    final route = app.navigation.dialogs.likedPosts(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

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
  postsRegex,
}

mixin DialogsGen on RoutesBase {
  @override
  void initializeLinkHandlers() {
    routeLinkHandlers.addAll({
      'posts': {
        '*': {
          '': {
            'filter': PostLinkHandler1(),
            'filter=qwerty': Post2LinkHandler1(),
            'filter|query?': Post3LinkHandler1(),
          },
          '*': {
            '': {
              'filter=qwerty1|filter=qwerty2': TestHandler(),
            },
          },
          'test': {
            '': {
              'filter|query?': Post4LinkHandler1(),
            },
          },
        },
        '': {
          '': PostsLinkHandler1(),
          'filter': Posts2LinkHandler1(),
        },
      },
      'stub': {
        '': {
          'filter': StubLinkHandler1(),
        },
      },
      'home': {
        '': HomeLinkHandler1(),
      },
      'likedPosts': {
        '': LikedPostsLinkHandler1(),
      },
    });
    regexHandlers.addAll({
      r'(.*?)': TestMapper(),
    });
  }
}
