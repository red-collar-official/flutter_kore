// ignore_for_file: implementation_imports, depend_on_referenced_packages

import 'dart:async';

import 'package:flutter_kore_template/domain/global/global.dart';
import 'package:flutter_kore_template/domain/interactors/interactors.dart';
import 'package:flutter_kore_template/resources/app_settings.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter_kore/flutter_kore.dart';
import 'package:flutter_kore_template/utilities/utilities.dart';

class HttpRequest<T> extends DioRequest<T> {
  HttpRequest({
    this.doNotRetry = false,
  }) : super();

  final bool doNotRetry;

  @override
  RequestSettings get defaultSettings => RequestSettings(
        defaultBaseUrl: Flavor.dev.baseUrl,
        logPrint: LogUtility.printMessage,
        exceptionPrint: LogUtility.e,
        defaultTimeoutInSeconds: AppSettings.defaultRequestTimeoutInSeconds,
      );

  @override
  void onAuthorization(dio.Dio dio) {
    if (!requiresLogin) {
      return;
    }

    // add logic for request auth
    // example:

    // final token = app.instances.get<AuthorizationInteractor>().state.jwt;
    //
    // if (token != null) {
    //   dio.options.headers['Authorization'] = 'Bearer $token';
    // }
  }

  @override
  Future onError(dio.DioException error, RetryHandler retry) async {
    if (doNotRetry) {
      return error;
    }

    if (error.type == dio.DioExceptionType.cancel) {
      return error;
    }

    final statusCode = error.response?.statusCode;

    if (statusCode == 401 || statusCode == 403) {
      final authorizationInteractor =
          app.instances.get<AuthorizationInteractor>();

      await requestCollection.cancelAllRequests(
        retryRequestsAfterProcessing: true,
        cancelReasonProcessor: () async {
          await authorizationInteractor.requestNewToken();
        },
      );

      if (!authorizationInteractor.isAuthorized) {
        return error;
      }

      return retry();
    }

    return error;
  }
}
