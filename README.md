# UMVVM library

![Tests code coverage status](coverage/coverage_badge.svg)

Set of classes for Flutter app architecture.

### Installing

Info about installing here.

### Examples

Examples can be found [here](./examples).

There is small basic example with all basic components, example on using navigation and example of connecting database.

### Docs

Here is small example demonstrating all components:

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
      response = await executeRequest(app.apis.posts.getPosts(0, limit));
    } else {
      response = await executeRequest(app.apis.posts.getPosts(offset, limit));
    }

    if (response.isSuccessful) {
      updateState(state.copyWith(posts: SuccessData(result: response.result ?? [])));
    } else {
      updateState(state.copyWith(posts: ErrorData(error: response.error)));
    }
  }
}

class PostsListViewModel extends BaseViewModel<PostsListView, PostsListViewState> {
  @override
  List<Connector> dependsOn(PostsListView input) => [
        app.connectors.postsInteractorConnector(),
      ];

  late final postsInteractor = getLocalInstance<PostsInteractor>();

  @override
  void onLaunch(PostsListView widget) {
    postsInteractor.loadPosts(0, 30, refresh: true);
  }

  void openPost(BuildContext context, Post post) {
    app.navigation.routeTo(
      app.navigation.routes.post(
        post: post,
      ),
      forceGlobal: true,
    );
  }

  Stream<StatefulData<List<Post>>?> get postsStream => postsInteractor.updates((state) => state.posts);

  @override
  PostsListViewState initialState(PostsListView input) => PostsListViewState();
}

class PostsListView extends BaseWidget {
  const PostsListView({
    super.key,
    super.viewModel,
  });

  @override
  State<StatefulWidget> createState() {
    return _PostsListViewWidgetState();
  }
}

class _PostsListViewWidgetState extends NavigationView<PostsListView,
    PostsListViewState, PostsListViewModel> {
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

Learn about components:

#### Global layer

* [App](./docs/app.md);
* [DI](./docs/di.md);
* [Event bus](./docs/event_bus.md);
* [Navigation](./docs/navigation.md).

#### Data Layer

* [Apis and databases](./docs/apis.md). 

#### Domain Layer

* [Interactors](./docs/interactor.md);
* [Wrappers](./docs/wrapper.md);
* [Instance parts](./docs/instance_part.md);
* [MvvmInstance](./docs/mvvm_instance.md);
* [Custom Mvvm instances](./docs/custom_instances.md).

#### View layer

* [View models](./docs/view_model.md);
* [Widgets and view states](./docs/widget.md);
* [Custom Mvvm instances](./docs/custom_instances.md).

#### Utility

* [FormViewModelMixin, UseDisposableMixin, StatefulData etc...](./docs/utility.md).

#### Other materials

* [Testing](./docs/testing.md);
* [Migration tips](./docs/migration.md);
* [Disabling components](./docs/disabling_components.md).

#### Important note

To generage test coverage report run sh coverage.sh

If you using VSCode then to quickly generate files for this architecture use [UMvvm-Gen VSCode extension](https://gitlab.rdclr.ru/flutter/umvvm-vs-code-gen-plugin/)

