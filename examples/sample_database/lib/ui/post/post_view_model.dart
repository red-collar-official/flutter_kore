import 'package:umvvm/umvvm.dart';
import 'package:sample_database/domain/global/global_app.dart';
import 'package:sample_database/domain/interactors/post/post_interactor.dart';

import 'post_view.dart';
import 'post_view_state.dart';

class PostViewModel extends NavigationViewModel<PostView, PostViewState> {
  @override
  DependentMvvmInstanceConfiguration get configuration => DependentMvvmInstanceConfiguration(
        dependencies: [
          app.connectors.postInteractorConnector(scope: BaseScopes.unique),
        ],
      );

  late final postInteractor = getLocalInstance<PostInteractor>();

  @override
  void onLaunch() {
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
    app.navigation.showDialog(
      app.navigation.dialogs.error(),
      dismissable: false,
    );
  }

  void openTestBottomSheet() {
    app.navigation.showBottomSheet(
      app.navigation.bottomSheets.authorization(),
      dismissable: false,
    );
  }

  late final post = postInteractor.wrapUpdates((state) => state.post);

  @override
  PostViewState get initialState => PostViewState();
}
