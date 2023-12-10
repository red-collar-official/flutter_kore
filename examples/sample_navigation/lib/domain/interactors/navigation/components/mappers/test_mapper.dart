import 'package:flutter/material.dart';
import 'package:sample_navigation/domain/global/global_app.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/routes.dart';
import 'package:umvvm/umvvm.dart';

class TestMapper extends LinkMapper {
  @override
  UIRoute constructRoute(LinkParams params) {
    return UIRoute<RouteNames>(
      name: RouteNames.postsRegex,
      defaultSettings: const UIRouteSettings(),
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
