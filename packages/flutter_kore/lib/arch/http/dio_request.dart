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
///  void decorateRequest(Dio dio) {
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

  /// Shared singleton [dio.Dio] instance used by all requests.
  /// Initialized lazily on first use via [_buildClient].
  static dio.Dio? _sharedDio;

  /// Test flag to return null response
  @visibleForTesting
  var forceReturnNullFromRequest = false;

  DioRequest() : super() {
    _getOrBuildClient();
  }

  /// Default settings for all requests
  RequestSettings<dio.Interceptor> get defaultSettings;

  // coverage:ignore-start
  /// Function to retry error requests
  Future<dynamic> onError(dio.DioException error, RetryHandler retry) async {
    return error;
  }

  /// Function to add additional data to the shared [dio.Dio] instance
  void decorateRequest(dio.Dio dio, dio.Options options) {}
  // coverage:ignore-end

  @override
  Future<Response<T>> execute() async {
    if (baseUrl?.isEmpty ?? true) {
      throw const IllegalArgumentException(message: 'Base url not set');
    }

    if (url?.isEmpty ?? true) {
      throw const IllegalArgumentException(message: 'Path url not set');
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

    final client = httpInstance;

    dynamic data;

    if (formData != null) {
      data = await formData;
    } else {
      data = body is Map || body is List ? jsonEncode(body) : body;
    }

    if (cancelToken.isCancelled) {
      if (requestCollection.cancelReasonProcessingCompleter != null) {
        await RequestCollection
            .instance
            .cancelReasonProcessingCompleter!
            .future;
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
        defaultSettings.exceptionPrint?.call(e, trace);

        requestCollection.removeRequest(this);

        return Response<T>(
          code: 0,
          error: const NotRecognizedHttpException(message: 'Unknown error'),
        );
      }
    }

    if (result != null) {
      try {
        await databasePutDelegate?.call(result);
      } catch (e, trace) {
        defaultSettings.exceptionPrint?.call(e, trace);
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
        defaultSettings.exceptionPrint?.call(e, trace);
      }
    }
  }

  /// Processes empty dio response
  Future<Response<T>> processNoResponse() async {
    try {
      final databaseData = await databaseGetDelegate?.call(headers);

      return Response<T>(
        code: 0,
        error: const NotRecognizedHttpException(message: 'Unknown error'),
        result: databaseData,
        fromDatabase: databaseData != null,
      );
    } catch (e, trace) {
      defaultSettings.exceptionPrint?.call(e, trace);

      return Response<T>(
        code: 0,
        error: const NotRecognizedHttpException(message: 'Unknown error'),
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
      defaultSettings.exceptionPrint?.call(e, trace);

      return Response<T>(
        code: 0,
        error: const NotRecognizedHttpException(message: 'Unknown error'),
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
      result = await parser!(simulateResponse!.data, simulateResponse!.headers);
    }

    await databasePutDelegate?.call(result);

    return Response<T>(
      code: simulateResponse!.statusCode,
      headers: simulateResponse!.headers,
      result: result,
    );
  }

  /// Returns the shared [dio.Dio] instance, building it on first call.
  ///
  /// The singleton is configured with only the base URL, transformer, and
  /// default interceptors — settings that are global and do not vary per
  /// request. Per-request concerns (headers, timeouts) are passed via
  /// [dio.Options] at call time inside [constructRequest].
  dio.Dio _getOrBuildClient() {
    _sharedDio ??= _buildClient();

    return _sharedDio!;
  }

  /// Builds the shared [dio.Dio] singleton.
  ///
  /// Only global, request-agnostic settings belong here. Per-request options
  /// (headers, timeouts) are passed directly to each HTTP verb call.
  dio.Dio _buildClient() {
    final client = dio.Dio();

    if (defaultSettings.defaultInterceptors.isNotEmpty) {
      client.interceptors.addAll(defaultSettings.defaultInterceptors);
    }

    client.interceptors.add(
      dio.LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: defaultSettings.logPrint ?? (_) {},
      ),
    );

    client.transformer = dio.BackgroundTransformer();

    return client;
  }

  /// Builds a [dio.Options] object carrying all per-request settings:
  /// merged headers (defaults + request-level) and connect/receive timeouts.
  dio.Options _buildRequestOptions() {
    final requestTimeout =
        timeout?.inSeconds ?? defaultSettings.defaultTimeoutInSeconds;
    final timeoutDuration = Duration(seconds: requestTimeout ~/ 2);

    final mergedHeaders = Map<String, dynamic>.from(
      defaultSettings.defaultHeaders,
    );

    if (headers != null) {
      mergedHeaders.addAll(headers!);
    }

    return dio.Options(
      headers: mergedHeaders,
      sendTimeout: timeoutDuration,
      receiveTimeout: timeoutDuration,
    );
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
      defaultSettings.exceptionPrint?.call(e, trace);

      return error;
    }
  }

  /// Constructs request for [dio.Dio] and executes it
  Future<dynamic> _startRequest(dio.Dio client, dynamic data) async {
    dio.Response? response;

    try {
      response = await constructRequest(client, method, data);
    } on dio.DioException catch (error, trace) {
      defaultSettings.exceptionPrint?.call(error, trace);

      if (error.type == dio.DioExceptionType.cancel) {
        if (requestCollection.cancelReasonProcessingCompleter != null) {
          await RequestCollection
              .instance
              .cancelReasonProcessingCompleter!
              .future;
          return _retryRequest(client, data, error);
        }
      }

      return onError(error, () => _retryRequest(client, data, error));
    }

    return response;
  }

  /// Executes the appropriate HTTP verb using named [queryParameters] and
  /// per-request [dio.Options]. Headers and timeouts travel with the call
  /// rather than being stamped onto the shared client.
  Future<dio.Response> constructRequest(
    dio.Dio client,
    RequestMethod method,
    dynamic encodedData,
  ) async {
    cancelToken = dio.CancelToken();

    final options = _buildRequestOptions();
    final queryParams = (query?.isNotEmpty ?? false) ? query : null;
    final path = (baseUrl ?? defaultSettings.defaultBaseUrl) + (url ?? '');

    decorateRequest(client, options);

    switch (method) {
      case .get:
        return client.get(
          path,
          queryParameters: queryParams,
          options: options,
          cancelToken: cancelToken,
        );
      case .post:
        return client.post(
          path,
          data: encodedData,
          queryParameters: queryParams,
          options: options,
          cancelToken: cancelToken,
        );
      case .put:
        return client.put(
          path,
          data: encodedData,
          queryParameters: queryParams,
          options: options,
          cancelToken: cancelToken,
        );
      case .delete:
        return client.delete(
          path,
          data: encodedData,
          queryParameters: queryParams,
          options: options,
          cancelToken: cancelToken,
        );
      case .patch:
        return client.patch(
          path,
          data: encodedData,
          queryParameters: queryParams,
          options: options,
          cancelToken: cancelToken,
        );
    }
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

  /// Underlying [dio.Dio] instance — returns the shared singleton.
  @override
  dio.Dio get httpInstance => _sharedDio!;
}
