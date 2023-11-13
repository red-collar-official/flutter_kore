import 'package:umvvm/umvvm.dart';
import 'package:sample_basic/domain/data/post.dart';
import 'package:sample_basic/domain/global/events.dart';
import 'package:sample_basic/domain/global/global_store.dart';
import 'package:sample_basic/domain/interactors/mixins/like_post_mixin.dart';

import 'posts_state.dart';

@instancePart
class TestInteractorPart extends BaseInstancePart<void, PostsInteractor> {
  void testUpdate() {
    parentInstance.updateState(parentInstance.state.copyWith(
      active: false,
    ));
  }
}

@basicInstance
class PostsInteractor extends BaseInteractor<PostsState, Map<String, dynamic>?>
    with LikePostMixin {
  @override
  List<PartConnector> parts(Map<String, dynamic>? input) => [
        app.connectors.testInteractorPartConnector(),
      ];

  late final testPart = useInstancePart<TestInteractorPart>();

  Future<void> loadPosts(int offset, int limit, {bool refresh = false}) async {
    updateState(state.copyWith(posts: const LoadingData()));

    late Response<List<Post>> response;

    if (refresh) {
      response = await executeAndCancelOnDispose(
        app.apis.posts.getPosts(0, limit),
      );
    } else {
      response = await app.apis.posts.getPosts(offset, limit).execute();
    }

    if (response.isSuccessful) {
      updateState(
          state.copyWith(posts: SuccessData(result: response.result ?? [])));
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
  PostsState initialState(Map<String, dynamic>? input) => PostsState();

  @override
  List<EventBusSubscriber> subscribe() => [
        on<PostLikedEvent>(
          (event) {
            _onPostLiked(event.id);
          },
          reactsToPause: true,
          firesAfterResume: false,
        ),
      ];
}
