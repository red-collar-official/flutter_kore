import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_navigation/domain/apis/base/request.dart';
import 'package:sample_navigation/domain/apis/posts_api.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/domain/global/global_app.dart';
import 'package:sample_navigation/domain/interactors/post/post_interactor.dart';
import 'package:test/test.dart';

class MockPostsApi extends PostsApi {
  @override
  HttpRequest<Post?> getPost(int id) =>
      super.getPost(id)
        ..simulateResult = Response(
          code: 200,
          result: Post(title: '', body: '', id: 1),
        );
}

void main() {
  test('PostInteractorTest', () async {
    await initApp(testMode: true);

    app.apis.posts = MockPostsApi();

    final postInteractor = PostInteractor();
    app.instances.addTest<PostInteractor>(instance: postInteractor);

    await postInteractor.loadPost(1);

    expect((postInteractor.state.post! as SuccessData).result.id, 1);
  });
}
