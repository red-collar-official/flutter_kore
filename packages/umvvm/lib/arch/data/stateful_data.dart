import 'package:umvvm/umvvm.dart';

/// Sealed class that holds either loading state, some typed data or error
///
/// ```dart
/// var statefulData = LoadingData();
///
/// statefulData.unwrap(); // throws error
///
/// statefulData = ErrorData(error: 'test error');
///
/// statefulData.unwrap(); // throws error
///
/// statefulData = SuccessData(result: 1);
///
/// statefulData.unwrap(); // valid
/// ```
sealed class StatefulData<T> {
  /// Returns success data or throws exception if value is not [SuccessData]
  T unwrap() {
    if (this is! SuccessData<T>) {
      throw IllegalStateException(message: 'Not a success data');
    }

    return (this as SuccessData<T>).result;
  }

  // coverage:ignore-start
  const StatefulData();
  // coverage:ignore-end
}

/// [StatefulData] indicating loading state for underlying object
class LoadingData<T> extends StatefulData<T> {
  // coverage:ignore-start
  const LoadingData();
  // coverage:ignore-end
}

/// [StatefulData] indicating success state for underlying object
/// holds result or null
class SuccessData<T> extends StatefulData<T> {
  /// Successfull result for this [StatefulData]
  final T result;

  // coverage:ignore-start
  const SuccessData({
    required this.result,
  });
  // coverage:ignore-end
}

/// [StatefulData] indicating error state for underlying object
/// holds error object or null
class ErrorData<T> extends StatefulData<T> {
  /// Reason object for this error state
  final dynamic error;

  // coverage:ignore-start
  const ErrorData({this.error});
  // coverage:ignore-end
}
