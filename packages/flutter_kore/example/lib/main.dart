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

  const PostLikedEvent({required this.id});
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
  const PostsState({this.posts, this.active});

  final StatefulData<List<Post>>? posts;
  final bool? active;
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

  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: PostsListView()),
  );
}

class HttpRequest<T> extends DioRequest<T> {
  @override
  RequestSettings<dio.Interceptor> get defaultSettings => RequestSettings(
    logPrint: (message) {
      if (kDebugMode) {
        print(message);
      }
    },
    exceptionPrint: (error, trace) {
      if (kDebugMode) {
        print(error);
        print(trace);
      }
    },
  );

  @override
  void onAuthorization(dio.Dio dio) {
    // ignore
  }

  @override
  Future onError(dio.DioException error, RetryHandler retry) async {
    return error;
  }
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
class PostsInteractor
    extends BaseInteractor<PostsState, Map<String, dynamic>?> {
  Future<void> loadPosts(int offset, int limit, {bool refresh = false}) async {
    updateState(state.copyWith(posts: const LoadingData()));

    late Response<List<Post>> response;

    if (refresh) {
      response = await executeAndCancelOnDispose(
        app.apis.posts.getPosts(0, limit),
      );
    } else {
      response = await executeAndCancelOnDispose(
        app.apis.posts.getPosts(offset, limit),
      );
    }

    if (response.isSuccessful) {
      updateState(
        state.copyWith(posts: SuccessData(result: response.result ?? [])),
      );
    } else {
      updateState(state.copyWith(posts: ErrorData(error: response.error)));
    }
  }

  @override
  List<EventBusSubscriber> subscribe() => [
    on<PostLikedEvent>((event) {
      // update state
    }),
  ];

  @override
  PostsState get initialState => const PostsState();
}

class PostsListView extends BaseWidget {
  const PostsListView({super.key, super.viewModel});

  @override
  State<StatefulWidget> createState() {
    return _PostsListViewWidgetState();
  }
}

class _PostsListViewWidgetState extends BaseIndependentView<PostsListView> {
  @override
  DependentKoreInstanceConfiguration get configuration =>
      DependentKoreInstanceConfiguration(
        dependencies: [app.connectors.postsInteractorConnector()],
      );

  late final postsInteractor = useLocalInstance<PostsInteractor>();

  late final posts = postsInteractor.wrapUpdates((state) => state.posts);

  void openPost(Post post) {
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
  void initState() {
    super.initState();

    postsInteractor.loadPosts(0, 30, refresh: true);
  }

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 232, 232),
      appBar: AppBar(title: const Text('Posts')),
      body: KoreStreamBuilder<StatefulData<List<Post>>?>(
        streamWrap: posts,
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
                openPost(item);
              },
              onLikeTap: () {
                like(item.id ?? 1);
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
}

class PostCard extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  final String body;
  final bool isLiked;
  final VoidCallback onLikeTap;

  const PostCard({
    super.key,
    required this.onTap,
    required this.title,
    required this.body,
    required this.isLiked,
    required this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 0,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildUserHeader(),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 8),
              Text(body),
              const SizedBox(height: 8),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      GestureDetector(
        onTap: onLikeTap,
        child: Icon(
          Icons.heart_broken,
          color: isLiked ? Colors.red : Colors.grey,
        ),
      ),
    ],
  );

  Widget _buildUserHeader() => const Row(
    children: [
      Icon(Icons.person),
      Text('Unnamed user', style: TextStyle(fontWeight: FontWeight.bold)),
    ],
  );
}
