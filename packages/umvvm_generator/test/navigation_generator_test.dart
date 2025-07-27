// ignore_for_file: unnecessary_string_escapes

import 'package:build/build.dart';
import 'package:test/test.dart';
import 'package:umvvm_generator/generators/builders.dart';

import 'components/test_generator.dart';

void main() {
  group('MainNavigationGenerator tests', () {
    test('Test code generation', () async {
      await testGenerator(
        'test_routes.dart',
        generateNavigation(BuilderOptions.empty),
        {
          'test_routes.dart': '''
import 'package:umvvm/umvvm.dart';

part 'test_routes.navigation.dart';

class TestMapper extends LinkMapper {
  @override
  UIRoute constructRoute(LinkParams params) {
    return UIRoute<RouteNames>(
      name: RouteNames.postsRegex,
      defaultSettings: const UIRouteSettings(
        global: true,
      ),
      child: Container(),
    );
  }

  @override
  LinkParams mapParamsFromUrl(
    String url,
  ) {
    return const LinkParams(
      pathParams: {
        'testParam': 'qwerty',
      },
      queryParams: {},
      state: null,
    );
  }

  @override
  Future<void> openRoute(UIRoute route) async {
    await app.navigation.routeTo(route as UIRoute<RouteNames>);
  }
}

class TestHandler extends LinkHandler {
  @override
  Future<UIRoute?> parseLinkToRoute(String url) async {
    return UIRoute(
      name: 'test',
      defaultSettings: const UIRouteSettings(global: true),
      child: Container(),
    );
  }

  @override
  Future<void> processRoute(UIRoute route) async {}
}

@routes
class Routes extends RoutesBase with RoutesGen {
  @Link(
    paths: ['posts/:{id}'],
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
    paths: [
      'posts/:{id}/:{type}',
      'posts/:{id}/test/test',
    ],
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
    paths: [
      'posts/:{id}',
    ],
    query: [
      'filter=qwerty1|qwerty2',
    ],
  )
  UIRoute<RouteNames> postFilterMultiplePossibleValues({
    int? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postFilterMultiplePossibleValues,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }

  @Link(
    paths: [
      'posts/:{id}',
    ],
    query: [
      'filter=qwerty1|qwerty2',
    ],
    possibleFragments: [
      'state',
    ],
  )
  UIRoute<RouteNames> postFilterMultiplePossibleValuesWithAnchor({
    int? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postFilterMultiplePossibleValuesWithAnchor,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }

  @Link(
    paths: ['posts/:{id}'],
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
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }

  @Link(
    paths: ['posts/:{id}'],
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
    paths: ['posts/:{id}'],
    query: ['filter', 'query'],
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
    paths: ['posts/:{id}/test'],
    query: ['filter', 'query'],
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
        id: queryParams!['query'],
      ),
      child: Container(),
    );
  }

  @Link(
    paths: ['posts'],
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

  @Link(paths: [
    'posts'
  ], query: [
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

  @Link(paths: [
    'stub'
  ], query: [
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
    paths: ['home'],
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
    paths: ['likedPosts'],
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

  @Link(
    regexes: [r'\bhttp:\/\/qwerty.com\b(.*?)'],
    customParamsMapper: TestMapper,
  )
  UIRoute<RouteNames> postsRegex({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postsRegex,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }

  @Link(
    paths: ['*/posts/:{id}'],
  )
  UIRoute<RouteNames> postsWithPrefix({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postsWithPrefix,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }

  @Link(
    paths: ['*/posts/test/:{id}'],
  )
  UIRoute<RouteNames> postsWithAnchor({
    String? state,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postsWithAnchor,
      defaultSettings: UIRouteSettings(
        id: state,
        global: pathParams != null,
      ),
      child: Container(),
    );
  }

  @Link(
    paths: ['*/posts/test/:{id}'],
    queriesForPath: [
      ['filter'],
    ],
  )
  UIRoute<RouteNames> postsWithQueriesForPath({
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postsWithQueriesForPath,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }
}
          ''',
        },
        outputs: {
          'generated|lib/test_routes.navigation.dart': '''
// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_routes.dart';

// **************************************************************************
// MainNavigationGenerator
// **************************************************************************

// ignore_for_file: unnecessary_parenthesis, unused_local_variable, prefer_final_locals, unnecessary_string_interpolations, join_return_with_assignment, unnecessary_raw_strings
class PostLinkHandler1 extends RouteLinkHandler {
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

    final route = app.navigation.routes.post(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class PostFilterMultiplePossibleValuesLinkHandler1 extends RouteLinkHandler {
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

    final route = app.navigation.routes.postFilterMultiplePossibleValues(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class PostFilterMultiplePossibleValuesWithAnchorLinkHandler1
    extends RouteLinkHandler {
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

    final route = app.navigation.routes
        .postFilterMultiplePossibleValuesWithAnchor(
          pathParams: pathParams,
          queryParams: queryParamsForView,
        );

    return route;
  }
}

class PostArrayLinkHandler1 extends RouteLinkHandler {
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

    final route = app.navigation.routes.postArray(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class Post2LinkHandler1 extends RouteLinkHandler {
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

    final route = app.navigation.routes.post2(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class Post3LinkHandler1 extends RouteLinkHandler {
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

    final route = app.navigation.routes.post3(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class Post4LinkHandler1 extends RouteLinkHandler {
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

    final route = app.navigation.routes.post4(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class PostsLinkHandler1 extends RouteLinkHandler {
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

    final route = app.navigation.routes.posts(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class Posts2LinkHandler1 extends RouteLinkHandler {
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

    final route = app.navigation.routes.posts2(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class StubLinkHandler1 extends RouteLinkHandler {
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

    final route = app.navigation.routes.stub(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class HomeLinkHandler1 extends RouteLinkHandler {
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

    final route = app.navigation.routes.home(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class LikedPostsLinkHandler1 extends RouteLinkHandler {
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

    final route = app.navigation.routes.likedPosts(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class PostsWithPrefixLinkHandler1 extends RouteLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('*/posts/:{id}');
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

    final route = app.navigation.routes.postsWithPrefix(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

class PostsWithAnchorLinkHandler1 extends RouteLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('*/posts/test/:{id}');
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

    final anchor = uriPath.fragment;

    final route = app.navigation.routes.postsWithAnchor(
      pathParams: pathParams,
      queryParams: queryParamsForView,
      state: anchor,
    );

    return route;
  }
}

class PostsWithQueriesForPathLinkHandler1 extends RouteLinkHandler {
  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final uriPath = Uri.parse(url);
    final segments = uriPath.pathSegments;
    final queryParams = uriPath.queryParametersAll;

    final patternUriPath = Uri.parse('*/posts/test/:{id}');
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

    final route = app.navigation.routes.postsWithQueriesForPath(
      pathParams: pathParams,
      queryParams: queryParamsForView,
    );

    return route;
  }
}

enum RouteNames {
  post,
  postCustom,
  postFilterMultiplePossibleValues,
  postFilterMultiplePossibleValuesWithAnchor,
  postArray,
  post2,
  post3,
  post4,
  posts,
  posts2,
  stub,
  home,
  likedPosts,
  postsRegex,
  postsWithPrefix,
  postsWithAnchor,
  postsWithQueriesForPath,
}

mixin RoutesGen on RoutesBase {
  @override
  void initializeLinkHandlers() {
    routeLinkHandlers.addAll({
      'posts': {
        '*': {
          '': {
            'filter': PostLinkHandler1(),
            'filter=qwerty1|filter=qwerty2':
                PostFilterMultiplePossibleValuesLinkHandler1(),
            'filter=qwerty1|filter=qwerty2|#=state':
                PostFilterMultiplePossibleValuesWithAnchorLinkHandler1(),
            'filter=[qwerty1,qwerty2]': PostArrayLinkHandler1(),
            'filter=qwerty': Post2LinkHandler1(),
            'filter|query': Post3LinkHandler1(),
          },
          '*': {
            '': {'filter=qwerty1|filter=qwerty2': TestHandler()},
          },
          'test': {
            'test': {
              '': {'filter=qwerty1|filter=qwerty2': TestHandler()},
            },
            '': {'filter|query': Post4LinkHandler1()},
          },
        },
        '': {'': PostsLinkHandler1(), 'filter': Posts2LinkHandler1()},
      },
      'stub': {
        '': {'filter': StubLinkHandler1()},
      },
      'home': {'': HomeLinkHandler1()},
      'likedPosts': {'': LikedPostsLinkHandler1()},
      '*': {
        'posts': {
          '*': {'': PostsWithPrefixLinkHandler1()},
          'test': {
            '*': {
              '': {
                '': PostsWithAnchorLinkHandler1(),
                'filter': PostsWithQueriesForPathLinkHandler1(),
              },
            },
          },
        },
      },
    });
    regexHandlers.addAll({r'\bhttp:\/\/qwerty.com\b(.*?)': TestMapper()});
  }
}
'''
        },
      );

      await testGenerator(
        'test_navigation_main.dart',
        generateNavigationInteractor(BuilderOptions.empty),
        {
          'test_navigation_main.dart': '''
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

part 'test_navigation_main.app_navigation.dart';

class AppTab {
  const AppTab();
}

class AppTabs {
  static final posts = AppTab();

  static List<AppTab> get tabs => [
        posts,
      ];
}

class NavigationState {
  const NavigationState({
    required this.currentTab,
  });

  final AppTab currentTab;
}

class Routes extends RoutesBase {}

class Dialogs extends RoutesBase {}

class BottomSheets extends RoutesBase {}

enum RouteNames {
  posts,
  home,
}

@singleton
@AppNavigation(tabs: AppTab)
class NavigationInteractor
    extends NavigationInteractorDeclaration<NavigationState> {
  @override
  AppTab? get currentTab => state.currentTab;

  @override
  Map<AppTab, GlobalKey<NavigatorState>> get currentTabKeys => {
        AppTabs.posts: GlobalKey<NavigatorState>(),
      };

  @override
  NavigationInteractorSettings get settings => NavigationInteractorSettings(
        initialRoute: RouteNames.home,
        tabs: AppTabs.tabs,
        tabViewHomeRoute: RouteNames.home,
        initialTabRoutes: {
          AppTabs.posts: RouteNames.posts,
        },
        appContainsTabNavigation: true,
      );

  @override
  Future<void> onBottomSheetOpened(Widget child, UIRouteSettings route) async {
    // ignore
  }

  @override
  Future<void> onDialogOpened(Widget child, UIRouteSettings route) async {
    // ignore
  }

  @override
  Future<void> onRouteOpened(Widget child, UIRouteSettings route) async {
  }

  @override
  void setCurrentTab(AppTab tab) {
    updateState(state.copyWith(currentTab: tab));
  }

  @override
  NavigationState get initialState => NavigationState(
        currentTab: AppTabs.posts,
      );
}
          ''',
        },
        outputs: {
          'generated|lib/test_navigation_main.app_navigation.dart': '''
// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_navigation_main.dart';

// **************************************************************************
// MainNavigationInteractorGenerator
// **************************************************************************

abstract class NavigationInteractorDeclaration<NavigationState>
    extends
        BaseNavigationInteractor<
          NavigationState,
          Map<String, dynamic>,
          AppTab,
          Routes,
          Dialogs,
          BottomSheets,
          RouteNames,
          DialogNames,
          BottomSheetNames,
          BaseDeepLinksInteractor
        > {
  final _routes = Routes();
  final _dialogs = Dialogs();
  final _bottomSheets = BottomSheets();

  @override
  BottomSheets get bottomSheets => _bottomSheets;
  @override
  Dialogs get dialogs => _dialogs;
  @override
  Routes get routes => _routes;
}
'''
        },
      );
    });

    test('Test code generation errors', () async {
      try {
        await testGenerator(
          'test_routes.dart',
          generateNavigation(BuilderOptions.empty),
          {
            'test_routes.dart': '''
import 'package:umvvm/umvvm.dart';

part 'test_routes.navigation.dart';

@routes
class Routes extends RoutesBase with RoutesGen {
  @Link(
    paths: [
      'posts/:{id}',
    ],
    query: [
      'filter=qwerty1|qwerty2',
    ],
    possibleFragments: [
      'state',
    ],
  )
  UIRoute<RouteNames> postFilterMultiplePossibleValuesWithAnchor({
    int? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postFilterMultiplePossibleValuesWithAnchor,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }

  @Link(
    paths: [
      'posts/:{id}',
    ],
    query: [
      'filter=qwerty1|qwerty2',
    ],
    possibleFragmentsForPath: [
      ['state'],
    ],
  )
  UIRoute<RouteNames> postFilterMultiplePossibleValuesWithAnchor2({
    int? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postFilterMultiplePossibleValuesWithAnchor,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }
}
          ''',
          },
        );
      } catch (e) {
        expect(
          e
              .toString()
              .contains('Multiple handlers detected for the same route'),
          true,
        );
      }
    });
  });

  test('Test code generation errors regexes and paths', () async {
    try {
      await testGenerator(
        'test_routes.dart',
        generateNavigation(BuilderOptions.empty),
        {
          'test_routes.dart': '''
import 'package:umvvm/umvvm.dart';

part 'test_routes.navigation.dart';

@routes
class Routes extends RoutesBase with RoutesGen {
  @Link(
    paths: [
      'posts/:{id}',
    ],
    regexes: [
      'filter=qwerty1|qwerty2',
    ],
  )
  UIRoute<RouteNames> postFilterMultiplePossibleValuesWithAnchor({
    int? post,
    int? id,
    int? filter,
    Map<String, dynamic>? pathParams,
    Map<String, dynamic>? queryParams,
  }) {
    return UIRoute(
      name: RouteNames.postFilterMultiplePossibleValuesWithAnchor,
      defaultSettings: UIRouteSettings(
        global: pathParams != null,
      ),
      child: Container(),
    );
  }
}
          ''',
        },
      );
    } catch (e) {
      expect(
        e.toString().contains('Cant add paths and regexes to the same route'),
        true,
      );
    }
  });
}
