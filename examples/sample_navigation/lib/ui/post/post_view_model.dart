import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_navigation/domain/global/global_app.dart';
import 'package:sample_navigation/domain/interactors/navigation/navigation_interactor.dart';
import 'package:sample_navigation/domain/interactors/post/post_interactor.dart';

import 'post_view.dart';
import 'post_view_state.dart';

class PostViewModel extends NavigationViewModel<PostView, PostViewState> {
  @override
  DependentKoreInstanceConfiguration get configuration =>
      DependentKoreInstanceConfiguration(
        dependencies: [
          app.connectors.postInteractorConnector(scope: BaseScopes.unique),
        ],
      );

  late final postInteractor = useLocalInstance<PostInteractor>();

  @override
  void onLaunch() {
    if (input.post == null) {
      postInteractor.loadPost(input.id!);
    } else {
      postInteractor.useExistingPost(input.post!);
    }
  }

  void like(int id) {
    postInteractor.likePost(id);
  }

  void openTestDialog() {
    app.instances
        .get<NavigationInteractor>()
        .showDialog(app.navigation.dialogs.error(), dismissable: false);
  }

  void openTestBottomSheet() {
    app.instances.get<NavigationInteractor>().showBottomSheet(
          app.navigation.bottomSheets.authorization(),
          dismissable: false,
        );
  }

  late final post = postInteractor.wrapUpdates((state) => state.post);

  @override
  PostViewState get initialState => PostViewState();
}
