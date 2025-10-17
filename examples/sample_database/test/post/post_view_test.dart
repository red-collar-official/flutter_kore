import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_kore/arch/http/base_request.dart';
import 'package:sample_database/domain/apis/base/request.dart';
import 'package:sample_database/domain/apis/posts_api.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/global/global_app.dart';
import 'package:sample_database/ui/post/post_view.dart';

class MockPostsApi extends PostsApi {
  @override
  HttpRequest<Post?> getPost(int id) => super.getPost(id)
    ..simulateResult = Response(
        code: 200,
        result: Post(
          title: 'TestTitle',
          body: 'TestBody',
          id: 1,
        ));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PostViewTest', () {
    testWidgets('PostViewTest InitialLoadTest', (tester) async {
      // need to run before tests
      // bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-dart/main/install.sh)

      await initApp(testMode: true);

      app.registerInstances();
      await app.createSingletons();

      app.apis.posts = MockPostsApi();

      await tester.pumpAndSettle();

      await tester.pumpWidget(const MaterialApp(
        home: Material(child: PostView(id: 1)),
      ));

      await Future.delayed(const Duration(seconds: 3), () {});

      await tester.pumpAndSettle();

      final titleFinder = find.text('TestTitle');

      expect(titleFinder, findsOneWidget);
    });
  });
}
