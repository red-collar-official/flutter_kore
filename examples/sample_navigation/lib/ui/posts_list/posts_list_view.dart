import 'package:flutter/material.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_navigation/domain/data/post.dart';
import 'package:sample_navigation/ui/posts_list/components/post_card.dart';

import 'posts_list_view_model.dart';
import 'posts_list_view_state.dart';

class PostsListView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PostsListViewWidgetState();
  }
}

class _PostsListViewWidgetState
    extends NavigationView<PostsListView, PostsListViewState, PostsListViewModel> {
  @override
  Widget buildView(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 232, 232),
      appBar: AppBar(
        title: const Text('Posts'),
      ),
      body: StreamBuilder<StatefulData<List<Post>>?>(
        stream: viewModel.postsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return buildList(snapshot.data!);
          }

          return Container();
        },
      ),
    );
  }

  Widget buildList(StatefulData<List<Post>> data) {
    switch (data) {
      case LoadingData():
        return const Center(child: CircularProgressIndicator());
      case ResultData<List<Post>>(:final result):
        return ListView.builder(
          itemBuilder: (context, index) {
            final item = result[index];

            return PostCard(
              onTap: () {
                viewModel.openPost(item);
              },
              onLikeTap: () {
                viewModel.like(item.id ?? 1);
              },
              title: item.title ?? '',
              body: item.body ?? '',
              isLiked: item.isLiked,
            );
          },
          itemCount: result.length,
        );
      case ErrorData<List<Post>>(:final error):
        return Text(error.toString());
    }
  }

  @override
  PostsListViewModel createViewModel() {
    return PostsListViewModel();
  }
}
