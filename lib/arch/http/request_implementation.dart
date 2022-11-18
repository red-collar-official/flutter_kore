// ignore_for_file: invalid_use_of_visible_for_testing_member

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart' as dio;

import 'background_dio_transformer.dart';
import 'base_request.dart';

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
///  Future onError(DioError error, RetryHandler retry) async {
///    await retry();
///  }
///
///}
/// ```
abstract class RequestImplementation<T> extends BaseRequest<T> {
  RequestImplementation() : super();

  /// Default headers to be added to every instance
  Map<String, dynamic> get defaultHeaders => {};

  /// Default base url if [baseUrl] is not provided
  String get defaultBaseUrl;

  /// Default timeout if [timeout] is not provided
  int get defaultTimeoutInSeconds => 10;

  /// Print function for [Dio] logger
  void logPrint(Object obj);

  /// Function to retry error requests
  Future<dynamic> onError(dio.DioError error, RetryHandler retry);

  /// Function to add autharization headers to [Dio] instance
  void onAuthorization(dio.Dio dio);

  @override
  Future<Response<T>> execute() async {
    if (simulateResult != null) {
      if (simulateResult!.result != null) {
        await databasePutDelegate?.call(simulateResult!.result!);
      }

      return simulateResult!;
    }

    final client = _buildClient();

    dynamic data;

    if (formData != null) {
      data = await formData;
    } else {
      data = file ?? body;
    }

    if (simulateResponse != null) {
      return _simulateServerResponse();
    }

    final response = simulateResponse ?? (await _startRequest(client, data));

    if (response == null) {
      final databaseData = await databaseGetDelegate?.call(headers);

      return Response<T>(
        code: 0,
        error: 'not_recognized_error',
        result: databaseData,
        fromDatabase: databaseData != null,
      );
    }

    if (response is dio.DioError) {
      final databaseData = await databaseGetDelegate?.call(headers);

      return Response<T>(
        code: response.response?.statusCode ?? 0,
        headers: response.response?.headers.map,
        error: response.response?.data ?? response.response?.statusMessage ?? '',
        result: databaseData,
        fromDatabase: databaseData != null,
      );
    }

    dynamic result;

    final responseBody = response as dio.Response;

    if (parser == null) {
      result = responseBody.data;
    } else {
      result = await parser!(responseBody.data, responseBody.headers.map);
    }

    if (result != null) {
      await databasePutDelegate?.call(result);
    }

    return Response<T>(
      code: responseBody.statusCode ?? 0,
      headers: responseBody.headers.map,
      result: result,
    );
  }

  /// For tests: constructs simulated server response
  Future<Response<T>> _simulateServerResponse() async {
    dynamic result;

    if (parser == null) {
      result = jsonDecode(simulateResponse!.data);
    } else {
      result = await parser!(jsonDecode(simulateResponse!.data), simulateResponse!.headers);
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
    client.options.connectTimeout = Duration(seconds: requestTimeout ~/ 2).inMilliseconds;
    client.options.receiveTimeout = Duration(seconds: requestTimeout ~/ 2).inMilliseconds;

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

    client.transformer = BackgroundTransformer();

    return client;
  }

  /// Function to retry request
  Future<dynamic> _retryRequest(dio.Dio client, dynamic data, dio.DioError error) async {
    try {
      return await constructRequest(client, method, data);
    } catch (e) {
      return error;
    }
  }

  /// Constructs request for [Dio] and executes it
  Future<dynamic> _startRequest(dio.Dio client, dynamic data) async {
    dio.Response? response;

    try {
      response = await constructRequest(client, method, data);
    } on dio.DioError catch (error) {
      return onError(error, () => _retryRequest(client, data, error));
    }

    return response;
  }

  /// Adds data to dio, adds autharization headers if needed and returns [Future] with request results
  Future<dio.Response> constructRequest(dio.Dio dio, RequestMethod method, dynamic encodedData) async {
    dynamic data;

    if (encodedData != null && encodedData is File) {
      data = encodedData.openRead();
    } else {
      data = encodedData;
    }

    if (requiresLogin) {
      onAuthorization(dio);
    }

    switch (method) {
      case RequestMethod.get:
        return dio.getUri(_fixDioUrlForQueryUri(query ?? {}, url ?? ''));
      case RequestMethod.post:
        return dio.postUri(_fixDioUrlForQueryUri(query ?? {}, url ?? ''), data: data);
      case RequestMethod.put:
        return dio.putUri(_fixDioUrlForQueryUri(query ?? {}, url ?? ''), data: data);
      case RequestMethod.delete:
        return dio.delete(Uri.encodeFull(url ?? ''));
      case RequestMethod.patch:
        return dio.patch(Uri.encodeFull(url ?? ''), data: encodedData);
      default:
        return dio.get(Uri.encodeFull(url ?? ''));
    }
  }

  /// Utility method to fix [Dio] queries
  Uri _fixDioUrlForQueryUri(Map<String, dynamic> queryParameters, String url) {
    final finalUrl = url;

    if (queryParameters.isEmpty) {
      return Uri.parse((baseUrl ?? '') + finalUrl);
    }

    final correctedMap = {
      for (var value in queryParameters.keys)
        value.toString():
            queryParameters[value] is List ? queryParameters[value].map((value) => value?.toString()) : queryParameters[value]?.toString(),
    };

    final uri = Uri.parse((baseUrl ?? '') + finalUrl);

    final resultUri =
        Uri(scheme: uri.scheme, host: uri.host, path: uri.path.substring(1), queryParameters: correctedMap.isEmpty ? null : correctedMap);

    return resultUri;
  }
}
