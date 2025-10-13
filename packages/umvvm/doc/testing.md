# Testing

<img src="doc_images/testing.png" alt="testing" width="750"/>

All components of the architecture except for view states can be unit tested. View states require widget tests.

Before tests, you always need to set the test mode flag.

```dart
UMvvmApp.isInTestMode = true;
```

If you are testing MVVM instances, you also need to register instances if they are used in the test.

```dart
setUp(() async {
  UMvvmApp.isInTestMode = true;

  app.registerInstances();
  await app.createSingletons();
});
```

There are several helper methods for tests.

Mock instances can be registered in the instance collection with the `addTest` method.

You can also force get an instance (skipping initialization checks).

```dart
app.instances.addTest<PostInteractor>(BaseScopes.global, mockPostInteractor);

app.instances.forceGet<PostInteractor>(); // valid
app.instances.forceGet<UserInteractor>(); // throws exception

```

You can also add a builder for a mocked dependency to mock instances initialization:

```dart
app.instances.addBuilder<PostInteractor>(() => postInteractor);

// or

app.instances.mock(instance: mockInstance);
app.instances.mock<TestMvvmInstance>(builder: MockTestMvvmInstance.new);
```

More information about DI can be found [here](./di.md).

Test view models can be passed as a parameter to MVVM widgets:

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

More information about view models can be found [here](./view_model.md). About widgets, you can read [here](./widget.md).

To check that an event was sent and received, you can use the following methods:

```dart
app.eventBus.checkEventWasSent(EnsureCloseRequestedEvent);

postInteractor.checkEventWasReceived(EnsureCloseRequestedEvent);

// or

postInteractor.checkEventWasReceived(EnsureCloseRequestedEvent, count: 10);
```

The `checkEventWasReceived` method is available for every MVVM instance.

You can also wait until an event is received by an instance.

Here is an example:

```dart
final interactor = await instances.getUniqueAsync<TestInteractor>();

eventBus.send(TestEvent(number: 5));

await interactor.waitTillEventIsReceived(TestEvent);

// or

await interactor.waitTillEventIsReceived(TestEvent, count: 10);

expect(interactor.checkEventWasReceived(TestEvent), true);
```

If you need to reset received events information, for example, to check again for the same events, you can clear this information as follows:

```dart
interactor.cleanupReceivedEvents();
```

More information about the event bus can be found [here](./event_bus.md).

For APIs, you can mock API results with `simulateResponse` and `simulateResult`.

A typical example of API mocks for tests:

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

You can then set APIs to a mocked instance:

```dart
app.apis.posts = MockPostsApi();
```

More information about APIs can be found [here](./view_model.md).

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

    final postInteractor = PostInteractorMock();
    app.instances.mock<PostInteractor>(instance: postInteractor);

    final postViewModel = PostViewModel();
    const mockWidget = PostView(id: 1);

    // ignore: cascade_invocations
    postViewModel
      ..initialize(mockWidget)
      ..onLaunch();

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

Custom instances can be tested in the same way. If you annotated an MVVM instance with the `Instance` annotation, you can safely replace builders and references for it.

Navigation can be tested with default methods. You can check the latest routes in all stacks; you can set the current tab if needed; you can execute links and open routes; this way you can simulate any navigation stack state.

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