import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_kore/flutter_kore.dart';
import 'package:sample_navigation/domain/data/post.dart';

part 'post_state.freezed.dart';

@freezed
abstract class PostState with _$PostState {
  factory PostState({StatefulData<Post>? post}) = _PostState;
}
