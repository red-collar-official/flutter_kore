import 'package:sample_database/domain/interactors/interactors.dart';
import 'package:sample_database/ui/post/post_view.dart';

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
