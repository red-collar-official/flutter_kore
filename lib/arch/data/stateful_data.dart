sealed class StatefulData<T> {
  T unwrap() {
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