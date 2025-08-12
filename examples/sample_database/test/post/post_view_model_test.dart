import 'package:sample_database/ui/post/post_view.dart';
import 'package:sample_database/ui/post/post_view_model.dart';
import 'package:umvvm/umvvm.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/global/global_app.dart';
import 'package:sample_database/domain/interactors/post/post_interactor.dart';
import 'package:test/test.dart';

class PostInteractorMock extends PostInteractor {
  @override
  Future<void> loadPost(int id, {bool refresh = false}) async {
    updateState(state.copyWith(
      post: SuccessData(result: Post(id: 1)),
    ));
  }
}

void main() {
  test('PostViewModelTest', () async {
    // need to run before tests
    // bash <(curl -s https://raw.githubusercontent.com/objectbox/objectbox-dart/main/install.sh)

    await initApp(testMode: true);

    app.registerInstances();

    final postInteractor = PostInteractorMock();
    app.instances.mock<PostInteractor>(instance: postInteractor);

    final postViewModel = PostViewModel();
    const mockWidget = PostView(id: 1);

    // ignore: cascade_invocations
    postViewModel
      ..initialize(mockWidget)
      ..onLaunch();

    expect((postViewModel.post.current as SuccessData).result.id, 1);
  });
}
