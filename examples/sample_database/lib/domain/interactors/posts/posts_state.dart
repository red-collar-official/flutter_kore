import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sample/domain/data/post.dart';
import 'package:sample/domain/data/stateful_data.dart';

part 'posts_state.freezed.dart';

@freezed
class PostsState with _$PostsState {
  factory PostsState({
    StatefulData<List<Post>>? posts,
  }) = _PostsState;
}
