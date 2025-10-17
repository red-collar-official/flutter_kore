import 'package:flutter_kore/flutter_kore.dart';
import 'package:flutter_kore_template/domain/data/data.dart';
import 'package:flutter_kore_template/domain/global/global.dart';

import 'posts_state.dart';

@basicInstance
class PostsInteractor extends BaseInteractor<PostsState, Map<String, dynamic>> {
  Future<void> loadPosts(int offset, int limit, {bool refresh = false}) async {
    updateState(state.copyWith(posts: const LoadingData()));

    late Response<List<Post>> response;

    if (refresh) {
      response = await app.apis.test.getPosts(0, limit).execute();
    } else {
      response = await app.apis.test.getPosts(offset, limit).execute();
    }

    if (response.isSuccessful) {
      updateState(
        state.copyWith(posts: SuccessData(result: response.result ?? [])),
      );
    } else {
      updateState(state.copyWith(posts: ErrorData(error: response.error)));
    }
  }

  @override
  PostsState get initialState => const PostsState();

  @override
  List<EventBusSubscriber> subscribe() => [
        on<PostLikedEvent>((event) {
          // ignore
        }),
      ];
}
