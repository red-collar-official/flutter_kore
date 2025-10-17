import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/material.dart';

part 'app_tab.mapper.dart';

@MappableClass()
class AppTab with AppTabMappable {
  const AppTab({required this.name, required this.index, required this.icon});

  final String name;
  final int index;
  final IconData icon;
}

class AppTabs {
  static const AppTab posts = AppTab(name: 'posts', index: 0, icon: Icons.feed);

  static const AppTab likedPosts = AppTab(
    name: 'liked_posts',
    index: 1,
    icon: Icons.feed,
  );

  static const List<AppTab> tabs = [posts, likedPosts];
}
