import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/global/events.dart';
import 'package:sample_database/domain/global/global_store.dart';
import 'package:sample_database/domain/interactors/mixins/like_post_mixin.dart';

import 'post_state.dart';

@defaultInteractor
class PostInteractor extends BaseInteractor<PostState, Map<String, dynamic>>
    with LikePostMixin {
  Future<void> loadPost(int id, {bool refresh = false}) async {
    updateState(state.copyWith(post: const LoadingData()));

    final response = await app.apis.posts.getPost(id).execute();

    if (response.isSuccessful) {
      updateState(state.copyWith(post: ResultData(result: response.result!)));
    } else {
      updateState(state.copyWith(post: ErrorData(error: response.error)));
    }
  }

  void useExistingPost(Post post) {
    updateState(state.copyWith(post: ResultData(result: post)));
  }

  void _onPostLiked() {
    final post = state.post!.unwrap();
    final currentLike = post.isLiked;

    final newPost = post.copyWith(isLiked: !currentLike);
    updateState(state.copyWith(post: ResultData(result: newPost)));
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
