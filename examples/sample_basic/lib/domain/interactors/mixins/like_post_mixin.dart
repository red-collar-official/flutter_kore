import 'package:sample_basic/domain/global/events.dart';
import 'package:sample_basic/domain/global/global_store.dart';

mixin LikePostMixin {
  Future<bool> likePost(int id) async {
    app.interactors.debugPrintMap();
    
    final result = await app.apis.posts.likePost(id).execute();

    if (result.isSuccessful) {
      app.eventBus.send(Events.eventPostLiked, payload: id);
    }

    return result.isSuccessful;
  }
}
