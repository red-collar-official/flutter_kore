import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// Main class for http requests
///
/// ```dart
/// HttpRequest<List<Post>> getPosts(int offset, int limit) => HttpRequest<List<Post>>()
///     ..method = RequestMethod.get
///     ..baseUrl = getBaseUrl(BackendUrls.main)
///     ..url = '/posts'
///     ..parser = (result, headers) async {
///       final list = <Post>[];
///
///       result?.forEach((data) {
///         list.add(Post.fromJson(data));
///       });
///
///       return list;
///     };
/// ```
class HttpRequest<T> extends DioRequest<T> {
  HttpRequest() : super();

  @override
  RequestSettings<Interceptor> get defaultSettings => RequestSettings(
    logPrint: (message) {
      if (kDebugMode) {
        print(message);
      }
    },
    exceptionPrint: (error, trace) {
      if (kDebugMode) {
        print(error);
        print(trace);
      }
    },
  );

  @override
  void onAuthorization(Dio dio) {
    // ignore
  }

  @override
  Future onError(DioException error, RetryHandler retry) async {
    if (error.type == DioExceptionType.cancel) {
      return error;
    }

    return retry();
  }
}
