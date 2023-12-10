import 'package:sample_navigation/domain/global/events.dart';
import 'package:sample_navigation/domain/global/global_app.dart';

mixin LikePostMixin {
  Future<bool> likePost(int id) async {
    final result = await app.apis.posts.likePost(id).execute();

    if (result.isSuccessful) {
      app.eventBus.send(PostLikedEvent(id: id));
    }

    return result.isSuccessful;
  }
}
