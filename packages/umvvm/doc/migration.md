# Migration tips

It can be easy to migrate from other architecture since most of components can be disabled and not be used. This way you can connect components one by one.

More info about disabling components can be found [here](./disabling_components.md).

### DI

If you migrate from other DI library you need to wrap your objects in wrappers so they can be used in DI system.

Here is an example:

```dart
// some preudo code

// was
locator.get<ThirdPartyInstance>();

// now

@singleton
class ThirdPartyInstanceWrapper extends BaseHolderWrapper<ThirdPartyInstance, Map<String, dynamic>> {
  @override
  ThirdPartyInstance provideInstance() {
    return ThirdPartyInstance();
  }
}

app.instances.get<ThirdPartyInstanceWrapper>().instance;

// or use some methods to work with instance defined in wrapper
```

Usual in DI libraries dependencies are defined via constructors.

In this library we define dependencies using connectors and dependent instances.

```dart
// some preudo code

// was
class SomeObject {
  SomeObject(
    this.dependency,
  );

  final ThirdPartyDependency dependency;
}

// now

@basicInstance
class ThirdPartyInstanceWrapper extends BaseHolderWrapper<ThirdPartyInstance, Map<String, dynamic>> {
  @override
  ThirdPartyInstance provideInstance() {
    return ThirdPartyInstance();
  }
}

@basicInstance
class Interactor extends BaseInteractor<InteractorState, Map<String, dynamic>> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
    DependentMvvmInstanceConfiguration(
      dependencies: [
        app.connectors.thirdPartyInstanceWrapperConnector(),
      ],
    );

  final ThirdPartyInstanceWrapper dependencyWrapper = getLocalInstance<ThirdPartyInstanceWrapper>();

  @override
  InteractorState get initialState => InteractorState();
}
```

More info about wrappers can be found [here](./wrapper.md).

More info about di component can be found [here](./di.md).

### Events

If you using other state management library based on events it is useful to know that you can do similar thing in Umvvm.
Just create events for your operations - for example: <b>LoadUserRequestEvent</b> and subscribe to this event in your view model or other mvvm instances.
Events can be sent through global event bus instance avaliable via <b>app.eventBus</b> interface. 

Here is an examle:

```dart
@mainApp
class App extends UMvvmApp with AppGen {
  late SharedPreferences prefs;
  final apis = Apis();

  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}

final app = App();

Future<void> main() async {
  await app.initialize();

  runApp(AppView(
    key: AppView.globalKey,
  ));
}

@api
class PostsApi {
  HttpRequest<List<Post>> getPosts(int offset, int limit) =>
      HttpRequest<List<Post>>()
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

@basicInstance
class PostsInteractor extends BaseInteractor<PostsState, Map<String, dynamic>?> {
  Future<void> loadPosts(int offset, int limit, {bool refresh = false}) async {
    updateState(state.copyWith(posts: const LoadingData()));

    late Response<List<Post>> response;

    if (refresh) {
      response = await executeAndCancelOnDispose(app.apis.posts.getPosts(0, limit));
    } else {
      response = await executeAndCancelOnDispose(app.apis.posts.getPosts(offset, limit));
    }

    if (response.isSuccessful) {
      updateState(state.copyWith(posts: SuccessData(result: response.result ?? [])));
    } else {
      updateState(state.copyWith(posts: ErrorData(error: response.error)));
    }
  }

  @override
  List<EventBusSubscriber> subscribe() => [
      on<LoadUserEvent>((event) {
        loadPosts(0, 30, refresh: true);
      }),
    ];
}

class PostsListViewModel extends BaseViewModel<PostsListView, PostsListViewState> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
    DependentMvvmInstanceConfiguration(
      dependencies: [
        app.connectors.postsInteractorConnector(),
      ],
    );

  late final postsInteractor = getLocalInstance<PostsInteractor>();

  @override
  void onLaunch() {
    // ignore
  }

  late final posts = postsInteractor.wrapUpdates((state) => state.posts);

  @override
  PostsListViewState get initialState => PostsListViewState();
}

class PostsListView extends StatefulWidget {
  const PostsListView({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _PostsListViewWidgetState();
  }
}

class _PostsListViewWidgetState extends State<PostsListView> {
  @override
  void initState() {
    super.initState();

    app.eventBus.send(LoadUserEvent());
  }

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 232, 232),
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: StreamBuilder<StatefulData<List<Post>>?>(
        stream: viewModel.posts.stream,
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
    switch (data) {
      case LoadingData():
        return const Center(child: CircularProgressIndicator());
      case SuccessData<List<Post>>(:final result):
        return ListView.builder(
          itemBuilder: (context, index) {
            final item = result[index];

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
          itemCount: result.length,
        );
      case ErrorData<List<Post>>(:final error):
        return Text(error.toString());
    }
  }

  @override
  PostsListViewModel createViewModel() {
    return PostsListViewModel();
  }
}
```

You only need to define stream bindings and use default <b>StreamBuilder</b> to listen to updates.

To learn more about event bus visit [this page](./event_bus.md).

By using <b>InstancePart</b> you can split logic in several small use cases to implement clean architecture pattern.

To learn more about instance parts visit [this page](./instance_part.md).
