import 'package:umvvm/umvvm.dart';

sealed class StatefulData<T> {
  T unwrap() {
    if (this is! SuccessData<T>) {
      throw IllegalStateException(message: 'Not a success data');
    }

    return (this as SuccessData<T>).result;
  }

  const StatefulData();
}

class LoadingData<T> extends StatefulData<T> {
  const LoadingData();
}

class SuccessData<T> extends StatefulData<T> {
  final T result;

  const SuccessData({
    required this.result,
  });
}

class ErrorData<T> extends StatefulData<T> {
  final dynamic error;

  const ErrorData({this.error});
}
