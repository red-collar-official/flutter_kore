import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:umvvm/mvvm_redux.dart';
import 'package:sample_database/domain/data/post.dart';

part 'posts_state.freezed.dart';

@freezed
class PostsState with _$PostsState {
  factory PostsState({
    StatefulData<List<Post>>? posts,
  }) = _PostsState;
}
