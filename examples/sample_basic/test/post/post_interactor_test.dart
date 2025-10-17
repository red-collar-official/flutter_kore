import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_basic/domain/apis/base/request.dart';
import 'package:sample_basic/domain/apis/posts_api.dart';
import 'package:sample_basic/domain/data/post.dart';
import 'package:sample_basic/domain/global/global_app.dart';
import 'package:sample_basic/domain/interactors/post/post_interactor.dart';
import 'package:test/test.dart';

class MockPostsApi extends PostsApi {
  @override
  HttpRequest<Post?> getPost(int id) =>
      super.getPost(id)
        ..simulateResult = Response(
          code: 200,
          result: const Post(title: '', body: '', id: 1),
        );
}

void main() {
  test('PostInteractorTest', () async {
    await initApp(testMode: true);

    app.apis.posts = MockPostsApi();

    final postInteractor = PostInteractor();

    // ignore: cascade_invocations
    postInteractor.initialize(null);

    await postInteractor.loadPost(1);

    expect((postInteractor.state.post! as SuccessData).result.id, 1);
  });
}
