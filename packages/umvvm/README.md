# UMVVM library

[![Code Coverage](./coverage/coverage_badge.svg)](./test/)

Set of classes for Flutter app architecture.

### Installing

```yaml
dependencies: 
  umvvm: ^<latest version>

dev_dependencies: 
  umvvm_generator: ^<latest version>
```

You also need dependency for build_runner if you don't have it yet.

```yaml
dev_dependencies: 
  build: ^<latest version>
  build_config: ^<latest version>
  build_runner: ^<latest version>
```

To build/rebuild generated files use:

```shell
flutter pub run build_runner build --delete-conflicting-outputs
```

### Examples

Minimal example can be found [here](https://github.com/red-collar-dev/umvvm/tree/main/packages/umvvm/example).

More complex examples can be found [here](https://github.com/red-collar-dev/umvvm/tree/main/examples).

There are small example with all basic components, example of using navigation and example of connecting database.

### Docs

Here is small example demonstrating all components:

```dart
import 'package:dart_mappable/dart_mappable.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

part 'main.api.dart';
part 'main.mvvm.dart';
part 'main.mapper.dart';

class PostLikedEvent {
  final int id;

  const PostLikedEvent({
    required this.id,
  });
}

@MappableClass()
class Post with PostMappable {
  const Post({
    required this.title,
    required this.body,
    required this.id,
    this.isLiked = false,
  });

  final String? title;
  final String? body;
  final int? id;
  final bool isLiked;

  static const fromMap = PostMapper.fromMap;
}

@MappableClass()
class PostsState with PostsStateMappable {
  const PostsState({
    this.posts,
  });

  final StatefulData<List<Post>>? posts;
}

@mainApi
class Apis with ApisGen {}

@mainApp
class App extends UMvvmApp with AppGen {
  final apis = Apis();

  @override
  Future<void> initialize() async {
    await super.initialize();
  }
}

final app = App();

Future<void> main() async {
  await app.initialize();

  runApp(const MaterialApp(home: PostsListView()));
}

class HttpRequest<T> extends DioRequest<T> {
  @override
  RequestSettings get defaultSettings => RequestSettings(
        logPrint: (message) {
          print(message);
        },
        exceptionPrint: (error, trace) {
          print(error);
          print(trace);
        },
      );
}

@api
class PostsApi {
  HttpRequest<List<Post>> getPosts(int offset, int limit) =>
      HttpRequest<List<Post>>()
        ..method = RequestMethod.get
        ..baseUrl = 'http://jsonplaceholder.typicode.com'
        ..url = '/posts'
        ..parser = (result, headers) async {
          final list = <Post>[];

          result?.forEach((data) {
            list.add(Post.fromMap(data));
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
        on<PostLikedEvent>((event) {
          // update posts list...
        }),
      ];

  @override
  PostsState get initialState => const PostsState();
}

class PostsListViewState {}

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
    postsInteractor.loadPosts(0, 30, refresh: true);
  }

  void openPost(Post post) {
    // read more about navigation component in docs

    // app.navigation.routeTo(
    //   app.navigation.routes.post(
    //     post: post,
    //   ),
    //   forceGlobal: true,
    // );
  }

  void like(int id) {
    app.eventBus.send(PostLikedEvent(id: id));
  }

  late final posts = postsInteractor.wrapUpdates((state) => state.posts);

  @override
  PostsListViewState get initialState => PostsListViewState();
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

class _PostsListViewWidgetState extends BaseView<PostsListView, PostsListViewState, PostsListViewModel> {
  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 232, 232),
      appBar: AppBar(title: const Text('Posts')),
      body: UmvvmStreamBuilder<StatefulData<List<Post>>?>(
        streamWrap: viewModel.posts,
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
  PostsListViewModel createViewModel() => PostsListViewModel();
}

// PostCard widget code ... 
```

Learn about components:

<img src="https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/doc_images/overall.png?raw=true" alt="overall" width="600"/>

#### Global layer

* [App](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/app.md);
* [DI](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/di.md);
* [Event bus](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/event_bus.md);
* [Navigation](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/navigation.md).

#### Data Layer

* [Apis and databases](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/apis.md). 

#### Domain Layer

* [Interactors](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/interactor.md);
* [Wrappers](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/wrapper.md);
* [Instance parts](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/instance_part.md);
* [MvvmInstance](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/mvvm_instance.md);
* [Custom Mvvm instances](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/custom_instances.md).

#### Presentation layer

* [View models](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/view_model.md);
* [Widgets and view states](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/widget.md);
* [Custom Mvvm instances](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/custom_instances.md).

#### Utility

* [FormViewModelMixin, UseDisposableMixin, StatefulData, UmvvmStreamBuilder etc...](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/utility.md).

#### Other materials

* [Testing](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/testing.md);
* [Migration tips](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/migration.md);
* [Disabling components](https://github.com/red-collar-dev/umvvm/blob/main/packages/umvvm/doc/disabling_components.md).

#### Important note

To generate test coverage report run <b>sh coverage.sh.</b>
