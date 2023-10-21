import 'dart:async';

import 'package:umvvm/umvvm.dart';

/// Collection of currently running requests
class RequestCollection {
  RequestCollection._internal();

  static final RequestCollection _singleton = RequestCollection._internal();

  static RequestCollection get instance {
    return _singleton;
  }

  final List<BaseRequest> requests = [];
  Completer? cancelReasonProcessingCompleter;

  /// Cancels all requests in collection.
  /// If [retryRequestsAfterProcessing] is true then every request
  /// will be retried after [cancelReasonProcessor] is finished
  Future<void> cancelAllRequests({
    Future Function()? cancelReasonProcessor,
    bool retryRequestsAfterProcessing = false,
  }) async {
    final alreadyWaitingForRetry = cancelReasonProcessingCompleter != null;

    if (retryRequestsAfterProcessing && !alreadyWaitingForRetry) {
      cancelReasonProcessingCompleter = Completer();
    }

    for (final element in requests) {
      element.cancel();
    }

    if (cancelReasonProcessor != null) {
      await cancelReasonProcessor();
    }

    if (retryRequestsAfterProcessing) {
      if (!(cancelReasonProcessingCompleter?.isCompleted ?? true)) {
        cancelReasonProcessingCompleter?.complete();
      }

      cancelReasonProcessingCompleter = null;
    }
  }

  void addRequest(BaseRequest request) {
    requests.add(request);
  }

  void removeRequest(BaseRequest request) {
    requests.remove(request);
  }

  void removeAllRequests() {
    requests.removeRange(0, requests.length - 1);
  }
}
