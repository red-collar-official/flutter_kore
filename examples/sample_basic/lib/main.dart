import 'package:material_ui/material_ui.dart';
import 'package:sample_basic/ui/posts_list/posts_list_view.dart';

import 'domain/global/global_app.dart';

void main() async {
  await initApp();

  runApp(const MyApp());
}

class const MyApp({super.key}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PostsListView(),
    );
  }
}
