import 'package:sample/domain/global/apis.dart';
import 'package:sample/domain/global/events.dart';
import 'package:sample/domain/global/global_store.dart';

mixin LikePostMixin {
  Future<bool> likePost(int id) async {
    final result = await Apis.posts.likePost(id).execute();

    if (result.isSuccessful) {
      app.eventBus.send(Events.eventPostLiked, payload: id);
    }

    return result.isSuccessful;
  }
}
