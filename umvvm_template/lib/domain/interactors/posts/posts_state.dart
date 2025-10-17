import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:flutter_kore_template/domain/data/data.dart';

part 'posts_state.mapper.dart';

@MappableClass()
class PostsState with PostsStateMappable {
  const PostsState({
    this.posts,
  });

  final StatefulData<List<Post>>? posts;
}
