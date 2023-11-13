import 'dart:async';

import 'package:umvvm/umvvm.dart';

/// Class describing parser for link and mapping to route
///
/// Example:
///
/// ```dart
/// class PostLinkHandler extends BottomSheetLinkHandler {
///   @override
///   Future<UIRoute> parseLinkToRoute(String url) async {
///     final uriPath = Uri.parse(url);
///     final segments = uriPath.pathSegments;
///     final queryParams = uriPath.queryParametersAll;
///
///     final patternUriPath = Uri.parse('posts/:{id}');
///     final patternQuery = [
///       'filter',
///     ];
///     final patternSegments = patternUriPath.pathSegments;
///
///     Map<String, dynamic> queryParamsForView = {};
///     Map<String, dynamic> pathParams = {};
///
///     for (var index = 0; index < patternSegments.length; index++) {
///       final pathSegmentPattern = patternSegments[index];
///
///       if (pathSegmentPattern == ':{id}') {
///         pathParams['id'] = segments[index];
///       }
///     }
///
///     for (var index = 0; index < patternQuery.length; index++) {
///       final queryParam = patternQuery[index];
///
///       queryParamsForView['filter'] = queryParams[queryParam] ?? [];
///     }
///
///     final route = app.navigation.bottomSheets.post(
///       pathParams: pathParams,
///       queryParams: queryParamsForView,
///     );
///
///     return route;
///   }
/// }
/// ```
abstract class LinkHandler {
  const LinkHandler();

  /// Maps given url to navigation [UIRoute]
  /// if you want to skip this url return null
  Future<UIRoute?> parseLinkToRoute(String url);

  /// Opens constructed route
  Future<void> processRoute(UIRoute route);
}

/// Generic link handler used for regexes parsing
class GenericLinkHandler extends LinkHandler {
  final LinkMapper mapper;

  const GenericLinkHandler({
    required this.mapper,
  });

  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final params = mapper.mapParamsFromUrl(url);

    return mapper.constructRoute(params);
  }

  @override
  Future<void> processRoute(UIRoute route) async {
    await mapper.openRoute(route);
  }
}

/// Link handler for routes
abstract class RouteLinkHandler extends LinkHandler {
  @override
  Future<void> processRoute(UIRoute route) async {
    await UMvvmApp.navigationInteractor?.routeTo(route);
  }
}

/// Link handler for dialogs
abstract class DialogLinkHandler extends LinkHandler {
  @override
  Future<void> processRoute(UIRoute route) async {
    await UMvvmApp.navigationInteractor?.showDialog(route);
  }
}

/// Link handler for bottom sheets
abstract class BottomSheetLinkHandler extends LinkHandler {
  @override
  Future<void> processRoute(UIRoute route) async {
    await UMvvmApp.navigationInteractor?.showBottomSheet(route);
  }
}
