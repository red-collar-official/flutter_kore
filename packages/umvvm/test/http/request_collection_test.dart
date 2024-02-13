import 'dart:async';

import 'package:dio/dio.dart' as dio;
import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/delay_utility.dart';
import '../mocks/request.dart';
import 'request_test.dart';

void main() {
  group('RequestCollection tests', () {
    setUp(() async {
      UMvvmApp.isInTestMode = true;
    });

    test('RequestCollection cancel test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.post
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesToDio(request.dioInstance!);

      final request2 = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesToDio(request2.dioInstance!);

      final collection = RequestCollection.instance;

      late Response<int> response1;
      late Response<int> response2;

      unawaited(request.execute().then((value) {
        response1 = value;
      }));

      unawaited(request2.execute().then((value) {
        response2 = value;
      }));

      await DelayUtility.pause();

      await collection.cancelAllRequests();

      await DelayUtility.pause();

      expect(response1.isSuccessful, false);
      expect(response2.isSuccessful, false);

      expect(
        (response1.error as dio.DioException).type == dio.DioExceptionType.cancel,
        true,
      );
      expect(
        (response2.error as dio.DioException).type == dio.DioExceptionType.cancel,
        true,
      );
    });

    test('RequestCollection cancel with retry test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesToDio(request.dioInstance!);

      final request2 = HttpRequest<int>()
        ..method = RequestMethod.post
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesToDio(request2.dioInstance!);

      final collection = RequestCollection.instance;

      late Response<int> response1;
      late Response<int> response2;

      unawaited(request.execute().then((value) {
        response1 = value;
      }));

      unawaited(request2.execute().then((value) {
        response2 = value;
      }));

      await DelayUtility.pause();

      await collection.cancelAllRequests(
        cancelReasonProcessor: () async {
          await DelayUtility.pause();
        },
        retryRequestsAfterProcessing: true,
      );

      await DelayUtility.pause(millis: 200);

      expect(response1.isSuccessful, true);
      expect(response2.isSuccessful, true);
    });

    test('RequestCollection remove all test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.post
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesToDio(request.dioInstance!);

      final request2 = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesToDio(request2.dioInstance!);

      final collection = RequestCollection.instance;

      unawaited(request.execute());

      unawaited(request2.execute());

      await DelayUtility.pause();

      collection.removeAllRequests();

      expect(collection.requests.length, 0);

      collection.removeAllRequests();

      expect(collection.requests.length, 0);
    });
  });
}
