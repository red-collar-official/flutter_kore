import 'package:dart_mappable/dart_mappable.dart';

part 'posts_list_view_state.mapper.dart';

@MappableClass()
class PostsListViewState with PostsListViewStateMappable {
  const PostsListViewState({this.darkMode = false});

  final bool darkMode;

  static const fromMap = PostsListViewStateMapper.fromMap;
}
