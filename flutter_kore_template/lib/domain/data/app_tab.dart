import 'package:material_ui/material_ui.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'app_tab.mapper.dart';

@MappableClass()
class const AppTab({required final String name, required final int index, required final IconData icon})
    with AppTabMappable;

class AppTabs {
  static const posts = AppTab(name: 'posts', index: 0, icon: Icons.feed);
  static const likedPosts = AppTab(name: 'liked_posts', index: 1, icon: Icons.feed);

  static const List<AppTab> tabs = [posts, likedPosts];
}
