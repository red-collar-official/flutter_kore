import 'package:flutter/material.dart';
import 'package:sample_basic/ui/posts_list/posts_list_view.dart';
import 'domain/global/global_store.dart';

void main() async {
  await initApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PostsListView(),
    );
  }
}
