import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_tab.freezed.dart';

@freezed
class AppTab with _$AppTab {
  const factory AppTab({
    required String name,
    required int index,
    required IconData icon,
  }) = _AppTab;
}

class AppTabs {
  static const AppTab posts = AppTab(
    name: 'posts',
    index: 0,
    icon: Icons.feed,
  );

  static const AppTab likedPosts = AppTab(
    name: 'liked_posts',
    index: 1,
    icon: Icons.feed,
  );

  static const List<AppTab> tabs = [
        posts,
        likedPosts,
      ];
}
