import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_basic/domain/data/post.dart';

part 'posts_state.mapper.dart';

@MappableClass()
class const PostsState({
  final StatefulData<List<Post>>? posts,
  final bool? active,
}) with PostsStateMappable {
  static const fromMap = PostsStateMapper.fromMap;
}
