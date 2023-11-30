/// Sealed class with possible input field states
/// can be [ValidFieldState], [IgnoredFieldState] or [ErrorFieldState]
sealed class FieldValidationState {}

/// Type of [FieldValidationState] indicating valid input field state
class ValidFieldState extends FieldValidationState {}

/// Type of [FieldValidationState] indicating that field is ignored
class IgnoredFieldState extends FieldValidationState {}

/// Type of [FieldValidationState] indicating that field contains error
class ErrorFieldState extends FieldValidationState {
  /// Description of input error to present to user
  final String? error;

  ErrorFieldState({this.error});
}
