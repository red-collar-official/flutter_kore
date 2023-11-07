import 'dart:async';

import 'package:umvvm/umvvm.dart';

/// Class describing parser for link and mapping to route
abstract class LinkHandler {
  /// Maps given url to navigation [UIRoute]
  /// if you want to skip this url return null
  Future<UIRoute?> parseLinkToRoute(String url);

  /// Opens constructed route
  Future<void> processRoute(UIRoute? route);
}

/// Generic link handler used for regexes parsing
class GenericLinkHandler extends LinkHandler {
  final LinkMapper mapper;

  GenericLinkHandler({
    required this.mapper,
  });

  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final params = mapper.mapParamsFromUrl(url);

    return mapper.constructRoute(params.$1, params.$2, params.$3);
  }

  @override
  Future<void> processRoute(UIRoute? route) async {
    if (route == null) {
      return;
    }

    await mapper.openRoute(route);
  }
}

/// Link handler for routes
abstract class RouteLinkHandler extends LinkHandler {
  @override
  Future<void> processRoute(UIRoute? route) async {
    if (route == null) {
      return;
    }

    await UMvvmApp.navigationInteractor?.routeTo(route);
  }
}

/// Link handler for dialogs
abstract class DialogLinkHandler extends LinkHandler {
  @override
  Future<void> processRoute(UIRoute? route) async {
    if (route == null) {
      return;
    }

    await UMvvmApp.navigationInteractor?.showDialog(route);
  }
}

/// Link handler for bottom sheets
abstract class BottomSheetLinkHandler extends LinkHandler {
  @override
  Future<void> processRoute(UIRoute? route) async {
    if (route == null) {
      return;
    }
    
    await UMvvmApp.navigationInteractor?.showBottomSheet(route);
  }
}
