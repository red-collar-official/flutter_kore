import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/global/events.dart';
import 'package:sample_database/domain/global/global_app.dart';
import 'package:sample_database/domain/interactors/mixins/like_post_mixin.dart';

import 'posts_state.dart';

@basicInstance
class PostsInteractor extends BaseInteractor<PostsState, Map<String, dynamic>>
    with LikePostMixin {
  Future<void> loadPosts(int offset, int limit, {bool refresh = false}) async {
    updateState(state.copyWith(posts: const LoadingData()));

    late Response<List<Post>> response;

    if (refresh) {
      response = await app.apis.posts.getPosts(0, limit).execute();
    } else {
      response = await app.apis.posts.getPosts(offset, limit).execute();
    }

    if (response.isSuccessful) {
      updateState(
        state.copyWith(posts: SuccessData(result: response.result ?? [])),
      );
    } else {
      updateState(state.copyWith(posts: ErrorData(error: response.error)));
    }
  }

  void _onPostLiked(int id) {
    final posts = (state.posts as SuccessData<List<Post>>).result.toList();
    final index = posts.indexWhere((element) => element.id == id);

    if (index == -1) {
      return;
    }

    posts[index] = posts[index].copyWith(isLiked: !posts[index].isLiked);

    updateState(state.copyWith(posts: SuccessData(result: posts)));
  }

  @override
  PostsState get initialState => PostsState();

  @override
  List<EventBusSubscriber> subscribe() => [
        on<PostLikedEvent>((event) {
          _onPostLiked(event.id);
        }),
      ];
}
