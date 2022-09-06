import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sample_basic/domain/data/post.dart';
import 'package:sample_basic/domain/data/stateful_data.dart';

part 'post_state.freezed.dart';

@freezed
class PostState with _$PostState {
  factory PostState({
    StatefulData<Post>? post,
  }) = _PostState;
}
