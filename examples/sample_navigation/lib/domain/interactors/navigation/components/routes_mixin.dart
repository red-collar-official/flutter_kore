import 'package:sample_navigation/ui/post/post_view.dart';

import '../navigation_interactor.dart';
import 'routes.dart';

mixin RoutesMixin {
  Map<Routes, RouteBuilder> routes = {
    Routes.post: (payload) {
      return PostView(
        post: payload?['post'],
        id: payload?['id'],
      );
    },
  };
}
