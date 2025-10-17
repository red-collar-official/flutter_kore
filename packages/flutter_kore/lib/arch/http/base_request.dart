import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// Settings for [BaseRequest]
class RequestSettings<I> {
  /// Default headers to be added to every instance
  final Map<String, dynamic> defaultHeaders;

  /// Default base url if [BaseRequest.baseUrl] is not provided
  final String defaultBaseUrl;

  /// Default timeout if [BaseRequest.timeout] is not provided
  final int defaultTimeoutInSeconds;

  /// Default interceptors for [BaseRequest]
  final Iterable<I> defaultInterceptors;

  /// Print function for logger
  final void Function(Object obj) logPrint;

  /// Print function for logger
  final void Function(Object error, StackTrace trace) exceptionPrint;

  const RequestSettings({
    this.defaultHeaders = const {},
    this.defaultBaseUrl = '',
    this.defaultTimeoutInSeconds = 10,
    this.defaultInterceptors = const [],
    required this.logPrint,
    required this.exceptionPrint,
  });
}

/// Main class to hold http response
class Response<ItemType> {
  /// Parsed result of request
  ItemType? result;

  /// Error of http request
  Object? error;

  /// Status code for this request
  int code;

  /// Headers for response of this request
  Map? headers;

  /// Flag to detect that [result] was from database
  bool fromDatabase;

  /// Checks that [error] is not null and status [code] is equal to 200 or less than 400 and greater than 200
  bool get isSuccessful => error == null && code >= 200 && code < 400;

  /// Checks that result is not null and was obtained from database
  bool get isSuccessfulFromDatabase => result != null && fromDatabase;

  Response({
    this.result,
    this.error,
    required this.code,
    this.headers,
    this.fromDatabase = false,
  });
}

/// Http request method
enum RequestMethod {
  post,
  get,
  put,
  delete,
  patch,
}

typedef ResponseParser<ItemType> = Future<ItemType> Function(
  dynamic result,
  Map? headers,
);
typedef DatabasePutDelegate<ItemType> = Future Function(ItemType parsedItem);
typedef DatabaseGetDelegate<ItemType> = Future Function(Map? headers);

/// Main class for http requests
///
/// T - return type of request
/// I - interceptor type
/// B - http instance type
/// F - form data type
abstract class BaseRequest<T, I, B, F> {
  BaseRequest({
    this.method = RequestMethod.get,
    this.url,
    this.parser,
    this.query,
    this.timeout,
    this.headers,
    this.body,
    this.baseUrl,
    this.requiresLogin = true,
    this.databaseGetDelegate,
    this.databasePutDelegate,
    this.simulateResponse,
    this.simulateResult,
    this.formData,
    this.ignoreCancelations = false,
    this.onPrefetchFromDatabase,
    this.additionalInterceptors = const [],
  });

  /// Http request method
  RequestMethod method;

  /// Base url for request
  String? baseUrl;

  /// Url to be added to [baseUrl] - always starts with /
  String? url;

  /// Summary timeout for connect and receive timeouts
  ///
  /// It will be divided by half and used as connect and receive timeouts
  Duration? timeout;

  /// Headers for this request
  Map<String, dynamic>? headers;

  /// Parser function for this request
  ///
  /// ```dart
  /// ..parser = (result, headers) async {
  ///     final list = <Post>[];
  ///
  ///     result?.forEach((data) {
  ///       list.add(Post.fromJson(data));
  ///     });
  ///
  ///     return list;
  ///   }
  /// ```
  ResponseParser<T>? parser;

  /// Body for this request
  dynamic body;

  /// Query for this request - will be added to the end of the [url]
  Map<String, dynamic>? query;

  /// Flag to indicate that we need to add autharization headers to this request
  bool requiresLogin;

  /// For tests: simulates parsed result for this request
  @visibleForTesting
  Response<T>? simulateResult;

  /// Delegate to put data to local database
  ///
  /// ```dart
  /// ..databaseGetDelegate = ((headers) => PostsBox.getPostsDelegate(offset, limit, headers))
  /// ```
  DatabasePutDelegate<T>? databasePutDelegate;

  /// Delegate to get data from local database
  ///
  /// ```dart
  /// ..databasePutDelegate = ((result) => PostsBox.putPostsDelegate(result))
  /// ```
  DatabaseGetDelegate<T>? databaseGetDelegate;

  /// For tests: simulates unparsed raw server response
  @visibleForTesting
  SimulateResponse? simulateResponse;

  /// Form data for this request
  Future<F>? formData;

  /// Flag indicating that this request cant be canceled from [RequestCollection]
  bool ignoreCancelations;

  /// Aditional interceptors for http instance
  Iterable<I> additionalInterceptors;

  void Function(T?)? onPrefetchFromDatabase;

  /// Executes this request and returns [Response] value
  Future<Response<T>> execute();

  /// Cancels current request if it is still executing
  void cancel();

  /// Collection of all running requests
  RequestCollection get requestCollection => RequestCollection.instance;

  /// Underlying http instance
  B? get httpInstance;
}
