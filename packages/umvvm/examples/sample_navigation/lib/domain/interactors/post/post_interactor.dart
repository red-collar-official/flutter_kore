import 'package:umvvm/umvvm.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/domain/global/events.dart';
import 'package:sample_navigation/domain/global/global_store.dart';
import 'package:sample_navigation/domain/interactors/mixins/like_post_mixin.dart';

import 'post_state.dart';

@basicInstance
class PostInteractor extends BaseInteractor<PostState, Map<String, dynamic>>
    with LikePostMixin {
  Future<void> loadPost(int id, {bool refresh = false}) async {
    updateState(state.copyWith(post: const LoadingData()));

    final response = await app.apis.posts.getPost(id).execute();

    if (response.isSuccessful) {
      updateState(state.copyWith(post: SuccessData(result: response.result!)));
    } else {
      updateState(state.copyWith(post: ErrorData(error: response.error)));
    }
  }

  void useExistingPost(Post post) {
    updateState(state.copyWith(post: SuccessData(result: post)));
  }

  void _onPostLiked() {
    final post = state.post!.unwrap();
    final currentLike = post.isLiked;

    final newPost = post.copyWith(isLiked: !currentLike);
    updateState(state.copyWith(post: SuccessData(result: newPost)));
  }

  @override
  PostState initialState(Map<String, dynamic>? input) => PostState();

  @override
  List<EventBusSubscriber> subscribe() => [
        on<PostLikedEvent>((event) {
          if (state.post is SuccessData<Post> &&
              event.id == (state.post as SuccessData<Post>).result.id) {
            _onPostLiked();
          }
        }),
      ];
}
