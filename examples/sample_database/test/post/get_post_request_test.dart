import 'package:flutter_kore/arch/http/simulate_response.dart';
import 'package:sample_database/domain/apis/base/request.dart';
import 'package:sample_database/domain/apis/posts_api.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/database/posts_box.dart';
import 'package:sample_database/domain/global/global_app.dart';
import 'package:test/test.dart';

class MockPostsApi extends PostsApi {
  @override
  HttpRequest<Post?> getPost(int id) => super.getPost(id)
    ..simulateResponse = SimulateResponse(
      data: [
        {'id': 1, 'title': 'qwerty', 'body': 'qwerty'},
      ],
    );
}

void main() {
  test('getPost parsing test', () async {
    // need to run before tests
    // bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-dart/main/install.sh)

    await initApp(testMode: true);

    app.apis.posts = MockPostsApi();

    final response = await app.apis.posts.getPost(1).execute();

    expect(response.result!.body, 'qwerty');

    final cached = await PostsBox.getPostDelegate(1);

    expect(cached?.body, 'qwerty');
  });
}
