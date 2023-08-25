# MVVM-Redux library

## Data Layer

Data layer consists of <b>Api</b> and <b>Box</b> classes.

Api class contains getters or functions that return <b>HttpRequest</b>.
Api classes must be annotated with <b>api</b> annotation.

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

If project requires database we can use any database such as <b>ObjectBox</b> or <b>Hive</b> or <b>Isar</b> library and add delegates to <b>HttpRequest</b> if needed.

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

This layer contains <b>Interactor</b> and <b>Service</b> classes.

### Interactors

Interactors contain state and subscription to <b>EventBus</b> events (EventBus will be described later). 

You can also specify input type for this interactor

State can be updated with <b>updateState</b> method and receivers like view models can later subscribe to state update events with <b>updates</b> or <b>changes</b>.

Interactors must be annotated with <b>defaultInteractor</b> or <b>singletonInteractor</b>.

When interactor is annotated with <b>singletonInteractor</b> it belongs to global interactors collection.

We dont need to write dependencies in our view models for singleton interactors (view model dependencies will be explained below) 
and we can access it with <b>app.interactors</b>.

When interactor is annotated with <b>defaultInteractor</b> we need to write dependency for it in our view model (view model dependencies will be explained below).

This interactors can be disposed when dependent element is disposed.

Interactors also can depend on other interactors via <b>dependsOn</b> override

Interactors also can use services via <b>usesServices</b> override

They are connected with <b>Connector</b> objects that will be discussed below

Typical example would be:

```dart
@defaultInteractor
class PostsInteractor extends BaseInteractor<PostsState, String> with LikePostMixin {
  @override
  List<Connector> dependsOn(String? input) => [
        Connector(type: SupportInteractor, unique: true),
      ];

  @override
  List<Connector> usesServices(String? input) => [
        Connector(type: ReactionsService),
      ];

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
  PostsState initialState(String? input) => PostsState();

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
@singletonInteractor
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
  List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>((event) {
        _onPostLiked(event.id);
      }),
    ];
}

```

In the last example we also can see that every interactor also has <b>savedStateObject</b>.

When we override <b>savedStateObject</b> so interactor can save state to <b>SharedPreferences</b> or other provider
It later can be restored with <b>onRestore</b>. It also has <b>isRestores</b> flag - that is false by default.

### Services

Services hold instances of third party dependencies
Service can be just used as instance holders or contain logic for working with third party api

Services also can be singleton or default

Services unlike interactors don`t have state, but they also can receive <b>EventBus</b> events (EventBus will be described later). 

Typical example would be:

```dart
@defaultService
class StringService extends BaseService<String, String> {
  @override
  String provideInstance(String? input) {
    return '';
  }
}

```

or singleton service:

```dart
@singletonService
class StringService extends BaseService<String, String> {
  @override
  String provideInstance(String? input) {
    return '';
  }
}

```

Instances can be then obtained using <b>app.services.get<T>()</b>

### Connectors

Connectors are objects that describe dependency for interactor or service

We can specify a type of object(interactor or service) we want to depend on.

We can also specify if we want to get unique instance or shared instance

We also can define count of objects that we want to connect

Examples would be:

```dart
@override
List<Connector> dependsOn(Map<String, dynamic>? input) => [
      Connector(type: SupportInteractor, unique: true), // unique instance
      Connector(type: ShareInteractor, count: 5), // 5 unique instances
    ];

@override
List<Connector> usesServices(Map<String, dynamic>? input) => [
      Connector(type: ReactionsService), // shared instance
    ];
```

Library creates connectors for every single service and interactor 
This way you dont need to write <b>Connector</b> classes for every interactor and just use predefined ones as follows:

```dart
@override
List<Connector> dependsOn(PostView input) => [
      app.connectors.postInteractorConnector(
        unique: true,
        input: input.post,
      ),
    ];
```

### EventBus

View models and interactors have access to <b>EventBus</b> events.
Events can be subscribed to with <b>subscribe</b> method.

An example:

```dart
@override
List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>((event) {
        _onPostLiked(event.id);
      }),
    ];
```

To send events you need to access <b>EventBus</b> instance.

An example:

```dart
app.eventBus.send(PostLikedEvent(id: id));
```

You also can create separate instance of EventBus to handle specific operation - for example file uploading
While we upload file we may want to send progress events in separate event bus

```dart
final fileUploadEventBus = EventBus.newSeparateInstance();
```

### MainApp and Apis

There are also utility classes to connect all components of architecture.
This classes are generated using <b>builder</b> package.

Main app class contains instances of interactor collection and service locator

For example here is definition of main app class:

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

And here is definition of Apis class:


```dart
@mainApi
class Apis with ApisGen {}
```

App class holds instances to global <b>InteractorCollection</b>, <b>ServiceCollection</b>, <b>SharedPreferences</b>, <b>Apis</b> and <b>ObjectBox</b>(if needed)
We define global variable for app class and initialize it before calling <b>runApp</b>.

## Presentation Layer

Presentation layer consists of view model and view classes that are connected together.

### ViewModel

View models contain logic for view classes

It also contains local <b>InteractorCollection</b>, <b>ServiceCollection</b> and local state that we like <b>Interactor</b> can update with <b>updateState</b>.
We also can listen to state changes with <b>updatesFor</b> or <b>changesFor</b>
We add interactors to view model using <b>dependsOn</b> getter.
We add services to view model using <b>usesServices</b> getter.
Using this getter we can connect default interactors to view model.
View models like interactors and services can receive <b>EventBus</b> events using <b>subscribeTo</b> getter.

View models also can override <b>onLaunch</b> method that is called on first frame of corresponding view.

```dart
class PostsListViewModel extends BaseViewModel<PostsListView, PostsListViewState> {
  @override
  List<Connector> dependsOn(PostsListView widget) => [
        Connector(interactor: PostsInteractor),
        Connector(interactor: PostInteractor, unique: true),
      ];
  
  @override
  List<Connector> usesServices(Map<String, dynamic>? input) => [
        Connector(type: ReactionsService), // shared instance
      ];    

  @override
  void onLaunch(PostsListView widget) {
    // called with initState
    interactors.get<PostsInteractor>().loadPosts(0, 30);
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
    interactors.get<PostsInteractor>().likePost(id);
  }

  void openPost(Post post) {
    app.navigation.routeTo(Routes.post, payload: {
      'post': post,
    });
  }

  Stream<StatefulData<List<Post>>?> get postsStream => interactors.get<PostsInteractor>().updates((state) => state.posts);

  @override
  PostsListViewState get initialState => PostsListViewState();

  @override
  Map<String, dynamic> get savedStateObject => state.toJson();

  @override
  List<EventBusSubscriber> subscribe() => [
      on<PostLikedEvent>((event) {
        _onPostLiked(event.id);
      }),
    ];
}
```

View models also have <b>savedStateObject</b> and it also later can be restored with <b>onRestore</b>.

### View

The last class is view. View has a reference to view model and getter for initial state for view model.

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
  Widget buildView(BuildContext context) {
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
}
```

Important note:

If you using VSCode then to quickly generate files for this architecture use [Mvvm-Redux-Gen VSCode extension](https://gitlab.rdclr.ru/flutter/mvvm-redux-vs-code-gen-plugin/)

