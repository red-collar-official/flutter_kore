import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart' as dio;
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:test/test.dart';
import 'package:umvvm/umvvm.dart';

import '../helpers/delay_utility.dart';
import '../mocks/request.dart';

const testMockPath = testBaseUrl + testPath;

const testPath = '/qwerty';
const testHeaders = {'testParam': 1};
const testBaseUrl = 'https://test.com';
const testParam = 'testParam';
const testBody = 'testParam';
const testBodyMap = {'testParam': 1};
final testFormData = dio.FormData();
const testBodyMapWithList = {
  'testParam': [1, 2]
};

Uri _fixDioUrlForQueryUri(
  String baseUrl,
  Map<String, dynamic> queryParameters,
  String url,
) {
  final finalUrl = url;

  if (queryParameters.isEmpty) {
    return Uri.parse(baseUrl + finalUrl);
  }

  final correctedMap = {
    for (final value in queryParameters.keys)
      value.toString(): queryParameters[value] is List
          ? queryParameters[value].map((value) => value?.toString())
          : queryParameters[value]?.toString(),
  };

  final uri = Uri.parse(baseUrl + finalUrl);

  final resultUri = Uri(
      scheme: uri.scheme,
      host: uri.host,
      path: uri.path.substring(1),
      queryParameters: correctedMap.isEmpty ? null : correctedMap);

  return resultUri;
}

void addTestErrorResponsesToDio(dio.Dio dio) {
  final dioAdapter = DioAdapter(dio: dio);

  // ignore: cascade_invocations
  dioAdapter.onGet(
    testMockPath,
    (server) => server.reply(
      500,
      null,
      delay: const Duration(milliseconds: 100),
    ),
  );
}

void addTestNullResponsesToDio(dio.Dio dio) {
  final dioAdapter = DioAdapter(dio: dio);

  // ignore: cascade_invocations
  dioAdapter.onGet(
    testMockPath,
    (server) {
      server.reply(500, null);
    },
  );
}

void addTestResponsesToDioForHeadersTest(dio.Dio dio) {
  final dioAdapter = DioAdapter(dio: dio);

  // ignore: cascade_invocations
  dioAdapter.onGet(
    testMockPath,
    (server) => server.reply(
      200,
      1,
      delay: const Duration(milliseconds: 100),
    ),
    headers: testHeaders,
  );
}

void addTestResponsesToDio(dio.Dio dio) {
  final dioAdapter = DioAdapter(dio: dio);

  // ignore: cascade_invocations
  dioAdapter.onGet(
    testMockPath,
    (server) => server.reply(
      200,
      1,
      delay: const Duration(milliseconds: 100),
    ),
  );

  // ignore: cascade_invocations
  dioAdapter.onPost(
    testMockPath,
    (server) => server.reply(
      200,
      1,
      delay: const Duration(milliseconds: 100),
    ),
  );

  // ignore: cascade_invocations
  dioAdapter.onPut(
    testMockPath,
    (server) => server.reply(
      200,
      1,
      delay: const Duration(milliseconds: 100),
    ),
  );

  // ignore: cascade_invocations
  dioAdapter.onPatch(
    testMockPath,
    (server) => server.reply(
      200,
      1,
      delay: const Duration(milliseconds: 100),
    ),
  );

  // ignore: cascade_invocations
  dioAdapter.onDelete(
    testMockPath,
    (server) => server.reply(
      200,
      1,
      delay: const Duration(milliseconds: 100),
    ),
  );
}

void addTestResponsesForParamsToDio(dio.Dio dio) {
  final dioAdapter = DioAdapter(dio: dio);

  // ignore: cascade_invocations
  dioAdapter.onGet(
    _fixDioUrlForQueryUri(testBaseUrl, testBodyMap, testPath).toString(),
    (server) => server.reply(
      200,
      1,
      delay: const Duration(milliseconds: 100),
    ),
  );

  // ignore: cascade_invocations
  dioAdapter.onPost(
    testMockPath,
    (server) => server.reply(
      200,
      1,
      delay: const Duration(milliseconds: 100),
    ),
    data: jsonEncode(testBodyMap),
  );

  // ignore: cascade_invocations
  dioAdapter.onPatch(
    testMockPath,
    (server) => server.reply(
      200,
      1,
      delay: const Duration(milliseconds: 100),
    ),
    data: testBody,
  );

  // ignore: cascade_invocations
  dioAdapter.onPut(
    testMockPath,
    (server) => server.reply(
      200,
      1,
      delay: const Duration(milliseconds: 100),
    ),
    data: testFormData,
  );
}

void main() {
  group('Request tests', () {
    int cache = 0;

    setUp(() async {
      UMvvmApp.isInTestMode = true;
      cache = 0;
    });

    test('Request get test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request preconditions test', () async {
      final request = HttpRequest<int>()..method = RequestMethod.get;

      expect(
        () async => request.execute(),
        throwsA(isA<IllegalArgumentException>()),
      );

      final request2 = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl;

      expect(
        () async => request2.execute(),
        throwsA(isA<IllegalArgumentException>()),
      );
    });

    test('Request simulate result test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..simulateResult = Response(code: 200, result: 1);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request additionalInterceptors test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..additionalInterceptors = [
          dio.LogInterceptor(),
        ]
        ..simulateResult = Response(code: 200, result: 1);

      expect(
        request.dioInstance!.interceptors
                .indexWhere((element) => element is dio.LogInterceptor) !=
            -1,
        true,
      );
    });

    test('Request defaultInterceptors test', () async {
      final request = HttpRequest2<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..simulateResult = Response(code: 200, result: 1);

      expect(
        request.dioInstance!.interceptors
                .indexWhere((element) => element is dio.LogInterceptor) !=
            -1,
        true,
      );
    });

    test('Request simulate response test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..simulateResponse = SimulateResponse(
          data: 1,
        );

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request simulate response with parser test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..simulateResponse = SimulateResponse(
          data: 1,
        )
        ..parser = (result, headers) async {
          return result;
        };

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request parser test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..parser = (result, headers) async {
          return result;
        };

      addTestResponsesToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request parser fail test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..parser = (result, headers) async {
          throw Exception();
        };

      addTestResponsesToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, false);
      expect(result.error is NotRecognizedHttpException, true);
    });

    test('Request empty response test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..forceReturnNullFromRequest = true;

      addTestNullResponsesToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, false);
      expect(result.error is NotRecognizedHttpException, true);
    });

    test('Request empty response database error test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..databaseGetDelegate = (headers) async {
          throw Exception();
        }
        ..forceReturnNullFromRequest = true;

      addTestNullResponsesToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, false);
      expect(result.error is NotRecognizedHttpException, true);
    });

    test('Request database error test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..databaseGetDelegate = (headers) async {
          throw Exception();
        }
        ..onPrefetchFromDatabase = (parsedItem) async {
          throw Exception();
        };

      addTestErrorResponsesToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, false);
      expect(result.error is NotRecognizedHttpException, true);
    });

    test('Request database test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..databaseGetDelegate = (headers) async {
          return cache;
        }
        ..databasePutDelegate = (parsedItem) async {
          cache = parsedItem;
        };

      addTestResponsesToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);

      var storedValue = 0;

      final request2 = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..databaseGetDelegate = (headers) async {
          return cache;
        }
        ..onPrefetchFromDatabase = (stored) async {
          storedValue = stored ?? 0;
        }
        ..databasePutDelegate = (parsedItem) async {
          cache = parsedItem;
        };

      addTestErrorResponsesToDio(request2.dioInstance!);

      final result2 = await request2.execute();

      expect(result2.isSuccessful, false);
      expect(result2.isSuccessfulFromDatabase, true);
      expect(result2.result, 1);
      expect(storedValue, 1);
    });

    test('Request database put error test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..databaseGetDelegate = (headers) async {
          return cache;
        }
        ..databasePutDelegate = (parsedItem) async {
          throw Exception();
        };

      addTestResponsesToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);

      var storedValue = 0;

      final request2 = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..databaseGetDelegate = (headers) async {
          return cache;
        }
        ..onPrefetchFromDatabase = (stored) async {
          storedValue = stored ?? 0;
        }
        ..databasePutDelegate = (parsedItem) async {
          cache = parsedItem;
        };

      addTestErrorResponsesToDio(request2.dioInstance!);

      final result2 = await request2.execute();

      expect(result2.isSuccessful, false);
      expect(result2.isSuccessfulFromDatabase, true);
      expect(result2.result, 0);
      expect(storedValue, 0);
    });

    test('Request post test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.post
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request patch test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.patch
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request delete test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.delete
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request put test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.put
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request get with params test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..query = testBodyMap
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesForParamsToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request get with params with list test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..query = testBodyMapWithList
        ..baseUrl = testBaseUrl
        ..url = testPath;

      final dioAdapter = DioAdapter(dio: request.dioInstance!);

      // ignore: cascade_invocations
      dioAdapter.onGet(
        _fixDioUrlForQueryUri(testBaseUrl, testBodyMapWithList, testPath)
            .toString(),
        (server) => server.reply(
          200,
          1,
          delay: const Duration(milliseconds: 100),
        ),
      );

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request post with params test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.post
        ..body = testBodyMap
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesForParamsToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request put with params test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.put
        ..body = {}
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesForParamsToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, false);
    });

    test('Request patch with params test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.patch
        ..body = testBody
        ..baseUrl = testBaseUrl
        ..url = testPath;

      addTestResponsesForParamsToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request put with form data test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.put
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..formData = Future.value(testFormData);

      addTestResponsesForParamsToDio(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request headers test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.get
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..headers = testHeaders;

      addTestResponsesToDioForHeadersTest(request.dioInstance!);

      final result = await request.execute();

      expect(result.isSuccessful, true);
      expect(result.result, 1);
    });

    test('Request cancel before execute test', () async {
      final request = HttpRequest<int>()
        ..method = RequestMethod.post
        ..baseUrl = testBaseUrl
        ..url = testPath
        ..body = testBodyMap;

      addTestResponsesForParamsToDio(request.dioInstance!);

      RequestCollection.instance.cancelReasonProcessingCompleter = Completer();

      request.cancel();

      late Response<int> response;

      unawaited(request.execute().then((value) {
        response = value;
      }));

      unawaited(request.execute());

      await DelayUtility.pause();

      RequestCollection.instance.cancelReasonProcessingCompleter!.complete();

      await DelayUtility.pause(millis: 200);

      expect(response.isSuccessful, true);
      expect(response.result, 1);
    });
  });
}
