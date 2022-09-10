import 'package:sample_database/domain/global/events.dart';
import 'package:sample_database/domain/global/global_store.dart';

mixin LikePostMixin {
  Future<bool> likePost(int id) async {
    final result = await app.apis.posts.likePost(id).execute();

    if (result.isSuccessful) {
      app.eventBus.send(Events.eventPostLiked, payload: id);
    }

    return result.isSuccessful;
  }
}
