class AppTab {
  const AppTab({
    required this.name,
    required this.index,
  });

  final String name;
  final int index;
}

class AppTabs {
  static const AppTab posts = AppTab(
    name: 'posts',
    index: 0,
  );

  static const AppTab likedPosts = AppTab(
    name: 'liked_posts',
    index: 1,
  );

  static const List<AppTab> tabs = [
    posts,
    likedPosts,
  ];
}
