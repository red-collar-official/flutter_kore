import 'package:umvvm/umvvm.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/domain/global/global_store.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/routes.dart';
import 'package:sample_navigation/domain/interactors/posts/posts_interactor.dart';

import 'posts_list_view.dart';
import 'posts_list_view_state.dart';

class PostsListViewModel
    extends NavigationViewModel<PostsListView, PostsListViewState> {
  @override
  List<Connector> dependsOn(PostsListView input) => [
        app.connectors.postsInteractorConnector(),
      ];

  @override
  void onLaunch(PostsListView widget) {
    getLocalInstance<PostsInteractor>().loadPosts(0, 30);
  }

  void like(int id) {
    getLocalInstance<PostsInteractor>().likePost(id);
  }

  void openPost(Post post) {
    app.navigation.routeTo(
      Routes.post(
        post: post,
      ),
      forceGlobal: true,
    );
  }

  Stream<StatefulData<List<Post>>?> get postsStream =>
      getLocalInstance<PostsInteractor>().updates((state) => state.posts);

  @override
  PostsListViewState initialState(PostsListView input) => PostsListViewState();

  // Stream<StoreChange<StatefulData<List<Post>>?>> get postsChangesStream => interactors.get<PostsInteractor>().changes((state) => state.posts);
}
