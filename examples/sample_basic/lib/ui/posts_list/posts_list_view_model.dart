import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';
import 'package:sample_basic/domain/data/post.dart';
import 'package:sample_basic/domain/global/global_store.dart';
import 'package:sample_basic/domain/interactors/posts/posts_interactor.dart';
import 'package:sample_basic/domain/interactors/user_defaults/user_defaults_interactor.dart';
import 'package:sample_basic/ui/post/post_view.dart';

import 'posts_list_view.dart';
import 'posts_list_view_state.dart';

class PostsListViewModel
    extends BaseViewModel<PostsListView, PostsListViewState> {
  @override
  List<Connector> dependsOn(PostsListView input) => [
        app.connectors.postsInteractorConnector(),
      ];

  late final postsInteractor = interactors.get<PostsInteractor>();

  late final userDefaultsInteractor =
      app.interactors.get<UserDefaultsInteractor>();

  @override
  void onLaunch(PostsListView widget) {
    postsInteractor.loadPosts(0, 30);
    userDefaultsInteractor.saveFirstAppLaunch();
  }

  void like(int id) {
    postsInteractor.likePost(id);
  }

  void openPost(BuildContext context, Post post) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return PostView(post: post);
    }));
  }

  Stream<StatefulData<List<Post>>?> get postsStream =>
      postsInteractor.updates((state) => state.posts);

  @override
  PostsListViewState initialState(PostsListView input) => PostsListViewState();

  // Stream<StoreChange<StatefulData<List<Post>>?>> get postsChangesStream => postsInteractor.changes((state) => state.posts);
}
