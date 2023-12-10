import 'package:flutter/material.dart';
import 'package:sample_basic/ui/posts_list/posts_list_view.dart';
import 'domain/global/global_app.dart';

void main() async {
  await initApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PostsListView(),
    );
  }
}
