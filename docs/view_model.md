# ViewModel

View models contain logic for view classes.

It also contains local state that we like <b>Interactor</b> can update with <b>updateState</b>.

We also can listen to state changes with <b>updates</b> or <b>changes</b>

View models also can depend on [interactors](./interactor.md) and [wrappers](./wrapper.md) (or [custom](./custom_instance.md) instances) via <b>dependsOn</b> override.

View models also can contain [parts](./instance_part.md) via <b>parts</b> override.

View models also can belong to modules via <b>belongsToModules</b> override (information about modules can be found [here](./di.md)).

They are connected with <b>Connector</b> objects (more information about connectors can be found [here](./connectors.md) and for DI [here](./di.md)).

View models like every mvvm instance can receive <b>EventBus</b> events using <b>subscribe</b> method.

To get local instances connected to view model use <b>getLocalInstance<T>()</b>.

To get part use <b>useInstancePart<T>()</b> method.

View models also can override <b>onLaunch</b> method that is called on initState 
and <b>onFirstFrame</b> that is called on first frame of corresponding view.

```dart
class PostsListViewModel extends BaseViewModel<PostsListView, PostsListViewState> {
  @override
  List<Connector> dependsOn(PostsListView widget) => [
        app.postsInteractorConnector(lazy: true),
        app.postInteractorConnector(scopes: BaseScopes.unique),
        app.reactionsWrapperConnector(),
      ]; 

  @override
  List<PartConnector> parts(Map<String, dynamic>? input) => [
      app.connectors.downloadUserPartConnector(
        input: input.id,
        async: true,
      ),
      app.connectors.followUserPartConnector(input: input.id),
    ];

  late final postsInteractor = getLocalInstance<PostsInteractor>();
  late final reactionsWrapper = getLocalInstance<ReactionsWrapper>();

  late final downloadUser = useInstancePart<DownloadUserPart>();
  late final followUser = useInstancePart<FollowUserPart>();

  @override
  void onLaunch(PostsListView widget) {
    // called with initState
    getLocalInstance<PostsInteractor>().loadPosts(0, 30);
  }

  @override
  void onFirstFrame(SearchView widget) {
    // called with first frame - post frame callback
  }

  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    updateState(HomeViewState.fromJson(savedStateObject));
  }

  void like(int id) {
    postsInteractor.likePost(id);
  }

  void openPost(Post post) {
    app.navigation.routeTo(app.navigation.routes.post(id: '1'));
  }

  Stream<StatefulData<List<Post>>?> get postsStream => postsInteractor.updates((state) => state.posts);

  @override
  PostsListViewState get initialState => PostsListViewState();

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

View models also have <b>savedStateObject</b> and it also later can be restored with <b>onRestore</b>.

By default state key in saved object is equals to state runtime type, but you can override it with <b>stateId</b> getter.

If app uses obfuscation this is <b>required</b>.

In the example above we also specify <b>syncRestore</b> option. If this option set to true state will be restored from cache during <b>initialize</b> call.
Otherwise it will be restored asynchronously.
