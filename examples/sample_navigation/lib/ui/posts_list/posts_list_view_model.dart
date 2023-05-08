import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/domain/data/stateful_data.dart';
import 'package:sample_navigation/domain/global/global_store.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/screens/routes.dart';
import 'package:sample_navigation/domain/interactors/navigation/navigation_interactor.dart';
import 'package:sample_navigation/domain/interactors/posts/posts_interactor.dart';

import 'posts_list_view.dart';
import 'posts_list_view_state.dart';

class PostsListViewModel
    extends BaseViewModel<PostsListView, PostsListViewState> {
  @override
  List<Connector> dependsOn(PostsListView input) => [
        Connector(type: PostsInteractor),
      ];

  @override
  void onLaunch(PostsListView widget) {
    interactors.get<PostsInteractor>().loadPosts(0, 30);
  }

  void like(int id) {
    interactors.get<PostsInteractor>().likePost(id);
  }

  void openPost(Post post) {
    app.interactors.get<NavigationInteractor>().routeTo(Routes.post, payload: {
      'post': post,
    });
  }

  Stream<StatefulData<List<Post>>?> get postsStream =>
      interactors.get<PostsInteractor>().updates((state) => state.posts);

  @override
  PostsListViewState initialState(PostsListView input) => PostsListViewState();

  // Stream<StoreChange<StatefulData<List<Post>>?>> get postsChangesStream => interactors.get<PostsInteractor>().changes((state) => state.posts);
}
