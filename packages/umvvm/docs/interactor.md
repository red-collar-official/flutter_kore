# Interactors

Interactors contain state and subscription to <b>EventBus</b> events.(more information about <b>EventBus</b> can be found [here](./event_bus.md)).

You also need to specify input type for interactors. It is passed as generic argument.

Input is always available via <b>input</b> field.

Interactor state can be any immutable object. You can use <b>dart-mappable</b> or <b>freezed</b> libraries (or any other object generation libraries).

State can be updated with <b>updateState</b> method and receivers like view models can later subscribe to state update events with <b>updates</b> or <b>changes</b>(<b>changes</b> returns stream of old and new values in object, <b>updates</b> returns stream of new object values).

Interactors must be annotated with <b>basicInstance</b>, <b>singleton</b> or full <b>Instance</b> annotation.

When interactor is annotated as singleton it belongs to global instance collection.

We don't need to write dependencies in our instances for singleton interactors 
and we can access it with <b>app.instances</b>.

Interactors also can depend on other interactors and [wrappers](./wrapper.md) (or [custom instances](./custom_instance.md)) via <b>dependencies</b> field in configuration object.

Configuration object provided via <b>configuration</b> getter for every interactor.

Interactors also can contain [parts](./instance_part.md) via <b>parts</b> field in configuration object.

Interactors also can belong to modules via <b>modules</b> field in configuration object (information about modules can be found [here](./di.md)).

They are connected with <b>Connector</b> objects (more information about connectors can be found [here](./connectors.md) and for DI [here](./di.md)).

Typical example would be:

```dart
// Map<String, dynamic> - input type
// PostsState - state type
@basicInstance
class PostsInteractor extends BaseInteractor<PostsState, Map<String, dynamic>> with LikePostMixin {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
    DependentMvvmInstanceConfiguration(
      dependencies: [
        const Connector(type: SupportInteractor, scope: BaseScopes.unique),
        const Connector(type: ReactionsWrapper),
      ],
    );

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

  Stream<StatefulData<List<Post>>?> get postsStream => updates((state) => state.posts);

  @override
  PostsState get initialState => PostsState();

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
  UserDefaultsState get initialState => UserDefaultsState();
  
  @override
  Map<String, dynamic> get savedStateObject => state.toJson();

  @override
  StateFullInstanceSettings get stateFullInstanceSettings =>
      StateFullInstanceSettings(
        stateId: state.runtimeType.toString(),
        isRestores: true,
      );
  
  @override
  List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>((event) {
        _onPostLiked(event.id);
      }),
    ];
}

```

In the last example we also can see that every interactor also has <b>savedStateObject</b>.

When we override <b>savedStateObject</b> so interactor can save state to <b>SharedPreferences</b> or other provider such as <b>SecureStorage</b>.

To enable it you need to override <b>stateFullInstanceSettings</b> getter and set <b>isRestores</b> flag to true.

Later state can be restored with <b>onRestore</b> callback.

By default state key for saved object is equal to state runtime type string, but you can override it with <b>stateId</b> field in <b>stateFullInstanceSettings</b>.
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
  UserDefaultsState get initialState => UserDefaultsState();
  
  @override
  Map<String, dynamic> get savedStateObject => state.toJson();

  @override
  StateFullInstanceSettings get stateFullInstanceSettings =>
      StateFullInstanceSettings(
        stateId: state.runtimeType.toString(),
        isRestores: true,
        syncRestore: false,
      );
  
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
  DependentMvvmInstanceConfiguration get configuration =>
    DependentMvvmInstanceConfiguration(
      dependencies: [
        const Connector(type: SupportInteractor, scope: BaseScopes.unique),
        const Connector(type: ReactionsWrapper),
      ],
      modules: [
        Modules.test,
      ],
      parts: [
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
      ],
    );

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
  PostsState get initialState => PostsState();

  @override
  List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>((event) {
        _onPostLiked(event.id);
      }),
    ];
}
```

To see base settings and methods of interactors you can visit [this page](./mvvm_instance.md).
