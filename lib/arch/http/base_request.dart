import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:umvvm/umvvm.dart';

/// Main class to hold [Dio] response
class Response<ItemType> {
  /// Parsed result of request
  ItemType? result;

  /// Error of [Dio] request
  Object? error;

  /// Status code for this request
  int code;

  /// Headers for response of this request
  Map? headers;

  /// Flag to detect that [result] was from database
  bool fromDatabase;

  /// Checks that error is not null and status code is less than 400
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
abstract class BaseRequest<T> {
  BaseRequest({
    this.method = RequestMethod.get,
    this.url,
    this.parser,
    this.file,
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

  /// body for this request - can be [Map] or [List]
  dynamic body;

  /// Query for this request - will be added to the end of the [url]
  Map<String, dynamic>? query;

  /// File for this request
  File? file;

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
  Future<FormData>? formData;

  /// Flag indicating that this request cant be canceled from [RequestCollection]
  bool ignoreCancelations;

  /// Aditional interceptors for [Dio] instance
  Iterable<Interceptor> additionalInterceptors;

  void Function(T?)? onPrefetchFromDatabase;

  /// Executes this request and returns [Response] value
  Future<Response<T>> execute();

  /// Cancels current request if it is still executing
  void cancel();

  /// Collection of all running requests
  RequestCollection get requestCollection => RequestCollection.instance;

  Dio? get dioInstance;
}
