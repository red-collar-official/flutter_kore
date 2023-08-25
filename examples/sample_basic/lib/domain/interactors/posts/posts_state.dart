import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_basic/domain/data/post.dart';

part 'posts_state.freezed.dart';

@freezed
class PostsState with _$PostsState {
  factory PostsState({
    StatefulData<List<Post>>? posts,
    bool? active,
  }) = _PostsState;
}
