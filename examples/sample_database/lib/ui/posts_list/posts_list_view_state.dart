import 'package:freezed_annotation/freezed_annotation.dart';

part 'posts_list_view_state.g.dart';
part 'posts_list_view_state.freezed.dart';

@freezed
abstract class PostsListViewState with _$PostsListViewState {
  factory PostsListViewState({@Default(false) bool darkMode}) =
      _PostsListViewState;

  factory PostsListViewState.fromJson(Map<String, dynamic> json) =>
      _$PostsListViewStateFromJson(json);
}
