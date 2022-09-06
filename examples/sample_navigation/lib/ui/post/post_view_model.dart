import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/domain/data/stateful_data.dart';
import 'package:sample_navigation/domain/global/global_store.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/bottom_sheets.dart';
import 'package:sample_navigation/domain/interactors/navigation/components/dialogs.dart';
import 'package:sample_navigation/domain/interactors/navigation/navigation_interactor.dart';
import 'package:sample_navigation/domain/interactors/post/post_interactor.dart';

import 'post_view.dart';
import 'post_view_state.dart';

class PostViewModel extends BaseViewModel<PostView, PostViewState> {
  @override
  List<Connector> get dependsOn => [
        Connector(interactor: PostInteractor, unique: true),
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
    app.interactors.get<NavigationInteractor>().showDialog(Dialogs.error, dismissable: false);
  }

  void openTestBottomSheet() {
    app.interactors.get<NavigationInteractor>().showBottomSheet(BottomSheets.autharization, dismissable: false, global: true);
  }

  Stream<StatefulData<Post>?> get postStream => interactors.get<PostInteractor>().updates((state) => state.post);
}
