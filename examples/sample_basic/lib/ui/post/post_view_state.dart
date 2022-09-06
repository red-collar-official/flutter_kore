import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_view_state.g.dart';
part 'post_view_state.freezed.dart';

@freezed
class PostViewState with _$PostViewState {
  factory PostViewState() = _PostViewState;

  factory PostViewState.fromJson(Map<String, dynamic> json) => _$PostViewStateFromJson(json);
}