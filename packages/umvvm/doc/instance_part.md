# Parts

<img src="doc_images/instance_part.png" alt="instance_part" width="600"/>

Part is mvvm instance type that has reference to parent mvvm instance.
It is usefull for splitting logic in large instances. 

Parts extend <b>RestrictedInstancePart</b> or <b>UniversalInstancePart</b>.

<b>UniversalInstancePart</b> is generic type that can be connected to any mvvm instance. 

<b>RestrictedInstancePart</b> allows you to specify type of instance that it can be connected to via generic argument.

You also need to specify input type for parts. It is passed as generic argument. Then input is available in all initialization methods.

You must annotate parts with <b>instancePart</b> annotation.

Part can receive events and can't have state or dependencies.

Part can contain other parts.

If part "../docs"is connected to other part "../docs"then you can get root parent instance reference with <b>rootParentInstance</b> field.

Here is an example:

```dart
@instancePart
class TestInteractorPart extends RestrictedInstancePart<Map<String, dynamic>, PostsInteractor> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
    DependentMvvmInstanceConfiguration(
      parts: [
        app.connectors.downloadUserPartConnector(
          input: input.id,
          isAsync: true,
        ),
        app.connectors.followUserPartConnector(input: input.id),
      ],
    );

  late final downloadUser = useInstancePart<DownloadUserPart>();

  void testUpdate() {
    parentInstance.updateState(parentInstance.state.copyWith(
      active: false,
    ));

    rootParentInstance.updateState(rootParentInstance.state.copyWith(
      active: false,
    ));
  }

  @override
  Future<void> initializeAsync() async {
    // ...
  }

  @override
  Future<void> dispose() async {
    // ...
  }

  @override
  void onAsyncPartReady(Type type, {int? index}) {
    switch (type) {
      case value:
        
        break;
      default:
    }
  }

  @override
  List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>((event) {
        _onPostLiked(event.id);
      }),
    ];
}
```

And universal part"../docs":

```dart
@instancePart
class TestUniversalInteractorPart extends UniversalInstancePart<Map<String, dynamic>> {
  void testUpdate() {
    // some update code
  }
}

@basicInstance
class PostsInteractor extends BaseInteractor<PostsState, Map<String, dynamic>>
    with LikePostMixin {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
    DependentMvvmInstanceConfiguration(
      parts: [
        app.connectors.testUniversalInteractorPartConnector(),
        app.connectors.testInteractorPartConnector(input: input.id),
      ],
    );

  late final testPart = useInstancePart<TestInteractorPart>();
  late final testUniversalPart = useInstancePart<TestUniversalInteractorPart>();
}
```

There is also ability to execute code in synced queue - meaning that if there are currently running operations - new code will be executed after all previous operations comleted - otherwise operation will be executed instantly

By default if part is disposed all pending operation are discarded, but it can be changed with <b>discardOnDispose</b> flag
Also you can provide optional timeout for this operation

```dart
@instancePart
class TestInteractorPart extends RestrictedInstancePart<Map<String, dynamic>, PostsInteractor> {
  Future<void> loadPosts(int offset, int limit, {bool refresh = false}) async {
    enqueue(operation: () async {
      parentInstance.updateState(parentInstance.state.copyWith(posts: LoadingData()));

      late Response<List<Post>> response;

      if (refresh) {
        response = await app.apis.posts.getPosts(0, limit).execute();
      } else {
        response = await app.apis.posts.getPosts(offset, limit).execute();
      }

      if (response.isSuccessful || response.isSuccessfulFromDatabase) {
        parentInstance.updateState(parentInstance.state.copyWith(posts: SuccessData(response.result ?? [])));
      } else {
        parentInstance.updateState(parentInstance.state.copyWith(posts: ErrorData(response.error)));
      }
    })
  }
}
```
