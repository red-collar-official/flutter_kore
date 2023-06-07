import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mvvm_redux/mvvm_redux.dart';

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
class HttpRequest<T> extends RequestImplementation<T> {
  HttpRequest() : super();

  @override
  Map<String, dynamic> get defaultHeaders => {};

  @override
  String get defaultBaseUrl => '';

  @override
  void logPrint(Object obj) {
    if (kDebugMode) {
      print(obj);
    }
  }

  @override
  void exceptionPrint(Object error, StackTrace trace) {
    if (kDebugMode) {
      print(error);
      print(trace);
    }
  }

  @override
  void onAuthorization(Dio dio) {
    // ignore
  }

  @override
  Future onError(DioException error, RetryHandler retry) async {
    await retry();
  }
}
