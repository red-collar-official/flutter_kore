import 'package:dio/dio.dart' as dio;
import 'package:umvvm/umvvm.dart';

class HttpRequest<T> extends RequestImplementation<T> {
  HttpRequest() : super();

  @override
  Map<String, dynamic> get defaultHeaders => {};

  @override
  String get defaultBaseUrl => '';

  @override
  void logPrint(Object obj) {
    // ignore
  }

  @override
  void exceptionPrint(Object error, StackTrace trace) {
    // ignore
  }

  @override
  void onAuthorization(dio.Dio dio) {
    // ignore
  }

  @override
  Future onError(dio.DioException error, RetryHandler retry) async {
    if (error.type == dio.DioExceptionType.cancel) {
      return error;
    }

    return retry();
  }
}

class HttpRequest2<T> extends RequestImplementation<T> {
  HttpRequest2() : super();

  @override
  Map<String, dynamic> get defaultHeaders => {};

  @override
  String get defaultBaseUrl => '';

  @override
  Iterable<dio.Interceptor> get defaultInterceptors => [
    dio.LogInterceptor(),
  ];

  @override
  void logPrint(Object obj) {
    // ignore
  }

  @override
  void exceptionPrint(Object error, StackTrace trace) {
    // ignore
  }

  @override
  void onAuthorization(dio.Dio dio) {
    // ignore
  }

  @override
  Future onError(dio.DioException error, RetryHandler retry) async {
    if (error.type == dio.DioExceptionType.cancel) {
      return error;
    }

    return retry();
  }
}
