import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_defaults_state.g.dart';
part 'user_defaults_state.freezed.dart';

@freezed
class UserDefaultsState with _$UserDefaultsState {
  factory UserDefaultsState({
    @Default(false) bool firstAppLaunch,
  }) = _UserDefaultsState;

  factory UserDefaultsState.fromJson(Map<String, dynamic> json) =>
      _$UserDefaultsStateFromJson(json);
}
