import 'package:dart_mappable/dart_mappable.dart';

part 'posts_list_view_state.mapper.dart';

@MappableClass()
class const PostsListViewState({final bool darkMode = false})
    with PostsListViewStateMappable {
  static const fromMap = PostsListViewStateMapper.fromMap;
}
