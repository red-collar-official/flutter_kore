import 'package:umvvm/umvvm.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/domain/global/global_app.dart';
import 'package:sample_navigation/domain/interactors/navigation/navigation_interactor.dart';
import 'package:sample_navigation/domain/interactors/post/post_interactor.dart';

import 'post_view.dart';
import 'post_view_state.dart';

class PostViewModel extends NavigationViewModel<PostView, PostViewState> {
  @override
  DependentMvvmInstanceConfiguration get configuration => DependentMvvmInstanceConfiguration(
        dependencies: [
          app.connectors.postInteractorConnector(scope: BaseScopes.unique),
        ],
      );

  @override
  void onLaunch() {
    final postInteractor = getLocalInstance<PostInteractor>();

    if (input.post == null) {
      postInteractor.loadPost(input.id!);
    } else {
      postInteractor.useExistingPost(input.post!);
    }
  }

  void like(int id) {
    getLocalInstance<PostInteractor>().likePost(id);
  }

  void openTestDialog() {
    app.instances.get<NavigationInteractor>().showDialog(app.navigation.dialogs.error(), dismissable: false);
  }

  void openTestBottomSheet() {
    app.instances.get<NavigationInteractor>().showBottomSheet(
          app.navigation.bottomSheets.authorization(),
          dismissable: false,
        );
  }

  Stream<StatefulData<Post>?> get postStream => getLocalInstance<PostInteractor>().updates((state) => state.post);

  StatefulData<Post>? get initialPost => getLocalInstance<PostInteractor>().state.post;

  @override
  PostViewState get initialState => PostViewState();
}
