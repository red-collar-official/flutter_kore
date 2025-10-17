import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_basic/domain/data/post.dart';

part 'post_state.mapper.dart';

@MappableClass()
class PostState with PostStateMappable {
  const PostState({this.post});

  final StatefulData<Post>? post;

  static const fromMap = PostStateMapper.fromMap;
}
