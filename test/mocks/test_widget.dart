import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

import 'test_view_model.dart';

class TestWidget extends BaseWidget {
  const TestWidget({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => PostsListViewWidgetState();
}

class PostsListViewWidgetState
    extends BaseView<TestWidget, int, TestViewModel> {
  @override
  Widget buildView(BuildContext context) {
    return Container();
  }

  @override
  TestViewModel createViewModel() => TestViewModel();
}
