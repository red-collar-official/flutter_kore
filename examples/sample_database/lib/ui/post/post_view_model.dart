import 'package:umvvm/mvvm_redux.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/global/global_store.dart';
import 'package:sample_database/domain/interactors/navigation/components/bottom_sheets/bottom_sheets.dart';
import 'package:sample_database/domain/interactors/navigation/components/dialogs/dialogs.dart';
import 'package:sample_database/domain/interactors/navigation/navigation_interactor.dart';
import 'package:sample_database/domain/interactors/post/post_interactor.dart';

import 'post_view.dart';
import 'post_view_state.dart';

class PostViewModel extends NavigationViewModel<PostView, PostViewState> {
  @override
  List<Connector> dependsOn(PostView input) => [
        app.connectors.postInteractorConnector(unique: true),
      ];

  @override
  void onLaunch(PostView widget) {
    final postInteractor = interactors.get<PostInteractor>();

    if (widget.post == null) {
      postInteractor.loadPost(widget.id!);
    } else {
      postInteractor.useExistingPost(widget.post!);
    }
  }

  void like(int id) {
    interactors.get<PostInteractor>().likePost(id);
  }

  void openTestDialog() {
    app.interactors
        .get<NavigationInteractor>()
        .showDialog(Dialogs.error(), dismissable: false);
  }

  void openTestBottomSheet() {
    app.navigation
        .showBottomSheet(BottomSheets.autharization(), dismissable: false);
  }

  Stream<StatefulData<Post>?> get postStream =>
      interactors.get<PostInteractor>().updates((state) => state.post);

  @override
  PostViewState initialState(PostView input) => PostViewState();

  StatefulData<Post>? get initialPost =>
      interactors.get<PostInteractor>().state.post;
}
