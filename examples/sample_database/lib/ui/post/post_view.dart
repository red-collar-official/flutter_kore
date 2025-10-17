import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/domain/global/global_app.dart';
import 'package:sample_database/domain/interactors/interactors.dart';
import 'package:sample_database/ui/posts_list/components/post_card.dart';
import 'package:flutter_kore/flutter_kore_widgets.dart';

class PostView extends StatefulWidget {
  final Post? post;
  final int? id;

  const PostView({super.key, this.post, this.id});

  @override
  State<StatefulWidget> createState() {
    return _PostViewWidgetState();
  }
}

class _PostViewWidgetState extends BaseIndependentView<PostView> {
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

  late final post = postInteractor.wrapUpdates((state) => state.post);

  @override
  void initState() {
    super.initState();

    if (input.post == null) {
      postInteractor.loadPost(input.id!);
    }
  }

  void like(int id) {
    postInteractor.likePost(id);
  }

  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Post')),
      body: Center(
        child: KoreStreamBuilder<StatefulData<Post>?>(
          streamWrap: post,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return buildPost(snapshot.data!);
            }

            return Container();
          },
        ),
      ),
    );
  }

  Widget buildPost(StatefulData<Post> data) {
    return switch (data) {
      SuccessData(result: final result) => PostCard(
        onTap: () {},
        title: result.title ?? '',
        body: result.body ?? '',
        isLiked: result.isLiked,
        onLikeTap: () {
          like(result.id ?? 0);
        },
      ),
      LoadingData() => const Center(child: CircularProgressIndicator()),
      ErrorData(error: final error) => Text(error.toString()),
    };
  }
}
