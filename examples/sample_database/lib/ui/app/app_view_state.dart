import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_view_state.g.dart';
part 'app_view_state.freezed.dart';

@freezed
class AppViewState with _$AppViewState {
  factory AppViewState() = _AppViewState;

  factory AppViewState.fromJson(Map<String, dynamic> json) =>
      _$AppViewStateFromJson(json);
}
