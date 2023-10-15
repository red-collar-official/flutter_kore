import 'package:umvvm/umvvm.dart';
import 'package:sample_basic/domain/data/post.dart';
import 'package:sample_basic/domain/global/global_store.dart';
import 'package:sample_basic/domain/interactors/post/post_interactor.dart';

import 'post_view.dart';
import 'post_view_state.dart';

class PostViewModel extends BaseViewModel<PostView, PostViewState> {
  @override
  List<Connector> dependsOn(PostView input) => [
        app.connectors.postInteractorConnector(
          scope: BaseScopes.unique,
          input: input.post,
        ),
      ];

  @override
  void onLaunch(PostView widget) {
    final postInteractor = getLocalInstance<PostInteractor>();

    if (widget.post == null) {
      postInteractor.loadPost(widget.id!);
    }
  }

  void like(int id) {
    getLocalInstance<PostInteractor>().likePost(id);
  }

  Stream<StatefulData<Post>?> get postStream =>
      getLocalInstance<PostInteractor>().updates((state) => state.post);

  StatefulData<Post>? get currentPost =>
      getLocalInstance<PostInteractor>().state.post;

  @override
  PostViewState initialState(PostView input) => PostViewState();
}
