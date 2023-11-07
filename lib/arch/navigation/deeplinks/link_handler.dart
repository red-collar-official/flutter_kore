import 'dart:async';

import 'package:umvvm/umvvm.dart';

abstract class LinkHandler {
  Future<UIRoute> parseLinkToRoute(String url);
  Future<String> generateLinkForRoute();

  Map? paramsForLink;
  Map? paramsForQuery;
  String? pathPrefix;

  Future<void> processRoute(UIRoute route);
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
