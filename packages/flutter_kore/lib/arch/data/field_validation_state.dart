/// Sealed class with possible input field states
///
/// Can be [ValidFieldState], [IgnoredFieldState] or [ErrorFieldState]
sealed class FieldValidationState {
  const FieldValidationState();
}

/// Type of [FieldValidationState] indicating valid input field state
class ValidFieldState extends FieldValidationState {
  // coverage:ignore-start
  const ValidFieldState();
  // coverage:ignore-end
}

/// Type of [FieldValidationState] indicating that field is ignored
class IgnoredFieldState extends FieldValidationState {
  // coverage:ignore-start
  const IgnoredFieldState();
  // coverage:ignore-end
}

/// Type of [FieldValidationState] indicating that field contains error
class ErrorFieldState extends FieldValidationState {
  /// Description of input error to present to user
  final String? error;

  // coverage:ignore-start
  const ErrorFieldState({this.error});
  // coverage:ignore-end
}
