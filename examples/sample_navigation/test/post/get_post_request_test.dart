import 'package:umvvm/arch/http/simulate_response.dart';
import 'package:sample_navigation/domain/apis/base/request.dart';
import 'package:sample_navigation/domain/apis/posts_api.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/domain/global/global_store.dart';
import 'package:test/test.dart';

class MockPostsApi extends PostsApi {
  @override
  HttpRequest<Post?> getPost(int id) => super.getPost(id)
    ..simulateResponse = SimulateResponse(
      data: [{'id': 1, 'title': 'qwerty', 'body': 'qwerty'}],
    );
}

void main() {
  test('getPost parsing test', () async {
    await initApp(testMode: true);

    app.apis.posts = MockPostsApi();

    final response = await app.apis.posts.getPost(1).execute();

    expect(response.result!.body, 'qwerty');
  });
}
