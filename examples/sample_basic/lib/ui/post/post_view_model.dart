import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_basic/domain/global/global_app.dart';
import 'package:sample_basic/domain/interactors/post/post_interactor.dart';

import 'post_view.dart';
import 'post_view_state.dart';

class PostViewModel extends BaseViewModel<PostView, PostViewState> {
  @override
  DependentKoreInstanceConfiguration get configuration =>
      DependentKoreInstanceConfiguration(
        dependencies: [
          app.connectors.postInteractorConnector(
            scope: BaseScopes.unique,
            input: input.post,
          ),
        ],
      );

  late final postInteractor = useLocalInstance<PostInteractor>();

  @override
  void onLaunch() {
    if (input.post == null) {
      postInteractor.loadPost(input.id!);
    }
  }

  void like(int id) {
    postInteractor.likePost(id);
  }

  late final post = postInteractor.wrapUpdates((state) => state.post);

  @override
  PostViewState get initialState => PostViewState();
}
