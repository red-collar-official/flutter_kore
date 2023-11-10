# Parts

To split logic in large instances you can create <b>parts</b>.

Part is instance type that has reference to parent mvvm instance.

Part can receive events and can't have state or dependencies.

Part can contain other parts.

If part is connected to other part then you can get root parent instance reference with <b>rootParentInstance</b> field.

Here is an example:

```dart
@instancePart
class TestInteractorPart extends BaseInstancePart<Map<String, dynamic>, PostsInteractor> {
  @override
  List<PartConnector> parts(Map<String, dynamic>? input) => [
      app.connectors.downloadUserPartConnector(
        input: input.id,
        async: true,
      ),
      app.connectors.followUserPartConnector(input: input.id),
    ];

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
  Future<void> initializeAsync(Map<String, dynamic>? input) async {
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

@basicInstance
class PostsInteractor extends BaseInteractor<PostsState, Map<String, dynamic>>
    with LikePostMixin {
  @override
  List<Type> parts(Map<String, dynamic>? input) => [
        TestInteractorPart,
      ];

  late final testPart = useInstancePart<TestInteractorPart>();
}
```
