import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample/domain/data/post.dart';
import 'package:sample/domain/data/stateful_data.dart';
import 'package:sample/domain/global/apis.dart';
import 'package:sample/domain/global/events.dart';
import 'package:sample/domain/interactors/mixins/like_post_mixin.dart';

import 'post_state.dart';

@defaultInteractor
class PostInteractor extends BaseInteractor<PostState> with LikePostMixin {
  Future<void> loadPost(int id, {bool refresh = false}) async {
    updateState(state.copyWith(post: StatefulData.loading()));

    final response = await Apis.posts.getPost(id).execute();

    if (response.isSuccessful || response.isSuccessfulFromDatabase) {
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

    final newPost = StatefulData.result((state.post as ResultData<Post?>).result!.copyWith(isLiked: !currentLike));
    updateState(state.copyWith(post: newPost));
  }

  @override
  PostState get initialState => PostState();

  @override
  Map<String, EventBusSubscriber> get subscribeTo => {
        Events.eventPostLiked: (payload) {
          if (state.post is ResultData<Post> && payload == (state.post as ResultData<Post>).result.id) {
            _onPostLiked();
          }
        }
      };
}
