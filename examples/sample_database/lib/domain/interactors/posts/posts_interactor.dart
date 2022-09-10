import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/data/stateful_data.dart';
import 'package:sample_database/domain/global/events.dart';
import 'package:sample_database/domain/global/global_store.dart';
import 'package:sample_database/domain/interactors/mixins/like_post_mixin.dart';

import 'posts_state.dart';

@defaultInteractor
class PostsInteractor extends BaseInteractor<PostsState> with LikePostMixin {
  Future<void> loadPosts(int offset, int limit, {bool refresh = false}) async {
    updateState(state.copyWith(posts: StatefulData.loading()));

    late Response<List<Post>> response;

    if (refresh) {
      response = await app.apis.posts.getPosts(0, limit).execute();
    } else {
      response = await app.apis.posts.getPosts(offset, limit).execute();
    }

    if (response.isSuccessful || response.isSuccessfulFromDatabase) {
      updateState(state.copyWith(posts: StatefulData.result(response.result ?? [])));
    } else {
      updateState(state.copyWith(posts: StatefulData.error(response.error)));
    }
  }

  void _onPostLiked(int id) {
    final posts = (state.posts as ResultData<List<Post>>).result.toList();
    final index = posts.indexWhere((element) => element.id == id);

    if (index == -1) {
      return;
    }

    posts[index] = posts[index].copyWith(isLiked: !posts[index].isLiked);

    updateState(state.copyWith(posts: StatefulData.result(posts)));
  }

  @override
  PostsState get initialState => PostsState();

  @override
  Map<String, EventBusSubscriber> get subscribeTo => {
        Events.eventPostLiked: (payload) {
          _onPostLiked(payload);
        }
      };
}
