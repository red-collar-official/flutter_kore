import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/ui/posts_list/components/post_card.dart';

import 'post_view_model.dart';
import 'post_view_state.dart';

class PostView extends BaseWidget {
  final Post? post;
  final int? id;

  const PostView({
    super.key,
    this.post,
    this.id,
    super.viewModel,
  });

  @override
  State<StatefulWidget> createState() {
    return _PostViewWidgetState();
  }
}

class _PostViewWidgetState extends NavigationView<PostView, PostViewState, PostViewModel> {
  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: Center(
        child: UmvvmStreamBuilder<StatefulData<Post>?>(
          streamWrap: viewModel.post,
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
            viewModel.like(result.id ?? 0);
            //viewModel.openTestBottomSheet();
          },
        ),
      LoadingData() => const Center(child: CircularProgressIndicator()),
      ErrorData(error: final error) => Text(error.toString()),
    };
  }

  @override
  PostViewModel createViewModel() {
    return PostViewModel();
  }
}
