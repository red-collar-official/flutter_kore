import 'package:dio/dio.dart' as dio;
import 'package:umvvm/umvvm.dart';

class HttpRequest<T> extends DioRequest<T> {
  HttpRequest() : super();

  @override
  RequestSettings get defaultSettings =>
      RequestSettings(logPrint: (message) {}, exceptionPrint: (error, trace) {}, defaultInterceptors: [
        dio.LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (object) {},
        ),
      ]);

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

class HttpRequest2<T> extends DioRequest<T> {
  HttpRequest2() : super();

  @override
  RequestSettings get defaultSettings => RequestSettings(
        logPrint: (message) {},
        exceptionPrint: (error, trace) {},
      );

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
