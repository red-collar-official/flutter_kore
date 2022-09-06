import 'package:mvvm_redux/arch/http/simulate_response.dart';
import 'package:sample_basic/domain/apis/base/request.dart';
import 'package:sample_basic/domain/apis/posts_api.dart';
import 'package:sample_basic/domain/data/post.dart';
import 'package:sample_basic/domain/database/posts_box.dart';
import 'package:sample_basic/domain/global/apis.dart';
import 'package:sample_basic/domain/global/global_store.dart';
import 'package:test/test.dart';

class MockPostsApi extends PostsApi {
  @override
  HttpRequest<Post?> getPost(int id) => super.getPost(id)
    ..simulateResponse = SimulateResponse(
      data: '[{"id": 1, "title": "qwerty", "body": "qwerty" }]',
    );
}

void main() {
  test('getPost parsing test', () async {
    // need to run
    // bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-dart/main/install.sh)

    await initApp(testMode: true);

    Apis.posts = MockPostsApi();

    final response = await Apis.posts.getPost(1).execute();

    expect(response.result!.body, 'qwerty');
  });
}
