# Testing

All components of architecture except for view states can be unit tested.
View states require widget tests.

Before tests you always need set test mode flag.

```dart
UMvvmApp.isInTestMode = true;
```

If you testing mvvm instances you also you need to register instances if they are used in test.

```dart
setUp(() async {
  UMvvmApp.isInTestMode = true;

  app.registerInstances();
  await app.createSingletons();
});
```

There are several helper methods for tests.

Mock instances can be registered in instance collection with <b>addTest</b> method.

You also can force get instance (skipping initialization checks).

```dart
app.instances.addTest<PostInteractor>(BaseScopes.global, mockPostInteractor);

app.instances.forceGet<PostInteractor>(); // valid
app.instances.forceGet<UserInteractor>(); // throws exception

```

You can also add builder for mocked dependency to mock instances initialization:

```dart
app.instances.addBuilder<PostInteractor>(() => postInteractor);
```

More info about DI can be found [here](./di.md).

Test view models can be passed as parameter to mvvm widgets:

```dart
final widget = PostView(
  post: Post(
    title: 'TestTitle',
    body: 'TestBody',
    id: 1,
  ),
  viewModel: MockViewModel(),
);
```

More info about view models can be found [here](./view_model.md). 
About widgets you can read [here](./widget.md). 

To check that event was sent and received you can use following methods:

```dart
app.eventBus.checkEventWasSent(EnsureCloseRequestedEvent);

postInteractor.checkEventWasReceived(EnsureCloseRequestedEvent);
```

<b>checkEventWasReceived</b> method available for every mvvm instance.

More info about event bus can be found [here](./event_bus.md). 

For apis you can mock api results with <b>simulateResponse</b> and <b>simulateResult</b>

Typical example of Api mocks for tests:

```dart
class MockPostsApiResponse extends PostsApi {
  @override
  HttpRequest<List<Post>> getPosts(int offset, int limit) => super.getPosts(offset, limit)
    ..simulateResponse = SimulateResponse(
      data: [{'id': 1, 'title': 'qwerty', 'body': 'qwerty' }],
    );
}

class MockPostsApiResult extends PostsApi {
  @override
  HttpRequest<List<Post>> getPosts(int offset, int limit) => HttpRequest<List<Post>>()
    ..simulateResult = Response(code: 200, result: [
      Post(
        title: '',
        body: '',
        id: 1,
      )
    ]);
}
```

You can then set apis to mocked instance:

```dart
app.apis.posts = MockPostsApi();
```

More info about apis can be found [here](./view_model.md). 

Here are some examples for typical test cases:

```dart
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

    app.apis.posts = MockPostsApi();

    final response = await app.apis.posts.getPost(1).execute();

    expect(response.result!.body, 'qwerty');
  });

  test('PostsInteractorTest', () async {
    await initApp(testMode: true);

    app.apis.posts = MockPostsApi();

    final postInteractor = PostInteractor();
    app.instances.addTest<PostInteractor>(BaseScopes.global, postInteractor);

    await postInteractor.loadPost(1);

    expect((postInteractor.state.post! as SuccessData).result.id, 1);
  });

  test('PostsViewModelTest', () async {
    await initApp(testMode: true);

    app.apis.posts = MockPostsApi();

    final postInteractor = PostInteractor();
    app.instances.addTest<PostInteractor>(BaseScopes.global, postInteractor);

    await postInteractor.loadPost(1);

    expect((postInteractor.state.post! as SuccessData).result.id, 1);
  });

  test('PostsInteractorTest', () async {
    await initApp(testMode: true);

    app.registerInstances();
    await app.createSingletons();

    final postInteractor = PostInteractorMock();
    app.instances.addBuilder<PostInteractor>(() => postInteractor);

    final postViewModel = PostViewModel();
    const mockWidget = PostView(id: 1);

    // ignore: cascade_invocations
    postViewModel
      ..initialize(mockWidget)
      ..onLaunch(mockWidget);

    expect((postViewModel.currentPost as SuccessData).result.id, 1);
  });

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
}
```

Custom instances can be tested in the same way. If you annotated mvvm instance with <b>Instance</b> annotation you can safely replace builders and references for it.

Navigation can be tested with default methods. You can check latest routes in all stacks, you can set current tab if needed, you can execute links and open routes, this way you can simulate any navigation stack state.

Here are some examples:

```dart
test('NavigationInteractor Add route set current tab test', () async {
  expect(app.navigation.state.currentTab, AppTabs.posts);

  await app.navigation.routeTo(app.navigation.routes.stub());

  expect(app.navigation.latestTabRoute().name, RouteNames.stub);

  app.navigation.setCurrentTab(AppTabs.likedPosts);

  expect(app.navigation.state.currentTab, AppTabs.likedPosts);

  expect(app.navigation.latestTabRoute().name, RouteNames.likedPosts);

  await app.navigation.routeTo(app.navigation.routes.stub());

  expect(app.navigation.latestTabRoute().name, RouteNames.stub);
});

test('DeepLinkInteractor Initial link route test', () async {
  app.navigation.dialogs.routeLinkHandlers.clear();
  app.navigation.bottomSheets.routeLinkHandlers.clear();
  app.navigation.deepLinks.reset();

  app.navigation.routes.initializeLinkHandlers();

  await app.navigation.deepLinks.receiveInitialLink();

  expect(app.navigation.latestGlobalRoute().name, RouteNames.posts);
});
```

Examples of tests can be found [here](././examples).
