# Custom instances

You can create custom instances by extending <b>MvvmInstance</b> class and mixing several mixins.

You can read about default methods of <b>MvvmInstance</b> [here](./mvvm_instance.md).

Here we will discuss mixins.

Mixins allow you to add additional funtions to your custom instance like dependencies, cancelable api calls and state.

For example if you need to add state to your instance you can write this:

```dart
abstract class BaseBox<State> extends MvvmInstance<dynamic> with StatefulMvvmInstance<State, dynamic> {
  String get boxName;

  late final hiveWrapper = app.instances.get<HiveWrapper>();

  @mustCallSuper
  @override
  void initialize(Input? input) {
    super.initialize(input);

    initializeStatefullInstance(input);

    initialized = true;
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();

    disposeStore();

    initialized = false;
  }
}
```

You need to add initialization call to <b>initialize</b> method and <b>disposeStore</b> method to <b>dispose</b> override.

Then you can extend this custom instance and use if state and receive updates, restore cache and etc..

```dart
@MappableClass()
class UsersBoxState with UsersBoxStateMappable {
  const UsersBoxState({
    this.id,
    this.users,
  });

  final String? id;
  final List<User>? users;
}

@basicInstance
class UsersBox extends BaseBox<UsersBoxState> {
  void updateUsers(List<User> users) {
    updateState(state.copyWith(users: users));
  }

  Stream<List<User>?> get usersStream => updates((state) => state.users);
}

class UsersListViewModel extends BaseViewModel<UsersListView, UsersListViewState> {
  @override
  List<Connector> dependsOn(PostsListView widget) => [
        app.usersBoxConnector(lazy: true),
      ]; 

  late final usersInteractor = getLocalInstance<UsersBox>();

  @override
  void onLaunch(PostsListView widget) {
    // called with initState
    getLocalInstance<PostsInteractor>().loadPosts(0, 30);
  }

  Stream<StatefulData<List<Post>>?> get usersStream => usersInteractor.usersStream;

  @override
  PostsListViewState get initialState => PostsListViewState();
}
```

If you need to add dependencies to your custom mvvm instance you can do the following:

```dart
abstract class BaseBox extends MvvmInstance<dynamic> with DependentMvvmInstance<dynamic> {
  String get boxName;

  late final hiveWrapper = app.instances.get<HiveWrapper>();

  @mustCallSuper
  @override
  void initialize(dynamic input) {
    super.initialize(input);

    initializeDependencies(input);

    initialized = true;
  }

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();

    disposeDependencies();

    initialized = false;
  }
}
```

You need to add initialization call to <b>initialize</b> method and <b>disposeDependencies</b> method to <b>dispose</b> override.

Then you can extend this custom instance and use dependencies, <b>getLocalInstance</b> method and etc...

```dart
@basicInstance
class UsersBox extends BaseBox {
  @override
  List<Connector> dependsOn(void input) => [
      app.connectors.postInteractorConnector(
        scope: BaseScopes.unique,
        input: input.post,
      ),
    ];

  late final postInteractor = getLocalInstance<PostInteractor>();
}
```

If you need to execute http requests in this instance you can add <b>ApiCaller</b> mixin so that requests can be cancelled automatically when instance is disposed.

You can do it as follows:

```dart
abstract class BaseBox extends MvvmInstance<dynamic> with ApiCaller<dynamic> {
  String get boxName;

  late final hiveWrapper = app.instances.get<HiveWrapper>();

  @mustCallSuper
  @override
  void dispose() {
    super.dispose();

    cancelAllRequests();

    initialized = false;
  }
}
```
