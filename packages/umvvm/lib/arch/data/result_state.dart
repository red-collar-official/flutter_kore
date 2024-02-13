/// Helper class that holds result of function execution
/// 
/// Can contain error, result, or null
/// 
/// Example:
///
/// ```dart
/// ResultState.success(result: 'test');
/// ```
class ResultState<T extends Object> {
  /// Error to be returned from function as result of function execution
  final Object? error;

  /// Successfull result of function execution
  final T? result;

  /// Message to display if [error] is not null
  final String? messageToDisplay;

  const ResultState._({
    this.error,
    this.messageToDisplay,
    this.result,
  });

  /// Checks if [error] and [messageToDisplay] are null
  bool get isSuccessfull => this.error == null && this.messageToDisplay == null;

  /// Returns error with given type or throws exception
  ErrorType unwrapError<ErrorType extends Object>() {
    return error! as ErrorType;
  }

  /// Constructs successful function result
  ///
  /// Example:
  ///
  /// ```dart
  /// ResultState.success(result: 'test');
  /// ```
  factory ResultState.success({
    T? result,
  }) =>
      ResultState._(
        result: result,
      );

  /// Constructs result based on error value
  ///
  /// Example:
  ///
  /// ```dart
  /// ResultState.check(error: result.serverSideException);
  /// ```
  factory ResultState.check({
    Object? error,
    String? messageToDisplay,
  }) =>
      ResultState._(
        error: error,
        messageToDisplay: messageToDisplay,
      );

  /// Constructs invalid function result
  ///
  /// Example:
  ///
  /// ```dart
  /// return ResultState.error(
  ///   error: StandartEmptyException(),
  ///   messageToDisplay: app.localization.authorization('login_error'),
  /// );
  /// ```
  factory ResultState.error({
    required Object error,
    String? messageToDisplay,
  }) =>
      ResultState._(
        error: error,
        messageToDisplay: messageToDisplay,
      );
}
