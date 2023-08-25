import 'package:freezed_annotation/freezed_annotation.dart';

part 'field_validation_state.freezed.dart';

@freezed
class FieldValidationState with _$FieldValidationState {
  factory FieldValidationState.valid() = ValidFieldState;
  factory FieldValidationState.ignored() = IgnoredFieldState;
  factory FieldValidationState.invalid(String error) = ErrorFieldState;
}
