import 'package:dart_mappable/dart_mappable.dart';
import 'package:umvvm/umvvm.dart';
import 'package:umvvm_template/domain/data/data.dart';

part 'posts_state.mapper.dart';

@MappableClass()
class PostsState with PostsStateMappable {
  const PostsState({
    this.posts,
  });

  final StatefulData<List<Post>>? posts;
}
