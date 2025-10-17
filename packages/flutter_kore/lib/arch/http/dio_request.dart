// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:flutter_kore/flutter_kore.dart';

/// Function that handles retry for given [BaseRequest]
typedef RetryHandler = Future<dynamic> Function();

/// Function that handles authorization for given [BaseRequest]
typedef AuthHandler = void Function(dio.Dio dio);

/// Main implementation for Http requests using [dio.Dio]
///
/// ```dart
/// class HttpRequest<T> extends DioRequest<T> {
///   HttpRequest() : super();
///
///  @override
///  RequestSettings get defaultSettings => RequestSettings(
///        logPrint: (message) {},
///        exceptionPrint: (error, trace) {},
///      );
///
///  @override
///  void onAuthorization(Dio dio) {
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
abstract class DioRequest<T> 
    extends BaseRequest<T, dio.Interceptor, dio.Dio, dio.FormData> {
  /// Dio cancel token for this request
  /// changes after every [execute] call
  var cancelToken = dio.CancelToken();

  /// Underlying [dio.Dio] instance
  late final _dio = _buildClient();

  /// Test flag to return null response
  @visibleForTesting
  bool forceReturnNullFromRequest = false;

  DioRequest() : super();

  /// Default settings for all requests
  RequestSettings<dio.Interceptor> get defaultSettings;

  // coverage:ignore-start
  /// Function to retry error requests
  Future<dynamic> onError(dio.DioException error, RetryHandler retry) async {
    return error;
  }

  /// Function to add authorization headers to [dio.Dio] instance
  void onAuthorization(dio.Dio dio) {}
  // coverage:ignore-end

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
      data = body is Map || body is List ? jsonEncode(body) : body;
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
        defaultSettings.exceptionPrint(e, trace);

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
        defaultSettings.exceptionPrint(e, trace);
      }
    }

    requestCollection.removeRequest(this);

    return Response<T>(
      code: responseBody.statusCode ?? 0,
      headers: responseBody.headers.map,
      result: result,
    );
  }

  /// Gets cached data from database if prefetch handler provided to request
  Future<void> getFromDatabase() async {
    if (onPrefetchFromDatabase != null) {
      try {
        final databaseData = await databaseGetDelegate?.call(headers);

        onPrefetchFromDatabase!(databaseData);
      } catch (e, trace) {
        defaultSettings.exceptionPrint(e, trace);
      }
    }
  }

  /// Processes empty dio response
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
      defaultSettings.exceptionPrint(e, trace);

      return Response<T>(
        code: 0,
        error: NotRecognizedHttpException(message: 'Unknown error'),
      );
    }
  }

  /// Processes generic [dio.DioException]
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
      defaultSettings.exceptionPrint(e, trace);

      return Response<T>(
        code: 0,
        error: NotRecognizedHttpException(message: 'Unknown error'),
      );
    }
  }

  /// Returns simulated result for dio request
  /// if simulate result value is provided
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

  /// Builds [dio.Dio] client for this request
  dio.Dio _buildClient() {
    final client = dio.Dio();

    client.options.baseUrl = baseUrl ?? defaultSettings.defaultBaseUrl;

    final requestTimeout =
        timeout?.inSeconds ?? defaultSettings.defaultTimeoutInSeconds;
    client.options.connectTimeout = Duration(seconds: requestTimeout ~/ 2);
    client.options.receiveTimeout = Duration(seconds: requestTimeout ~/ 2);

    final resultHeaders = Map<String, dynamic>.from(
      defaultSettings.defaultHeaders,
    );

    if (headers != null) {
      resultHeaders.addAll(headers!);
    }

    client.options.headers = resultHeaders;

    client.interceptors.addAll([
      dio.LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: defaultSettings.logPrint,
      ),
    ]);

    if (additionalInterceptors.isNotEmpty) {
      client.interceptors.addAll(additionalInterceptors);
    }

    if (defaultSettings.defaultInterceptors.isNotEmpty) {
      client.interceptors.addAll(defaultSettings.defaultInterceptors);
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
      defaultSettings.exceptionPrint(e, trace);

      return error;
    }
  }

  /// Constructs request for [dio.Dio] and executes it
  Future<dynamic> _startRequest(dio.Dio client, dynamic data) async {
    dio.Response? response;

    try {
      response = await constructRequest(client, method, data);
    } on dio.DioException catch (error, trace) {
      defaultSettings.exceptionPrint(error, trace);

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

    if (encodedData != null) {
      data = encodedData;
    }

    if (requiresLogin) {
      onAuthorization(client);
    }

    cancelToken = dio.CancelToken();

    switch (method) {
      case RequestMethod.get:
        return client.getUri(
          constructUri(query ?? {}, url ?? ''),
          cancelToken: cancelToken,
        );
      case RequestMethod.post:
        return client.postUri(
          constructUri(query ?? {}, url ?? ''),
          data: data,
          cancelToken: cancelToken,
        );
      case RequestMethod.put:
        return client.putUri(
          constructUri(query ?? {}, url ?? ''),
          data: data,
          cancelToken: cancelToken,
        );
      case RequestMethod.delete:
        return client.deleteUri(
          constructUri(query ?? {}, url ?? ''),
          data: data,
          cancelToken: cancelToken,
        );
      case RequestMethod.patch:
        return client.patchUri(
          constructUri(query ?? {}, url ?? ''),
          data: data,
          cancelToken: cancelToken,
        );
    }
  }

  /// Utility method to construct [dio.Dio] queries
  Uri constructUri(Map<String, dynamic> queryParameters, String url) {
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
      queryParameters: correctedMap.isEmpty ? null : correctedMap,
    );

    return resultUri;
  }

  /// Cancels current request if it is still executing
  @mustCallSuper
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

  /// Underlying [dio.Dio] instance
  @override
  dio.Dio? get httpInstance => _dio;
}
