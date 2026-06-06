import 'package:dio/dio.dart' as dio;
import 'package:flutter_kore/flutter_kore.dart';

class HttpRequest<T> extends DioRequest<T> {
  HttpRequest() : super();

  @override
  RequestSettings<dio.Interceptor> get defaultSettings => RequestSettings(
    logPrint: (_) {},
    exceptionPrint: (error, trace) {},
    defaultInterceptors: [
      dio.LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (object) {},
      ),
    ],
  );

  @override
  void decorateRequest(dio.Dio dio, dio.Options options) {
    // ignore
  }

  @override
  Future onError(dio.DioException error, RetryHandler retry) async {
    if (error.type == .cancel) {
      return error;
    }

    return retry();
  }
}

class HttpRequest2<T> extends DioRequest<T> {
  HttpRequest2() : super();

  @override
  RequestSettings<dio.Interceptor> get defaultSettings => RequestSettings(
    logPrint: (_) {},
    exceptionPrint: (_, _) {},
  );

  @override
  void decorateRequest(dio.Dio dio, dio.Options options) {
    // ignore
  }

  @override
  Future onError(dio.DioException error, RetryHandler retry) async {
    if (error.type == .cancel) {
      return error;
    }

    return retry();
  }
}
