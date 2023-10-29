import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

import 'route_names.dart';

class Routes {
  static UIRoute<RouteNames> post({
    int? number,
    int? id,
  }) {
    return UIRoute<RouteNames>(
      name: RouteNames.post,
      child: Container(),
      defaultSettings: const UIRouteSettings(),
    );
  }

  static UIRoute<RouteNames> stub() {
    return UIRoute<RouteNames>(
      name: RouteNames.stub,
      child: Container(),
      defaultSettings: const UIRouteSettings(),
    );
  }

  static UIRoute<RouteNames> home() {
    return UIRoute<RouteNames>(
      name: RouteNames.home,
      child: Container(),
      defaultSettings: const UIRouteSettings(),
    );
  }
}
