import 'package:umvvm/umvvm.dart';
import 'package:sample_basic/domain/apis/base/request.dart';
import 'package:sample_basic/domain/apis/posts_api.dart';
import 'package:sample_basic/domain/data/post.dart';
import 'package:sample_basic/domain/global/global_app.dart';
import 'package:sample_basic/domain/interactors/posts/posts_interactor.dart';
import 'package:test/test.dart';

class MockPostsApi extends PostsApi {
  @override
  HttpRequest<List<Post>> getPosts(int offset, int limit) => super.getPosts(offset, limit)
    ..simulateResult = Response(code: 200, result: [
      Post(
        title: '',
        body: '',
        id: 1,
      )
    ]);
}

void main() {
  test('PostsInteractorTest', () async {
    await initApp(testMode: true);

    app.apis.posts = MockPostsApi();

    final postsInteractor = PostsInteractor();

    // ignore: cascade_invocations
    postsInteractor.initialize(null);

    await postsInteractor.loadPosts(0, 30);

    expect((postsInteractor.state.posts! as SuccessData).result[0].id, 1);
  });
}
