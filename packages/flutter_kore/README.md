# flutter_kore packge

<img src="https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/doc_images/logo.png?raw=true" alt="header" width="750"/>

[![Code Coverage](https://raw.githubusercontent.com/red-collar-official/flutter_kore/refs/heads/main/packages/flutter_kore/coverage_badge.svg)](https://github.com/red-collar-official/flutter_kore/tree/main/packages/flutter_kore/test)

Set of classes for Flutter app architecture.

### Installing

```yaml
dependencies: 
  flutter_kore: ^<latest version>

dev_dependencies: 
  flutter_kore_generator: ^<latest version>
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

Minimal example can be found [here](https://github.com/red-collar-official/flutter_kore/tree/main/packages/flutter_kore/example).

More complex examples can be found [here](https://github.com/red-collar-official/flutter_kore/tree/main/examples).

Template project can be found [here](https://github.com/red-collar-official/flutter_kore/tree/main/flutter_kore_template).

There are small example with all basic components, example of using navigation and example of connecting database.

### Docs

Here is small example demonstrating all components:

```dart
import 'package:dart_mappable/dart_mappable.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:flutter_kore/flutter_kore_widgets.dart';

part 'main.api.dart';
part 'main.kore.dart';
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

@mainApi
class Apis with ApisGen {}

@mainApp
class App extends KoreApp with AppGen {
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
  RequestSettings<Interceptor> get defaultSettings => RequestSettings(
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

@MappableClass()
class PostsState with PostsStateMappable {
  const PostsState({
    this.posts,
  });

  final StatefulData<List<Post>>? posts;
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

class PostsListView extends StatefulWidget {
  const PostsListView({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _PostsListViewWidgetState();
  }
}

class _PostsListViewWidgetState extends BaseIndependentView<PostsListView> {
  @override
  DependentKoreInstanceConfiguration get configuration =>
      DependentKoreInstanceConfiguration(
        dependencies: [
          app.connectors.postsInteractorConnector(),
        ],
      );

  late final postsInteractor = useLocalInstance<PostsInteractor>();

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

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 232, 232),
      appBar: AppBar(title: const Text('Posts')),
      body: KoreStreamBuilder<StatefulData<List<Post>>?>(
        streamWrap: postsInteractor.wrapUpdates((state) => state.posts),
        builder: (context, snapshot) {
          // build list with snapshot.data...
        },
      ),
    );
  }
}
```

Learn about components:


<img src="https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/doc_images/layers.png?raw=true" alt="layers" width="750"/>


<img src="https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/doc_images/components.png?raw=true" alt="main" width="750"/>

#### Global layer

* [App](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/app.md);
* [DI](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/di.md);
* [Event bus](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/event_bus.md);
* [Navigation](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/navigation.md).

#### Data Layer

* [Apis and databases](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/apis.md). 

#### Domain Layer

* [Interactors](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/interactor.md);
* [Wrappers](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/wrapper.md);
* [Instance parts](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/instance_part.md);
* [KoreInstance](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/kore_instance.md);
* [Custom kore instances](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/custom_instances.md).

#### Presentation layer

* [View models](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/view_model.md);
* [Widgets and view states](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/widget.md);
* [Custom kore instances](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/custom_instances.md).

#### Utility

* [FormViewModelMixin, UseDisposableMixin, StatefulData, KoreStreamBuilder etc...](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/utility.md).

#### Other materials

* [Testing](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/testing.md);
* [Disabling components](https://github.com/red-collar-official/flutter_kore/blob/main/packages/flutter_kore/doc/disabling_components.md).

#### Important note

To generate test coverage report run <b>sh coverage.sh.</b>
