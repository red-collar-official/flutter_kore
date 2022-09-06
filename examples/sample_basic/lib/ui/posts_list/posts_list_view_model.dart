import 'package:flutter/material.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_basic/domain/data/post.dart';
import 'package:sample_basic/domain/data/stateful_data.dart';
import 'package:sample_basic/domain/interactors/posts/posts_interactor.dart';
import 'package:sample_basic/ui/post/post_view.dart';

import 'posts_list_view.dart';
import 'posts_list_view_state.dart';

class PostsListViewModel extends BaseViewModel<PostsListView, PostsListViewState> {
  @override
  List<Connector> get dependsOn => [
        Connector(interactor: PostsInteractor),
      ];

  @override
  void onLaunch(PostsListView widget) {
    interactors.get<PostsInteractor>().loadPosts(0, 30);
  }

  void like(int id) {
    interactors.get<PostsInteractor>().likePost(id);
  }

  void openPost(BuildContext context, Post post) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return PostView(post: post);
    }));
  }

  Stream<StatefulData<List<Post>>?> get postsStream => interactors.get<PostsInteractor>().updates((state) => state.posts);
  // Stream<StoreChange<StatefulData<List<Post>>?>> get postsChangesStream => interactors.get<PostsInteractor>().changes((state) => state.posts);
}
