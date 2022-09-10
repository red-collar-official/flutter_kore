# MVVM-Redux library

## Data Layer

Data layer consists of <b>Api</b> and <b>Box</b> classes.

Api class contains getters or functions that return <b>HttpRequest</b>.
Api classes must be annotated with <b>api</b> annotation

<b>HttpRequest</b> has following fields:

```dart
this.method = RequestMethod.get,
this.url,
this.parser,
this.file,
this.query,
this.timeout = const Duration(seconds: 20),
this.headers = const {},
this.body,
this.baseUrl,
this.requiresLogin = true,
this.databaseGetDelegate,
this.databasePutDelegate,
this.simulateResponse,
this.simulateResult,
this.formData,
```

Important notes here:

1) <b>parser</b> is a function that takes server response body and headers
2) <b>simulateResponse</b> lets you simulate unparsed server response body and headers so you can check parser function and database delegates
3) <b>simulateResult</b> lets you simulate parsed server response, so you can check interactors and viewmodels

Typical example for Api class would be:

```dart
@api
class PostsApi {
  HttpRequest<List<Post>> getPosts(int offset, int limit) => HttpRequest<List<Post>>()
    ..method = RequestMethod.get
    ..baseUrl = getBaseUrl(BackendUrls.main)
    ..url = '/posts'
    ..parser = (result, headers) async {
      final list = <Post>[];

      result?.forEach((data) {
        list.add(Post.fromJson(data));
      });

      return list;
    };
}
```

Typical example of Api mocks for tests:

```dart
class MockPostsApiResponse extends PostsApi {
  @override
  HttpRequest<List<Post>> getPosts(int offset, int limit) => super.getPosts(offset, limit)
    ..simulateResponse = SimulateResponse(
      data: '[{"id": 1, "title": "qwerty", "body": "qwerty" }]',
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

If project requires database we use <b>ObjectBox</b> library and add delegates to <b>HttpRequest</b> if needed.

Here is an example:

```dart
HttpRequest<List<Post>> getPosts(int offset, int limit) => HttpRequest<List<Post>>()
    ..method = RequestMethod.get
    ..baseUrl = getBaseUrl(BackendUrls.main)
    ..url = '/posts'
    ..parser = (result, headers) async {
        final list = <Post>[];

        result?.forEach((data) {
        list.add(Post.fromJson(data));
        });

        return list;
    }
    ..databaseGetDelegate = ((headers) => PostsBox.getPostsDelegate(offset, limit, headers))
    ..databasePutDelegate = ((result) => PostsBox.putPostsDelegate(result));
```

Where delegates looks like:

```dart
class PostsBox {
  static Future<List<Post>> getPostsDelegate(int offset, int limit, Map? headers) async {
    final postsBox = App.objectBox.store.box<Post>();

    final query = postsBox.query().build();

    query
      ..offset = offset
      ..limit = limit;

    final List<Post> posts = query.find();

    return posts;
  }

  static Future putPostsDelegate(List<Post> result) async {
    final postsBox = App.objectBox.store.box<Post>();

    postsBox.putMany(result);
  }
}
```

Delegates are defined in a separate file as static functions.

After you initialized all request fields you can use it as follows:

```dart
Future<void> loadPosts(int offset, int limit, {bool refresh = false}) async {
    updateState(state.copyWith(posts: StatefulData.loading()));

    late Response<List<Post>> response;

    if (refresh) {
      response = await Apis.posts.getPosts(0, limit).execute();
    } else {
      response = await Apis.posts.getPosts(offset, limit).execute();
    }

    if (response.isSuccessful || response.isSuccessfulFromDatabase) {
      updateState(state.copyWith(posts: StatefulData.result(response.result ?? [])));
    } else {
      updateState(state.copyWith(posts: StatefulData.error(response.error)));
    }
}
```

## Business Logic Layer

This layer contains <b>Interactor</b> classes.
Interactors contain state and subscription to <b>EventBus</b> events (EventBus will be described later). 

State can be updated with <b>updateState</b> method and receivers like view models can later subscribe to state update events with <b>updatesFor</b> or <b>changesFor</b>

Interactors must be annotated with <b>defaultInteractor</b> or <b>singletonInteractor</b>

When interactor is annotated with <b>singletonInteractor</b> it belongs to global interactors collection.

We dont need to write dependencies in our view models for singleton interactors (view model dependencies will be explained below) 
and we can access it with <b>app.interactors</b>

When interactor is annotated with <b>defaultInteractor</b> we need to write dependency for it in our view model (view model dependencies will be explained below) 

This interactors can be disposed when dependent element is disposed

Typical example would be:

```dart
@defaultInteractor
class PostsInteractor extends BaseInteractor<PostsState> with LikePostMixin {
  Future<void> loadPosts(int offset, int limit, {bool refresh = false}) async {
    updateState(state.copyWith(posts: StatefulData.loading()));

    late Response<List<Post>> response;

    if (refresh) {
      response = await app.apis.posts.getPosts(0, limit).execute();
    } else {
      response = await app.apis.posts.getPosts(offset, limit).execute();
    }

    if (response.isSuccessful || response.isSuccessfulFromDatabase) {
      updateState(state.copyWith(posts: StatefulData.result(response.result ?? [])));
    } else {
      updateState(state.copyWith(posts: StatefulData.error(response.error)));
    }
  }

  void _onPostLiked(int id) {
    final posts = (state.posts as ResultData<List<Post>>).result.toList();
    final index = posts.indexWhere((element) => element.id == id);

    if (index == -1) {
      return;
    }

    posts[index] = posts[index].copyWith(isLiked: !posts[index].isLiked);

    updateState(state.copyWith(posts: StatefulData.result(posts)));
  }

  @override
  PostsState get initialState => PostsState();

  @override
  Map<String, EventBusSubscriber> get subscribeTo => {
        Events.eventPostLiked: (payload) {
          _onPostLiked(payload);
        }
      };
}
```

Or singleton interactor:

```dart
@singletonInteractor
class UserDefaultsInteractor extends BaseInteractor<UserDefaultsState> {
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
  Map<String, EventBusSubscriber> get subscribeTo => {};
}

```

In the last example we also can see that every interactor also has <b>savedStateObject</b>

When we override <b>savedStateObject</b> so interactor can save state to <b>SharedPreferences</b>
It later can be restored with <b>onRestore</b>

### EventBus

View models and interactors have access to <b>EventBus</b> events
Events can be subscribed to with <b>subscribeTo</b> getter

An example:

```dart
@override
Map<String, EventBusSubscriber> get subscribeTo => {
      Events.eventPostLiked: (payload) {
        _onPostLiked(payload);
      }
    };
```

To send events you need to access <b>EventBus</b> instance

An example:

```dart
app.eventBus.send(Events.eventPostLiked, payload: id);
```

### MainApp and Apis

There are also utility classes to connect all components of architecture
This classes are generated using <b>builder</b> package

For example here is definition of main app class

```dart
@mainApp
class App extends MvvmReduxApp with AppGen {
  late SharedPreferences prefs;
  late ObjectBox objectBox;
  final apis = Apis();

  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}
```

And here is definition of Apis class 


```dart
@mainApi
class Apis with ApisGen {}
```

App class holds instances to global <b>InteractorCollection</b>, <b>SharedPreferences</b>, <b>Apis</b> and <b>ObjectBox</b>(if needed)
We define global variable for app class and initialize it before calling <b>runApp</b>

## Presentation Layer

Presentation layer consists of view model and view classes that are connected together

### ViewModel

View models contain logic for view classes

It also contains local <b>InteractorCollection</b> and local state that we like <b>Interactor</b> can update with <b>updateState</b>.
We also can listen to state changes with <b>updatesFor</b> or <b>changesFor</b>
We add interactors to view model using <b>dependsOn</b> getter.
Using this getter we can connect default interactors to view model.
When we connect interactor to view model it ensures that interactor is initialized and alive for lifetime of view model.
If we add <b>unique</b> flag we get unique instance of interactor - otherwise we get instance from global interactors collection.
View models like interactors can receive <b>EventBus</b> events using <b>subscribeTo</b> getter.

View models also can override <b>onLaunch</b> method that is called on first frame of corresponding view.

```dart
class PostsListViewModel extends BaseViewModel<PostsListView, PostsListViewState> {
  @override
  List<Connector> get dependsOn => [
        Connector(interactor: PostsInteractor),
        Connector(interactor: PostInteractor, unique: true),
      ];

  @override
  void onLaunch(PostsListView widget) {
    interactors.get<PostsInteractor>().loadPosts(0, 30);
  }

  @override
  void onRestore(Map<String, dynamic> savedStateObject) {
    updateState(HomeViewState.fromJson(savedStateObject));
  }

  void like(int id) {
    interactors.get<PostsInteractor>().likePost(id);
  }

  void openPost(Post post) {
    app.interactors.get<NavigationInteractor>().routeTo(Routes.post, payload: {
      'post': post,
    });
  }

  Stream<StatefulData<List<Post>>?> get postsStream => interactors.get<PostsInteractor>().updates((state) => state.posts);

  @override
  Map<String, dynamic> get savedStateObject => state.toJson();

  Map<String, EventBusSubscriber> get subscribeTo => {
      Events.testEvent: (payload) {
        // ...
      }
    };
}
```

View models also have <b>savedStateObject</b> and it also later can be restored with <b>onRestore</b>

### View

The last class is view. View has a reference to view model and getter for initial state.

Example: 

```dart
class PostsListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PostsListViewWidgetState();
  }
}

class _PostsListViewWidgetState extends BaseView<PostsListView, PostsListViewState, PostsListViewModel> {
  @override
  Widget buildPage(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 232, 232),
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: StreamBuilder<StatefulData<List<Post>>?>(
        stream: viewModel.postsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return buildList(snapshot.data!);
          }

          return Container();
        },
      ),
    );
  }

  Widget buildList(StatefulData<List<Post>> data) {
    return data.when(
      result: (List<Post> value) {
        return ListView.builder(
          itemBuilder: (context, index) {
            final item = value[index];

            return PostCard(
              onTap: () {
                viewModel.openPost(item);
              },
              onLikeTap: () {
                viewModel.like(item.id ?? 1);
              },
              title: item.title ?? '',
              body: item.body ?? '',
              isLiked: item.isLiked,
            );
          },
          itemCount: value.length,
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (dynamic message) {
        return Text(message.toString());
      },
    );
  }

  @override
  PostsListViewModel createViewModel() {
    return PostsListViewModel();
  }

  @override
  PostsListViewState get initialState => PostsListViewState();
}
```

