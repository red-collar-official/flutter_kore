class ResultState<T extends Object> {
  final Object? error;
  final T? result;
  final String? messageToDisplay;

  const ResultState._({
    this.error,
    this.messageToDisplay,
    this.result,
  });

  bool get isSuccessfull => this.error == null && this.messageToDisplay == null;

  ErrorType unwrapError<ErrorType extends Object>() {
    return error! as ErrorType;
  }

  factory ResultState.success({
    T? result,
  }) =>
      ResultState._(
        result: result,
      );

  factory ResultState.check({
    Object? error,
    String? messageToDisplay,
  }) =>
      ResultState._(
        error: error,
        messageToDisplay: messageToDisplay,
      );

  factory ResultState.error({
    required Object error,
    String? messageToDisplay,
  }) =>
      ResultState._(
        error: error,
        messageToDisplay: messageToDisplay,
      );
}
