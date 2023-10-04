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
          unique: true,
          input: input.post,
        ),
      ];

  @override
  void onLaunch(PostView widget) {
    final postInteractor = interactors.get<PostInteractor>();

    if (widget.post == null) {
      postInteractor.loadPost(widget.id!);
    }
  }

  void like(int id) {
    interactors.debugPrintMap();

    interactors.get<PostInteractor>().likePost(id);
  }

  Stream<StatefulData<Post>?> get postStream =>
      interactors.get<PostInteractor>().updates((state) => state.post);

  StatefulData<Post>? get currentPost =>
      interactors.get<PostInteractor>().state.post;

  @override
  PostViewState initialState(PostView input) => PostViewState();
}
