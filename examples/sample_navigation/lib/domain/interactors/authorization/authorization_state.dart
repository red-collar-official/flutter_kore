import 'package:freezed_annotation/freezed_annotation.dart';

part 'authorization_state.g.dart';
part 'authorization_state.freezed.dart';

@freezed
class AuthorizationState with _$AuthorizationState {
  factory AuthorizationState({
    String? token,
  }) = _AuthorizationState;

  factory AuthorizationState.fromJson(Map<String, dynamic> json) => _$AuthorizationStateFromJson(json);
}
