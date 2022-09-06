import 'package:mvvm_redux/arch/http/base_request.dart';
import 'package:sample/domain/apis/base/request.dart';
import 'package:sample/domain/apis/posts_api.dart';
import 'package:sample/domain/data/post.dart';
import 'package:sample/domain/data/stateful_data.dart';
import 'package:sample/domain/global/apis.dart';
import 'package:sample/domain/global/global_store.dart';
import 'package:sample/domain/interactors/posts/posts_interactor.dart';
import 'package:test/test.dart';

class MockPostsApi extends PostsApi {
  @override
  HttpRequest<List<Post>> getPosts(int offset, int limit) => HttpRequest<List<Post>>()
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
    
    Apis.posts = MockPostsApi();

    final postsInteractor = PostsInteractor();
    app.interactors.addTest<PostsInteractor>(postsInteractor);

    await postsInteractor.loadPosts(0, 30);

    expect((postsInteractor.state.posts! as ResultData).result[0].id, 1);
  });
}
