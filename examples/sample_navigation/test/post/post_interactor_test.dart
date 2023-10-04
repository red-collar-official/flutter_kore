import 'package:umvvm/mvvm_redux.dart';
import 'package:sample_navigation/domain/apis/base/request.dart';
import 'package:sample_navigation/domain/apis/posts_api.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/domain/global/global_store.dart';
import 'package:sample_navigation/domain/interactors/post/post_interactor.dart';
import 'package:test/test.dart';

class MockPostsApi extends PostsApi {
  @override
  HttpRequest<Post?> getPost(int id) => super.getPost(id)
    ..simulateResult = Response(
        code: 200,
        result: Post(
          title: '',
          body: '',
          id: 1,
        ));
}

void main() {
  test('PostsInteractorTest', () async {
    await initApp(testMode: true);

    app.apis.posts = MockPostsApi();

    final postInteractor = PostInteractor();
    app.interactors.addTest<PostInteractor>(postInteractor);

    await postInteractor.loadPost(1);

    expect((postInteractor.state.post! as ResultData).result.id, 1);
  });
}
