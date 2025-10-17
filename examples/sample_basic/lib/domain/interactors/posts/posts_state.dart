import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_basic/domain/data/post.dart';

part 'posts_state.freezed.dart';

@freezed
class PostsState with _$PostsState {
  factory PostsState({StatefulData<List<Post>>? posts, bool? active}) =
      _PostsState;
}
