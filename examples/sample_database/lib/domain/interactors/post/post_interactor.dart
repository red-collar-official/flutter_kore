import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/data/stateful_data.dart';
import 'package:sample_database/domain/global/events.dart';
import 'package:sample_database/domain/global/global_store.dart';
import 'package:sample_database/domain/interactors/mixins/like_post_mixin.dart';

import 'post_state.dart';

@defaultInteractor
class PostInteractor extends BaseInteractor<PostState, Map<String, dynamic>>
    with LikePostMixin {
  Future<void> loadPost(int id, {bool refresh = false}) async {
    updateState(state.copyWith(post: StatefulData.loading()));

    final response = await app.apis.posts.getPost(id).execute();

    if (response.isSuccessful) {
      updateState(state.copyWith(post: StatefulData.result(response.result!)));
    } else {
      updateState(state.copyWith(post: StatefulData.error(response.error)));
    }
  }

  void useExistingPost(Post post) {
    updateState(state.copyWith(post: StatefulData.result(post)));
  }

  void _onPostLiked() {
    final currentLike = (state.post as ResultData<Post?>).result!.isLiked;

    final newPost = StatefulData.result((state.post as ResultData<Post?>)
        .result!
        .copyWith(isLiked: !currentLike));
    updateState(state.copyWith(post: newPost));
  }

  @override
  PostState initialState(Map<String, dynamic>? input) => PostState();

  @override
  List<EventBusSubscriber> subscribe() => [
        on<PostLikedEvent>((event) {
          if (state.post is ResultData<Post> &&
              event.id == (state.post as ResultData<Post>).result.id) {
            _onPostLiked();
          }
        }),
      ];
}
