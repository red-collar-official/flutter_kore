import 'package:flutter/material.dart';
import 'package:sample_database/domain/global/global_store.dart';
import 'package:sample_database/domain/interactors/navigation/components/screens/routes.dart';
import 'package:umvvm/umvvm.dart';

class TestMapper extends LinkMapper {
  @override
  UIRoute constructRoute(
    Map<String, String> pathParams,
    Map<String, String> queryParams,
  ) {
    return UIRoute<RouteNames>(
      name: RouteNames.postsRegex,
      defaultSettings: const UIRouteSettings(),
      child: Container(),
    );
  }

  @override
  (Map<String, String>, Map<String, String>) mapParamsFromUrl(String url) {
    return (
      {
        'testParam': 'qwerty',
      },
      {},
    );
  }

  @override
  Future<void> openRoute(UIRoute route) async {
    await app.navigation.routeTo(route as UIRoute<RouteNames>);
  }
}
