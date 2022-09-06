import 'package:mvvm_redux/arch/http/simulate_response.dart';
import 'package:sample/domain/apis/base/request.dart';
import 'package:sample/domain/apis/posts_api.dart';
import 'package:sample/domain/data/post.dart';
import 'package:sample/domain/database/posts_box.dart';
import 'package:sample/domain/global/apis.dart';
import 'package:sample/domain/global/global_store.dart';
import 'package:test/test.dart';

class MockPostsApi extends PostsApi {
  @override
  HttpRequest<List<Post>> getPosts(int offset, int limit) => super.getPosts(offset, limit)
    ..simulateResponse = SimulateResponse(
      data: '[{"id": 1, "title": "qwerty", "body": "qwerty" }]',
    );
}

void main() {
  test('getPosts parsing test', () async {
    await initApp(testMode: true);

    Apis.posts = MockPostsApi();

    final response = await Apis.posts.getPosts(0, 30).execute();

    expect(response.result![0].body, 'qwerty');

    final cached = await PostsBox.getPostsDelegate(0, 30, null);

    expect(cached[0].body, 'qwerty');
  });
}
