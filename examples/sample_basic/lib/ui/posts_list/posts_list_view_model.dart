import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_basic/domain/data/post.dart';
import 'package:sample_basic/domain/global/global_app.dart';
import 'package:sample_basic/domain/interactors/posts/posts_interactor.dart';
import 'package:sample_basic/domain/interactors/user_defaults/user_defaults_interactor.dart';
import 'package:sample_basic/ui/post/post_view.dart';

import 'posts_list_view.dart';
import 'posts_list_view_state.dart';

class PostsListViewModel
    extends BaseViewModel<PostsListView, PostsListViewState> {
  @override
  DependentKoreInstanceConfiguration get configuration =>
      DependentKoreInstanceConfiguration(
        dependencies: [app.connectors.postsInteractorConnector()],
      );

  late final postsInteractor = useLocalInstance<PostsInteractor>();

  late final userDefaultsInteractor = app.instances
      .get<UserDefaultsInteractor>();

  @override
  void onLaunch() {
    postsInteractor.loadPosts(0, 30, refresh: true);
    userDefaultsInteractor.saveFirstAppLaunch();
  }

  void like(int id) {
    postsInteractor.likePost(id);
  }

  void openPost(BuildContext context, Post post) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return PostView(post: post);
        },
      ),
    );
  }

  late final posts = postsInteractor.wrapUpdates((state) => state.posts);

  @override
  PostsListViewState get initialState => const PostsListViewState();
}
