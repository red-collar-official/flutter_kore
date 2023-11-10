# Interactors

Interactors contain state and subscription to <b>EventBus</b> events.(more information about <b>EventBus</b> can be found [here](./event_bus.md)).

You need also specify input type for interactors, by default it is <b>Map<String, dynamic></b>.

Interactor state can be any immutable object. You can use <b>dart-mappable</b> or <b>freezed</b> libraries (or any other object generation libraries).

State can be updated with <b>updateState</b> method and receivers like view models can later subscribe to state update events with <b>updates</b> or <b>changes</b>(<b>changes</b> returns stream of old and new value in object, <b>updates</b> returns stream of new object values).

Interactors must be annotated with <b>basicInstance</b>, <b>singleton</b> or full <b>Instance</b> annotation.

When interactor is annotated as singleton it belongs to global instance collection.

We don't need to write dependencies in our instances for singleton interactors 
and we can access it with <b>app.instances</b>.

Interactors can be disposed when dependent element is disposed.

Interactors also can depend on other interactors and [wrappers](./wrapper.md) (or [custom instances](./custom_instance.md)) via <b>dependsOn</b> override.

Interactors also can contain [parts](./instance_part.md) via <b>parts</b> override.

Interactors also can belong to modules via <b>belongsToModules</b> override (information about modules can be found [here](./di.md)).

They are connected with <b>Connector</b> objects (more information about connectors can be found [here](./connectors.md) and for DI [here](./di.md)).

Typical example would be:

```dart
// Map<String, dynamic> - input type
// PostsState - state type
@basicInstance
class PostsInteractor extends BaseInteractor<PostsState, Map<String, dynamic>> with LikePostMixin {
  @override
  List<Connector> dependsOn(String? input) => [
        const Connector(type: SupportInteractor, scope: BaseScopes.unique),
        const Connector(type: ReactionsWrapper),
      ];

  late final supportInteractor = getLocalInstance<SupportInteractor>();
  late final reactionsWrapper = getLocalInstance<ReactionsWrapper>();

  Future<void> loadPosts(int offset, int limit, {bool refresh = false}) async {
    updateState(state.copyWith(posts: LoadingData()));

    late Response<List<Post>> response;

    if (refresh) {
      response = await app.apis.posts.getPosts(0, limit).execute();
    } else {
      response = await app.apis.posts.getPosts(offset, limit).execute();
    }

    if (response.isSuccessful || response.isSuccessfulFromDatabase) {
      updateState(state.copyWith(posts: SuccessData(response.result ?? [])));
    } else {
      updateState(state.copyWith(posts: ErrorData(response.error)));
    }
  }

  void _onPostLiked(int id) {
    final posts = (state.posts as SuccessData<List<Post>>).result.toList();
    final index = posts.indexWhere((element) => element.id == id);

    if (index == -1) {
      return;
    }

    posts[index] = posts[index].copyWith(isLiked: !posts[index].isLiked);

    updateState(state.copyWith(posts: SuccessData(posts)));
  }

  Stream<StatefulData<List<Post>>?> get postsStream =>
      updates((state) => state.posts);

  @override
  PostsState initialState(Map<String, dynamic>? input) => PostsState();

  @override
  List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>((event) {
        _onPostLiked(event.id);
      }),
    ];
}
```

Or singleton interactor:

```dart
@singleton
class UserDefaultsInteractor extends BaseInteractor<UserDefaultsState, Map<String, dynamic>> {
  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    updateState(UserDefaultsState.fromJson(savedStateObject));
  }

  void saveFirstAppLaunch() {
    updateState(state.copyWith(firstAppLaunch: true));
  }

  @override
  UserDefaultsState initialState(Map<String, dynamic>? input) => UserDefaultsState();
  
  @override
  Map<String, dynamic> get savedStateObject => state.toJson();

  @override
  bool get isRestores => true;
  
  @override
  List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>((event) {
        _onPostLiked(event.id);
      }),
    ];
}

```

In the last example we also can see that every interactor also has <b>savedStateObject</b>.

When we override <b>savedStateObject</b> so interactor can save state to <b>SharedPreferences</b> or other provider such as SecureStorage.

It later can be restored with <b>onRestore</b>. It also has <b>isRestores</b> flag - that is false by default.

By default state key in saved object is equals to state runtime type, but you can override it with <b>stateId</b> getter.

If app uses obfuscation this is <b>required</b>.

You can also specify input type for every interactor in annotation:

```dart
@Instance(inputType: String)
class UserDefaultsInteractor extends BaseInteractor<UserDefaultsState, String> {
  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    updateState(UserDefaultsState.fromJson(savedStateObject));
  }

  void saveFirstAppLaunch() {
    updateState(state.copyWith(firstAppLaunch: true));
  }

  @override
  UserDefaultsState initialState(String? input) => UserDefaultsState();
  
  @override
  Map<String, dynamic> get savedStateObject => state.toJson();

  @override
  bool get isRestores => true;

  @override
  bool get syncRestore => false;

  @override
  String get stateId => 'test';
  
  @override
  List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>((event) {
        _onPostLiked(event.id);
      }),
    ];
}
```

In the example above we also specify <b>syncRestore</b> option. If this option set to true state will be restored from cache during <b>initialize</b> call.
Otherwise it will be restored asynchronously.

And here is example if declaration of all types of dependencies:

```dart
@basicInstance
class PostsInteractor extends BaseInteractor<PostsState, Map<String, dynamic>> with LikePostMixin {
  @override
  List<Connector> dependsOn(String? input) => [
        const Connector(type: SupportInteractor, scope: BaseScopes.unique),
        const Connector(type: ReactionsWrapper),
      ];

  @override
  List<InstancesModule> belongsToModules(Map<String, dynamic>? input) => [
    Modules.test,
  ];

  @override
  List<PartConnector> parts(int? input) => [
    const PartConnector(type: TestInstancePart1, input: 5, async: true),
    const PartConnector(
        type: TestInstancePart2,
        async: true,
        count: 2,
        input: 10,
    ),
    PartConnector(
        type: TestInstancePart3,
        count: 2,
        inputForIndex: (index) => index + 1,
    ),
    PartConnector(
        type: TestInstancePart4,
        async: true,
        count: 2,
        inputForIndex: (index) => index + 1,
    ),
    const PartConnector(
        type: TestInstancePart5,
        withoutConnections: true,
    ),
  ];

  late final supportInteractor = getLocalInstance<SupportInteractor>();
  late final reactionsWrapper = getLocalInstance<ReactionsWrapper>();

  late final testInstancePart1 = useInstancePart<TestInstancePart1>();

  Future<void> loadPosts(int offset, int limit, {bool refresh = false}) async {
    updateState(state.copyWith(posts: LoadingData()));

    late Response<List<Post>> response;

    if (refresh) {
      response = await app.apis.posts.getPosts(0, limit).execute();
    } else {
      response = await app.apis.posts.getPosts(offset, limit).execute();
    }

    if (response.isSuccessful || response.isSuccessfulFromDatabase) {
      updateState(state.copyWith(posts: SuccessData(response.result ?? [])));
    } else {
      updateState(state.copyWith(posts: ErrorData(response.error)));
    }
  }

  void _onPostLiked(int id) {
    final posts = (state.posts as SuccessData<List<Post>>).result.toList();
    final index = posts.indexWhere((element) => element.id == id);

    if (index == -1) {
      return;
    }

    posts[index] = posts[index].copyWith(isLiked: !posts[index].isLiked);

    updateState(state.copyWith(posts: SuccessData(posts)));
  }

  @override
  PostsState initialState(Map<String, dynamic>? input) => PostsState();

  @override
  List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>((event) {
        _onPostLiked(event.id);
      }),
    ];
}
```
