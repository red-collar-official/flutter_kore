import 'package:flutter/material.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_database/domain/data/post.dart';
import 'package:sample_database/ui/posts_list/components/post_card.dart';

import 'post_view_model.dart';
import 'post_view_state.dart';

class PostView extends StatefulWidget {
  final Post? post;
  final int? id;

  const PostView({
    Key? key,
    this.post,
    this.id,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _PostViewWidgetState();
  }
}

class _PostViewWidgetState
    extends BaseView<PostView, PostViewState, PostViewModel> {
  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: Center(
        child: StreamBuilder<StatefulData<Post>?>(
          stream: viewModel.postStream,
          initialData: viewModel.initialPost,
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
    return data.when(
      result: (Post value) {
        return PostCard(
          onTap: () {},
          title: value.title ?? '',
          body: value.body ?? '',
          isLiked: value.isLiked,
          onLikeTap: () {
            viewModel.like(value.id ?? 0);
            //viewModel.openTestBottomSheet();
          },
        );
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (dynamic message) {
        return Text(message.toString());
      },
    );
  }

  @override
  PostViewModel createViewModel() {
    return PostViewModel();
  }
}
