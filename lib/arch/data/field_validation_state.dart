sealed class FieldValidationState {}

class ValidFieldState extends FieldValidationState {}

class IgnoredFieldState extends FieldValidationState {}

class ErrorFieldState extends FieldValidationState {
  final String? error;

  ErrorFieldState({this.error});
}
