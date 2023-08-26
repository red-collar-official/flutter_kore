sealed class StatefulData<T> {
  T unwrap() {
    return (this as ResultData<T>).result;
  }

  const StatefulData();
}

class LoadingData<T> extends StatefulData<T> {
  const LoadingData();
}

class ResultData<T> extends StatefulData<T> {
  final T result;

  const ResultData({
    required this.result,
  });
}

class ErrorData<T> extends StatefulData<T> {
  final dynamic error;

  const ErrorData({this.error});
}