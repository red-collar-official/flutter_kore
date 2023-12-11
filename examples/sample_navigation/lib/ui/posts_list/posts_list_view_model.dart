import 'package:umvvm/umvvm.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/domain/global/global_app.dart';
import 'package:sample_navigation/domain/interactors/posts/posts_interactor.dart';

import 'posts_list_view.dart';
import 'posts_list_view_state.dart';

class PostsListViewModel
    extends NavigationViewModel<PostsListView, PostsListViewState> {
  @override
  DependentMvvmInstanceConfiguration get configuration =>
      DependentMvvmInstanceConfiguration(
        dependencies: [
          app.connectors.postsInteractorConnector(),
        ],
      );

  @override
  void onLaunch(PostsListView widget) {
    getLocalInstance<PostsInteractor>().loadPosts(0, 30);
  }

  void like(int id) {
    getLocalInstance<PostsInteractor>().likePost(id);
  }

  void openPost(Post post) {
    app.navigation.routeTo(
      app.navigation.routes.post(
        post: post,
      ),
      forceGlobal: true,
    );
  }

  Stream<StatefulData<List<Post>>?> get postsStream =>
      getLocalInstance<PostsInteractor>().updates((state) => state.posts);

  @override
  PostsListViewState get initialState => PostsListViewState();

  // Stream<StoreChange<StatefulData<List<Post>>?>> get postsChangesStream => getLocalInstance<PostsInteractor>().changes((state) => state.posts);
}
