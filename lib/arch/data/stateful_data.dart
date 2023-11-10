import 'package:umvvm/umvvm.dart';

/// Sealed class that holds either loading state, some typed data or error 
sealed class StatefulData<T> {
  /// Returns success data or throws exception if value is not [SuccessData]
  T unwrap() {
    if (this is! SuccessData<T>) {
      throw IllegalStateException(message: 'Not a success data');
    }

    return (this as SuccessData<T>).result;
  }

  const StatefulData();
}

/// [StatefulData] indicating loading state for underlying object
class LoadingData<T> extends StatefulData<T> {
  const LoadingData();
}

/// [StatefulData] indicating success state for underlying object
/// holds result or null
class SuccessData<T> extends StatefulData<T> {
  /// Successfull result for this [StatefulData]
  final T result;

  const SuccessData({
    required this.result,
  });
}

/// [StatefulData] indicating error state for underlying object
/// holds error object or null
class ErrorData<T> extends StatefulData<T> {
  /// Reason object for this error state
  final dynamic error;

  const ErrorData({this.error});
}
