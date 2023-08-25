import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/ui/post/post_view.dart';

import 'route_names.dart';

class Routes {
  static UIRoute<RouteNames> post({
    Post? post,
    int? id,
  }) {
    return UIRoute<RouteNames>(
      name: RouteNames.post,
      child: PostView(
        post: post,
        id: id,
      ),
      defaultSettings: const UIRouteSettings(),
    );
  }
}
