// TODO: wait integration_test to update

// import 'package:flutter/material.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:integration_test/integration_test.dart';
// import 'package:umvvm/arch/http/base_request.dart';
// import 'package:sample_navigation/domain/apis/base/request.dart';
// import 'package:sample_navigation/domain/apis/posts_api.dart';
// import 'package:sample_navigation/domain/data/post.dart';
// import 'package:sample_navigation/domain/global/global_app.dart';
// import 'package:sample_navigation/ui/posts_list/posts_list_view.dart';

// class MockPostsApi extends PostsApi {
//   @override
//   HttpRequest<List<Post>> getPosts(int offset, int limit) => super.getPosts(offset, limit)
//     ..simulateResult = Response(code: 200, result: [
//       Post(
//         title: 'TestTitle',
//         body: 'TestBody',
//         id: 1,
//       )
//     ]);
// }

// void main() {
//   IntegrationTestWidgetsFlutterBinding.ensureInitialized();

//   group('PostsListViewTest', () {
//     testWidgets('PostsListViewTest InitialLoadTest', (tester) async {
//       await initApp(testMode: true);

//       app.registerInstances();
//       await app.createSingletons();

//       app.apis.posts = MockPostsApi();

//       await tester.pumpAndSettle();

//       await tester.pumpWidget(const MaterialApp(
//         home: Material(child: PostsListView()),
//       ));

//       await Future.delayed(const Duration(seconds: 3), () {});

//       await tester.pumpAndSettle();

//       final titleFinder = find.text('TestTitle');

//       expect(titleFinder, findsOneWidget);
//     });
//   });
// }
