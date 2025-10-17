import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/global/global_app.dart';
import 'package:sample_database/domain/interactors/posts/posts_interactor.dart';

import 'posts_list_view.dart';
import 'posts_list_view_state.dart';

class PostsListViewModel
    extends NavigationViewModel<PostsListView, PostsListViewState> {
  @override
  DependentKoreInstanceConfiguration get configuration =>
      DependentKoreInstanceConfiguration(
        dependencies: [app.connectors.postsInteractorConnector()],
      );

  late final postsInteractor = useLocalInstance<PostsInteractor>();

  @override
  void onLaunch() {
    postsInteractor.loadPosts(0, 30);
  }

  void like(int id) {
    postsInteractor.likePost(id);
  }

  void openPost(Post post) {
    app.navigation.routeTo(app.navigation.routes.post(post: post));
  }

  late final posts = postsInteractor.wrapUpdates((state) => state.posts);

  @override
  PostsListViewState get initialState => PostsListViewState();
}
