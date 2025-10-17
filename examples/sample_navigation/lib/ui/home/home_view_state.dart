import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_view_state.g.dart';
part 'home_view_state.freezed.dart';

@freezed
abstract class HomeViewState with _$HomeViewState {
  factory HomeViewState() = _HomeViewState;

  factory HomeViewState.fromJson(Map<String, dynamic> json) =>
      _$HomeViewStateFromJson(json);
}
