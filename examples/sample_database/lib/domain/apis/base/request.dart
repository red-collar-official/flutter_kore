// ignore: implementation_imports
import 'package:dio/src/dio_error.dart';
// ignore: implementation_imports
import 'package:dio/src/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mvvm_redux/mvvm_redux.dart';

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
  void onAutharization(Dio dio) {
    // ignore
  }

  @override
  Future onError(DioError error, RetryHandler retry) async {
    await retry();
  }
}
