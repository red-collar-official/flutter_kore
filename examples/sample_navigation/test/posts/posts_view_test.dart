import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mvvm_redux/arch/http/base_request.dart';
import 'package:sample_navigation/domain/apis/base/request.dart';
import 'package:sample_navigation/domain/apis/posts_api.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/domain/global/global_store.dart';
import 'package:sample_navigation/ui/posts_list/posts_list_view.dart';

class MockPostsApi extends PostsApi {
  @override
  HttpRequest<List<Post>> getPosts(int offset, int limit) =>
      HttpRequest<List<Post>>()
        ..simulateResult = Response(code: 200, result: [
          Post(
            title: 'TestTitle',
            body: 'TestBody',
            id: 1,
          )
        ]);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('PostsListViewTest', () {
    testWidgets('PostsListViewTest InitialLoadTest', (tester) async {
      await initApp(testMode: true);

      app
        ..registerInteractors()
        ..registerServices()
        ..registerSingletons();

      app.apis.posts = MockPostsApi();

      await tester.pumpAndSettle();

      await tester.pumpWidget(MaterialApp(
        home: Material(child: PostsListView()),
      ));

      await Future.delayed(const Duration(seconds: 3), () {});

      await tester.pumpAndSettle();

      final titleFinder = find.text('TestTitle');

      expect(titleFinder, findsOneWidget);
    });
  });
}
