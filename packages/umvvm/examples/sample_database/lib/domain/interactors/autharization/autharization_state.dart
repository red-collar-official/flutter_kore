import 'package:freezed_annotation/freezed_annotation.dart';

part 'autharization_state.g.dart';
part 'autharization_state.freezed.dart';

@freezed
class AutharizationState with _$AutharizationState {
  factory AutharizationState({
    String? token,
  }) = _AutharizationState;

  factory AutharizationState.fromJson(Map<String, dynamic> json) =>
      _$AutharizationStateFromJson(json);
}
