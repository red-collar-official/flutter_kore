import 'package:sample_navigation/ui/post/post_view.dart';
import 'package:sample_navigation/ui/post/post_view_model.dart';
import 'package:umvvm/umvvm.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/domain/global/global_app.dart';
import 'package:sample_navigation/domain/interactors/post/post_interactor.dart';
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
    await initApp(testMode: true);

    app.registerInstances();
    await app.createSingletons();

    final postInteractor = PostInteractorMock();
    app.instances.addBuilder<PostInteractor>(() => postInteractor);

    final postViewModel = PostViewModel();
    const mockWidget = PostView(id: 1);

    // ignore: cascade_invocations
    postViewModel
      ..initialize(mockWidget)
      ..onLaunch();

    expect((postViewModel.initialPost as SuccessData).result.id, 1);
  });
}
