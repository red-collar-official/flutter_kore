import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/global/events.dart';
import 'package:sample_database/domain/global/global_app.dart';
import 'package:sample_database/domain/interactors/mixins/like_post_mixin.dart';

import 'post_state.dart';

@Instance(inputType: Post)
class PostInteractor extends BaseInteractor<PostState, Post>
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
  PostState get initialState =>
      PostState(post: input == null ? null : SuccessData(result: input!));

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
