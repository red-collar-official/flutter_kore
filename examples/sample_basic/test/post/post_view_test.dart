import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sample_basic/ui/post/post_view_model.dart';
import 'package:umvvm/arch/http/base_request.dart';
import 'package:sample_basic/domain/apis/base/request.dart';
import 'package:sample_basic/domain/apis/posts_api.dart';
import 'package:sample_basic/domain/data/post.dart';
import 'package:sample_basic/domain/global/global_app.dart';
import 'package:sample_basic/ui/post/post_view.dart';

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

class MockViewModel extends PostViewModel {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PostViewTest', () {
    testWidgets('PostViewTest InitialLoadTest', (tester) async {
      await initApp(testMode: true);

      app.registerInstances();
      await app.createSingletons();

      await tester.pumpAndSettle();

      final widget = PostView(
        post: Post(
          title: 'TestTitle',
          body: 'TestBody',
          id: 1,
        ),
        viewModel: MockViewModel(),
      );

      await tester.pumpWidget(MaterialApp(
        home: Material(
          child: widget,
        ),
      ));

      await Future.delayed(const Duration(seconds: 3), () {});

      await tester.pumpAndSettle();

      final titleFinder = find.text('TestTitle');

      expect(titleFinder, findsOneWidget);
    });
  });
}
