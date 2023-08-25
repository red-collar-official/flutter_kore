import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mvvm_redux/mvvm_redux.dart';
import 'package:sample_database/domain/data/post.dart';

part 'post_state.freezed.dart';

@freezed
class PostState with _$PostState {
  factory PostState({
    StatefulData<Post>? post,
  }) = _PostState;
}
