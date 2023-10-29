// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:umvvm/umvvm.dart';

typedef RetryHandler = Future<dynamic> Function();
typedef AuthHandler = void Function(dio.Dio dio);

/// Main implementation for Http requests using [Dio]
///
/// ```dart
/// class HttpRequest<T> extends RequestImplementation<T> {
///   HttpRequest() : super();
///
///   @override
///   Map<String, dynamic> get defaultHeaders => {};
///
///   @override
///   String get defaultBaseUrl => '';
///
///   @override
///   void logPrint(Object obj) {
///     if (kDebugMode) {
///       print(obj);
///     }
///   }
///
///  @override
///  void onAutharization(Dio dio) {
///    // ignore
///  }
///
///  @override
///  Future onError(DioError error, RetryHandler retry) {
///    return retry();
///  }
///
///}
/// ```
abstract class RequestImplementation<T> extends BaseRequest<T> {
  var cancelToken = dio.CancelToken();
  late final _dio = _buildClient();

  @visibleForTesting
  bool forceReturnNullFromRequest = false;

  RequestImplementation() : super();

  /// Default headers to be added to every instance
  Map<String, dynamic> get defaultHeaders => {};

  /// Default base url if [baseUrl] is not provided
  String get defaultBaseUrl;

  /// Default timeout if [timeout] is not provided
  int get defaultTimeoutInSeconds => 10;

  /// Default timeout if [timeout] is not provided
  Iterable<dio.Interceptor> get defaultInterceptors => [];

  /// Print function for [Dio] logger
  void logPrint(Object obj);

  /// Print function for [Dio] logger
  void exceptionPrint(Object error, StackTrace trace);

  /// Function to retry error requests
  Future<dynamic> onError(dio.DioException error, RetryHandler retry);

  /// Function to add autharization headers to [Dio] instance
  void onAuthorization(dio.Dio dio);

  @override
  Future<Response<T>> execute() async {
    if (baseUrl?.isEmpty ?? true) {
      throw IllegalArgumentException(message: 'Base url not set');
    }

    if (url?.isEmpty ?? true) {
      throw IllegalArgumentException(message: 'Path url not set');
    }

    requestCollection.addRequest(this);

    unawaited(getFromDatabase());

    final simulationResult = await simulateResultStep();

    if (simulationResult != null) {
      return simulationResult;
    }

    if (simulateResponse != null) {
      requestCollection.removeRequest(this);

      return _simulateServerResponse();
    }

    final client = _dio;

    dynamic data;

    if (formData != null) {
      data = await formData;
    } else {
      data = file ?? body;
    }

    if (cancelToken.isCancelled) {
      if (requestCollection.cancelReasonProcessingCompleter != null) {
        await RequestCollection
            .instance.cancelReasonProcessingCompleter!.future;
      }
    }

    final response = simulateResponse ?? (await _startRequest(client, data));

    if (response == null || forceReturnNullFromRequest) {
      requestCollection.removeRequest(this);

      return processNoResponse();
    }

    if (response is dio.DioException) {
      requestCollection.removeRequest(this);

      return processDioException(response, client, data);
    }

    dynamic result;

    final responseBody = response as dio.Response;

    if (parser == null) {
      result = responseBody.data;
    } else {
      try {
        result = await parser!(responseBody.data, responseBody.headers.map);
      } catch (e, trace) {
        exceptionPrint(e, trace);

        requestCollection.removeRequest(this);

        return Response<T>(
          code: 0,
          error: NotRecognizedHttpException(message: 'Unknown error'),
        );
      }
    }

    if (result != null) {
      try {
        await databasePutDelegate?.call(result);
      } catch (e, trace) {
        exceptionPrint(e, trace);
      }
    }

    requestCollection.removeRequest(this);

    return Response<T>(
      code: responseBody.statusCode ?? 0,
      headers: responseBody.headers.map,
      result: result,
    );
  }

  Future<void> getFromDatabase() async {
    if (onPrefetchFromDatabase != null) {
      try {
        final databaseData = await databaseGetDelegate?.call(headers);

        onPrefetchFromDatabase!(databaseData);
      } catch (e, trace) {
        exceptionPrint(e, trace);
      }
    }
  }

  Future<Response<T>> processNoResponse() async {
    try {
      final databaseData = await databaseGetDelegate?.call(headers);

      return Response<T>(
        code: 0,
        error: NotRecognizedHttpException(message: 'Unknown error'),
        result: databaseData,
        fromDatabase: databaseData != null,
      );
    } catch (e, trace) {
      exceptionPrint(e, trace);

      return Response<T>(
        code: 0,
        error: NotRecognizedHttpException(message: 'Unknown error'),
      );
    }
  }

  Future<Response<T>> processDioException(
    dio.DioException exception,
    dio.Dio client,
    dynamic data,
  ) async {
    try {
      final databaseData = await databaseGetDelegate?.call(headers);

      return Response<T>(
        code: exception.response?.statusCode ?? 0,
        headers: exception.response?.headers.map,
        error: exception,
        result: databaseData,
        fromDatabase: databaseData != null,
      );
    } catch (e, trace) {
      exceptionPrint(e, trace);

      return Response<T>(
        code: 0,
        error: NotRecognizedHttpException(message: 'Unknown error'),
      );
    }
  }

  Future<Response<T>?> simulateResultStep() async {
    if (simulateResult != null) {
      if (simulateResult!.result != null) {
        await databasePutDelegate?.call(simulateResult!.result as T);
      }

      return simulateResult!;
    }

    return null;
  }

  /// For tests: constructs simulated server response
  Future<Response<T>> _simulateServerResponse() async {
    dynamic result;

    if (parser == null) {
      result = simulateResponse!.data;
    } else {
      result = await parser!(
        simulateResponse!.data,
        simulateResponse!.headers,
      );
    }

    await databasePutDelegate?.call(result);

    return Response<T>(
      code: simulateResponse!.statusCode,
      headers: simulateResponse!.headers,
      result: result,
    );
  }

  /// Builds [Dio] client for this request
  dio.Dio _buildClient() {
    final client = dio.Dio();

    client.options.baseUrl = baseUrl ?? defaultBaseUrl;

    final requestTimeout = timeout?.inSeconds ?? defaultTimeoutInSeconds;
    client.options.connectTimeout = Duration(seconds: requestTimeout ~/ 2);
    client.options.receiveTimeout = Duration(seconds: requestTimeout ~/ 2);

    final resultHeaders = defaultHeaders;

    if (headers != null) {
      resultHeaders.addAll(headers!);
    }

    client.options.headers = resultHeaders;

    client.interceptors.addAll([
      dio.LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: logPrint,
      ),
    ]);

    if (additionalInterceptors.isNotEmpty) {
      client.interceptors.addAll(additionalInterceptors);
    }

    if (defaultInterceptors.isNotEmpty) {
      client.interceptors.addAll(defaultInterceptors);
    }

    client.transformer = dio.BackgroundTransformer();

    return client;
  }

  /// Function to retry request
  Future<dynamic> _retryRequest(
    dio.Dio client,
    dynamic data,
    dio.DioException error,
  ) async {
    try {
      return await constructRequest(client, method, data);
    } catch (e, trace) {
      exceptionPrint(e, trace);

      return error;
    }
  }

  /// Constructs request for [Dio] and executes it
  Future<dynamic> _startRequest(dio.Dio client, dynamic data) async {
    dio.Response? response;

    try {
      response = await constructRequest(client, method, data);
    } on dio.DioException catch (error, trace) {
      exceptionPrint(error, trace);

      if (error.type == dio.DioExceptionType.cancel) {
        if (requestCollection.cancelReasonProcessingCompleter != null) {
          await RequestCollection
              .instance.cancelReasonProcessingCompleter!.future;
          return _retryRequest(client, data, error);
        }
      }

      return onError(error, () => _retryRequest(client, data, error));
    }

    return response;
  }

  /// Adds data to dio, adds autharization headers if needed and returns [Future] with request results
  Future<dio.Response> constructRequest(
    dio.Dio client,
    RequestMethod method,
    dynamic encodedData,
  ) async {
    dynamic data;

    if (encodedData != null && encodedData is File) {
      data = encodedData.openRead();
    } else {
      data = encodedData;
    }

    if (requiresLogin) {
      onAuthorization(client);
    }

    cancelToken = dio.CancelToken();

    switch (method) {
      case RequestMethod.get:
        return client.getUri(
          _fixDioUrlForQueryUri(query ?? {}, url ?? ''),
          cancelToken: cancelToken,
        );
      case RequestMethod.post:
        return client.postUri(
          _fixDioUrlForQueryUri(query ?? {}, url ?? ''),
          data: data,
          cancelToken: cancelToken,
        );
      case RequestMethod.put:
        return client.putUri(
          _fixDioUrlForQueryUri(query ?? {}, url ?? ''),
          data: data,
          cancelToken: cancelToken,
        );
      case RequestMethod.delete:
        return client.deleteUri(
          _fixDioUrlForQueryUri(query ?? {}, url ?? ''),
          data: data,
          cancelToken: cancelToken,
        );
      case RequestMethod.patch:
        return client.patchUri(
          _fixDioUrlForQueryUri(query ?? {}, url ?? ''),
          data: data,
          cancelToken: cancelToken,
        );
      // coverage:ignore-start
      default:
        return client.get(
          Uri.encodeFull(url ?? ''),
          cancelToken: cancelToken,
        );
      // coverage:ignore-end
    }
  }

  /// Utility method to fix [Dio] queries
  Uri _fixDioUrlForQueryUri(Map<String, dynamic> queryParameters, String url) {
    final finalUrl = url;

    if (queryParameters.isEmpty) {
      return Uri.parse((baseUrl ?? '') + finalUrl);
    }

    final correctedMap = {
      for (final value in queryParameters.keys)
        value.toString(): queryParameters[value] is List
            ? queryParameters[value].map((value) => value?.toString())
            : queryParameters[value]?.toString(),
    };

    final uri = Uri.parse((baseUrl ?? '') + finalUrl);

    final resultUri = Uri(
        scheme: uri.scheme,
        host: uri.host,
        path: uri.path.substring(1),
        queryParameters: correctedMap.isEmpty ? null : correctedMap);

    return resultUri;
  }

  @override
  void cancel() {
    if (ignoreCancelations) {
      return;
    }

    try {
      cancelToken.cancel();
    } catch (e) {
      // ignore
    }
  }

  @override
  dio.Dio? get dioInstance => _dio;
}
