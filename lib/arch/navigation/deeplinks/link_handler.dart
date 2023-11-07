import 'dart:async';

import 'package:umvvm/umvvm.dart';

abstract class LinkHandler {
  Future<UIRoute> parseLinkToRoute(String url);

  Future<void> processRoute(UIRoute route);
}

class GenericLinkHandler extends LinkHandler {
  final LinkMapper mapper;

  GenericLinkHandler({
    required this.mapper,
  });

  @override
  Future<UIRoute> parseLinkToRoute(String url) async {
    final params = mapper.mapParamsFromUrl(url);

    return mapper.constructRoute(params.$1, params.$2);
  }

  @override
  Future<void> processRoute(UIRoute route) async {
    await mapper.openRoute(route);
  }
}

abstract class RouteLinkHandler extends LinkHandler {
  @override
  Future<void> processRoute(UIRoute route) async {
    await UMvvmApp.navigationInteractor?.routeTo(route);
  }
}

abstract class DialogLinkHandler extends LinkHandler {
  @override
  Future<void> processRoute(UIRoute route) async {
    await UMvvmApp.navigationInteractor?.showDialog(route);
  }
}

abstract class BottomSheetLinkHandler extends LinkHandler {
  @override
  Future<void> processRoute(UIRoute route) async {
    await UMvvmApp.navigationInteractor?.showBottomSheet(route);
  }
}
