class ResultState<T extends Object> {
  final T? error;
  final String? messageToDisplay;

  const ResultState._({
    required this.error,
    required this.messageToDisplay,
  });

  bool get isSuccessfull => this.error == null && this.messageToDisplay == null;

  ErrorType unwrapError<ErrorType extends Object>() {
    return error! as ErrorType;
  }

  factory ResultState.success() => const ResultState._(
        error: null,
        messageToDisplay: null,
      );

  factory ResultState.check({
    T? error,
    String? messageToDisplay,
  }) =>
      ResultState._(
        error: error,
        messageToDisplay: messageToDisplay,
      );

  factory ResultState.error({
    required T error,
    String? messageToDisplay,
  }) =>
      ResultState._(
        error: error,
        messageToDisplay: messageToDisplay,
      );
}
