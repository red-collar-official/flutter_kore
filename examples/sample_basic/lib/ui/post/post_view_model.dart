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

  late final postInteractor = getLocalInstance<PostInteractor>();

  @override
  void onLaunch(PostView widget) {
    if (widget.post == null) {
      postInteractor.loadPost(widget.id!);
    }
  }

  void like(int id) {
    postInteractor.likePost(id);
  }

  Stream<StatefulData<Post>?> get postStream =>
      postInteractor.updates((state) => state.post);

  StatefulData<Post>? get currentPost => postInteractor.state.post;

  @override
  PostViewState initialState(PostView input) => PostViewState();
}
